-- =====================================================================
-- 115 — Explicações fármaco-fármaco dos pares moderados da ATORVASTATINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 9 pares moderados da atorvastatina que os tinham vazios.
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do INFARMED.
-- Mecanismo central: a atorvastatina é substrato do CYP3A4 e da
-- OATP1B1; os inibidores do CYP3A4 (azóis cetoconazol/itraconazol/
-- voriconazol/fluconazol, macrólidos eritromicina, ritonavir) elevam as
-- suas concentrações e o risco de miopatia/rabdomiólise. A rifabutina,
-- indutora enzimática, reduz a eficácia. Colchicina e daptomicina somam
-- risco muscular por mecanismos próprios.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/9 — ATORVASTATINA + CETOCONAZOL (inibição do CYP3A4 — miopatia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + cetoconazol: o azol inibe o CYP3A4 e pode aumentar os níveis da estatina, com risco de miopatia/rabdomiólise. Suspender a estatina ou reduzir a dose.',
  summary_pro_en = 'Atorvastatin + ketoconazole: the azole inhibits CYP3A4 and can raise statin levels, with a risk of myopathy/rhabdomyolysis. Stop the statin or reduce the dose.',
  explanation_pt = 'O cetoconazol é um inibidor potente do CYP3A4, a principal enzima que metaboliza a atorvastatina; a coadministração aumenta marcadamente as concentrações da estatina e o risco de miopatia, incluindo rabdomiólise, sobretudo com doses elevadas ou em doentes com disfunção renal ou hepática. O rótulo da atorvastatina recomenda considerar o risco/benefício da associação com outros antifúngicos azólicos (incluindo o cetoconazol) e monitorizar todos os doentes para sinais de miopatia, sobretudo no início e durante a titulação; para o cetoconazol não há limite de dose especificado (ao contrário do itraconazol, 20 mg). Informar o doente para suspender a estatina perante dor muscular, fraqueza ou urina escura.',
  explanation_en = 'Ketoconazole is a potent inhibitor of CYP3A4, the main enzyme that metabolises atorvastatin; co-administration markedly raises statin concentrations and the risk of myopathy, including rhabdomyolysis, especially at high doses or in patients with renal or hepatic dysfunction. The atorvastatin label recommends considering the risk/benefit of concomitant use with other azole antifungals (including ketoconazole) and monitoring all patients for signs of myopathy, particularly at initiation and during titration; no specific dose limit is given for ketoconazole (unlike itraconazole, 20 mg). Instruct the patient to stop the statin in the presence of muscle pain, weakness or dark urine.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- 2/9 — ATORVASTATINA + COLCHICINA (risco muscular aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + colchicina: risco aditivo de miopatia/rabdomiólise. Usar com precaução, sobretudo com insuficiência renal.',
  summary_pro_en = 'Atorvastatin + colchicine: additive risk of myopathy/rhabdomyolysis. Use with caution, especially with renal impairment.',
  explanation_pt = 'Tanto a colchicina como as estatinas podem causar miopatia, e a associação aumenta o risco de rabdomiólise, sobretudo em doentes com insuficiência renal, idosos ou com doses elevadas de colchicina (ex.: crise gotosa aguda em doente medicado com estatina). A colchicina é também substrato do CYP3A4/P-gp, partilhando vias com a atorvastatina. Na prática, usar a menor dose eficaz de colchicina pelo menor tempo, vigiar sintomas musculares e CPK, e considerar suspender temporariamente a estatina durante um ciclo de colchicina em doentes de risco.',
  explanation_en = 'Both colchicine and statins can cause myopathy, and the combination increases the risk of rhabdomyolysis, especially in patients with renal impairment, the elderly or with high colchicine doses (e.g., acute gout flare in a patient on a statin). Colchicine is also a CYP3A4/P-gp substrate, sharing pathways with atorvastatin. In practice, use the lowest effective colchicine dose for the shortest time, monitor muscle symptoms and CK, and consider temporarily stopping the statin during a colchicine course in at-risk patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'colchicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'colchicina'));

