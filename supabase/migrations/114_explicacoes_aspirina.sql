-- =====================================================================
-- 114 — Explicações fármaco-fármaco dos pares moderados da ASPIRINA
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 9 pares moderados da aspirina que os tinham vazios.
-- Padrão da 089/100: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados já citados no campo
-- source_* de cada par (DailyMed/FDA, EMA) + Prontuário Terapêutico do
-- INFARMED.
-- Mecanismos centrais da aspirina (AAS):
--   1. Hemorragia aditiva com anticoagulantes/antiagregantes (apixabano,
--      dabigatrano, rivaroxabano, enoxaparina, clopidogrel — dupla
--      antiagregação) e lesão da mucosa gastrointestinal;
--   2. Toxicidade gastrointestinal aditiva com corticosteroides (dexametasona)
--      e AINE+AINE (naproxeno);
--   3. Redução da depuração renal do metotrexato e interferência do metamizol
--      com o efeito antiagregante da aspirina.
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/9 — APIXABANO + ASPIRINA (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Apixabano + aspirina: risco hemorrágico aditivo (antiagregação + anticoagulação + lesão gastrointestinal). Avaliar criteriosamente a indicação.',
  summary_pro_en = 'Apixaban + aspirin: additive bleeding risk (antiplatelet + anticoagulant + gastrointestinal injury). Assess the indication carefully.',
  explanation_pt = 'A aspirina inibe irreversivelmente a COX-1 plaquetária e lesa a mucosa gastrointestinal; o apixabano inibe o fator Xa. Em conjunto, o risco de hemorragia — em particular digestiva — aumenta de forma aditiva e clinicamente relevante, sobretudo em idosos, com função renal diminuída, história de úlcera ou hemorragia, ou com outros antiagregantes. A dupla terapia com anticoagulante e antiagregante está reservada a indicações específicas (por exemplo, FA com doença coronária recente). Fora dessas situações, evitar a associação; se inevitável, usar a menor dose de aspirina, considerar gastroproteção e instruir o doente para sinais de hemorragia.',
  explanation_en = 'Aspirin irreversibly inhibits platelet COX-1 and injures the gastrointestinal mucosa; apixaban inhibits factor Xa. Together, the risk of bleeding — particularly digestive — increases in an additive and clinically relevant way, especially in the elderly, with reduced renal function, a history of ulcer or bleeding, or with other antiplatelet agents. Dual therapy with an anticoagulant and an antiplatelet is reserved for specific indications (for example, AF with recent coronary disease). Outside these situations, avoid the combination; if unavoidable, use the lowest aspirin dose, consider gastroprotection and instruct the patient about bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'apixabano'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'apixabano'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'));

