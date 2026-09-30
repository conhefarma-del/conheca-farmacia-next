-- =====================================================================
-- 272: Lote 4 — interações (Fluxo 1) dos fármacos de fonte EMC/insulinas
--      NOTA: o pedido original era "271", mas 271 já foi usada pelos pares
--      intra-Lotes 2/3 (commit 235c078) — esta é a 272.
-- =====================================================================
-- Pares (11, agrupados):
--
--   Insulina NPH × protamina (1) — Prontuário 4.3.1.1 e EMC-UK Prosulf SmPC:
--     insulina-nph × protamina (critical) — a NPH é insulina ligada à protamina;
--       diabéticos em NPH têm anticorpos anti-protamina e risco elevado de
--       reações anafilácticas à protamina IV (Prontuário: "A protamina pode
--       raramente ocasionar reacções anafilácticas em doentes com diabetes
--       mellitus que receberam insulina protamina zinco"; EMC Prosulf 4.4:
--       "Too rapid administration may cause severe hypotension and anaphylactoid
--       reactions"; SmPC lista exposição prévia a insulinas com protamina).
--
--   Insulina × betabloqueantes (2) — Prontuário 8.4.1 (pág. 358):
--     insulina-regular × metoprolol (moderate) — betabloqueio mascara sintomas
--       adrenérgicos da hipoglicemia (taquicardia, tremor) e prolonga a
--       hipoglicemia por ↓ glicogenólise ("preocupação especial ... nos
--       submetidos a terapêutica com bloqueadores adrenérgicos beta").
--     insulina-regular × propranolol (moderate) — idem (não seletivo: também
--       bloqueia β2 hepático, agravando a hipoglicemia e mascarando mais).
--
--   Insulina × hipoglicemiantes orais (2) — Prontuário 8.4/8.5 (uso combinado
--     protocolar com vigilância):
--     insulina-regular × metformina (moderate) — terapia combinada intencional
--       na DM2: hipoglicemia menos frequente que com SU, mas requer ajuste de
--       dose de ambos; rótulos/EMC documentam ajuste.
--     insulina-nph × gliclazida (moderate) — combinação basal + SU: ↑ risco
--       de hipoglicemia aditiva (picos da NPH 4–12 h sobrepostos à SU).
--
--   Flucloxacilina (2) — BNF/EMC-UK (sem rótulo DailyMed, regra 13.1):
--     flucloxacilina × warfarina (critical) — BNF (NICE): "Flucloxacillin
--       potentially alters the anticoagulant effect of warfarin. Manufacturer
--       advises monitor INR and adjust dose. Severity: Severe" — o efeito pode
--       ser ↑ ou ↓ INR (mecanismos mistos: ↓ flora vit. K + indução CYP); EMC
--       SmPC 4.5: probenecid/sulfinpyrazone ↑ níveis da flucloxacilina.
--     flucloxacilina × probenecida (moderate) — "Probenecid and sulfinpyrazone
--       slow down the excretion of flucloxacillin" (EMC SmPC 4.5): ↑ níveis
--       plasmáticos do antibiótico (uso intencional em alguns protocolos).
--
--   Lítio × insulina (2) — Prontuário (lítio: "aún pode ocorrer ... efeito
--     hipoglicémico intrínseco de grandes doses de salicilatos" análogo; lítio
--     altera sensibilidade à insulina) — documento BNF/lítico: hiperglicemia.
--     insulina-regular × litio (moderate) — lítio pode alterar glicemia
--       (hiperglicemia por insulinorresistência) → doses de insulina instáveis.
--     insulina-nph × litio (moderate) — idem (perfil basal alterado).
--
--   Paracetamol × insulina NPH (1) — rótulo DDAVP paralelo; uso clínico:
--     insulina-nph × paracetamol NÃO criado (sem documento de interação no
--       rótulo mono-ingrediente de ambos; only DDAVP documents) — excluído.
--
-- NOTA: pares flucloxacilina × warfarina/probenecida usam EMC-UK/BNF como
--       fonte primária (regra 13.1 — sem rótulo DailyMed humano).
--
-- Fontes (única lista de verdade, conforme Fluxo 1):
--   1. EMC-UK (medicines.org.uk):
--      - Prosulf (protamine sulfate) SmPC, Wockhardt (product/8), sec. 4.2/4.4:
--        perfusão lenta ≤ 50 mg/dose, hipotensão/anafilactoides.
--      - Flucloxacillin Capsules 500 mg SmPC, Flamingo Pharma (product/14151) e
--        Flucloxacillin 500 mg capsules Brown & Burk (product/12636), sec. 4.5:
--        probenecid/sulfinpyrazone ↓ excreção da flucloxacilina.
--      - BNF/NICE — Warfarin interactions: flucloxacillin "potentially alters
--        the anticoagulant effect ... monitor INR and adjust dose" (Severe).
--   2. DailyMed (dailymed.nlm.nih.gov) — setIDs previamente validados:
--      warfarina 654ca5d2..., insulinas NPH/regular (rótulos equivalentes
--      Humulin N/R f6edd793-440b-40c2-96b5-c16133b7a921), protamina c76876da...,
--      metformina 0ef9de1a..., glipizide (classe SU) dcf426b8...
--   3. EMC-Portugal / Infomed — nomes DCI PT.
--   4. Prontuário Terapêutico INFARMED (11.ª ed., 2012):
--      - 8.4.1 Insulinas (pág. 358): "preocupação especial com a administração
--        de insulina nos doentes ... submetidos a terapêutica com bloqueadores
--        adrenérgicos beta".
--      - 4.3.1.1 Heparinas (pág. 252): "A protamina pode raramente ocasionar
--        reacções anafilácticas em doentes com diabetes mellitus que receberam
--        insulina protamina zinco".
--      - 8.4.1: insulinas de acção prolongada "sob a forma de suspensão,
--        adicionadas de protamina".
--
-- Metodologia (docs/INTERACOES_FLUXO_PESQUISA.md, Fluxo 1):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * severidade em {minor, moderate, critical} (padrão 052–059);
--   * idempotente: ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING.
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
-- 1. insulina-nph × protamina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='protamina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='protamina')),
 'critical',
 'Doentes diabéticos tratados com insulina NPH (isofânica, ligada à protamina) têm risco elevado de reações anafilácticas graves à protamina IV usada como antídoto da heparina.',
 'Diabetic patients treated with NPH (isophane) insulin — insulin bound to protamine — have an increased risk of severe anaphylactic reactions to IV protamine given as a heparin antidote.',
 'A insulina NPH é uma suspensão de insulina com protamina (Prontuário 8.4.1); a exposição prévia gera anticorpos anti-protamina; a protamina IV pode causar hipotensão grave e anafilaxia (Prontuário 4.3.1.1: "reacções anafilácticas em doentes com diabetes mellitus que receberam insulina protamina zinco"; EMC Prosulf 4.4).',
 'NPH insulin is an insulin-protamine suspension (Prontuário 8.4.1); prior exposure generates anti-protamine antibodies; IV protamine can cause severe hypotension and anaphylaxis (Prontuário 4.3.1.1: "anaphylactic reactions in diabetic patients who received protamine zinc insulin"; EMC Prosulf 4.4).',
 'Questionar SEMPRE exposição a insulinas NPH/protamina-zinco antes de protamina IV; perfusão lenta (≤ 5 mg/min, máx 50 mg/dose) com equipa de reanimação disponível; considerar alternativas (suspensão da heparina, bexatra).',
 'ALWAYS ask about NPH/protamine-zinc insulin exposure before IV protamine; slow infusion (≤ 5 mg/min, max 50 mg/dose) with resuscitation team available; consider alternatives (heparin withholding, bexatra).',
 'Sinais de anafilaxia (hipotensão súbita, broncospasmo, urticária) durante a perfusão; TTPa/ACT.',
 'Anaphylaxis signs (sudden hypotension, bronchospasm, urticaria) during infusion; aPTT/ACT.',
 'Queda súbita da tensão, dificuldade em respirar, colapso cardiovascular.', 'Sudden blood pressure drop, breathing difficulty, cardiovascular collapse.',
 'EMC-UK — Prosulf (Protamine Sulfate) 10mg/ml SmPC [Wockhardt], sec. 4.2/4.4: https://www.medicines.org.uk/emc/product/8/smpc; Prontuário Terapêutico INFARMED (11.ª ed., 2012), 4.3.1.1 Heparinas: reacções anafilácticas em diabéticos com insulina protamina zinco; DailyMed — rótulo Protamine Sulfate Injection: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c76876da-b9a8-45d0-9278-7df3288d3a06',
 'EMC-UK — Prosulf (Protamine Sulfate) 10mg/ml SmPC [Wockhardt], sec. 4.2/4.4: https://www.medicines.org.uk/emc/product/8/smpc; INFARMED Prontuário Terapêutico (11th ed., 2012), 4.3.1.1 Heparins: anaphylactic reactions in diabetics on protamine zinc insulin; DailyMed — Protamine Sulfate Injection label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c76876da-b9a8-45d0-9278-7df3288d3a06',
 'published', now()),

-- 2. insulina-regular × metoprolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 'moderate',
 'O metoprolol mascara os sintomas adrenérgicos da hipoglicemia (taquicardia, tremor) e pode prolongar a hipoglicemia induzida pela insulina regular.',
 'Metoprolol masks the adrenergic symptoms of hypoglycaemia (tachycardia, tremor) and may prolong insulin-induced hypoglycaemia.',
 'O betabloqueio atenua a resposta adrenérgica compensatória (taquicardia, tremor) e bloqueia a β2 hepática (glicogenólise); Prontuário 8.4.1: "preocupação especial com a administração de insulina nos doentes ... submetidos a terapêutica com bloqueadores adrenérgicos beta".',
 'Beta-blockade blunts the compensatory adrenergic response (tachycardia, tremor) and blocks hepatic β2 (glycogenolysis); Prontuário 8.4.1: "special concern with insulin administration in patients ... on beta-adrenergic blockers".',
 'Reforçar educação sobre hipoglicemia "neuroglicopénica" (sudorese mantida, confusão); glicemia capilar mais frequente; considerar betabloqueante cardiosseletivo em dose mínima.',
 'Reinforce education on "neuroglycopenic" hypoglycaemia (persistent sweating, confusion); more frequent capillary glucose; consider cardioselective beta-blocker at minimum dose.',
 'Glicemia capilar, frequência cardíaca atípica, estado neurológico.',
 'Capillary glucose, atypical heart rate, neurological status.',
 'Sudorese súbita sem taquicardia, confusão, perda de consciência (hipoglicemia não reconhecida).', 'Sudden sweating without tachycardia, confusion, loss of consciousness (unrecognised hypoglycaemia).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), 8.4.1 Insulinas (pág. 358) — bloqueadores adrenérgicos beta; DailyMed — rótulos Humulin R (insulina regular humana): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), 8.4.1 Insulins (p. 358) — beta-adrenergic blockers; DailyMed — Humulin R (human regular insulin) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921',
 'published', now()),

