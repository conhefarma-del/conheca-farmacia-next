-- =====================================================================
-- 133 — Publicar conteúdo em draft (perfis, farmacologia, dimensões)
-- ---------------------------------------------------------------------
-- As migrações 096 e 132 inserem em drug_profiles e drug_pharmacology com
-- o status default 'draft', e a política RLS pública (anon_read_*) só
-- expõe registos com status='published'. Por isso benzilpenicilina-
-- -benzatina, piperacilina-tazobactam (132) e os 28 da 096 que entraram
-- não apareciam na ficha pública /medicamentos/[slug] apesar de os dados
-- estarem na BD.
-- O mesmo se passa com 56 registos de drug_disease_interactions
-- (lotes 101/102) que nunca foram publicados — inclui a piperacilina.
-- Esta migração publica exatamente os registos em draft não arquivados
-- (não toca nos publicados nem nos arquivados). Idempotente: reaplicar
-- é seguro (só volta a acertar os que estiverem em draft).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. drug_profiles — publicar os drafts (30: 28 da 096 + 2 da 132)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles
SET status = 'published'
WHERE status = 'draft'
  AND is_archived = false;

-- ---------------------------------------------------------------------
-- 2. drug_pharmacology — publicar os drafts (30)
-- ---------------------------------------------------------------------
UPDATE public.drug_pharmacology
SET status = 'published'
WHERE status = 'draft'
  AND is_archived = false;

-- ---------------------------------------------------------------------
-- 3. drug_disease_interactions — publicar os drafts (56, lotes 101/102)
-- ---------------------------------------------------------------------
UPDATE public.drug_disease_interactions
SET status = 'published'
WHERE status = 'draft'
  AND is_archived = false;

-- =====================================================================
-- FIM — 133: perfis + farmacologia 182/182 publicados + doença completa
-- =====================================================================
