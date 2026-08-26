-- =====================================================================
-- 206 — Expansão Antibióticos: pares de interação + dimensões
--
-- Pares: critical (2) + moderate (6) + minor (2)
-- Dimensões: alimento, doença, gravidez
-- Fontes: DailyMed/FDA, EMC-UK, Health Canada
-- =====================================================================

-- =====================================================================
-- 1. Pares de interação (drug_interactions)
-- =====================================================================
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   mechanism_pt, mechanism_en,
   management_pt, management_en,
   monitoring_pt, monitoring_en,
   red_flags_pt, red_flags_en,
   source_pt, source_en, source_url, status)
SELECT a.id, b.id, v.severity, v.summary_pt, v.summary_en,
  v.mechanism_pt, v.mechanism_en,
  v.management_pt, v.management_en,
  v.monitoring_pt, v.monitoring_en,
  v.red_flags_pt, v.red_flags_en,
  v.source_pt, v.source_en, v.source_url, 'published'
FROM (VALUES
  -- CRITICAL
  ('simvastatina', 'telitromicina', 'critical',
   'Cetolida + estatina: risco severo de miopatia/rabdomiólise. Telitromicina inibe CYP3A4, aumentando níveis de simvastatina ~10x.', 'Ketolide + statin: severe risk of myopathy/rhabdomyolysis. Telithromycin inhibits CYP3A4, increasing simvastatin levels ~10-fold.',
   'A telitromicina inibe moderadamente o CYP3A4, o principal sistema metabolizador da simvastatina. O aumento dos níveis de simvastatina pode causar miopatia grave com rabdomiólise. A combinação é clinicamente significativa e deve ser evitada.', 'Telithromycin moderately inhibits CYP3A4, the main metabolic pathway for simvastatin. Increased simvastatin levels can cause severe myopathy with rhabdomyolysis. The combination is clinically significant and should be avoided.',
   'Evitar a coadministração. Se inevitável, suspender simvastatina durante o tratamento com telitromicina. Alternativa: pravastatina (não metabolizada por CYP3A4).', 'Avoid coadministration. If unavoidable, discontinue simvastatin during telithromycin treatment. Alternative: pravastatin (not CYP3A4-metabolised).',
   'Creatina quinase (CK), sintomas de miopatia (dor muscular, fraqueza, urina escura).', 'Creatine kinase (CK), myopathy symptoms (muscle pain, weakness, dark urine).',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Telitromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9', 'DailyMed/FDA (NIH/NLM) — approved Telithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9'),
  ('warfarina', 'telitromicina', 'critical',
   'Cetolida + anticoagulante: warfarina potencializada via inibição CYP2C9. Risco de hemorragia grave.', 'Ketolide + anticoagulant: warfarin potentiated via CYP2C9 inhibition. Risk of serious haemorrhage.',
   'A telitromicina inibe o CYP2C9, a principal enzima metabólica da warfarina (enantiómetro S, mais potente). Estudos mostram aumento de 2-3x do INR. O risco de hemorragia é significativo.', 'Telithromycin inhibits CYP2C9, the main metabolic enzyme for warfarin (S-enantiomer, more potent). Studies show 2-3-fold INR increase. The risk of haemorrhage is significant.',
   'Evitar combinação se possível. Se necessário, reduzir dose de warfarina 25-50% e monitorizar INR diariamente durante e 1 semana após antibioticoterapia.', 'Avoid combination if possible. If necessary, reduce warfarin dose 25-50% and monitor INR daily during and 1 week after antibiotic therapy.',
   'INR diário, sinais de hemorragia (equimoses, hematúria, melena).', 'Daily INR, signs of bleeding (bruising, haematuria, melaena).',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Telitromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9', 'DailyMed/FDA (NIH/NLM) — approved Telithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9'),
  -- MODERATE
  ('sulfametoxazol-trimetoprima', 'warfarina', 'moderate',
   'Sulfonamida + anticoagulante: efeito anticoagulante potencializado. Mecanismo duplo: inibição CYP2C9 + deslocamento de ligação proteica.', 'Sulfonamide + anticoagulant: anticoagulant effect potentiated. Dual mechanism: CYP2C9 inhibition + protein binding displacement.',
   'O sulfametoxazol inibe moderadamente o CYP2C9 e desloca a warfarina das proteínas plasmáticas. Atrimetoprima contribui pouco. O INR pode aumentar 1,5-2x. Risco de hemorragia, especialmente em idosos.', 'Sulfamethoxazole moderately inhibits CYP2C9 and displaces warfarin from plasma proteins. Trimethoprim contributes little. INR may increase 1.5-2-fold. Haemorrhage risk, especially in the elderly.',
   'Monitorizar INR estreitamente (2-3x/semana) durante a primeira semana. Considerar reduzir dose de warfarina 10-20%. Não há necessidade de alteração rotineira.', 'Monitor INR closely (2-3 times/week) during the first week. Consider reducing warfarin dose 10-20%. No routine alteration required.',
   'INR, sinais de hemorragia.', 'INR, signs of bleeding.',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62', 'DailyMed/FDA (NIH/NLM) — approved Bactrim label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'),
  ('sulfametoxazol-trimetoprima', 'metformina', 'moderate',
   'Sulfonamida + biguanida: risco de hipoglicemia e acidose láctica. Trimetoprima pode reduzir TFG e eletrólitos.', 'Sulfonamide + biguanide: risk of hypoglycaemia and lactic acidosis. Trimethoprim may reduce GFR and electrolytes.',
   'A combinação pode causar: (1) hipoglicemia (mecanismo não totalmente elucidado — possivelmente sensibilização das células beta), (2) hipercalemia (trimetoprima bloqueia canais de potássio), (3) redução da TFG (desidratação). Risco maior em idosos e insuficiência renal.', 'The combination may cause: (1) hypoglycaemia (mechanism not fully elucidated — possibly beta-cell sensitisation), (2) hyperkalaemia (trimethoprim blocks potassium channels), (3) reduced GFR (dehydration). Higher risk in the elderly and renal impairment.',
   'Monitorizar glicemia, eletrólitos e TFG. Manter hidratação adequada. Considerar reduzir dose de metformina se TFG <45.', 'Monitor blood glucose, electrolytes, and GFR. Maintain adequate hydration. Consider reducing metformin dose if eGFR <45.',
   'Glicemia, potássio, TFG, eletrólitos.', 'Blood glucose, potassium, GFR, electrolytes.',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62', 'DailyMed/FDA (NIH/NLM) — approved Bactrim label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'),
  ('clindamicina', 'eritromicina', 'moderate',
   'Lincosamida + macrólido: antagonismo bacteriológico. Ambos ligam à subunidade 50S — competição pelo mesmo sítio.', 'Lincosamide + macrolide: bacteriological antagonism. Both bind to the 50S subunit — competition for the same site.',
   'Clindamicina e eritromicina competem pelo mesmo sítio de ligação na subunidade 50S do ribossomo. A eritromicina (bacteriostático) pode reduzir a eficácia da clindamicina (também bacteriostático). Clinicamente, a combinação é geralmente evitada, exceto em Pneumocystis (sinergismo documentado).', 'Clindamycin and erythromycin compete for the same binding site on the 50S ribosomal subunit. Erythromycin (bacteriostatic) may reduce clindamycin efficacy (also bacteriostatic). Clinically, the combination is generally avoided, except in Pneumocystis (documented synergy).',
   'Evitar a combinação para infeções bacterianas convencionais. Exceção: profilaxia de Pneumocystis jirovecii (sinergismo).', 'Avoid the combination for conventional bacterial infections. Exception: Pneumocystis jirovecii prophylaxis (synergy).',
   'Resposta clínica, culturas se disponíveis.', 'Clinical response, cultures if available.',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clindamicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd', 'DailyMed/FDA (NIH/NLM) — approved Clindamycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd'),
  ('penicilina-g', 'probenecida', 'moderate',
   'Penicilina + uricosúrico: níveis de penicilina aumentados ~2x via bloqueio da secreção tubular renal.', 'Penicillin + uricosuric: penicillin levels increased ~2x via blockade of renal tubular secretion.',
   'O probenecida bloqueia a secreção tubular renal da penicilina, aumentando os níveis séricos e prolongando a meia-vida. Historicamente usado intencionalmente para prolongar ação da penicilina. Atualmente, a utilização concomitante é rara.', 'Probenecid blocks renal tubular secretion of penicillin, increasing serum levels and prolonging half-life. Historically used intentionally to prolong penicillin action. Currently, concomitant use is rare.',
   'Se coadministração intencional (sífilis, endocardite): reduzir dose de penicilina. Se não intencional: não há necessidade de ajuste — apenas monitorizar.', 'If intentional coadministration (syphilis, endocarditis): reduce penicillin dose. If unintentional: no adjustment required — just monitor.',
   'Níveis séricos de penicilina (se disponível), resposta clínica.', 'Serum penicillin levels (if available), clinical response.',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilina G: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c', 'DailyMed/FDA (NIH/NLM) — approved Penicillin G label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c'),
  ('aciclovir', 'probenecida', 'moderate',
   'Antivírico + uricosúrico: níveis de aciclovir aumentados ~40% via bloqueio da secreção tubular renal.', 'Antiviral + uricosuric: acyclovir levels increased ~40% via blockade of renal tubular secretion.',
   'O probenecida bloqueia a secreção tubular renal do aciclovir, aumentando os níveis séricos em ~40% e prolongando a meia-vida. Risco aumentado de nefrotoxicidade (cristais de aciclovir).', 'Probenecid blocks renal tubular secretion of acyclovir, increasing serum levels by ~40% and prolonging half-life. Increased risk of nephrotoxicity (acyclovir crystals).',
   'Se coadministração necessária: reduzir dose de aciclovir 50% e aumentar hidratação. Monitorizar TFG e creatinina.', 'If coadministration necessary: reduce acyclovir dose by 50% and increase hydration. Monitor GFR and creatinine.',
   'Creatinina, TFG, volume urinário, sintomas nefrológicos.', 'Creatinine, GFR, urine volume, nephrological symptoms.',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Aciclovir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109', 'DailyMed/FDA (NIH/NLM) — approved Acyclovir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109'),
  -- MINOR
  ('cefixima', 'probioticos', 'minor',
   'Cefalosporina + probióticos: antibiótico pode reduzir eficácia de probióticos vivos. Administrar com intervalo ≥2 h.', 'Cephalosporin + probiotics: antibiotic may reduce efficacy of live probiotics. Administer with ≥2 h interval.',
   'A cefixima pode reduzir a contagem de lactobacilos e bifidobactérias dos probióticos. A separação temporal minimiza o efeito. Não há interação clinicamente significativa.', 'Cefixime may reduce Lactobacillus and Bifidobacterium counts in probiotics. Temporal separation minimises the effect. No clinically significant interaction.',
   'Administrar probióticos ≥2 h após ou antes da cefixima.', 'Administer probiotics ≥2 h after or before cefixime.',
   'Não requer monitorização específica.', 'No specific monitoring required.',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefixima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34', 'DailyMed/FDA (NIH/NLM) — approved Cefixime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34'),
  ('clindamicina', 'probioticos', 'minor',
   'Lincosamida + probióticos: antibiótico pode reduzir eficácia de probióticos vivos. Administrar com intervalo ≥2 h.', 'Lincosamide + probiotics: antibiotic may reduce efficacy of live probiotics. Administer with ≥2 h interval.',
   'A clindamicina tem amplo espectro anti-anaeróbios e pode reduzir significativamente a flora intestinal. Probióticos concomitantes podem ajudar a prevenir diarreia associada a antibióticos, mas a eficácia é reduzida.', 'Clindamycin has broad anaerobic spectrum and may significantly reduce intestinal flora. Concomitant probiotics may help prevent antibiotic-associated diarrhoea, but efficacy is reduced.',
   'Administrar probióticos ≥2 h após clindamicina. Considerar Saccharomyces boulardii (resistente a antibióticos).', 'Administer probiotics ≥2 h after clindamycin. Consider Saccharomyces boulardii (antibiotic-resistant).',
   'Não requer monitorização específica.', 'No specific monitoring required.',
   '', '',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clindamicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd', 'DailyMed/FDA (NIH/NLM) — approved Clindamycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd', 'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd')
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
     mechanism_pt, mechanism_en,
     management_pt, management_en,
     monitoring_pt, monitoring_en,
     red_flags_pt, red_flags_en,
     source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. Interações alimento/bebida (drug_food_interactions)
-- =====================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en,
   mechanism_pt, mechanism_en,
   advice_pt, advice_en, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en,
  v.mechanism_pt, v.mechanism_en,
  v.advice_pt, v.advice_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('penicilina-g', 'alimentos_alcalinos', 'Alimentos/alimentos alcalinos', 'Alkaline foods',
   'Alimentos alcalinos inativam a penicilina G por hidrólise. Aumentar intervalo entre refeição e medicamento.',
   'Alkaline foods inactivate penicillin G by hydrolysis. Increase interval between food and medication.',
   'Administrar 1 h antes ou 2 h após refeições. Evitar sucos de fruta ácidos (podem precipitar).',
   'Administer 1 h before or 2 h after meals. Avoid acidic fruit juices (may precipitate).'
  ),
  ('sulfametoxazol-trimetoprima', 'alimentos_ricos_potassio', 'Alimentos ricos em potássio', 'Potassium-rich foods',
   'Trimetoprima bloqueia canais de potássio — alimentos ricos em K+ podem agravar hipercalemia.',
   'Trimethoprim blocks potassium channels — K+-rich foods may worsen hyperkalaemia.',
   'Evitar excesso de alimentos ricos em potássio (banana, laranja, batata) durante tratamento prolongado.',
   'Avoid excess potassium-rich foods (banana, orange, potato) during prolonged treatment.'
  ),
  ('clindamicina', 'alimentos', 'Comida', 'Food',
   'Comida reduz a biodisponibilidade oral da clindamicina em ~50%. O estômago vazio melhora a absorção.',
   'Food reduces oral clindamycin bioavailability by ~50%. Fasting improves absorption.',
   'Tomar clindamicina oral com estômago vazio (1 h antes ou 2 h após refeição).',
   'Take oral clindamycin on an empty stomach (1 h before or 2 h after meals).'
  ),
  ('aciclovir', 'alimentos', 'Comida', 'Food',
   'Comida não afeta significativamente a absorção do aciclovir. Pode reduzir náuseas.',
   'Food does not significantly affect acyclovir absorption. May reduce nausea.',
   'Pode ser tomado com ou sem comida. Comida ajuda a reduzir náuseas.',
   'May be taken with or without food. Food helps reduce nausea.'
  ),
  ('cefixima', 'alimentos', 'Comida', 'Food',
   'Comida aumenta a absorção da cefixima em ~15%. Biodisponibilidade: 40-50% em jejum, ~55% com comida.',
   'Food increases cefixime absorption by ~15%. Bioavailability: 40-50% fasting, ~55% with food.',
   'Tomar com comida para melhorar absorção, se necessário.',
   'Take with food to improve absorption, if needed.'
  )
) AS v(slug, entity_slug, entity_pt, entity_en,
     mechanism_pt, mechanism_en,
     advice_pt, advice_en)
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
  ('penicilina-g', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Excreção renal >80% — acumulação em insuficiência renal. Risco de neurotoxicidade (convulsões) com doses não ajustadas.',
   'Renal excretion >80% — accumulation in renal impairment. Risk of neurotoxicity (seizures) with unadjusted doses.',
   'Ajustar intervalo à TFG: TFG 10-50: q6-8h; TFG <10: q12-16h. Hemodiálise remove ~40%.',
   'Adjust interval to eGFR: eGFR 10-50: q6-8h; eGFR <10: q12-16h. Haemodialysis removes ~40%.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilina G: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c',
   'DailyMed/FDA (NIH/NLM) — approved Penicillin G label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c'
  ),
  ('sulfametoxazol-trimetoprima', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Excreção renal — acumulação em TFG <30. Trimetoprima bloqueia canais de potássio (hipercalemia). Sulfametoxazol precipita em urina ácida.',
   'Renal excretion — accumulation at eGFR <30. Trimethoprim blocks potassium channels (hyperkalaemia). Sulfamethoxazole precipitates in acidic urine.',
   'TFG 15-30: dose reduzida 50%. TFG <15: evitar. Alcalinizar urina para prevenir cristalúria.',
   'eGFR 15-30: 50% dose reduction. eGFR <15: avoid. Alkalinise urine to prevent crystalluria.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62',
   'DailyMed/FDA (NIH/NLM) — approved Bactrim label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'
  ),
  ('aciclovir', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Excreção renal >90% inalterada. Meia-vida prolongada (até 20 h em anúria). Risco de cristalúria e nefrotoxicidade.',
   'Renal excretion >90% unchanged. Prolonged half-life (up to 20 h in anuria). Risk of crystalluria and nephrotoxicity.',
   'TFG 50-80: q8h. TFG 20-50: q12h. TFG 10-20: q24h. TFG <10: q24h com dose reduzida 50%. Hemodiálise: adicionar dose pós-HD.',
   'eGFR 50-80: q8h. eGFR 20-50: q12h. eGFR 10-20: q24h. eGFR <10: q24h with 50% dose reduction. Haemodialysis: add post-HD dose.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Aciclovir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109',
   'DailyMed/FDA (NIH/NLM) — approved Acyclovir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109'
  ),
  ('cefixima', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Excreção renal ~50% inalterada. Acumulação em TFG <60. Meia-vida prolongada.',
   'Renal excretion ~50% unchanged. Accumulation at eGFR <60. Prolonged half-life.',
   'TFG 30-60: dose habitual. TFG 10-29: 200 mg/dia. TFG <10: 100 mg/dia.',
   'eGFR 30-60: usual dose. eGFR 10-29: 200 mg/day. eGFR <10: 100 mg/day.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefixima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34',
   'DailyMed/FDA (NIH/NLM) — approved Cefixime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34'
  ),
  ('clindamicina', 'insuficiencia_hepatica', 'Insuficiência hepática', 'Hepatic impairment',
   'precaution', 'moderate',
   'Metabolismo hepático significativo. Acumulação em insuficiência hepática grave. Risco de hepatotoxicidade aditiva.',
   'Significant hepatic metabolism. Accumulation in severe hepatic impairment. Risk of additive hepatotoxicity.',
   'Não requer ajuste em insuficiência hepática leve-moderada. Evitar em insuficiência hepática grave.',
   'No adjustment required in mild-moderate hepatic impairment. Avoid in severe hepatic impairment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clindamicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd',
   'DailyMed/FDA (NIH/NLM) — approved Clindamycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd'
  )
) AS v(slug, condition_slug, condition_pt, condition_en,
     interaction_type, severity,
     reason_pt, reason_en,
     advice_pt, advice_en,
     source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- =====================================================================
-- 4. Perfis de gravidez/lactação (drug_pregnancy_info)
-- =====================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en,
   trimester_pt, trimester_en,
   lactation_pt, lactation_en,
   contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id,
  v.pregnancy_category, v.risk_pt, v.risk_en,
  v.trimester_pt, v.trimester_en,
  v.lactation_pt, v.lactation_en,
  v.contraception_pt, v.contraception_en,
  v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('penicilina-g', 'compatible',
   'Categoria B: seguro na gravidez. Penicilinas são as de eleição em gravidez (sífilis, listeriose).',
   'Category B: safe in pregnancy. Penicillins are the drugs of choice in pregnancy (syphilis, listeriosis).',
   'Todos os trimestres. Seguro.',
   'All trimesters. Safe.',
   'Excretada em pequenas quantidades no leite materno. Segura durante aleitamento.',
   'Excreted in small amounts in breast milk. Safe during breastfeeding.',
   'Não há evidência de efeitos sobre a fertilidade.',
   'No evidence of effects on fertility.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilina G: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c',
   'DailyMed/FDA (NIH/NLM) — approved Penicillin G label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c'
  ),
  ('sulfametoxazol-trimetoprima', 'contraindicated',
   'CONTRAINDICADO no 3º trimestre (kernicterus). Evitar no 1º trimestre (folato). Considerar no 2º trimestre para PCP.',
   'CONTRAINDICATED in 3rd trimester (kernicterus). Avoid in 1st trimester (folate). May consider in 2nd trimester for PCP.',
   '3º trimestre: CONTRAINDICADO. 1º trimestre: evitar. 2º trimestre: apenas para indicações graves.',
   '3rd trimester: CONTRAINDICATED. 1st trimester: avoid. 2nd trimester: only for serious indications.',
   'Excretado no leite materno. CONTRAINDICADO durante aleitamento.',
   'Excreted in breast milk. CONTRAINDICATED during breastfeeding.',
   'Efeitos sobre a fertilidade em animais. Dados inadequados em humanos.',
   'Effects on fertility in animals. Inadequate human data.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62',
   'DailyMed/FDA (NIH/NLM) — approved Bactrim label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'
  ),
  ('clindamicina', 'compatible',
   'Categoria B: seguro na gravidez para indicações aprovadas (profilaxia cirúrgica).',
   'Category B: safe in pregnancy for approved indications (surgical prophylaxis).',
   'Todos os trimestres. Seguro.',
   'All trimesters. Safe.',
   'Excretada em baixas concentrações no leite. Compatível com aleitamento.',
   'Excreted in low concentrations in breast milk. Compatible with breastfeeding.',
   'Não há evidência de efeitos sobre a fertilidade.',
   'No evidence of effects on fertility.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clindamicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd',
   'DailyMed/FDA (NIH/NLM) — approved Clindamycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd'
  ),
  ('aciclovir', 'compatible',
   'Categoria B: seguro. Tratamento de eleição para herpes genital e zóster em grávidas.',
   'Category B: safe. Treatment of choice for genital herpes and zoster in pregnancy.',
   'Todos os trimestres. Seguro.',
   'All trimesters. Safe.',
   'Excretado em baixas concentrações (<1% da dose). Compatível com aleitamento.',
   'Excreted in low concentrations (<1% of dose). Compatible with breastfeeding.',
   'Não há evidência de efeitos sobre a fertilidade.',
   'No evidence of effects on fertility.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Aciclovir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109',
   'DailyMed/FDA (NIH/NLM) — approved Acyclovir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109'
  ),
  ('cefixima', 'compatible',
   'Categoria B: seguro. Dados limitados mas reassuring em humanos.',
   'Category B: safe. Limited but reassuring human data.',
   'Todos os trimestres. Dados limitados.',
   'All trimesters. Limited data.',
   'Excretado em pequenas quantidades no leite. Precaução.',
   'Excreted in small amounts in breast milk. Use with caution.',
   'Não há evidência de efeitos sobre a fertilidade.',
   'No evidence of effects on fertility.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefixima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34',
   'DailyMed/FDA (NIH/NLM) — approved Cefixime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=655a59ba-08e9-51d4-e053-2991aa0aef34'
  ),
  ('cefpodoxima', 'compatible',
   'Categoria B: seguro. Dados limitados em humanos.',
   'Category B: safe. Limited human data.',
   'Todos os trimestres. Dados limitados.',
   'All trimesters. Limited data.',
   'Excretado em pequenas quantidades no leite. Precaução.',
   'Excreted in small amounts in breast milk. Use with caution.',
   'Não há evidência de efeitos sobre a fertilidade.',
   'No evidence of effects on fertility.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cefpodoxima: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c36f2137-98bb-4583-89f7-6bce9582c465',
   'DailyMed/FDA (NIH/NLM) — approved Cefpodoxime label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c36f2137-98bb-4583-89f7-6bce9582c465'
  ),
  ('telitromicina', 'contraindicated',
   'CONTRAINDICADO na gravidez. Toxicidade fetal (perda embrionária, atraso no desenvolvimento).',
   'CONTRAINDICATED in pregnancy. Fetal toxicity (embryonic loss, developmental delay).',
   'Todos os trimestres: CONTRAINDICADO.',
   'All trimesters: CONTRAINDICATED.',
   'CONTRAINDICADO durante aleitamento.',
   'CONTRAINDICATED during breastfeeding.',
   'Dados inadequados sobre fertilidade humana.',
   'Inadequate data on human fertility.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Telitromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9',
   'DailyMed/FDA (NIH/NLM) — approved Telithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9'
  )
) AS v(slug, pregnancy_category,
     risk_pt, risk_en,
     trimester_pt, trimester_en,
     lactation_pt, lactation_en,
     contraception_pt, contraception_en,
     source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
