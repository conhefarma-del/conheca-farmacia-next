-- =====================================================================
-- 116 — Explicações fármaco-fármaco dos pares moderados do CETOCONAZOL
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 7 pares moderados do cetoconazol que os tinham vazios e não
-- foram cobertos noutras migrações (atorvastatina+cetoconazol na 115;
-- cetoconazol+omeprazol na 113).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do INFARMED.
-- Mecanismo central: o cetoconazol é um inibidor potente do CYP3A4 (e da
-- P-gp) — eleva os níveis de alprazolam, amlodipina, sildenafil e dos
-- anti-histamínicos (desloratadina, loratadina); com a nevirapina a
-- interação é bidirecional (indução pelo NNRTI reduz o cetoconazol).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/7 — ALPRAZOLAM + CETOCONAZOL (inibição do CYP3A4 — sedação aumentada)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Alprazolam + cetoconazol: o azol inibe o CYP3A4 e pode aumentar muito os níveis do alprazolam, com sedação e depressão respiratória. Contraindicado (rótulo do cetoconazol).',
  summary_pro_en = 'Alprazolam + ketoconazole: the azole inhibits CYP3A4 and can greatly raise alprazolam levels, with sedation and respiratory depression. Contraindicated (ketoconazole label).',
  explanation_pt = 'O alprazolam é metabolizado pelo CYP3A4, e o cetoconazol é um inibidor potente desta enzima, podendo aumentar marcadamente as concentrações da benzodiazepina e os seus efeitos (sedação, sonolência, ataxia, depressão respiratória), sobretudo em idosos. O rótulo do cetoconazol considera a coadministração com alprazolam (tal como midazolam e triazolam orais) contraindicada, porque a elevação das concentrações pode potenciar e prolongar os efeitos hipnóticos e sedativos. Não associar; considerar uma benzodiazepina ou ansiolítico alternativo não metabolizado pelo CYP3A4.',
  explanation_en = 'Alprazolam is metabolised by CYP3A4, and ketoconazole is a potent inhibitor of this enzyme, potentially raising benzodiazepine concentrations and effects markedly (sedation, drowsiness, ataxia, respiratory depression), especially in the elderly. The ketoconazole label considers co-administration with alprazolam (like oral midazolam and triazolam) contraindicated, because the elevated concentrations can potentiate and prolong hypnotic and sedative effects. Do not combine; consider an alternative benzodiazepine or anxiolytic not metabolised by CYP3A4.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alprazolam'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- 2/7 — AMLODIPINA + CETOCONAZOL (inibição do CYP3A4 — hipotensão/edema)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Amlodipina + cetoconazol: inibição do CYP3A4 com aumento dos níveis da amlodipina. Vigiar hipotensão e edema.',
  summary_pro_en = 'Amlodipine + ketoconazole: CYP3A4 inhibition raising amlodipine levels. Monitor hypotension and oedema.',
  explanation_pt = 'A amlodipina é substrato do CYP3A4, e o cetoconazol, ao inibir esta enzima, pode aumentar as suas concentrações e potenciar os efeitos vasodilatadores (hipotensão, edema periférico, rubor, cefaleia). Na maioria dos doentes a interação é gerida com monitorização da pressão arterial e dos sinais de edema; se surgirem sintomas, considerar reduzir a dose da amlodipina ou usar um anti-hipertensor menos dependente do CYP3A4 durante o antifúngico.',
  explanation_en = 'Amlodipine is a CYP3A4 substrate, and ketoconazole, by inhibiting this enzyme, can raise its concentrations and potentiate the vasodilator effects (hypotension, peripheral oedema, flushing, headache). In most patients the interaction is managed by monitoring blood pressure and signs of oedema; if symptoms arise, consider reducing the amlodipine dose or using an antihypertensive less dependent on CYP3A4 during the antifungal.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amlodipina'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- 3/7 — CETOCONAZOL + DESLORATADINA (aumento dos níveis do anti-histamínico)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + desloratadina: o azol aumenta os níveis da desloratadina (CYP3A4), geralmente sem prolongamento do QT relevante. Vigiar sonolência.',
  summary_pro_en = 'Ketoconazole + desloratadine: the azole raises desloratadine levels (CYP3A4), usually without relevant QT prolongation. Monitor drowsiness.',
  explanation_pt = 'O cetoconazol, ao inibir o CYP3A4, pode aumentar as concentrações da desloratadina; no entanto, a desloratadina e o seu metabolito ativo têm margem de segurança ampla e a associação não se associa a prolongamento significativo do QT (ao contrário da terfenadina/astemizol do passado). Na prática, a interação é geralmente bem tolerada; vigiar sonolência ou sedação em doentes suscetíveis e usar a menor dose eficaz do anti-histamínico durante o tratamento antifúngico.',
  explanation_en = 'Ketoconazole, by inhibiting CYP3A4, can raise desloratadine concentrations; however, desloratadine and its active metabolite have a wide safety margin and the combination is not associated with significant QT prolongation (unlike the old terfenadine/astemizole). In practice, the interaction is generally well tolerated; monitor drowsiness or sedation in susceptible patients and use the lowest effective antihistamine dose during antifungal treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'desloratadina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'desloratadina'));

