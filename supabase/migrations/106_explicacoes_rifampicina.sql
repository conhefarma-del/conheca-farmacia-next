-- =====================================================================
-- 106 — Explicações fármaco-fármaco dos pares moderados da RIFAMPICINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 12 pares moderados da rifampicina que os tinham vazios —
-- sétimo lote dos pares moderados sem explicação (319 → 218 → 202 → 190).
-- NOTA: os pares rifampicina+amiodarona e rifampicina+carbamazepina já
-- foram preenchidos nas migrações 103 e 104 (não repetidos aqui).
-- Padrão da 089/100/103/104/105: UPDATE com LEAST/GREATEST canónico +
-- updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados citados no campo
-- source_* já existente de cada par (DailyMed/FDA, EMA/EMC-UK).
-- Mecanismo central: a rifampicina é indutora potente do CYP3A4 (e de
-- outras monooxigenases) e reduz os níveis dos fármacos coadministrados.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/12 — ATORVASTATINA + RIFAMPICINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + rifampicina: a rifampicina induz o CYP3A4 e reduz os níveis de atorvastatina, diminuindo o efeito hipolipemiante. Vigiar o LDL e ajustar a dose.',
  summary_pro_en = 'Atorvastatin + rifampicin: rifampicin induces CYP3A4 and lowers atorvastatin levels, reducing the lipid-lowering effect. Monitor LDL and adjust the dose.',
  explanation_pt = 'A rifampicina é um indutor potente do CYP3A4, a principal via de metabolização da atorvastatina; em uso crónico, reduz substancialmente as suas concentrações e compromete o controlo lipídico. Recomenda-se vigiar o perfil lipídico e aumentar a dose de atorvastatina conforme necessário, ou preferir uma estatina menos dependente do CYP3A4 (ex.: pravastatina, rosuvastatina) durante o tratamento com rifampicina.',
  explanation_en = 'Rifampicin is a potent inducer of CYP3A4, the main pathway of atorvastatin metabolism; with chronic use it substantially reduces its concentrations and compromises lipid control. Monitor the lipid profile and increase the atorvastatin dose as needed, or prefer a statin less dependent on CYP3A4 (e.g. pravastatin, rosuvastatin) during rifampicin treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 2/12 — BEDAQUILINA + RIFAMPICINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Bedaquilina + rifampicina: a rifampicina reduz drasticamente os níveis de bedaquilina (indução do CYP3A4), com risco de falência terapêutica. Evitar a associação.',
  summary_pro_en = 'Bedaquiline + rifampicin: rifampicin markedly reduces bedaquiline levels (CYP3A4 induction), with risk of therapeutic failure. Avoid the combination.',
  explanation_pt = 'A bedaquilina é metabolizada pelo CYP3A4 e a rifampicina, indutora potente, pode reduzir as suas concentrações em mais de 50%, comprometendo o tratamento da tuberculose multirresistente. O rótulo da bedaquilina desaconselha a associação com indutores potentes do CYP3A4. Deve evitar-se a coadministração; se for necessária, considerar esquemas alternativos e monitorizar a resposta clínica e microbiológica.',
  explanation_en = 'Bedaquiline is metabolised by CYP3A4 and rifampicin, a potent inducer, can reduce its concentrations by more than 50%, compromising multidrug-resistant tuberculosis treatment. The bedaquiline label advises against combination with potent CYP3A4 inducers. The coadministration should be avoided; if needed, consider alternative regimens and monitor the clinical and microbiological response.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'bedaquilina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'bedaquilina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 3/12 — CETOCONAZOL + RIFAMPICINA (interação bidirecional CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + rifampicina: a rifampicina reduz os níveis de cetoconazol (falência antifúngica) e o cetoconazol eleva os de rifampicina. Evitar a associação.',
  summary_pro_en = 'Ketoconazole + rifampicin: rifampicin lowers ketoconazole levels (antifungal failure) and ketoconazole raises rifampicin levels. Avoid the combination.',
  explanation_pt = 'A interação é bidirecional: a rifampicina induz o CYP3A4 e reduz drasticamente as concentrações de cetoconazol (perda do efeito antifúngico), enquanto o cetoconazol inibe o CYP3A4 e pode aumentar os níveis de rifampicina, com risco de hepatotoxicidade. Deve evitar-se a associação; se for inevitável, monitorizar a resposta antifúngica e a função hepática, considerando alternativas antifúngicas não dependentes do CYP3A4 (ex.: anfotericina B, equinocandinas).',
  explanation_en = 'The interaction is bidirectional: rifampicin induces CYP3A4 and markedly reduces ketoconazole concentrations (loss of antifungal effect), while ketoconazole inhibits CYP3A4 and can raise rifampicin levels, with risk of hepatotoxicity. The combination should be avoided; if unavoidable, monitor the antifungal response and liver function, considering antifungal alternatives not dependent on CYP3A4 (e.g. amphotericin B, echinocandins).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cetoconazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 4/12 — DOXICICLINA + RIFAMPICINA (indução do metabolismo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Doxiciclina + rifampicina: a rifampicina acelera o metabolismo da doxiciclina e reduz os seus níveis em ~50%, com risco de falência terapêutica. Evitar ou usar dose dupla.',
  summary_pro_en = 'Doxycycline + rifampicin: rifampicin accelerates doxycycline metabolism and lowers its levels by ~50%, with risk of therapeutic failure. Avoid or use a doubled dose.',
  explanation_pt = 'A rifampicina induz as enzimas hepáticas que metabolizam a doxiciclina e pode reduzir a sua semivida e as concentrações em cerca de 50%, comprometendo o tratamento de brucelose, rickettsioses e outras zoonoses (associação clássica documentada). Recomenda-se evitar a associação; se for inevitável, considerar duplicar a dose de doxiciclina (com vigilância) ou escolher um esquema alternativo.',
  explanation_en = 'Rifampicin induces the hepatic enzymes that metabolise doxycycline and can reduce its half-life and concentrations by about 50%, compromising the treatment of brucellosis, rickettsioses and other zoonoses (a classically documented combination). Avoid the association; if unavoidable, consider doubling the doxycycline dose (with monitoring) or choosing an alternative regimen.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'doxiciclina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'doxiciclina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 5/12 — FLUCONAZOL + RIFAMPICINA (indução do CYP2C9/CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluconazol + rifampicina: a rifampicina reduz os níveis de fluconazol (~25–50%), podendo comprometer o tratamento antifúngico. Vigiar e considerar ajuste de dose.',
  summary_pro_en = 'Fluconazole + rifampicin: rifampicin lowers fluconazole levels (~25–50%), potentially compromising antifungal treatment. Monitor and consider dose adjustment.',
  explanation_pt = 'A rifampicina induz o CYP2C9 e o CYP3A4, vias de metabolização do fluconazol, e pode reduzir as suas concentrações em cerca de 25–50% e encurtar a semivida; o efeito antifúngico pode ficar comprometido em infeções graves. Recomenda-se vigiar a resposta clínica e considerar aumentar a dose de fluconazol durante a associação, monitorizando a função hepática.',
  explanation_en = 'Rifampicin induces CYP2C9 and CYP3A4, pathways of fluconazole metabolism, and can reduce its concentrations by about 25–50% and shorten the half-life; the antifungal effect may be compromised in severe infections. Monitor the clinical response and consider increasing the fluconazole dose during the combination, monitoring liver function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluconazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 6/12 — ITRACONAZOL + RIFAMPICINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Itraconazol + rifampicina: a rifampicina reduz drasticamente os níveis de itraconazol (indução do CYP3A4), com falência antifúngica. Contraindicado na prática.',
  summary_pro_en = 'Itraconazole + rifampicin: rifampicin markedly reduces itraconazole levels (CYP3A4 induction), with antifungal failure. Practically contraindicated.',
  explanation_pt = 'O itraconazol é metabolizado pelo CYP3A4; a rifampicina, indutora potente, pode reduzir as suas concentrações e as do metabolito ativo (hidroxi-itraconazol) para níveis indetetáveis, com perda total do efeito antifúngico. A associação é praticamente contraindicada; se for inevitável, considerar um antifúngico alternativo (anfotericina B, equinocandinas) ou monitorizar os níveis de itraconazol se disponíveis.',
  explanation_en = 'Itraconazole is metabolised by CYP3A4; rifampicin, a potent inducer, can reduce its concentrations and those of the active metabolite (hydroxy-itraconazole) to undetectable levels, with complete loss of antifungal effect. The combination is practically contraindicated; if unavoidable, consider an alternative antifungal (amphotericin B, echinocandins) or monitor itraconazole levels if available.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'itraconazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 7/12 — LINEZOLIDA + RIFAMPICINA (redução de níveis)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Linezolida + rifampicina: a rifampicina reduz os níveis de linezolida (~30%), com possível perda de eficácia. Vigiar a resposta clínica.',
  summary_pro_en = 'Linezolid + rifampicin: rifampicin lowers linezolid levels (~30%), with possible loss of efficacy. Monitor the clinical response.',
  explanation_pt = 'A rifampicina aumenta a clearance da linezolida e reduz a sua exposição em cerca de 30%, mesmo que a linezolida não seja metabolizada de forma significativa pelo CYP; a relevância clínica é debatida, mas o risco de falência é maior em infeções graves (ex.: endocardite, pneumonia por estafilococos resistentes). Recomenda-se vigiar a resposta clínica e considerar alternativa (ex.: vancomicina, daptomicina) quando a associação for desaconselhada pelo contexto.',
  explanation_en = 'Rifampicin increases linezolid clearance and reduces its exposure by about 30%, even though linezolid is not significantly CYP-metabolised; the clinical relevance is debated, but the failure risk is higher in severe infections (e.g. endocarditis, resistant staphylococcal pneumonia). Monitor the clinical response and consider an alternative (e.g. vancomycin, daptomycin) when the combination is discouraged by the context.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'linezolida'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 8/12 — OMEPRAZOL + RIFAMPICINA (indução do CYP2C19/CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Omeprazol + rifampicina: a rifampicina reduz os níveis de omeprazol (indução do CYP2C19/3A4), diminuindo a supressão ácida. Vigiar a resposta e considerar ajuste.',
  summary_pro_en = 'Omeprazole + rifampicin: rifampicin lowers omeprazole levels (CYP2C19/3A4 induction), reducing acid suppression. Monitor the response and consider adjustment.',
  explanation_pt = 'O omeprazol é metabolizado pelo CYP2C19 e CYP3A4; a rifampicina induz estas enzimas e pode reduzir as suas concentrações em mais de 50%, com diminuição da supressão ácida gástrica (relevante em úlcera, DRGE grave ou profilaxia de stress). Recomenda-se vigiar a resposta clínica e considerar aumentar a dose de omeprazol ou preferir um IBP menos afetado (ex.: pantoprazol) durante a associação.',
  explanation_en = 'Omeprazole is metabolised by CYP2C19 and CYP3A4; rifampicin induces these enzymes and can reduce its concentrations by more than 50%, decreasing gastric acid suppression (relevant in ulcer, severe GORD or stress prophylaxis). Monitor the clinical response and consider increasing the omeprazole dose or preferring a less affected PPI (e.g. pantoprazole) during the combination.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'omeprazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'omeprazol'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 9/12 — PRAZIQUANTEL + RIFAMPICINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Praziquantel + rifampicina: a rifampicina reduz drasticamente os níveis de praziquantel (indução do CYP3A4), com falência do tratamento antiparasitário. Evitar a associação.',
  summary_pro_en = 'Praziquantel + rifampicin: rifampicin markedly reduces praziquantel levels (CYP3A4 induction), with antiparasitic treatment failure. Avoid the combination.',
  explanation_pt = 'O praziquantel sofre extenso metabolismo de primeira passagem pelo CYP3A4; a rifampicina, indutora potente, reduz as suas concentrações de forma marcada e compromete a eficácia contra esquistossomose, teníase e outras parasitoses — interação clássica documentada no rótulo. Recomenda-se evitar a coadministração; se for inevitável, tratar a parasitose após concluir o esquema com rifampicina ou escolher alternativa terapêutica.',
  explanation_en = 'Praziquantel undergoes extensive CYP3A4 first-pass metabolism; rifampicin, a potent inducer, markedly reduces its concentrations and compromises efficacy against schistosomiasis, taeniasis and other parasitoses — a classically label-documented interaction. Avoid the coadministration; if unavoidable, treat the parasitosis after completing the rifampicin regimen or choose an alternative therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'praziquantel'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'praziquantel'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 10/12 — PREDNISOLONA + RIFAMPICINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Prednisolona + rifampicina: a rifampicina reduz os níveis de prednisolona (indução do CYP3A4), diminuindo o efeito do corticoide. Considerar ajuste de dose.',
  summary_pro_en = 'Prednisolone + rifampicin: rifampicin lowers prednisolone levels (CYP3A4 induction), reducing the corticosteroid effect. Consider dose adjustment.',
  explanation_pt = 'A prednisolona é metabolizada pelo CYP3A4; a rifampicina induz esta enzima e pode reduzir as suas concentrações em 30–50%, atenuando o efeito anti-inflamatório/imunossupressor (relevante em doenças autoimunes, transplante e doenças respiratórias). Recomenda-se monitorizar a resposta clínica e considerar aumentar a dose de prednisolona durante a associação, com redução após a suspensão da rifampicina.',
  explanation_en = 'Prednisolone is metabolised by CYP3A4; rifampicin induces this enzyme and can reduce its concentrations by 30–50%, attenuating the anti-inflammatory/immunosuppressive effect (relevant in autoimmune diseases, transplantation and respiratory diseases). Monitor the clinical response and consider increasing the prednisolone dose during the combination, reducing it after rifampicin discontinuation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'prednisolona'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'prednisolona'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 11/12 — RIFAMPICINA + SILDENAFIL (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Sildenafil + rifampicina: a rifampicina reduz os níveis de sildenafil (indução do CYP3A4), diminuindo a eficácia. Considerar ajuste de dose.',
  summary_pro_en = 'Sildenafil + rifampicin: rifampicin lowers sildenafil levels (CYP3A4 induction), reducing efficacy. Consider dose adjustment.',
  explanation_pt = 'O sildenafil é metabolizado pelo CYP3A4; a rifampicina induz esta enzima e pode reduzir as suas concentrações de forma marcada, diminuindo o efeito na disfunção erétil ou na hipertensão pulmonar. Recomenda-se monitorizar a resposta e considerar aumentar a dose de sildenafil (dentro dos limites aprovados) durante a associação, ou preferir alternativa menos dependente do CYP3A4.',
  explanation_en = 'Sildenafil is metabolised by CYP3A4; rifampicin induces this enzyme and can markedly reduce its concentrations, decreasing the effect in erectile dysfunction or pulmonary hypertension. Monitor the response and consider increasing the sildenafil dose (within approved limits) during the combination, or prefer an alternative less dependent on CYP3A4.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'sildenafil'));