-- 3/9 — ATORVASTATINA + DAPTOMICINA (risco muscular aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + daptomicina: risco aditivo de miopatia/rabdomiólise. Suspender a estatina durante o tratamento com daptomicina.',
  summary_pro_en = 'Atorvastatin + daptomycin: additive risk of myopathy/rhabdomyolysis. Stop the statin during daptomycin treatment.',
  explanation_pt = 'A daptomicina associa-se a miopatia, com elevação da CPK, e o rótulo recomenda monitorizar a CPK semanalmente (mais frequentemente em doentes com estatinas concomitantes ou recentes) e considerar a suspensão temporária de agentes associados a rabdomiólise, como as estatinas (HMG-CoA redutase), durante o tratamento com daptomicina. O risco é maior com doses elevadas de daptomicina, ciclos prolongados ou insuficiência renal. Na prática, ponderar interromper a atorvastatina (e outras estatinas) durante o antibiótico, monitorizar a CPK semanalmente e vigiar sintomas musculares; a estatina pode ser retomada após o fim do tratamento.',
  explanation_en = 'Daptomycin is associated with myopathy, with CK elevation, and the label recommends monitoring CK weekly (more frequently in patients on recent or concomitant statins) and considering the temporary suspension of agents associated with rhabdomyolysis, such as statins (HMG-CoA reductase), during daptomycin treatment. The risk is higher with high daptomycin doses, prolonged courses or renal impairment. In practice, consider interrupting atorvastatin (and other statins) during the antibiotic, monitor CK weekly and watch for muscle symptoms; the statin can be resumed after the end of treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'daptomicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'daptomicina'));

-- 4/9 — ATORVASTATINA + ERITROMICINA (inibição do CYP3A4 — miopatia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + eritromicina: o macrólido inibe o CYP3A4 e pode elevar os níveis da estatina, com risco de miopatia. Vigiar e considerar suspensão.',
  summary_pro_en = 'Atorvastatin + erythromycin: the macrolide inhibits CYP3A4 and can raise statin levels, with a risk of myopathy. Monitor and consider stopping.',
  explanation_pt = 'A eritromicina é um inibidor do CYP3A4, enzima que metaboliza a atorvastatina, e pode aumentar as concentrações da estatina e o risco de miopatia/rabdomiólise, sobretudo em ciclos prolongados, doses elevadas ou com insuficiência renal. O rótulo da atorvastatina lista a eritromicina entre os inibidores do CYP3A4 cuja associação requer considerar o risco/benefício (o limite de 20 mg é explícito apenas para claritromicina e itraconazol). Durante um ciclo de eritromicina, considerar a menor dose da estatina ou a suspensão temporária, vigiar sintomas musculares e CPK, e informar o doente.',
  explanation_en = 'Erythromycin is an inhibitor of CYP3A4, the enzyme that metabolises atorvastatin, and can raise statin concentrations and the risk of myopathy/rhabdomyolysis, especially in prolonged courses, high doses or with renal impairment. The atorvastatin label lists erythromycin among the CYP3A4 inhibitors whose combination requires a risk/benefit consideration (the 20 mg limit is explicit only for clarithromycin and itraconazole). During an erythromycin course, consider the lowest statin dose or temporary suspension, monitor muscle symptoms and CK, and inform the patient.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'eritromicina'));

-- 5/9 — ATORVASTATINA + FLUCONAZOL (inibição do CYP3A4 — miopatia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + fluconazol: inibição do CYP3A4 com aumento dos níveis da estatina. Vigiar e considerar redução da dose.',
  summary_pro_en = 'Atorvastatin + fluconazole: CYP3A4 inhibition raising statin levels. Monitor and consider dose reduction.',
  explanation_pt = 'O fluconazol inibe o CYP3A4 (em grau variável consoante a dose) e pode aumentar as concentrações da atorvastatina, elevando o risco de miopatia/rabdomiólise, sobretudo com doses altas de fluconazol ou em ciclos prolongados. Recomenda-se vigiar sintomas musculares e CPK, usar a menor dose eficaz da estatina durante o tratamento antifúngico e informar o doente para suspender perante dor muscular, fraqueza ou urina escura. Em doentes com insuficiência renal, o risco é maior.',
  explanation_en = 'Fluconazole inhibits CYP3A4 (to a variable degree depending on dose) and can raise atorvastatin concentrations, increasing the risk of myopathy/rhabdomyolysis, especially with high fluconazole doses or prolonged courses. Monitor muscle symptoms and CK, use the lowest effective statin dose during antifungal treatment and instruct the patient to stop in the presence of muscle pain, weakness or dark urine. In patients with renal impairment, the risk is higher.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'));

