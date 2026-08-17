-- =====================================================================
-- 181: Anexo 2 do Prontuário (Fármacos e Aleitamento) — enriquecimento
--      de drug_pregnancy_info.lactation_pt/lactation_en dos fármacos da BD
--      com a informação oficial INFARMED sobre aleitamento.
-- ---------------------------------------------------------------------
-- Fonte: Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2,
-- "Fármacos e Aleitamento" (pág. 578-597).
--
-- Abordagem (idêntica à 179):
--  * Entradas VALIDADAS visualmente no texto original (o Anexo 2 usa
--    2 colunas de texto fluido; entradas ambíguas foram EXCLUÍDAS).
--  * UPDATE (não INSERT): todos os fármacos já têm drug_pregnancy_info
--    preenchido de fontes DailyMed/EMC; aqui ADICIONAMOS a fonte oficial
--    angolana e, quando a lactation_pt é placeholder ("Sem dados..."/
--    "Desconhecida..."), preenchemos com a observação do Anexo 2.
--  * A lactation_pt existente (conteúdo real) nunca é substituída.
-- Aplicar após 173-180. Idempotente (JOIN por slug + UPDATE).
-- =====================================================================

-- acitretina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'acitretina' AND pi.drug_id = d.id;

-- adrenalina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Não é provável qualquer efeito adverso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'No adverse effects are likely.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não é provável qualquer efeito adverso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não é provável qualquer efeito adverso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: No adverse effects are likely.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: No adverse effects are likely.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'adrenalina' AND pi.drug_id = d.id;

-- alopurinol: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite; não se sabe se é perigoso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk; it is not known whether it is harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; não se sabe se é perigoso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; não se sabe se é perigoso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; it is not known whether it is harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; it is not known whether it is harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'alopurinol' AND pi.drug_id = d.id;

-- alprazolam: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Benzodiazepinas; excreta-se no leite e produz letargia e perda de peso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See Benzodiazepines; excreted in milk and causes lethargy and weight loss.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Benzodiazepinas; excreta-se no leite e produz letargia e perda de peso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Benzodiazepinas; excreta-se no leite e produz letargia e perda de peso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Benzodiazepines; excreted in milk and causes lethargy and weight loss.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Benzodiazepines; excreted in milk and causes lethargy and weight loss.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'alprazolam' AND pi.drug_id = d.id;

-- amantadina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Foi referida toxicidade no lactente; evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Toxicity has been reported in the infant; avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Foi referida toxicidade no lactente; evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Foi referida toxicidade no lactente; evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Toxicity has been reported in the infant; avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Toxicity has been reported in the infant; avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'amantadina' AND pi.drug_id = d.id;

-- amiodarona: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar, por presença no leite em quantidades significativas; possível hipotiroidismo.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid, because significant amounts are present in milk; possible hypothyroidism.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar, por presença no leite em quantidades significativas; possível hipotiroidismo.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar, por presença no leite em quantidades significativas; possível hipotiroidismo.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid, because significant amounts are present in milk; possible hypothyroidism.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid, because significant amounts are present in milk; possible hypothyroidism.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'amiodarona' AND pi.drug_id = d.id;

-- amlodipina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'amlodipina' AND pi.drug_id = d.id;

-- amoxicilina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Seguro na dose usual.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Safe at the usual dose.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Seguro na dose usual.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Seguro na dose usual.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Safe at the usual dose.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Safe at the usual dose.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'amoxicilina' AND pi.drug_id = d.id;

-- amoxicilina_acidoclavulanico: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Seguro na dose usual.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Safe at the usual dose.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Seguro na dose usual.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Seguro na dose usual.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Safe at the usual dose.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Safe at the usual dose.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'amoxicilina-clavulanato' AND pi.drug_id = d.id;

-- ampicilina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Vestígios no leite; seguro na dosagem usual; vigiar o lactente.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Trace amounts in milk; safe at the usual dosage; monitor the infant.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Vestígios no leite; seguro na dosagem usual; vigiar o lactente.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Vestígios no leite; seguro na dosagem usual; vigiar o lactente.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Trace amounts in milk; safe at the usual dosage; monitor the infant.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Trace amounts in milk; safe at the usual dosage; monitor the infant.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'ampicilina' AND pi.drug_id = d.id;

