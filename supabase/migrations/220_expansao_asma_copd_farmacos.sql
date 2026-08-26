-- =====================================================================
-- 220 — Expansão Anti-asma/COPD: 3 fármacos novos + perfis + farmacologia
--
-- Fontes: DailyMed/FDA, EMC-UK, Prontuário Terapêutico
-- UUIDs fixos para prever ordem canónica
-- =====================================================================

-- =====================================================================
-- 1. Fármacos (drugs)
-- =====================================================================
INSERT INTO public.drugs
  (id, slug, name_pt, name_en, class_pt, class_en, aliases, status)
VALUES
  ('a0000000-0000-4000-8000-000000000030', 'beclometasona', 'Beclometasona', 'Beclomethasone', 'Corticosteroide inalatório', 'Inhaled corticosteroid', '{"beclometasona dipropionato","becotide","beklazin"}', 'published'),
  ('a0000000-0000-4000-8000-000000000031', 'fluticasona', 'Fluticasona', 'Fluticasone', 'Corticosteroide inalatório', 'Inhaled corticosteroid', '{"fluticasona propionato","flixotide","fluticasona furoato","avamys"}', 'published'),
  ('a0000000-0000-4000-8000-000000000032', 'roflumilast', 'Roflumilast', 'Roflumilast', 'Inibidor de PDE4 (COPD)', 'PDE4 inhibitor (COPD)', '{"daliresp","daxas"}', 'published')
ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- 2. Perfis (drug_profiles) — 8 colunas + 'published'
-- =====================================================================
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)
SELECT d.id,
  v.overview_public_pt, v.overview_public_en,
  v.overview_pro_pt, v.overview_pro_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('beclometasona',
   'A beclometasona é um corticosteroide inalatório usado para prevenir sintomas de asma. Reduz a inflamação das vias aéreas.',
   'Beclomethasone is an inhaled corticosteroid used to prevent asthma symptoms. It reduces airway inflammation.',
   'Corticosteroide inalatório de média potência. Inibe a libertação de mediadores inflamatórios e reduz a reactividade brônquica. Metabolizado por esterases pulmonares a metabolito inactivo (B-17-MP). Meia-vida pulmonar: 6 h. Dose: 200-800 mcg/dia (2-4 jactos). Forma MQF (microfinamente pulverizada) para melhor deposição pulmonar.',
   'Medium-potency inhaled corticosteroid. Inhibits inflammatory mediator release and reduces bronchial reactivity. Metabolised by pulmonary esterases to inactive metabolite (B-17-MP). Pulmonary half-life: 6 h. Dose: 200-800 mcg/day (2-4 puffs). MFI (microfine formulation) for better lung deposition.',
   'DailyMed/FDA — Beconase, Vancenase; EMC-UK — Beclometasone',
   'DailyMed/FDA — Beconase, Vancenase; EMC-UK — Beclometasone'),
  ('fluticasona',
   'A fluticasona é um corticosteroide inalatório de alta potência usado para asma e rinite alérgica.',
   'Fluticasone is a high-potency inhaled corticosteroid used for asthma and allergic rhinitis.',
   'Corticosteroide inalatório de alta potência. Inibe a transcrição genética de citocinas pró-inflamatórias via recetores glucocorticoides. Metabolizado por CYP3A4 hepático (efeito de primeiro passagem elevado — baixa biodisponibilidade sistémica ~1-2%). Meia-vida: 7,8 h (fluticasona propionato), 24 h (fluticasona furoato). Dose: 100-1000 mcg/dia.',
   'High-potency inhaled corticosteroid. Inhibits pro-inflammatory cytokine gene transcription via glucocorticoid receptors. Metabolised by hepatic CYP3A4 (high first-pass effect — low systemic bioavailability ~1-2%). Half-life: 7.8 h (fluticasone propionate), 24 h (fluticasone furoate). Dose: 100-1000 mcg/day.',
   'DailyMed/FDA — Flovent, Avamys; EMC-UK — Fluticasone',
   'DailyMed/FDA — Flovent, Avamys; EMC-UK — Fluticasone'),
  ('roflumilast',
   'O roflumilast é um inibidor de PDE4 para COPD grave com bronquite crónica.',
   'Roflumilast is a PDE4 inhibitor for severe COPD with chronic bronchitis.',
   'Inibidor selectivo de fosfodiesterase 4 (PDE4). Reduz a inflamação neutrofílica nas vias aéreas e a hipersecreção de muco. Indicado como terapia adjuvante em COPD grave (TFG <50) com bronquite crónica e exacerbações frecuentes. Não é broncodilatador. Meia-vida: 17 h (metabolito activo: 30 h). Metabolizado por CYP3A4 e CYP1A2. Dose: 500 mcg 1x/dia.',
   'Selective phosphodiesterase 4 (PDE4) inhibitor. Reduces neutrophilic airway inflammation and mucus hypersecretion. Indicated as add-on therapy in severe COPD (FEV1 <50%) with chronic bronchitis and frequent exacerbations. Not a bronchodilator. Half-life: 17 h (active metabolite: 30 h). Metabolised by CYP3A4 and CYP1A2. Dose: 500 mcg once daily.',
   'DailyMed/FDA — Daliresp; EMC-UK — Roflumilast',
   'DailyMed/FDA — Daliresp; EMC-UK — Roflumilast')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 3. Farmacologia (drug_pharmacology) — 13 colunas + 'published'