-- 4/7 — CETOCONAZOL + FEXOFENADINA (inibição da P-gp — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + fexofenadina: o azol pode aumentar os níveis da fexofenadina (inibição da P-gp), com possível sonolência. Vigiar.',
  summary_pro_en = 'Ketoconazole + fexofenadine: the azole can raise fexofenadine levels (P-gp inhibition), with possible drowsiness. Monitor.',
  explanation_pt = 'A fexofenadina é substrato da glicoproteína-P (P-gp), e o cetoconazol, ao inibir este transportador, pode aumentar as concentrações da fexofenadina. Apesar de a fexofenadina ser um anti-histamínico não sedativo, níveis elevados podem causar sonolência, cefaleia ou tonturas em doentes suscetíveis. A interação é geralmente ligeira; vigiar sintomas e considerar ajustar a dose do anti-histamínico durante o tratamento antifúngico.',
  explanation_en = 'Fexofenadine is a P-glycoprotein (P-gp) substrate, and ketoconazole, by inhibiting this transporter, can raise fexofenadine concentrations. Although fexofenadine is a non-sedating antihistamine, high levels can cause drowsiness, headache or dizziness in susceptible patients. The interaction is generally mild; monitor symptoms and consider adjusting the antihistamine dose during antifungal treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'fexofenadina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'fexofenadina'));

-- 5/7 — CETOCONAZOL + LORATADINA (aumento dos níveis do anti-histamínico)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + loratadina: o azol aumenta os níveis da loratadina (CYP3A4), sem prolongamento do QT relevante. Vigiar sonolência.',
  summary_pro_en = 'Ketoconazole + loratadine: the azole raises loratadine levels (CYP3A4), without relevant QT prolongation. Monitor drowsiness.',
  explanation_pt = 'A loratadina é metabolizada pelo CYP3A4, e o cetoconazol pode aumentar as suas concentrações. Ao contrário dos anti-histamínicos de primeira geração, a loratadina não se associa a prolongamento significativo do QT, mesmo com níveis elevados; a interação manifesta-se sobretudo por sonolência ou sedação ligeira em doentes suscetíveis. Vigiar sintomas, usar a menor dose eficaz e considerar um anti-histamínico alternativo se a sedação for incómoda.',
  explanation_en = 'Loratadine is metabolised by CYP3A4, and ketoconazole can raise its concentrations. Unlike first-generation antihistamines, loratadine is not associated with significant QT prolongation, even at high levels; the interaction manifests mainly as drowsiness or mild sedation in susceptible patients. Monitor symptoms, use the lowest effective dose and consider an alternative antihistamine if sedation is troublesome.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'loratadina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'loratadina'));

-- 6/7 — CETOCONAZOL + NEVIRAPINA (interação bidirecional — indução)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + nevirapina: a nevirapina reduz os níveis do cetoconazol e o azol aumenta os da nevirapina. O rótulo desaconselha a associação; vigiar resposta e função hepática.',
  summary_pro_en = 'Ketoconazole + nevirapine: nevirapine lowers ketoconazole levels and the azole raises nevirapine levels. The label advises against the combination; monitor response and liver function.',
  explanation_pt = 'A nevirapina, inibidor não nucleósido da transcriptase reversa, induz o CYP3A4 e reduz as concentrações do cetoconazol, podendo comprometer o tratamento antifúngico; em sentido inverso, o cetoconazol inibe o CYP3A4 e pode aumentar os níveis da nevirapina, com maior risco de efeitos adversos (nomeadamente hepatotoxicidade e erupção cutânea). O rótulo da nevirapina indica que o cetoconazol e a nevirapina não devem ser administrados concomitantemente (a redução do cetoconazol pode comprometer a eficácia antifúngica) e que o aumento da exposição à nevirapina exige vigilância apertada dos efeitos adversos. Se a associação for inevitável, monitorizar a resposta clínica à infeção fúngica e a função hepática/rash.',
  explanation_en = 'Nevirapine, a non-nucleoside reverse transcriptase inhibitor, induces CYP3A4 and lowers ketoconazole concentrations, potentially compromising antifungal treatment; conversely, ketoconazole inhibits CYP3A4 and can raise nevirapine levels, with a higher risk of adverse effects (notably hepatotoxicity and skin rash). The nevirapine label states that ketoconazole and nevirapine should not be administered concomitantly (reduced ketoconazole may compromise antifungal efficacy) and that increased nevirapine exposure warrants close monitoring for adverse effects. If the combination is unavoidable, monitor the clinical response to the fungal infection and liver function/rash.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'nevirapina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'nevirapina'));

-- 7/7 — CETOCONAZOL + SILDENAFIL (inibição do CYP3A4 — toxicidade)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + sildenafil: o azol aumenta muito os níveis do sildenafil (CYP3A4), com risco de hipotensão, priapismo e toxicidade. Considerar dose inicial de 25 mg.',
  summary_pro_en = 'Ketoconazole + sildenafil: the azole greatly raises sildenafil levels (CYP3A4), with a risk of hypotension, priapism and toxicity. Consider a starting dose of 25 mg.',
  explanation_pt = 'O sildenafil é substrato do CYP3A4, e o cetoconazol, inibidor potente desta enzima, pode aumentar marcadamente as suas concentrações, potenciando a vasodilatação (hipotensão, cefaleia, rubor, congestão nasal) e o risco de priapismo. O rótulo do sildenafil recomenda considerar uma dose inicial de 25 mg em doentes tratados com inibidores potentes do CYP3A4 (ex.: cetoconazol, itraconazol). Alertar o doente para sinais de alarme (priapismo, dor torácica) e evitar o uso simultâneo de nitratos.',
  explanation_en = 'Sildenafil is a CYP3A4 substrate, and ketoconazole, a potent inhibitor of this enzyme, can markedly raise its concentrations, potentiating vasodilation (hypotension, headache, flushing, nasal congestion) and the risk of priapism. The sildenafil label recommends considering a starting dose of 25 mg in patients treated with strong CYP3A4 inhibitors (e.g., ketoconazole, itraconazole). Alert the patient to alarm signs (priapism, chest pain) and avoid the simultaneous use of nitrates.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'));