-- atazanavir: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Aleitamento não recomendado na infecção por VIH.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Breastfeeding is not recommended in HIV infection.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Aleitamento não recomendado na infecção por VIH.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Aleitamento não recomendado na infecção por VIH.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Breastfeeding is not recommended in HIV infection.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Breastfeeding is not recommended in HIV infection.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'atazanavir' AND pi.drug_id = d.id;

-- atorvastatina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil. V. Estatinas.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available. See Statins.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil. V. Estatinas.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil. V. Estatinas.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available. See Statins.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available. See Statins.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'atorvastatina' AND pi.drug_id = d.id;

-- azatioprina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Interromper o aleitamento.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Discontinue breastfeeding.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Interromper o aleitamento.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Interromper o aleitamento.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Discontinue breastfeeding.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Discontinue breastfeeding.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'azatioprina' AND pi.drug_id = d.id;

-- azelastina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Não deve ser usada.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Should not be used.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não deve ser usada.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não deve ser usada.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Should not be used.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Should not be used.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'azelastina' AND pi.drug_id = d.id;

-- azitromicina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite; o produtor recomenda que se use apenas se não existir alternativa disponível; vigiar então o lactente.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk; the manufacturer recommends use only if no alternative is available; monitor the infant.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; o produtor recomenda que se use apenas se não existir alternativa disponível; vigiar então o lactente.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; o produtor recomenda que se use apenas se não existir alternativa disponível; vigiar então o lactente.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; the manufacturer recommends use only if no alternative is available; monitor the infant.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; the manufacturer recommends use only if no alternative is available; monitor the infant.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'azitromicina' AND pi.drug_id = d.id;

-- budesonida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Corticosteróides.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See Corticosteroids.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Corticosteróides.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Corticosteróides.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Corticosteroids.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Corticosteroids.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'budesonida' AND pi.drug_id = d.id;

-- buprenorfina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Contra-indicada no tratamento da dependência a opiáceos; evitar; pode inibir a lactação.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Contraindicated in the treatment of opioid dependence; avoid; may inhibit lactation.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Contra-indicada no tratamento da dependência a opiáceos; evitar; pode inibir a lactação.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Contra-indicada no tratamento da dependência a opiáceos; evitar; pode inibir a lactação.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Contraindicated in the treatment of opioid dependence; avoid; may inhibit lactation.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Contraindicated in the treatment of opioid dependence; avoid; may inhibit lactation.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'buprenorfina' AND pi.drug_id = d.id;

-- calcitriol: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Vigiar calcemia do lactente se a mãe recebe doses elevadas.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Monitor the infant''s blood calcium if the mother receives high doses.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Vigiar calcemia do lactente se a mãe recebe doses elevadas.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Vigiar calcemia do lactente se a mãe recebe doses elevadas.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Monitor the infant''s blood calcium if the mother receives high doses.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Monitor the infant''s blood calcium if the mother receives high doses.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'calcitriol' AND pi.drug_id = d.id;

-- captopril: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite; o produtor recomenda evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk; the manufacturer recommends avoiding.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; o produtor recomenda evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; o produtor recomenda evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; the manufacturer recommends avoiding.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; the manufacturer recommends avoiding.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'captopril' AND pi.drug_id = d.id;

-- carbamazepina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; presente no leite em quantidades muito pequenas para ser perigosa; possível erupção grave.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; present in milk in very small amounts unlikely to be harmful; possible severe rash.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite em quantidades muito pequenas para ser perigosa; possível erupção grave.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite em quantidades muito pequenas para ser perigosa; possível erupção grave.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in very small amounts unlikely to be harmful; possible severe rash.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in very small amounts unlikely to be harmful; possible severe rash.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'carbamazepina' AND pi.drug_id = d.id;

-- ciclofosfamida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presentes no leite em baixas concentrações.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk at low concentrations.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presentes no leite em baixas concentrações.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presentes no leite em baixas concentrações.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk at low concentrations.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk at low concentrations.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'ciclofosfamida' AND pi.drug_id = d.id;

-- claritromicina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'claritromicina' AND pi.drug_id = d.id;

-- desloratadina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite; recomenda-se evitar. V. Anti-histamínicos H1.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk; avoiding is recommended. See H1 antihistamines.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; recomenda-se evitar. V. Anti-histamínicos H1.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite; recomenda-se evitar. V. Anti-histamínicos H1.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; avoiding is recommended. See H1 antihistamines.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk; avoiding is recommended. See H1 antihistamines.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'desloratadina' AND pi.drug_id = d.id;

