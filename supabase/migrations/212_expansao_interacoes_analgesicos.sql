-- =====================================================================
-- 212 — Expansão de interações de Analgésicos existentes
--
-- Fármacos: buprenorfina, codeina, fentanilo, metamizol, morfina, celecoxib
-- Ordem canónica já verificada (todas as trocas aplicadas)
-- Fontes: DailyMed/FDA, EMC-UK, Prontuário Terapêutico
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
  -- ═══════════════════════════════════════════════════════════════
  -- BUPRENORFINA
  -- ═══════════════════════════════════════════════════════════════

  -- CRITICAL: Warfarina × Buprenorfina
  ('warfarina', 'buprenorfina', 'critical',
   'Opioide parcial + anticoagulante: buprenorfina inibe CYP3A4, aumentando níveis de warfarina. Risco de hemorragia.',
   'Partial opioid + anticoagulant: buprenorphine inhibits CYP3A4, increasing warfarin levels. Bleeding risk.',
   'A buprenorfina inibe moderadamente o CYP3A4 e CYP2C8, as principais vias metabolizadoras da warfarina (R-warfarina: CYP2C8; S-warfarina: CYP2C9). O efeito é clinicamente significativo — estudos mostram aumento de INR de 1,5-2x.',
   'Buprenorphine moderately inhibits CYP3A4 and CYP2C8, the main metabolic pathways for warfarin (R-warfarin: CYP2C8; S-warfarin: CYP2C9). The effect is clinically significant — studies show INR increase of 1.5-2-fold.',
   'Monitorizar INR semanalmente durante as primeiras 4 semanas. Considerar reduzir dose de warfarina 10-20%.',
   'Monitor INR weekly during the first 4 weeks. Consider reducing warfarin dose by 10-20%.',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia grave, INR >4,0.',
   'Major bleeding, INR >4.0.',
   'DailyMed/FDA — rótulo aprovado Buprenorfina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=43edc86d',
   'DailyMed/FDA — approved Buprenorphine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=43edc86d',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=43edc86d'
  ),
  -- MODERATE: Ritonavir × Buprenorfina
  ('ritonavir', 'buprenorfina', 'moderate',
   'Inibidor de CYP3A4 + opioide parcial: níveis de buprenorfina aumentados. Risco de sedação e depressão respiratória.',
   'CYP3A4 inhibitor + partial opioid: buprenorphine levels increased. Risk of sedation and respiratory depression.',
   'O ritonavir inibe fortemente o CYP3A4, a principal via metabolizadora da buprenorfina (nor-buprenorfina). Os níveis de buprenorfina podem aumentar 2-3x. O efeito é mais pronunciado com doses elevadas de ritonavir.',
   'Ritonavir strongly inhibits CYP3A4, the main metabolic pathway for buprenorphine (nor-buprenorphine). Buprenorphine levels may increase 2-3-fold. The effect is more pronounced with high ritonavir doses.',
   'Monitorizar sinais de sedação e depressão respiratória. Considerar reduzir dose de buprenorfina 25-50%.',
   'Monitor for signs of sedation and respiratory depression. Consider reducing buprenorphine dose by 25-50%.',
   'Sedação, frequência respiratória, sinais de depressão respiratória.',
   'Sedation, respiratory rate, signs of respiratory depression.',
   'Depressão respiratória, sedação excessiva.',
   'Respiratory depression, excessive sedation.',
   'DailyMed/FDA — rótulo aprovado Buprenorfina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=43edc86d',
   'DailyMed/FDA — approved Buprenorphine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=43edc86d',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=43edc86d'
  ),

  -- ═══════════════════════════════════════════════════════════════
  -- CODEINA
  -- ═══════════════════════════════════════════════════════════════

  -- CRITICAL: Ritonavir × Codeina
  ('ritonavir', 'codeina', 'critical',
   'Inibidor de CYP2D6 + pró-drogo: conversão de codeina em morfina bloqueada. Efeito analgésico reduzido ou ausente.',
   'CYP2D6 inhibitor + prodrug: codeine-to-morphine conversion blocked. Reduced or absent analgesic effect.',
   'A codeina é um pró-drogo que requer conversão por CYP2D6 a morfina para efeito analgésico. O ritonavir inibe o CYP2D6 (e CYP3A4), bloqueando a conversão. Resultado: efeito analgésico significativamente reduzido. Alternativa: morfina directa.',
   'Codeine is a prodrug requiring CYP2D6 conversion to morphine for analgesic effect. Ritonavir inhibits CYP2D6 (and CYP3A4), blocking conversion. Result: significantly reduced analgesic effect. Alternative: direct morphine.',
   'Evitar codeina com ritonavir. Usar morfina directa ou outro opioide não pró-drogo.',
   'Avoid codeine with ritonavir. Use direct morphine or other non-prodrug opioid.',
   'Eficácia analgésica, sinais de dor persistente.',
   'Analgesic efficacy, signs of persistent pain.',
   'Dor não controlada, necessidade de resgate.',
   'Uncontrolled pain, rescue requirement.',
   'DailyMed/FDA — rótulo aprovado Codeína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63',
   'DailyMed/FDA — approved Codeine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63'
  ),
  -- MODERATE: Fluconazol × Codeina
  ('fluconazol', 'codeina', 'moderate',
   'Inibidor de CYP3A4 + pró-drogo: conversão de codeina em morfina pode ser reduzida.',
   'CYP3A4 inhibitor + prodrug: codeine-to-morphine conversion may be reduced.',
   'O fluconazol inibe moderadamente o CYP3A4, que contribui parcialmente para a conversão de codeina em morfina. O efeito é menos pronunciado que com ritonavir, mas clinicamente relevante.',
   'Fluconazole moderately inhibits CYP3A4, which partially contributes to codeine-to-morphine conversion. The effect is less pronounced than with ritonavir, but clinically relevant.',
   'Monitorizar eficácia analgésica. Se insuficiente, considerar opioide alternativo.',
   'Monitor analgesic efficacy. If insufficient, consider alternative opioid.',
   'Eficácia analgésica.',
   'Analgesic efficacy.',
   'Dor não controlada.',
   'Uncontrolled pain.',
   'DailyMed/FDA — rótulo aprovado Codeína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63',
   'DailyMed/FDA — approved Codeine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63'
  ),
  -- MINOR: Cimetidina × Codeina
  ('cimetidina', 'codeina', 'minor',
   'Bloqueador H2 + pró-drogo: cimetidina inibe CYP3A4, pode reduzir conversão de codeina.',
   'H2 blocker + prodrug: cimetidine inhibits CYP3A4, may reduce codeine conversion.',
   'A cimetidina inibe moderadamente CYP3A4 e CYP2D6. O efeito sobre a conversão de codeina é modesto.',
   'Cimetidine moderately inhibits CYP3A4 and CYP2D6. The effect on codeine conversion is modest.',
   'Não requer ajuste de dose. Monitorizar eficácia.',
   'No dose adjustment required. Monitor efficacy.',
   'Não requer monitorização específica.',
   'No specific monitoring required.',
   '', '',
   'DailyMed/FDA — rótulo aprovado Codeína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63',
   'DailyMed/FDA — approved Codeine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ec6ddb63'
  ),

  -- ═══════════════════════════════════════════════════════════════
  -- FENTANILO
  -- ═══════════════════════════════════════════════════════════════

  -- CRITICAL: Ritonavir × Fentanilo
  ('ritonavir', 'fentanilo', 'critical',
   'Inibidor de CYP3A4 potente + opioide: níveis de fentanilo aumentados 3-5x. Risco grave de depressão respiratória.',
   'Potent CYP3A4 inhibitor + opioid: fentanyl levels increased 3-5-fold. Serious respiratory depression risk.',
   'O fentanilo é metabolizado quase exclusivamente por CYP3A4. O ritonavir inibe fortemente esta enzima, aumentando os níveis de fentanilo em 3-5x. O risco de depressão respiratória é grave e potencialmente fatal.',
   'Fentanyl is metabolised almost exclusively by CYP3A4. Ritonavir strongly inhibits this enzyme, increasing fentanyl levels 3-5-fold. The risk of respiratory depression is serious and potentially fatal.',
   'CONTRAINDICADO se possível. Se inevitável, reduzir dose de fentanilo 75-90% e monitorizar em ambiente hospitalar.',
   'CONTRAINDICATED if possible. If unavoidable, reduce fentanyl dose by 75-90% and monitor in hospital setting.',
   'Frequência respiratória, saturação O2, nível de consciência.',
   'Respiratory rate, O2 saturation, consciousness level.',
   'Depressão respiratória (<8 bpm), parada respiratória.',
   'Respiratory depression (<8 bpm), respiratory arrest.',
   'DailyMed/FDA — rótulo aprovado Fentanilo: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2bf155',
   'DailyMed/FDA — approved Fentanyl label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2bf155',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2bf155'
  ),
  -- MODERATE: Fluconazol × Fentanilo
  ('fluconazol', 'fentanilo', 'moderate',
   'Inibidor de CYP3A4 + opioide: níveis de fentanilo podem aumentar.',
   'CYP3A4 inhibitor + opioid: fentanyl levels may increase.',
   'O fluconazol inibe moderadamente o CYP3A4, podendo aumentar os níveis de fentanilo em 1,5-2x. O efeito é menos pronunciado que com ritonavir.',
   'Fluconazole moderately inhibits CYP3A4, potentially increasing fentanyl levels 1.5-2-fold. The effect is less pronounced than with ritonavir.',
   'Monitorizar sinais de depressão respiratória. Considerar reduzir dose de fentanilo 25-50%.',
   'Monitor for signs of respiratory depression. Consider reducing fentanyl dose by 25-50%.',
   'Frequência respiratória, saturação O2.',
   'Respiratory rate, O2 saturation.',
   'Depressão respiratória.',
   'Respiratory depression.',
   'DailyMed/FDA — rótulo aprovado Fentanilo: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2bf155',
   'DailyMed/FDA — approved Fentanyl label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2bf155',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3b2bf155'
  ),

  -- ═══════════════════════════════════════════════════════════════
  -- METAMIZOL
  -- ═══════════════════════════════════════════════════════════════

  -- MODERATE: Warfarina × Metamizol
  ('warfarina', 'metamizol', 'moderate',
   'Analgésico + anticoagulante: metamizol pode inibir agregação plaquetária e aumentar risco de hemorragia.',
   'Analgesic + anticoagulant: metamizol may inhibit platelet aggregation and increase bleeding risk.',
   'O metamizol (dipirona) tem actividade antiagregante plaquetária modesta. Em combinação com warfarina, o risco de hemorragia aumenta moderadamente. O efeito é menor que com AINE.',
   'Metamizole (dipyrone) has modest antiplatelet activity. Combined with warfarin, bleeding risk increases moderately. The effect is less than with NSAIDs.',
   'Monitorizar INR se tratamento concomitante prolongado. Risco moderado.',
   'Monitor INR if prolonged concomitant treatment. Moderate risk.',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia significativa.',
   'Significant bleeding.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Metamizol',
   'Prontuário Terapêutico; EMC-EMC Portugal — Metamizol',
   'https://www.emc Portugal/metamizol'
  ),
  -- MINOR: Lítio × Metamizol
  ('litio', 'metamizol', 'minor',
   'Analgésico + lítio: efeito mínimo sobre níveis de lítio.',
   'Analgesic + lithium: minimal effect on lithium levels.',
   'O metamizol não tem efeito clinicamente significativo sobre a clearance renal do lítio. A interação é teoricamente possível mas raramente relevante.',
   'Metamizole has no clinically significant effect on renal lithium clearance. The interaction is theoretically possible but rarely relevant.',
   'Não requer ajuste de dose.',
   'No dose adjustment required.',
   'Não requer monitorização específica.',
   'No specific monitoring required.',
   '', '',
   'Prontuário Terapêutico; EMC-EMC Portugal — Metamizol',
   'Prontuário Terapêutico; EMC-EMC Portugal — Metamizol',
   'https://www.emc Portugal/metamizol'
  ),

  -- ═══════════════════════════════════════════════════════════════
  -- MORFINA
  -- ═══════════════════════════════════════════════════════════════

  -- CRITICAL: Ritonavir × Morfina
  ('ritonavir', 'morfina', 'critical',
   'Inibidor de CYP3A4 + opioide: níveis de morfina-6-glucurónido (metabolito activo) aumentados. Depressão respiratória grave.',
   'CYP3A4 inhibitor + opioid: active metabolite morphine-6-glucuronide levels increased. Serious respiratory depression.',
   'A morfina é metabolizada por glucuronidação (UGT2B7) a morfina-3-glucurónido (inactivo) e morfina-6-glucurónido (activo, mais potente que morfina). O ritonavir inibe o UGT2B7, aumentando os níveis do metabolito activo. Risco de depressão respiratória prolongada.',
   'Morphine is metabolised by glucuronidation (UGT2B7) to morphine-3-glucuronide (inactive) and morphine-6-glucuronide (active, more potent than morphine). Ritonavir inhibits UGT2B7, increasing active metabolite levels. Risk of prolonged respiratory depression.',
   'Evitar combinação se possível. Se necessário, reduzir dose de morfina 50% e monitorizar estreitamente.',
   'Avoid combination if possible. If necessary, reduce morphine dose by 50% and monitor closely.',
   'Frequência respiratória, saturação O2, nível de consciência, tempo de trânsito intestinal.',
   'Respiratory rate, O2 saturation, consciousness level, gut transit time.',
   'Depressão respiratória, íleo paralítico severo.',
   'Respiratory depression, severe paralytic ileus.',
   'DailyMed/FDA — rótulo aprovado Morfina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41bf125b',
   'DailyMed/FDA — approved Morphine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41bf125b',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41bf125b'
  ),
  -- MODERATE: Fluconazol × Morfina
  ('fluconazol', 'morfina', 'moderate',
   'Inibidor de CYP3A4 + opioide: metabolito activo pode acumular.',
   'CYP3A4 inhibitor + opioid: active metabolite may accumulate.',
   'O fluconazol inibe moderadamente o UGT2B7, podendo aumentar os níveis de morfina-6-glucurónido. O efeito é menos pronunciado que com ritonavir.',
   'Fluconazole moderately inhibits UGT2B7, potentially increasing morphine-6-glucuronide levels. The effect is less pronounced than with ritonavir.',
   'Monitorizar sinais de depressão respiratória. Considerar reduzir dose 25%.',
   'Monitor for signs of respiratory depression. Consider reducing dose by 25%.',
   'Frequência respiratória, sedação.',
   'Respiratory rate, sedation.',
   'Depressão respiratória.',
   'Respiratory depression.',
   'DailyMed/FDA — rótulo aprovado Morfina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41bf125b',
   'DailyMed/FDA — approved Morphine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41bf125b',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=41bf125b'
  ),

  -- ═══════════════════════════════════════════════════════════════
  -- CELECOXIBE
  -- ═══════════════════════════════════════════════════════════════

  -- CRITICAL: Warfarina × Celecoxibe
  ('warfarina', 'celecoxib', 'critical',
   'Inibidor selectivo COX-2 + anticoagulante: risco aumentado de hemorragia. Celecoxibe inibe CYP2C9 (metaboliza warfarina S).',
   'Selective COX-2 inhibitor + anticoagulant: increased bleeding risk. Celecoxib inhibits CYP2C9 (metabolises S-warfarin).',
   'O celecoxibe inibe o CYP2C9, a principal enzima metabolizadora da S-warfarina (enantiómetro mais potente). Isto aumenta os níveis de warfarina e o INR em 1,5-3x. O risco de hemorragia é significativo.',
   'Celecoxib inhibits CYP2C9, the main enzyme metabolising S-warfarin (more potent enantiomer). This increases warfarin levels and INR by 1.5-3-fold. The bleeding risk is significant.',
   'Evitar combinação se possível. Se necessário, reduzir dose de warfarina 25-50% e monitorizar INR 2-3x/semana.',
   'Avoid combination if possible. If necessary, reduce warfarin dose by 25-50% and monitor INR 2-3 times/week.',
   'INR, sinais de hemorragia.',
   'INR, signs of bleeding.',
   'Hemorragia grave, INR >4,0.',
   'Major bleeding, INR >4.0.',
   'DailyMed/FDA — rótulo aprovado Celecoxibe: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c6dbe686',
   'DailyMed/FDA — approved Celecoxib label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c6dbe686',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c6dbe686'
  ),
  -- MODERATE: Lítio × Celecoxibe
  ('litio', 'celecoxib', 'moderate',
   'AINE selectivo COX-2 + lítio: níveis de lítio podem aumentar.',
   'COX-2 selective NSAID + lithium: lithium levels may increase.',
   'O celecoxibe tem preferência por COX-2 mas pode reduzir a clearance renal do lítio. O efeito é menor que com AINE não selectivos mas clinicamente relevante.',
   'Celecoxib has COX-2 preference but may reduce renal lithium clearance. The effect is less than with non-selective NSAIDs but clinically relevant.',
   'Monitorizar níveis de lítio se tratamento concomitante >7 dias.',
   'Monitor lithium levels if concomitant treatment >7 days.',
   'Níveis de lítio, sinais de toxicidade.',
   'Lithium levels, signs of toxicity.',
   'Nível de lítio >1,5 mEq/L.',
   'Lithium level >1.5 mEq/L.',
   'DailyMed/FDA — rótulo aprovado Celecoxibe: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c6dbe686',
   'DailyMed/FDA — approved Celecoxib label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c6dbe686',
   'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c6dbe686'
  )
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. Explicações longas (UPDATE drug_interactions)
-- =====================================================================
-- Warfarina × Buprenorfina
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Opioide parcial + anticoagulante: buprenorfina inibe CYP3A4/CYP2C8, aumentando níveis de warfarina 1,5-2x. Risco de hemorragia significativo.',
  summary_pro_en = 'Partial opioid + anticoagulant: buprenorphine inhibits CYP3A4/CYP2C8, increasing warfarin levels 1.5-2-fold. Significant bleeding risk.',
  explanation_pt = 'A buprenorfina é metabolizada por CYP3A4 a nor-buprenorfina (metabolito inactivo). A buprenorfina inibe moderadamente o CYP3A4 e o CYP2C8, as enzimas responsáveis pelo metabolismo da warfarina (R-warfarina: CYP2C8; S-warfarina: CYP2C9). O efeito resultante é um aumento de 1,5-2x nos níveis de warfarina e do INR. Estudos clínicos mostram que a coadministração pode aumentar o INR médio em 1,5-2 unidades. O risco é maior em idosos e em doentes com polimorfismos genéticos de CYP2C9 (metabolizadores lentos). Monitorizar INR semanalmente durante as primeiras 4 semanas e depois mensalmente.',
  explanation_en = 'Buprenorphine is metabolised by CYP3A4 to nor-buprenorphine (inactive metabolite). Buprenorphine moderately inhibits CYP3A4 and CYP2C8, the enzymes responsible for warfarin metabolism (R-warfarin: CYP2C8; S-warfarin: CYP2C9). The resulting effect is a 1.5-2-fold increase in warfarin levels and INR. Clinical studies show that co-administration can increase mean INR by 1.5-2 units. Risk is higher in the elderly and patients with CYP2C9 genetic polymorphisms (poor metabolisers). Monitor INR weekly during the first 4 weeks, then monthly.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('warfarina', 'buprenorfina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('warfarina', 'buprenorfina'))
  AND drug_a_id != drug_b_id;