-- 2/9 — ASPIRINA + CLOPIDOGREL (dupla antiagregação — hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + clopidogrel: dupla antiagregação com risco hemorrágico aditivo. Usar apenas nas indicações aprovadas (SCA, stents) e avaliar a duração.',
  summary_pro_en = 'Aspirin + clopidogrel: dual antiplatelet therapy with additive bleeding risk. Use only in approved indications (ACS, stents) and assess the duration.',
  explanation_pt = 'A aspirina e o clopidogrel inibem a agregação plaquetária por mecanismos complementares (COX-1 e recetor P2Y12), e a dupla antiagregação é a terapêutica padrão após síndrome coronária aguda e stents coronários, com redução de eventos trombóticos. No entanto, o benefício é acompanhado de um aumento do risco hemorrágico, em particular digestivo, sobretudo em idosos, com história de úlcera ou hemorragia, ou com anticoagulantes. A duração da dupla terapia deve ser definida pelo risco isquémico vs hemorrágico (habitualmente 1–12 meses consoante o cenário), com gastroproteção (IBP) nos doentes de risco e reavaliação periódica.',
  explanation_en = 'Aspirin and clopidogrel inhibit platelet aggregation by complementary mechanisms (COX-1 and the P2Y12 receptor), and dual antiplatelet therapy is the standard treatment after acute coronary syndrome and coronary stents, reducing thrombotic events. However, the benefit is accompanied by an increased bleeding risk, particularly digestive, especially in the elderly, with a history of ulcer or bleeding, or with anticoagulants. The duration of dual therapy should be defined by the ischaemic vs bleeding risk (usually 1–12 months depending on the scenario), with gastroprotection (PPI) in at-risk patients and periodic reassessment.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'clopidogrel'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'clopidogrel'));

-- 3/9 — ASPIRINA + DABIGATRANO (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + dabigatrano: risco hemorrágico aditivo (antiagregação + antitrombina + lesão gastrointestinal). Avaliar a indicação e a dose.',
  summary_pro_en = 'Aspirin + dabigatran: additive bleeding risk (antiplatelet + antithrombin + gastrointestinal injury). Assess the indication and dose.',
  explanation_pt = 'A aspirina inibe as plaquetas e lesa a mucosa gástrica, e o dabigatrano inibe diretamente a trombina; a associação aumenta o risco de hemorragia gastrointestinal e de outras localizações de forma aditiva. O risco é maior em idosos (mais de 75 anos), insuficiência renal (o dabigatrano é eliminado por via renal), baixo peso e história de hemorragia ou úlcera. A combinação de anticoagulante com antiagregante está reservada a indicações específicas (FA + doença coronária recente); fora delas, evitar. Se inevitável, considerar a menor dose de dabigatrano, gastroproteção e vigilância de sinais de hemorragia.',
  explanation_en = 'Aspirin inhibits platelets and injures the gastric mucosa, and dabigatran directly inhibits thrombin; the combination increases the risk of gastrointestinal and other bleeding in an additive way. The risk is higher in the elderly (over 75 years), renal impairment (dabigatran is eliminated renally), low body weight and a history of bleeding or ulcer. Anticoagulant plus antiplatelet combinations are reserved for specific indications (AF + recent coronary disease); outside them, avoid. If unavoidable, consider the lowest dabigatran dose, gastroprotection and monitoring for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'dabigatrano'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'dabigatrano'));

-- 4/9 — ASPIRINA + DEXAMETASONA (úlcera/hemorragia gastrointestinal aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + dexametasona: risco aditivo de úlcera e hemorragia gastrointestinal. Considerar gastroproteção nos doentes de risco.',
  summary_pro_en = 'Aspirin + dexamethasone: additive risk of peptic ulcer and gastrointestinal bleeding. Consider gastroprotection in at-risk patients.',
  explanation_pt = 'A aspirina (sobretudo em doses anti-inflamatórias ou com uso prolongado) inibe as prostaglandinas gastroprotetoras e pode lesar a mucosa; os corticosteroides sistémicos, como a dexametasona, inibem a reparação da mucosa e podem mascarar sinais de perfuração. Em conjunto, o risco de úlcera, hemorragia e perfuração digestiva aumenta, particularmente em idosos, em doses elevadas e em tratamentos prolongados. Considerar gastroproteção com inibidor da bomba de protões nos doentes de risco, usar a menor dose eficaz de cada fármaco e vigiar sintomas digestivos.',
  explanation_en = 'Aspirin (especially at anti-inflammatory doses or with prolonged use) inhibits gastroprotective prostaglandins and can injure the mucosa; systemic corticosteroids such as dexamethasone inhibit mucosal repair and can mask signs of perforation. Together, the risk of ulcer, bleeding and digestive perforation increases, particularly in the elderly, at high doses and in prolonged treatment. Consider gastroprotection with a proton pump inhibitor in at-risk patients, use the lowest effective dose of each drug and monitor digestive symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'dexametasona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'dexametasona'));

-- 5/9 — ASPIRINA + ENOXAPARINA (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + enoxaparina: risco hemorrágico aditivo. Usar apenas com indicação clara (SCA) e vigiar hemorragia, função renal e trombocitopenia.',
  summary_pro_en = 'Aspirin + enoxaparin: additive bleeding risk. Use only with a clear indication (ACS) and monitor bleeding, renal function and thrombocytopenia.',
  explanation_pt = 'A aspirina e a enoxaparina (heparina de baixo peso molecular) atuam em vias complementares da hemostase — antiagregação plaquetária e anti-Xa/antitrombina — e a associação é utilizada intencionalmente na síndrome coronária aguda. O risco de hemorragia (em particular digestiva e no local de punção) é aditivo, sobretudo em idosos, insuficiência renal, baixo peso ou com outros antiagregantes/anticoagulantes. Recomenda-se vigiar sinais de hemorragia, a função renal e a contagem plaquetária (risco de trombocitopenia induzida pela heparina, sobretudo com enoxaparina), e considerar gastroproteção.',
  explanation_en = 'Aspirin and enoxaparin (low-molecular-weight heparin) act on complementary haemostatic pathways — platelet antiaggregation and anti-Xa/antithrombin — and the combination is used intentionally in acute coronary syndrome. The bleeding risk (particularly digestive and at puncture sites) is additive, especially in the elderly, renal impairment, low body weight or with other antiplatelet/anticoagulant agents. Monitor signs of bleeding, renal function and platelet count (risk of heparin-induced thrombocytopenia, especially with enoxaparin), and consider gastroprotection.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'enoxaparina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'enoxaparina'));

