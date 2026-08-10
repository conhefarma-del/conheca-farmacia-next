-- =====================================================================
-- 119 — Explicações fármaco-fármaco dos pares moderados da PREDNISOLONA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 5 pares moderados da prednisolona que os tinham vazios
-- (rifampicina, ibuprofeno, metformina, warfarina e furosemida já tinham
-- explicação nas 097/106/107/114/117).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais da prednisolona (corticosteroide sistémico):
--   1. Úlcera/hemorragia gastrointestinal aditiva com AINEs (diclofenac,
--      naproxeno) — "concomitant use of oral corticosteroids... increase the
--      risk of GI bleeding" (rótulos dos AINEs);
--   2. Hipocaliemia aditiva com a tiazida (hidroclorotiazida) — "Hypokalemia
--      may develop... during concomitant use of corticosteroid" (rótulo da
--      hidroclorotiazida);
--   3. Inibição do CYP3A4 pelos azóis (fluconazol, voriconazol) — excesso de
--      corticoide, síndrome de Cushing e supressão adrenal (rótulo do
--      voriconazol).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/5 — DICLOFENAC + PREDNISOLONA (úlcera/hemorragia GI aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diclofenac + prednisolona: risco aditivo de úlcera e hemorragia gastrointestinal. Considerar gastroproteção nos doentes de risco.',
  summary_pro_en = 'Diclofenac + prednisolone: additive risk of peptic ulcer and gastrointestinal bleeding. Consider gastroprotection in at-risk patients.',
  explanation_pt = 'Os AINEs, como o diclofenac, aumentam o risco de eventos gastrointestinais graves (hemorragia, ulceração e perfuração), e o rótulo do diclofenac identifica o uso concomitante de corticosteroides orais como fator que aumenta o risco de hemorragia GI. A prednisolona, por seu lado, tem a precaução de uso com cautela em doentes com úlcera péptica ativa ou latente. Em conjunto, o risco de úlcera, hemorragia e perfuração digestiva aumenta de forma aditiva, sobretudo em idosos, com história de úlcera/hemorragia ou em tratamentos prolongados. Considerar gastroproteção (inibidor da bomba de protões) nos doentes de risco, usar a menor dose eficaz de cada fármaco e vigiar sintomas digestivos.',
  explanation_en = 'NSAIDs such as diclofenac increase the risk of serious gastrointestinal events (bleeding, ulceration and perforation), and the diclofenac label identifies concomitant use of oral corticosteroids as a factor that increases the risk of GI bleeding. Prednisolone, in turn, carries a precaution to use with caution in patients with active or latent peptic ulcer. Together, the risk of ulcer, bleeding and digestive perforation increases additively, especially in the elderly, with a history of ulcer/bleeding or in prolonged treatment. Consider gastroprotection (proton pump inhibitor) in at-risk patients, use the lowest effective dose of each drug and monitor digestive symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

-- 2/5 — FLUCONAZOL + PREDNISOLONA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluconazol + prednisolona: o azol pode inibir o CYP3A4 e aumentar a exposição ao corticoide. Vigiar sinais de excesso de corticoide.',
  summary_pro_en = 'Fluconazole + prednisolone: the azole can inhibit CYP3A4 and increase corticosteroid exposure. Monitor for signs of corticosteroid excess.',
  explanation_pt = 'A prednisolona é metabolizada em parte pelo CYP3A4, e o fluconazol é um inibidor do CYP3A4 (além do CYP2C9/2C19), podendo aumentar as concentrações do corticoide e os seus efeitos. Embora a interação seja menos documentada que com o voriconazol, aplica-se o mesmo princípio farmacológico: monitorizar sinais de excesso de corticoide (hiperglicemia, retenção de líquidos, hipertensão, aumento de peso, sintomas de síndrome de Cushing) durante a associação, sobretudo com doses elevadas ou tratamentos prolongados, e ajustar a dose da prednisolona se necessário.',
  explanation_en = 'Prednisolone is partly metabolised by CYP3A4, and fluconazole is a CYP3A4 inhibitor (in addition to CYP2C9/2C19), which can raise corticosteroid concentrations and their effects. Although the interaction is less documented than with voriconazole, the same pharmacological principle applies: monitor for signs of corticosteroid excess (hyperglycaemia, fluid retention, hypertension, weight gain, Cushing syndrome symptoms) during the combination, especially at high doses or prolonged treatment, and adjust the prednisolone dose if needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

-- 3/5 — HIDROCLOROTIAZIDA + PREDNISOLONA (hipocaliemia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Hidroclorotiazida + prednisolona: risco aditivo de hipocaliemia. Monitorizar potássio e considerar suplementação.',
  summary_pro_en = 'Hydrochlorothiazide + prednisolone: additive risk of hypokalaemia. Monitor potassium and consider supplementation.',
  explanation_pt = 'A hidroclorotiazida pode causar hipocaliemia, e o rótulo indica explicitamente que a hipocaliemia pode desenvolver-se durante o uso concomitante de corticosteroides ou ACTH, com depleção eletrolítica intensificada, particularmente de potássio. A prednisolona, por seu lado, causa perda de potássio e alcalose hipocaliémica (listadas como perturbações hidroelectrolíticas no rótulo). A associação soma o risco de hipocaliemia, que pode provocar arritmias ventriculares ou sensibilizar o coração aos efeitos tóxicos dos digitálicos. Recomenda-se monitorizar os eletrólitos séricos, especialmente o potássio, e considerar suplementação de potássio.',
  explanation_en = 'Hydrochlorothiazide can cause hypokalaemia, and the label explicitly states that hypokalaemia may develop during concomitant use of corticosteroids or ACTH, with intensified electrolyte depletion, particularly potassium. Prednisolone, in turn, causes potassium loss and hypokalaemic alkalosis (listed as fluid and electrolyte disturbances in the label). The combination adds up the risk of hypokalaemia, which can provoke ventricular arrhythmias or sensitise the heart to the toxic effects of digitalis. Monitor serum electrolytes, especially potassium, and consider potassium supplementation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

-- 4/5 — NAPROXENO + PREDNISOLONA (úlcera/hemorragia GI aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Naproxeno + prednisolona: risco aditivo de úlcera e hemorragia gastrointestinal. Considerar gastroproteção nos doentes de risco.',
  summary_pro_en = 'Naproxen + prednisolone: additive risk of peptic ulcer and gastrointestinal bleeding. Consider gastroprotection in at-risk patients.',
  explanation_pt = 'Os AINEs, como o naproxeno, aumentam o risco de eventos gastrointestinais graves (hemorragia, ulceração e perfuração), com maior risco em idosos e em doentes com história de úlcera péptica ou hemorragia GI; o uso concomitante de corticosteroides orais é um fator reconhecido de aumento do risco de hemorragia GI nos rótulos dos AINEs. A prednisolona tem a precaução de uso com cautela em doentes com úlcera péptica ativa ou latente. Em conjunto, o risco de úlcera, hemorragia e perfuração digestiva aumenta de forma aditiva. Considerar gastroproteção (inibidor da bomba de protões) nos doentes de risco, usar a menor dose eficaz de cada fármaco e vigiar sintomas digestivos.',
  explanation_en = 'NSAIDs such as naproxen increase the risk of serious gastrointestinal events (bleeding, ulceration and perforation), with a higher risk in the elderly and in patients with a history of peptic ulcer or GI bleeding; concomitant use of oral corticosteroids is a recognised factor increasing the risk of GI bleeding in the NSAID labels. Prednisolone carries a precaution to use with caution in patients with active or latent peptic ulcer. Together, the risk of ulcer, bleeding and digestive perforation increases additively. Consider gastroprotection (proton pump inhibitor) in at-risk patients, use the lowest effective dose of each drug and monitor digestive symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'naproxeno'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'naproxeno'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

-- 5/5 — PREDNISOLONA + VORICONAZOL (inibição do CYP3A4 — excesso de corticoide)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Prednisolona + voriconazol: o azol inibe o CYP3A4 e pode causar excesso de corticoide, Cushing e supressão adrenal. Monitorizar de perto.',
  summary_pro_en = 'Prednisolone + voriconazole: the azole inhibits CYP3A4 and can cause corticosteroid excess, Cushing and adrenal suppression. Monitor closely.',
  explanation_pt = 'O voriconazol inibe o CYP3A4, a enzima que metaboliza os corticosteroides, e o rótulo do voriconazol indica que essa inibição pode levar a excesso de corticoide e supressão adrenal, com síndrome de Cushing (com ou sem insuficiência adrenal subsequente) reportada em doentes a receber voriconazol concomitantemente com corticosteroides; recomenda monitorizar cuidadosamente a disfunção adrenal durante e após o tratamento com voriconazol, e instruir o doente para procurar cuidados médicos imediatos perante sinais de Cushing ou insuficiência adrenal (fadiga, hipotensão, hiperpigmentação, perda de peso). Considerar reduzir a dose do corticoide e vigiar os efeitos metabólicos (glicemia, retenção de líquidos).',
  explanation_en = 'Voriconazole inhibits CYP3A4, the enzyme that metabolises corticosteroids, and the voriconazole label states that this inhibition can lead to corticosteroid excess and adrenal suppression, with Cushing syndrome (with or without subsequent adrenal insufficiency) reported in patients receiving voriconazole concomitantly with corticosteroids; careful monitoring for adrenal dysfunction during and after voriconazole treatment is recommended, and patients should be instructed to seek immediate medical care if signs of Cushing or adrenal insufficiency appear (fatigue, hypotension, hyperpigmentation, weight loss). Consider reducing the corticosteroid dose and monitor metabolic effects (glycaemia, fluid retention).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'prednisolona'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'prednisolona'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));
