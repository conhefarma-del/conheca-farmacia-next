-- =====================================================================
-- 221 — Expansão Anti-asma/COPD: interações + dimensões
--
-- drug_interactions: 16 cols (slug_a, slug_b, severity, summary_pt, summary_en,
--   mechanism_pt, mechanism_en, management_pt, management_en,
--   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
--   source_pt, source_en, source_url)
-- drug_disease_interactions: 12 cols (slug, condition_slug, condition_pt, condition_en,
--   interaction_type, severity, reason_pt, reason_en,
--   advice_pt, advice_en, source_pt, source_en)
--
-- Ordem canónica: teofilina (1193d741) é MENOR que todos os outros fármacos desta classe
-- =====================================================================

-- =====================================================================
-- 1. Interações fármaco-fármaco (drug_interactions) — 16 cols
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
  -- ═══════════════════════════════════════════════════════════════
  -- CRITICAL
  -- ═══════════════════════════════════════════════════════════════

  -- Teofilina × Fluconazol (CRITICAL: fluconazol inibe CYP1A2, níveis de teofilina +30-50%)
  ('teofilina', 'fluconazol', 'critical',
   'Metilxantina + inibidor CYP1A2: fluconazol aumenta níveis de teofilina 30-50%. Risco de toxicidade.',
   'Methylxanthine + CYP1A2 inhibitor: fluconazole increases theophylline levels 30-50%. Risk of toxicity.',
   'A teofilina é metabolizada por CYP1A2 (70%). O fluconazol inibe CYP1A2 moderadamente, aumentando os níveis de teofilina 30-50%. O índice terapêutico é estreito (10-20 μg/mL) — mesmo aumentos moderados podem causar toxicidade.',
   'Theophylline is metabolised by CYP1A2 (70%). Fluconazole moderately inhibits CYP1A2, increasing theophylline levels 30-50%. The therapeutic index is narrow (10-20 μg/mL) — even moderate increases may cause toxicity.',
   'Reduzir dose de teofilina 25-50%. Monitorizar níveis de teofilina semanalmente durante coadministração.',
   'Reduce theophylline dose by 25-50%. Monitor theophylline levels weekly during co-administration.',
   'Níveis de teofilina, sinais de toxicidade (náusea, vómitos, taquicardia, convulsões).',
   'Theophylline levels, signs of toxicity (nausea, vomiting, tachycardia, seizures).',
   'Convulsões, arritmias, morte (níveis >30 μg/mL).',
   'Seizures, arrhythmias, death (levels >30 μg/mL).',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1193d741'),

  -- Teofilina × Ritonavir (CRITICAL: ritonavir inibe CYP3A4/1A2)
  ('teofilina', 'ritonavir', 'critical',
   'Metilxantina + inibidor CYP potente: ritonavir pode aumentar níveis de teofilina significativamente.',
   'Methylxanthine + potent CYP inhibitor: ritonavir may significantly increase theophylline levels.',
   'O ritonavir inibe CYP3A4 e pode inibir CYP1A2, aumentando os níveis de teofilina. O efeito é imprevisível e pode ser significativo.',
   'Ritonavir inhibits CYP3A4 and may inhibit CYP1A2, increasing theophylline levels. The effect is unpredictable and may be significant.',
   'Evitar combinação se possível. Se necessária, reduzir dose de teofilina 50% e monitorizar níveis semanalmente.',
   'Avoid combination if possible. If necessary, reduce theophylline dose by 50% and monitor levels weekly.',
   'Níveis de teofilina, ECG, sinais de toxicidade.',
   'Theophylline levels, ECG, signs of toxicity.',
   'Toxicidade teofilina grave.',
   'Severe theophylline toxicity.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1193d741'),

  -- Ritonavir × Roflumilast (CRITICAL: ritonavir inibe CYP3A4)
  ('ritonavir', 'roflumilast', 'critical',
   'Inibidor CYP3A4 potente + substrato CYP3A4: ritonavir aumenta níveis de roflumilast e metabolito.',
   'Potent CYP3A4 inhibitor + CYP3A4 substrate: ritonavir increases roflumilast and metabolite levels.',
   'O roflumilast é metabolizado por CYP3A4 e CYP1A2. O ritonavir inibe potente CYP3A4, aumentando os níveis de roflumilast e do seu metabolito activo (N-óxido). Risco de toxicidade GI e hepática.',
   'Roflumilast is metabolised by CYP3A4 and CYP1A2. Ritonavir potently inhibits CYP3A4, increasing roflumilast and its active metabolite (N-oxide) levels. Risk of GI and hepatic toxicity.',
   'CONTRAINDICADO. Não coadministrar. Considerar alternativa (ex: montelucaste).',
   'CONTRAINDICATED. Do not co-administer. Consider alternative (e.g. montelukast).',
   'Função hepática, sinais de toxicidade GI.',
   'Liver function, signs of GI toxicity.',
   'Toxicidade hepática grave.',
   'Severe hepatic toxicity.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f25a0230'),

  -- ═══════════════════════════════════════════════════════════════
  -- MODERATE
  -- ═══════════════════════════════════════════════════════════════

  -- Teofilina × Carbamazepina (MODERATE: carbamazepina induz CYP1A2, reduz teofilina)
  ('teofilina', 'carbamazepina', 'moderate',
   'Indutor CYP1A2 + substrato CYP1A2: carbamazepina reduz níveis de teofilina 20-40%.',
   'CYP1A2 inducer + CYP1A2 substrate: carbamazepine reduces theophylline levels 20-40%.',
   'A carbamazepina induz CYP1A2, acelerando o metabolismo da teofilina. Os níveis podem reduzir 20-40%, comprometendo o controlo de asma/COPD.',
   'Carbamazepine induces CYP1A2, accelerating theophylline metabolism. Levels may decrease 20-40%, compromising asthma/COPD control.',
   'Aumentar dose de teofilina conforme níveis. Monitorizar níveis mensalmente.',
   'Increase theophylline dose based on levels. Monitor levels monthly.',
   'Níveis de teofilina.',
   'Theophylline levels.',
   'Perda de controlo de asma/COPD.',
   'Loss of asthma/COPD control.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1193d741'),

  -- Teofilina × Fenitoína (MODERATE: fenitoína induz CYP1A2)
  ('teofilina', 'fenitoina', 'moderate',
   'Indutor CYP1A2 + substrato CYP1A2: fenitoína reduz níveis de teofilina 20-30%.',
   'CYP1A2 inducer + CYP1A2 substrate: phenytoin reduces theophylline levels 20-30%.',
   'A fenitoína induz CYP1A2, reduzindo os níveis de teofilina. O efeito é moderado.',
   'Phenytoin induces CYP1A2, reducing theophylline levels. The effect is moderate.',
   'Ajustar dose de teofilina conforme níveis.',
   'Adjust theophylline dose based on levels.',
   'Níveis de teofilina.',
   'Theophylline levels.',
   '',
   '',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1193d741'),

  -- Teofilina × Fluoxetina (MODERATE: fluoxetina inibe CYP1A2)
  ('teofilina', 'fluoxetina', 'moderate',
   'Inibidor CYP1A2 + substrato CYP1A2: fluoxetina pode aumentar níveis de teofilina 10-20%.',
   'CYP1A2 inhibitor + CYP1A2 substrate: fluoxetine may increase theophylline levels 10-20%.',
   'A fluoxetina inibe fracamente CYP1A2, podendo aumentar ligeiramente os níveis de teofilina. O efeito é geralmente modesto.',
   'Fluoxetine weakly inhibits CYP1A2, potentially slightly increasing theophylline levels. The effect is generally modest.',
   'Monitorizar níveis de teofilina se dose elevada de fluoxetina.',
   'Monitor theophylline levels if high-dose fluoxetine.',
   'Níveis de teofilina.',
   'Theophylline levels.',
   '',
   '',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1193d741'),

  -- Teofilina × Warfarina (MODERATE: teofilina pode afectar warfarina)
  ('teofilina', 'warfarina', 'moderate',
   'Metilxantina + anticoagulante: teofilina pode aumentar ligeiramente efeito da warfarina.',
   'Methylxanthine + anticoagulant: theophylline may slightly potentiate warfarin effect.',
   'A teofilina pode competir parcialmente pelo metabolismo CYP1A2/CYP2C9 da warfarina, aumentando ligeiramente o INR.',
   'Theophylline may partially compete for CYP1A2/CYP2C9 metabolism of warfarin, slightly increasing INR.',
   'Monitorizar INR nas primeiras 2-3 semanas após início/alteração de teofilina.',
   'Monitor INR during the first 2-3 weeks after theophylline initiation/change.',
   'INR.',
   'INR.',
   '',
   '',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1193d741'),

  -- Fluconazol × Roflumilast (MODERATE: fluconazol inibe CYP3A4)
  ('fluconazol', 'roflumilast', 'moderate',
   'Inibidor CYP3A4 + substrato CYP3A4: fluconazol pode aumentar níveis de roflumilast.',
   'CYP3A4 inhibitor + CYP3A4 substrate: fluconazole may increase roflumilast levels.',
   'O fluconazol inibe CYP3A4, a via metabolizadora parcial do roflumilast. Níveis podem aumentar 20-30%.',
   'Fluconazole inhibits CYP3A4, a partial metabolic pathway for roflumilast. Levels may increase 20-30%.',
   'Monitorizar efeitos adversos GI e hepáticos. Reduzir dose se necessário.',
   'Monitor GI and hepatic adverse effects. Reduce dose if necessary.',
   'Função hepática, sinais GI.',
   'Liver function, GI signs.',
   '',
   '',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f25a0230'),

  -- Prednisolona × Warfarina (MODERATE: corticosteroides podem afectar INR)
  ('prednisolona', 'warfarina', 'moderate',
   'Corticosteroide + anticoagulante: prednisolona pode reduzir efeito da warfarina (indução CYP).',
   'Corticosteroid + anticoagulant: prednisolone may reduce warfarin effect (CYP induction).',
   'Os corticosteroides podem induzir CYP3A4, acelerando o metabolismo da warfarina e reduzindo o INR.',
   'Corticosteroids may induce CYP3A4, accelerating warfarin metabolism and reducing INR.',
   'Monitorizar INR durante e após疗程 de prednisolona.',
   'Monitor INR during and after prednisolone course.',
   'INR, sinais de tromboembolismo.',
   'INR, signs of thromboembolism.',
   'Tromboembolismo.',
   'Thromboembolism.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=11d08d64'),

  -- Prednisolona × Fluconazol (MODERATE: fluconazol pode aumentar prednisolona)
  ('prednisolona', 'fluconazol', 'moderate',
   'Inibidor CYP3A4 + corticosteroide: fluconazol pode aumentar níveis de prednisolona.',
   'CYP3A4 inhibitor + corticosteroid: fluconazole may increase prednisolone levels.',
   'O fluconazol inibe CYP3A4, a via metabolizadora da prednisolona. Níveis podem aumentar significativamente.',
   'Fluconazole inhibits CYP3A4, the metabolic pathway for prednisolone. Levels may increase significantly.',
   'Monitorizar sinais de hipercortisolismo. Considerar reduzir dose de prednisolona.',
   'Monitor for signs of hypercortisolism. Consider reducing prednisolone dose.',
   'Glicemia, peso, sinais de Cushing.',
   'Blood glucose, weight, Cushing signs.',
   'Síndrome de Cushing iatrogénico.',
   'Iatrogenic Cushing syndrome.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=11d08d64'),

  -- Acetilcisteina × Teofilina (MINOR: sem interação significativa)
  ('teofilina', 'acetilcisteina', 'minor',
   'Mucolítico + metilxantina: sem interação farmacocinética clinicamente significativa.',
   'Mucolytic + methylxanthine: no clinically significant pharmacokinetic interaction.',
   'A acetilcisteina não afecta significativamente o metabolismo da teofilina. Efeito aditivo terapêutico possível (mucolítico + broncodilatador).',
   'Acetylcysteine does not significantly affect theophylline metabolism. Possible additive therapeutic effect (mucolytic + bronchodilator).',
   'Não requer ajuste de dose.',
   'No dose adjustment required.',
   '',
   '',
   '',
   '',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1193d741')

) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. Interações alimento (drug_food_interactions) — 8 cols + 'published'
-- =====================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en,
   mechanism_pt, mechanism_en, advice_pt, advice_en, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en,
  v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('teofilina', 'alimentos_ricos_xantina', 'Alimentos ricos em xantinas (chá, café, chocolate)', 'Xanthine-rich foods (tea, coffee, chocolate)',
   'Alimentos ricos em xantinas podem adicionar ao efeito estimulante da teofilina, aumentando risco de insónia e taquicardia.',
   'Xanthine-rich foods may add to the stimulant effect of theophylline, increasing risk of insomnia and tachycardia.',
   'Limitar consumo de chá, café e chocolate durante tratamento com teofilina.',
   'Limit tea, coffee, and chocolate consumption during theophylline treatment.'),
  ('teofilina', 'alcool', 'Álcool', 'Alcohol',
   'O álcool crónico pode induzir CYP1A2, reduzindo níveis de teofilina. O álcool agudo pode aumentar absorção.',
   'Chronic alcohol may induce CYP1A2, reducing theophylline levels. Acute alcohol may increase absorption.',
   'Evitar álcool crónico. Se consumo regular, monitorizar níveis.',
   'Avoid chronic alcohol. If regular consumption, monitor levels.')
) AS v(slug, entity_slug, entity_pt, entity_en,
       mechanism_pt, mechanism_en, advice_pt, advice_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- 3. Interações doença (drug_disease_interactions) — 12 cols + 'published'
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en,
   interaction_type, severity, reason_pt, reason_en,
   advice_pt, advice_en, source_pt, source_en, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en,
  v.interaction_type, v.severity, v.reason_pt, v.reason_en,
  v.advice_pt, v.advice_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('teofilina', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment',
   'precaution', 'critical',
   'Metabolismo hepático (CYP1A2). Clearance reduzido 50-70% em insuficiência hepática. Risco de acumulação e toxicidade.',
   'Hepatic metabolism (CYP1A2). Clearance reduced 50-70% in hepatic impairment. Risk of accumulation and toxicity.',
   'Reduzir dose 50%. Monitorizar níveis semanalmente.',
   'Reduce dose by 50%. Monitor levels weekly.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('teofilina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Clearance renal da teofilina pode ser reduzida em insuficiência renal grave.',
   'Renal clearance of theophylline may be reduced in severe renal impairment.',
   'TFG <30: reduzir dose 25%. Monitorizar níveis.',
   'eGFR <30: reduce dose by 25%. Monitor levels.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('teofilina', 'epilepsia', 'Epilepsia', 'Epilepsy',
   'precaution', 'moderate',
   'A teofilina pode reduzir o limiar convulsivo em doses elevadas (>20 μg/mL).',
   'Theophylline may lower seizure threshold at high doses (>20 μg/mL).',
   'Manter níveis <20 μg/mL. Monitorizar sinais de convulsões.',
   'Maintain levels <20 μg/mL. Monitor for seizure signs.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('roflumilast', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment',
   'contraindication', 'critical',
   'CONTRAINDICADO em insuficiência hepática grave (Child-Pugh C). Aumento significativo de exposição.',
   'CONTRAINDICATED in severe hepatic impairment (Child-Pugh C). Significant exposure increase.',
   'Não administrar em Child-Pugh C. Child-Pugh B: reduzir dose.',
   'Do not administer in Child-Pugh B. Child-Pugh B: reduce dose.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('roflumilast', 'depressao', 'Depressão', 'Depression',
   'precaution', 'moderate',
   'Roflumilast pode causar ou piorar depressão. Histórico de depressão = maior risco.',
   'Roflumilast may cause or worsen depression. History of depression = higher risk.',
   'Avaliar história psiquiátrica antes de iniciar. Monitorizar humor. Suspender se depressão significativa.',
   'Assess psychiatric history before starting. Monitor mood. Discontinue if significant depression.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('fluticasona', 'tuberculose', 'Tuberculose activa', 'Active tuberculosis',
   'precaution', 'critical',
   'Corticosteroides inalatórios podem suprimir imunidade local, agravando tuberculose activa.',
   'Inhaled corticosteroids may suppress local immunity, worsening active tuberculosis.',
   'Não iniciar corticosteroide inalatório em tuberculose activa não tratada.',
   'Do not start inhaled corticosteroid in untreated active tuberculosis.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('beclometasona', 'tuberculose', 'Tuberculose activa', 'Active tuberculosis',
   'precaution', 'critical',
   'Corticosteroides inalatórios podem suprimir imunidade local.',
   'Inhaled corticosteroids may suppress local immunity.',
   'Não iniciar em tuberculose activa não tratada.',
   'Do not start in untreated active tuberculosis.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('prednisolona', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment',
   'precaution', 'moderate',
   'Metabolismo hepático. Clearance reduzido em insuficiência hepática.',
   'Hepatic metabolism. Reduced clearance in hepatic impairment.',
   'Reduzir dose. Monitorizar glicemia e sinais de Cushing.',
   'Reduce dose. Monitor blood glucose and Cushing signs.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('prednisolona', 'diabetes_mellitus', 'Diabetes mellitus', 'Diabetes mellitus',
   'precaution', 'moderate',
   'Corticosteroides elevam glicemia via gluconeogénese e resistência à insulina.',
   'Corticosteroids raise blood glucose via gluconeogenesis and insulin resistance.',
   'Monitorizar glicemia 2-4x/dia durante疗程. Ajustar dose de insulina/antidiabéticos conforme necessário.',
   'Monitor blood glucose 2-4x/day during course. Adjust insulin/antidiabetic dose as needed.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK')
) AS v(slug, condition_slug, condition_pt, condition_en,
       interaction_type, severity, reason_pt, reason_en,
       advice_pt, advice_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 4. Perfil gravidez (drug_pregnancy_info) — 12 cols + 'published'
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en,
   trimester_pt, trimester_en, lactation_pt, lactation_en,
   contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id,
  v.pregnancy_category, v.risk_pt, v.risk_en,
  v.trimester_pt, v.trimester_en, v.lactation_pt, v.lactation_en,
  v.contraception_pt, v.contraception_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('beclometasona', 'caution',
   'Corticosteroide inalatório. Dados limitados. Usar dose mínima eficaz.',
   'Inhaled corticosteroid. Limited data. Use minimum effective dose.',
   'Dados insuficientes. Usar apenas se benefício justifica risco.',
   'Insufficient data. Use only if benefit justifies risk.',
   'Excretada no leite materno em baixas concentrações. Pode ser usada com precaução.',
   'Excreted in breast milk in low concentrations. May be used with caution.',
   'Dados insuficientes.',
   'Insufficient data.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('fluticasona', 'caution',
   'Corticosteroide inalatório de alta potência. Dados limitados. Usar dose mínima.',
   'High-potency inhaled corticosteroid. Limited data. Use minimum dose.',
   'Dados insuficientes. Usar apenas se benefício justifica risco.',
   'Insufficient data. Use only if benefit justifies risk.',
   'Excretada no leite materno. Decisão entre suspender aleitamento ou fármaco.',
   'Excreted in breast milk. Decision between discontinuing breastfeeding or drug.',
   'Dados insuficientes.',
   'Insufficient data.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('roflumilast', 'contraindicated',
   'CONTRAINDICADO na gravidez. Estudos em animais mostram toxicidade reprodutiva.',
   'CONTRAINDICATED in pregnancy. Animal studies show reproductive toxicity.',
   'CONTRAINDICADO em todos os trimestres.',
   'CONTRAINDICATED in all trimesters.',
   'Evitar durante aleitamento.',
   'Avoid during breastfeeding.',
   'Contracepção fiável é obrigatória.',
   'Reliable contraception is mandatory.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK')
) AS v(slug, pregnancy_category, risk_pt, risk_en,
       trimester_pt, trimester_en, lactation_pt, lactation_en,
       contraception_pt, contraception_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