-- 6/9 — ASPIRINA + METAMIZOL (interferência com o efeito antiagregante + risco hematológico)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + metamizol: o metamizol pode interferir com o efeito antiagregante da aspirina e adiciona risco hematológico (agranulocitose). Vigiar.',
  summary_pro_en = 'Aspirin + metamizole: metamizole can interfere with the antiplatelet effect of aspirin and adds haematological risk (agranulocytosis). Monitor.',
  explanation_pt = 'O metamizol, como alguns AINEs, pode interferir com a acetilação irreversível da COX-1 plaquetária pela aspirina e reduzir o seu efeito antiagregante, sobretudo quando tomado antes da aspirina; além disso, o metamizol associa-se a agranulocitose, embora rara. A associação deve ser ponderada: preferir paracetamol para analgesia pontual em doentes a tomar aspirina de baixa dose, separar a toma quando possível e instruir o doente para sinais de hemorragia ou de infeção (febre, faringite) que possam indicar agranulocitose.',
  explanation_en = 'Metamizole, like some NSAIDs, can interfere with the irreversible acetylation of platelet COX-1 by aspirin and reduce its antiplatelet effect, especially when taken before aspirin; additionally, metamizole is associated with agranulocytosis, although rare. The combination should be weighed: prefer paracetamol for occasional analgesia in patients taking low-dose aspirin, separate administration when possible and instruct the patient about bleeding signs or signs of infection (fever, pharyngitis) that may indicate agranulocytosis.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'metamizol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'metamizol'));

-- 7/9 — ASPIRINA + METOTREXATO (redução da depuração renal do metotrexato)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + metotrexato: o AAS reduz a depuração renal do metotrexato e aumenta a toxicidade. Evitar com doses altas; vigiar de perto com doses baixas.',
  summary_pro_en = 'Aspirin + methotrexate: aspirin reduces renal methotrexate clearance and increases toxicity. Avoid with high doses; monitor closely with low doses.',
  explanation_pt = 'O metotrexato é eliminado maioritariamente por secreção tubular renal, e os salicilatos (aspirina) e outros AINEs reduzem essa excreção por competição no túbulo, podendo aumentar as concentrações do metotrexato e o risco de mielossupressão, mucosite, hepatotoxicidade e nefrotoxicidade. Com doses altas de metotrexato (quimioterapia), a associação é contraindicada; com doses baixas (artrite reumatoide, psoríase), usar com precaução, vigiando hemograma, função renal e mucosite, sobretudo em idosos. Em doentes com indicação antiagregante, o risco deve ser ponderado com o reumatologista.',
  explanation_en = 'Methotrexate is eliminated mainly by renal tubular secretion, and salicylates (aspirin) and other NSAIDs reduce that excretion by tubular competition, potentially raising methotrexate concentrations and the risk of myelosuppression, mucositis, hepatotoxicity and nephrotoxicity. With high-dose methotrexate (chemotherapy), the combination is contraindicated; with low doses (rheumatoid arthritis, psoriasis), use with caution, monitoring blood count, renal function and mucositis, especially in the elderly. In patients with an antiplatelet indication, the risk should be weighed with the rheumatologist.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'metotrexato'));

