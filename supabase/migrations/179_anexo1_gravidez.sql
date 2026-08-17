-- =====================================================================
-- 179: Anexo 1 do Prontuário (Fármacos e Gravidez) — enriquecimento
--      de drug_pregnancy_info dos fármacos da BD com a classificação
--      oficial INFARMED (categoria A/B/C/D/X + trimestre + observação).
-- ---------------------------------------------------------------------
-- Fonte: Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1,
-- "Fármacos e Gravidez" (pág. 539-577).
--
-- Abordagem:
--  * Entradas VALIDADAS visualmente no texto original (o Anexo 1 usa
--    colunas de texto fluido; entradas ambíguas foram EXCLUÍDAS).
--  * UPDATE (não INSERT): todos os 51 fármacos já têm
--    drug_pregnancy_info preenchido de fontes DailyMed/EMC; aqui
--    ADICIONAMOS a fonte oficial angolana e, quando em falta, o
--    trimester. A categoria só é atualizada quando a atual é
--    'no_data' (para não regredir classificações mais conservadoras).
--
-- Mapeamento Anexo 1 -> schema: A/B -> compatible; C/D -> caution;
-- X -> contraindicated; sufixo M = baseado em informação do fabricante.
-- Aplicar após 173-178. Idempotente (JOIN por slug + UPDATE).
-- =====================================================================

