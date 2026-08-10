-- =====================================================================
-- 125 — Explicações fármaco-fármaco dos pares moderados da
--        HIDROCLOROTIAZIDA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 3 pares moderados da hidroclorotiazida que os tinham vazios
-- (prednisolona já coberto na 119; lítio já tinha explicação na 118).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais:
--   1. Calcitriol + hidroclorotiazida — hipercalcemia: as tiazidas reduzem
--      a excreção renal de cálcio e o rótulo do calcitriol refere relatos
--      de hipercalcemia na associação com tiazidas;
--   2. Dexametasona + hidroclorotiazida — hipocaliemia aditiva: o rótulo
--      da tiazida lista "Corticosteroid, ACTH: intensified electrolyte
--      depletion, particularly hypokalemia" e o da dexametasona lista
--      perda de potássio e alcalose hipocaliémica;
--   3. Enalapril + hidroclorotiazida — efeito anti-hipertensor aditivo
--      ("approximately additive" no rótulo do enalapril), hipotensão de
--      primeira dose em doentes com depleção de volume e balanço de
--      eletrólitos (hipocaliemia da tiazida vs hipercaliemia do IECA).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/3 — CALCITRIOL + HIDROCLOROTIAZIDA (hipercalcemia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Calcitriol + hidroclorotiazida: as tiazidas reduzem a excreção renal de cálcio e podem potenciar a hipercalcemia do calcitriol. Monitorizar cálcio sérico.',
  summary_pro_en = 'Calcitriol + hydrochlorothiazide: thiazides reduce renal calcium excretion and can potentiate calcitriol-induced hypercalcaemia. Monitor serum calcium.',
  explanation_pt = 'As tiazidas diminuem a excreção renal de cálcio (a hidroclorotiazida aumenta a reabsorção tubular de cálcio) e o rótulo da hidroclorotiazida documenta hipercalcemia e hipofosfatemia em doentes em terapêutica tiazida prolongada, com alterações paratiroideias; o rótulo do calcitriol refere explicitamente que "as tiazidas induzem hipercalcemia pela redução da excreção urinária de cálcio" e que existem relatos de hipercalcemia quando as tiazidas são administradas concomitantemente com calcitriol, recomendando precaução. A associação soma, assim, os dois mecanismos hipercalcémicos. Monitorizar o cálcio sérico (e o produto cálcio x fósforo), especialmente no início ou ajuste de dose; vigiar sinais de hipercalcemia (fraqueza, cefaleia, náuseas, vómitos, obstipação, poliúria) e reduzir/suspender o calcitriol ou os suplementos de cálcio se necessário.',
  explanation_en = 'Thiazides decrease renal calcium excretion (hydrochlorothiazide increases tubular calcium reabsorption) and the hydrochlorothiazide label documents hypercalcaemia and hypophosphataemia in patients on prolonged thiazide therapy, with parathyroid changes; the calcitriol label explicitly states that "thiazides induce hypercalcaemia by reducing urinary calcium excretion" and that there are reports of hypercalcaemia when thiazides are given concomitantly with calcitriol, recommending caution. The combination thus adds up the two hypercalcaemic mechanisms. Monitor serum calcium (and the calcium x phosphorus product), especially at initiation or dose adjustment; watch for hypercalcaemia signs (weakness, headache, nausea, vomiting, constipation, polyuria) and reduce/stop calcitriol or calcium supplements if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'calcitriol'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));

-- 2/3 — DEXAMETASONA + HIDROCLOROTIAZIDA (hipocaliemia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dexametasona + hidroclorotiazida: perda aditiva de potássio (hipocaliemia). Monitorizar potássio e repor se necessário.',
  summary_pro_en = 'Dexamethasone + hydrochlorothiazide: additive potassium loss (hypokalaemia). Monitor potassium and replace if needed.',
  explanation_pt = 'Ambos os fármacos causam perda renal de potássio: a hidroclorotiazida (a troca de sódio por potássio no túbulo distal pode causar hipocaliemia e hipomagnesemia, com risco de arritmias ventriculares e de potenciar a toxicidade digitálica) e a dexametasona (o rótulo lista, entre as perturbações hidroelectrolíticas, retenção de sódio e líquidos, perda de potássio e alcalose hipocaliémica). O rótulo da hidroclorotiazida refere explicitamente que a hipocaliemia pode desenvolver-se "durante o uso concomitante de corticosteroides ou ACTH" e que os corticosteroides causam "intensified electrolyte depletion, particularly hypokalemia". A associação é comum na prática (ex.: asma/DPOC com corticosteroide + hipertensão com tiazida), mas exige vigilância: monitorizar o potássio sérico (e magnésio), sobretudo em idosos, cirróticos e doentes digitálicos, e repor potássio quando indicado.',
  explanation_en = 'Both drugs cause renal potassium loss: hydrochlorothiazide (the exchange of sodium for potassium in the distal tubule can cause hypokalaemia and hypomagnesaemia, with a risk of ventricular arrhythmias and of potentiating digitalis toxicity) and dexamethasone (the label lists, among the fluid and electrolyte disturbances, sodium and fluid retention, potassium loss and hypokalaemic alkalosis). The hydrochlorothiazide label explicitly states that hypokalaemia may develop "during concomitant use of corticosteroid or ACTH" and that corticosteroids cause "intensified electrolyte depletion, particularly hypokalemia". The combination is common in practice (e.g. asthma/COPD with a corticosteroid + hypertension with a thiazide), but requires vigilance: monitor serum potassium (and magnesium), especially in the elderly, cirrhotics and digitalised patients, and replace potassium when indicated.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));

-- 3/3 — ENALAPRIL + HIDROCLOROTIAZIDA (anti-hipertensão aditiva + eletrólitos)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Enalapril + hidroclorotiazida: efeito anti-hipertensor aditivo (associação fixa comum). Vigiar hipotensão de primeira dose, função renal e potássio.',
  summary_pro_en = 'Enalapril + hydrochlorothiazide: additive antihypertensive effect (common fixed combination). Watch for first-dose hypotension, renal function and potassium.',
  explanation_pt = 'A associação de um IECA com uma tiazida é uma combinação fixa bem estabelecida no tratamento da hipertensão, com efeito anti-hipertensor aproximadamente aditivo (o rótulo do enalapril refere que os efeitos na pressão arterial são "approximately additive" com os diuréticos tiazida) e benefício na redução da hipocaliemia induzida pela tiazida. Os riscos a vigiar: (1) hipotensão de primeira dose — em doentes com depleção de volume/sódio pelo diurético, o rótulo do enalapril recomenda corrigir a depleção ou reduzir a dose inicial; (2) função renal — a hipovolemia pode aumentar a creatinina; (3) eletrólitos — balanço entre a hipocaliemia da tiazida e a tendência hipercaliémica do IECA (o rótulo da tiazida refere que pode ser usada em doentes em quem a hipercaliemia não pode ser arriscada, incluindo doentes com IECA). Monitorizar TA, creatinina e potássio após o início/ajuste; iniciar com doses baixas em idosos e doentes com depleção de volume.',
  explanation_en = 'The combination of an ACE inhibitor with a thiazide is a well-established fixed combination for hypertension, with an approximately additive antihypertensive effect (the enalapril label states the blood pressure effects are "approximately additive" with thiazide diuretics) and a benefit in reducing thiazide-induced hypokalaemia. The risks to watch: (1) first-dose hypotension — in patients with volume/sodium depletion from the diuretic, the enalapril label recommends correcting the depletion or reducing the initial dose; (2) renal function — hypovolaemia can raise creatinine; (3) electrolytes — the balance between thiazide hypokalaemia and the ACE inhibitor hyperkalaemic tendency (the thiazide label states it may be used in patients in whom hyperkalaemia cannot be risked, including patients taking ACE inhibitors). Monitor BP, creatinine and potassium after initiation/adjustment; start with low doses in the elderly and in volume-depleted patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));
