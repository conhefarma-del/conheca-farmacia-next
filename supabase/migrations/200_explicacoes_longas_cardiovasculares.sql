-- =====================================================================
-- 200 — Explicações longas dos pares cardiovasculares (Fluxo 4)
--
-- Pares: critical (11) + moderate (11) da migração 199
-- Formato: summary_pro (resumo técnico) + explanation PT/EN
-- Fontes: DailyMed/FDA, EMC-UK, Prontuário Terapêutico
-- =====================================================================

-- =====================================================================
-- 1. Pares CRÍTICOS
-- =====================================================================

-- 1.1 lisinopril × espironolactona
UPDATE public.drug_interactions
SET summary_pro_pt = 'Inibidor ECA + espironolactona (poupador de K+): risco grave de hipercalemia. Ambos reduzem a excreção renal de potássio. Monitorizar K+ e TFG semanalmente nas primeiras 4 semanas, depois mensalmente.',
    summary_pro_en = 'ACE inhibitor + spironolactone (K+-sparing): serious hyperkalaemia risk. Both reduce renal K+ excretion. Monitor K+ and GFR weekly for first 4 weeks, then monthly.',
    explanation_pt = 'O lisinopril inibe a ECA, reduzindo a angiotensina II e a secreção de aldosterona. A espironolactona bloqueia o recetor mineralocorticoide, impedindo a ação da aldosterona residual. A dupla redução da secreção de aldosterona resulta em retenção significativa de potássio. O risco é especialmente elevado em doentes com insuficiência renal (TFG <60 mL/min), diabetes, ou idosos. A combinação é utilizada terapeuticamente na IC severa (estudo RALES — 30% redução de mortalidade), mas requer monitorização rigorosa. Se K+ >5,5 mEq/L, reduzir a dose de ambos ou suspender o poupador de potássio.',
    explanation_en = 'Lisinopril inhibits ACE, reducing angiotensin II and aldosterone secretion. Spironolactone blocks the mineralocorticoid receptor, preventing action of residual aldosterone. The dual reduction of aldosterone secretion results in significant potassium retention. Risk is especially elevated in patients with renal impairment (GFR <60 mL/min), diabetes, or elderly. The combination is used therapeutically in severe HF (RALES trial — 30% mortality reduction), but requires close monitoring. If K+ >5,5 mEq/L, reduce doses or discontinue K+-sparing agent.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Lisinopril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e6898cf8-34c8-44d5-8a86-fbe3be847b16',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Lisinopril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e6898cf8-34c8-44d5-8a86-fbe3be847b16'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'lisinopril')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'espironolactona');

-- 1.2 losartana × espironolactona
UPDATE public.drug_interactions
SET summary_pro_pt = 'BRA + espironolactona (poupador de K+): risco grave de hipercalemia. Mecanismo idêntico ao IECA + espironolactona. Monitorizar K+ e TFG.',
    summary_pro_en = 'ARB + spironolactone (K+-sparing): serious hyperkalaemia risk. Identical mechanism to ACE inhibitor + spironolactone. Monitor K+ and GFR.',
    explanation_pt = 'A losartana bloqueia o recetor AT1 da angiotensina II, reduzindo a secreção de aldosterona. A espironolactona bloqueia o recetor mineralocorticoide. A dupla inibição da via aldosterona causa retenção significativa de potássio. O risco é comparável ao da combinação IECA + espironolactona. Monitorizar K+ e TFG regularmente. A combinação pode ser utilizada na IC severa com monitorização rigorosa.',
    explanation_en = 'Losartan blocks the angiotensin II AT1 receptor, reducing aldosterone secretion. Spironolactone blocks the mineralocorticoid receptor. Dual inhibition of the aldosterone pathway causes significant potassium retention. Risk is comparable to ACE inhibitor + spironolactone combination. Monitor K+ and GFR regularly. Combination may be used in severe HF with close monitoring.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Losartana: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1dadbe02-289c-4312-9e65-40f3314dcc31',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Losartan label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1dadbe02-289c-4312-9e65-40f3314dcc31'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'losartana')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'espironolactona');

