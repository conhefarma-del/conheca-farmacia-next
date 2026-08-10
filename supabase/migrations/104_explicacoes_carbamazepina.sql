-- =====================================================================
-- 104 — Explicações fármaco-fármaco dos pares moderados da CARBAMAZEPINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 17 pares moderados da carbamazepina que os tinham vazios —
-- quinto lote dos pares moderados sem explicação (319 → 275 → 253 → 235 → 218).
-- Padrão da 089/100/103: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados citados no campo
-- source_* já existente de cada par (DailyMed/FDA, EMA/EMC-UK, OMS/WHO).
-- Mecanismo central: a carbamazepina é indutora potente do CYP3A4 (e de
-- outras monooxigenases) e é simultaneamente substrato do CYP3A4 — as
-- interações são bidirecionais (indução reduz fármacos coadministrados;
-- inibidores do CYP3A4 elevam os níveis de carbamazepina).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/17 — ARTEMÉTER+LUMEFANTRINA + CARBAMAZEPINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + arteméter+lumefantrina: a carbamazepina induz o CYP3A4 e reduz os níveis do antimalárico, com risco de falência terapêutica. Evitar a associação.',
  summary_pro_en = 'Carbamazepine + artemether+lumefantrine: carbamazepine induces CYP3A4 and lowers antimalarial levels, with risk of therapeutic failure. Avoid the combination.',
  explanation_pt = 'A carbamazepina é um indutor potente do CYP3A4, a via que metaboliza o arteméter e o lumefantrina; a coadministração pode reduzir substancialmente as concentrações do antimalárico e comprometer a cura da malária. Em doentes epiléticos com malária, preferir um antimalárico menos dependente do CYP3A4 (ex.: atovaquona+proguanil) e, se a associação for inevitável, considerar vigilância apertada da resposta clínica e parasitológica.',
  explanation_en = 'Carbamazepine is a potent inducer of CYP3A4, the pathway that metabolises artemether and lumefantrine; coadministration can substantially reduce antimalarial concentrations and compromise malaria cure. In epileptic patients with malaria, prefer an antimalarial less dependent on CYP3A4 (e.g. atovaquone+proguanil) and, if the combination is unavoidable, monitor the clinical and parasitological response closely.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'artemeter-lumefantrina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'));

-- 2/17 — ARTESUNATO+AMODIAQUINA + CARBAMAZEPINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + artesunato+amodiaquina: indução do metabolismo do antimalárico pela carbamazepina, com risco de níveis subterapêuticos e falência. Evitar se possível.',
  summary_pro_en = 'Carbamazepine + artesunate+amodiaquine: carbamazepine induces antimalarial metabolism, with risk of subtherapeutic levels and failure. Avoid if possible.',
  explanation_pt = 'A carbamazepina induz as monooxigenases (incluindo o CYP3A4) que participam no metabolismo do artesunato (e do seu metabolito ativo diidroartemisinina) e da amodiaquina; os níveis do antimalárico podem cair abaixo do limiar terapêutico e comprometer a resposta. Preferir alternativa antimalárica em doentes sob carbamazepina e, se a associação for inevitável, vigiar a resposta clínica e parasitológica.',
  explanation_en = 'Carbamazepine induces the monooxygenases (including CYP3A4) involved in the metabolism of artesunate (and its active metabolite dihydroartemisinin) and amodiaquine; antimalarial levels can fall below the therapeutic threshold and compromise response. Prefer an alternative antimalarial in patients on carbamazepine and, if the combination is unavoidable, monitor the clinical and parasitological response.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'artesunato-amodiaquina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'artesunato-amodiaquina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'));

