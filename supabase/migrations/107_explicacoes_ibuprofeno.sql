-- =====================================================================
-- 107 — Explicações fármaco-fármaco dos pares moderados do IBUPROFENO
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 15 pares moderados do ibuprofeno que os tinham vazios.
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do INFARMED.
-- Mecanismo central: o ibuprofeno é um AINE não seletivo (inibição da COX-1
-- e COX-2) — agrega inibição plaquetária reversível, lesão da mucosa
-- gastrointestinal e redução das prostaglandinas renais.
-- Grupos: anticoagulantes/DOACs (hemorragia), AINE+AINE (toxicidade aditiva),
-- corticosteroides (GI), IECA (renal/TA), lítio e metotrexato (depuração
-- renal), aminoglicosídeo (nefrotoxicidade), fluoroquinolona (SNC/convulsões),
-- bisfosfonato (GI), paracetamol (uso prolongado).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/15 — ALENDRONATO + IBUPROFENO (irritação gastrointestinal aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Alendronato + ibuprofeno: risco aditivo de irritação e lesão gastrointestinal alta (esofagite/úlcera). Usar com precaução, sobretudo em idosos e com história de úlcera.',
  summary_pro_en = 'Alendronate + ibuprofen: additive risk of upper gastrointestinal irritation and injury (esophagitis/ulcer). Use with caution, especially in the elderly and in patients with a history of ulcer.',
  explanation_pt = 'O alendronato, como os bisfosfonatos orais, pode irritar a mucosa esofágica e gástrica, enquanto o ibuprofeno inibe as prostaglandinas gastroprotetoras (COX-1), aumentando o risco de úlcera e hemorragia. A associação potencia o risco de lesão gastrointestinal alta: esofagite, úlcera péptica e hemorragia, particularmente em idosos, em doentes com história de úlcera ou com doses elevadas de AINE. Recomenda-se tomar o alendronato em jejum com água (conforme a posologia), considerar gastroproteção nos doentes de risco e usar a menor dose eficaz de ibuprofeno pelo menor tempo possível, vigiando sintomas como dor epigástrica, disfagia e melenas.',
  explanation_en = 'Alendronate, like oral bisphosphonates, can irritate the esophageal and gastric mucosa, while ibuprofen inhibits gastroprotective prostaglandins (COX-1), increasing the risk of ulcer and bleeding. The combination potentiates the risk of upper gastrointestinal injury: esophagitis, peptic ulcer and bleeding, particularly in the elderly, in patients with a history of ulcer or with high NSAID doses. Take alendronate on an empty stomach with water (as per the dosing instructions), consider gastroprotection in at-risk patients and use the lowest effective ibuprofen dose for the shortest time, watching for symptoms such as epigastric pain, dysphagia and melaena.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alendronato'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alendronato'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 2/15 — APIXABANO + IBUPROFENO (risco hemorrágico aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Apixabano + ibuprofeno: risco hemorrágico aditivo (inibição plaquetária + lesão da mucosa gastrointestinal). Evitar ou usar com precaução extrema e vigiar sinais de hemorragia.',
  summary_pro_en = 'Apixaban + ibuprofen: additive bleeding risk (platelet inhibition + gastrointestinal mucosal injury). Avoid or use with extreme caution and monitor for signs of bleeding.',
  explanation_pt = 'O apixabano inibe o fator Xa, reduzindo a coagulação, e o ibuprofeno acrescenta inibição plaquetária reversível e lesão da mucosa gastrointestinal — dois mecanismos independentes que aumentam o risco de hemorragia, incluindo digestiva alta e intracraniana. O risco é maior em idosos (mais de 75 anos), com função renal diminuída, com história de úlcera ou hemorragia, ou com uso concomitante de outros antiagregantes. Sempre que possível, evitar a associação; se inevitável, usar a menor dose eficaz de ibuprofeno pelo menor tempo, considerar gastroproteção e instruir o doente para sinais de alarme (sangue nas fezes, hematúria, equimoses extensas, cefaleia súbita).',
  explanation_en = 'Apixaban inhibits factor Xa, reducing coagulation, and ibuprofen adds reversible platelet inhibition and gastrointestinal mucosal injury — two independent mechanisms that increase the risk of bleeding, including upper gastrointestinal and intracranial haemorrhage. The risk is higher in the elderly (over 75 years), in patients with reduced renal function, with a history of ulcer or bleeding, or with concomitant use of other antiplatelet agents. Whenever possible, avoid the combination; if unavoidable, use the lowest effective ibuprofen dose for the shortest time, consider gastroprotection and instruct the patient about alarm signs (blood in the stool, haematuria, extensive bruising, sudden headache).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'apixabano'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'apixabano'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 3/15 — CELECOXIB + IBUPROFENO (AINE + AINE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Celecoxib + ibuprofeno (dois AINEs): sem benefício analgésico adicional e com risco aumentado de efeitos gastrointestinais, renais e cardiovasculares. Não associar.',
  summary_pro_en = 'Celecoxib + ibuprofen (two NSAIDs): no additional analgesic benefit and increased risk of gastrointestinal, renal and cardiovascular effects. Do not combine.',
  explanation_pt = 'Combinar dois AINEs — o celecoxib, inibidor seletivo da COX-2, com o ibuprofeno, não seletivo — não acrescenta eficácia analgésica, mas aumenta a toxicidade: risco gastrointestinal (dispepsia, úlcera, hemorragia), renal (retenção de sódio, insuficiência renal aguda em doentes de risco) e cardiovascular (hipertensão, eventos trombóticos). Os coxibes mantêm o risco cardiovascular e renal mesmo com a poupança gastrointestinal relativa. Deve escolher-se um único AINE na dose eficaz mais baixa; a associação crónica de dois AINEs deve ser evitada, sobretudo em idosos e em doentes com doença renal, cardiovascular ou história de úlcera.',
  explanation_en = 'Combining two NSAIDs — celecoxib, a selective COX-2 inhibitor, with ibuprofen, a non-selective one — adds no analgesic efficacy but increases toxicity: gastrointestinal risk (dyspepsia, ulcer, bleeding), renal risk (sodium retention, acute kidney injury in at-risk patients) and cardiovascular risk (hypertension, thrombotic events). Coxibs keep the cardiovascular and renal risk even with the relative gastrointestinal sparing. A single NSAID at the lowest effective dose should be chosen; chronic combination of two NSAIDs should be avoided, especially in the elderly and in patients with renal or cardiovascular disease or a history of ulcer.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'celecoxib'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'celecoxib'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 4/15 — DABIGATRANO + IBUPROFENO (risco hemorrágico aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dabigatrano + ibuprofeno: risco hemorrágico aditivo (antiagregação + lesão gastrointestinal). Evitar em doentes de alto risco e vigiar sinais de hemorragia.',
  summary_pro_en = 'Dabigatran + ibuprofen: additive bleeding risk (antiplatelet effect + gastrointestinal injury). Avoid in high-risk patients and monitor for signs of bleeding.',
  explanation_pt = 'O dabigatrano é um inibidor direto da trombina; o ibuprofeno inibe reversivelmente a COX-1 plaquetária e lesa a mucosa gástrica. A soma destes efeitos aumenta o risco de hemorragia gastrointestinal e de outras localizações. Fatores que agravam o risco: idade avançada, insuficiência renal (o dabigatrano é eliminado por via renal), peso baixo, história de hemorragia ou úlcera. Preferir, se necessário, um analgésico sem efeito antiagregante (paracetamol) e, se o AINE for inevitável, usá-lo na menor dose e pelo menor tempo possível, com vigilância de hemorragia e da função renal.',
  explanation_en = 'Dabigatran is a direct thrombin inhibitor; ibuprofen reversibly inhibits platelet COX-1 and injures the gastric mucosa. The sum of these effects increases the risk of gastrointestinal and other bleeding. Aggravating factors: advanced age, renal impairment (dabigatran is eliminated renally), low body weight, history of bleeding or ulcer. Prefer, when needed, an analgesic without antiplatelet effect (paracetamol) and, if the NSAID is unavoidable, use the lowest dose for the shortest possible time, with monitoring of bleeding and renal function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dabigatrano'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dabigatrano'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 5/15 — DEXAMETASONA + IBUPROFENO (úlcera/hemorragia gastrointestinal aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dexametasona + ibuprofeno: risco aditivo de úlcera e hemorragia gastrointestinal. Considerar gastroproteção nos doentes de risco.',
  summary_pro_en = 'Dexamethasone + ibuprofen: additive risk of peptic ulcer and gastrointestinal bleeding. Consider gastroprotection in at-risk patients.',
  explanation_pt = 'Tanto os corticosteroides como os AINEs podem lesar a mucosa gastrointestinal; a associação aumenta o risco de úlcera péptica, perfuração e hemorragia digestiva, sobretudo em idosos, em doses altas e em tratamentos prolongados. A dexametasona também pode mascarar sinais de infeção e alterar o metabolismo, enquanto o ibuprofeno acrescenta inibição plaquetária. Usar a menor dose de corticoide pelo menor tempo, considerar gastroproteção (inibidor da bomba de protões) nos doentes de risco e vigiar sintomas digestivos.',
  explanation_en = 'Both corticosteroids and NSAIDs can injure the gastrointestinal mucosa; the combination increases the risk of peptic ulcer, perforation and digestive bleeding, especially in the elderly, at high doses and in prolonged treatment. Dexamethasone can also mask signs of infection and alter metabolism, while ibuprofen adds platelet inhibition. Use the lowest corticosteroid dose for the shortest time, consider gastroprotection (proton pump inhibitor) in at-risk patients and monitor digestive symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 6/15 — DICLOFENAC + IBUPROFENO (AINE + AINE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diclofenac + ibuprofeno (dois AINEs): sem benefício analgésico e com risco aumentado de toxicidade gastrointestinal, renal e cardiovascular. Não associar.',
  summary_pro_en = 'Diclofenac + ibuprofen (two NSAIDs): no analgesic benefit and increased risk of gastrointestinal, renal and cardiovascular toxicity. Do not combine.',
  explanation_pt = 'A associação de dois AINEs não seletivos não melhora a analgesia e soma os efeitos adversos: lesão gastrointestinal (dispepsia, úlcera, hemorragia), retenção de sódio e lesão renal (sobretudo em idosos, hipovolémicos ou com doença renal prévia) e risco cardiovascular. Ambos inibem a COX-1, pelo que o efeito antiagregante e gástrico é aditivo. Deve usar-se um único AINE, na menor dose eficaz, e optar por alternativas não farmacológicas ou paracetamol quando adequado. A associação crónica deve ser evitada.',
  explanation_en = 'Combining two non-selective NSAIDs does not improve analgesia and adds up the adverse effects: gastrointestinal injury (dyspepsia, ulcer, bleeding), sodium retention and renal injury (especially in the elderly, in hypovolaemic patients or in those with pre-existing renal disease) and cardiovascular risk. Both inhibit COX-1, so the antiplatelet and gastric effect is additive. A single NSAID should be used at the lowest effective dose, preferring non-pharmacological alternatives or paracetamol when appropriate. Chronic combination should be avoided.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 7/15 — ENALAPRIL + IBUPROFENO (redução do efeito do IECA + função renal)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Enalapril + ibuprofeno: o AINE reduz o efeito anti-hipertensor e nefroprotetor do IECA e pode deteriorar a função renal. Vigiar pressão arterial, creatinina e potássio.',
  summary_pro_en = 'Enalapril + ibuprofen: the NSAID reduces the antihypertensive and nephroprotective effect of the ACE inhibitor and can worsen renal function. Monitor blood pressure, creatinine and potassium.',
  explanation_pt = 'Os AINEs inibem a síntese de prostaglandinas renais, essenciais para manter a vasodilatação da arteríola aferente em doentes com fluxo renal reduzido; os IECA bloqueiam a angiotensina II, que contrai a arteríola eferente. A associação pode causar insuficiência renal aguda (sobretudo em idosos, desidratação, insuficiência cardíaca ou uso de diuréticos), reduzir o efeito anti-hipertensor e nefroprotetor do enalapril e causar retenção de sódio e possível hipercaliemia. Recomenda-se vigiar a pressão arterial, a creatinina e o potássio após iniciar ou ajustar o AINE, garantir hidratação adequada e considerar uma alternativa analgésica (paracetamol).',
  explanation_en = 'NSAIDs inhibit the synthesis of renal prostaglandins, which are essential to maintain afferent arteriolar vasodilation in patients with reduced renal blood flow; ACE inhibitors block angiotensin II, which constricts the efferent arteriole. The combination can cause acute kidney injury (especially in the elderly, dehydration, heart failure or diuretic use), reduce the antihypertensive and nephroprotective effect of enalapril and cause sodium retention and possible hyperkalaemia. Monitor blood pressure, creatinine and potassium after starting or adjusting the NSAID, ensure adequate hydration and consider an analgesic alternative (paracetamol).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 8/15 — ESTREPTOMICINA + IBUPROFENO (nefrotoxicidade aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Estreptomicina + ibuprofeno: risco aditivo de nefrotoxicidade. Vigiar função renal e manter hidratação adequada.',
  summary_pro_en = 'Streptomycin + ibuprofen: additive risk of nephrotoxicity. Monitor renal function and maintain adequate hydration.',
  explanation_pt = 'A estreptomicina é um aminoglicosídeo com nefrotoxicidade e ototoxicidade conhecidas; o ibuprofeno, ao inibir as prostaglandinas renais, reduz o fluxo sanguíneo renal e pode potenciar a lesão tubular. A associação aumenta o risco de insuficiência renal aguda, sobretudo em idosos, desidratados ou com doença renal prévia. Recomenda-se vigiar a creatinina durante o tratamento, manter hidratação adequada e usar o AINE apenas se estritamente necessário e na menor dose eficaz.',
  explanation_en = 'Streptomycin is an aminoglycoside with well-known nephrotoxicity and ototoxicity; ibuprofen, by inhibiting renal prostaglandins, reduces renal blood flow and can potentiate tubular injury. The combination increases the risk of acute kidney injury, especially in the elderly, in dehydrated patients or in those with pre-existing renal disease. Monitor creatinine during treatment, maintain adequate hydration and use the NSAID only if strictly necessary and at the lowest effective dose.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'estreptomicina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'estreptomicina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- 9/15 — IBUPROFENO + LEVOFLOXACINA (SNC / limiar convulsivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Levofloxacina + ibuprofeno: risco aumentado de estimulação do SNC e convulsões. Evitar em doentes com epilepsia ou história de convulsões.',
  summary_pro_en = 'Levofloxacin + ibuprofen: increased risk of CNS stimulation and seizures. Avoid in patients with epilepsy or a history of seizures.',
  explanation_pt = 'As fluoroquinolonas, como a levofloxacina, antagonizam os recetores GABA, diminuindo o limiar convulsivo; os AINEs (ibuprofeno) podem potenciar este efeito, aumentando o risco de convulsões, sobretudo em doentes com epilepsia, lesão cerebral ou insuficiência renal. O rótulo da levofloxacina e o Prontuário Terapêutico desaconselham a associação em doentes predispostos. Se o antibiótico for necessário, preferir um analgésico alternativo ou vigiar de perto; alertar o doente para sintomas neurológicos (tonturas, confusão, tremor) e suspender perante qualquer sinal.',
  explanation_en = 'Fluoroquinolones, such as levofloxacin, antagonise GABA receptors, lowering the seizure threshold; NSAIDs (ibuprofen) can potentiate this effect, increasing the risk of seizures, especially in patients with epilepsy, brain injury or renal impairment. The levofloxacin label and the Portuguese Prontuário Terapêutico advise against the combination in predisposed patients. If the antibiotic is needed, prefer an alternative analgesic or monitor closely; warn the patient about neurological symptoms (dizziness, confusion, tremor) and stop at any sign.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'levofloxacina'));

-- 10/15 — IBUPROFENO + LÍTIO (redução da depuração renal do lítio)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ibuprofeno + lítio: o AINE reduz a depuração renal do lítio, com risco de aumento da litemia e toxicidade (tremor, confusão, convulsões). Monitorizar litemia.',
  summary_pro_en = 'Ibuprofen + lithium: the NSAID reduces renal lithium clearance, with a risk of raised serum lithium and toxicity (tremor, confusion, seizures). Monitor lithium levels.',
  explanation_pt = 'Os AINEs, ao inibirem a síntese de prostaglandinas renais, reduzem o fluxo sanguíneo renal e a excreção do lítio, podendo aumentar a litemia e precipitar toxicidade (náuseas, tremor grosseiro, confusão, ataxia, convulsões) em poucos dias. O efeito é particularmente relevante em idosos e em doentes com função renal diminuída. O rótulo do lítio e o Prontuário Terapêutico recomendam monitorizar a litemia e os sinais de toxicidade ao iniciar, ajustar ou suspender o AINE, e preferir paracetamol como analgésico.',
  explanation_en = 'NSAIDs, by inhibiting the synthesis of renal prostaglandins, reduce renal blood flow and lithium excretion, potentially raising serum lithium and precipitating toxicity (nausea, coarse tremor, confusion, ataxia, seizures) within days. The effect is particularly relevant in the elderly and in patients with reduced renal function. The lithium label and the Portuguese Prontuário Terapêutico recommend monitoring serum lithium and signs of toxicity when starting, adjusting or stopping the NSAID, and preferring paracetamol as the analgesic.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'litio'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'litio'));

-- 11/15 — IBUPROFENO + METOTREXATO (redução da depuração renal do metotrexato)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ibuprofeno + metotrexato: o AINE reduz a depuração renal do metotrexato, com risco de mielossupressão e toxicidade grave. Evitar com doses altas; vigiar de perto com doses baixas.',
  summary_pro_en = 'Ibuprofen + methotrexate: the NSAID reduces renal methotrexate clearance, with a risk of myelosuppression and severe toxicity. Avoid with high doses; monitor closely with low doses.',
  explanation_pt = 'O metotrexato é eliminado maioritariamente por secreção tubular renal; os AINEs reduzem essa excreção (por competição e por redução do fluxo renal) e podem aumentar as concentrações do metotrexato e o risco de mielossupressão, mucosite, hepatotoxicidade e nefrotoxicidade. Com doses altas de metotrexato (quimioterapia) a associação é contraindicada; com doses baixas (artrite reumatoide, psoríase) deve usar-se com precaução, vigiando hemograma, função renal e mucosite, sobretudo em idosos.',
  explanation_en = 'Methotrexate is eliminated mainly by renal tubular secretion; NSAIDs reduce this excretion (by competition and by reducing renal blood flow) and can raise methotrexate concentrations and the risk of myelosuppression, mucositis, hepatotoxicity and nephrotoxicity. With high-dose methotrexate (chemotherapy) the combination is contraindicated; with low doses (rheumatoid arthritis, psoriasis) it should be used with caution, monitoring blood count, renal function and mucositis, especially in the elderly.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'));