-- 1.3 nifedipina × sildenafil
UPDATE public.drug_interactions
SET summary_pro_pt = 'BCC + inibidor da PDE5: hipotensão severa potencialmente fatal. Ambos causam vasodilatação. Se indispensável, reduzir dose de sildenafil para 25 mg e monitorizar PA.',
    summary_pro_en = 'CCB + PDE5 inhibitor: potentially fatal severe hypotension. Both cause vasodilation. If essential, reduce sildenafil to 25 mg and monitor BP.',
    explanation_pt = 'A nifedipina bloqueia os canais de cálcio tipo L vascular, causando vasodilatação. O sildenafil inibe a PDE5, elevando o GMPc e potenciando a vasodilatação mediada por NO. A combinação sinérgica pode causar hipotensão severa e sintomática (PA sistólica <90 mmHg). O risco é maior em doentes idosos, desidratados ou em terapia anti-hipertensiva múltipla. Se a combinação for indispensável, reduzir a dose de sildenafil para 25 mg e monitorizar a PA frequentemente.',
    explanation_en = 'Nifedipine blocks vascular L-type calcium channels, causing vasodilation. Sildenafil inhibits PDE5, raising cGMP and potentiating NO-mediated vasodilation. The synergistic combination can cause severe symptomatic hypotension (systolic BP <90 mmHg). Risk is higher in elderly, dehydrated patients, or those on multiple antihypertensives. If combination is essential, reduce sildenafil to 25 mg and monitor BP frequently.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Nifedipina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8b8cfee-ea71-44c2-81af-675efecfdf15',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Nifedipine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8b8cfee-ea71-44c2-81af-675efecfdf15'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'nifedipina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'sildenafil');

-- 1.4 metoprolol × amiodarona
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador + antiarrítmico classe III: bradicardia severa e bloqueio AV. Ambos deprimem a condução AV. Monitorizar ECG e frequência cardíaca.',
    summary_pro_en = 'Beta-blocker + class III antiarrhythmic: severe bradycardia and AV block. Both depress AV conduction. Monitor ECG and heart rate.',
    explanation_pt = 'O metoprolol bloqueia os recetores β1 cardíacos, reduzindo a frequência cardíaca e a condução AV. A amiodarona tem efeitos de classe I, II, III e IV — deprime adicionalmente a condução AV e prolonga o período refratário. A combinação pode causar bradicardia sintomática (<50 bpm), bloqueio AV de 2º grau, ou bloqueio completo. O risco é especialmente elevado em doentes com doença do nó sinusal ou bloqueio AV pré-existente. Reduzir a dose de betabloqueador e monitorizar ECG.',
    explanation_en = 'Metoprolol blocks cardiac beta-1 receptors, reducing heart rate and AV conduction. Amiodarone has class I, II, III, and IV effects — additionally depressing AV conduction and prolonging refractory period. The combination can cause symptomatic bradycardia (<50 bpm), second-degree AV block, or complete heart block. Risk is especially elevated in patients with sinus node disease or pre-existing AV block. Reduce beta-blocker dose and monitor ECG.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metoprolol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5466243e-1e3d-175e-e063-6394a90a5dee',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Metoprolol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5466243e-1e3d-175e-e063-6394a90a5dee'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'metoprolol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'amiodarona');

-- 1.5 metoprolol × verapamilo
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador + BCC não diidropiridínico: bloqueio AV severo, bradicardia e insuficiência cardíaca. CONTRAINDICADO em doentes com bloqueio AV ou disfunção ventricular.',
    summary_pro_en = 'Beta-blocker + non-dihydropyridine CCB: severe AV block, bradycardia, and heart failure. CONTRAINDICATED in patients with AV block or ventricular dysfunction.',
    explanation_pt = 'O metoprolol e o verapamilo deprimem sinérgicamente a condução AV e a contractilidade miocárdica. O verapamilo bloqueia os canais de cálcio cardíacos (nó AV, miocárdio), enquanto o metoprolol bloqueia os recetores β1. A combinação pode causar bloqueio AV de alto grau, parada sinusal, ou insuficiência cardíaca aguda. CONTRAINDICADO em doentes com bloqueio AV de 2º ou 3º grau, síndrome do nó sinusal, ou IC descompensada.',
    explanation_en = 'Metoprolol and verapamil synergistically depress AV conduction and myocardial contractility. Verapamil blocks cardiac calcium channels (AV node, myocardium), while metoprolol blocks beta-1 receptors. The combination can cause high-grade AV block, sinus arrest, or acute heart failure. CONTRAINDICATED in patients with 2nd or 3rd degree AV block, sinus node syndrome, or decompensated HF.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metoprolol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5466243e-1e3d-175e-e063-6394a90a5dee',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Metoprolol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5466243e-1e3d-175e-e063-6394a90a5dee'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'metoprolol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'verapamilo');

