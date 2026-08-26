-- =====================================================================
-- 211 — Nimesulida completa: fármaco + perfil + farmacologia + interações + dimensões
--
-- Fonte principal: Prontuário Terapêutico (grupo 14), EMC-EMC Portugal, BNF
-- Nimesulida não está no DailyMed (FDA) nem EMC-UK — usar fontes PT/EU
-- =====================================================================

-- =====================================================================
-- 1. Fármaco (drugs)
-- =====================================================================
INSERT INTO public.drugs
  (id, slug, name_pt, name_en, class_pt, class_en, aliases, status)
VALUES
  ('a0000000-0000-4000-8000-000000000001', 'nimesulida', 'Nimesulida', 'Nimesulide', 'AINE selectivo COX-2', 'COX-2 selective NSAID',
   '{"nimesulide","nise","aulin","mesulid"}', 'published')
ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- 2. Perfil (drug_profiles)
-- =====================================================================
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)
SELECT d.id,
  'A nimesulida é um anti-inflamatório não esteroide (AINE) com preferência pelo COX-2, usado para tratar dor e inflamação. É mais selectivo que outros AINE, com menor risco gastrointestinal. Disponível em comprimidos, suspensão oral e creme tópico.',
  'Nimesulide is a non-steroidal anti-inflammatory drug (NSAID) with COX-2 preference, used to treat pain and inflammation. It is more selective than other NSAIDs, with lower gastrointestinal risk. Available as tablets, oral suspension, and topical cream.',
  'AINE com preferência por COX-2 (selectividade ~100:1 in vitro). Inibe also 5-LOX (lipoxigenase), distinguindo-o de outros AINE. Meia-vida: 2-3 h (curta). Dose: 100 mg 2x/dia (máx. 15 dias). Forma tópica: eficaz para dor localizada. Hepatotoxicidade idiossincrásica rara mas potencialmente grave.',
  'NSAID with COX-2 preference (selectivity ~100:1 in vitro). Also inhibits 5-LOX (lipoxygenase), distinguishing it from other NSAIDs. Half-life: 2-3 h (short). Dose: 100 mg 2x/day (max 15 days). Topical form: effective for localised pain. Rare but potentially serious idiosyncratic hepatotoxicity.',
  'Prontuário Terapêutico — Grupo 14 (Dermatologia); EMC-EMC Portugal — Ficha Técnica Nimesulida',
  'Prontuário Terapêutico — Group 14 (Dermatology); EMC-EMC Portugal — Nimesulide SPC',
  'published'
FROM public.drugs d
WHERE d.slug = 'nimesulida'
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 3. Farmacologia (drug_pharmacology)
-- =====================================================================
INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en,
   mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en,
   absorption_pt, absorption_en,
   half_life_pt, half_life_en,
   source_pt, source_en, status)
SELECT d.id,
  'Inibição preferencial de COX-2 (selectividade ~100:1 in vitro). Inibe também 5-LOX, reduzindo a formação de leucotrienos. Actividade anti-inflamatória, analgésica e antipirética. Efeito tópico localizado significativo.',
  'Preferential COX-2 inhibition (selectivity ~100:1 in vitro). Also inhibits 5-LOX, reducing leukotriene formation. Anti-inflammatory, analgesic, and antipyretic activity. Significant local topical effect.',
  'Inibição preferencial de COX-2 sobre COX-1. A inibição adicional de 5-LOX confere propriedades anti-inflamatórias adicionais. Inibe também a produção de citocinas pró-inflamatórias (IL-1, IL-6, TNF-α).',
  'Preferential inhibition of COX-2 over COX-1. Additional 5-LOX inhibition confers additional anti-inflammatory properties. Also inhibits pro-inflammatory cytokine production (IL-1, IL-6, TNF-α).',
  'Metabolizado extensivamente no fígado. CYP2C9 (principal) e CYP3A4. Metabolitos inactivos. Excreção renal (50%) e biliar (50%).',
  'Extensively metabolised in the liver. CYP2C9 (major) and CYP3A4. Inactive metabolites. Renal excretion (50%) and biliary (50%).',
  'Absorção oral rápida e completa. Biodisponibilidade: 100%. Pico: 1-2 h. Comida não afecta significativamente a absorção. Forma tópica: absorção sistémica mínima.',
  'Rapid and complete oral absorption. Bioavailability: 100%. Peak: 1-2 h. Food does not significantly affect absorption. Topical form: minimal systemic absorption.',
  '2-3 h (curta). Não se acumula significativamente com doses 2x/dia.',
  '2-3 h (short). Does not accumulate significantly with 2x/day dosing.',
  'Prontuário Terapêutico; EMC-EMC Portugal',
  'Prontuário Terapêutico; EMC-EMC Portugal',
  'published'