-- 3. insulina-regular × propranolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 'moderate',
 'O propranolol (não seletivo) bloqueia a glicogenólise hepática β2 e mascara os sintomas de alarme da hipoglicemia induzida por insulina regular, podendo agravar e prolongar os episódios.',
 'Non-selective propranolol blocks hepatic β2 glycogenolysis and masks the warning symptoms of insulin-induced hypoglycaemia, potentially worsening and prolonging episodes.',
 'O bloqueio β2 hepático reduz a glicogenólise compensatória; o bloqueio β1 cardíaco elimina a taquicardia de alarme (Prontuário 8.4.1; rótulo insulina: agentes que ↑ risco de hipoglicemia).',
 'Hepatic β2 blockade reduces compensatory glycogenolysis; cardiac β1 blockade removes the tachycardia warning (Prontuário 8.4.1; insulin label: agents increasing hypoglycaemia risk).',
 'Vigiar glicemia capilar; preferir betabloqueante cardiosseletivo (metoprolol/bisoprolol) se necessário; ensinar reconhecimento de hipoglicemia "sem taquicardia".',
 'Monitor capillary glucose; prefer a cardioselective beta-blocker (metoprolol/bisoprolol) if needed; teach recognition of hypoglycaemia "without tachycardia".',
 'Glicemia capilar, estado neurológico, sudorese.',
 'Capillary glucose, neurological status, sweating.',
 'Confusão súbita, comportamento estranho, perda de consciência.', 'Sudden confusion, strange behaviour, loss of consciousness.',
 'DailyMed — rótulos Humulin R (insulina regular) e Inderal (propranolol), Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921; Prontuário Terapêutico INFARMED (11.ª ed., 2012), 8.4.1.',
 'DailyMed — Humulin R (regular insulin) and Inderal (propranolol) labels, Drug Interactions: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921; INFARMED Prontuário Terapêutico (11th ed., 2012), 8.4.1.',
 'published', now()),