-- 1.6 propranolol × verapamilo
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador não seletivo + BCC não diidropiridínico: bloqueio AV severo e parada cardíaca. CONTRAINDICADO — risco de morte.',
    summary_pro_en = 'Non-selective beta-blocker + non-dihydropyridine CCB: severe AV block and cardiac arrest. CONTRAINDICATED — risk of death.',
    explanation_pt = 'O propranolol (não seletivo β1+β2) e o verapamilo deprimem profundamente a condução AV e a contractilidade. O propranolol adiciona bloqueio β2 (broncoespasmo) ao efeito depressor do verapamilo. A combinação pode causar bloqueio AV completo, parada sinusal, colapso cardiovascular e morte. CONTRAINDICADO absolutamente — não existe dose segura desta combinação.',
    explanation_en = 'Propranolol (non-selective beta-1+beta-2) and verapamil profoundly depress AV conduction and contractility. Propranolol adds beta-2 blockade (bronchospasm) to verapamil''s depressant effect. The combination can cause complete AV block, sinus arrest, cardiovascular collapse, and death. Absolutely CONTRAINDICATED — no safe dose exists for this combination.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Propranolol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d5ac315-df2b-4b3a-bc7e-ad04752865c4',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Propranolol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d5ac315-df2b-4b3a-bc7e-ad04752865c4'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'propranolol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'verapamilo');

-- 1.7 rosuvastatina × ciclosporina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Estatina + imunossupressor: AUC da rosuvastatina aumentada ~7x. Risco extremo de miopatia e rabdomiólise. Dose máxima: 5 mg/dia de rosuvastatina.',
    summary_pro_en = 'Statin + immunosuppressant: rosuvastatin AUC increased ~7-fold. Extreme risk of myopathy and rhabdomyolysis. Maximum dose: 5 mg/day rosuvastatin.',
    explanation_pt = 'A ciclosporina inibe o transportador de influxo de estatinas (OATP1B1) no fígado, aumentando significativamente os níveis plasmáticos de rosuvastatina. A AUC aumenta aproximadamente 7 vezes. Níveis elevados de estatinas causam toxicidade muscular — miopatia (dor muscular, elevação de CK >10x o normal) e rabdomiólise (destruição muscular com mioglobinúria e insuficiência renal aguda). Se a combinação for indispensável, limitar a rosuvastatina a 5 mg/dia e monitorizar CK semanalmente.',
    explanation_en = 'Ciclosporin inhibits the statin influx transporter (OATP1B1) in the liver, significantly increasing rosuvastatin plasma levels. AUC increases approximately 7-fold. Elevated statin levels cause muscular toxicity — myopathy (muscle pain, CK elevation >10x normal) and rhabdomyolysis (muscle destruction with myoglobinuria and acute renal failure). If combination is essential, limit rosuvastatin to 5 mg/day and monitor CK weekly.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Rosuvastatina (Crestor): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=325a5d0e-9a72-4015-9fcd-1655fb504cee',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Rosuvastatin (Crestor) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=325a5d0e-9a72-4015-9fcd-1655fb504cee'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'rosuvastatina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'ciclosporina');