-- diclofenac: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite em quantidades muito pequenas para ser perigoso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in very small amounts unlikely to be harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'diclofenac' AND pi.drug_id = d.id;

-- digoxina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite em quantidades muito pequenas para ser perigosa.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in very small amounts unlikely to be harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigosa.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigosa.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'digoxina' AND pi.drug_id = d.id;

-- diltiazem: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Quantidade significativa no leite. Evitar, a menos que não haja alternativa segura.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Significant amounts in milk. Avoid unless there is no safe alternative.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade significativa no leite. Evitar, a menos que não haja alternativa segura.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade significativa no leite. Evitar, a menos que não haja alternativa segura.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Significant amounts in milk. Avoid unless there is no safe alternative.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Significant amounts in milk. Avoid unless there is no safe alternative.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'diltiazem' AND pi.drug_id = d.id;

-- dissulfiram: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; desconhece-se se é perigoso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; it is not known whether it is harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; desconhece-se se é perigoso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; desconhece-se se é perigoso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; it is not known whether it is harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; it is not known whether it is harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'dissulfiram' AND pi.drug_id = d.id;

-- domperidona: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite em quantidades muito pequenas para ser perigoso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in very small amounts unlikely to be harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'domperidona' AND pi.drug_id = d.id;

-- doxazosina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; acumula-se no leite.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; it accumulates in milk.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; acumula-se no leite.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; acumula-se no leite.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; it accumulates in milk.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; it accumulates in milk.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'doxazosina' AND pi.drug_id = d.id;

-- doxiciclina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Usar antibiótico de alternativa.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Use an alternative antibiotic.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Usar antibiótico de alternativa.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Usar antibiótico de alternativa.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Use an alternative antibiotic.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Use an alternative antibiotic.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'doxiciclina' AND pi.drug_id = d.id;

-- eritromicina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; presente no leite, em estudos animais.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; present in milk in animal studies.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite, em estudos animais.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite, em estudos animais.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in animal studies.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in animal studies.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'eritromicina' AND pi.drug_id = d.id;

-- ertapenem: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; presente no leite, em estudos animais.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; present in milk in animal studies.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite, em estudos animais.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite, em estudos animais.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in animal studies.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in animal studies.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'ertapenem' AND pi.drug_id = d.id;

-- eslicarbazepina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'eslicarbazepina' AND pi.drug_id = d.id;

-- fenitoina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente em pequena quantidade no leite; recomenda-se evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in small amounts in milk; avoiding is recommended.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente em pequena quantidade no leite; recomenda-se evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente em pequena quantidade no leite; recomenda-se evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in small amounts in milk; avoiding is recommended.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in small amounts in milk; avoiding is recommended.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fenitoina' AND pi.drug_id = d.id;

-- fenobarbital: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Continuar o aleitamento; sedação; espasmos infantis após interrupção do leite contendo fenobarbital; metahemoglobinemia com fenobarbital e fenitoína; V. Barbitúricos.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Continue breastfeeding; sedation; infantile spasms after stopping milk containing phenobarbital; methaemoglobinaemia with phenobarbital and phenytoin; see Barbiturates.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Continuar o aleitamento; sedação; espasmos infantis após interrupção do leite contendo fenobarbital; metahemoglobinemia com fenobarbital e fenitoína; V. Barbitúricos.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Continuar o aleitamento; sedação; espasmos infantis após interrupção do leite contendo fenobarbital; metahemoglobinemia com fenobarbital e fenitoína; V. Barbitúricos.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Continue breastfeeding; sedation; infantile spasms after stopping milk containing phenobarbital; methaemoglobinaemia with phenobarbital and phenytoin; see Barbiturates.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Continue breastfeeding; sedation; infantile spasms after stopping milk containing phenobarbital; methaemoglobinaemia with phenobarbital and phenytoin; see Barbiturates.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fenobarbital' AND pi.drug_id = d.id;

-- fentanilo: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Quantidade bastante pequena no leite para ser perigosa; evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Amount in milk too small to be harmful; avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade bastante pequena no leite para ser perigosa; evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade bastante pequena no leite para ser perigosa; evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Amount in milk too small to be harmful; avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Amount in milk too small to be harmful; avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fentanilo' AND pi.drug_id = d.id;

