-- =====================================================================
-- 209 — Expansão Analgésicos/Anti-inflamatórios: pares + dimensões
--
-- Pares: critical + moderate + minor
-- Dimensões: alimento, doença, gravidez
-- Fontes: DailyMed/FDA, EMC-UK, Health Canada
--
-- NOTA: Verificar ordem canónica (drug_a_id < drug_b_id) após aplicar 208
-- =====================================================================

-- =====================================================================
-- 1. Pares de interação (drug_interactions)
-- =====================================================================
-- NOTA: Estes pares serão validados após a aplicação da migração 208
-- porque os UUIDs dos novos fármacos ainda não existem na BD.
-- Se algum par falhar por canonical_order, trocar a ordem dos slugs.

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
  -- CRITICAL: Metadona + Benzodiazepinas (não incluídas na BD — par de referência)
  -- CRITICAL: Indometacina + Lítio
  ('indometacina', 'litio', 'critical',
   'AINE + lítio: níveis de lítio aumentados 15-30%. Risco de toxicidade por lítio (tremor, confusão, convulsões).',
   'NSAID + lithium: lithium levels increased 15-30%. Risk of lithium toxicity (tremor, confusion, seizures).',
   'A indometacina reduz a clearance renal do lítio, aumentando os níveis séricos. O efeito é mais pronunciado com indometacina que com outros AINE. A toxicidade pode ser grave.',
   'Indomethacin reduces renal clearance of lithium, increasing serum levels. The effect is more pronounced with indomethacin than other NSAIDs. Toxicity can be severe.',
   'Evitar combinação se possível. Se necessário, reduzir dose de lítio 20-30% e monitorizar níveis de lítio semanalmente durante as primeiras 2 semanas.',
   'Avoid combination if possible. If necessary, reduce lithium dose by 20-30% and monitor lithium levels weekly during the first 2 weeks.',
   'Níveis de lítio, sinais de toxicidade (tremor, náusea, confusão, diarreia).',
   'Lithium levels, signs of toxicity (tremor, nausea, confusion, diarrhoea).',
   'Nível de lítio >1,5 mEq/L, sinais neurológicos graves.',
   'Lithium level >1.5 mEq/L, severe neurological signs.',
   'DailyMed/FDA — rótulo aprovado Indometacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'DailyMed/FDA — approved Indomethacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2'
  ),
  -- CRITICAL: Metadona + Ritonavir
  ('ritonavir', 'metadona', 'critical',
   'Inibidor de CYP3A4 + opioide: níveis de metadona aumentados significativamente. Risco de sedação excessiva e depressão respiratória.',
   'CYP3A4 inhibitor + opioid: methadone levels significantly increased. Risk of excessive sedation and respiratory depression.',
   'O ritonavir inibe fortemente o CYP3A4 e CYP2B6, as principais vias metabolizadoras da metadona. Os níveis de metadona podem aumentar 2-4x. Risco de prolongamento do QTc e depressão respiratória.',
   'Ritonavir strongly inhibits CYP3A4 and CYP2B6, the main metabolic pathways for methadone. Methadone levels may increase 2-4-fold. Risk of QTc prolongation and respiratory depression.',
   'Evitar combinação se possível. Se necessário, reduzir dose de metadona 50-75% e monitorizar estreitamente. Considerar ECG para QTc.',
   'Avoid combination if possible. If necessary, reduce methadone dose by 50-75% and monitor closely. Consider ECG for QTc.',
   'Sedação, frequência respiratória, ECG (QTc), sinais de depressão respiratória.',
   'Sedation, respiratory rate, ECG (QTc), signs of respiratory depression.',
   'Depressão respiratória, QTc >500 ms, sincope.',
   'Respiratory depression, QTc >500 ms, syncope.',
   'DailyMed/FDA — rótulo aprovado Metadona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'DailyMed/FDA — approved Methadone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138'
  ),
  -- MODERATE: Ketorolaco + Warfarina
  ('warfarina', 'ketorolaco', 'moderate',
   'AINE injectável + anticoagulante: risco aumentado de hemorragia. Inibição plaquetária + efeito anticoagulante.',
   'Injectable NSAID + anticoagulant: increased bleeding risk. Platelet inhibition + anticoagulant effect.',
   'O ketorolaco inibe fortemente COX-1, reduzindo a agregação plaquetária. Em combinação com warfarina, o risco de hemorragia GI e outras hemorragias é significativamente aumentado.',
   'Ketorolac strongly inhibits COX-1, reducing platelet aggregation. Combined with warfarin, the risk of GI and other bleeding is significantly increased.',
   'Evitar combinação. Se inevitável, monitorizar INR diariamente e sinais de hemorragia. Duração máxima do ketorolaco: 5 dias.',
   'Avoid combination. If unavoidable, monitor INR daily and signs of bleeding. Maximum ketorolac duration: 5 days.',
   'INR, sinais de hemorragia (equimoses, hematúria, melena).',
   'INR, signs of bleeding (bruising, haematuria, melaena).',
   'Hemorragia grave, queda de Hb >2 g/dL.',
   'Major bleeding, Hb drop >2 g/dL.',
   'DailyMed/FDA — rótulo aprovado Ketorolaco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'DailyMed/FDA — approved Ketorolac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6'
  ),
  -- MODERATE: Piroxicam + Warfarina
  ('warfarina', 'piroxicam', 'moderate',
   'AINE de meia-vida longa + anticoagulante: risco aumentado de hemorragia. Acumulação prolongada.',
   'Long half-life NSAID + anticoagulant: increased bleeding risk. Prolonged accumulation.',
   'A meia-vida longa do piroxicam (50 h) prolonga a exposição ao efeito antiagregante plaquetário. O risco de hemorragia é superior ao de AINE de meia-vida curta.',
   'The long half-life of piroxicam (50 h) prolongs exposure to the antiplatelet effect. Bleeding risk is higher than with short half-life NSAIDs.',
   'Evitar combinação. Se necessário, monitorizar INR semanalmente. Considerar AINE de meia-vida curta (ibuprofeno) como alternativa.',
   'Avoid combination. If necessary, monitor INR weekly. Consider short half-life NSAID (ibuprofen) as alternative.',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia grave.',
   'Major bleeding.',
   'DailyMed/FDA — rótulo aprovado Piroxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'DailyMed/FDA — approved Piroxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3'
  ),
  -- MODERATE: Indometacina + Metotrexato
  ('indometacina', 'metotrexato', 'moderate',
   'AINE + antimetabolito: clearance renal do metotrexato reduzido. Risco de toxicidade (mielossupressão, mucosite).',
   'NSAID + antimetabolite: methotrexate renal clearance reduced. Risk of toxicity (myelosuppression, mucositis).',
   'A indometacina reduz o fluxo sanguíneo renal e a secreção tubular do metotrexato, aumentando os níveis séricos. Risco de pancitopenia e mucosite.',
   'Indomethacin reduces renal blood flow and tubular secretion of methotrexate, increasing serum levels. Risk of pancytopenia and mucositis.',
   'Evitar AINE durante tratamento com doses altas de metotrexato. Se necessário, monitorizar hemograma semanalmente e níveis de metotrexato.',
   'Avoid NSAIDs during high-dose methotrexate. If necessary, monitor blood count weekly and methotrexate levels.',
   'Hemograma, níveis de metotrexato, sinais de mucosite.',
   'Blood count, methotrexate levels, signs of mucositis.',
   'Pancitopenia, mucosite grave, neutrófilos <500/mm³.',
   'Pancytopenia, severe mucositis, neutrophils <500/mm³.',
   'DailyMed/FDA — rótulo aprovado Indometacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'DailyMed/FDA — approved Indomethacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2'
  ),
  -- MODERATE: Metadona + Fluconazol
  ('fluconazol', 'metadona', 'moderate',
   'Inibidor de CYP3A4 + opioide: níveis de metadona aumentados. Risco de sedação e depressão respiratória.',
   'CYP3A4 inhibitor + opioid: methadone levels increased. Risk of sedation and respiratory depression.',
   'O fluconazol inibe o CYP3A4, reduzindo o metabolismo da metadona. Os níveis podem aumentar 1,5-2x. Efeito mais pronunciado em metabolizadores lentos de CYP2D6.',
   'Fluconazole inhibits CYP3A4, reducing methadone metabolism. Levels may increase 1.5-2-fold. More pronounced effect in CYP2D6 poor metabolizers.',
   'Monitorizar sinais de sedação e depressão respiratória. Considerar reduzir dose de metadona 25-50% se tratamento prolongado.',
   'Monitor for signs of sedation and respiratory depression. Consider reducing methadone dose by 25-50% if prolonged treatment.',
   'Sedação, frequência respiratória, sinais de depressão respiratória.',
   'Sedation, respiratory rate, signs of respiratory depression.',
   'Depressão respiratória, sedação excessiva.',
   'Respiratory depression, excessive sedation.',
   'DailyMed/FDA — rótulo aprovado Metadona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'DailyMed/FDA — approved Methadone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138'
  ),
  -- MODERATE: Ketorolaco + Metotrexato
  ('metotrexato', 'ketorolaco', 'moderate',
   'AINE injectável + antimetabolito: clearance renal do metotrexato reduzido. Risco de toxicidade.',
   'Injectable NSAID + antimetabolite: methotrexate renal clearance reduced. Risk of toxicity.',
   'O ketorolaco reduz o fluxo sanguíneo renal e a secreção tubular do metotrexato, aumentando os níveis séricos e prolongando a meia-vida.',
   'Ketorolac reduces renal blood flow and tubular secretion of methotrexate, increasing serum levels and prolonging half-life.',
   'Evitar combinação durante tratamento com doses altas de metotrexato. Se necessário, monitorizar hemograma e níveis de metotrexato.',
   'Avoid combination during high-dose methotrexate treatment. If necessary, monitor blood count and methotrexate levels.',
   'Hemograma, níveis de metotrexato.',
   'Blood count, methotrexate levels.',
   'Pancitopenia, mucosite.',
   'Pancytopenia, mucositis.',
   'DailyMed/FDA — rótulo aprovado Ketorolaco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'DailyMed/FDA — approved Ketorolac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6'
  ),
  -- MODERATE: Meloxicam + Warfarina
  ('warfarina', 'meloxicam', 'moderate',
   'AINE selectivo COX-2 + anticoagulante: risco aumentado de hemorragia, mas inferior a AINE não selectivos.',
   'COX-2 selective NSAID + anticoagulant: increased bleeding risk, but lower than non-selective NSAIDs.',
   'O meloxicam tem preferência por COX-2, com menor efeito sobre a agregação plaquetária. No entanto, o risco de hemorragia GI permanece significativo com uso concomitante.',
   'Meloxicam has COX-2 preference with less effect on platelet aggregation. However, GI bleeding risk remains significant with concomitant use.',
   'Monitorizar INR durante as primeiras semanas. Considerar dose baixa de meloxicam (7,5 mg/dia).',
   'Monitor INR during the first weeks. Consider low-dose meloxicam (7.5 mg/day).',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia significativa.',
   'Significant bleeding.',
   'DailyMed/FDA — rótulo aprovado Meloxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727',
   'DailyMed/FDA — approved Meloxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727'
  ),
  -- MODERATE: Indometacina + Vancomicina
  ('vancomicina', 'indometacina', 'moderate',
   'AINE + glicopeptídeo: nefrotoxicidade aditiva. Ambos são potencialmente nefrotóxicos.',
   'NSAID + glycopeptide: additive nephrotoxicity. Both are potentially nephrotoxic.',
   'A indometacina reduz o fluxo sanguíneo renal, enquanto a vancomicina é directamente nefrotóxica. A combinação aumenta o risco de insuficiência renal aguda.',
   'Indomethacin reduces renal blood flow while vancomycin is directly nephrotoxic. The combination increases the risk of acute renal failure.',
   'Monitorizar função renal (creatinina, TFG) antes e durante o tratamento. Manter hidratação adequada.',
   'Monitor renal function (creatinine, GFR) before and during treatment. Maintain adequate hydration.',
   'Creatinina, TFG, volume urinário.',
   'Creatinine, GFR, urine volume.',
   'Creatinina >2x basal, anúria.',
   'Creatinine >2x baseline, anuria.',
   'DailyMed/FDA — rótulo aprovado Indometacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'DailyMed/FDA — approved Indomethacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2'
  ),
  -- MINOR: Piroxicam + Cimetidina
  ('cimetidina', 'piroxicam', 'minor',
   'Bloqueador H2 + AINE: cimetidina pode reduzir absorção do piroxicam mas efeito clínico mínimo.',
   'H2 blocker + NSAID: cimetidina may reduce piroxicam absorption but minimal clinical effect.',
   'A cimetidina pode reduzir ligeiramente a absorção oral do piroxicam, mas o efeito clínico é mínimo. Ambos são metabolizados por CYP — competição teórica.',
   'Cimetidine may slightly reduce oral absorption of piroxicam, but the clinical effect is minimal. Both are CYP-metabolised — theoretical competition.',
   'Não requer ajuste de dose. Monitorizar eficácia do piroxicam.',
   'No dose adjustment required. Monitor piroxicam efficacy.',
   'Não requer monitorização específica.',
   'No specific monitoring required.',
   '', '',
   'DailyMed/FDA — rótulo aprovado Piroxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'DailyMed/FDA — approved Piroxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3'
  )
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. Interações alimento/bebida (drug_food_interactions)
-- =====================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en,
   mechanism_pt, mechanism_en, advice_pt, advice_en, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en,
  v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('piroxicam', 'alimentos', 'Comida', 'Food',
   'Comida retarda absorção mas não afecta extensão. Pico adiado de 1-2 h.',
   'Food delays absorption but does not affect extent. Peak delayed by 1-2 h.',
   'Pode ser tomado com comida para reduzir desconforto GI.',
   'May be taken with food to reduce GI discomfort.'
  ),
  ('indometacina', 'alimentos', 'Comida', 'Food',
   'Comida retarda absorção (cápsulas: pico de 1-2 h para 2-4 h). Suspenção oral: absorção mais rápida.',
   'Food delays absorption (capsules: peak from 1-2 h to 2-4 h). Oral suspension: faster absorption.',
   'Tomar com comida para reduzir desconforto GI. Preferir suspensão oral se disponível.',
   'Take with food to reduce GI discomfort. Prefer oral suspension if available.'
  ),
  ('meloxicam', 'alimentos', 'Comida', 'Food',
   'Comida não afecta significativamente a absorção do meloxicam. Pode ser tomado com ou sem comida.',
   'Food does not significantly affect meloxicam absorption. May be taken with or without food.',
   'Tomar com ou sem comida. Comida pode reduzir desconforto GI.',
   'Take with or without food. Food may reduce GI discomfort.'
  ),
  ('metadona', 'alimentos', 'Comida', 'Food',
   'Comida pode aumentar biodisponibilidade da metadona oral. Efeito modesto.',
   'Food may increase oral methadone bioavailability. Modest effect.',
   'Manter consistência: sempre com ou sempre sem comida. Mudanças podem afectar níveis.',
   'Maintain consistency: always with or always without food. Changes may affect levels.'
  ),
  ('ketorolaco', 'alimentos', 'Comida', 'Food',
   'Comida retarda absorção oral mas não afecta extensão. Forma parenteral não é afectada.',
   'Food delays oral absorption but does not affect extent. Parenteral form is not affected.',
   'Forma oral: tomar com comida. Forma injectável: não aplicável.',
   'Oral form: take with food. Injectable form: not applicable.'
  )
) AS v(slug, entity_slug, entity_pt, entity_en,
       mechanism_pt, mechanism_en, advice_pt, advice_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- 3. Interações doença/condição (drug_disease_interactions)
-- =====================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en,
   interaction_type, severity, reason_pt, reason_en,
   advice_pt, advice_en,
   source_pt, source_en, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en,
  v.interaction_type, v.severity, v.reason_pt, v.reason_en,
  v.advice_pt, v.advice_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('ketorolaco', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Excreção renal significativa. Acumulação em insuficiência renal. Risco de nefrotoxicidade agravada.',
   'Significant renal excretion. Accumulation in renal impairment. Risk of aggravated nephrotoxicity.',
   'TFG 30-50: reduzir dose 50%. TFG <30: evitar. Monitorizar creatinina e eletrólitos.',
   'eGFR 30-50: reduce dose by 50%. eGFR <30: avoid. Monitor creatinine and electrolytes.',
   'DailyMed/FDA — rótulo aprovado Ketorolaco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'DailyMed/FDA — approved Ketorolac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6'
  ),
  ('piroxicam', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Meia-vida longa prolonga exposição em insuficiência renal. Risco de acumulação e toxicidade.',
   'Long half-life prolongs exposure in renal impairment. Risk of accumulation and toxicity.',
   'TFG 30-50: dose reduzida. TFG <30: evitar. Preferir AINE de meia-vida curta.',
   'eGFR 30-50: reduced dose. eGFR <30: avoid. Prefer short half-life NSAID.',
   'DailyMed/FDA — rótulo aprovado Piroxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'DailyMed/FDA — approved Piroxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3'
  ),
  ('meloxicam', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Excreção renal parcial. Acumulação em insuficiência renal moderada-grave.',
   'Partial renal excretion. Accumulation in moderate-severe renal impairment.',
   'TFG 30-50: dose máxima 7,5 mg/dia. TFG <30: evitar.',
   'eGFR 30-50: max dose 7.5 mg/day. eGFR <30: avoid.',
   'DailyMed/FDA — rótulo aprovado Meloxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727',
   'DailyMed/FDA — approved Meloxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727'
  ),
  ('indometacina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Nefrotoxicidade directa. Risco elevado de insuficiência renal aguda, especialmente em idosos.',
   'Direct nephrotoxicity. High risk of acute renal failure, especially in the elderly.',
   'Evitar em insuficiência renal. Se necessário, monitorizar TFG estreitamente.',
   'Avoid in renal impairment. If necessary, monitor GFR closely.',
   'DailyMed/FDA — rótulo aprovado Indometacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'DailyMed/FDA — approved Indomethacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2'
  ),
  ('metadona', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment',
   'precaution', 'critical',
   'Metabolismo hepático extenso. Acumulação significativa em insuficiência hepática. Risco de depressão respiratória prolongada.',
   'Extensive hepatic metabolism. Significant accumulation in hepatic impairment. Risk of prolonged respiratory depression.',
   'Reduzir dose 50-75%. Monitorizar estreitamente. Considerar alternativas não hepáticas.',
   'Reduce dose by 50-75%. Monitor closely. Consider non-hepatic alternatives.',
   'DailyMed/FDA — rótulo aprovado Metadona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'DailyMed/FDA — approved Methadone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138'
  ),
  ('metadona', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Metabolitos renais (normetadona) podem acumular. Efeito clínico moderado — metadona é maioritariamente hepática.',
   'Renal metabolites (normethadone) may accumulate. Moderate clinical effect — methadone is primarily hepatic.',
   'Ajuste de dose raramente necessário. Monitorizar sinais de acumulação.',
   'Dose adjustment rarely needed. Monitor for signs of accumulation.',
   'DailyMed/FDA — rótulo aprovado Metadona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'DailyMed/FDA — approved Methadone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138'
  )
) AS v(slug, condition_slug, condition_pt, condition_en,
       interaction_type, severity, reason_pt, reason_en,
       advice_pt, advice_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 4. Perfis de gravidez/lactação (drug_pregnancy_info)
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
  ('ketorolaco', 'contraindicated',
   'CONTRAINDICADO na gravidez (3º trimestre). Risco de fechamento prematuro do ducto arterioso.',
   'CONTRAINDICATED in pregnancy (3rd trimester). Risk of premature ductus arteriosus closure.',
   '3º trimestre: CONTRAINDICADO. 1º-2º trimestre: evitar.',
   '3rd trimester: CONTRAINDICATED. 1st-2nd trimester: avoid.',
   'Excretado no leite materno em baixas concentrações. Evitar durante aleitamento.',
   'Excreted in breast milk in low concentrations. Avoid during breastfeeding.',
   'Pode afectar a fertilidade. Não usar como contraceptivo.',
   'May affect fertility. Do not use as contraception.',
   'DailyMed/FDA — rótulo aprovado Ketorolaco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6',
   'DailyMed/FDA — approved Ketorolac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0749f61d-12e6-4280-8f41-bd4df81e7ae6'
  ),
  ('piroxicam', 'contraindicated',
   'CONTRAINDICADO no 3º trimestre. Meia-vida longa aumenta exposição fetal.',
   'CONTRAINDICATED in 3rd trimester. Long half-life increases fetal exposure.',
   '3º trimestre: CONTRAINDICADO. 1º-2º trimestre: evitar (preferir paracetamol).',
   '3rd trimester: CONTRAINDICATED. 1st-2nd trimester: avoid (prefer paracetamol).',
   'Excretado no leite materno. Evitar durante aleitamento.',
   'Excreted in breast milk. Avoid during breastfeeding.',
   'Pode inibir a ovulação. Usar contracepção fiável.',
   'May inhibit ovulation. Use reliable contraception.',
   'DailyMed/FDA — rótulo aprovado Piroxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3',
   'DailyMed/FDA — approved Piroxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=923a81d7-78e7-48e9-901d-e3ce3539aba3'
  ),
  ('meloxicam', 'contraindicated',
   'CONTRAINDICADO no 3º trimestre. Risco de fechamento do ducto arterioso.',
   'CONTRAINDICATED in 3rd trimester. Risk of ductus arteriosus closure.',
   '3º trimestre: CONTRAINDICADO. 1º-2º trimestre: evitar.',
   '3rd trimester: CONTRAINDICATED. 1st-2nd trimester: avoid.',
   'Dados limitados. Evitar durante aleitamento.',
   'Limited data. Avoid during breastfeeding.',
   'Pode afectar a fertilidade. Usar contracepção fiável.',
   'May affect fertility. Use reliable contraception.',
   'DailyMed/FDA — rótulo aprovado Meloxicam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727',
   'DailyMed/FDA — approved Meloxicam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58dbce26-b2ac-2ce4-e063-6294a90a5727'
  ),
  ('metadona', 'caution',
   'Usado na gravidez para substituição de opioides (MMT). Benefício justifica o risco. Neonatos podem apresentar síndrome de abstinência neonatal.',
   'Used in pregnancy for opioid substitution (MMT). Benefit outweighs risk. Neonates may present with neonatal abstinence syndrome.',
   'Todos os trimestres: usar apenas em MMT com monitorização obstétrica estreita.',
   'All trimesters: use only in MMT with close obstetric monitoring.',
   'Excretada no leite materno. Compatível com aleitamento em doses estáveis. Monitorizar lactente para sedação.',
   'Excreted in breast milk. Compatible with breastfeeding at stable doses. Monitor infant for sedation.',
   'Contracepção fiável é recomendada durante substituição de opioides.',
   'Reliable contraception is recommended during opioid substitution.',
   'DailyMed/FDA — rótulo aprovado Metadona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138',
   'DailyMed/FDA — approved Methadone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=092d78eb-6423-495c-bf0d-e6532bea7138'
  ),
  ('indometacina', 'contraindicated',
   'CONTRAINDICADO no 3º trimestre (fechamento do ducto arterioso). Usado intencionalmente para fechar ducto em prematuros.',
   'CONTRAINDICATED in 3rd trimester (ductus arteriosus closure). Used intentionally to close ductus in premature infants.',
   '3º trimestre: CONTRAINDICADO (excepto para fechamento terapêutico do ducto). 1º-2º trimestre: evitar.',
   '3rd trimester: CONTRAINDICATED (except therapeutic duct closure). 1st-2nd trimester: avoid.',
   'Excretado no leite materno. Evitar durante aleitamento.',
   'Excreted in breast milk. Avoid during breastfeeding.',
   'Pode afectar a fertilidade feminina e masculina.',
   'May affect female and male fertility.',
   'DailyMed/FDA — rótulo aprovado Indometacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2',
   'DailyMed/FDA — approved Indomethacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d2997707-1541-4f5d-8c8d-70b0a13be8b2'
  ),
  ('naloxona', 'compatible',
   'Antagonista opioide — sem efeito teratogénico conhecido. Usado em emergência na gravidez.',
   'Opioid antagonist — no known teratogenic effect. Used in emergency during pregnancy.',
   'Todos os trimestres: seguro (usado em emergência).',
   'All trimesters: safe (used in emergency).',
   'Excretada no leite materno em baixas concentrações. Segura durante aleitamento.',
   'Excreted in breast milk in low concentrations. Safe during breastfeeding.',
   'Sem efeitos conhecidos sobre a fertilidade.',
   'No known effects on fertility.',
   'DailyMed/FDA — rótulo aprovado Naloxona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b5463553-b775-47a3-8d10-31e01ca1ec72',
   'DailyMed/FDA — approved Naloxone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b5463553-b775-47a3-8d10-31e01ca1ec72'
  )
) AS v(slug, pregnancy_category, risk_pt, risk_en,
       trimester_pt, trimester_en, lactation_pt, lactation_en,
       contraception_pt, contraception_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