-- 1.8 simvastatina × cetoconazol
UPDATE public.drug_interactions
SET summary_pro_pt = 'Estatina + antifúngico azólico: CONTRAINDICADO. Cetoconazol inibe CYP3A4, aumentando níveis de simvastatina >10x. Risco extremo de rabdomiólise.',
    summary_pro_en = 'Statin + azole antifungal: CONTRAINDICATED. Ketoconazole inhibits CYP3A4, increasing simvastatin levels >10-fold. Extreme risk of rhabdomyolysis.',
    explanation_pt = 'O cetoconazol é um inibidor potente do CYP3A4. A simvastatina é um pró-fármaco metabolizado extensivamente pelo CYP3A4. A inibição do CYP3A4 pelo cetoconazol aumenta os níveis de simvastatina e do seu metabólito ativo em mais de 10 vezes. Níveis tão elevados causam destruição muscular maciça — rabdomiólise com mioglobinúria, hipercalemia e insuficiência renal aguda potencialmente fatal. CONTRAINDICADO — não existe dose segura. Usar estatinas não metabolizadas por CYP3A4 (rosuvastatina, pravastatina).',
    explanation_en = 'Ketoconazole is a potent CYP3A4 inhibitor. Simvastatin is a prodrug extensively metabolised by CYP3A4. CYP3A4 inhibition by ketoconazole increases simvastatin and active metabolite levels more than 10-fold. Such elevated levels cause massive muscle destruction — rhabdomyolysis with myoglobinuria, hyperkalaemia, and potentially fatal acute renal failure. CONTRAINDICATED — no safe dose exists. Use statins not metabolised by CYP3A4 (rosuvastatin, pravastatin).',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Simvastatina (Zocor): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8f55d5de-5a4f-4a39-8c84-c53976dd6af9',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Simvastatin (Zocor) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8f55d5de-5a4f-4a39-8c84-c53976dd6af9'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'simvastatina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'cetoconazol');

-- 1.9 simvastatina × eritromicina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Estatina + macrólido: CONTRAINDICADO. Eritromicina inibe CYP3A4, aumentando níveis de simvastatina significativamente. Risco de miopatia e rabdomiólise.',
    summary_pro_en = 'Statin + macrolide: CONTRAINDICATED. Erythromycin inhibits CYP3A4, significantly increasing simvastatin levels. Risk of myopathy and rhabdomyolysis.',
    explanation_pt = 'A eritromicina é um inibidor moderado do CYP3A4. A combinação com simvastatina aumenta os níveis desta em 2-4 vezes. Embora o aumento seja menor que com cetoconazol, o risco de miopatia e rabdomiólise permanece significativo. A FDA suspendeu a dose de 80 mg de simvastatina precisamente devido ao risco de rabdomiólise com inibidores de CYP3A4. CONTRAINDICADO — usar azitromicina (não inibe CYP3A4) como alternativa ao macrólido.',
    explanation_en = 'Erythromycin is a moderate CYP3A4 inhibitor. Combination with simvastatin increases simvastatin levels 2-4 fold. Although the increase is less than with ketoconazole, the risk of myopathy and rhabdomyolysis remains significant. The FDA withdrew the 80 mg simvastatin dose precisely due to rhabdomyolysis risk with CYP3A4 inhibitors. CONTRAINDICATED — use azithromycin (does not inhibit CYP3A4) as macrolide alternative.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Simvastatina (Zocor): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8f55d5de-5a4f-4a39-8c84-c53976dd6af9',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Simvastatin (Zocor) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8f55d5de-5a4f-4a39-8c84-c53976dd6af9'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'simvastatina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'eritromicina');

-- 1.10 isossorbida × sildenafil
UPDATE public.drug_interactions
SET summary_pro_pt = 'Nitrato + inibidor da PDE5: CONTRAINDICADO. Hipotensão severa potencialmente fatal. Intervalo mínimo de 24h (sildenafil) ou 48h (tadalafil) entre fármacos.',
    summary_pro_en = 'Nitrate + PDE5 inhibitor: CONTRAINDICATED. Potentially fatal severe hypotension. Minimum 24-hour (sildenafil) or 48-hour (tadalafil) interval between drugs.',
    explanation_pt = 'A isossorbida é convertida em NO, que ativa a guamilato ciclase e eleva o GMPc. O sildenafil inibe a PDE5, que degrada o GMPc. A combinação resulta em acumulação massiva de GMPc, causando vasodilatação extrema e hipotensão severa (PA sistólica <70 mmHg). Esta combinação já causou mortes documentadas. O intervalo de segurança é mínimo 24h para sildenafil (meia-vida 4h) e 48h para tadalafil (meia-vida 17,5h). CONTRAINDICADO em qualquer circunstância.',
    explanation_en = 'Isosorbide is converted to NO, which activates guanylate cyclase and raises cGMP. Sildenafil inhibits PDE5, which degrades cGMP. The combination results in massive cGMP accumulation, causing extreme vasodilation and severe hypotension (systolic BP <70 mmHg). This combination has caused documented deaths. Safety interval is minimum 24 hours for sildenafil (half-life 4h) or 48 hours for tadalafil (half-life 17.5h). CONTRAINDICATED under any circumstances.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isossorbida Dinitrato: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=44ede034-1fa1-4993-9aa5-49e04fada541',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Isosorbide Dinitrate label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=44ede034-1fa1-4993-9aa5-49e04fada541'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'isossorbida')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'sildenafil');

