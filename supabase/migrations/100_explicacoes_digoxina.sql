-- =====================================================================
-- 100 — Explicações fármaco-fármaco dos pares moderados da DIGOXINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 22 pares moderados da digoxina que os tinham vazios —
-- terceiro lote dos pares moderados sem explicação (319 → 275 → 253).
-- Padrão da 089: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados citados no campo
-- source_* já existente de cada par (DailyMed/FDA, EMA/EMC-UK).
-- Mecanismos centrais: digoxina é substrato da glicoproteína-P (P-gp) e
-- do CYP3A4, com janela terapêutica estreita (0,8–2,0 ng/mL).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/22 — ADRENALINA + DIGOXINA (arritmias ventriculares)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Adrenalina + digoxina: risco aumentado de arritmias ventriculares (a digoxina sensibiliza o miocárdio à estimulação beta-adrenérgica). Usar com precaução e vigiar ECG.',
  summary_pro_en = 'Epinephrine + digoxin: increased risk of ventricular arrhythmias (digoxin sensitises the myocardium to beta-adrenergic stimulation). Use with caution and monitor the ECG.',
  explanation_pt = 'A digoxina sensibiliza o miocárdio à estimulação simpática: a adrenalina, ao estimular os recetores beta e alfa, aumenta a automaticidade e pode precipitar arritmias ventriculares, incluindo taquicardia ventricular, em doentes digitálicos. O risco é maior com hipocaliemia (que a própria digoxina favorece) e com doses elevadas de adrenalina. Esta associação surge sobretudo em contexto de emergência (paragem cardiorrespiratória, anafilaxia) ou em doentes com insuficiência cardíaca avançada. Recomenda-se monitorizar o ECG durante a administração, corrigir eletrólitos (sobretudo potássio e magnésio) e usar as menores doses eficazes de adrenalina.',
  explanation_en = 'Digoxin sensitises the myocardium to sympathetic stimulation: epinephrine, by stimulating beta and alpha receptors, increases automaticity and can precipitate ventricular arrhythmias, including ventricular tachycardia, in digitalised patients. The risk is higher with hypokalaemia (which digoxin itself favours) and with high epinephrine doses. This combination arises mainly in emergencies (cardiac arrest, anaphylaxis) or in patients with advanced heart failure. Monitor the ECG during administration, correct electrolytes (especially potassium and magnesium) and use the lowest effective epinephrine doses.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'adrenalina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'adrenalina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 2/22 — AMIODARONA + DIGOXINA (inibição da P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A amiodarona inibe a glicoproteína-P e pode DUPLICAR os níveis de digoxina. Reduzir a dose de digoxina em 30–50% ao iniciar e monitorizar a digoxinemia.',
  summary_pro_en = 'Amiodarone inhibits P-glycoprotein and can DOUBLE digoxin levels. Reduce the digoxin dose by 30–50% when starting and monitor digoxin levels.',
  explanation_pt = 'A amiodarona é um inibidor potente da glicoproteína-P (P-gp), o transportador que elimina a digoxina a nível intestinal, renal e biliar. A inibição reduz a clearance da digoxina e pode aumentar as suas concentrações em 50–100%, com risco de toxicidade digitálica (náuseas, arritmias, alterações visuais). O efeito desenvolve-se nos primeiros dias e persiste durante semanas após suspender a amiodarona (semivida longa). O rótulo da digoxina recomenda reduzir a dose em cerca de 30–50% quando se inicia amiodarona e monitorizar a digoxinemia e o ECG. Esta associação é comum na fibrilhação auricular, exigindo controlo apertado.',
  explanation_en = 'Amiodarone is a potent inhibitor of P-glycoprotein (P-gp), the transporter that eliminates digoxin at the intestinal, renal and biliary level. The inhibition reduces digoxin clearance and can raise its concentrations by 50–100%, with a risk of digitalis toxicity (nausea, arrhythmias, visual disturbances). The effect develops within days and persists for weeks after amiodarone is stopped (long half-life). The digoxin label recommends reducing the dose by about 30–50% when amiodarone is started and monitoring digoxin levels and the ECG. This combination is common in atrial fibrillation and requires tight control.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 3/22 — AZITROMICINA + DIGOXINA (alteração da flora / P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Macrólidos podem aumentar os níveis de digoxina (inibição da P-gp e da flora intestinal que metaboliza a digoxina). Monitorizar sinais de toxicidade digitálica.',
  summary_pro_en = 'Macrolides can raise digoxin levels (P-gp inhibition and reduction of the gut flora that metabolises digoxin). Monitor for signs of digitalis toxicity.',
  explanation_pt = 'A azitromicina, como os restantes macrólidos, pode aumentar as concentrações de digoxina por dois mecanismos: inibição da glicoproteína-P (que elimina a digoxina) e redução da flora bacteriana intestinal que inativa a digoxina (cerca de 10% dos doentes têm flora que metaboliza o fármaco). O efeito é variável, mas existem relatos de toxicidade digitálica após ciclos de macrólidos. Recomenda-se vigiar sintomas de toxicidade (náuseas, vómitos, bradicardia, arritmias, confusão, alterações visuais) e considerar monitorizar a digoxinemia, sobretudo em idosos e doentes com função renal diminuída.',
  explanation_en = 'Azithromycin, like other macrolides, can raise digoxin concentrations through two mechanisms: inhibition of P-glycoprotein (which eliminates digoxin) and reduction of the gut bacterial flora that inactivates digoxin (about 10% of patients have flora that metabolises the drug). The effect is variable, but reports of digitalis toxicity after macrolide courses exist. Monitor for toxicity symptoms (nausea, vomiting, bradycardia, arrhythmias, confusion, visual disturbances) and consider monitoring digoxin levels, especially in the elderly and in patients with reduced renal function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'azitromicina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'azitromicina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 4/22 — BUMETANIDA + DIGOXINA (hipocaliemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diurético de ansa + digoxina: a hipocaliemia e a hipomagnesiemia induzidas aumentam a toxicidade digitálica. Monitorizar eletrólitos e digoxinemia.',
  summary_pro_en = 'Loop diuretic + digoxin: diuretic-induced hypokalaemia and hypomagnesaemia increase digitalis toxicity. Monitor electrolytes and digoxin levels.',
  explanation_pt = 'A bumetanida é um diurético de ansa que depleta potássio e magnésio. Estes eletrólitos são críticos na toxicidade digitálica: a hipocaliemia e a hipomagnesiemia potenciam os efeitos arritmogénicos da digoxina (bloqueio da Na+/K+-ATPase é agravado), mesmo com níveis de digoxina terapêuticos. O risco é maior em doentes idosos, com função renal diminuída ou com doses altas de diurético. Recomenda-se monitorizar o potássio e o magnésio séricos (mantendo K+ ≥ 4,0 mEq/L), corrigir défices, vigiar o ECG e considerar a monitorização da digoxinemia.',
  explanation_en = 'Bumetanide is a loop diuretic that depletes potassium and magnesium. These electrolytes are critical in digitalis toxicity: hypokalaemia and hypomagnesaemia potentiate the arrhythmogenic effects of digoxin (aggravated Na+/K+-ATPase blockade), even at therapeutic digoxin levels. The risk is higher in elderly patients, in those with reduced renal function or with high diuretic doses. Monitor serum potassium and magnesium (keeping K+ ≥ 4.0 mEq/L), correct deficits, monitor the ECG and consider digoxin level monitoring.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'bumetanida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'bumetanida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 5/22 — CALCITRIOL + DIGOXINA (hipercalcemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O calcitriol eleva a calcemia e a hipercalcemia aumenta a toxicidade digitálica (arritmias). Monitorizar calcemia e sinais de toxicidade.',
  summary_pro_en = 'Calcitriol raises serum calcium and hypercalcaemia increases digitalis toxicity (arrhythmias). Monitor serum calcium and toxicity signs.',
  explanation_pt = 'O calcitriol (vitamina D ativa) aumenta a absorção intestinal de cálcio e pode elevar a calcemia. A hipercalcemia potenciada pela digoxina aumenta o risco de arritmias, sobretudo em doentes com insuficiência renal ou em tratamento com suplementos de cálcio. A toxicidade digitálica pode surgir com níveis de digoxina que seriam seguros com calcemia normal. Recomenda-se monitorizar a calcemia durante o tratamento com calcitriol (sobretudo se houver suplementação de cálcio ou doença renal), vigiar sinais de toxicidade digitálica e ajustar conforme necessário.',
  explanation_en = 'Calcitriol (active vitamin D) increases intestinal calcium absorption and can raise serum calcium. Hypercalcaemia combined with digoxin increases the risk of arrhythmias, especially in patients with renal impairment or on calcium supplements. Digitalis toxicity can occur at digoxin levels that would be safe with normal serum calcium. Monitor serum calcium during calcitriol treatment (especially with calcium supplementation or kidney disease), watch for digitalis toxicity signs and adjust accordingly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 6/22 — CETOCONAZOL + DIGOXINA (inibição da P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O cetoconazol inibe a glicoproteína-P e pode aumentar os níveis de digoxina. Monitorizar a digoxinemia e sinais de toxicidade.',
  summary_pro_en = 'Ketoconazole inhibits P-glycoprotein and can raise digoxin levels. Monitor digoxin levels and toxicity signs.',
  explanation_pt = 'O cetoconazol é um inibidor potente da glicoproteína-P e do CYP3A4, os dois sistemas que eliminam a digoxina. A inibição aumenta a biodisponibilidade oral e reduz a clearance da digoxina, elevando as suas concentrações e o risco de toxicidade digitálica. Recomenda-se monitorizar a digoxinemia quando se inicia ou ajusta o cetoconazol, reduzir a dose de digoxina se necessário e vigiar sintomas de toxicidade (náuseas, bradicardia, arritmias, alterações visuais), sobretudo em tratamentos prolongados.',
  explanation_en = 'Ketoconazole is a potent inhibitor of P-glycoprotein and CYP3A4, the two systems that eliminate digoxin. The inhibition increases oral bioavailability and reduces digoxin clearance, raising its concentrations and the risk of digitalis toxicity. Monitor digoxin levels when ketoconazole is started or adjusted, reduce the digoxin dose if needed and watch for toxicity symptoms (nausea, bradycardia, arrhythmias, visual disturbances), especially in prolonged treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 7/22 — CLOROQUINA + DIGOXINA (inibição da P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A cloroquina pode inibir a glicoproteína-P e aumentar os níveis de digoxina. Monitorizar a digoxinemia durante o tratamento antimalárico.',
  summary_pro_en = 'Chloroquine can inhibit P-glycoprotein and raise digoxin levels. Monitor digoxin levels during antimalarial treatment.',
  explanation_pt = 'A cloroquina inibe a glicoproteína-P e pode reduzir a eliminação da digoxina, aumentando as suas concentrações plasmáticas e o risco de toxicidade digitálica. Existem relatos de aumento dos níveis de digoxina com a administração concomitante de cloroquina. Recomenda-se monitorizar a digoxinemia e o ECG quando se inicia a cloroquina (sobretudo em tratamentos prolongados, como no lúpus ou na artrite reumatoide) e vigiar sinais de toxicidade digitálica, ajustando a dose de digoxina se necessário.',
  explanation_en = 'Chloroquine inhibits P-glycoprotein and can reduce digoxin elimination, raising its plasma concentrations and the risk of digitalis toxicity. Reports exist of increased digoxin levels with concomitant chloroquine. Monitor digoxin levels and the ECG when chloroquine is started (especially in prolonged treatment, such as lupus or rheumatoid arthritis) and watch for digitalis toxicity signs, adjusting the digoxin dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 8/22 — DEXAMETASONA + DIGOXINA (hipocaliemia e retenção de sódio)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Corticosteroides + digoxina: a hipocaliemia induzida aumenta a toxicidade digitálica; a retenção de sódio/água pode agravar a insuficiência cardíaca. Monitorizar eletrólitos.',
  summary_pro_en = 'Corticosteroids + digoxin: steroid-induced hypokalaemia increases digitalis toxicity; sodium/water retention may worsen heart failure. Monitor electrolytes.',
  explanation_pt = 'A dexametasona tem atividade mineralocorticoide ligeira que, em doses altas ou uso prolongado, pode causar hipocaliemia e retenção de sódio e água. A hipocaliemia potencia a toxicidade digitálica (arritmias ventriculares, mesmo com digoxinemia terapêutica), e a retenção de fluidos pode descompensar a insuficiência cardíaca que motivou a digoxina. Recomenda-se monitorizar o potássio sérico (manter ≥ 4,0 mEq/L) e o peso, vigiar sinais de descompensação e de toxicidade digitálica, e ajustar conforme necessário.',
  explanation_en = 'Dexamethasone has mild mineralocorticoid activity that, at high doses or with prolonged use, can cause hypokalaemia and sodium/water retention. Hypokalaemia potentiates digitalis toxicity (ventricular arrhythmias, even at therapeutic digoxin levels), and fluid retention can decompensate the heart failure that prompted digoxin. Monitor serum potassium (keep ≥ 4.0 mEq/L) and weight, watch for decompensation and digitalis toxicity signs, and adjust accordingly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 9/22 — ERITROMICINA + DIGOXINA (inibição da P-gp e flora)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A eritromicina inibe a P-gp e reduz a flora que inativa a digoxina, podendo aumentar os seus níveis. Monitorizar sinais de toxicidade digitálica.',
  summary_pro_en = 'Erythromycin inhibits P-gp and reduces the flora that inactivates digoxin, potentially raising its levels. Monitor for digitalis toxicity signs.',
  explanation_pt = 'A eritromicina aumenta as concentrações de digoxina por dois mecanismos: inibição da glicoproteína-P (reduz a excreção intestinal e renal da digoxina) e eliminação da flora bacteriana intestinal que metaboliza a digoxina em metabolitos inativos. Estudos mostram aumentos de 40–100% na digoxinemia em doentes tratados com eritromicina, com risco de toxicidade digitálica. Recomenda-se monitorizar a digoxinemia e o ECG durante e após o ciclo antibiótico, vigiar sintomas de toxicidade e reduzir a dose de digoxina se necessário.',
  explanation_en = 'Erythromycin raises digoxin concentrations through two mechanisms: P-glycoprotein inhibition (reduces intestinal and renal digoxin excretion) and elimination of the gut bacterial flora that metabolises digoxin to inactive metabolites. Studies show 40–100% increases in digoxin levels in patients treated with erythromycin, with a risk of digitalis toxicity. Monitor digoxin levels and the ECG during and after the antibiotic course, watch for toxicity symptoms and reduce the digoxin dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'eritromicina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'eritromicina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 10/22 — FLECAINIDA + DIGOXINA (efeito aditivo na condução AV)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Flecainida + digoxina: a flecainida pode aumentar ligeiramente os níveis de digoxina e ambos deprimem a condução AV. Monitorizar ECG e digoxinemia.',
  summary_pro_en = 'Flecainide + digoxin: flecainide can slightly raise digoxin levels and both depress AV conduction. Monitor ECG and digoxin levels.',
  explanation_pt = 'A flecainida e a digoxina têm efeitos aditivos na condução auriculoventricular, com risco de bloqueio AV, e a flecainida pode aumentar ligeiramente as concentrações de digoxina (possível inibição do transporte de efluxo). A associação é usada em cardiologia (ex.: controlo de arritmias auriculares), mas exige vigilância: monitorizar o ECG (intervalo PR, duração QRS), a digoxinemia e sinais de toxicidade de ambos (a flecainida pode causar proarritmia e a digoxina arritmias com níveis elevados).',
  explanation_en = 'Flecainide and digoxin have additive effects on atrioventricular conduction, with a risk of AV block, and flecainide can slightly raise digoxin concentrations (possible inhibition of efflux transport). The combination is used in cardiology (e.g. control of atrial arrhythmias), but requires vigilance: monitor the ECG (PR interval, QRS duration), digoxin levels and signs of toxicity of both (flecainide can be proarrhythmic and digoxin causes arrhythmias at high levels).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'flecainida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'flecainida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 11/22 — FUROSEMIDA + DIGOXINA (hipocaliemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diurético de ansa + digoxina: a hipocaliemia e hipomagnesiemia induzidas aumentam a toxicidade digitálica. Monitorizar eletrólitos e ECG.',
  summary_pro_en = 'Loop diuretic + digoxin: diuretic-induced hypokalaemia and hypomagnesaemia increase digitalis toxicity. Monitor electrolytes and ECG.',
  explanation_pt = 'A furosemida é um diurético de ansa que causa depleção de potássio e magnésio, os eletrólitos que mais condicionam a toxicidade digitálica. A hipocaliemia aumenta a ligação da digoxina à Na+/K+-ATPase e potencia as arritmias, mesmo com níveis terapêuticos. Esta é uma associação clássica em doentes com insuficiência cardíaca, que usam os dois fármacos em conjunto. Recomenda-se monitorizar o potássio sérico (manter ≥ 4,0 mEq/L) e o magnésio, corrigir défices, vigiar o ECG e considerar a monitorização da digoxinemia em doentes instáveis.',
  explanation_en = 'Furosemide is a loop diuretic that depletes potassium and magnesium, the electrolytes that most influence digitalis toxicity. Hypokalaemia increases digoxin binding to Na+/K+-ATPase and potentiates arrhythmias, even at therapeutic levels. This is a classic combination in heart failure patients, who use both drugs together. Monitor serum potassium (keep ≥ 4.0 mEq/L) and magnesium, correct deficits, monitor the ECG and consider digoxin level monitoring in unstable patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 12/22 — HIDROXICLOROQUINA + DIGOXINA (inibição da P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A hidroxicloroquina pode inibir a P-gp e aumentar os níveis de digoxina. Monitorizar a digoxinemia em tratamentos prolongados.',
  summary_pro_en = 'Hydroxychloroquine can inhibit P-gp and raise digoxin levels. Monitor digoxin levels in prolonged treatment.',
  explanation_pt = 'A hidroxicloroquina, como a cloroquina, pode inibir a glicoproteína-P e reduzir a eliminação da digoxina, aumentando as suas concentrações e o risco de toxicidade digitálica. A interação é mais relevante em doentes com lúpus ou artrite reumatoide em tratamento prolongado, nos quais o efeito se pode manifestar ao longo de semanas. Recomenda-se monitorizar a digoxinemia e o ECG quando se inicia ou ajusta a hidroxicloroquina e vigiar sinais de toxicidade digitálica (náuseas, bradicardia, arritmias, alterações visuais).',
  explanation_en = 'Hydroxychloroquine, like chloroquine, can inhibit P-glycoprotein and reduce digoxin elimination, raising its concentrations and the risk of digitalis toxicity. The interaction is most relevant in patients with lupus or rheumatoid arthritis on prolonged treatment, in whom the effect can manifest over weeks. Monitor digoxin levels and the ECG when hydroxychloroquine is started or adjusted and watch for digitalis toxicity signs (nausea, bradycardia, arrhythmias, visual disturbances).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'hidroxicloroquina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 13/22 — INDAPAMIDA + DIGOXINA (hipocaliemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diurético tiazídico-like + digoxina: a hipocaliemia induzida aumenta a toxicidade digitálica. Monitorizar eletrólitos.',
  summary_pro_en = 'Thiazide-like diuretic + digoxin: diuretic-induced hypokalaemia increases digitalis toxicity. Monitor electrolytes.',
  explanation_pt = 'A indapamida é um diurético de tipo tiazídico que causa depleção de potássio e magnésio. A hipocaliemia potencia a toxicidade da digoxina (arritmias ventriculares, mesmo com níveis terapêuticos), sobretudo em doentes idosos hipertensos que usam a associação com frequência. Recomenda-se monitorizar o potássio sérico durante o tratamento (manter ≥ 4,0 mEq/L), corrigir défices, vigiar o ECG e considerar a monitorização da digoxinemia se houver sintomas sugestivos de toxicidade.',
  explanation_en = 'Indapamide is a thiazide-like diuretic that depletes potassium and magnesium. Hypokalaemia potentiates digoxin toxicity (ventricular arrhythmias, even at therapeutic levels), especially in elderly hypertensive patients who frequently use the combination. Monitor serum potassium during treatment (keep ≥ 4.0 mEq/L), correct deficits, monitor the ECG and consider digoxin level monitoring if toxicity symptoms are suspected.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'indapamida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'indapamida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 14/22 — ITRACONAZOL + DIGOXINA (inibição da P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O itraconazol inibe a P-gp e pode aumentar os níveis de digoxina. Monitorizar a digoxinemia e reduzir a dose se necessário.',
  summary_pro_en = 'Itraconazole inhibits P-gp and can raise digoxin levels. Monitor digoxin levels and reduce the dose if needed.',
  explanation_pt = 'O itraconazol é um inibidor potente da glicoproteína-P, reduzindo a excreção intestinal e renal da digoxina e aumentando as suas concentrações plasmáticas — estudos mostram aumentos de 50–100%. O risco de toxicidade digitálica (náuseas, arritmias, alterações visuais) é significativo. Recomenda-se monitorizar a digoxinemia quando se inicia o itraconazol, reduzir a dose de digoxina se necessário e vigiar o ECG e os sintomas de toxicidade durante e após o tratamento antifúngico.',
  explanation_en = 'Itraconazole is a potent P-glycoprotein inhibitor, reducing intestinal and renal digoxin excretion and raising its plasma concentrations — studies show 50–100% increases. The risk of digitalis toxicity (nausea, arrhythmias, visual disturbances) is significant. Monitor digoxin levels when itraconazole is started, reduce the digoxin dose if needed and watch the ECG and toxicity symptoms during and after antifungal treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 15/22 — METOCLOPRAMIDA + DIGOXINA (absorção aumentada)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A metoclopramida acelera o esvaziamento gástrico e pode aumentar a absorção e os níveis de digoxina. Monitorizar a digoxinemia em doentes estáveis.',
  summary_pro_en = 'Metoclopramide accelerates gastric emptying and can increase digoxin absorption and levels. Monitor digoxin levels in stable patients.',
  explanation_pt = 'A metoclopramida acelera o esvaziamento gástrico e o trânsito intestinal, o que pode aumentar a velocidade e a extensão da absorção da digoxina (sobretudo nas formulações de libertação lenta) e elevar transitoriamente os níveis plasmáticos. O efeito é geralmente modesto, mas relevante em doentes com níveis limítrofes ou função renal diminuída. Recomenda-se monitorizar a digoxinemia quando se inicia ou suspende a metoclopramida e vigiar sinais de toxicidade digitálica; separar as tomas quando possível.',
  explanation_en = 'Metoclopramide accelerates gastric emptying and intestinal transit, which can increase the rate and extent of digoxin absorption (especially slow-release formulations) and transiently raise plasma levels. The effect is usually modest, but relevant in patients with borderline levels or reduced renal function. Monitor digoxin levels when metoclopramide is started or stopped and watch for digitalis toxicity signs; separate dosing when possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'metoclopramida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metoclopramida'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 16/22 — MIDODRINA + DIGOXINA (bradicardia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Midodrina + digoxina: efeito cronotrópico negativo aditivo (bradicardia) e risco de arritmias. Monitorizar frequência cardíaca e ECG.',
  summary_pro_en = 'Midodrine + digoxin: additive negative chronotropic effect (bradycardia) and arrhythmia risk. Monitor heart rate and ECG.',
  explanation_pt = 'A midodrina (agonista alfa-1) aumenta o tónus vagal reflexo e a digoxina tem efeito cronotrópico e dromotrópico negativo: a associação pode causar bradicardia acentuada e bloqueios de condução, sobretudo em doentes idosos com disfunção do nó sinusal. A digoxina, por si, também aumenta a automaticidade em níveis tóxicos, pelo que o ECG deve ser vigiado. Recomenda-se monitorizar a frequência cardíaca e o ECG, usar as menores doses eficazes de midodrina e vigiar sintomas de hipoperfusão (tonturas, síncope) e de toxicidade digitálica.',
  explanation_en = 'Midodrine (alpha-1 agonist) increases reflex vagal tone and digoxin has negative chronotropic and dromotropic effects: the combination can cause marked bradycardia and conduction blocks, especially in elderly patients with sinus node dysfunction. Digoxin itself also increases automaticity at toxic levels, so the ECG should be monitored. Monitor heart rate and ECG, use the lowest effective midodrine doses and watch for hypoperfusion symptoms (dizziness, syncope) and digitalis toxicity signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'midodrina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'midodrina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 17/22 — PROPAFENONA + DIGOXINA (aumento dos níveis e condução AV)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A propafenona pode aumentar os níveis de digoxina e ambos deprimem a condução AV. Monitorizar digoxinemia, ECG e sinais de toxicidade.',
  summary_pro_en = 'Propafenone can raise digoxin levels and both depress AV conduction. Monitor digoxin levels, ECG and toxicity signs.',
  explanation_pt = 'A propafenona aumenta as concentrações de digoxina (inibição do transporte de efluxo, com aumentos de 30–80% documentados) e, como antiarrítmico de classe IC, tem efeitos depressores da condução que se somam aos da digoxina (risco de bloqueio AV). A associação é frequente na fibrilhação auricular. Recomenda-se monitorizar a digoxinemia quando se inicia a propafenona (reduzindo a dose de digoxina se necessário), vigiar o ECG (PR, QRS, frequência) e os sintomas de toxicidade de ambos os fármacos.',
  explanation_en = 'Propafenone raises digoxin concentrations (inhibition of efflux transport, with documented 30–80% increases) and, as a class 1C antiarrhythmic, has conduction-depressant effects that add to those of digoxin (AV block risk). The combination is common in atrial fibrillation. Monitor digoxin levels when propafenone is started (reducing the digoxin dose if needed), watch the ECG (PR, QRS, rate) and symptoms of toxicity of both drugs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'propafenona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'propafenona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 18/22 — QUININA + DIGOXINA (inibição da P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A quinina inibe a P-gp e pode aumentar muito os níveis de digoxina. Monitorizar a digoxinemia e reduzir a dose de digoxina.',
  summary_pro_en = 'Quinine inhibits P-gp and can markedly raise digoxin levels. Monitor digoxin levels and reduce the digoxin dose.',
  explanation_pt = 'A quinina é um inibidor potente da glicoproteína-P: reduz a excreção renal e intestinal da digoxina e pode aumentar as suas concentrações em 50–100%, com risco significativo de toxicidade digitálica. Estudos com doses terapêuticas de quinina mostram aumentos substanciais da digoxinemia. Recomenda-se monitorizar a digoxinemia quando se inicia a quinina (reduzindo a dose de digoxina em cerca de 30–50%), vigiar o ECG e os sintomas de toxicidade (náuseas, arritmias, alterações visuais) durante e após o tratamento antimalárico.',
  explanation_en = 'Quinine is a potent P-glycoprotein inhibitor: it reduces renal and intestinal digoxin excretion and can raise its concentrations by 50–100%, with a significant risk of digitalis toxicity. Studies at therapeutic quinine doses show substantial increases in digoxin levels. Monitor digoxin levels when quinine is started (reducing the digoxin dose by about 30–50%), watch the ECG and toxicity symptoms (nausea, arrhythmias, visual disturbances) during and after antimalarial treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'quinina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 19/22 — RIFAMPICINA + DIGOXINA (indução da P-gp — níveis reduzidos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A rifampicina induz a P-gp e pode REDUZIR os níveis de digoxina, com perda de eficácia. Monitorizar a digoxinemia e ajustar a dose.',
  summary_pro_en = 'Rifampicin induces P-gp and can REDUCE digoxin levels, with loss of efficacy. Monitor digoxin levels and adjust the dose.',
  explanation_pt = 'A rifampicina é um indutor potente da glicoproteína-P: aumenta a expressão do transportador e acelera a eliminação da digoxina, reduzindo as suas concentrações plasmáticas. O efeito pode diminuir a eficácia da digoxina (perda de controlo da frequência na fibrilhação auricular ou da insuficiência cardíaca), exigindo por vezes aumento da dose. A interação é particularmente relevante no tratamento da tuberculose em doentes cardiopatas. Recomenda-se monitorizar a digoxinemia ao iniciar e suspender a rifampicina, ajustar a dose de digoxina conforme necessário e reavaliar após a suspensão (os níveis podem subir quando o efeito indutor desaparece).',
  explanation_en = 'Rifampicin is a potent P-glycoprotein inducer: it increases transporter expression and accelerates digoxin elimination, reducing its plasma concentrations. The effect can decrease digoxin efficacy (loss of rate control in atrial fibrillation or of heart failure control), sometimes requiring a dose increase. The interaction is particularly relevant in tuberculosis treatment in cardiac patients. Monitor digoxin levels when rifampicin is started and stopped, adjust the digoxin dose as needed and re-evaluate after discontinuation (levels may rise when the inducing effect fades).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 20/22 — SOTALOL + DIGOXINA (bradicardia e arritmias aditivas)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sotalol + digoxina: bradicardia e bloqueio AV aditivos; o sotalol prolonga o QT e a digoxina aumenta o risco de arritmias. Monitorizar ECG e eletrólitos.',
  summary_pro_en = 'Sotalol + digoxin: additive bradycardia and AV block; sotalol prolongs the QT and digoxin increases the arrhythmia risk. Monitor ECG and electrolytes.',
  explanation_pt = 'O sotalol combina bloqueio beta (cronotrópico e dromotrópico negativo) com atividade de classe III (prolongamento do QT): com a digoxina, os efeitos na frequência cardíaca e na condução AV somam-se, aumentando o risco de bradicardia e bloqueio. A hipocaliemia/hipomagnesiemia (que a digoxina pode favorecer) potencia o risco de torsades de pointes do sotalol. Esta associação surge na fibrilhação auricular, exigindo monitorização do ECG (frequência, PR, QT), eletrólitos e função renal, com ajuste de doses.',
  explanation_en = 'Sotalol combines beta blockade (negative chronotropic and dromotropic effects) with class III activity (QT prolongation): with digoxin, the effects on heart rate and AV conduction add up, increasing the risk of bradycardia and block. Hypokalaemia/hypomagnesaemia (which digoxin can favour) potentiates sotalol torsades de pointes risk. This combination arises in atrial fibrillation, requiring ECG monitoring (rate, PR, QT), electrolytes and renal function, with dose adjustment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sotalol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sotalol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 21/22 — SUCRALFATO + DIGOXINA (absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O sucralfato liga-se à digoxina no trato GI e reduz a sua absorção. Separar as tomas por 2 horas e monitorizar a resposta clínica.',
  summary_pro_en = 'Sucralfate binds digoxin in the GI tract and reduces its absorption. Separate dosing by 2 hours and monitor the clinical response.',
  explanation_pt = 'O sucralfato forma um gel viscoso que se liga a vários fármacos no trato gastrointestinal, incluindo a digoxina, reduzindo a sua absorção e a sua eficácia. A interação é evitável separando as tomas: administrar a digoxina pelo menos 2 horas antes do sucralfato (algumas fontes recomendam mais). Recomenda-se separar as administrações, monitorizar a resposta clínica (controlo da frequência, sinais de insuficiência cardíaca) e, em doentes estáveis com níveis conhecidos, considerar verificar a digoxinemia após a introdução do sucralfato.',
  explanation_en = 'Sucralfate forms a viscous gel that binds several drugs in the gastrointestinal tract, including digoxin, reducing its absorption and efficacy. The interaction is avoidable by separating doses: give digoxin at least 2 hours before sucralfate (some sources recommend longer). Separate the administrations, monitor the clinical response (rate control, heart failure signs) and, in stable patients with known levels, consider checking digoxin levels after sucralfate is introduced.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sucralfato'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sucralfato'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- 22/22 — VORICONAZOL + DIGOXINA (inibição da P-gp)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O voriconazol inibe a P-gp e pode aumentar os níveis de digoxina. Monitorizar a digoxinemia e sinais de toxicidade.',
  summary_pro_en = 'Voriconazole inhibits P-gp and can raise digoxin levels. Monitor digoxin levels and toxicity signs.',
  explanation_pt = 'O voriconazol inibe a glicoproteína-P e pode reduzir a eliminação da digoxina, aumentando as suas concentrações e o risco de toxicidade digitálica. O rótulo do voriconazol recomenda monitorizar os níveis de digoxina quando são coadministrados. A interação é particularmente relevante em doentes imunodeprimidos com infeções fúngicas invasivas, muitas vezes com múltiplos fármacos. Recomenda-se monitorizar a digoxinemia ao iniciar e suspender o voriconazol, vigiar o ECG e os sintomas de toxicidade digitálica e ajustar a dose de digoxina se necessário.',
  explanation_en = 'Voriconazole inhibits P-glycoprotein and can reduce digoxin elimination, raising its concentrations and the risk of digitalis toxicity. The voriconazole label recommends monitoring digoxin levels when they are co-administered. The interaction is particularly relevant in immunocompromised patients with invasive fungal infections, often on multiple drugs. Monitor digoxin levels when voriconazole is started and stopped, watch the ECG and digitalis toxicity symptoms and adjust the digoxin dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'voriconazol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'voriconazol'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

-- =====================================================================
-- FIM — 100: 22 explicações de pares moderados da digoxina
-- =====================================================================
