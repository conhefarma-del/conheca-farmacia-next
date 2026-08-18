-- =====================================================================
-- 188: Papel de cada fármaco em cada alvo molecular (drug_target_roles)
--      Substrato / inibidor / indutor de CYP450, COX, transportadores
--      (P-gp/BCRP/OATP), MAO e outras enzimas (VKORC1, G6PD, TPMT,
--      PDE5, HMG-CoA redutase).
--
-- Motivação: a secção "Metabolismo" do perfil de cada fármaco
-- (/medicamento/[slug]) mostra o mapa estruturado fármaco ↔ alvo.
-- As linhas nascem do parse dos textos de molecular_targets
-- (substrates/inhibitors/inducers) a casar com os nomes reais dos
-- fármacos da BD — sem conteúdo inventado: source_pt = fonte do alvo.
-- O admin revê e corrige falsos positivos em /admin/alvos/drug-links.
--
-- Schema: espelho de 187 (molecular_targets): RLS admin_all +
-- anon_read, soft-delete, status draft/published, trigger
-- update_updated_at_column. Idempotente (IF NOT EXISTS / ON CONFLICT).
-- =====================================================================

-- ============================================================
-- 1. Tabela
-- ============================================================
CREATE TABLE IF NOT EXISTS public.drug_target_roles (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id     UUID NOT NULL REFERENCES public.drugs(id) ON DELETE CASCADE,
  target_id   UUID NOT NULL REFERENCES public.molecular_targets(id) ON DELETE CASCADE,
  role        TEXT NOT NULL CHECK (role IN ('substrate', 'inhibitor', 'inducer')),
  source_pt   TEXT NOT NULL DEFAULT '',
  source_en   TEXT NOT NULL DEFAULT '',
  status      TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT drug_target_roles_unique UNIQUE (drug_id, target_id, role)
);

CREATE INDEX IF NOT EXISTS idx_dtr_drug   ON public.drug_target_roles (drug_id, status, is_archived);
CREATE INDEX IF NOT EXISTS idx_dtr_target ON public.drug_target_roles (target_id, role, status);
CREATE INDEX IF NOT EXISTS idx_dtr_role   ON public.drug_target_roles (role, status, is_archived);

-- ============================================================
-- 2. RLS
-- ============================================================
ALTER TABLE public.drug_target_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_read_drug_target_roles" ON public.drug_target_roles
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "admin_all_drug_target_roles" ON public.drug_target_roles
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- ============================================================
-- 3. Trigger updated_at
-- ============================================================
DROP TRIGGER IF EXISTS set_drug_target_roles_updated_at ON public.drug_target_roles;
CREATE TRIGGER set_drug_target_roles_updated_at
  BEFORE UPDATE ON public.drug_target_roles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