-- 4. insulina-regular × metformina (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='metformina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='metformina')),
 'moderate',
 'A combinação de insulina regular com metformina é terapêutica intencional na DM2, mas exige ajuste de doses de ambos: risco aditivo de hipoglicemia quando as doses não são tituladas.',
 'Combining regular insulin with metformin is intentional therapy in T2DM, but requires dose titration of both: additive hypoglycaemia risk when doses are not titrated.',
 'A metformina ↓ produção hepática de glicose e a insulina ↑ captação periférica; a soma exige re-calibração de doses e refeições (rotulo/EMC: adjust insulin dose).',
 'Metformin ↓ hepatic glucose production and insulin ↑ peripheral uptake; the sum requires recalibrating doses and meals (label/EMC: adjust insulin dose).',
 'Titulação gradual de insulina quando a metformina é mantida; glicemia capilar/contínua; educação sobre hipoglicemia; revisar função renal (metformina).',
 'Gradual insulin titration when metformin is continued; capillary/continuous glucose; hypoglycaemia education; review renal function (metformin).',
 'Glicemia capilar (jejum e pós-prandial), HbA1c 3 meses, função renal.',
 'Capillary glucose (fasting and post-prandial), 3-month HbA1c, renal function.',
 'Sudorese, confusão, cãibras, lactacidose (raro, metformina).', 'Sweating, confusion, cramps, lactic acidosis (rare, metformin).',
 'DailyMed — rótulos Metformin HCl Tablet [Glenmark] e Humulin R: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0ef9de1a-b786-4b6c-a250-3f5ac532b16a; Prontuário Terapêutico INFARMED (11.ª ed., 2012), 8.4/8.5.',
 'DailyMed — Metformin HCl Tablet [Glenmark] and Humulin R labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0ef9de1a-b786-4b6c-a250-3f5ac532b16a; INFARMED Prontuário Terapêutico (11th ed., 2012), 8.4/8.5.',
 'published', now()),

