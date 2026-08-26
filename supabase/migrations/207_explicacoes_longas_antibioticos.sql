-- =====================================================================
-- 207 — Explicações longas dos pares antibióticos (Fluxo 4)
--
-- Pares: critical (2) + moderate (5) da migração 206
-- Formato: summary_pro (resumo técnico) + explanation PT/EN
-- Fontes: DailyMed/FDA, EMC-UK
-- =====================================================================

-- =====================================================================
-- 1. Pares CRÍTICOS
-- =====================================================================

-- 1.1 telitromicina × simvastatina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Cetolida + estatina: CYP3A4 inibido, simvastatina ~10x. Miopatia/rabdomiólise grave. EVITAR.',
    summary_pro_en = 'Ketolide + statin: CYP3A4 inhibited, simvastatin ~10-fold. Severe myopathy/rhabdomyolysis. AVOID.',
    explanation_pt = 'A telitromicina inibe moderadamente o CYP3A4, a principal via metabólica da simvastatina (ácido 3-hidroxi-3-metilglutaril-CoA redutase). O aumento dos níveis de simvastatina pode ser até 10x, excedendo o limiar de toxicidade muscular. A miopatia pode progredir para rabdomiólise com falência renal aguda. Risco particularmente elevado em: (1) doses altas de simvastatina (>20 mg), (2) idade >65 anos, (3) doença renal/hepática concomitante, (4) hipotireoidismo. Estratégia: suspender simvastatina durante 5-7 dias de telitromicina. Alternativa segura: pravastatina (não é substrato CYP3A4).',
    explanation_en = 'Telithromycin moderately inhibits CYP3A4, the main metabolic pathway for simvastatin (HMG-CoA reductase). Increased simvastatin levels may reach ~10-fold, exceeding the muscle toxicity threshold. Myopathy may progress to rhabdomyolysis with acute renal failure. Particularly elevated risk with: (1) high simvastatin doses (>20 mg), (2) age >65, (3) concomitant renal/hepatic disease, (4) hypothyroidism. Strategy: discontinue simvastatin for 5-7 days during telithromycin. Safe alternative: pravastatin (not a CYP3A4 substrate).',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Telitromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Telithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'telitromicina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'simvastatina');

-- 1.2 telitromicina × warfarina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Cetolida + anticoagulante: CYP2C9 inibido, INR 2-3x. Hemorragia grave.',
    summary_pro_en = 'Ketolide + anticoagulant: CYP2C9 inhibited, INR 2-3-fold. Serious haemorrhage.',
    explanation_pt = 'A telitromicina inibe o CYP2C9, a principal enzima metabólica da warfarina S-enantiómetro (mais potente). O aumento dos níveis de warfarina pode elevar o INR 2-3x, excedendo o intervalo terapêutico. Risco de hemorragia gastrointestinal, intracraniana ou urinária. Estudos farmacocinéticos mostram AUC da warfarina aumentada 130% com telitromicina. Estratégia: se inevitável, reduzir dose de warfarina 25-50% e monitorizar INR diariamente durante antibioticoterapia e 1 semana após.',
    explanation_en = 'Telithromycin inhibits CYP2C9, the main metabolic enzyme for warfarin S-enantiomer (more potent). Increased warfarin levels may elevate INR 2-3-fold, exceeding the therapeutic range. Risk of gastrointestinal, intracranial, or urinary haemorrhage. Pharmacokinetic studies show warfarin AUC increased 130% with telithromycin. Strategy: if unavoidable, reduce warfarin dose by 25-50% and monitor INR daily during antibiotic therapy and 1 week after.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Telitromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Telithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ba1cca98-f350-4655-88e3-6ef990779fb9'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'telitromicina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'warfarina');

-- =====================================================================
-- 2. Pares MODERADOS
-- =====================================================================

-- 2.1 sulfametoxazol-trimetoprima × warfarina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Sulfonamida + anticoagulante: CYP2C9 inibido + deslocamento proteico. INR 1,5-2x.',
    summary_pro_en = 'Sulfonamide + anticoagulant: CYP2C9 inhibited + protein displacement. INR 1.5-2-fold.',
    explanation_pt = 'O sulfametoxazol inibe moderadamente o CYP2C9 e desloca a warfarina das proteínas plasmáticas (ligação ~99%). A trimetoprima contribui pouco para esta interação. O aumento do INR é geralmente de 1,5-2x, significativo mas raramente catastrófico. Risco maior em idosos (comorbilidades, polifarmácia) e doentes com CYP2C9 variante (metabolizadores lentos). Monitorização: INR 2-3x/semana na primeira semana, depois semanal.',
    explanation_en = 'Sulfamethoxazole moderately inhibits CYP2C9 and displaces warfarin from plasma proteins (~99% bound). Trimethoprim contributes little to this interaction. INR increase is usually 1.5-2-fold, significant but rarely catastrophic. Higher risk in the elderly (comorbidities, polypharmacy) and patients with CYP2C9 variant (poor metabolisers). Monitoring: INR 2-3 times/week in the first week, then weekly.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Bactrim label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'sulfametoxazol-trimetoprima')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'warfarina');