-- 6/9 — ATORVASTATINA + ITRACONAZOL (inibição do CYP3A4 — miopatia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + itraconazol: o azol inibe o CYP3A4 e pode aumentar marcadamente os níveis da estatina. Suspender a estatina ou reduzir a dose.',
  summary_pro_en = 'Atorvastatin + itraconazole: the azole inhibits CYP3A4 and can markedly raise statin levels. Stop the statin or reduce the dose.',
  explanation_pt = 'O itraconazol é um inibidor potente do CYP3A4 e pode aumentar de forma marcada as concentrações da atorvastatina (e o risco de miopatia/rabdomiólise), sobretudo em ciclos prolongados de antifúngico ou com insuficiência renal. O rótulo da atorvastatina recomenda não exceder 20 mg de atorvastatina por dia durante o tratamento com itraconazol (limite explícito no rótulo), com vigilância de sintomas musculares e CPK. Informar o doente para suspender a estatina perante dor muscular, fraqueza ou urina escura.',
  explanation_en = 'Itraconazole is a potent CYP3A4 inhibitor and can markedly raise atorvastatin concentrations (and the risk of myopathy/rhabdomyolysis), especially in prolonged antifungal courses or with renal impairment. The atorvastatin label recommends not exceeding 20 mg of atorvastatin per day during itraconazole treatment (an explicit limit in the label), with monitoring of muscle symptoms and CK. Instruct the patient to stop the statin in the presence of muscle pain, weakness or dark urine.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 7/9 — ATORVASTATINA + RIFABUTINA (indução enzimática — perda de eficácia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + rifabutina: a rifabutina induz enzimas e pode reduzir os níveis da estatina, diminuindo o efeito hipolipemiante. Monitorizar lípidos.',
  summary_pro_en = 'Atorvastatin + rifabutin: rifabutin induces enzymes and can lower statin levels, reducing the lipid-lowering effect. Monitor lipids.',
  explanation_pt = 'A rifabutina, como a rifampicina, é um indutor enzimático (CYP3A4 e transportadores) que acelera o metabolismo da atorvastatina, podendo reduzir as suas concentrações e comprometer o controlo lipídico durante o tratamento antimicobacteriano (ex.: profilaxia em VIH). O efeito é menos marcado que com a rifampicina, mas recomenda-se monitorizar o perfil lipídico e, se necessário, ajustar a dose da estatina (ou considerar uma estatina menos dependente do CYP3A4, como a pravastatina).',
  explanation_en = 'Rifabutin, like rifampicin, is an enzyme inducer (CYP3A4 and transporters) that accelerates atorvastatin metabolism, potentially lowering its concentrations and compromising lipid control during antimycobacterial treatment (e.g., prophylaxis in HIV). The effect is less marked than with rifampicin, but monitoring the lipid profile is recommended and, if needed, adjusting the statin dose (or considering a statin less dependent on CYP3A4, such as pravastatin).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'rifabutina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'rifabutina'));

