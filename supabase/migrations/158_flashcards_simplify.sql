-- =====================================================================
-- 158 — Flashcards: simplificação de linguagem dos fronts gerados
-- ---------------------------------------------------------------------
-- O mesmo princípio do Quiz (plano 2026-08-13-quiz): perguntas com
-- linguagem mais simples sempre que possível, sem abdicar dos termos
-- clínicos essenciais. Só os FRONTS gerados (templates) são reescritos;
-- os backs (conteúdo clínico real) e as fontes ficam intactos. Cartões
-- manuais (card_type = 'manual') nunca são tocados.
--
-- Os templates batem com lib/quiz/simplify.js (FRONT_TEMPLATES) e com a
-- migração 157 (reaplicar 157 regera os cartões já com os fronts novos).
-- =====================================================================

-- 1. Mecanismo de ação
UPDATE public.flashcards fc
SET front_pt = 'Como atua o ' || dr.name_pt || ' no organismo?',
    updated_at = now()
FROM public.drugs dr
WHERE fc.drug_id = dr.id
  AND fc.card_type = 'mecanismo'
  AND fc.status = 'published'
  AND fc.front_pt LIKE 'Qual é o mecanismo de ação de %';

-- 2. Classe terapêutica
UPDATE public.flashcards fc
SET front_pt = 'A que grupo de medicamentos pertence o ' || dr.name_pt || '?',
    updated_at = now()
FROM public.drugs dr
WHERE fc.drug_id = dr.id
  AND fc.card_type = 'classe'
  AND fc.status = 'published'
  AND fc.front_pt LIKE '% — a que classe terapêutica pertence?';

-- 3. Perfil / visão geral
UPDATE public.flashcards fc
SET front_pt = 'Para que serve o ' || dr.name_pt || '? (visão geral e indicação)',
    updated_at = now()
FROM public.drugs dr
WHERE fc.drug_id = dr.id
  AND fc.card_type = 'perfil'
  AND fc.status = 'published'
  AND fc.front_pt LIKE 'Qual é a visão geral / indicação de %';

-- 4. Interações fármaco-fármaco — reconstrói o front com os nomes reais
--    do par (mesma regra de dedup do seed 157: a interação mais severa
--    por fármaco A), para os cartões com o template antigo.
WITH ranked AS (
  SELECT di.drug_a_id, di.drug_b_id,
         ROW_NUMBER() OVER (
           PARTITION BY di.drug_a_id
           ORDER BY CASE di.severity WHEN 'critical' THEN 1 WHEN 'moderate' THEN 2 ELSE 3 END
         ) AS rn
  FROM public.drug_interactions di
  WHERE di.status = 'published' AND di.is_archived = false
    AND di.severity IN ('critical','moderate')
)
UPDATE public.flashcards fc
SET front_pt = 'Que interação existe entre ' || dr_a.name_pt || ' e ' || dr_b.name_pt || '?',
    updated_at = now()
FROM ranked r
JOIN public.drugs dr_a ON dr_a.id = r.drug_a_id
JOIN public.drugs dr_b ON dr_b.id = r.drug_b_id
WHERE fc.drug_id = r.drug_a_id
  AND fc.card_type = 'interacao'
  AND fc.status = 'published'
  AND fc.front_pt LIKE '%— que interação existe?';

-- =====================================================================
-- FIM — 158: simplificação dos fronts
-- =====================================================================