-- 2.2 sulfametoxazol-trimetoprima × metformina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Sulfonamida + biguanida: hipoglicemia, hipercalemia, redução TFG. Monitorizar.',
    summary_pro_en = 'Sulfonamide + biguanide: hypoglycaemia, hyperkalaemia, reduced GFR. Monitor.',
    explanation_pt = 'A combinação apresenta três mecanismos de risco: (1) Hipoglicemia — trimetoprima pode sensibilizar células beta pancreáticas (mecanismo parcialmente elucidado). (2) Hipercalemia — trimetoprima bloqueia canais ENaC renais (efeito semelhante a amilorida). (3) Redução da TFG — desidratação por efeito diurético aditivo. Risco particularmente elevado em: idosos, TFG basal <60, uso concomitante de IECA/BRA/diuréticos poupadores de potássio. Estratégia: monitorizar glicemia (2x/dia na primeira semana), potássio (semanal) e creatinina (quinzenal).',
    explanation_en = 'The combination presents three risk mechanisms: (1) Hypoglycaemia — trimethoprim may sensitise pancreatic beta cells (partially elucidated mechanism). (2) Hyperkalaemia — trimethoprim blocks renal ENaC channels (similar to amiloride effect). (3) Reduced GFR — dehydration from additive diuretic effect. Particularly elevated risk in: the elderly, baseline eGFR <60, concomitant ACE inhibitor/ARB/potassium-sparing diuretic use. Strategy: monitor blood glucose (twice daily in the first week), potassium (weekly), and creatinine (fortnightly).',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Bactrim: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Bactrim label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f59d0c04-9c66-4d53-a0e1-cb55570deb62'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'sulfametoxazol-trimetoprima')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'metformina');

-- 2.3 clindamicina × eritromicina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Lincosamida + macrólido: antagonismo — competição pela subunidade 50S. Evitar.',
    summary_pro_en = 'Lincosamide + macrolide: antagonism — competition for 50S subunit. Avoid.',
    explanation_pt = 'Clindamicina e eritromicina competem pelo mesmo sítio de ligação na subunidade 50S do ribossomo 70S bacteriano. A eritromicina (macrólido) é bacteriostática e pode reduzir a eficácia bactericida da clindamicina em situações onde a atividade depende da concentração (combinação sinérgica). Exceção documentada: em Pneumocystis jirovecii, a combinação pode ter sinergismo (ambos inibem a síntese proteica em locais diferentes). Na prática clínica convencional, a combinação é evitada.',
    explanation_en = 'Clindamycin and erythromycin compete for the same binding site on the 70S bacterial ribosomal 50S subunit. Erythromycin (macrolide) is bacteriostatic and may reduce the bactericidal efficacy of clindamycin in concentration-dependent situations (synergistic combination). Documented exception: in Pneumocystis jirovecii, the combination may have synergy (both inhibit protein synthesis at different sites). In conventional clinical practice, the combination is avoided.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clindamicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Clindamycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3f6b2c5a-e581-414f-bc9e-eaf66a5685cd'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'clindamicina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'eritromicina');

-- 2.4 penicilina-g × probenecida
UPDATE public.drug_interactions
SET summary_pro_pt = 'Penicilina + uricosúrico: níveis penicilina ~2x via bloqueio secreção tubular.',
    summary_pro_en = 'Penicillin + uricosuric: penicillin levels ~2x via tubular secretion blockade.',
    explanation_pt = 'O probenecida bloqueia a secreção tubular renal da penicilina via transporte OAT1/OAT3, aumentando os níveis séricos em ~2x e prolongando a meia-vida de 30 min para ~6 h. Historicamente, esta interação era usada intencionalmente (era pré-antibiótica) para prolongar a ação da penicilina. Atualmente, a combinação é rara, mas pode ser considerada em: (1) sífilis neurosifilis (quando não há acesso a ceftriaxona IV), (2) endocardite por enterococos (terapia de combinação).',
    explanation_en = 'Probenecid blocks renal tubular secretion of penicillin via OAT1/OAT3 transporters, increasing serum levels ~2x and prolonging half-life from 30 min to ~6 h. Historically, this interaction was used intentionally (pre-antibiotic era) to prolong penicillin action. Currently, the combination is rare, but may be considered in: (1) neurosyphilis (when IV ceftriaxone is unavailable), (2) enterococcal endocarditis (combination therapy).',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilina G: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Penicillin G label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9e58122f-5c75-4905-a774-d3a4dae4ff8c'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'penicilina-g')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'probenecida');

-- 2.5 aciclovir × probenecida
UPDATE public.drug_interactions
SET summary_pro_pt = 'Antivírico + uricosúrico: aciclovir ~40% via bloqueio secreção tubular.',
    summary_pro_en = 'Antiviral + uricosuric: acyclovir ~40% via tubular secretion blockade.',
    explanation_pt = 'O probenecida bloqueia a secreção tubular renal do aciclovir via transportadores OAT1/OAT3, aumentando os níveis séricos em ~40% e prolongando a meia-vida. Embora o aumento seja moderado, o aciclovir tem um índice terapêutico estreto — a nefrotoxicidade (cristais tubulares) pode ser precipitada. Estratégia: se coadministração necessária, reduzir dose de aciclovir 50% e aumentar hidratação oral para >2 L/dia. Monitorizar creatinina e volume urinário.',
    explanation_en = 'Probenecid blocks renal tubular secretion of acyclovir via OAT1/OAT3 transporters, increasing serum levels by ~40% and prolonging half-life. Although the increase is moderate, acyclovir has a narrow therapeutic index — nephrotoxicity (tubular crystals) may be precipitated. Strategy: if coadministration necessary, reduce acyclovir dose by 50% and increase oral hydration to >2 L/day. Monitor creatinine and urine volume.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Aciclovir: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Acyclovir label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb64dfab-52ee-4312-bc9c-c3d04efe9109'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'aciclovir')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'probenecida');
