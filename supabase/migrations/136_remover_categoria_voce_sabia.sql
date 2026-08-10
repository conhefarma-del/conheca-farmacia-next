-- =============================================================================
-- 136 — Descontinuar a categoria 'voce-sabia'
-- -----------------------------------------------------------------------------
-- A secção "Você Sabia?" foi descontinuada. Os artigos dessa categoria passam
-- para 'conheca-medicamento' (que herdou a cor #0a844f no frontend). A coluna
-- category é texto livre (sem CHECK constraint), por isso só é preciso o UPDATE.
-- Idempotente: após a primeira execução não há artigos 'voce-sabia' e o UPDATE
-- não altera nada.
-- =============================================================================

UPDATE public.articles
SET category = 'conheca-medicamento',
    category_label = 'Conheça o Medicamento'
WHERE category = 'voce-sabia';