-- 3/17 — CARBAMAZEPINA + CETOCONAZOL (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cetoconazol + carbamazepina: o cetoconazol inibe o CYP3A4 e pode elevar os níveis de carbamazepina, com risco de toxicidade (nistagmo, ataxia, sedação). Vigiar níveis.',
  summary_pro_en = 'Ketoconazole + carbamazepine: ketoconazole inhibits CYP3A4 and may raise carbamazepine levels, with risk of toxicity (nystagmus, ataxia, sedation). Monitor levels.',
  explanation_pt = 'A carbamazepina é metabolizada pelo CYP3A4; o cetoconazol é um inibidor potente desta enzima e pode aumentar as concentrações de carbamazepina, com risco de intoxicação (nistagmo, ataxia, diplopia, sedação, e em casos graves arritmias e convulsões). Recomenda-se vigiar os níveis plasmáticos de carbamazepina, reduzir a dose se necessário e monitorizar sinais de toxicidade enquanto durar o antifúngico.',
  explanation_en = 'Carbamazepine is metabolised by CYP3A4; ketoconazole is a potent inhibitor of this enzyme and can raise carbamazepine concentrations, with risk of intoxication (nystagmus, ataxia, diplopia, sedation and, in severe cases, arrhythmias and seizures). Monitor carbamazepine plasma levels, reduce the dose if needed and watch for toxicity signs while the antifungal lasts.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'cetoconazol'));

-- 4/17 — CARBAMAZEPINA + CLOZAPINA (indução + risco hematológico)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + clozapina: a carbamazepina reduz os níveis de clozapina (indução do CYP1A2/3A4) e ambas têm risco hematológico aditivo. Evitar a associação.',
  summary_pro_en = 'Carbamazepine + clozapine: carbamazepine lowers clozapine levels (CYP1A2/3A4 induction) and both carry additive haematological risk. Avoid the combination.',
  explanation_pt = 'A carbamazepina induz o CYP1A2 e o CYP3A4 e pode reduzir as concentrações de clozapina para metade, comprometendo o efeito antipsicótico; por outro lado, a clozapina e a carbamazepina associam-se ambas a discrasias sanguíneas (agranulocitose/neutropenia), e a coadministração é tradicionalmente evitada pelo risco hematológico aditivo. Recomenda-se escolher alternativa antiepilética (ex.: valproato, lamotrigina) em doentes com clozapina; se inevitável, vigiar hemograma e níveis de clozapina.',
  explanation_en = 'Carbamazepine induces CYP1A2 and CYP3A4 and can halve clozapine concentrations, compromising the antipsychotic effect; in addition, both clozapine and carbamazepine are associated with blood dyscrasias (agranulocytosis/neutropenia), and coadministration is traditionally avoided because of the additive haematological risk. Choose an alternative antiepileptic (e.g. valproate, lamotrigine) in patients on clozapine; if unavoidable, monitor the blood count and clozapine levels.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'clozapina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'clozapina'));

-- 5/17 — CARBAMAZEPINA + DEXAMETASONA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + dexametasona: a carbamazepina induz o CYP3A4 e reduz os níveis de dexametasona, podendo diminuir o efeito do corticosteroide. Considerar ajuste de dose.',
  summary_pro_en = 'Carbamazepine + dexamethasone: carbamazepine induces CYP3A4 and lowers dexamethasone levels, potentially reducing the corticosteroid effect. Consider dose adjustment.',
  explanation_pt = 'A dexametasona é metabolizada pelo CYP3A4; a carbamazepina, indutora potente desta enzima, pode reduzir as suas concentrações e atenuar o efeito anti-inflamatório/imunossupressor. Em doentes em corticoterapia prolongada (ex.: doenças autoimunes, após transplante) com epilepsia tratada com carbamazepina, monitorizar a resposta clínica e considerar aumentar a dose de dexametasona ou preferir um corticosteroide menos dependente do CYP3A4.',
  explanation_en = 'Dexamethasone is metabolised by CYP3A4; carbamazepine, a potent inducer of this enzyme, can lower its concentrations and attenuate the anti-inflammatory/immunosuppressive effect. In patients on long-term corticosteroid therapy (e.g. autoimmune diseases, post-transplant) with epilepsy treated with carbamazepine, monitor the clinical response and consider increasing the dexamethasone dose or preferring a corticosteroid less dependent on CYP3A4.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'dexametasona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'dexametasona'));

