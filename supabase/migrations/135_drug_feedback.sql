-- =====================================================================
-- 135 — Feedback dos leitores (drug_feedback)
-- ---------------------------------------------------------------------
-- Caixa de feedback nas fichas de fármaco (/medicamento/[slug]) e,
-- futuramente, noutras páginas (calculadora /interacoes, artigos):
-- os leitores podem reportar informação errada ou dar sugestões sobre
-- um fármaco ou uma interação específica.
--
-- Padrão seguido:
--   • RLS da newsletter (047): INSERT público anónimo com WITH CHECK de
--     validação + acesso total de admin (is_current_user_admin — a mesma
--     lógica EXISTS de admin_users das tabelas 043/060);
--   • soft-delete e trigger update_updated_at_column (padrão 043/060);
--   • drug_id é OPCIONAL: o componente é reutilizável noutras páginas
--     (ex.: /interacoes) onde não há um único fármaco; a coluna
--     contexto guarda a rota/página de origem.
--   • interaction_type/interaction_id/interaction_label identificam a
--     interação exata reportada (botão "reportar" em cada cartão).
-- Idempotente: CREATE TABLE IF NOT EXISTS + DROP POLICY IF EXISTS.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. DDL — drug_feedback
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.drug_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id UUID REFERENCES public.drugs(id) ON DELETE SET NULL,
  interaction_type TEXT CHECK (
    interaction_type IS NULL OR interaction_type IN ('drug_drug', 'food', 'disease', 'pregnancy')
  ),
  interaction_id UUID,
  interaction_label TEXT,
  tipo TEXT NOT NULL DEFAULT 'outro' CHECK (tipo IN ('erro', 'sugestao', 'outro')),
  mensagem TEXT NOT NULL,
  email TEXT,
  contexto TEXT,
  status TEXT NOT NULL DEFAULT 'novo' CHECK (status IN ('novo', 'em_revisao', 'resolvido')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_drug_feedback_drug ON public.drug_feedback (drug_id);
CREATE INDEX IF NOT EXISTS idx_drug_feedback_status ON public.drug_feedback (status);
CREATE INDEX IF NOT EXISTS idx_drug_feedback_created ON public.drug_feedback (created_at DESC);

COMMENT ON TABLE public.drug_feedback
  IS 'Feedback dos leitores (erro/sugestão) sobre fármacos e interações. Insert anónimo público; leitura/gestão apenas por admin.';

-- ---------------------------------------------------------------------
-- 2. Trigger updated_at
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS set_drug_feedback_updated_at ON public.drug_feedback;
CREATE TRIGGER set_drug_feedback_updated_at
  BEFORE UPDATE ON public.drug_feedback
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ---------------------------------------------------------------------
-- 3. RLS
-- ---------------------------------------------------------------------
ALTER TABLE public.drug_feedback ENABLE ROW LEVEL SECURITY;

-- Insert público anónimo (padrão newsletter): validação no WITH CHECK —
-- mensagem obrigatória com comprimento limitado, email opcional com
-- formato válido, drug_id opcional mas se presente tem de existir.
DROP POLICY IF EXISTS "anon_insert_drug_feedback" ON public.drug_feedback;
CREATE POLICY "anon_insert_drug_feedback" ON public.drug_feedback
  FOR INSERT TO anon, authenticated
  WITH CHECK (
    length(trim(mensagem)) BETWEEN 3 AND 2000
    AND (email IS NULL OR (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' AND length(email) <= 254))
    AND (drug_id IS NULL OR EXISTS (SELECT 1 FROM public.drugs WHERE id = drug_id))
  );

-- Leitura e gestão apenas por admin
DROP POLICY IF EXISTS "admin_all_drug_feedback" ON public.drug_feedback;
CREATE POLICY "admin_all_drug_feedback" ON public.drug_feedback
  FOR ALL TO authenticated
  USING (public.is_current_user_admin())
  WITH CHECK (public.is_current_user_admin());

-- =====================================================================
-- FIM — 135: drug_feedback (feedback dos leitores)
-- =====================================================================
