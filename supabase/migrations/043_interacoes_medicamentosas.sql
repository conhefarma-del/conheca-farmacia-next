-- 043: Calculadora de Interações Medicamentosas
-- Duas tabelas: drugs (fármacos) + drug_interactions (pares com severidade).
-- Padrão: espelho de clinical_protocols (039): RLS admin_all + anon_read, soft-delete, status.
-- Pares canónicos: CHECK (drug_a_id < drug_b_id) para a UNIQUE(a,b) funcionar independentemente da ordem.

CREATE TABLE IF NOT EXISTS public.drugs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  class_pt TEXT NOT NULL DEFAULT '',
  class_en TEXT NOT NULL DEFAULT '',
  aliases TEXT[] NOT NULL DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.drug_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_a_id UUID NOT NULL REFERENCES public.drugs(id) ON DELETE RESTRICT,
  drug_b_id UUID NOT NULL REFERENCES public.drugs(id) ON DELETE RESTRICT,
  severity TEXT NOT NULL DEFAULT 'moderate' CHECK (severity IN ('critical', 'moderate', 'minor', 'none')),
  summary_pt TEXT NOT NULL DEFAULT '',
  summary_en TEXT NOT NULL DEFAULT '',
  mechanism_pt TEXT NOT NULL DEFAULT '',
  mechanism_en TEXT NOT NULL DEFAULT '',
  management_pt TEXT NOT NULL DEFAULT '',
  management_en TEXT NOT NULL DEFAULT '',
  monitoring_pt TEXT NOT NULL DEFAULT '',
  monitoring_en TEXT NOT NULL DEFAULT '',
  red_flags_pt TEXT NOT NULL DEFAULT '',
  red_flags_en TEXT NOT NULL DEFAULT '',
  source_pt TEXT NOT NULL DEFAULT '',
  source_en TEXT NOT NULL DEFAULT '',
  source_url TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT drug_interactions_pair_unique UNIQUE (drug_a_id, drug_b_id),
  CONSTRAINT drug_interactions_canonical_order CHECK (drug_a_id < drug_b_id)
);

-- Índices de consulta: os pares são sempre procurados pelos dois ids
CREATE INDEX IF NOT EXISTS idx_drug_interactions_drug_a ON public.drug_interactions (drug_a_id);
CREATE INDEX IF NOT EXISTS idx_drug_interactions_drug_b ON public.drug_interactions (drug_b_id);

-- RLS
ALTER TABLE public.drugs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drug_interactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_all_drugs" ON public.drugs
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "anon_read_drugs" ON public.drugs
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "admin_all_drug_interactions" ON public.drug_interactions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "anon_read_drug_interactions" ON public.drug_interactions
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE TRIGGER set_drugs_updated_at
  BEFORE UPDATE ON public.drugs
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_drug_interactions_updated_at
  BEFORE UPDATE ON public.drug_interactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