-- fexofenadina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Anti-histamínicos H1.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See H1 antihistamines.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Anti-histamínicos H1.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Anti-histamínicos H1.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See H1 antihistamines.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See H1 antihistamines.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fexofenadina' AND pi.drug_id = d.id;

-- filgrastim: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'filgrastim' AND pi.drug_id = d.id;

-- flecainida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Quantidade significativa presente no leite; evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Significant amounts present in milk; avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade significativa presente no leite; evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade significativa presente no leite; evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Significant amounts present in milk; avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Significant amounts present in milk; avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'flecainida' AND pi.drug_id = d.id;

-- fluconazol: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Quantidade significativa no leite; evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Significant amounts in milk; avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade significativa no leite; evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade significativa no leite; evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Significant amounts in milk; avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Significant amounts in milk; avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fluconazol' AND pi.drug_id = d.id;

-- fluoxetina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Antidepressores (inibidores da recaptação de serotonina).' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See Antidepressants (serotonin reuptake inhibitors).' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Antidepressores (inibidores da recaptação de serotonina).'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Antidepressores (inibidores da recaptação de serotonina).'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Antidepressants (serotonin reuptake inhibitors).'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Antidepressants (serotonin reuptake inhibitors).'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fluoxetina' AND pi.drug_id = d.id;

-- fondaparinux: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; presente no leite, em estudos animais.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; present in milk in animal studies.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite, em estudos animais.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; presente no leite, em estudos animais.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in animal studies.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; present in milk in animal studies.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fondaparinux' AND pi.drug_id = d.id;

-- fosfomicina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Excretado no leite; recomenda-se evitar, a menos que seja realmente necessário.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Excreted in milk; avoiding is recommended unless really necessary.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Excretado no leite; recomenda-se evitar, a menos que seja realmente necessário.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Excretado no leite; recomenda-se evitar, a menos que seja realmente necessário.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Excreted in milk; avoiding is recommended unless really necessary.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Excreted in milk; avoiding is recommended unless really necessary.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'fosfomicina' AND pi.drug_id = d.id;

-- furosemida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite em quantidades muito pequenas para ser perigoso; pode inibir a lactação.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in very small amounts unlikely to be harmful; may inhibit lactation.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso; pode inibir a lactação.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso; pode inibir a lactação.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful; may inhibit lactation.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful; may inhibit lactation.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'furosemida' AND pi.drug_id = d.id;

-- gentamicina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'gentamicina' AND pi.drug_id = d.id;

-- glibenclamida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Possibilidade teórica de hipoglicemia no lactente; V. Sulfonilureias.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Theoretical possibility of hypoglycaemia in the infant; see Sulphonylureas.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Possibilidade teórica de hipoglicemia no lactente; V. Sulfonilureias.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Possibilidade teórica de hipoglicemia no lactente; V. Sulfonilureias.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Theoretical possibility of hypoglycaemia in the infant; see Sulphonylureas.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Theoretical possibility of hypoglycaemia in the infant; see Sulphonylureas.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'glibenclamida' AND pi.drug_id = d.id;

-- gliclazida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Sulfonilureias.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See Sulphonylureas.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Sulfonilureias.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Sulfonilureias.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Sulphonylureas.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Sulphonylureas.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'gliclazida' AND pi.drug_id = d.id;

-- glimepirida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Sulfonilureias.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See Sulphonylureas.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Sulfonilureias.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Sulfonilureias.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Sulphonylureas.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Sulphonylureas.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'glimepirida' AND pi.drug_id = d.id;

-- haloperidol: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Antipsicóticos. Atraso no desenvolvimento.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See Antipsychotics. Developmental delay.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Antipsicóticos. Atraso no desenvolvimento.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Antipsicóticos. Atraso no desenvolvimento.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Antipsychotics. Developmental delay.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Antipsychotics. Developmental delay.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'haloperidol' AND pi.drug_id = d.id;

-- hidroxicloroquina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite em quantidades muito pequenas para ser perigosa.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in very small amounts unlikely to be harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigosa.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigosa.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'hidroxicloroquina' AND pi.drug_id = d.id;