-- 12/15 — IBUPROFENO + NAPROXENO (AINE + AINE)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ibuprofeno + naproxeno (dois AINEs): risco aditivo de toxicidade gastrointestinal, renal e cardiovascular, sem benefício analgésico. Não associar.',
  summary_pro_en = 'Ibuprofen + naproxen (two NSAIDs): additive risk of gastrointestinal, renal and cardiovascular toxicity, without analgesic benefit. Do not combine.',
  explanation_pt = 'Tal como noutras associações de dois AINEs, ibuprofeno + naproxeno não aumenta a eficácia analgésica mas soma os riscos: hemorragia e úlcera gastrointestinal, retenção de sódio e deterioração renal, e eventos cardiovasculares. Ambos inibem a COX-1 plaquetária e gástrica, pelo que o efeito antiagregante e lesivo para a mucosa é aditivo. Recomenda-se usar um único AINE na menor dose eficaz, alternando com paracetamol se necessário, e evitar a toma simultânea crónica.',
  explanation_en = 'As with other combinations of two NSAIDs, ibuprofen + naproxen does not increase analgesic efficacy but adds up the risks: gastrointestinal bleeding and ulcer, sodium retention and renal deterioration, and cardiovascular events. Both inhibit platelet and gastric COX-1, so the antiplatelet and mucosal-injury effect is additive. Use a single NSAID at the lowest effective dose, alternating with paracetamol if needed, and avoid chronic simultaneous use.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'naproxeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'naproxeno'));