-- 1.11 isossorbida × tadalafil
UPDATE public.drug_interactions
SET summary_pro_pt = 'Nitrato + inibidor da PDE5: CONTRAINDICADO. Hipotensão severa potencialmente fatal. Tadalafil tem meia-vida mais longa (17,5h) — intervalo mínimo de 48h.',
    summary_pro_en = 'Nitrate + PDE5 inhibitor: CONTRAINDICATED. Potentially fatal severe hypotension. Tadalafil has longer half-life (17.5h) — minimum 48-hour interval.',
    explanation_pt = 'Mecanismo idêntico ao sildenafil + isossorbida. O tadalafil tem meia-vida significativamente mais longa (17,5h vs 4h do sildenafil), o que prolonga o período de risco. O intervalo de segurança deve ser de pelo menos 48h. A vasodilatação combinada pode causar choque cardiogênico. CONTRAINDICADO em qualquer circunstância.',
    explanation_en = 'Identical mechanism to sildenafil + isosorbide. Tadalafil has a significantly longer half-life (17.5h vs 4h for sildenafil), which prolongs the risk period. Safety interval must be at least 48 hours. Combined vasodilation can cause cardiogenic shock. CONTRAINDICATED under any circumstances.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Isossorbida Dinitrato: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=44ede034-1fa1-4993-9aa5-49e04fada541',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Isosorbide Dinitrate label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=44ede034-1fa1-4993-9aa5-49e04fada541'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'isossorbida')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'tadalafil');

-- =====================================================================
-- 2. Pares MODERADOS
-- =====================================================================

-- 2.1 lisinopril × furosemida
UPDATE public.drug_interactions
SET summary_pro_pt = 'Inibidor ECA + diurético de alça: hipotensão sintomática, especialmente na primeira dose do IECA. Reduzir dose do diurético antes de iniciar IECA.',
    summary_pro_en = 'ACE inhibitor + loop diuretic: symptomatic hypotension, especially with first ACEI dose. Reduce diuretic dose before starting ACEI.',
    explanation_pt = 'A furosemida causa depleção de volume e reduz a pré-carga. O lisinopril reduz a resistência vascular periférica (pós-carga). A combinação pode causar hipotensão ortostática severa, especialmente na primeira dose do IECA ou após aumento da dose do diurético. Estratégia: reduzir ou suspender o diurético 2-3 dias antes de iniciar o IECA, depois reintroduzir gradualmente se necessário.',
    explanation_en = 'Furosemide causes volume depletion and reduces preload. Lisinopril reduces peripheral vascular resistance (afterload). The combination can cause severe orthostatic hypotension, especially with the first ACEI dose or after diuretic dose increase. Strategy: reduce or discontinue diuretic 2-3 days before starting ACEI, then reintroduce gradually if needed.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Lisinopril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e6898cf8-34c8-44d5-8a86-fbe3be847b16',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Lisinopril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e6898cf8-34c8-44d5-8a86-fbe3be847b16'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'lisinopril')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'furosemida');

-- 2.2 lisinopril × hidroclorotiazida
UPDATE public.drug_interactions
SET summary_pro_pt = 'Inibidor ECA + tiazídico: hipotensão sintomática. Combinação frequentemente utilizada terapeuticamente — iniciar com dose baixa.',
    summary_pro_en = 'ACE inhibitor + thiazide: symptomatic hypotension. Combination frequently used therapeutically — start at low dose.',
    explanation_pt = 'Mecanismo semelhante ao IECA + diurético de alça. A hidroclorotiazida é menos potente que a furosemida, mas a combinação IECA + tiazídico é uma das mais prescritas para hipertensão. O risco de hipotensão é menor, mas deve-se iniciar com doses baixas de ambos e titrar gradualmente. A combinação tem efeito aditivo na redução da PA.',
    explanation_en = 'Mechanism similar to ACE inhibitor + loop diuretic. Hydrochlorothiazide is less potent than furosemide, but ACEI + thiazide is one of the most prescribed combinations for hypertension. Hypotension risk is lower, but should start with low doses of both and titrate gradually. The combination has additive blood pressure-lowering effects.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Lisinopril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e6898cf8-34c8-44d5-8a86-fbe3be847b16',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Lisinopril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e6898cf8-34c8-44d5-8a86-fbe3be847b16'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'lisinopril')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida');

