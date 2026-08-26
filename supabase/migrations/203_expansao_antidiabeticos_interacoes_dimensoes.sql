-- =====================================================================
-- 203 — Expansão: pares de interação + dimensões antidiabéticos
--
-- Pares dos 9 fármacos novos com fármacos existentes
-- Dimensões: alimento, doença, gravidez/lactação
-- Fontes: DailyMed, EMC-UK, Prontuário Terapêutico
-- =====================================================================

-- =====================================================================
-- 1. Pares de interação (drug_interactions)
-- =====================================================================
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, source_url, status)
SELECT a.id, b.id, v.severity, v.summary_pt, v.summary_en,
  v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
  v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
  v.source_pt, v.source_en, v.source_url, 'published'
FROM (VALUES
  -- === SGLT2 inhibitors ===
  ('furosemida', 'empagliflozina', 'critical',
   'SGLT2 + diurético de alça: risco severo de desidratação e hipotensão.',
   'SGLT2 + loop diuretic: severe risk of dehydration and hypotension.',
   'Ambos causam diurese. O SGLT2 provoca glicosúria osmótica e o furosemida inibe a reabsorção de NaCl. Efeito aditivo na perda de volume.',
   'Both cause diuresis. SGLT2 causes osmotic glycosuria and furosemide inhibits NaCl reabsorption. Additive volume depletion effect.',
   'Reduzir dose do diurético. Monitorizar eletrólitos e estado de hidratação. Considerar suspender diurético temporariamente.',
   'Reduce diuretic dose. Monitor electrolytes and hydration status. Consider temporarily discontinuing diuretic.',
   'Peso, eletrólitos, pressão arterial, TFG',
   'Weight, electrolytes, blood pressure, GFR',
   'Síncope, hipotensão severa, desidratação grave',
   'Syncope, severe hypotension, severe dehydration',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Empagliflozina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3',
   'DailyMed/FDA (NIH/NLM) — approved Empagliflozin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3',
   ''),
  ('metformina', 'canagliflozina', 'moderate',
   'SGLT2 + biguanida: potencial de desidratação e acidose láctica.',
   'SGLT2 + biguanide: potential for dehydration and lactic acidosis.',
   'Ambos afetam a homeostasia do fluido. A metformina requer hidratação adequada para prevenir acidose láctica.',
   'Both affect fluid homeostasis. Metformin requires adequate hydration to prevent lactic acidosis.',
   'Monitorizar função renal e estado de hidratação. Suspender SGLT2 se desidratado.',
   'Monitor renal function and hydration status. Discontinue SGLT2 if dehydrated.',
   'Creatinina, eletrólitos, estado de hidratação',
   'Creatinine, electrolytes, hydration status',
   'Acidose láctica, desidratação severa',
   'Lactic acidosis, severe dehydration',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Canagliflozina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b9057d3b-b104-4f09-8a61-c61ef9d4a3f3',
   'DailyMed/FDA (NIH/NLM) — approved Canagliflozin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b9057d3b-b104-4f09-8a61-c61ef9d4a3f3',
   ''),
  -- === DPP-4 inhibitors ===
  ('saxagliptina', 'cetoconazol', 'moderate',
   'DPP-4 + antifúngico azólico: aumento dos níveis de saxagliptina.',
   'DPP-4 + azole antifungal: increased saxagliptin levels.',
   'O cetoconazol inibe o CYP3A4, aumentando os níveis de saxagliptina em ~2,5 vezes. Reduzir dose para 2,5 mg/dia.',
   'Ketoconazole inhibits CYP3A4, increasing saxagliptin levels ~2.5-fold. Reduce dose to 2.5 mg/day.',
   'Reduzir dose de saxagliptina para 2,5 mg/dia quando coadministrada com inibidores fortes de CYP3A4.',
   'Reduce saxagliptin dose to 2.5 mg/day when coadministered with strong CYP3A4 inhibitors.',
   'Glicemia',
   'Blood glucose',
   'Hipoglicemia',
   'Hypoglycaemia',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Saxagliptina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c5116390-e0fe-4969-94cb-e9de5165fbab',
   'DailyMed/FDA (NIH/NLM) — approved Saxagliptin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c5116390-e0fe-4969-94cb-e9de5165fbab',
   ''),
  -- === GLP-1 agonists ===
  ('metformina', 'liraglutida', 'minor',
   'GLP-1 RA + biguanida: combinação frequentemente utilizada. Sem interação farmacocinética significativa.',
   'GLP-1 RA + biguanide: frequently used combination. No significant pharmacokinetic interaction.',
   'Mecanismos complementares. Metformina reduz produção hepática de glicose; liraglutida estimula secreção de insulina. Sinergismo glicêmico.',
   'Complementary mechanisms. Metformin reduces hepatic glucose production; liraglutide stimulates insulin secretion. Glycaemic synergy.',
   'Ajustar doses individualmente consoante a resposta glicémica.',
   'Adjust doses individually according to glycaemic response.',
   'Glicemia, HbA1c, peso',
   'Blood glucose, HbA1c, weight',
   'Hipoglicemia (rara em monoterapia com metformina)',
   'Hypoglycaemia (rare with metformin monotherapy)',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Liraglutida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=29f4637b-e204-425b-b89c-3b1a315d6588',
   'DailyMed/FDA (NIH/NLM) — approved Liraglutide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=29f4637b-e204-425b-b89c-3b1a315d6588',
   ''),
  -- === Acarbose ===
  ('acarbose', 'metformina', 'minor',
   'Inibidor da alfa-glucosidase + biguanida: combinação segura e eficaz.',
   'Alpha-glucosidase inhibitor + biguanide: safe and effective combination.',
   'Mecanismos complementares: acarbose retarda digestão de HC; metformina reduz produção hepática de glicose.',
   'Complementary mechanisms: acarbose delays carbohydrate digestion; metformin reduces hepatic glucose production.',
   'Ajustar doses individualmente. Efeitos GI aditivos possíveis.',
   'Adjust doses individually. Additive GI effects possible.',
   'Glicemia pós-prandial, HbA1c',
   'Postprandial glucose, HbA1c',
   'Efeitos GI significativos',
   'Significant GI effects',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Acarbose: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c85bc02a-bf18-4690-84b8-2c256bce5f9f',
   'DailyMed/FDA (NIH/NLM) — approved Acarbose label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c85bc02a-bf18-4690-84b8-2c256bce5f9f',
   '')
) AS v(slug_a, slug_b, severity,
      summary_pt, summary_en,
      mechanism_pt, mechanism_en, management_pt, management_en,
      monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
      source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. Dimensões: Doença/Condição (drug_disease_interactions)
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en,
   interaction_type, severity, reason_pt, reason_en,
   advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en,
  v.interaction_type, v.severity, v.reason_pt, v.reason_en,
  v.advice_pt, v.advice_en,
  v.source_pt, v.source_en, 1, 'published'
FROM (VALUES
  ('empagliflozina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate', 'Redução da eficácia com TFG baixa. Evitar se TFG <20 mL/min.',
   'Reduced efficacy at low eGFR. Avoid if eGFR <20 mL/min.',
   'Ajustar dose consoante TFG. Suspender se TFG <20.',
   'Adjust dose according to eGFR. Discontinue if eGFR <20.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Empagliflozina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3',
   'DailyMed/FDA (NIH/NLM) — approved Empagliflozin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3'),
  ('dapagliflozina', 'insuficiencia_cardiaca', 'Insuficiência cardíaca', 'Heart failure',
   'precaution', 'moderate', 'Reduz hospitalização por IC (estudo DAPA-HF). Considerar em IC com ou sem DM2.',
   'Reduces HF hospitalisation (DAPA-HF trial). Consider in HF with or without T2DM.',
   'Iniciar 10 mg/dia. Benefício independente do controlo glicémico.',
   'Start 10 mg/day. Benefit independent of glycaemic control.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dapagliflozina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=72ad22ae-efe6-4cd6-a302-98aaee423d69',
   'DailyMed/FDA (NIH/NLM) — approved Dapagliflozin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=72ad22ae-efe6-4cd6-a302-98aaee423d69'),
  ('liraglutida', 'pancreatite', 'Pancreatite', 'Pancreatitis',
   'contraindication', 'critical', 'CONTRAINDICADO em pancreatite atual ou prévia. Risco de recorrência.',
   'CONTRAINDICATED in current or past pancreatitis. Risk of recurrence.',
   'Não iniciar. Suspender imediatamente se suspeita de pancreatite.',
   'Do not initiate. Discontinue immediately if pancreatitis suspected.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Liraglutida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=29f4637b-e204-425b-b89c-3b1a315d6588',
   'DailyMed/FDA (NIH/NLM) — approved Liraglutide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=29f4637b-e204-425b-b89c-3b1a315d6588')
) AS v(slug, condition_slug, condition_pt, condition_en,
       interaction_type, severity, reason_pt, reason_en,
       advice_pt, advice_en,
       source_pt, source_en)
JOIN public.drugs d ON d.slug = v.slug
ON CONFLICT DO NOTHING;

-- =====================================================================
-- 3. Dimensões: Gravidez/Lactação (drug_pregnancy_info)
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
  v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
  v.source_pt, v.source_en, 'published'
FROM (VALUES
  ('empagliflozina', 'contraindicated',
   'CONTRAINDICADO na gravidez. Risco de danos fetais renais (no 2º e 3º trimestres).',
   'CONTRAINDICATED in pregnancy. Risk of fetal renal harm (in 2nd and 3rd trimesters).',
   'CONTRAINDICADO no 2º e 3º trimestres.', 'CONTRAINDICATED in 2nd and 3rd trimesters.',
   'Desconhecido se excretado no leite.', 'Unknown if excreted in breast milk.',
   'Suspender pelo menos 3 meses antes da conceção.', 'Discontinue at least 3 months before conception.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Empagliflozina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3',
   'DailyMed/FDA (NIH/NLM) — approved Empagliflozin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8b6261f6-4bdc-462e-8af1-4064664c62f3'),
  ('dapagliflozina', 'contraindicated',
   'CONTRAINDICADO na gravidez. Risco de danos fetais renais.',
   'CONTRAINDICATED in pregnancy. Risk of fetal renal harm.',
   'CONTRAINDICADO no 2º e 3º trimestres.', 'CONTRAINDICATED in 2nd and 3rd trimesters.',
   'Desconhecido se excretado no leite.', 'Unknown if excreted in breast milk.',
   'Suspender antes da conceção.', 'Discontinue before conception.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dapagliflozina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=72ad22ae-efe6-4cd6-a302-98aaee423d69',
   'DailyMed/FDA (NIH/NLM) — approved Dapagliflozin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=72ad22ae-efe6-4cd6-a302-98aaee423d69'),
  ('liraglutida', 'caution',
   'Usar apenas se benefício justificar risco. Dados limitados na gravidez.',
   'Use only if benefit justifies risk. Limited data in pregnancy.',
   'Evitar no 1º trimestre se possível.', 'Avoid in 1st trimester if possible.',
   'Desconhecido se excretado no leite.', 'Unknown if excreted in breast milk.',
   'Usar método contraceptivo eficaz.', 'Use effective contraception.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Liraglutida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=29f4637b-e204-425b-b89c-3b1a315d6588',
   'DailyMed/FDA (NIH/NLM) — approved Liraglutide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=29f4637b-e204-425b-b89c-3b1a315d6588')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en,
       source_pt, source_en)
JOIN public.drugs d ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