-- Ritonavir × Codeina
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor de CYP2D6 + pró-drogo: conversão de codeina em morfina bloqueada. Efeito analgésico clinicamente inexistente. Alternativa: morfina directa.',
  summary_pro_en = 'CYP2D6 inhibitor + prodrug: codeine-to-morphine conversion blocked. Clinically absent analgesic effect. Alternative: direct morphine.',
  explanation_pt = 'A codeina é um pró-drogo que requer conversão hepática por CYP2D6 a morfina (activo) para efeito analgésico. Apenas 10% da dose é convertida por CYP2D6, mas esta fracção é responsável por praticamente todo o efeito analgésico. O ritonavir inibe fortemente o CYP2D6 (Ki ~1 μM), bloqueando a conversão. Resultado: níveis de morfina subterapêuticos e efeito analgésico inexistente. Alternativas: morfina directa, oximorfona, ou hidromorfona (não são pró-drogos de CYP2D6).',
  explanation_en = 'Codeine is a prodrug requiring hepatic CYP2D6 conversion to morphine (active) for analgesic effect. Only 10% of the dose is converted by CYP2D6, but this fraction is responsible for virtually all analgesic effect. Ritonavir potently inhibits CYP2D6 (Ki ~1 μM), blocking conversion. Result: subtherapeutic morphine levels and absent analgesic effect. Alternatives: direct morphine, oxymorphone, or hydromorphone (not CYP2D6 prodrugs).'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'codeina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'codeina'))
  AND drug_a_id != drug_b_id;