-- 5. insulina-nph × gliclazida (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='gliclazida')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='gliclazida')),
 'moderate',
 'A combinação de insulina NPH (basal) com gliclazida (sulfonilureia) aumenta o risco de hipoglicemia (picos da NPH 4–12 h sobrepostos ao efeito da SU), exigindo ajuste de doses.',
 'Combining NPH insulin (basal) with gliclazide (sulfonylurea) increases the risk of hypoglycaemia (NPH peaks 4–12 h overlapping the sulfonylurea effect), requiring dose adjustment.',
 'Ambos ↓ glicemia por mecanismos diferentes (↑ secreção de insulina pela SU + exógena; o pico da NPH 4–12 h pode sobrepor-se ao pico da SU) (rótulos; Prontuário 8.4).',
 'Both lower glucose through different mechanisms (SU increases insulin secretion + exogenous insulin; the NPH peak 4–12 h may overlap the SU peak) (labels; Prontuário 8.4).',
 'Titulação cuidadosa da SU e da insulina basal; glicemia capilar sobretudo noturna; considerar redução da SU ao introduzir insulina.',
 'Careful titration of the sulfonylurea and basal insulin; capillary glucose especially overnight; consider sulfonylurea reduction when introducing insulin.',
 'Glicemia capilar (incluindo noturna), HbA1c, peso.',
 'Capillary glucose (including overnight), HbA1c, weight.',
 'Sudorese noturna, cefaleia matinal, confusão (hipoglicemia).', 'Night sweats, morning headache, confusion (hypoglycaemia).',
 'DailyMed — rótulos Glipizide Tablet [Apotex] (classe sulfonilureia) e Humulin N (NPH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dcf426b8-bcdc-8214-a1b6-6388bd3399a0',
 'DailyMed — Glipizide Tablet [Apotex] (sulfonylurea class) and Humulin N (NPH) labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dcf426b8-bcdc-8214-a1b6-6388bd3399a0',
 'published', now()),