-- 2.3 losartana × ibuprofeno
UPDATE public.drug_interactions
SET summary_pro_pt = 'BRA + AINE: redução do efeito anti-hipertensivo e risco de disfunção renal. Evitar AINE crónicos com BRA.',
    summary_pro_en = 'ARB + NSAID: reduced antihypertensive effect and risk of renal dysfunction. Avoid chronic NSAIDs with ARBs.',
    explanation_pt = 'Os AINE inibem as COX-1 e COX-2, reduzindo a síntese de prostaglandinas renais (PGE2, PGI2). As prostaglandinas mantêm a vasodilatação aferente glomerular, essencial para a função renal quando a angiotensina II está reduzida (por BRA). A combinação pode causar: (1) redução do efeito anti-hipertensivo (2-8 mmHg), (2) disfunção renal aguda, (3) hipercalemia. Risco aumentado em idosos, desidratados, ou com TFG <60 mL/min.',
    explanation_en = 'NSAIDs inhibit COX-1 and COX-2, reducing renal prostaglandin synthesis (PGE2, PGI2). Prostaglandins maintain afferent glomerular vasodilation, essential for renal function when angiotensin II is reduced (by ARB). The combination may cause: (1) reduced antihypertensive effect (2-8 mmHg), (2) acute renal dysfunction, (3) hyperkalaemia. Risk increased in elderly, dehydrated patients, or those with GFR <60 mL/min.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Losartana: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1dadbe02-289c-4312-9e65-40f3314dcc31',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Losartan label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1dadbe02-289c-4312-9e65-40f3314dcc31'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'losartana')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno');

-- 2.4 nifedipina × ciclosporina
UPDATE public.drug_interactions
SET summary_pro_pt = 'BCC + imunossupressor: nifedipina aumenta níveis de ciclosporina. Monitorizar concentrações de ciclosporina e função renal.',
    summary_pro_en = 'CCB + immunosuppressant: nifedipine increases ciclosporin levels. Monitor ciclosporin concentrations and renal function.',
    explanation_pt = 'A nifedipina pode aumentar os níveis plasmáticos de ciclosporina através da inibição do metabolismo hepático e/ou transporte renal. O aumento é variável (20-50%). Níveis elevados de ciclosporina causam nefrotoxicidade, hipertensão, e neurotoxicidade. Monitorizar concentrações de ciclosporina (trough) regularmente e ajustar a dose do imunossupressor conforme necessário.',
    explanation_en = 'Nifedipine may increase ciclosporin plasma levels through inhibition of hepatic metabolism and/or renal transport. The increase is variable (20-50%). Elevated ciclosporin levels cause nephrotoxicity, hypertension, and neurotoxicity. Monitor ciclosporin trough concentrations regularly and adjust immunosuppressant dose as needed.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Nifedipina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8b8cfee-ea71-44c2-81af-675efecfdf15',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Nifedipine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b8b8cfee-ea71-44c2-81af-675efecfdf15'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'nifedipina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'ciclosporina');

-- 2.5 metoprolol × fluoxetina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador + ISRS: fluoxetina inibe CYP2D6, aumentando níveis de metoprolol 2-5x. Risco de bradicardia e hipotensão.',
    summary_pro_en = 'Beta-blocker + SSRI: fluoxetine inhibits CYP2D6, increasing metoprolol levels 2-5 fold. Risk of bradycardia and hypotension.',
    explanation_pt = 'O metoprolol é metabolizado extensivamente pelo CYP2D6. A fluoxetina e o seu metabolito norfluoxetina são inibidores potentes e prolongados do CYP2D6 (meia-vida do inhibidor: 4-16 dias). O aumento dos níveis de metoprolol pode ser de 2 a 5 vezes, causando bradicardia sintomática, hipotensão, fadiga e bloqueio AV. Considerar betabloqueador não metabolizado por CYP2D6 (atenolol, bisoprolol) ou ISRS com menor inibição de CYP2D6 (sertralina, escitalopram).',
    explanation_en = 'Metoprolol is extensively metabolised by CYP2D6. Fluoxetine and its metabolite norfluoxetine are potent, long-acting CYP2D6 inhibitors (inhibitor half-life: 4-16 days). Metoprolol level increase can be 2-5 fold, causing symptomatic bradycardia, hypotension, fatigue, and AV block. Consider a beta-blocker not metabolised by CYP2D6 (atenolol, bisoprolol) or an SSRI with less CYP2D6 inhibition (sertraline, escitalopram).',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metoprolol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5466243e-1e3d-175e-e063-6394a90a5dee',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Metoprolol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5466243e-1e3d-175e-e063-6394a90a5dee'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'metoprolol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'fluoxetina');