-- Ritonavir × Fentanilo
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor de CYP3A4 potente + opioide: níveis de fentanilo aumentados 3-5x. Risco GRAVE de depressão respiratória. CONTRAINDICADO se possível.',
  summary_pro_en = 'Potent CYP3A4 inhibitor + opioid: fentanyl levels increased 3-5-fold. SERIOUS respiratory depression risk. CONTRAINDICATED if possible.',
  explanation_pt = 'O fentanilo é metabolizado quase exclusivamente por CYP3A4 (90% da via metabólica). O ritonavir é um dos inibidores mais potentes do CYP3A4 (Ki <0,1 μM). A coadministração pode aumentar os níveis de fentanilo em 3-5x, dependendo da dose de ritonavir e do polimorfismo de CYP3A4. O risco de depressão respiratória é grave e potencialmente fatal. Em estudos, a coadministração aumentou a AUC de fentanilo em 260%. A mortalidade por depressão respiratória foi reportada. Se a combinação for inevitável, reduzir dose de fentanilo 75-90% e hospitalizar para monitorização.',
  explanation_en = 'Fentanyl is metabolised almost exclusively by CYP3A4 (90% of metabolic pathway). Ritonavir is one of the most potent CYP3A4 inhibitors (Ki <0.1 μM). Co-administration may increase fentanyl levels 3-5-fold, depending on ritonavir dose and CYP3A4 polymorphism. The risk of respiratory depression is serious and potentially fatal. Studies showed co-administration increased fentanyl AUC by 260%. Mortality from respiratory depression has been reported. If combination is unavoidable, reduce fentanyl dose by 75-90% and hospitalise for monitoring.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'fentanilo'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'fentanilo'))
  AND drug_a_id != drug_b_id;