-- 8/9 — ATORVASTATINA + RITONAVIR (inibição do CYP3A4 — miopatia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + ritonavir: o ritonavir inibe fortemente o CYP3A4 e aumenta os níveis da estatina. Não exceder 20 mg/dia com os esquemas com ritonavir indicados no rótulo.',
  summary_pro_en = 'Atorvastatin + ritonavir: ritonavir strongly inhibits CYP3A4 and raises statin levels. Do not exceed 20 mg/day with the ritonavir regimens indicated in the label.',
  explanation_pt = 'O ritonavir (inibidor da protease, frequentemente usado como potenciador farmacocinético) é um inibidor potente do CYP3A4, e a coadministração com atorvastatina aumenta as concentrações da estatina e o risco de miopatia/rabdomiólise. O rótulo da atorvastatina especifica: com saquinavir+ritonavir, darunavir+ritonavir ou fosamprenavir(+ritonavir), não exceder 20 mg de atorvastatina por dia; com tipranavir+ritonavir a associação não é recomendada; com lopinavir+ritonavir considerar o risco/benefício. Na prática (VIH em terapêutica antirretrovírica), usar a dose mais baixa adequada e titular lentamente com monitorização dos lípidos, sintomas musculares e CPK; em alternativa, considerar uma estatina menos dependente do CYP3A4. Informar o doente para os sinais de miopatia.',
  explanation_en = 'Ritonavir (a protease inhibitor, often used as a pharmacokinetic booster) is a potent CYP3A4 inhibitor, and co-administration with atorvastatin raises statin concentrations and the risk of myopathy/rhabdomyolysis. The atorvastatin label specifies: with saquinavir+ritonavir, darunavir+ritonavir or fosamprenavir(+ritonavir), do not exceed 20 mg of atorvastatin per day; with tipranavir+ritonavir the combination is not recommended; with lopinavir+ritonavir consider the risk/benefit. In practice (HIV on antiretroviral therapy), use the lowest appropriate dose and titrate slowly with monitoring of lipids, muscle symptoms and CK; alternatively, consider a statin less dependent on CYP3A4. Instruct the patient about myopathy signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

-- 9/9 — ATORVASTATINA + VORICONAZOL (inibição do CYP3A4 — miopatia)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Atorvastatina + voriconazol: o azol inibe o CYP3A4 e pode elevar os níveis da estatina. Vigiar miopatia e considerar redução da dose.',
  summary_pro_en = 'Atorvastatin + voriconazole: the azole inhibits CYP3A4 and can raise statin levels. Monitor for myopathy and consider dose reduction.',
  explanation_pt = 'O voriconazol inibe o CYP3A4 e pode aumentar as concentrações da atorvastatina, elevando o risco de miopatia/rabdomiólise, sobretudo em ciclos prolongados de antifúngico (ex.: aspergilose invasiva) ou com insuficiência renal. O rótulo da atorvastatina recomenda considerar o risco/benefício da associação com outros antifúngicos azólicos (incluindo o voriconazol), vigiar sintomas musculares e CPK, e usar a menor dose eficaz da estatina. Informar o doente para suspender perante dor muscular, fraqueza ou urina escura. Em doentes em antifúngico prolongado, reavaliar periodicamente a necessidade e a dose da estatina.',
  explanation_en = 'Voriconazole inhibits CYP3A4 and can raise atorvastatin concentrations, increasing the risk of myopathy/rhabdomyolysis, especially in prolonged antifungal courses (e.g., invasive aspergillosis) or with renal impairment. The atorvastatin label recommends considering the risk/benefit of combination with other azole antifungals (including voriconazole), monitoring muscle symptoms and CK, and using the lowest effective statin dose. Instruct the patient to stop in the presence of muscle pain, weakness or dark urine. In patients on prolonged antifungal therapy, periodically reassess the need for and the dose of the statin.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'atorvastatina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));