-- ibuprofeno: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite em quantidades muito pequenas para ser perigoso; seguro nas doses usuais, mas alguns produtores recomendam evitar, mesmo em uso tópico.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in very small amounts unlikely to be harmful; safe at usual doses, but some manufacturers recommend avoiding, even in topical use.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso; seguro nas doses usuais, mas alguns produtores recomendam evitar, mesmo em uso tópico.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso; seguro nas doses usuais, mas alguns produtores recomendam evitar, mesmo em uso tópico.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful; safe at usual doses, but some manufacturers recommend avoiding, even in topical use.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful; safe at usual doses, but some manufacturers recommend avoiding, even in topical use.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'ibuprofeno' AND pi.drug_id = d.id;

-- indacaterol: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Há excreção do indacaterol e metabolitos no leite, em estudos de toxicologia animal; não se podendo excluir a presença no leite materno, decidir-se-á em cada caso a descontinuação do aleitamento ou a abstinência do fármaco.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Indacaterol and metabolites are excreted in milk in animal toxicology studies; since presence in human milk cannot be excluded, decide in each case whether to discontinue breastfeeding or abstain from the drug.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Há excreção do indacaterol e metabolitos no leite, em estudos de toxicologia animal; não se podendo excluir a presença no leite materno, decidir-se-á em cada caso a descontinuação do aleitamento ou a abstinência do fármaco.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Há excreção do indacaterol e metabolitos no leite, em estudos de toxicologia animal; não se podendo excluir a presença no leite materno, decidir-se-á em cada caso a descontinuação do aleitamento ou a abstinência do fármaco.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Indacaterol and metabolites are excreted in milk in animal toxicology studies; since presence in human milk cannot be excluded, decide in each case whether to discontinue breastfeeding or abstain from the drug.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Indacaterol and metabolites are excreted in milk in animal toxicology studies; since presence in human milk cannot be excluded, decide in each case whether to discontinue breastfeeding or abstain from the drug.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'indacaterol' AND pi.drug_id = d.id;

-- indapamida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'indapamida' AND pi.drug_id = d.id;

-- lamivudina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Risco teórico de convulsões e neuropatia; administrar piridoxina profiláctica à mãe e à criança.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Theoretical risk of seizures and neuropathy; give prophylactic pyridoxine to the mother and child.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Risco teórico de convulsões e neuropatia; administrar piridoxina profiláctica à mãe e à criança.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Risco teórico de convulsões e neuropatia; administrar piridoxina profiláctica à mãe e à criança.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Theoretical risk of seizures and neuropathy; give prophylactic pyridoxine to the mother and child.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Theoretical risk of seizures and neuropathy; give prophylactic pyridoxine to the mother and child.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'lamivudina' AND pi.drug_id = d.id;

-- levodopa: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'A levodopa pode suprimir a lactação; está presente no leite; evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Levodopa may suppress lactation; it is present in milk; avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: A levodopa pode suprimir a lactação; está presente no leite; evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: A levodopa pode suprimir a lactação; está presente no leite; evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Levodopa may suppress lactation; it is present in milk; avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Levodopa may suppress lactation; it is present in milk; avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'levodopa' AND pi.drug_id = d.id;

-- levotiroxina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Quantidade muito pequena no leite mas pode interferir com o diagnóstico neonatal de hipotiroidismo.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Very small amounts in milk, but may interfere with neonatal screening for hypothyroidism.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade muito pequena no leite mas pode interferir com o diagnóstico neonatal de hipotiroidismo.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidade muito pequena no leite mas pode interferir com o diagnóstico neonatal de hipotiroidismo.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Very small amounts in milk, but may interfere with neonatal screening for hypothyroidism.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Very small amounts in milk, but may interfere with neonatal screening for hypothyroidism.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'levotiroxina' AND pi.drug_id = d.id;

-- linezolida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite, em estudos animais; o produtor recomenda evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in animal studies; the manufacturer recommends avoiding.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite, em estudos animais; o produtor recomenda evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite, em estudos animais; o produtor recomenda evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in animal studies; the manufacturer recommends avoiding.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in animal studies; the manufacturer recommends avoiding.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'linezolida' AND pi.drug_id = d.id;

-- litio: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'A amamentação continuada pode aumentá-la, com toxicidade do lactente; o bom controlo da litiemia materna reduz os riscos.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Continued breastfeeding may raise it, with toxicity to the infant; good maternal lithium control reduces the risks.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: A amamentação continuada pode aumentá-la, com toxicidade do lactente; o bom controlo da litiemia materna reduz os riscos.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: A amamentação continuada pode aumentá-la, com toxicidade do lactente; o bom controlo da litiemia materna reduz os riscos.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Continued breastfeeding may raise it, with toxicity to the infant; good maternal lithium control reduces the risks.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Continued breastfeeding may raise it, with toxicity to the infant; good maternal lithium control reduces the risks.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'litio' AND pi.drug_id = d.id;