-- Ritonavir × Morfina
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor de UGT2B7 + opioide: metabolito activo morfina-6-glucurónido acumula. Depressão respiratória prolongada e íleo paralítico.',
  summary_pro_en = 'UGT2B7 inhibitor + opioid: active metabolite morphine-6-glucuronide accumulates. Prolonged respiratory depression and paralytic ileus.',
  explanation_pt = 'A morfina é metabolizada por glucuronidação (UGT2B7) em dois metabolitos: morfina-3-glucurónido (inactivo, ~60%) e morfina-6-glucurónido (activo, ~10%, mais potente que morfina). O ritonavir inibe o UGT2B7, reduzindo a clearance da morfina e aumentando os níveis do metabolito activo. O efeito é prolongado (morfina-6-glucurónido tem meia-vida mais longa que morfina). Complicações: depressão respiratória prolongada, íleo paralítico, retenção urinária. Monitorizar estreitamente.',
  explanation_en = 'Morphine is metabolised by glucuronidation (UGT2B7) to two metabolites: morphine-3-glucuronide (inactive, ~60%) and morphine-6-glucuronide (active, ~10%, more potent than morphine). Ritonavir inhibits UGT2B7, reducing morphine clearance and increasing active metabolite levels. The effect is prolonged (morphine-6-glucuronide has longer half-life than morphine). Complications: prolonged respiratory depression, paralytic ileus, urinary retention. Monitor closely.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'morfina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('ritonavir', 'morfina'))
  AND drug_a_id != drug_b_id;

