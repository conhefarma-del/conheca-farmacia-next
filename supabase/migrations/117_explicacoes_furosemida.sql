-- =====================================================================
-- 117 — Explicações fármaco-fármaco dos pares moderados da FUROSEMIDA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 8 pares moderados da furosemida que os tinham vazios
-- (digoxina+furosemida já tinha explicação na 100).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais da furosemida (diurético de ansa):
--   1. Ototoxicidade aditiva com aminoglicosídeos (estreptomicina,
--      gentamicina, amicacina, tobramicina) — "except in life-threatening
--      situations, avoid this combination" (rótulo da furosemida);
--   2. Hipotensão sintomática de primeira dose com IECA (ramipril) em
--      doentes com depleção de volume/sódio por diuréticos + risco renal;
--   3. Hipocaliemia aditiva com acetazolamida (perda renal de potássio)
--      e corticosteroides (prednisolona, dexametasona — perda de potássio
--      e alcalose hipocaliémica).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/8 — AMICACINA + FUROSEMIDA (ototoxicidade aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Amicacina + furosemida: ototoxicidade aditiva (auditiva e vestibular). Evitar a associação, exceto em situações de risco de vida.',
  summary_pro_en = 'Amikacin + furosemide: additive ototoxicity (auditory and vestibular). Avoid the combination, except in life-threatening situations.',
  explanation_pt = 'Tanto a amicacina (aminoglicosídeo) como a furosemida (diurético de ansa) são ototóxicos, e a associação potencia o risco de lesão auditiva e vestibular, sobretudo em doentes com insuficiência renal, doses elevadas ou administração intravenosa rápida. O rótulo da amicacina recomenda evitar o uso concomitante com diuréticos potentes (etacrinato ou furosemida), porque os diuréticos podem causar ototoxicidade por si e, administrados por via intravenosa, podem aumentar a toxicidade do aminoglicosídeo ao alterar as suas concentrações séricas e teciduais; o rótulo da furosemida indica que pode aumentar o potencial ototóxico dos aminoglicosídeos, especialmente com função renal comprometida, e desaconselha a associação exceto em situações de risco de vida. Se inevitável, monitorizar a função renal, a audiometria e os sinais de vestibulotoxicidade (tonturas, nistagmo, acufenos).',
  explanation_en = 'Both amikacin (aminoglycoside) and furosemide (loop diuretic) are ototoxic, and the combination potentiates the risk of auditory and vestibular damage, especially in patients with renal impairment, high doses or rapid intravenous administration. The amikacin label recommends avoiding concomitant use with potent diuretics (ethacrynic acid or furosemide), because diuretics can cause ototoxicity on their own and, given intravenously, can increase aminoglycoside toxicity by altering its serum and tissue concentrations; the furosemide label states it may increase the ototoxic potential of aminoglycosides, especially with impaired renal function, and advises against the combination except in life-threatening situations. If unavoidable, monitor renal function, audiometry and signs of vestibulotoxicity (dizziness, nystagmus, tinnitus).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amicacina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amicacina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

-- 2/8 — DEXAMETASONA + FUROSEMIDA (hipocaliemia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dexametasona + furosemida: risco aditivo de hipocaliemia e alcalose hipocaliémica. Monitorizar potássio e ECG.',
  summary_pro_en = 'Dexamethasone + furosemide: additive risk of hypokalaemia and hypokalaemic alkalosis. Monitor potassium and ECG.',
  explanation_pt = 'A furosemida provoca perda renal de potássio (hipocaliemia, alcalose hipoclorémica), e os corticosteroides sistémicos, como a dexametasona, aumentam a excreção de potássio e podem causar alcalose hipocaliémica, sobretudo em doses elevadas. Em conjunto, o risco de hipocaliemia é aditivo, com potencial para arritmias, sobretudo em doentes com doença cardíaca, idosos ou com outros fármacos que baixem o potássio. Os rótulos da furosemida e dos corticosteroides recomendam monitorizar os eletrólitos séricos e considerar suplementação de potássio durante a associação.',
  explanation_en = 'Furosemide causes renal potassium loss (hypokalaemia, hypochloraemic alkalosis), and systemic corticosteroids such as dexamethasone increase potassium excretion and can cause hypokalaemic alkalosis, especially at high doses. Together, the risk of hypokalaemia is additive, with potential for arrhythmias, particularly in patients with cardiac disease, the elderly or those on other potassium-lowering drugs. The furosemide and corticosteroid labels recommend monitoring serum electrolytes and considering potassium supplementation during the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

-- 3/8 — ESTREPTOMICINA + FUROSEMIDA (ototoxicidade aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Estreptomicina + furosemida: ototoxicidade aditiva (vestibular e auditiva). Evitar a associação, exceto em situações de risco de vida.',
  summary_pro_en = 'Streptomycin + furosemide: additive ototoxicity (vestibular and auditory). Avoid the combination, except in life-threatening situations.',
  explanation_pt = 'A estreptomicina tem potencial ototóxico próprio (predominantemente vestibular, com cefaleia, náuseas, vómitos e desequilíbrio, e perda auditiva de altas frequências), e a furosemida aumenta esse potencial. O rótulo da estreptomicina indica explicitamente que os efeitos ototóxicos dos aminoglicosídeos, incluindo a estreptomicina, são potenciados pela coadministração de furosemida e outros diuréticos; o rótulo da furosemida desaconselha a associação com aminoglicosídeos, exceto em situações de risco de vida, sobretudo com função renal comprometida. Se inevitável, monitorizar a função renal, audiometria e sinais vestibulares, e ajustar as doses.',
  explanation_en = 'Streptomycin has intrinsic ototoxic potential (predominantly vestibular, with headache, nausea, vomiting and disequilibrium, and high-frequency hearing loss), and furosemide potentiates this potential. The streptomycin label explicitly states that the ototoxic effects of aminoglycosides, including streptomycin, are potentiated by co-administration of furosemide and other diuretics; the furosemide label advises against the combination with aminoglycosides, except in life-threatening situations, especially with impaired renal function. If unavoidable, monitor renal function, audiometry and vestibular signs, and adjust doses.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'estreptomicina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'estreptomicina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

-- 4/8 — FUROSEMIDA + GENTAMICINA (ototoxicidade aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Furosemida + gentamicina: ototoxicidade e nefrotoxicidade aditivas. Evitar a associação, exceto em situações de risco de vida.',
  summary_pro_en = 'Furosemide + gentamicin: additive ototoxicity and nephrotoxicity. Avoid the combination, except in life-threatening situations.',
  explanation_pt = 'A gentamicina (aminoglicosídeo) é ototóxica e nefrotóxica, e a furosemida aumenta o potencial ototóxico dos aminoglicosídeos, especialmente na presença de insuficiência renal; o rótulo da furosemida recomenda evitar a associação exceto em situações de risco de vida. A hipovolemia induzida pela furosemida pode ainda reduzir a depuração renal da gentamicina e aumentar o risco de nefrotoxicidade. Se a associação for inevitável, usar as menores doses eficazes, monitorizar a função renal, os níveis séricos do aminoglicosídeo (quando disponíveis), a audiometria e os sinais vestibulares, e manter hidratação adequada.',
  explanation_en = 'Gentamicin (aminoglycoside) is ototoxic and nephrotoxic, and furosemide increases the ototoxic potential of aminoglycosides, especially in the presence of renal impairment; the furosemide label recommends avoiding the combination except in life-threatening situations. Furosemide-induced hypovolaemia can also reduce gentamicin renal clearance and increase the risk of nephrotoxicity. If the combination is unavoidable, use the lowest effective doses, monitor renal function, aminoglycoside serum levels (when available), audiometry and vestibular signs, and maintain adequate hydration.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'gentamicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'gentamicina'));

-- 5/8 — FUROSEMIDA + PREDNISOLONA (hipocaliemia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Furosemida + prednisolona: risco aditivo de hipocaliemia e alcalose hipocaliémica. Monitorizar potássio e considerar suplementação.',
  summary_pro_en = 'Furosemide + prednisolone: additive risk of hypokalaemia and hypokalaemic alkalosis. Monitor potassium and consider supplementation.',
  explanation_pt = 'A furosemida causa perda renal de potássio e alcalose hipoclorémica, e os corticosteroides, como a prednisolona, aumentam a excreção de potássio (retenção de sódio e água, perda de potássio, alcalose hipocaliémica — listadas como perturbações hidroelectrolíticas nos rótulos dos corticosteroides). A associação soma o risco de hipocaliemia, que pode precipitar arritmias, fraqueza muscular e piorar o controlo da insuficiência cardíaca. Recomenda-se monitorizar os eletrólitos séricos, especialmente potássio, e considerar suplementação de potássio ou um diurético poupador de potássio sob orientação.',
  explanation_en = 'Furosemide causes renal potassium loss and hypochloraemic alkalosis, and corticosteroids such as prednisolone increase potassium excretion (sodium and water retention, potassium loss, hypokalaemic alkalosis — listed as fluid and electrolyte disturbances in the corticosteroid labels). The combination adds up the risk of hypokalaemia, which can precipitate arrhythmias, muscle weakness and worsen heart failure control. Monitor serum electrolytes, especially potassium, and consider potassium supplementation or a potassium-sparing diuretic under guidance.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

-- 6/8 — ACETAZOLAMIDA + FUROSEMIDA (hipocaliemia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Acetazolamida + furosemida: perda renal aditiva de potássio com risco de hipocaliemia e alcalose. Monitorizar eletrólitos.',
  summary_pro_en = 'Acetazolamide + furosemide: additive renal potassium loss with a risk of hypokalaemia and alkalosis. Monitor electrolytes.',
  explanation_pt = 'A acetazolamida (inibidor da anidrase carbónica) promove perda renal de bicarbonato, sódio, água e potássio, e a furosemida causa também perda de potássio e alcalose hipoclorémica; o rótulo da acetazolamida contraindica o uso quando os níveis séricos de sódio e/ou potássio estão deprimidos. Em conjunto, o risco de hipocaliemia, hiponatremia e alcalose é aditivo, com potencial para arritmias, fraqueza e piora do estado clínico em doentes com insuficiência cardíaca ou hepática. Recomenda-se monitorizar os eletrólitos séricos (potássio, sódio, bicarbonato) e a função renal durante a associação.',
  explanation_en = 'Acetazolamide (carbonic anhydrase inhibitor) promotes renal loss of bicarbonate, sodium, water and potassium, and furosemide also causes potassium loss and hypochloraemic alkalosis; the acetazolamide label contraindicates its use when serum sodium and/or potassium levels are depressed. Together, the risk of hypokalaemia, hyponatraemia and alkalosis is additive, with potential for arrhythmias, weakness and clinical worsening in patients with heart or liver failure. Monitor serum electrolytes (potassium, sodium, bicarbonate) and renal function during the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'acetazolamida'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'acetazolamida'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

-- 7/8 — FUROSEMIDA + RAMIPRIL (hipotensão de primeira dose + risco renal)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Furosemida + ramipril: risco de hipotensão sintomática de primeira dose (depleção de volume pelo diurético) e de deterioração renal. Vigiar pressão arterial, creatinina e potássio.',
  summary_pro_en = 'Furosemide + ramipril: risk of symptomatic first-dose hypotension (diuretic-induced volume depletion) and renal deterioration. Monitor blood pressure, creatinine and potassium.',
  explanation_pt = 'O ramipril (IECA) pode causar hipotensão sintomática, sobretudo após a primeira dose, e o risco é maior em doentes com depleção de volume e/ou sódio por terapia diurética prolongada (como a furosemida); o rótulo do ramipril recomenda corrigir a depleção de volume/sódio antes de iniciar o IECA. A associação também pode aumentar a creatinina sérica (sobretudo em doentes com insuficiência renal prévia ou estenose das artérias renais), podendo exigir redução da dose do IECA e/ou do diurético. Iniciar o ramipril com a dose mais baixa, de preferência à noite ou com o doente deitado, monitorizar a pressão arterial nas primeiras horas após a primeira dose, e vigiar creatinina e potássio nas primeiras semanas.',
  explanation_en = 'Ramipril (ACE inhibitor) can cause symptomatic hypotension, especially after the first dose, and the risk is higher in patients with volume and/or sodium depletion from prolonged diuretic therapy (such as furosemide); the ramipril label recommends correcting volume/sodium depletion before starting the ACE inhibitor. The combination can also raise serum creatinine (especially in patients with pre-existing renal impairment or renal artery stenosis), possibly requiring dose reduction of the ACE inhibitor and/or the diuretic. Start ramipril at the lowest dose, preferably at bedtime or with the patient supine, monitor blood pressure in the first hours after the first dose, and check creatinine and potassium in the first weeks.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'ramipril'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'ramipril'));

-- 8/8 — FUROSEMIDA + TOBRAMICINA (ototoxicidade aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Furosemida + tobramicina: ototoxicidade e nefrotoxicidade aditivas. Evitar a associação, exceto em situações de risco de vida.',
  summary_pro_en = 'Furosemide + tobramycin: additive ototoxicity and nephrotoxicity. Avoid the combination, except in life-threatening situations.',
  explanation_pt = 'A tobramicina (aminoglicosídeo) é ototóxica e nefrotóxica, e o rótulo da tobramicina indica que os aminoglicosídeos não devem ser administrados concomitantemente com diuréticos potentes, como o etacrinato e a furosemida, porque alguns diuréticos causam ototoxicidade por si e os diuréticos intravenosos podem aumentar a toxicidade do aminoglicosídeo ao alterar as suas concentrações séricas e teciduais. O rótulo da furosemida acrescenta que pode aumentar o potencial ototóxico dos aminoglicosídeos, sobretudo com função renal comprometida, e desaconselha a associação exceto em situações de risco de vida. Se inevitável, monitorizar a função renal, os níveis do aminoglicosídeo, a audiometria e os sinais vestibulares.',
  explanation_en = 'Tobramycin (aminoglycoside) is ototoxic and nephrotoxic, and the tobramycin label states that aminoglycosides should not be given concurrently with potent diuretics such as ethacrynic acid and furosemide, because some diuretics cause ototoxicity on their own and intravenous diuretics can increase aminoglycoside toxicity by altering its serum and tissue concentrations. The furosemide label adds that it may increase the ototoxic potential of aminoglycosides, especially with impaired renal function, and advises against the combination except in life-threatening situations. If unavoidable, monitor renal function, aminoglycoside levels, audiometry and vestibular signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'tobramicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'furosemida'), (SELECT id FROM public.drugs WHERE slug = 'tobramicina'));
