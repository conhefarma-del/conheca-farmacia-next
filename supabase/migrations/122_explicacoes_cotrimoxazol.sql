-- =====================================================================
-- 122 — Explicações fármaco-fármaco dos pares moderados do COTRIMOXAZOL
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 5 pares moderados do cotrimoxazol que os tinham vazios
-- (glimepirida e glibenclamida já tinham explicação).
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado e verificado nos rótulos aprovados citados no
-- campo source_* de cada par (DailyMed/FDA) + Prontuário Terapêutico do
-- INFARMED / OMS para a sulfadoxina-pirimetamina.
-- Mecanismos centrais do cotrimoxazol (sulfametoxazol + trimetoprim):
--   1. Inibição do OCT2 (trimetoprim) — aumenta a metformina (risco de
--      acidose láctica) e a lamivudina ("Avoid coadministration... with
--      drugs that are substrates of OCT2");
--   2. Metotrexato — "Avoid concurrent use": deslocamento da ligação
--      proteica + competição renal + antifolato aditivo;
--   3. Hematológica aditiva com zidovudina (neutropenia/anemia) e
--      sulfonamida+sulfonamida com a sulfadoxina-pirimetamina (folato).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/5 — COTRIMOXAZOL + LAMIVUDINA (OCT2 — níveis ↑)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cotrimoxazol + lamivudina: o trimetoprim inibe o OCT2 e aumenta os níveis de lamivudina. Sem ajuste de dose, mas vigiar toxicidade.',
  summary_pro_en = 'Co-trimoxazole + lamivudine: trimethoprim inhibits OCT2 and raises lamivudine levels. No dose adjustment, but monitor for toxicity.',
  explanation_pt = 'A lamivudina é eliminada predominantemente por secreção renal ativa de catiões orgânicos, e o trimetoprim (componente do cotrimoxazol) inibe esses transportadores (OCT), aumentando as concentrações plasmáticas de lamivudina; o rótulo da lamivudina indica que esta interação não é considerada clinicamente significativa e que não é necessário ajuste da dose de lamivudina. O rótulo do cotrimoxazol recomenda, contudo, evitar a coadministração com substratos do OCT2 sempre que possível. Na prática, a associação é comum (profilaxia em VIH) e bem tolerada; vigiar sinais de toxicidade hematológica ou hepática nos doentes suscetíveis.',
  explanation_en = 'Lamivudine is predominantly eliminated by active renal secretion of organic cations, and trimethoprim (a co-trimoxazole component) inhibits those transporters (OCT), raising lamivudine plasma concentrations; the lamivudine label states this interaction is not considered clinically significant and that no lamivudine dose adjustment is needed. The co-trimoxazole label, however, recommends avoiding co-administration with OCT2 substrates whenever possible. In practice, the combination is common (HIV prophylaxis) and well tolerated; monitor for haematological or hepatic toxicity in susceptible patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'lamivudina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'lamivudina'));

-- 2/5 — COTRIMOXAZOL + METFORMINA (OCT2 — risco de acidose láctica)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cotrimoxazol + metformina: o trimetoprim inibe o OCT2 e aumenta os níveis de metformina, com risco de acidose láctica. Vigiar função renal e glicemia.',
  summary_pro_en = 'Co-trimoxazole + metformin: trimethoprim inhibits OCT2 and raises metformin levels, with a risk of lactic acidosis. Monitor renal function and glycaemia.',
  explanation_pt = 'A metformina é eliminada por via renal através do transportador de catiões orgânicos OCT2, e o trimetoprim (componente do cotrimoxazol) é um inibidor do OCT2, podendo aumentar as concentrações de metformina e o risco de acidose láctica, sobretudo em doentes com função renal diminuída, idosos ou com outras causas de acidose; o rótulo do cotrimoxazol recomenda evitar a coadministração com substratos do OCT2 (a metformina é explicitamente mencionada) e monitorizar a glicemia. Durante a associação, vigiar a função renal, sinais de acidose láctica (mal-estar, mialgias, dor abdominal, dispneia, sonolência) e considerar a suspensão temporária da metformina em doentes de risco.',
  explanation_en = 'Metformin is eliminated renally through the organic cation transporter OCT2, and trimethoprim (a co-trimoxazole component) is an OCT2 inhibitor, which can raise metformin concentrations and the risk of lactic acidosis, especially in patients with reduced renal function, the elderly or with other causes of acidosis; the co-trimoxazole label recommends avoiding co-administration with OCT2 substrates (metformin is explicitly mentioned) and monitoring glycaemia. During the combination, monitor renal function, signs of lactic acidosis (malaise, myalgia, abdominal pain, dyspnoea, drowsiness) and consider temporarily stopping metformin in at-risk patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'metformina'));