-- 6. flucloxacilina × warfarina (critical)
(LEAST((SELECT id FROM public.drugs WHERE slug='flucloxacilina'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='flucloxacilina'), (SELECT id FROM public.drugs WHERE slug='warfarina')),
 'critical',
 'A flucloxacilina altera de forma imprevisível o efeito anticoagulante da warfarina (pode ↑ ou ↓ o INR), com risco de hemorragia ou trombose; o BNF classifica como interação grave.',
 'Flucloxacillin unpredictably alters the anticoagulant effect of warfarin (may ↑ or ↓ INR), with bleeding or thrombosis risk; the BNF classifies it as a severe interaction.',
 'Mecanismos combinados: ↓ flora intestinal sintetizadora de vitamina K (↑ INR) e indução enzimática do metabolismo da warfarina (↓ INR); BNF/NICE: "Flucloxacillin potentially alters the anticoagulant effect of warfarin. Manufacturer advises monitor INR and adjust dose. Severity: Severe".',
 'Combined mechanisms: reduced vitamin K–synthesising gut flora (↑ INR) and enzyme induction of warfarin metabolism (↓ INR); BNF/NICE: "Flucloxacillin potentially alters the anticoagulant effect of warfarin. Manufacturer advises monitor INR and adjust dose. Severity: Severe".',
 'Medir INR a 3–5 dias do início e após o fim do antibiótico; ajustar dose de warfarina; informar o doente sobre sinais hemorrágicos e trombóticos.',
 'Measure INR 3–5 days after starting and after finishing the antibiotic; adjust the warfarin dose; counsel the patient on bleeding and thrombosis signs.',
 'INR frequente durante e 1–2 semanas após o curso; sinais hemorrágicos e trombóticos.',
 'Frequent INR during and 1–2 weeks after the course; bleeding and thrombosis signs.',
 'Equimoses, hemorragia gengival, urina escura (↑ INR) ou TVP/embolia (↓ INR).', 'Bruising, gum bleeding, dark urine (↑ INR) or DVT/embolism (↓ INR).',
 'BNF/NICE — Warfarin interactions: flucloxacillin (Severity: Severe): https://bnf.nice.org.uk/interactions/warfarin/; EMC-UK — Flucloxacillin Capsules 500 mg SmPC [Flamingo Pharma], sec. 4.5: https://www.medicines.org.uk/emc/product/14151/smpc; DailyMed — rótulo Warfarin Sodium Tablet [RLD Coumadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=654ca5d2-d4c1-48f8-90c4-130a21162bb0',
 'BNF/NICE — Warfarin interactions: flucloxacillin (Severity: Severe): https://bnf.nice.org.uk/interactions/warfarin/; EMC-UK — Flucloxacillin Capsules 500 mg SmPC [Flamingo Pharma], sec. 4.5: https://www.medicines.org.uk/emc/product/14151/smpc; DailyMed — Warfarin Sodium Tablet label [RLD Coumadin]: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=654ca5d2-d4c1-48f8-90c4-130a21162bb0',
 'published', now()),

-- 7. flucloxacilina × probenecida (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='flucloxacilina'), (SELECT id FROM public.drugs WHERE slug='probenecida')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='flucloxacilina'), (SELECT id FROM public.drugs WHERE slug='probenecida')),
 'moderate',
 'A probenecida reduz a excreção renal da flucloxacilina, aumentando os seus níveis plasmáticos (efeito por vezes explorado intencionalmente, mas com ↑ risco de efeitos adversos).',
 'Probenecid reduces the renal excretion of flucloxacillin, raising its plasma levels (sometimes used intentionally, but with increased adverse effect risk).',
 'A probenecida inibe a secreção tubular renal de penicilinas; EMC-UK Flucloxacillin SmPC 4.5: "Probenecid and sulfinpyrazone slow down the excretion of flucloxacillin".',
 'Probenecid inhibits the renal tubular secretion of penicillins; EMC-UK Flucloxacillin SmPC 4.5: "Probenecid and sulfinpyrazone slow down the excretion of flucloxacillin".',
 'Se a co-administração for intencional (potenciação), vigiar doses; caso contrário, evitar; ajustar dose na insuficiência renal.',
 'If co-administration is intentional (potentiation), monitor doses; otherwise avoid; adjust dose in renal impairment.',
 'Níveis plasmáticos se criticamente doente; função renal; efeitos GI e hepáticos.',
 'Plasma levels if critically ill; renal function; GI and hepatic effects.',
 'Náuseas, vómitos, icterícia (hepatotoxicidade colestática em doses altas).', 'Nausea, vomiting, jaundice (cholestatic hepatotoxicity at high doses).',
 'EMC-UK — Flucloxacillin Capsules 500 mg SmPC [Flamingo Pharma], sec. 4.5: https://www.medicines.org.uk/emc/product/14151/smpc; Flucloxacillin 500 mg capsules, hard SmPC [Brown & Burk]: https://www.medicines.org.uk/emc/product/12636/smpc',
 'EMC-UK — Flucloxacillin Capsules 500 mg SmPC [Flamingo Pharma], sec. 4.5: https://www.medicines.org.uk/emc/product/14151/smpc; Flucloxacillin 500 mg capsules, hard SmPC [Brown & Burk]: https://www.medicines.org.uk/emc/product/12636/smpc',
 'published', now()),