-- loratadina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Anti-histamínicos H1.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See H1 antihistamines.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Anti-histamínicos H1.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Anti-histamínicos H1.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See H1 antihistamines.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See H1 antihistamines.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'loratadina' AND pi.drug_id = d.id;

-- montelucaste: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite materno; a utilização durante o aleitamento só deve ocorrer se o benefício for claramente superior ao risco.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in breast milk; use during breastfeeding only if the benefit is clearly greater than the risk.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite materno; a utilização durante o aleitamento só deve ocorrer se o benefício for claramente superior ao risco.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite materno; a utilização durante o aleitamento só deve ocorrer se o benefício for claramente superior ao risco.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in breast milk; use during breastfeeding only if the benefit is clearly greater than the risk.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in breast milk; use during breastfeeding only if the benefit is clearly greater than the risk.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'montelukast' AND pi.drug_id = d.id;

-- moxifloxacina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'V. Tetraciclinas.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'See Tetracyclines.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Tetraciclinas.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: V. Tetraciclinas.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Tetracyclines.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: See Tetracyclines.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'moxifloxacina' AND pi.drug_id = d.id;

-- mupirocina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite em quantidades muito pequenas para ser perigoso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in very small amounts unlikely to be harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite em quantidades muito pequenas para ser perigoso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in very small amounts unlikely to be harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'mupirocina' AND pi.drug_id = d.id;

-- naproxeno: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Usar com precaução ou mesmo evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Use with caution or even avoid.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Usar com precaução ou mesmo evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Usar com precaução ou mesmo evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Use with caution or even avoid.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Use with caution or even avoid.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'naproxeno' AND pi.drug_id = d.id;

-- nitrofurantoina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Quantidades muito reduzidas no leite, mas que podem ser suficientes para produzir hemólise em lactentes com défice em G-6-PD.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Very small amounts in milk, but may be enough to cause haemolysis in infants with G-6-PD deficiency.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidades muito reduzidas no leite, mas que podem ser suficientes para produzir hemólise em lactentes com défice em G-6-PD.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Quantidades muito reduzidas no leite, mas que podem ser suficientes para produzir hemólise em lactentes com défice em G-6-PD.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Very small amounts in milk, but may be enough to cause haemolysis in infants with G-6-PD deficiency.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Very small amounts in milk, but may be enough to cause haemolysis in infants with G-6-PD deficiency.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'nitrofurantoina' AND pi.drug_id = d.id;

-- propafenona: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar o aleitamento durante 72 horas após o tratamento.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid breastfeeding for 72 hours after treatment.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar o aleitamento durante 72 horas após o tratamento.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar o aleitamento durante 72 horas após o tratamento.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid breastfeeding for 72 hours after treatment.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid breastfeeding for 72 hours after treatment.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'propafenona' AND pi.drug_id = d.id;

-- pseudoefedrina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Presente no leite, em estudos animais; o produtor recomenda evitar.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Present in milk in animal studies; the manufacturer recommends avoiding.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite, em estudos animais; o produtor recomenda evitar.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Presente no leite, em estudos animais; o produtor recomenda evitar.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in animal studies; the manufacturer recommends avoiding.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Present in milk in animal studies; the manufacturer recommends avoiding.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'pseudoefedrina' AND pi.drug_id = d.id;

-- quinina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; risco de hemólise em lactentes com défice em G-6-PD.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; risk of haemolysis in infants with G-6-PD deficiency.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; risco de hemólise em lactentes com défice em G-6-PD.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; risco de hemólise em lactentes com défice em G-6-PD.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; risk of haemolysis in infants with G-6-PD deficiency.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; risk of haemolysis in infants with G-6-PD deficiency.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'quinina' AND pi.drug_id = d.id;

-- ritonavir: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Aleitamento possível nos primeiros 6 meses, se não há alternativa segura.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Breastfeeding possible in the first 6 months if there is no safe alternative.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Aleitamento possível nos primeiros 6 meses, se não há alternativa segura.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Aleitamento possível nos primeiros 6 meses, se não há alternativa segura.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Breastfeeding possible in the first 6 months if there is no safe alternative.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Breastfeeding possible in the first 6 months if there is no safe alternative.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'ritonavir' AND pi.drug_id = d.id;