-- 2.6 propranolol × insulina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador não seletivo + insulina: mascaramiento de hipoglicemia. Bloqueio β2 impede taquicardia compensatória.',
    summary_pro_en = 'Non-selective beta-blocker + insulin: masking of hypoglycaemia. Beta-2 blockade prevents compensatory tachycardia.',
    explanation_pt = 'A hipoglicemia provoca libertação de adrenalina (resposta adrenérgica), causando taquicardia, tremor e sudorese — sinais que alertam o doente. O propranolol bloqueia os recetores β1 (reduzindo a taquicardia) e β2 (podendo prolongar a hipoglicemia ao inibir a glicogenólise). O doente pode não reconhecer a hipoglicemia até que seja severa (confusão, convulsões). Preferir betabloqueador cardioseletivo (metoprolol, bisoprolol) em diabéticos insulinizados.',
    explanation_en = 'Hypoglycaemia triggers adrenaline release (adrenergic response), causing tachycardia, tremor, and sweating — signs that alert the patient. Propranolol blocks beta-1 receptors (reducing tachycardia) and beta-2 receptors (potentially prolonging hypoglycaemia by inhibiting glycogenolysis). The patient may not recognise hypoglycaemia until it is severe (confusion, seizures). Prefer cardioselective beta-blockers (metoprolol, bisoprolol) in insulin-treated diabetics.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Propranolol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d5ac315-df2b-4b3a-bc7e-ad04752865c4',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Propranolol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d5ac315-df2b-4b3a-bc7e-ad04752865c4'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'propranolol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'insulina');

-- 2.7 propranolol × cimetidina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador + anti-H2: cimetidina inibe CYP, aumentando níveis de propranolol. Risco de bradicardia excessiva.',
    summary_pro_en = 'Beta-blocker + H2 blocker: cimetidine inhibits CYP, increasing propranolol levels. Risk of excessive bradycardia.',
    explanation_pt = 'A cimetidina inibe múltiplos CYP (1A2, 2D6, 3A4), reduzindo o metabolismo de primeiro passo do propranolol. A AUC pode aumentar 3-5 vezes. Usar ranitidina ou famotidina como alternativas (não inibem CYP significativamente).',
    explanation_en = 'Cimetidine inhibits multiple CYPs (1A2, 2D6, 3A4), reducing first-pass metabolism of propranolol. AUC may increase 3-5 fold. Use ranitidine or famotidine as alternatives (do not significantly inhibit CYP).',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Propranolol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d5ac315-df2b-4b3a-bc7e-ad04752865c4',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Propranolol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0d5ac315-df2b-4b3a-bc7e-ad04752865c4'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'propranolol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'cimetidina');

-- 2.8 rosuvastatina × fenofibrato
UPDATE public.drug_interactions
SET summary_pro_pt = 'Estatina + fibrato: risco aumentado de miopatia. Monitorizar CK e sintomas musculares.',
    summary_pro_en = 'Statin + fibrate: increased risk of myopathy. Monitor CK and muscle symptoms.',
    explanation_pt = 'A combinação de estatina com fenofibrato aumenta o risco de miopatia (dor muscular, fraqueza, elevação de CK). O mecanismo envolve competição na excreção biliar e inibição de transportadores. O fenofibrato é mais seguro que o gemfibrozilo com estatinas (menos inibição de glucuronização). Se indispensável, usar rosuvastatina (menor risco) e monitorizar CK mensalmente.',
    explanation_en = 'Statin + fibrate combination increases the risk of myopathy (muscle pain, weakness, CK elevation). Mechanism involves competition in biliary excretion and transporter inhibition. Fenofibrate is safer than gemfibrozil with statins (less glucuronidation inhibition). If essential, use rosuvastatin (lower risk) and monitor CK monthly.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Rosuvastatina (Crestor): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=325a5d0e-9a72-4015-9fcd-1655fb504cee',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Rosuvastatin (Crestor) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=325a5d0e-9a72-4015-9fcd-1655fb504cee'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'rosuvastatina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'fenofibrato');