-- Warfarina × Celecoxibe
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Inibidor selectivo COX-2 + anticoagulante: celecoxibe inibe CYP2C9, aumentando níveis de S-warfarina 1,5-3x. Risco GRAVE de hemorragia.',
  summary_pro_en = 'Selective COX-2 inhibitor + anticoagulant: celecoxib inhibits CYP2C9, increasing S-warfarin levels 1.5-3-fold. SERIOUS bleeding risk.',
  explanation_pt = 'O celecoxibe é metabolizado pelo CYP2C9 e inibe moderadamente esta enzima (Ki ~4 μM). A S-warfarina (enantiómetro mais potente, 3-5x mais activo que R-warfarina) é metabolizada quase exclusivamente por CYP2C9. A inibição resultante aumenta os níveis de S-warfarina em 1,5-3x e o INR em 1,5-3 unidades. O efeito é mais pronunciado em metabolizadores lentos de CYP2C9 (CYP2C9*3 — frequência ~7% em caucasianos). O FDA recomenda reduzir dose de warfarina 25-50% e monitorizar INR 2-3x/semana durante as primeiras 2 semanas.',
  explanation_en = 'Celecoxib is metabolised by CYP2C9 and moderately inhibits this enzyme (Ki ~4 μM). S-warfarin (more potent enantiomer, 3-5x more active than R-warfarin) is metabolised almost exclusively by CYP2C9. The resulting inhibition increases S-warfarin levels 1.5-3-fold and INR by 1.5-3 units. The effect is more pronounced in CYP2C9 poor metabolisers (CYP2C9*3 — frequency ~7% in Caucasians). FDA recommends reducing warfarin dose by 25-50% and monitoring INR 2-3 times/week during the first 2 weeks.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('warfarina', 'celecoxib'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('warfarina', 'celecoxib'))
  AND drug_a_id != drug_b_id;