-- sirolimus: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Não se sabe se é perigoso.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'It is not known whether it is harmful.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não se sabe se é perigoso.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não se sabe se é perigoso.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: It is not known whether it is harmful.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: It is not known whether it is harmful.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'sirolimus' AND pi.drug_id = d.id;

-- sulfassalazina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'sulfassalazina' AND pi.drug_id = d.id;

-- ticagrelor: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Contra-indicada durante o aleitamento.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Contraindicated during breastfeeding.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Contra-indicada durante o aleitamento.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Contra-indicada durante o aleitamento.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Contraindicated during breastfeeding.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Contraindicated during breastfeeding.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'ticagrelor' AND pi.drug_id = d.id;

-- tobramicina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'tobramicina' AND pi.drug_id = d.id;

-- tramadol: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Avoid; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Avoid; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'tramadol' AND pi.drug_id = d.id;

-- valproato: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'No useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: No useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: No useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'valproato' AND pi.drug_id = d.id;

-- vancomicina: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'O produtor recomenda evitar; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'The manufacturer recommends avoiding; no useful information is available.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: O produtor recomenda evitar; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: O produtor recomenda evitar; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: The manufacturer recommends avoiding; no useful information is available.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: The manufacturer recommends avoiding; no useful information is available.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'vancomicina' AND pi.drug_id = d.id;

-- micofenolato: Anexo 2 (entrada "Ácido micofenólico (micofenolato de mofetil)")
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'Contra-indicado. Excluir uma gravidez antes de iniciar o tratamento e aguardar 6 meses após a interrupção do fármaco para iniciar a gravidez e o aleitamento.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'Contraindicated. Exclude a pregnancy before starting treatment and wait 6 months after stopping the drug before becoming pregnant or breastfeeding.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Contra-indicado. Excluir uma gravidez antes de iniciar o tratamento e aguardar 6 meses após a interrupção do fármaco para iniciar a gravidez e o aleitamento.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: Contra-indicado. Excluir uma gravidez antes de iniciar o tratamento e aguardar 6 meses após a interrupção do fármaco para iniciar a gravidez e o aleitamento.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Contraindicated. Exclude a pregnancy before starting treatment and wait 6 months after stopping the drug before becoming pregnant or breastfeeding.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: Contraindicated. Exclude a pregnancy before starting treatment and wait 6 months after stopping the drug before becoming pregnant or breastfeeding.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'micofenolato' AND pi.drug_id = d.id;

-- pimozida: Anexo 2
UPDATE public.drug_pregnancy_info pi
SET lactation_pt = CASE WHEN pi.lactation_pt = '' OR pi.lactation_pt ILIKE 'Sem dados%' OR pi.lactation_pt ILIKE 'Sem informa%' OR pi.lactation_pt ILIKE 'Desconhecida%'
                         THEN E'O produtor recomenda evitar, a menos que o seu uso seja imperioso; não há informação útil.' ELSE pi.lactation_pt END,
    lactation_en = CASE WHEN pi.lactation_en = '' OR pi.lactation_en ILIKE 'No data%' OR pi.lactation_en ILIKE 'Unknown%' OR pi.lactation_en ILIKE 'No information%'
                         THEN E'The manufacturer recommends avoiding, unless its use is essential; there is no useful information.' ELSE pi.lactation_en END,
    source_pt    = CASE WHEN pi.source_pt = '' THEN E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: O produtor recomenda evitar, a menos que o seu uso seja imperioso; não há informação útil.'
                        WHEN pi.source_pt NOT LIKE '%Anexo 2%' THEN pi.source_pt || ' ; ' || E'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 2, Fármacos e Aleitamento: O produtor recomenda evitar, a menos que o seu uso seja imperioso; não há informação útil.'
                        ELSE pi.source_pt END,
    source_en    = CASE WHEN pi.source_en = '' THEN E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: The manufacturer recommends avoiding, unless its use is essential; there is no useful information.'
                        WHEN pi.source_en NOT LIKE '%Annex 2%' THEN pi.source_en || ' ; ' || E'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 2, Drugs and Breastfeeding: The manufacturer recommends avoiding, unless its use is essential; there is no useful information.'
                        ELSE pi.source_en END,
    updated_at = now()
FROM public.drugs d
WHERE d.slug = E'pimozida' AND pi.drug_id = d.id;

