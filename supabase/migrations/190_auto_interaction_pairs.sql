-- =====================================================================
-- 190: Pares com auto-interação pré-computados em SQL
--      (auto_interaction_pairs — view materializada)
--
-- Motivação: o aviso de auto-interação nos cartões de interações
-- fármaco-fármaco de /medicamento/[slug] era calculado no cliente
-- (cruzamento de drug_target_roles por par). Passa a ser pré-computado
-- aqui: um par tem auto-interação quando um dos fármacos é substrato de
-- um alvo e o outro é inibidor/indutor do MESMO alvo (ex.:
-- claritromicina inibidor × simvastatina substrato do CYP3A4).
--
-- A view é materializada com refresh automático por triggers
-- statement-level em drug_interactions e drug_target_roles (dados
-- pequenos: ~700 pares × 133 papéis), por isso está sempre fresca após
-- qualquer alteração no admin. Acesso público via GRANT (matviews não
-- têm RLS).
--
-- Idempotente (DROP/CREATE + OR REPLACE FUNCTION + DROP TRIGGER).
-- =====================================================================

-- ============================================================
-- 1. View materializada
-- ============================================================
DROP MATERIALIZED VIEW IF EXISTS public.auto_interaction_pairs;

CREATE MATERIALIZED VIEW public.auto_interaction_pairs AS
SELECT
  di.id                                AS pair_id,
  di.drug_a_id                         AS drug_a_id,
  di.drug_b_id                         AS drug_b_id,
  mt.id                                AS target_id,
  mt.slug                              AS target_slug,
  mt.name_pt                           AS target_name_pt,
  mt.name_en                           AS target_name_en,
  ra.role                              AS role_a,
  rb.role                              AS role_b
FROM public.drug_interactions di
JOIN public.drug_target_roles ra
  ON ra.drug_id = di.drug_a_id
 AND ra.status = 'published'
 AND ra.is_archived = false
JOIN public.drug_target_roles rb
  ON rb.drug_id = di.drug_b_id
 AND rb.status = 'published'
 AND rb.is_archived = false
JOIN public.molecular_targets mt
  ON mt.id = ra.target_id
 AND mt.id = rb.target_id
 AND mt.status = 'published'
 AND mt.is_archived = false
WHERE di.status = 'published'
  AND di.is_archived = false
  AND (
    (ra.role = 'substrate' AND rb.role IN ('inhibitor', 'inducer'))
    OR (rb.role = 'substrate' AND ra.role IN ('inhibitor', 'inducer'))
  );

-- Índice único obrigatório para REFRESH ... CONCURRENTLY
-- (uma linha por par × alvo × combinação de papéis).
CREATE UNIQUE INDEX IF NOT EXISTS auto_interaction_pairs_uniq
  ON public.auto_interaction_pairs (pair_id, target_id, role_a, role_b);

CREATE INDEX IF NOT EXISTS auto_interaction_pairs_drug_a
  ON public.auto_interaction_pairs (drug_a_id);
CREATE INDEX IF NOT EXISTS auto_interaction_pairs_drug_b
  ON public.auto_interaction_pairs (drug_b_id);

-- ============================================================
-- 2. Função de refresh (SECURITY DEFINER — corre como dona da view)
-- ============================================================
CREATE OR REPLACE FUNCTION public.refresh_auto_interaction_pairs()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  REFRESH MATERIALIZED VIEW public.auto_interaction_pairs;
  RETURN NULL;
END;
$$;

-- ============================================================
-- 3. Triggers statement-level (1 refresh por statement)
-- ============================================================
DROP TRIGGER IF EXISTS trg_refresh_aip_interactions
  ON public.drug_interactions;
CREATE TRIGGER trg_refresh_aip_interactions
  AFTER INSERT OR UPDATE OR DELETE ON public.drug_interactions
  FOR EACH STATEMENT EXECUTE FUNCTION public.refresh_auto_interaction_pairs();

DROP TRIGGER IF EXISTS trg_refresh_aip_roles
  ON public.drug_target_roles;
CREATE TRIGGER trg_refresh_aip_roles
  AFTER INSERT OR UPDATE OR DELETE ON public.drug_target_roles
  FOR EACH STATEMENT EXECUTE FUNCTION public.refresh_auto_interaction_pairs();

-- ============================================================
-- 4. Acesso (matviews não têm RLS — grant explícito)
-- ============================================================
REVOKE ALL ON public.auto_interaction_pairs FROM PUBLIC;
GRANT SELECT ON public.auto_interaction_pairs TO anon, authenticated;