-- 13/15 — IBUPROFENO + PARACETAMOL (uso prolongado: renal/GI)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Ibuprofeno + paracetamol: uso combinado prolongado e em doses altas aumenta o risco de lesão renal e hemorragia gastrointestinal. Respeitar limites diários e vigiar função renal.',
  summary_pro_en = 'Ibuprofen + paracetamol: prolonged combined use at high doses increases the risk of renal injury and gastrointestinal bleeding. Respect daily limits and monitor renal function.',
  explanation_pt = 'O paracetamol e o ibuprofeno têm mecanismos diferentes, mas a utilização crónica e em doses elevadas de ambos aumenta o risco de nefrotoxicidade (necrose papilar, insuficiência renal) e, segundo alguns estudos, o risco de hemorragia gastrointestinal e de eventos cardiovasculares quando comparado com cada fármaco isolado. Para analgesia pontual a associação é aceitável (efeito aditivo), mas deve evitar-se o uso prolongado sem supervisão, respeitar os limites diários (paracetamol até 3–4 g/dia; ibuprofeno conforme apresentação) e vigiar a função renal em doentes de risco.',
  explanation_en = 'Paracetamol and ibuprofen have different mechanisms, but chronic use of both at high doses increases the risk of nephrotoxicity (papillary necrosis, renal failure) and, according to some studies, the risk of gastrointestinal bleeding and cardiovascular events compared with each drug alone. For occasional analgesia the combination is acceptable (additive effect), but prolonged unsupervised use should be avoided, daily limits should be respected (paracetamol up to 3–4 g/day; ibuprofen per presentation) and renal function should be monitored in at-risk patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'paracetamol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'paracetamol'));