-- 6/17 — CARBAMAZEPINA + DIIDROARTEMISININA+PIPERAQUINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + diidroartemisinina+piperaquina: indução do metabolismo do antimalárico pela carbamazepina, com risco de níveis subterapêuticos. Evitar se possível.',
  summary_pro_en = 'Carbamazepine + dihydroartemisinin+piperaquine: carbamazepine induces antimalarial metabolism, with risk of subtherapeutic levels. Avoid if possible.',
  explanation_pt = 'A carbamazepina induz o CYP3A4, via importante no metabolismo da diidroartemisinina e da piperaquina; os níveis do antimalárico podem cair abaixo do limiar terapêutico, comprometendo a cura. Além disso, a piperaquina prolonga o QT — em doentes epiléticos tratados com carbamazepina, preferir um antimalárico alternativo (ex.: atovaquona+proguanil, que também é menos dependente do CYP3A4) e vigiar a resposta clínica e parasitológica se a associação for inevitável.',
  explanation_en = 'Carbamazepine induces CYP3A4, an important pathway in dihydroartemisinin and piperaquine metabolism; antimalarial levels can fall below the therapeutic threshold, compromising cure. In addition, piperaquine prolongs the QT — in epileptic patients treated with carbamazepine, prefer an alternative antimalarial (e.g. atovaquone+proguanil, which is also less CYP3A4-dependent) and monitor the clinical and parasitological response if the combination is unavoidable.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'diidroartemisinina-piperaquina'));

-- 7/17 — CARBAMAZEPINA + EFAVIRENZ (indução mútua do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Efavirenz + carbamazepina: indução mútua do CYP3A4 — ambos os fármacos podem ficar subterapêuticos. Vigiar níveis e resposta clínica.',
  summary_pro_en = 'Efavirenz + carbamazepine: mutual CYP3A4 induction — both drugs can become subtherapeutic. Monitor levels and clinical response.',
  explanation_pt = 'A interação é bidirecional: a carbamazepina induz o CYP3A4 e reduz as concentrações de efavirenz, e o efavirenz induz também o CYP3A4, reduzindo os níveis de carbamazepina. O resultado pode ser a perda simultânea do controlo virológico e do controlo das crises epiléticas. Sempre que possível, escolher outro antiepilético (ex.: levetiracetam, valproato) em doentes com efavirenz; se a associação for inevitável, vigiar a carga viral e os níveis de carbamazepina, ajustando doses.',
  explanation_en = 'The interaction is bidirectional: carbamazepine induces CYP3A4 and lowers efavirenz concentrations, and efavirenz also induces CYP3A4, lowering carbamazepine levels. The result can be simultaneous loss of virological control and of seizure control. Whenever possible, choose another antiepileptic (e.g. levetiracetam, valproate) in patients on efavirenz; if the combination is unavoidable, monitor the viral load and carbamazepine levels, adjusting doses.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'efavirenz'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'efavirenz'));

-- 8/17 — CARBAMAZEPINA + FLUCONAZOL (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Fluconazol + carbamazepina: o fluconazol inibe o CYP3A4 e pode elevar os níveis de carbamazepina, com risco de toxicidade. Vigiar níveis e sinais de intoxicação.',
  summary_pro_en = 'Fluconazole + carbamazepine: fluconazole inhibits CYP3A4 and may raise carbamazepine levels, with risk of toxicity. Monitor levels and intoxication signs.',
  explanation_pt = 'O fluconazol inibe o CYP3A4, reduzindo a clearance da carbamazepina e podendo aumentar as suas concentrações até níveis tóxicos (nistagmo, ataxia, diplopia, sedação). O efeito depende da dose de fluconazol. Recomenda-se vigiar os níveis plasmáticos de carbamazepina e reduzir a dose se necessário durante e após o tratamento antifúngico.',
  explanation_en = 'Fluconazole inhibits CYP3A4, reducing carbamazepine clearance and potentially raising its concentrations to toxic levels (nystagmus, ataxia, diplopia, sedation). The effect depends on the fluconazole dose. Monitor carbamazepine plasma levels and reduce the dose if needed during and after antifungal treatment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'fluconazol'));

-- 9/17 — CARBAMAZEPINA + HALOPERIDOL (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + haloperidol: a carbamazepina reduz os níveis de haloperidol (indução do CYP3A4), podendo diminuir o efeito antipsicótico. Ajustar dose e vigiar.',
  summary_pro_en = 'Carbamazepine + haloperidol: carbamazepine lowers haloperidol levels (CYP3A4 induction), potentially reducing the antipsychotic effect. Adjust the dose and monitor.',
  explanation_pt = 'O haloperidol é metabolizado pelo CYP3A4; a carbamazepina, indutora potente, pode reduzir as suas concentrações em cerca de 50%, com perda do controlo psicótico. Por outro lado, alguns doentes apresentam maior sedação com a associação. Recomenda-se monitorizar a resposta clínica, ajustar a dose de haloperidol (frequentemente para cima) e considerar alternativa antiepilética sem indução enzimática (ex.: valproato) quando o quadro psiquiátrico o permitir.',
  explanation_en = 'Haloperidol is metabolised by CYP3A4; carbamazepine, a potent inducer, can reduce its concentrations by about 50%, with loss of psychotic control. Conversely, some patients experience more sedation with the combination. Monitor the clinical response, adjust the haloperidol dose (often upwards) and consider an antiepileptic without enzyme induction (e.g. valproate) when the psychiatric picture allows it.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'haloperidol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'haloperidol'));

-- 10/17 — CARBAMAZEPINA + ISONIAZIDA (inibição + hepatotoxicidade)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Isoniazida + carbamazepina: a isoniazida inibe o metabolismo da carbamazepina e eleva os seus níveis; ambas são hepatotóxicas. Vigiar níveis e função hepática.',
  summary_pro_en = 'Isoniazid + carbamazepine: isoniazid inhibits carbamazepine metabolism and raises its levels; both are hepatotoxic. Monitor levels and liver function.',
  explanation_pt = 'A isoniazida inibe as enzimas que metabolizam a carbamazepina (CYP2C19/CYP3A4) e pode aumentar as suas concentrações até níveis tóxicos (nistagmo, ataxia, sedação); em doentes tuberculosos, o efeito pode ser clinicamente relevante nas primeiras semanas. Além disso, ambos os fármacos são hepatotóxicos, com risco aditivo de lesão hepática. Recomenda-se vigiar os níveis de carbamazepina e reduzir a dose se necessário, monitorizar transaminases e estar atento a sintomas de intoxicação.',
  explanation_en = 'Isoniazid inhibits the enzymes that metabolise carbamazepine (CYP2C19/CYP3A4) and can raise its concentrations to toxic levels (nystagmus, ataxia, sedation); in tuberculosis patients the effect can be clinically relevant in the first weeks. In addition, both drugs are hepatotoxic, with an additive risk of liver injury. Monitor carbamazepine levels and reduce the dose if needed, monitor transaminases and watch for intoxication symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'isoniazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'isoniazida'));