-- glimepirida: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('glimepirida', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: É desaconselhado pela actividade estrogénica e por falta de indicações seguras que justifiquem o seu uso.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Discouraged by its oestrogenic activity and lack of safe indications justifying its use.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- pioglitazona: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('pioglitazona', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: A insulina é normalmente usada em todos os diabéticos durante a gravidez.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Insulin is normally used in all diabetics during pregnancy.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- levonorgestrel: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('levonorgestrel', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Contraceptivos orais.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See oral contraceptives.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- anastrozol: Anexo 1 = D (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('anastrozol', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Contra-indicado; V. Inibidores da aromatase.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Contraindicated; see aromatase inhibitors.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- penicilamina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('penicilamina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Evitar, a menos que o benefício potencial ultrapasse o possível risco.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Avoid unless the potential benefit outweighs the possible risk.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- mupirocina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('mupirocina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: O produtor recomenda evitar a menos que o benefício potencial seja superior ao risco.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: The manufacturer recommends avoiding unless the potential benefit outweighs the risk.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- pirazinamida: Anexo 1 = C (caution) | trimestre 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('pirazinamida', 'caution', E'2º e 3º', E'2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Deve ser usada só nos primeiros 2 meses de tratamento.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Should be used only in the first 2 months of treatment.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- estreptomicina: Anexo 1 = D (caution) | trimestre 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('estreptomicina', 'caution', E'2º e 3º', E'2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Toxicidade no 8º par de nervos cranianos; não é teratogénica.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Toxicity to the 8th cranial nerve; not teratogenic.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- linezolida: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('linezolida', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Evitar; não há informação útil.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Avoid; no useful information.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- haloperidol: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('haloperidol', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Antipsicóticos.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See antipsychotics.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- isotretinoina: Anexo 1 = X (contraindicated) | trimestre 1º, 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('isotretinoina', 'contraindicated', E'1º, 2º e 3º', E'1º, 2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Malformações craneofaciais e cardíacas; deve ser usada contracepção eficaz durante pelo menos 1 mês antes do tratamento oral, durante o tratamento e pelo menos 1 mês após a suspensão.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Craniofacial and cardiac malformations; effective contraception should be used for at least 1 month before oral treatment, during treatment and for at least 1 month after discontinuation.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- acitretina: Anexo 1 = X (contraindicated) | trimestre 1º, 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('acitretina', 'contraindicated', E'1º, 2º e 3º', E'1º, 2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Possibilidade de hepatoxicidade neonatal e hemorragia por hipofibrinemia.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Risk of neonatal hepatotoxicity and bleeding due to hypofibrinaemia.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- acetilcisteina: Anexo 1 = C (caution) | trimestre 1º, 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('acetilcisteina', 'caution', E'1º, 2º e 3º', E'1º, 2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Acidose tubular renal; aumento do risco de esquizofrenia.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Renal tubular acidosis; increased risk of schizophrenia.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- aspirina: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('aspirina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Aceitável o seu uso durante este período.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Its use is acceptable during this period.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- azitromicina: Anexo 1 = B (compatible)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('azitromicina', 'compatible', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não existem dados disponíveis; o produtor recomenda usar apenas se não existem alternativas disponíveis.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No data available; the manufacturer recommends use only if no alternatives exist.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- ipratropio: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('ipratropio', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Desconhece-se se é perigoso; não há informações disponíveis.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: It is unknown whether it is harmful; no information available.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- captopril: Anexo 1 = D (caution) | trimestre 1º, 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('captopril', 'caution', E'1º, 2º e 3º', E'1º, 2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Desconhece-se o risco potencial para o feto no 1º trimestre; durante o 2º e 3º trimestres os fármacos que actuam no sistema renina-angiotensina podem causar lesões fetais e neonatais (hipotensão, disfunção renal, oligúria e/ou anúria).',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Fetal risk in the 1st trimester unknown; in the 2nd and 3rd trimesters drugs acting on the renin-angiotensin system may cause fetal and neonatal injury (hypotension, renal dysfunction, oliguria and/or anuria).')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- dabigatrano: Anexo 1 = D (caution) | trimestre 1º, 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('dabigatrano', 'caution', E'1º, 2º e 3º', E'1º, 2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não existem dados adequados sobre a sua utilização em mulheres grávidas.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No adequate data on its use in pregnant women.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- dextrometorfano: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('dextrometorfano', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Analgésicos opiáceos.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See opioid analgesics.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- digoxina: Anexo 1 = DM (caution) | trimestre 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('digoxina', 'caution', E'3º', E'3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não há referências relacionando malformações congénitas com os diferentes digitálicos. Pode ser necessário o ajuste de dose.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No references linking congenital malformations to the different digitalis glycosides. Dose adjustment may be needed.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- epoetina_alfa: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('epoetina_alfa', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não há evidência de riscos e os benefícios ultrapassam provavelmente os riscos de anemia e de transfusão na gravidez.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No evidence of risks and the benefits probably outweigh the risks of anaemia and transfusion in pregnancy.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- eritromicina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('eritromicina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não se sabe se é perigosa.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: It is unknown whether it is harmful.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- etilefrina: Anexo 1 = D (caution) | trimestre 1º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('etilefrina', 'caution', E'1º', E'1º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Contra-indicada.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Contraindicated.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- fenitoina: Anexo 1 = BM (compatible)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('fenitoina', 'compatible', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Evitar; usar apenas se o benefício potencial suplantar os riscos possíveis para o feto.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Avoid; use only if the potential benefit outweighs the possible risks to the fetus.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- ferro: Anexo 1 = C (caution) | trimestre 1º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('ferro', 'caution', E'1º', E'1º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não existem dados em mulheres grávidas; não deverá ser utilizado durante a gravidez.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No data in pregnant women; should not be used during pregnancy.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- finasterida: Anexo 1 = D (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('finasterida', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Contra-indicada na gravidez; risco de malformações dos órgãos genitais externos do feto masculino.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Contraindicated in pregnancy; risk of malformations of the external genitalia of the male fetus.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- fluoxetina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('fluoxetina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Num estudo de coorte prospectivo, não foi encontrado aumento do risco; em estudos animais mostrou poder produzir alterações talvez permanentemente no cérebro.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: In a prospective cohort study no increased risk was found; in animal studies it may produce perhaps permanent brain changes.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- fosfomicina: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('fosfomicina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não há informação disponível; usar apenas se não houver alternativa segura disponível.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No information available; use only if no safe alternative exists.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- furosemida: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('furosemida', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: O produtor recomenda que se use apenas se o benefício potencial for superior ao risco.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: The manufacturer recommends use only if the potential benefit outweighs the risk.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- gentamicina: Anexo 1 = D (caution) | trimestre 1º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('gentamicina', 'caution', E'1º', E'1º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Aminoglicosídeos.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See aminoglycosides.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- hidroclorotiazida: Anexo 1 = D (caution) | trimestre 1º, 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('hidroclorotiazida', 'caution', E'1º, 2º e 3º', E'1º, 2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Diuréticos. Usar com precaução.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See diuretics. Use with caution.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- hidromorfona: Anexo 1 = B (compatible) | trimestre 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('hidromorfona', 'compatible', E'3º', E'3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Analgésicos opiáceos.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See opioid analgesics.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- hidroxicloroquina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('hidroxicloroquina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Em doses elevadas e por períodos longos causa alterações neurológicas e interfere com o ouvido, o equilíbrio e a visão do feto.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: In high doses and for long periods causes neurological changes and interferes with the fetal ear, balance and vision.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- levocetirizina: Anexo 1 = C (caution) | trimestre 1º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('levocetirizina', 'caution', E'1º e 3º', E'1º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Anti-histamínicos H1.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See H1 antihistamines.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- levofloxacina: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('levofloxacina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Quinolonas; deve ser considerado contra-indicado, uma vez que existem outras alternativas mais seguras.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See quinolones; should be considered contraindicated since safer alternatives exist.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- levotiroxina: Anexo 1 = A (compatible)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('levotiroxina', 'compatible', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Controlar a concentração sérica materna de tireotrofina e ajustar a dosagem se necessário.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Monitor maternal serum TSH and adjust the dose if necessary.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- loperamida: Anexo 1 = BM (compatible)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('loperamida', 'compatible', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Recomenda-se evitar por falta de informação disponível.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Avoidance recommended due to lack of available information.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- mefloquina: Anexo 1 = CM (caution) | trimestre 1º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('mefloquina', 'caution', E'1º', E'1º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Teratogenicidade em estudos animais; contra-indicada na gravidez.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Teratogenicity in animal studies; contraindicated in pregnancy.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- metformina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('metformina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não foram referidos efeitos teratogénicos, não obstante atravessar a placenta em quantidades desprezíveis; usar com precaução.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No teratogenic effects reported, although it crosses the placenta in negligible amounts; use with caution.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- midodrina: Anexo 1 = C (caution) | trimestre 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('midodrina', 'caution', E'3º', E'3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Simpaticomiméticos.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See sympathomimetics.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- morfina: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('morfina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Evitar; estimulante uterino potente (tem sido usado para induzir aborto e pode originar nados-mortos).',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Avoid; potent uterine stimulant (has been used to induce abortion and may cause stillbirths).')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- nevirapina: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('nevirapina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não existe informação disponível; o produtor recomenda que se use apenas se for essencial.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No information available; the manufacturer recommends use only if essential.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- propafenona: Anexo 1 = DM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('propafenona', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não se conhecem contra-indicações para a forma de aplicação oftálmica.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No contraindications known for the ophthalmic form.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- ramipril: Anexo 1 = C (caution) | trimestre 1º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('ramipril', 'caution', E'1º', E'1º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Inibidores da enzima de conversão da angiotensina (IECA); os fármacos que actuam no sistema renina-angiotensina podem causar lesões fetais e neonatais no 2º e 3º trimestres.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See angiotensin-converting enzyme inhibitors (ACEI); drugs acting on the renin-angiotensin system may cause fetal and neonatal injury in the 2nd and 3rd trimesters.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- salbutamol: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('salbutamol', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Usar apenas se o benefício potencial for superior aos riscos.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Use only if the potential benefit outweighs the risks.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- salmeterol: Anexo 1 = D (caution) | trimestre 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('salmeterol', 'caution', E'3º', E'3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: V. Agonistas beta-2 adrenérgicos.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: See beta-2 adrenergic agonists.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- sertralina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('sertralina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Evitar; não há dados que suportem um risco teratogénico.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Avoid; no data supporting a teratogenic risk.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- sildenafil: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('sildenafil', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Administração a ratas fêmeas; V. Antidepressores inibidores da recaptação da serotonina.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Administration to female rats; see serotonin reuptake inhibitor antidepressants.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- tobramicina: Anexo 1 = C (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('tobramicina', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Recomenda-se evitar.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Avoidance recommended.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- tramadol: Anexo 1 = CM (caution)
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('tramadol', 'caution', NULL, NULL,
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Não foram descritos efeitos embriotóxicos ou teratogénicos em animais, mas não existem estudos controlados na grávida; usar só se houver reconhecida necessidade e sob vigilância médica.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: No embryotoxic or teratogenic effects described in animals, but no controlled studies in pregnancy; use only if clearly needed and under medical supervision.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

-- medroxiprogesterona: Anexo 1 = D (caution) | trimestre 1º, 2º e 3º
UPDATE public.drug_pregnancy_info pi
SET source_pt    = CASE WHEN pi.source_pt = '' THEN v.src_pt
                        WHEN pi.source_pt NOT LIKE '%Anexo 1%' THEN pi.source_pt || ' ; ' || v.src_pt
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN v.src_en
                        WHEN pi.source_en NOT LIKE '%Annex 1%' THEN pi.source_en || ' ; ' || v.src_en
                        ELSE pi.source_en END,
    trimester_pt = CASE WHEN pi.trimester_pt = '' THEN COALESCE(v.trim, pi.trimester_pt) ELSE pi.trimester_pt END,
    trimester_en = CASE WHEN pi.trimester_en = '' THEN COALESCE(v.trim, pi.trimester_en) ELSE pi.trimester_en END,
    pregnancy_category = CASE WHEN pi.pregnancy_category = 'no_data' THEN v.cat ELSE pi.pregnancy_category END,
    updated_at = now()
FROM public.drugs d
JOIN (VALUES
  ('medroxiprogesterona', 'caution', E'1º, 2º e 3º', E'1º, 2º e 3º',
   E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 1, Fármacos e Gravidez: Fetos de ambos os sexos. Não há evidência de efeito adverso com injecção depósito para contracepção.',
   E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 1, Drugs and Pregnancy: Fetuses of both sexes. No evidence of adverse effect with depot injection for contraception.')
) AS v(slug, cat, trim, trim_en, src_pt, src_en) ON v.slug = d.slug
WHERE pi.drug_id = d.id;