-- 14/15 — IBUPROFENO + PREDNISOLONA (úlcera/hemorragia gastrointestinal aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Prednisolona + ibuprofeno: risco aditivo de úlcera péptica e hemorragia gastrointestinal. Considerar gastroproteção, sobretudo em idosos.',
  summary_pro_en = 'Prednisolone + ibuprofen: additive risk of peptic ulcer and gastrointestinal bleeding. Consider gastroprotection, especially in the elderly.',
  explanation_pt = 'A prednisolona, como os corticosteroides sistémicos, inibe a reparação da mucosa e pode mascarar sinais de perfuração; o ibuprofeno reduz as prostaglandinas gastroprotetoras e inibe a agregação plaquetária. Em conjunto, o risco de úlcera, hemorragia e perfuração digestiva aumenta, sobretudo em idosos, em doses altas e em terapêuticas prolongadas. Sempre que possível, usar a menor dose de corticoide pelo menor tempo, considerar gastroproteção (inibidor da bomba de protões) nos doentes de risco e vigiar sintomas digestivos e sinais de anemia.',
  explanation_en = 'Prednisolone, like systemic corticosteroids, inhibits mucosal repair and can mask signs of perforation; ibuprofen reduces gastroprotective prostaglandins and inhibits platelet aggregation. Together, the risk of ulcer, bleeding and digestive perforation increases, especially in the elderly, at high doses and in prolonged therapy. Whenever possible, use the lowest corticosteroid dose for the shortest time, consider gastroprotection (proton pump inhibitor) in at-risk patients and monitor digestive symptoms and signs of anaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

-- 15/15 — IBUPROFENO + RIVAROXABANO (risco hemorrágico aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Rivaroxabano + ibuprofeno: risco hemorrágico aditivo. Evitar se possível; se inevitável, usar menor dose, menor tempo e vigiar sinais de hemorragia.',
  summary_pro_en = 'Rivaroxaban + ibuprofen: additive bleeding risk. Avoid if possible; if unavoidable, use the lowest dose, shortest time and monitor for signs of bleeding.',
  explanation_pt = 'O rivaroxabano inibe o fator Xa e o ibuprofeno acrescenta inibição plaquetária e lesão da mucosa gastrointestinal, aumentando o risco de hemorragia, em particular digestiva. Fatores de risco: idade avançada, insuficiência renal ou hepática, história de hemorragia ou úlcera e uso de outros antiagregantes. Preferir paracetamol para analgesia; se o AINE for necessário, usar a menor dose eficaz pelo menor tempo, considerar gastroproteção e instruir o doente para sinais de hemorragia (fezes escuras, hematúria, equimoses, cefaleia súbita).',
  explanation_en = 'Rivaroxaban inhibits factor Xa and ibuprofen adds platelet inhibition and gastrointestinal mucosal injury, increasing the risk of bleeding, particularly digestive. Risk factors: advanced age, renal or hepatic impairment, history of bleeding or ulcer and use of other antiplatelet agents. Prefer paracetamol for analgesia; if the NSAID is needed, use the lowest effective dose for the shortest time, consider gastroprotection and instruct the patient about bleeding signs (dark stools, haematuria, bruising, sudden headache).',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'));