-- 11/17 — CARBAMAZEPINA + ITRACONAZOL (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Itraconazol + carbamazepina: o itraconazol inibe o CYP3A4 e pode elevar os níveis de carbamazepina, com risco de toxicidade. Vigiar níveis.',
  summary_pro_en = 'Itraconazole + carbamazepine: itraconazole inhibits CYP3A4 and may raise carbamazepine levels, with risk of toxicity. Monitor levels.',
  explanation_pt = 'O itraconazol é um inibidor potente do CYP3A4, a principal via de metabolização da carbamazepina; a coadministração pode aumentar as concentrações de carbamazepina e causar intoxicação (nistagmo, ataxia, diplopia, sedação). Recomenda-se vigiar os níveis plasmáticos de carbamazepina e reduzir a dose se necessário durante o tratamento antifúngico; considerar alternativa antifúngica menos inibidora (ex.: fluconazol em doses baixas, com precaução) quando possível.',
  explanation_en = 'Itraconazole is a potent inhibitor of CYP3A4, the main pathway of carbamazepine metabolism; coadministration can raise carbamazepine concentrations and cause intoxication (nystagmus, ataxia, diplopia, sedation). Monitor carbamazepine plasma levels and reduce the dose if needed during antifungal treatment; consider a less inhibitory antifungal (e.g. low-dose fluconazole, with caution) when possible.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'itraconazol'));

-- 12/17 — CARBAMAZEPINA + LAMOTRIGINA (indução da glucuronidação + epóxido)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + lamotrigina: a carbamazepina reduz os níveis de lamotrigina (indução da glucuronidação) e a lamotrigina pode elevar o metabolito epóxido da carbamazepina. Vigiar ambos.',
  summary_pro_en = 'Carbamazepine + lamotrigine: carbamazepine lowers lamotrigine levels (glucuronidation induction) and lamotrigine may raise carbamazepine-epoxide. Monitor both.',
  explanation_pt = 'A interação é bidirecional: a carbamazepina induz a glucuronidação da lamotrigina e reduz as suas concentrações em cerca de 40–50%, podendo exigir aumento da dose de lamotrigina; em sentido inverso, a lamotrigina inibe a epóxido-hidrolase e pode elevar as concentrações do metabolito ativo carbamazepina-10,11-epóxido, causando toxicidade (nistagmo, ataxia, diplopia) mesmo com níveis de carbamazepina dentro do intervalo. Recomenda-se titular a lamotrigina com base na resposta, vigiar sinais de toxicidade do epóxido e considerar a monitorização do epóxido se disponível.',
  explanation_en = 'The interaction is bidirectional: carbamazepine induces lamotrigine glucuronidation and reduces its concentrations by about 40–50%, potentially requiring a lamotrigine dose increase; conversely, lamotrigine inhibits epoxide hydrolase and can raise the active metabolite carbamazepine-10,11-epoxide, causing toxicity (nystagmus, ataxia, diplopia) even with carbamazepine levels in range. Titrate lamotrigine according to response, watch for epoxide toxicity signs and consider epoxide monitoring if available.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'lamotrigina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'lamotrigina'));