-- 12/12 — RIFAMPICINA + VORICONAZOL (indução do CYP3A4/CYP2C19)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Voriconazol + rifampicina: a rifampicina reduz drasticamente os níveis de voriconazol (indução do CYP3A4/CYP2C19), com falência antifúngica. Contraindicado na prática.',
  summary_pro_en = 'Voriconazole + rifampicin: rifampicin markedly reduces voriconazole levels (CYP3A4/CYP2C19 induction), with antifungal failure. Practically contraindicated.',
  explanation_pt = 'O voriconazol é metabolizado pelo CYP2C19 e CYP3A4; a rifampicina, indutora potente de ambas as vias, pode reduzir as suas concentrações para valores quase indetetáveis, com perda do efeito antifúngico. A associação é praticamente contraindicada; se for inevitável, considerar outro antifúngico (anfotericina B lipossómica, equinocandinas) e monitorizar os níveis de voriconazol se disponíveis.',
  explanation_en = 'Voriconazole is metabolised by CYP2C19 and CYP3A4; rifampicin, a potent inducer of both pathways, can reduce its concentrations to nearly undetectable values, with loss of antifungal effect. The combination is practically contraindicated; if unavoidable, consider another antifungal (liposomal amphotericin B, echinocandins) and monitor voriconazole levels if available.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rifampicina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));
