-- 060: Schema das novas dimensões de interações (Fluxo 2)
-- Três tabelas para as interações NÃO fármaco-fármaco, referenciando public.drugs:
--   1. drug_food_interactions  — medicamento ↔ alimento/bebida
--   2. drug_disease_interactions — medicamento ↔ doença/condição
--   3. drug_pregnancy_info     — medicamento ↔ gestação/lactação (1:1 por fármaco)
-- Padrão: espelho de 043 (drugs/drug_interactions): RLS admin_all + anon_read,
-- soft-delete, status draft/published, trigger update_updated_at_column.
-- Conteúdo clínico autorado PT/EN + source_pt/en (fonte canónica do Fluxo 2:
-- EMC-UK/MHRA, corroborado por Health Canada/DailyMed — ver docs/INTERACOES_FLUXO_PESQUISA.md).

-- ============================================================
-- 1. drug_food_interactions
-- ============================================================
CREATE TABLE IF NOT EXISTS public.drug_food_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id UUID NOT NULL REFERENCES public.drugs(id) ON DELETE RESTRICT,
  entity_slug TEXT NOT NULL,
  entity_pt TEXT NOT NULL,
  entity_en TEXT NOT NULL,
  severity TEXT NOT NULL DEFAULT 'moderate' CHECK (severity IN ('critical', 'moderate', 'minor', 'none')),
  mechanism_pt TEXT NOT NULL DEFAULT '',
  mechanism_en TEXT NOT NULL DEFAULT '',
  advice_pt TEXT NOT NULL DEFAULT '',
  advice_en TEXT NOT NULL DEFAULT '',
  source_pt TEXT NOT NULL DEFAULT '',
  source_en TEXT NOT NULL DEFAULT '',
  sort_order INT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT drug_food_interactions_unique UNIQUE (drug_id, entity_slug)
);

CREATE INDEX IF NOT EXISTS idx_drug_food_interactions_drug ON public.drug_food_interactions (drug_id);

-- ============================================================
-- 2. drug_disease_interactions
-- ============================================================
CREATE TABLE IF NOT EXISTS public.drug_disease_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id UUID NOT NULL REFERENCES public.drugs(id) ON DELETE RESTRICT,
  condition_slug TEXT NOT NULL,
  condition_pt TEXT NOT NULL,
  condition_en TEXT NOT NULL,
  interaction_type TEXT NOT NULL DEFAULT 'precaution' CHECK (interaction_type IN ('contraindication', 'precaution')),
  severity TEXT NOT NULL DEFAULT 'moderate' CHECK (severity IN ('critical', 'moderate', 'minor', 'none')),
  reason_pt TEXT NOT NULL DEFAULT '',
  reason_en TEXT NOT NULL DEFAULT '',
  advice_pt TEXT NOT NULL DEFAULT '',
  advice_en TEXT NOT NULL DEFAULT '',
  source_pt TEXT NOT NULL DEFAULT '',
  source_en TEXT NOT NULL DEFAULT '',
  sort_order INT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT drug_disease_interactions_unique UNIQUE (drug_id, condition_slug)
);

CREATE INDEX IF NOT EXISTS idx_drug_disease_interactions_drug ON public.drug_disease_interactions (drug_id);

-- ============================================================
-- 3. drug_pregnancy_info (1:1 por fármaco)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.drug_pregnancy_info (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id UUID NOT NULL UNIQUE REFERENCES public.drugs(id) ON DELETE RESTRICT,
  pregnancy_category TEXT NOT NULL DEFAULT 'caution' CHECK (pregnancy_category IN ('contraindicated', 'caution', 'compatible', 'no_data')),
  risk_pt TEXT NOT NULL DEFAULT '',
  risk_en TEXT NOT NULL DEFAULT '',
  trimester_pt TEXT NOT NULL DEFAULT '',
  trimester_en TEXT NOT NULL DEFAULT '',
  lactation_pt TEXT NOT NULL DEFAULT '',
  lactation_en TEXT NOT NULL DEFAULT '',
  contraception_pt TEXT NOT NULL DEFAULT '',
  contraception_en TEXT NOT NULL DEFAULT '',
  source_pt TEXT NOT NULL DEFAULT '',
  source_en TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- RLS
-- ============================================================
ALTER TABLE public.drug_food_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drug_disease_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drug_pregnancy_info ENABLE ROW LEVEL SECURITY;

-- admin_all (mesmo padrão de 043)
CREATE POLICY "admin_all_drug_food_interactions" ON public.drug_food_interactions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_drug_disease_interactions" ON public.drug_disease_interactions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_drug_pregnancy_info" ON public.drug_pregnancy_info
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- anon_read (só published, não arquivado)
CREATE POLICY "anon_read_drug_food_interactions" ON public.drug_food_interactions
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_drug_disease_interactions" ON public.drug_disease_interactions
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_drug_pregnancy_info" ON public.drug_pregnancy_info
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

-- ============================================================
-- Triggers updated_at
-- ============================================================
CREATE TRIGGER set_drug_food_interactions_updated_at
  BEFORE UPDATE ON public.drug_food_interactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_drug_disease_interactions_updated_at
  BEFORE UPDATE ON public.drug_disease_interactions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_drug_pregnancy_info_updated_at
  BEFORE UPDATE ON public.drug_pregnancy_info
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