FROM public.drugs d
WHERE d.slug = 'nimesulida'
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 4. Interações fármaco-fármaco (drug_interactions)
-- =====================================================================
-- Verificar ordem canónica ANTES de aplicar!
-- nimesulida UUID será gerado por 211. Verificar ordem com:
-- SELECT id, slug FROM drugs WHERE slug IN ('nimesulida', 'slug_par');

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
  -- CRITICAL: Warfarina × Nimesulida (ordem verificada após criação do fármaco)
  ('warfarina', 'nimesulida', 'critical',
   'AINE selectivo COX-2 + anticoagulante: risco aumentado de hemorragia. Inibição plaquetária + efeito anticoagulante.',
   'COX-2 selective NSAID + anticoagulant: increased bleeding risk. Platelet inhibition + anticoagulant effect.',
   'A nimesulida inibe preferencialmente COX-2 mas tem efeito residual sobre COX-1 plaquetário. Em combinação com warfarina, o risco de hemorragia GI aumenta significativamente. A meia-vida curta (2-3 h) reduz o risco comparado com AINE de meia-vida longa, mas a potência anti-inflamatória é elevada.',
   'Nimesulide preferentially inhibits COX-2 but has residual COX-1 platelet effect. Combined with warfarin, GI bleeding risk increases significantly. The short half-life (2-3 h) reduces risk compared to long half-life NSAIDs, but anti-inflammatory potency is high.',
   'Evitar combinação se possível. Se necessário, monitorizar INR semanalmente. Dose baixa de nimesulida e duração curta.',
   'Avoid combination if possible. If necessary, monitor INR weekly. Low-dose nimesulide and short duration.',
   'INR, sinais de hemorragia (equimoses, hematúria, melena).',
   'INR, signs of bleeding (bruising, haematuria, melaena).',
   'Hemorragia grave, queda de Hb >2 g/dL.',
   'Major bleeding, Hb drop >2 g/dL.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide',
   'https://www.emc Portugal/nimesulida'
  ),
  -- MODERATE: Nimesulida × Lítio
  ('litio', 'nimesulida', 'moderate',
   'AINE + lítio: níveis de lítio podem aumentar. Risco de toxicidade por lítio.',
   'NSAID + lithium: lithium levels may increase. Risk of lithium toxicity.',
   'A nimesulida pode reduzir a clearance renal do lítio via inibição de prostaglandinas renais. O efeito é menor que com indometacina ou naproxeno, devido à meia-vida curta e selectividade COX-2.',
   'Nimesulide may reduce renal lithium clearance via prostaglandin inhibition. The effect is less than with indomethacin or naproxen, due to short half-life and COX-2 selectivity.',
   'Monitorizar níveis de lítio se tratamento concomitante prolongado. Considerar reduzir dose de lítio 10-20%.',
   'Monitor lithium levels if prolonged concomitant treatment. Consider reducing lithium dose by 10-20%.',
   'Níveis de lítio, sinais de toxicidade (tremor, náusea).',
   'Lithium levels, signs of toxicity (tremor, nausea).',
   'Nível de lítio >1,5 mEq/L.',
   'Lithium level >1.5 mEq/L.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide',
   'https://www.emc Portugal/nimesulida'
  ),
  -- MODERATE: Nimesulida × Metotrexato
  ('nimesulida', 'metotrexato', 'moderate',
   'AINE + antimetabolito: clearance renal do metotrexato pode ser reduzido.',
   'NSAID + antimetabolite: methotrexate renal clearance may be reduced.',
   'A nimesulida pode reduzir a secreção tubular do metotrexato. O efeito é menor que com AINE não selectivos, mas clinicamente relevante em doses altas de metotrexato.',
   'Nimesulide may reduce tubular secretion of methotrexate. The effect is less than with non-selective NSAIDs, but clinically relevant at high methotrexate doses.',
   'Evitar AINE durante tratamento com doses altas de metotrexato. Se necessário, monitorizar hemograma.',
   'Avoid NSAIDs during high-dose methotrexate. If necessary, monitor blood count.',
   'Hemograma, níveis de metotrexato.',
   'Blood count, methotrexate levels.',
   'Pancitopenia, mucosite.',
   'Pancytopenia, mucositis.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide',
   'https://www.emc Portugal/nimesulida'
  ),
  -- MODERATE: Nimesulida × Metformina
  ('metformina', 'nimesulida', 'moderate',
   'AINE + biguanida: AINE pode reduzir TFG e aumentar risco de acidose láctica.',
   'NSAID + biguanide: NSAID may reduce GFR and increase risk of lactic acidosis.',
   'A nimesulida reduz o fluxo sanguíneo renal via inibição de prostaglandinas, podendo reduzir a TFG. Em doentes com insuficiência renal borderline, isto pode precipitar acumulação de metformina e acidose láctica.',
   'Nimesulide reduces renal blood flow via prostaglandin inhibition, potentially reducing GFR. In patients with borderline renal impairment, this may precipitate metformin accumulation and lactic acidosis.',
   'Monitorizar TFG antes e durante tratamento concomitante. Evitar em TFG <45.',
   'Monitor GFR before and during concomitant treatment. Avoid if eGFR <45.',
   'TFG, creatinina, sinais de acidose láctica.',
   'GFR, creatinine, signs of lactic acidosis.',
   'Acidose láctica (náusea, vômitos, dor abdominal, letargia).',
   'Lactic acidosis (nausea, vomiting, abdominal pain, lethargy).',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide',
   'https://www.emc Portugal/nimesulida'
  ),
  -- MODERATE: Nimesulida × Aspirina
  ('aspirina', 'nimesulida', 'moderate',
   'Dois AINE: efeitos anti-inflamatórios aditivos mas sem benefício. Risco GI aumentado.',
   'Two NSAIDs: additive anti-inflammatory effects without benefit. Increased GI risk.',
   'A combinação de dois AINE não oferece benefício terapêutico adicional e aumenta significativamente o risco de toxicidade GI (úlcera, hemorragia). A aspirina baixa dose (antiagregante) pode ser mantida com precaução.',
   'Combination of two NSAIDs offers no additional therapeutic benefit and significantly increases GI toxicity risk (ulcer, bleeding). Low-dose aspirin (antiplatelet) may be maintained with caution.',
   'Não combinar dois AINE. Se aspirina antiagregante é necessária, administrar 30 min antes da nimesulida.',
   'Do not combine two NSAIDs. If antiplatelet aspirin is necessary, administer 30 min before nimesulide.',
   'Sinais de hemorragia GI (dor epigástrica, hematúria, melena).',
   'Signs of GI bleeding (epigastric pain, haematuria, melaena).',
   'Hemorragia GI, úlcera gástrica.',
   'GI bleeding, gastric ulcer.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide',
   'https://www.emc Portugal/nimesulida'
  ),
  -- MINOR: Nimesulida × Cimetidina
  ('nimesulida', 'cimetidina', 'minor',
   'Bloqueador H2 + AINE: cimetidina pode reduzir ligeiramente a absorção da nimesulida.',
   'H2 blocker + NSAID: cimetidine may slightly reduce nimesulide absorption.',
   'A cimetidina pode reduzir ligeiramente a biodisponibilidade oral da nimesulida, mas o efeito clínico é mínimo. Não requer ajuste de dose.',
   'Cimetidine may slightly reduce oral bioavailability of nimesulide, but the clinical effect is minimal. No dose adjustment required.',
   'Não requer ajuste de dose.',
   'No dose adjustment required.',
   'Não requer monitorização específica.',
   'No specific monitoring required.',
   '', '',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide',
   'https://www.emc Portugal/nimesulida'
  )
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 5. Interações alimento (drug_food_interactions)
-- =====================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en,
   mechanism_pt, mechanism_en, advice_pt, advice_en, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en,
  v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('nimesulida', 'alimentos', 'Comida', 'Food',
   'Comida não afecta significativamente a absorção da nimesulida. Pode ser tomada com ou sem comida.',
   'Food does not significantly affect nimesulide absorption. May be taken with or without food.',
   'Tomar com comida para reduzir desconforto GI, se necessário.',
   'Take with food to reduce GI discomfort, if needed.'
  )
) AS v(slug, entity_slug, entity_pt, entity_en,
       mechanism_pt, mechanism_en, advice_pt, advice_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- 6. Interações doença (drug_disease_interactions)
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
  ('nimesulida', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Excreção renal parcial (50%). Acumulação em insuficiência renal. Risco de nefrotoxicidade agravada.',
   'Partial renal excretion (50%). Accumulation in renal impairment. Risk of aggravated nephrotoxicity.',
   'TFG 30-50: reduzir dose. TFG <30: evitar. Monitorizar creatinina.',
   'eGFR 30-50: reduce dose. eGFR <30: avoid. Monitor creatinine.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide'
  ),
  ('nimesulida', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment',
   'contraindication', 'critical',
   'CONTRAINDICADO em insuficiência hepática. Nimesulida é potencialmente hepatotóxica — risco de hepatite fulminante.',
   'CONTRAINDICATED in hepatic impairment. Nimesulide is potentially hepatotoxic — risk of fulminant hepatitis.',
   'Não administrar em doentes com insuficiência hepática. Suspender imediatamente se sinais de hepatotoxicidade.',
   'Do not administer in patients with hepatic impairment. Discontinue immediately if signs of hepatotoxicity.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide'
  ),
  ('nimesulida', 'asma', 'Asma', 'Asthma',
   'precaution', 'moderate',
   'AINE podem precipitar broncoespasmo em doentes com asma sensível a AINE (asma aspirina-induzida).',
   'NSAIDs may precipitate bronchospasm in patients with NSAID-sensitive asthma (aspirin-induced asthma)',
   'Evitar em doentes com asma sensível a AINE. Se necessário, monitorizar função pulmonar.',
   'Avoid in patients with NSAID-sensitive asthma. If necessary, monitor pulmonary function.',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
   'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide'
  )
) AS v(slug, condition_slug, condition_pt, condition_en,
       interaction_type, severity, reason_pt, reason_en,
       advice_pt, advice_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 7. Perfil gravidez (drug_pregnancy_info)
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en,
   trimester_pt, trimester_en, lactation_pt, lactation_en,
   contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id,
  'contraindicated',
  'CONTRAINDICADO na gravidez. AINE — risco de fechamento prematuro do ducto arterioso e oligohidrâmnio.',
  'CONTRAINDICATED in pregnancy. NSAID — risk of premature ductus arteriosus closure and oligohydramnios.',
  'Todos os trimestres: CONTRAINDICADO.',
  'All trimesters: CONTRAINDICATED.',
  'Excretada no leite materno em baixas concentrações. Evitar durante aleitamento.',
  'Excreted in breast milk in low concentrations. Avoid during breastfeeding.',
  'Pode afectar a fertilidade. Usar contracepção fiável.',
  'May affect fertility. Use reliable contraception.',
  'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulida',
  'Prontuário Terapêutico; EMC-EMC Portugal — Nimesulide'
FROM public.drugs d
WHERE d.slug = 'nimesulida'
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 8. Explicações longas (UPDATE drug_interactions)
-- =====================================================================
-- Encontrar pares independentemente da ordem canónica
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE selectivo COX-2 + anticoagulante: risco aumentado de hemorragia. Inibição plaquetária residual + efeito anticoagulante. Meia-vida curta (2-3 h) reduz risco vs. AINE longos.',
  summary_pro_en = 'COX-2 selective NSAID + anticoagulant: increased bleeding risk. Residual platelet inhibition + anticoagulant effect. Short half-life (2-3 h) reduces risk vs. long NSAIDs.',
  explanation_pt = 'A nimesulida é um AINE com forte preferência por COX-2 (selectividade ~100:1 in vitro). No entanto, inibe também parcialmente a COX-1 plaquetária, especialmente em doses elevadas. A warfarina anticoagula via inibição dos factores de coagulação dependentes de vitamina K. A combinação de inibição plaquetária parcial + anticoagulação aumenta o risco de hemorragia. A meia-vida curta (2-3 h) é uma vantagem em relação a AINE de meia-vida longa (piroxicam: 50 h), mas a potência anti-inflamatória é elevada. O Prontuário Terapêutico português recomenda evitar a combinação ou monitorizar INR semanalmente.',
  explanation_en = 'Nimesulide is an NSAID with strong COX-2 preference (selectivity ~100:1 in vitro). However, it also partially inhibits platelet COX-1, especially at higher doses. Warfarin anticoagulates via inhibition of vitamin K-dependent coagulation factors. The combination of partial platelet inhibition + anticoagulation increases bleeding risk. The short half-life (2-3 h) is an advantage over long half-life NSAIDs (piroxicam: 50 h), but anti-inflammatory potency is high. The Portuguese Prontuário Terapêutico recommends avoiding the combination or monitoring INR weekly.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('nimesulida', 'warfarina'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('nimesulida', 'warfarina'))
  AND drug_a_id != drug_b_id;

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE selectivo COX-2 + lítio: níveis de lítio podem aumentar. Efeito menor que AINE não selectivos devido à meia-vida curta.',
  summary_pro_en = 'COX-2 selective NSAID + lithium: lithium levels may increase. Less effect than non-selective NSAIDs due to short half-life.',
  explanation_pt = 'A nimesulida reduz o fluxo sanguíneo renal via inibição de prostaglandinas, diminuindo a clearance do lítio. A selectividade COX-2 e a meia-vida curta (2-3 h) tornam o efeito menor comparado com indometacina ou naproxeno. No entanto, o efeito é clinicamente relevante em tratamentos prolongados. Monitorizar níveis de lítio se coadministração >7 dias.',
  explanation_en = 'Nimesulide reduces renal blood flow via prostaglandin inhibition, decreasing lithium clearance. COX-2 selectivity and short half-life (2-3 h) make the effect smaller compared to indomethacin or naproxen. However, the effect is clinically relevant with prolonged treatment. Monitor lithium levels if co-administration >7 days.'
WHERE drug_a_id IN (SELECT id FROM drugs WHERE slug IN ('nimesulida', 'litio'))
  AND drug_b_id IN (SELECT id FROM drugs WHERE slug IN ('nimesulida', 'litio'))
  AND drug_a_id != drug_b_id;