-- 13/17 — CARBAMAZEPINA + MEFLOQUINA (indução do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + mefloquina: a carbamazepina reduz os níveis de mefloquina (indução do CYP3A4), com risco de falência profilática/terapêutica. Evitar a associação.',
  summary_pro_en = 'Carbamazepine + mefloquine: carbamazepine lowers mefloquine levels (CYP3A4 induction), with risk of prophylactic/therapeutic failure. Avoid the combination.',
  explanation_pt = 'A mefloquina é metabolizada pelo CYP3A4; a carbamazepina, indutora potente, pode reduzir as suas concentrações abaixo do limiar eficaz, comprometendo a profilaxia ou o tratamento da malária. Em doentes epiléticos, a mefloquina é também de evitar pelo risco de convulsões. Preferir outro antimalárico (ex.: atovaquona+proguanil, doxiciclina) em doentes sob carbamazepina.',
  explanation_en = 'Mefloquine is metabolised by CYP3A4; carbamazepine, a potent inducer, can reduce its concentrations below the effective threshold, compromising malaria prophylaxis or treatment. In epileptic patients, mefloquine is also to be avoided because of the seizure risk. Prefer another antimalarial (e.g. atovaquone+proguanil, doxycycline) in patients on carbamazepine.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'mefloquina'));

-- 14/17 — CARBAMAZEPINA + RIFAMPICINA (indução potente)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Rifampicina + carbamazepina: a rifampicina induz fortemente o CYP3A4 e reduz os níveis de carbamazepina, com risco de perda do controlo das crises. Vigiar níveis e ajustar dose.',
  summary_pro_en = 'Rifampicin + carbamazepine: rifampicin strongly induces CYP3A4 and lowers carbamazepine levels, with risk of losing seizure control. Monitor levels and adjust the dose.',
  explanation_pt = 'A rifampicina é um indutor potente do CYP3A4 e pode reduzir as concentrações de carbamazepina em mais de 50%, com risco de recaída das crises epiléticas; o efeito desenvolve-se em dias a semanas e persiste após a suspensão da rifampicina. Ambas são hepatotóxicas, com risco aditivo. Recomenda-se vigiar os níveis plasmáticos de carbamazepina e aumentar a dose conforme necessário durante e após o tratamento antituberculoso, monitorizando transaminases.',
  explanation_en = 'Rifampicin is a potent inducer of CYP3A4 and can reduce carbamazepine concentrations by more than 50%, with risk of seizure relapse; the effect develops over days to weeks and persists after rifampicin discontinuation. Both are hepatotoxic, with an additive risk. Monitor carbamazepine plasma levels and increase the dose as needed during and after antituberculosis treatment, monitoring transaminases.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'rifampicina'));

-- 15/17 — CARBAMAZEPINA + RITONAVIR (inibição vs indução)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ritonavir + carbamazepina: o ritonavir inibe o CYP3A4 e eleva os níveis de carbamazepina, enquanto a carbamazepina reduz os níveis do anti-retrovírico. Vigiar ambos.',
  summary_pro_en = 'Ritonavir + carbamazepine: ritonavir inhibits CYP3A4 and raises carbamazepine levels, while carbamazepine lowers antiretroviral levels. Monitor both.',
  explanation_pt = 'A interação é bidirecional e complexa: o ritonavir (potente inibidor do CYP3A4) pode aumentar as concentrações de carbamazepina até níveis tóxicos, enquanto a carbamazepina (indutora do CYP3A4) pode reduzir os níveis de ritonavir e dos inibidores da protease potenciados, comprometendo a supressão viral. Recomenda-se vigiar os níveis de carbamazepina (reduzir a dose se necessário) e monitorizar a resposta virológica; considerar antiepilético alternativo (ex.: levetiracetam) em doentes com terapêutica anti-retrovírica baseada em ritonavir.',
  explanation_en = 'The interaction is bidirectional and complex: ritonavir (potent CYP3A4 inhibitor) can raise carbamazepine concentrations to toxic levels, while carbamazepine (CYP3A4 inducer) can lower ritonavir and boosted protease inhibitor levels, compromising viral suppression. Monitor carbamazepine levels (reduce the dose if needed) and the virological response; consider an alternative antiepileptic (e.g. levetiracetam) in patients on ritonavir-based antiretroviral therapy.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'ritonavir'));

-- 16/17 — CARBAMAZEPINA + TEOFILINA (indução do CYP1A2/CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Carbamazepina + teofilina: a carbamazepina induz o metabolismo da teofilina e reduz os seus níveis em ~50%, com perda do efeito broncodilatador. Vigiar níveis de teofilina.',
  summary_pro_en = 'Carbamazepine + theophylline: carbamazepine induces theophylline metabolism and lowers its levels by ~50%, with loss of bronchodilator effect. Monitor theophylline levels.',
  explanation_pt = 'A carbamazepina induz o CYP1A2 e o CYP3A4, vias de metabolização da teofilina, e pode reduzir as suas concentrações em cerca de 50%, comprometendo o controlo da asma/DPOC. A teofilina tem janela terapêutica estreita, pelo que se recomenda vigiar os seus níveis plasmáticos e ajustar a dose (frequentemente para cima) enquanto durar a associação; considerar alternativa antiepilética sem indução enzimática se o controlo respiratório for difícil.',
  explanation_en = 'Carbamazepine induces CYP1A2 and CYP3A4, pathways of theophylline metabolism, and can reduce its concentrations by about 50%, compromising asthma/COPD control. Theophylline has a narrow therapeutic window, so monitor its plasma levels and adjust the dose (often upwards) while the combination lasts; consider an antiepileptic without enzyme induction if respiratory control is difficult.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'teofilina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'teofilina'));

