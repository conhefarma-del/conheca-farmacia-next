-- =====================================================================
-- 113 — Explicações fármaco-fármaco dos pares moderados do OMEPRAZOL
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 10 pares moderados do omeprazol que os tinham vazios.
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do INFARMED.
-- Mecanismos centrais do omeprazol (inibidor da bomba de protões):
--   1. Elevação do pH gástrico — reduz a absorção de fármacos que exigem
--      meio ácido (cetoconazol, itraconazol, atazanavir, cloroquina, ferro,
--      levotiroxina, alendronato);
--   2. Inibição do CYP2C19 — fármacos metabolizados por esta enzima
--      (clopidogrel — interação clinicamente relevante, fenitoína);
--   3. Interação bidirecional com o voriconazol (inibição do CYP2C19
--      nos dois sentidos).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/10 — ALENDRONATO + OMEPRAZOL (absorção reduzida / risco ósseo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Omeprazol + alendronato: os IBP podem reduzir a absorção dos bisfosfonatos e o uso prolongado associa-se a maior risco de fraturas. Reavaliar a necessidade do IBP.',
  summary_pro_en = 'Omeprazole + alendronate: PPIs can reduce bisphosphonate absorption and long-term use is associated with a higher fracture risk. Reassess the PPI need.',
  explanation_pt = 'O omeprazol reduz a acidez gástrica, o que pode diminuir a absorção de alguns bisfosfonatos orais e a sua eficácia na osteoporose; além disso, o uso prolongado de inibidores da bomba de protões associa-se a um risco aumentado de fraturas ósseas (possivelmente por redução da absorção de cálcio e efeitos diretos no metabolismo ósseo). Em doentes a fazer alendronato, o IBP deve ser usado apenas com indicação clara, na menor dose e pelo menor tempo possível; reavaliar a necessidade de gastroproteção e garantir aporte adequado de cálcio e vitamina D.',
  explanation_en = 'Omeprazole reduces gastric acidity, which can decrease the absorption of some oral bisphosphonates and their efficacy in osteoporosis; additionally, long-term proton pump inhibitor use is associated with an increased risk of bone fractures (possibly through reduced calcium absorption and direct effects on bone metabolism). In patients taking alendronate, the PPI should be used only with a clear indication, at the lowest dose and for the shortest time possible; reassess the need for gastroprotection and ensure adequate calcium and vitamin D intake.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alendronato'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alendronato'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 2/10 — ATAZANAVIR + OMEPRAZOL (pH gástrico elevado — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Omeprazol + atazanavir: o IBP reduz marcadamente a exposição ao atazanavir, com risco de falência antirretrovírica. Evitar; se necessário, IBP ≤20 mg 12 horas antes com reforço e vigilância.',
  summary_pro_en = 'Omeprazole + atazanavir: the PPI markedly reduces atazanavir exposure, with a risk of antiretroviral failure. Avoid; if needed, PPI ≤20 mg 12 hours before with boosting and monitoring.',
  explanation_pt = 'A absorção do atazanavir depende de um pH gástrico ácido: o omeprazol, ao suprimir a secreção ácida, reduz a solubilidade e a concentração plasmática do atazanavir de forma clinicamente significativa, com risco de perda de resposta virológica e de desenvolvimento de resistência (o rótulo do atazanavir alerta explicitamente para este risco). Se a associação for inevitável, o rótulo recomenda não exceder uma dose de IBP comparável a omeprazol 20 mg e administrá-la aproximadamente 12 horas antes da toma de atazanavir 300 mg com ritonavir 100 mg, com monitorização virológica. Em doentes com VIH, qualquer fármaco que eleve o pH gástrico deve ser gerido com cuidado e reavaliado.',
  explanation_en = 'Atazanavir absorption depends on an acidic gastric pH: omeprazole, by suppressing acid secretion, reduces the solubility and plasma concentration of atazanavir in a clinically significant way, with a risk of loss of virologic response and development of resistance (the atazanavir label explicitly warns about this risk). If the combination is unavoidable, the label recommends not exceeding a PPI dose comparable to omeprazole 20 mg and taking it approximately 12 hours before atazanavir 300 mg with ritonavir 100 mg, with virological monitoring. In HIV patients, any drug that raises gastric pH must be managed carefully and reassessed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atazanavir'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atazanavir'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 3/10 — CETOCONAZOL + OMEPRAZOL (pH gástrico elevado — absorção muito reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Omeprazol + cetoconazol: a absorção do cetoconazol depende de pH ácido e é drasticamente reduzida pelos IBP. Evitar a associação.',
  summary_pro_en = 'Omeprazole + ketoconazole: ketoconazole absorption depends on acidic pH and is drastically reduced by PPIs. Avoid the combination.',
  explanation_pt = 'O cetoconazol (comprimido) é uma base fraca cuja dissolução e absorção oral dependem fortemente do pH gástrico ácido. O omeprazol, ao suprimir a secreção ácida, reduz de forma clinicamente significativa as concentrações plasmáticas do cetoconazol, podendo comprometer o tratamento de infeções fúngicas sistémicas. O rótulo do cetoconazol e o Prontuário Terapêutico recomendam evitar a associação ou, se inevitável, considerar formulações alternativas e monitorizar a resposta clínica ao antifúngico.',
  explanation_en = 'Ketoconazole (tablet) is a weak base whose dissolution and oral absorption depend strongly on acidic gastric pH. Omeprazole, by suppressing acid secretion, reduces ketoconazole plasma concentrations in a clinically significant way, potentially compromising the treatment of systemic fungal infections. The ketoconazole label and the Portuguese Prontuário Terapêutico recommend avoiding the combination or, if unavoidable, considering alternative formulations and monitoring the clinical response to the antifungal.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 4/10 — CLOPIDOGREL + OMEPRAZOL (inibição do CYP2C19)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Clopidogrel + omeprazol: o omeprazol inibe o CYP2C19 e reduz a ativação do clopidogrel, diminuindo a proteção antiagregante. Evitar; preferir pantoprazol ou antagonista H2.',
  summary_pro_en = 'Clopidogrel + omeprazole: omeprazole inhibits CYP2C19 and reduces clopidogrel activation, decreasing antiplatelet protection. Avoid; prefer pantoprazole or an H2 antagonist.',
  explanation_pt = 'O clopidogrel é uma pró-fármaco que depende do CYP2C19 para se converter no metabolito ativo; o omeprazol é um inibidor potente desta enzima e reduz a formação do metabolito ativo e a inibição plaquetária, com aumento documentado do risco de eventos cardiovasculares. O rótulo do clopidogrel desaconselha a coadministração com inibidores do CYP2C19 como o omeprazol e o esomeprazol. Sempre que for necessária gastroproteção em doentes a tomar clopidogrel, preferir pantoprazol (menos inibidor do CYP2C19) ou um antagonista H2, e evitar a associação.',
  explanation_en = 'Clopidogrel is a prodrug that depends on CYP2C19 to be converted into the active metabolite; omeprazole is a potent inhibitor of this enzyme and reduces the formation of the active metabolite and platelet inhibition, with a documented increased risk of cardiovascular events. The clopidogrel label advises against co-administration with CYP2C19 inhibitors such as omeprazole and esomeprazole. Whenever gastroprotection is needed in patients taking clopidogrel, prefer pantoprazole (less CYP2C19 inhibition) or an H2 antagonist, and avoid the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 5/10 — CLOROQUINA + OMEPRAZOL (pH gástrico elevado — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Omeprazol + cloroquina: o pH elevado pode reduzir a absorção da cloroquina. Monitorizar a resposta e separar a toma.',
  summary_pro_en = 'Omeprazole + chloroquine: raised pH can reduce chloroquine absorption. Monitor response and separate administration.',
  explanation_pt = 'A cloroquina é uma base fraca cuja absorção gastrointestinal pode ser reduzida quando o pH gástrico está elevado, como acontece com os inibidores da bomba de protões. Embora o impacto clínico seja variável, a redução da absorção pode comprometer a profilaxia ou o tratamento antimalárico ou o uso em doenças autoimunes. Recomenda-se separar a administração (por exemplo, omeprazol em jejum e cloroquina em horário afastado), garantir a adesão e monitorizar a resposta clínica; em doentes com falência terapêutica inexplicada, reavaliar a associação.',
  explanation_en = 'Chloroquine is a weak base whose gastrointestinal absorption can be reduced when gastric pH is raised, as happens with proton pump inhibitors. Although the clinical impact is variable, reduced absorption can compromise malaria prophylaxis or treatment or use in autoimmune diseases. Separate administration (for example, omeprazole on an empty stomach and chloroquine at a distant time), ensure adherence and monitor the clinical response; in patients with unexplained therapeutic failure, reassess the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cloroquina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 6/10 — FENITOÍNA + OMEPRAZOL (inibição do CYP2C19)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fenitoína + omeprazol: o IBP pode aumentar os níveis de fenitoína (inibição do CYP2C19). Monitorizar níveis e sinais de toxicidade.',
  summary_pro_en = 'Phenytoin + omeprazole: the PPI can raise phenytoin levels (CYP2C19 inhibition). Monitor levels and signs of toxicity.',
  explanation_pt = 'A fenitoína é metabolizada no fígado, em parte pelo CYP2C19, a mesma enzima que o omeprazol inibe. A coadministração pode aumentar as concentrações de fenitoína e precipitar toxicidade (nistagmo, ataxia, sedação, disartria), sobretudo no início do IBP ou com doses elevadas. Recomenda-se monitorizar os níveis séricos de fenitoína e os sinais de toxicidade ao iniciar ou suspender o omeprazol, ajustando a dose conforme necessário. Em doentes epiléticos com controlo estável, preferir, se possível, um IBP com menor potencial de interação.',
  explanation_en = 'Phenytoin is metabolised in the liver, partly by CYP2C19, the same enzyme inhibited by omeprazole. Co-administration can raise phenytoin concentrations and precipitate toxicity (nystagmus, ataxia, sedation, dysarthria), especially at PPI start or at high doses. Monitor serum phenytoin levels and signs of toxicity when starting or stopping omeprazole, adjusting the dose as needed. In epileptic patients with stable control, prefer, if possible, a PPI with lower interaction potential.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fenitoina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fenitoina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 7/10 — FERRO + OMEPRAZOL (pH gástrico elevado — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ferro + omeprazol: o pH elevado reduz a absorção do ferro não-heme. Monitorizar a resposta à suplementação e considerar ferro parenteral se necessário.',
  summary_pro_en = 'Iron + omeprazole: raised pH reduces non-haem iron absorption. Monitor the response to supplementation and consider parenteral iron if needed.',
  explanation_pt = 'A absorção do ferro não-heme (presente nos suplementos orais) depende do pH gástrico ácido, que mantém o ferro na forma ferrosa mais absorvível; o omeprazol, ao suprimir a secreção ácida, pode reduzir a absorção e a eficácia da suplementação em doentes com anemia ferropriva. Em doentes a fazer IBP com resposta insatisfatória ao ferro oral, considerar aumentar a dose, separar as tomas, preferir ferro heme ou administração em dias alternados, e avaliar a necessidade de ferro intravenoso.',
  explanation_en = 'Non-haem iron absorption (present in oral supplements) depends on acidic gastric pH, which keeps iron in the more absorbable ferrous form; omeprazole, by suppressing acid secretion, can reduce absorption and the efficacy of supplementation in patients with iron deficiency anaemia. In patients on a PPI with an unsatisfactory response to oral iron, consider increasing the dose, separating administrations, preferring haem iron or alternate-day dosing, and assess the need for intravenous iron.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ferro'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ferro'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 8/10 — ITRACONAZOL + OMEPRAZOL (pH gástrico elevado — absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Itraconazol (cápsulas) + omeprazol: a absorção depende de pH ácido e é reduzida pelos IBP. Separar a toma e considerar a solução oral.',
  summary_pro_en = 'Itraconazole (capsules) + omeprazole: absorption depends on acidic pH and is reduced by PPIs. Separate administration and consider the oral solution.',
  explanation_pt = 'As cápsulas de itraconazol necessitam de um meio gástrico ácido para dissolver e absorver o fármaco; o omeprazol, ao elevar o pH, reduz as concentrações plasmáticas do itraconazol e pode comprometer o tratamento ou a profilaxia antifúngica. Recomenda-se separar a administração (o itraconazol com uma refeição e o IBP em jejum) e, em alternativa, usar a solução oral de itraconazol, menos dependente do pH gástrico. Monitorizar a resposta clínica e, quando disponível, a concentração do antifúngico.',
  explanation_en = 'Itraconazole capsules require an acidic gastric medium to dissolve and absorb the drug; omeprazole, by raising the pH, reduces itraconazole plasma concentrations and can compromise antifungal treatment or prophylaxis. Separate administration (itraconazole with a meal and the PPI on an empty stomach) and, alternatively, use the itraconazole oral solution, which is less pH-dependent. Monitor the clinical response and, when available, the antifungal concentration.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 9/10 — LEVOTIROXINA + OMEPRAZOL (absorção reduzida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Levotiroxina + omeprazol: o IBP pode reduzir a absorção da levotiroxina (hipocloridria). Manter a levotiroxina em jejum, separar a toma e monitorizar TSH.',
  summary_pro_en = 'Levothyroxine + omeprazole: the PPI can reduce levothyroxine absorption (hypochlorhydria). Keep levothyroxine on an empty stomach, separate administration and monitor TSH.',
  explanation_pt = 'O rótulo da levotiroxina indica que a acidez gástrica é essencial para uma absorção adequada e que os inibidores da bomba de protões podem causar hipocloridria, afetar o pH intragástrico e reduzir a absorção da levotiroxina, com possível necessidade de aumento da dose em alguns doentes hipotiroideus; recomenda monitorizar o doente de forma apropriada. Na prática, manter a levotiroxina sempre em jejum, 30–60 minutos antes do pequeno-almoço, separar a toma do IBP o máximo possível e monitorizar a TSH, ajustando a dose se necessário, sobretudo ao iniciar ou suspender o IBP.',
  explanation_en = 'The levothyroxine label states that gastric acidity is essential for adequate absorption and that proton pump inhibitors can cause hypochlorhydria, affect intragastric pH and reduce levothyroxine absorption, potentially raising dose requirements in some hypothyroid patients; appropriate patient monitoring is recommended. In practice, keep levothyroxine always on an empty stomach, 30–60 minutes before breakfast, separate it from the PPI as much as possible and monitor TSH, adjusting the dose if needed, especially when starting or stopping the PPI.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

-- 10/10 — OMEPRAZOL + VORICONAZOL (interação bidirecional CYP2C19)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Omeprazol + voriconazol: interação bidirecional — o voriconazol aumenta o omeprazol (2–4×) e o omeprazol aumenta o voriconazol (~15–40%). Reduzir a dose do omeprazol para metade.',
  summary_pro_en = 'Omeprazole + voriconazole: bidirectional interaction — voriconazole raises omeprazole (2–4×) and omeprazole increases voriconazole (~15–40%). Halve the omeprazole dose.',
  explanation_pt = 'A interação é bidirecional e mediada pelo CYP2C19: o voriconazol inibe o CYP2C19 e pode aumentar as concentrações do omeprazol (Cmax ≈2× e AUC ≈4× segundo o rótulo do voriconazol), enquanto o omeprazol aumenta a exposição ao voriconazol em cerca de 15% (Cmax) e 40% (AUC). O rótulo do voriconazol recomenda reduzir a dose do omeprazol para metade quando se inicia o voriconazol em doentes com omeprazol ≥40 mg (sem necessidade de ajuste do voriconazol). Na prática, vigiar os efeitos adversos de ambos (cefaleia, diarreia, hipomagnesemia do IBP; fotossensibilidade, hepatotoxicidade e alterações visuais do voriconazol) e considerar a monitorização terapêutica do voriconazol.',
  explanation_en = 'The interaction is bidirectional and mediated by CYP2C19: voriconazole inhibits CYP2C19 and can raise omeprazole concentrations (Cmax ≈2× and AUC ≈4× per the voriconazole label), while omeprazole increases voriconazole exposure by about 15% (Cmax) and 40% (AUC). The voriconazole label recommends halving the omeprazole dose when starting voriconazole in patients on omeprazole ≥40 mg (no voriconazole dose adjustment needed). In practice, monitor the adverse effects of both (headache, diarrhoea, PPI hypomagnesaemia; voriconazole photosensitivity, hepatotoxicity and visual disturbances) and consider voriconazole therapeutic drug monitoring.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'omeprazol'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'omeprazol'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));