-- 8/9 — ASPIRINA + NAPROXENO (AINE + AINE — GI aditivo e interferência)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + naproxeno: risco gastrointestinal aditivo e possível interferência do naproxeno com o efeito antiagregante da aspirina. Evitar a toma simultânea.',
  summary_pro_en = 'Aspirin + naproxen: additive gastrointestinal risk and possible interference of naproxen with the antiplatelet effect of aspirin. Avoid simultaneous administration.',
  explanation_pt = 'A associação de aspirina com outro AINE (naproxeno) soma a toxicidade gastrointestinal (úlcera, hemorragia) e renal, sem benefício analgésico adicional. Em relação ao efeito antiagregante, a interferência com a acetilação irreversível da COX-1 plaquetária pela aspirina está bem documentada com o ibuprofeno; com o naproxeno os dados são menos consistentes, mas a precaução aplica-se por prudência em doentes a tomar AAS de baixa dose. Recomenda-se evitar a toma simultânea: usar um único AINE, considerar paracetamol para analgesia e, se a aspirina antiagregante for necessária, separar a toma do naproxeno (pelo menos 2 horas, idealmente mais) ou usar um AINE com menor interferência.',
  explanation_en = 'Combining aspirin with another NSAID (naproxen) adds up gastrointestinal toxicity (ulcer, bleeding) and renal toxicity, with no additional analgesic benefit. Regarding the antiplatelet effect, interference with the irreversible acetylation of platelet COX-1 by aspirin is well documented with ibuprofen; with naproxen the data are less consistent, but the precaution applies out of prudence in patients on low-dose aspirin. Avoid simultaneous administration: use a single NSAID, consider paracetamol for analgesia and, if antiplatelet aspirin is needed, separate naproxen administration (at least 2 hours, ideally more) or use an NSAID with less interference.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'naproxeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'naproxeno'));

-- 9/9 — ASPIRINA + RIVAROXABANO (hemorragia aditiva)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Aspirina + rivaroxabano: risco hemorrágico aditivo (antiagregação + anti-Xa + lesão gastrointestinal). Avaliar a indicação e a dose.',
  summary_pro_en = 'Aspirin + rivaroxaban: additive bleeding risk (antiplatelet + anti-Xa + gastrointestinal injury). Assess the indication and dose.',
  explanation_pt = 'A aspirina inibe as plaquetas e lesa a mucosa gástrica, e o rivaroxabano inibe o fator Xa; a associação aumenta o risco de hemorragia, em particular digestiva, de forma aditiva. Fatores de risco: idade avançada, insuficiência renal ou hepática, história de úlcera ou hemorragia e uso de outros antiagregantes. A combinação anticoagulante + antiagregante está reservada a indicações específicas (por exemplo, FA + doença coronária recente, ou doença arterial periférica em que o rivaroxabano 2,5 mg é usado com aspirina de forma intencional). Fora dessas indicações, evitar; se usada, respeitar o esquema aprovado e vigiar sinais de hemorragia.',
  explanation_en = 'Aspirin inhibits platelets and injures the gastric mucosa, and rivaroxaban inhibits factor Xa; the combination increases the risk of bleeding, particularly digestive, in an additive way. Risk factors: advanced age, renal or hepatic impairment, history of ulcer or bleeding and use of other antiplatelet agents. Anticoagulant + antiplatelet combinations are reserved for specific indications (for example, AF + recent coronary disease, or peripheral artery disease in which rivaroxaban 2.5 mg is intentionally used with aspirin). Outside these indications, avoid; if used, respect the approved regimen and monitor for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'));
