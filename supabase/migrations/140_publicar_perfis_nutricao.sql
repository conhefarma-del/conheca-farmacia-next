-- =====================================================================
-- 140 — Publicar perfis + farmacologia da 137 (nutrição) que ficaram
--        em draft
-- ---------------------------------------------------------------------
-- A migração 137 não incluía `status = 'published'` nos INSERTs — os 9
-- perfis e 9 farmacologias dos fármacos de nutrição foram criados com
-- o valor default 'draft' e a RLS de leitura anónima esconde-os.
-- Esta migração corrige o estado e atualiza o updated_at.
-- Aplicar depois da 137. Idempotente.
-- =====================================================================

UPDATE public.drug_profiles dp
SET status = 'published', updated_at = NOW()
FROM public.drugs d
WHERE d.id = dp.drug_id
  AND d.slug IN (
    'acido_ascorbico', 'aminoacidos', 'carbonato_calcio',
    'cloreto_potassio', 'colecalciferol', 'emulsao_lipidica',
    'glicose', 'sulfato_magnesio', 'zinco'
  )
  AND dp.status = 'draft';

UPDATE public.drug_pharmacology dp
SET status = 'published', updated_at = NOW()
FROM public.drugs d
WHERE d.id = dp.drug_id
  AND d.slug IN (
    'acido_ascorbico', 'aminoacidos', 'carbonato_calcio',
    'cloreto_potassio', 'colecalciferol', 'emulsao_lipidica',
    'glicose', 'sulfato_magnesio', 'zinco'
  )
  AND dp.status = 'draft';

-- =====================================================================
-- Nota: a migração 137 em disco foi também corrigida (adicionado
-- `status, 'published'` nos dois INSERTs) para que o gerador do pack
-- e futuras reaplicações criem os registos já publicados.
-- =====================================================================