-- =====================================================================
INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en,
   mechanism_pt, mechanism_en,
   metabolism_pt, metabolism_en,
   absorption_pt, absorption_en,
   half_life_pt, half_life_en,
   source_pt, source_en, status)
SELECT d.id,
  v.pharmacodynamics_pt, v.pharmacodynamics_en,
  v.mechanism_pt, v.mechanism_en,
  v.metabolism_pt, v.metabolism_en,
  v.absorption_pt, v.absorption_en,
  v.half_life_pt, v.half_life_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('beclometasona',
   'Actividade anti-inflamatória corticosteróide inalatória. Reduz reactividade brônquica e inflamação crónica.',
   'Anti-inflammatory inhaled corticosteroid activity. Reduces bronchial reactivity and chronic inflammation.',
   'Liga ao recetor glucocorticoide intracelular, inibe a transcrição de citocinas pró-inflamatórias (IL-1, IL-6, TNF-α) e aumenta a transcrição de lipocortina-1. Efeito local pulmonar com baixa actividade sistémica.',
   'Binds to intracellular glucocorticoid receptor, inhibits transcription of pro-inflammatory cytokines (IL-1, IL-6, TNF-α) and increases lipocortin-1 transcription. Local pulmonary effect with low systemic activity.',
   'Metabolizado por esterases pulmonares a B-17-MP (inactivo). Metabolismo hepático menor por CYP3A4.',
   'Metabolised by pulmonary esterases to B-17-MP (inactive). Minor hepatic metabolism by CYP3A4.',
   'Absorção pulmonar rápida (40-50% da dose inalada). Biodisponibilidade sistémica: 10-20%.',
   'Rapid pulmonary absorption (40-50% of inhaled dose). Systemic bioavailability: 10-20%.',
   'Pulmonar: 6 h. Sistémica: 2,7 h.',
   'Pulmonary: 6 h. Systemic: 2.7 h.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('fluticasona',
   'Actividade anti-inflamatória corticosteróide inalatória de alta potência.',
   'High-potency anti-inflammatory inhaled corticosteroid activity.',
   'Liga ao recetor glucocorticoide com alta afinidade (25x maior que prednisolona). Inibe a transcrição de múltiplas citocinas pró-inflamatórias e reduz a reactividade brônquica. Efeito local pulmonar com baixa actividade sistémica devido ao elevado metabolismo de primeiro passagem.',
   'Binds to glucocorticoid receptor with high affinity (25x greater than prednisolone). Inhibits transcription of multiple pro-inflammatory cytokines and reduces bronchial reactivity. Local pulmonary effect with low systemic activity due to high first-pass metabolism.',
   'Metabolizado por CYP3A4 hepático (efeito de primeiro passagem elevado). Metabolitos inactivos (17β-carboxílico). Baixa biodisponibilidade sistémica (~1-2%).',
   'Metabolised by hepatic CYP3A4 (high first-pass effect). Inactive metabolites (17β-carboxylic acid). Low systemic bioavailability (~1-2%).',
   'Absorção pulmonar rápida. Biodisponibilidade sistémica: 1-2% (propionato), 0,5% (furoato).',
   'Rapid pulmonary absorption. Systemic bioavailability: 1-2% (propionate), 0.5% (furoate).',
   'Propionato: 7,8 h. Furoato: 24 h.',
   'Propionate: 7.8 h. Furoate: 24 h.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK'),
  ('roflumilast',
   'Actividade anti-inflamatória via inibição de PDE4. Reduz exacerbações em COPD grave.',
   'Anti-inflammatory activity via PDE4 inhibition. Reduces exacerbations in severe COPD.',
   'Inibe selectivamente a fosfodiesterase 4 (PDE4), aumentando os níveis de AMPc intracelular em células inflamatórias (neutrófilos, macrófagos, eosinófilos). Resultado: redução da inflamação neutrofílica e hipersecreção de muco nas vias aéreas.',
   'Selectively inhibits phosphodiesterase 4 (PDE4), increasing intracellular cAMP levels in inflammatory cells (neutrophils, macrophages, eosinophils). Result: reduced neutrophilic airway inflammation and mucus hypersecretion.',
   'Metabolizado por CYP3A4 e CYP1A2 a roflumilast N-óxido (metabolito activo, 3-5x mais potente). Inibidor fraco de CYP3A4.',
   'Metabolised by CYP3A4 and CYP1A2 to roflumilast N-oxide (active metabolite, 3-5x more potent). Weak CYP3A4 inhibitor.',
   'Absorção oral rápida. Biodisponibilidade: ~80%. Comida não afecta Cmax mas retarda Tmax.',
   'Rapid oral absorption. Bioavailability: ~80%. Food does not affect Cmax but delays Tmax.',
   'Roflumilast: 17 h. N-óxido: 30 h.',
   'Roflumilast: 17 h. N-oxide: 30 h.',
   'DailyMed/FDA; EMC-UK',
   'DailyMed/FDA; EMC-UK')
) AS v(slug, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en,
       metabolism_pt, metabolism_en, absorption_pt, absorption_en,
       half_life_pt, half_life_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- =====================================================================
-- 4. Indicações, efeitos e precauções (UPDATE drug_profiles)
-- =====================================================================
UPDATE public.drug_profiles SET
  indications_pt = 'Asma (profilaxia), bronquite crónica, Doença Pulmonar Obstrutiva Crónica (DPOC), rinite alérgica.',
  indications_en = 'Asthma (prophylaxis), chronic bronchitis, Chronic Obstructive Pulmonary Disease (COPD), allergic rhinitis.',
  side_effects_pt = 'Disfonia (rouquidão), candidíase orofaríngea, tosse, cefaleia, hematomas faciais (com uso prolongado).',
  side_effects_en = 'Dysphonia (hoarseness), oropharyngeal candidiasis, cough, headache, facial bruising (with prolonged use).',
  precautions_pt = 'Enxaguar boca após cada jacto. Usar espaçador para reduzir candidíase. Não usar para alívio de crises. Em doses altas, monitorizar função suprarrenal.',
  precautions_en = 'Rinse mouth after each puff. Use spacer to reduce candidiasis. Do not use for relief of acute attacks. At high doses, monitor adrenal function.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'beclometasona');

UPDATE public.drug_profiles SET
  indications_pt = 'Asma (profilaxia e manutenção), rinite alérgica sazonal e perene, pólipos nasais.',
  indications_en = 'Asthma (prophylaxis and maintenance), seasonal and perennial allergic rhinitis, nasal polyps.',
  side_effects_pt = 'Disfonia, candidíase orofaríngea, cefaleia, epistaxe (forma nasal), hematomas faciais (uso prolongado).',
  side_effects_en = 'Dysphonia, oropharyngeal candidiasis, headache, epistaxis (nasal form), facial bruising (prolonged use).',
  precautions_pt = 'Enxaguar boca após cada jacto. Usar espaçador. Não usar para crises agudas. Doses altas podem suprimir eixo HPA. Fluticasona furoato nasal: monitorizar hemorragia nasal.',
  precautions_en = 'Rinse mouth after each puff. Use spacer. Do not use for acute attacks. High doses may suppress HPA axis. Fluticasone furoate nasal: monitor nasal bleeding.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'fluticasona');

UPDATE public.drug_profiles SET
  indications_pt = 'COPD grave (TFG <50%) com bronquite crónica e exacerbações frecuentes, como terapia adjuvante.',
  indications_en = 'Severe COPD (FEV1 <50%) with chronic bronchitis and frequent exacerbations, as add-on therapy.',
  side_effects_pt = 'Diarreia (10%), náusea, dor de cabeça, perda de peso, insónia, dor abdominal. Raramente: depressão, ansiedade.',
  side_effects_en = 'Diarrhoea (10%), nausea, headache, weight loss, insomnia, abdominal pain. Rarely: depression, anxiety.',
  precautions_pt = 'Não é broncodilatador — não alivia crises agudas. Pode causar perda de peso clinicamente significativa. Monitorizar peso. Evitar com inibidores potentes CYP3A4 (ritonavir, ketoconazol). Não usar em crianças <18 anos.',
  precautions_en = 'Not a bronchodilator — does not relieve acute attacks. May cause clinically significant weight loss. Monitor weight. Avoid with potent CYP3A4 inhibitors (ritonavir, ketoconazole). Do not use in children <18 years.'
WHERE drug_id IN (SELECT id FROM drugs WHERE slug = 'roflumilast');