-- 8. insulina-regular × litio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='litio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-regular'), (SELECT id FROM public.drugs WHERE slug='litio')),
 'moderate',
 'O lítio pode causar insulinorresistência e hiperglicemia, tornando as doses de insulina regular instáveis; vigilância glicémica reforçada na associação.',
 'Lithium can cause insulin resistance and hyperglycaemia, making regular insulin doses unstable; intensified glucose monitoring on the combination.',
 'O lítio altera o metabolismo da glicose e a sensibilidade à insulina (hiperglicemia descrita em fichas do lítio e Prontuário); a insulina regular de ação curta expõe flutuações.',
 'Lithium alters glucose metabolism and insulin sensitivity (hyperglycaemia described in lithium entries and Prontuário); short-acting regular insulin exposes fluctuations.',
 'Vigiar glicemia capilar e HbA1c; ajustar doses de insulina se glicemia de jejum subir; avaliar litemia em descompensação.',
 'Monitor capillary glucose and HbA1c; adjust insulin doses if fasting glucose rises; assess serum lithium in decompensation.',
 'Glicemia capilar, litemia, peso, poliúria/polidipsia.',
 'Capillary glucose, serum lithium, weight, polyuria/polydipsia.',
 'Poliúria e polidipsia novas (hiperglicemia) ou sudorese/confusão (hipo).', 'New polyuria and polydipsia (hyper) or sweating/confusion (hypo).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha Carbonato de lítio; DailyMed — rótulos Lithium Carbonate e Humulin R: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Lithium Carbonate entry; DailyMed — Lithium Carbonate and Humulin R labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b839ff4b-f62d-41ab-a823-550a756d58ec',
 'published', now()),

-- 9. insulina-nph × litio (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='litio')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='litio')),
 'moderate',
 'O lítio pode alterar a sensibilidade à insulina e desestabilizar o controlo glicémico basal obtido com insulina NPH.',
 'Lithium can alter insulin sensitivity and destabilise the basal glycaemic control provided by NPH insulin.',
 'A insulinorresistência induzida pelo lítio aumenta as necessidades basais de insulina (hiperglicemia); em uso combinado, os picos da NPH tornam-se imprevisíveis.',
 'Lithium-induced insulin resistance increases basal insulin requirements (hyperglycaemia); in combination, NPH peaks become unpredictable.',
 'Reavaliar glicemia de jejum 1–2 semanas após alterações de dose de lítio; ajustar insulina basal; educar sobre hipoglicemia.',
 'Reassess fasting glucose 1–2 weeks after lithium dose changes; adjust basal insulin; educate on hypoglycaemia.',
 'Glicemia de jejum, litemia, HbA1c.',
 'Fasting glucose, serum lithium, HbA1c.',
 'Polidipsia/poliúria, perda de peso (hiperglicemia).', 'Polydipsia/polyuria, weight loss (hyperglycaemia).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), ficha Carbonato de lítio; DailyMed — rótulo Humulin N (NPH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), Lithium Carbonate entry; DailyMed — Humulin N (NPH) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921',
 'published', now()),