-- 17/17 — CARBAMAZEPINA + VORICONAZOL (inibição vs indução)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Voriconazol + carbamazepina: o voriconazol eleva os níveis de carbamazepina (inibição do CYP3A4) e a carbamazepina reduz drasticamente os níveis de voriconazol (indução). Evitar a associação.',
  summary_pro_en = 'Voriconazole + carbamazepine: voriconazole raises carbamazepine levels (CYP3A4 inhibition) and carbamazepine markedly reduces voriconazole levels (induction). Avoid the combination.',
  explanation_pt = 'A interação é bidirecional e contraindicada na prática: o voriconazol inibe o CYP3A4 e pode elevar a carbamazepina até níveis tóxicos, enquanto a carbamazepina induz fortemente o CYP3A4 (e outras vias) e reduz as concentrações de voriconazol para níveis subterapêuticos, com risco de falência antifúngica. Deve evitar-se a associação; se inevitável, considerar outro antifúngico (ex.: anfotericina B, equinocandinas) ou outra terapêutica antiepilética, com monitorização apertada de níveis e resposta.',
  explanation_en = 'The interaction is bidirectional and practically contraindicated: voriconazole inhibits CYP3A4 and can raise carbamazepine to toxic levels, while carbamazepine strongly induces CYP3A4 (and other pathways) and reduces voriconazole concentrations to subtherapeutic levels, with risk of antifungal failure. The combination should be avoided; if unavoidable, consider another antifungal (e.g. amphotericin B, echinocandins) or another antiepileptic, with close monitoring of levels and response.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'carbamazepina'), (SELECT id FROM public.drugs WHERE slug = 'voriconazol'));