-- 3/5 — COTRIMOXAZOL + METOTREXATO (antifolato aditivo — evitar)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cotrimoxazol + metotrexato: evitar a associação — antifolato aditivo, deslocamento proteico e competição renal com risco de mielossupressão.',
  summary_pro_en = 'Co-trimoxazole + methotrexate: avoid the combination — additive antifolate effect, protein binding displacement and renal competition with a risk of myelosuppression.',
  explanation_pt = 'O rótulo do cotrimoxazol recomenda evitar o uso concomitante com metotrexato: as sulfonamidas podem deslocar o metotrexato da ligação às proteínas plasmáticas e competir com o transporte renal do metotrexato, aumentando as concentrações de metotrexato livre; além disso, o trimetoprim é um antifolato (inibidor da dihidrofolato redutase) que soma o seu efeito ao do metotrexato, e o rótulo do metotrexato lista as sulfonamidas entre os fármacos a evitar. O risco de mielossupressão, mucosite e toxicidade hematológica é particularmente relevante com doses altas de metotrexato (quimioterapia); mesmo com doses baixas (artrite reumatoide), evitar ou, se inevitável, vigiar de perto o hemograma, a função renal e a mucosite.',
  explanation_en = 'The co-trimoxazole label recommends avoiding concomitant use with methotrexate: sulfonamides can displace methotrexate from plasma protein binding and compete with renal methotrexate transport, raising free methotrexate concentrations; additionally, trimethoprim is an antifolate (dihydrofolate reductase inhibitor) that adds its effect to that of methotrexate, and the methotrexate label lists sulfonamides among the drugs to avoid. The risk of myelosuppression, mucositis and haematological toxicity is particularly relevant with high-dose methotrexate (chemotherapy); even with low doses (rheumatoid arthritis), avoid or, if unavoidable, closely monitor the blood count, renal function and mucositis.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'));

-- 4/5 — COTRIMOXAZOL + SULFADOXINA-PIRIMETAMINA (sulfonamida + sulfonamida)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cotrimoxazol + sulfadoxina-pirimetamina: associação de sulfonamidas com antifolato — risco aditivo de reações hematológicas e de hipersensibilidade. Evitar.',
  summary_pro_en = 'Co-trimoxazole + sulfadoxine-pyrimethamine: combination of sulfonamides with antifolate — additive risk of haematological reactions and hypersensitivity. Avoid.',
  explanation_pt = 'O cotrimoxazol (sulfametoxazol + trimetoprim) e a sulfadoxina-pirimetamina partilham componentes sulfonamida (sulfametoxazol e sulfadoxina) e antifolato (trimetoprim e pirimetamina, ambos inibidores da dihidrofolato redutase); a associação soma o risco de reações adversas hematológicas (anemia megaloblástica, neutropenia, trombocitopenia por depleção de folato), dermatológicas graves e de hipersensibilidade, sem benefício antimicrobiano adicional. A OMS (Diretrizes para a malária) não recomenda o uso concomitante de duas associações com sulfonamidas/antifolatos. Evitar a associação e escolher um esquema alternativo; se inevitável, monitorizar o hemograma e a função hepática.',
  explanation_en = 'Co-trimoxazole (sulfamethoxazole + trimethoprim) and sulfadoxine-pyrimethamine share sulfonamide components (sulfamethoxazole and sulfadoxine) and antifolate components (trimethoprim and pyrimethamine, both dihydrofolate reductase inhibitors); the combination adds up the risk of haematological adverse reactions (megaloblastic anaemia, neutropenia, thrombocytopenia from folate depletion), severe skin reactions and hypersensitivity, with no additional antimicrobial benefit. The WHO (Guidelines for malaria) does not recommend the concomitant use of two sulfonamide/antifolate combinations. Avoid the combination and choose an alternative regimen; if unavoidable, monitor the blood count and liver function.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'sulfadoxina-pirimetamina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'sulfadoxina-pirimetamina'));

-- 5/5 — COTRIMOXAZOL + ZIDOVUDINA (hematológica aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Cotrimoxazol + zidovudina: risco aditivo de mielossupressão (neutropenia e anemia). Monitorizar hemograma na profilaxia em VIH.',
  summary_pro_en = 'Co-trimoxazole + zidovudine: additive risk of myelosuppression (neutropenia and anaemia). Monitor the blood count in HIV prophylaxis.',
  explanation_pt = 'A zidovudina associa-se a toxicidade hematológica, incluindo neutropenia e anemia grave, sobretudo em doentes com VIH avançado; o cotrimoxazol, com o seu componente antifolato (trimetoprim) e o efeito das sulfonamidas na medula, soma o risco de mielossupressão quando usado concomitantemente (a associação é comum na profilaxia de pneumocistose em VIH). Recomenda-se monitorizar o hemograma com regularidade durante a associação, sobretudo nos primeiros meses de tratamento e em doentes com contagens baixas; considerar ácido folínico se surgir depleção de folato e ajustar ou interromper a zidovudina perante neutropenia ou anemia significativas.',
  explanation_en = 'Zidovudine is associated with haematological toxicity, including neutropenia and severe anaemia, especially in patients with advanced HIV; co-trimoxazole, with its antifolate component (trimethoprim) and the bone marrow effect of sulfonamides, adds the risk of myelosuppression when used concomitantly (the combination is common in Pneumocystis prophylaxis in HIV). Monitor the blood count regularly during the combination, especially in the first months of treatment and in patients with low counts; consider folinic acid if folate depletion arises and adjust or interrupt zidovudine in the face of significant neutropenia or anaemia.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'zidovudina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'), (SELECT id FROM public.drugs WHERE slug = 'zidovudina'));