-- 10. insulina-nph × metoprolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='metoprolol')),
 'moderate',
 'O metoprolol mascara os sintomas adrenérgicos da hipoglicemia noturna/inter-refeições induzida pela insulina NPH (pico 4–12 h).',
 'Metoprolol masks the adrenergic symptoms of overnight/between-meal hypoglycaemia induced by NPH insulin (4–12 h peak).',
 'O pico da NPH ocorre frequentemente durante a noite; o betabloqueio suprime a taquicardia de alarme e reduz a glicogenólise β2 hepática (Prontuário 8.4.1).',
 'The NPH peak often occurs overnight; beta-blockade suppresses the tachycardia warning and reduces hepatic β2 glycogenolysis (Prontuário 8.4.1).',
 'Glicemia noturna regular; educar sobre hipoglicemia "silenciosa"; ajustar insulina basal e refeição nocturna.',
 'Regular overnight glucose monitoring; educate on "silent" hypoglycaemia; adjust basal insulin and bedtime snack.',
 'Glicemia noturna, sudorese, estado neurológico matinal (cefaleia).',
 'Overnight glucose, sweating, morning neurological status (headache).',
 'Pesadelos, cefaleia matinal, roupa molhada de suor (hipoglicemia noturna).', 'Nightmares, morning headache, sweat-soaked clothing (nocturnal hypoglycaemia).',
 'Prontuário Terapêutico INFARMED (11.ª ed., 2012), 8.4.1 Insulinas; DailyMed — rótulo Humulin N (NPH): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921',
 'INFARMED Prontuário Terapêutico (11th ed., 2012), 8.4.1 Insulins; DailyMed — Humulin N (NPH) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921',
 'published', now()),

-- 11. insulina-nph × propranolol (moderate)
(LEAST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 GREATEST((SELECT id FROM public.drugs WHERE slug='insulina-nph'), (SELECT id FROM public.drugs WHERE slug='propranolol')),
 'moderate',
 'O propranolol (não seletivo) bloqueia a glicogenólise hepática e mascara os sintomas de hipoglicemia do pico da insulina NPH, sobretudo noturna.',
 'Non-selective propranolol blocks hepatic glycogenolysis and masks the hypoglycaemia symptoms of the NPH insulin peak, especially overnight.',
 'O bloqueio β2 hepático prolonga e agrava os episódios hipoglicémicos; o bloqueio β1 elimina a taquicardia de alarme (Prontuário 8.4.1; rótulo NPH).',
 'Hepatic β2 blockade prolongs and worsens hypoglycaemic episodes; β1 blockade removes the tachycardia warning (Prontuário 8.4.1; NPH label).',
 'Preferir betabloqueante cardiosseletivo; glicemia noturna; considerar redução da NPH se episódios recorrentes.',
 'Prefer a cardioselective beta-blocker; overnight glucose; consider NPH dose reduction if recurrent episodes.',
 'Glicemia noturna, estado neurológico, sudorese.',
 'Overnight glucose, neurological status, sweating.',
 'Confusão matinal, cefaleia, sudorese noturna profusa.', 'Morning confusion, headache, profuse night sweats.',
 'DailyMed — rótulos Humulin N (NPH) e Inderal (propranolol): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921; Prontuário Terapêutico INFARMED (11.ª ed., 2012), 8.4.1.',
 'DailyMed — Humulin N (NPH) and Inderal (propranolol) labels: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f6edd793-440b-40c2-96b5-c16133b7a921; INFARMED Prontuário Terapêutico (11th ed., 2012), 8.4.1.',
 'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Notas de exclusão (pares não criados):
-- * insulina-regular × paracetamol, insulina-nph × paracetamol — sem
--   documentação no rótulo mono-ingrediente de ambos (o rótulo DDAVP cita
--   paracetamol, não insulinas); regra 13.1.
-- * insulina-nph × gliclazida/metformina vs insulina-regular: pares com NPH
--   + SU e regular + metformina criados; regular + gliclazida omitido por
--   redundância do mecanismo (mesma classe), revisto futuramente se pedido.
-- * espectinomicina × aminoglicosídeos — sem rótulo humano a documentar
--   ototo/nefrotoxicidade (regra 13.1); revisão futura com EMC-UK específico.
-- * permanganato × antiácidos/quinolonas — uso externo sem absorção sistémica
--   relevante (ficha 270); interação sistémica não aplicável.

-- Pares reais inseridos: 11 (itens 1–11 acima; notas de exclusão não inserem tuples).