-- 2.9 simvastatina × amiodarona
UPDATE public.drug_interactions
SET summary_pro_pt = 'Estatina + antiarrítmico: amiodarona pode aumentar níveis de simvastatina. Dose máxima: 20 mg/dia de simvastatina.',
    summary_pro_en = 'Statin + antiarrhythmic: amiodarone may increase simvastatin levels. Maximum dose: 20 mg/day simvastatin.',
    explanation_pt = 'A amiodarona pode inibir parcialmente o CYP3A4, aumentando os níveis de simvastatina. O risco de miopatia é moderado mas significativo. A FDA recomenda limitar a simvastatina a 20 mg/dia quando coadministrada com amiodarona. Monitorizar CK e sinais de toxicidade muscular.',
    explanation_en = 'Amiodarone may partially inhibit CYP3A4, increasing simvastatin levels. Risk of myopathy is moderate but significant. The FDA recommends limiting simvastatin to 20 mg/day when coadministered with amiodarone. Monitor CK and signs of muscle toxicity.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Simvastatina (Zocor): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8f55d5de-5a4f-4a39-8c84-c53976dd6af9',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Simvastatin (Zocor) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8f55d5de-5a4f-4a39-8c84-c53976dd6af9'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'simvastatina')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'amiodarona');

-- 2.10 carvedilol × insulina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador α/β + insulina: mascaramiento de hipoglicemia. Bloqueio β2 impede taquicardia compensatória.',
    summary_pro_en = 'Alpha/beta blocker + insulin: masking of hypoglycaemia. Beta-2 blockade prevents compensatory tachycardia.',
    explanation_pt = 'Mecanismo semelhante ao propranolol + insulina. O carvedilol bloqueia β1 e β2, impedindo a taquicardia compensatória da hipoglicemia. No entanto, a atividade bloqueadora α1 pode mascarar também a sudorese. Monitorizar glicemia frequentemente em diabéticos insulinizados.',
    explanation_en = 'Mechanism similar to propranolol + insulin. Carvedilol blocks beta-1 and beta-2, preventing compensatory tachycardia of hypoglycaemia. However, alpha-1 blocking activity may also mask sweating. Monitor blood glucose frequently in insulin-treated diabetics.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Carvedilol (Coreg): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07c619c6-4a0c-445e-94fa-664a54f68a39',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Carvedilol (Coreg) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07c619c6-4a0c-445e-94fa-664a54f68a39'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'carvedilol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'insulina');

-- 2.11 carvedilol × ciclosporina
UPDATE public.drug_interactions
SET summary_pro_pt = 'Betabloqueador + imunossupressor: carvedilol pode reduzir níveis de ciclosporina. Monitorizar concentrações.',
    summary_pro_en = 'Beta-blocker + immunosupressant: carvedilol may reduce ciclosporin levels. Monitor concentrations.',
    explanation_pt = 'O carvedilol pode reduzir ligeiramente os níveis de ciclosporina, possivelmente por indução do metabolismo ou alteração do transporte. O efeito é variável e clinicamente menos significativo que com nifedipina. Monitorizar concentrações de ciclosporina (trough) e ajustar a dose do imunossupressor se necessário.',
    explanation_en = 'Carvedilol may slightly reduce ciclosporin levels, possibly through metabolism induction or transport alteration. The effect is variable and clinically less significant than with nifedipine. Monitor ciclosporin trough concentrations and adjust immunosuppressant dose if needed.',
    source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Carvedilol (Coreg): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07c619c6-4a0c-445e-94fa-664a54f68a39',
    source_en = 'DailyMed/FDA (NIH/NLM) — approved Carvedilol (Coreg) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=07c619c6-4a0c-445e-94fa-664a54f68a39'
WHERE drug_a_id = (SELECT id FROM public.drugs WHERE slug = 'carvedilol')
  AND drug_b_id = (SELECT id FROM public.drugs WHERE slug = 'ciclosporina');
