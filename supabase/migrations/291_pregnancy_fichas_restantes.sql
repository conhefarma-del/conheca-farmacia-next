-- =====================================================================
-- 291 — Bullets de gravidez nas fichas que ficaram fora da 288
-- ---------------------------------------------------------------------
-- CONTEXTO: a 288 (padrão 282) adicionou o bullet "• GRAVIDEZ:" às 33 fichas
-- contraindicadas que não mencionavam gravidez nas precautions, e resolveu 6
-- registos no_data. Verificação posterior à aplicação (2026-10-02,
-- _temp/_288_gaps_residuais.mjs) encontrou 3 fichas que ficaram de fora:
--
--   * daptomicina — a 288 mudou-lhe a categoria para 'contraindicated' na
--     drug_pregnancy_info (PARTE B.1) mas NÃO lhe tocou nas precautions do
--     perfil. Resultado: ficha publicada com contraindicação formal sem
--     qualquer menção de gravidez — exactamente o problema que a 288 existia
--     para resolver. É a única lacuna REAL (fármaco activo e visível).
--
--   * tadalafil, vardenafil, tansulosina, degarelix — mantidas em 'no_data'
--     pela 288 com justificação no registo 1:1 (uso exclusivamente masculino),
--     mas sem o bullet formatado na ficha do perfil (o degarelix tinha uma
--     menção solta a gravidez, sem o formato uniforme). Não é incoerência
--     (no_data é honesto), é opacidade: o utilizador vê a ficha sem saber que
--     a ausência de dados é uma decisão documentada e não um esquecimento.
--
--   (As outras 2 fichas sinalizadas — losartano e sulfametoxazol-trimetoprima —
--    pertencem a fármacos JÁ ARQUIVADOS, logo não visíveis ao utilizador.
--    Não são tratadas aqui: o losartano é consolidado na 290 e o
--    sulfametoxazol-trimetoprima é duplicado arquivado do cotrimoxazol.)
--
-- Padrão 282 (idêntico à 288): UPDATE com guarda strpos = 0, append com E'\n',
-- nunca substituir texto existente. Idempotente: reaplicar = 0 mudanças.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 1. DAPTOMICINA — contraindicação formal (Prontuário l. 2789)
--    A 288 mudou a categoria mas não escreveu nada na ficha.
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — o Prontuário (1.1.11, DAPTOMICINA) indica "Gravidez e aleitamento" como contra-indicações; os dados humanos são muito limitados e a daptomicina é inactivada pelo surfactante pulmonar do recém-nascido. Usar apenas em infecção grave por Staphylococcus aureus resistente sem alternativa eficaz; contraindicado o aleitamento durante o tratamento.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — the Prontuário (1.1.11, DAPTOMICIN) lists "pregnancy and breastfeeding" as contraindications; human data are very limited and daptomycin is inactivated by neonatal pulmonary surfactant. Use only for severe resistant Staphylococcus aureus infection without an effective alternative; breastfeeding is contraindicated during treatment.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'daptomicina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- ---------------------------------------------------------------------
-- 2. TADALAFIL, VARDENAFIL, TANSULOSINA — no_data documentado na ficha
--    (a 288 manteve a categoria com justificação no registo 1:1; aqui
--     torna-se visível na ficha do perfil)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: sem dados — fármaco de uso exclusivamente masculino (disfunção eréctil); não existe cenário clínico de exposição fetal, pelo que a categoria "sem dados" é uma decisão documentada e não uma omissão. Sem indicação de contracepção adicional específica por este fármaco.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: no data — male-only indication (erectile dysfunction); there is no clinical scenario of fetal exposure, so the "no data" category is a documented decision rather than an omission. No specific additional contraception is indicated for this drug.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug IN ('tadalafil', 'vardenafil')) w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: sem dados — fármaco de uso exclusivamente masculino (hiperplasia benigna da próstata); não existe cenário clínico de exposição fetal, pelo que a categoria "sem dados" é uma decisão documentada e não uma omissão. Sem indicação de contracepção adicional específica por este fármaco.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: no data — male-only indication (benign prostatic hyperplasia); there is no clinical scenario of fetal exposure, so the "no data" category is a documented decision rather than an omission. No specific additional contraception is indicated for this drug.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'tansulosina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- ---------------------------------------------------------------------
-- 3. DEGARELIX — no_data com justificação já no registo 1:1 (Prontuário
--    l. 37401, uso exclusivamente masculino: cancro da próstata), mas sem
--    bullet na ficha. Incluído para uniformizar as 4 fichas no_data.
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: sem dados — fármaco de uso exclusivamente masculino (cancro da próstata); não existe cenário clínico de exposição fetal, pelo que a categoria "sem dados" é uma decisão documentada e não uma omissão. Sem indicação de contracepção adicional específica por este fármaco.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: no data — male-only indication (prostate cancer); there is no clinical scenario of fetal exposure, so the "no data" category is a documented decision rather than an omission. No specific additional contraception is indicated for this drug.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'degarelix') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

COMMIT;

-- =====================================================================
-- Verificação pós-migração (executar à parte, expectativas):
--   SELECT d.slug, dpi.pregnancy_category,
--          strpos(dp.precautions_pt, '• GRAVIDEZ:') > 0 AS tem_bullet
--     FROM public.drugs d
--     JOIN public.drug_profiles dp ON dp.drug_id = d.id AND dp.is_archived = false
--     JOIN public.drug_pregnancy_info dpi ON dpi.drug_id = d.id AND dpi.is_archived = false
--     WHERE d.slug IN ('daptomicina','tadalafil','vardenafil','tansulosina')
--     ORDER BY d.slug;
--   → 4 linhas, todas com tem_bullet = true;
--     daptomicina = contraindicated; as outras 3 = no_data.
--
--   -- nenhuma ficha contraindicada sem menção de gravidez (fármacos activos):
--   SELECT d.slug FROM public.drugs d
--     JOIN public.drug_pregnancy_info dpi ON dpi.drug_id = d.id AND dpi.is_archived = false
--     JOIN public.drug_profiles dp ON dp.drug_id = d.id AND dp.is_archived = false
--     WHERE d.is_archived = false
--       AND dpi.pregnancy_category = 'contraindicated'
--       AND strpos(dp.precautions_pt, 'GRAVIDEZ') = 0;
--   → 0 linhas
-- =====================================================================
