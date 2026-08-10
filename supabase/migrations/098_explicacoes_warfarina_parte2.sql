-- =====================================================================
-- 098 — Explicações fármaco-fármaco dos pares moderados da WARFARINA (2/2)
-- ---------------------------------------------------------------------
-- Preenche summary_pro_* (resumo profissional) e explanation_* (explicação
-- longa) dos 18 pares moderados restantes da warfarina (AINEs,
-- cardiovasculares, hormonas, antiepiléticos e outros) que os tinham
-- vazios — segundo lote dos 319 pares moderados sem explicação.
-- Padrão da 089: UPDATE com LEAST/GREATEST canónico + updated_at = now().
-- Conteúdo autoral, ancorado nos rótulos aprovados citados no campo
-- source_* já existente de cada par (DailyMed/FDA, EMA/EMC-UK).
-- Idempotente: reaplicar é seguro.
-- =====================================================================

-- 1/18 — CELECOXIB + WARFARINA (risco hemorrágico aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE + warfarina: aumento do risco hemorrágico (GI e geral). O celecoxib é preferível a outros AINEs, mas exige monitorizar o INR e vigiar hemorragia.',
  summary_pro_en = 'NSAID + warfarin: increased bleeding risk (GI and general). Celecoxib is preferable to other NSAIDs, but requires INR monitoring and bleeding vigilance.',
  explanation_pt = 'Os anti-inflamatórios não esteroides (AINEs), incluindo os inibidores seletivos da COX-2 como o celecoxib, aumentam o risco de hemorragia em doentes anticoagulados por mecanismos que se somam ao da warfarina: inibição da agregação plaquetária, lesão da mucosa gástrica e, em alguns casos, interferência com o metabolismo da warfarina. O celecoxib tem menor efeito antiagregante e gastrointestinal que os AINEs não seletivos, mas o risco hemorrágico global permanece aumentado. Recomenda-se usar a menor dose eficaz pelo menor tempo, monitorizar o INR quando se inicia ou ajusta o celecoxib e vigiar sinais de hemorragia gastrointestinal; considerar gastroproteção nos doentes de risco.',
  explanation_en = 'Non-steroidal anti-inflammatory drugs (NSAIDs), including selective COX-2 inhibitors such as celecoxib, increase the bleeding risk in anticoagulated patients through mechanisms that add to warfarin''s: platelet aggregation inhibition, gastric mucosal injury and, in some cases, interference with warfarin metabolism. Celecoxib has less antiplatelet and gastrointestinal effect than non-selective NSAIDs, but the overall bleeding risk remains increased. Use the lowest effective dose for the shortest time, monitor the INR when celecoxib is started or adjusted, and watch for gastrointestinal bleeding signs; consider gastroprotection in at-risk patients.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'celecoxib'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'celecoxib'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 2/18 — COLCHICINA + WARFARINA (inibição do CYP3A4)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A colchicina inibe o CYP3A4 e pode aumentar os níveis de warfarina e o INR. Monitorizar o INR ao iniciar e ajustar a dose.',
  summary_pro_en = 'Colchicine inhibits CYP3A4 and can raise warfarin levels and the INR. Monitor the INR when starting and adjust the dose.',
  explanation_pt = 'A colchicina é substrato e inibidor do CYP3A4, enzima envolvida no metabolismo da warfarina; a inibição pode reduzir a clearance da warfarina e aumentar o INR. A interação é relevante sobretudo em tratamentos prolongados (ex.: profilaxia da gota, febre mediterrânica familiar), nos quais o efeito se acumula. Recomenda-se monitorizar o INR ao iniciar a colchicina e após ajustes, e vigiar sinais de hemorragia; em doentes com insuficiência renal ou hepática, o risco de toxicidade de ambos os fármacos aumenta.',
  explanation_en = 'Colchicine is a substrate and inhibitor of CYP3A4, an enzyme involved in warfarin metabolism; the inhibition can reduce warfarin clearance and raise the INR. The interaction is especially relevant in prolonged treatment (e.g. gout prophylaxis, familial Mediterranean fever), in which the effect accumulates. Monitor the INR when starting colchicine and after dose changes, and watch for bleeding signs; in renal or hepatic impairment, the toxicity risk of both drugs increases.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'colchicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'colchicina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 3/18 — DABIGATRANO + WARFARINA (dupla anticoagulação)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dois anticoagulantes em simultâneo: risco hemorrágico aditivo. Não associar; a transição entre warfarina e dabigatrano exige protocolo (suspender um, iniciar o outro com INR/coagulação controlada).',
  summary_pro_en = 'Two anticoagulants at the same time: additive bleeding risk. Do not combine; switching between warfarin and dabigatran requires a protocol (stop one, start the other with controlled INR/coagulation).',
  explanation_pt = 'A associação de warfarina e dabigatrano (dois anticoagulantes com mecanismos diferentes — antagonismo da vitamina K e inibição direta da trombina) não tem indicação terapêutica e multiplica o risco de hemorragia major, incluindo hemorragia intracraniana. A transição entre os dois fármacos deve seguir protocolo: ao mudar de warfarina para dabigatrano, suspender a warfarina e iniciar o dabigatrano quando o INR estiver abaixo do limiar; ao contrário, iniciar a warfarina alguns dias antes de suspender o dabigatrano, monitorizando o INR. A dupla anticoagulação pode ocorrer transitoriamente em transições mal geridas ou por erro de medicação — alertar o doente para sinais de hemorragia.',
  explanation_en = 'The combination of warfarin and dabigatran (two anticoagulants with different mechanisms — vitamin K antagonism and direct thrombin inhibition) has no therapeutic indication and multiplies the risk of major bleeding, including intracranial haemorrhage. Switching between the two drugs must follow a protocol: when changing from warfarin to dabigatran, stop warfarin and start dabigatran when the INR is below the threshold; conversely, start warfarin a few days before stopping dabigatran, monitoring the INR. Dual anticoagulation can occur transiently in poorly managed switches or by medication error — alert the patient to bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dabigatrano'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dabigatrano'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 4/18 — DEXAMETASONA + WARFARINA (indução enzimática)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Os corticosteroides podem alterar o efeito da warfarina (habitualmente redução do INR por indução, mas com variabilidade). Monitorizar o INR ao iniciar, ajustar e suspender a dexametasona.',
  summary_pro_en = 'Corticosteroids can alter the effect of warfarin (usually an INR decrease by induction, but variable). Monitor the INR when starting, adjusting and stopping dexamethasone.',
  explanation_pt = 'Os corticosteroides, incluindo a dexametasona, podem modificar a resposta à warfarina em ambos os sentidos: a maioria dos relatos mostra redução do INR (possivelmente por indução enzimática e retenção de fluidos), mas existem casos de aumento do efeito, e a resposta é imprevisível entre doentes. A interação é mais relevante em ciclos prolongados ou em doses altas. Recomenda-se monitorizar o INR com frequência ao iniciar, ajustar e suspender a dexametasona e ajustar a dose de warfarina conforme o resultado; o INR deve ser reavaliado após a suspensão do corticosteroide.',
  explanation_en = 'Corticosteroids, including dexamethasone, can modify the response to warfarin in both directions: most reports show an INR decrease (possibly through enzyme induction and fluid retention), but cases of increased effect exist, and the response is unpredictable between patients. The interaction is most relevant in prolonged courses or high doses. The INR should be monitored frequently when starting, adjusting and stopping dexamethasone and the warfarin dose adjusted accordingly; the INR must be re-evaluated after corticosteroid discontinuation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'dexametasona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 5/18 — DICLOFENAC + WARFARINA (risco hemorrágico aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE + warfarina: aumento do risco hemorrágico (GI e geral). Evitar AINEs em anticoagulados; se inevitável, usar a menor dose, gastroproteção e monitorizar o INR.',
  summary_pro_en = 'NSAID + warfarin: increased bleeding risk (GI and general). Avoid NSAIDs in anticoagulated patients; if unavoidable, use the lowest dose, gastroprotection and INR monitoring.',
  explanation_pt = 'O diclofenac, como os restantes AINEs, aumenta o risco hemorrágico em doentes com warfarina por três vias: inibição reversível da agregação plaquetária, lesão da mucosa gástrica (risco de úlcera e hemorragia digestiva) e possível interferência com a farmacocinética da warfarina. O risco de hemorragia gastrointestinal grave com a associação AINE + anticoagulante é substancial e bem documentado. Sempre que possível, usar analgésicos alternativos (paracetamol em dose controlada); se o diclofenac for inevitável, usar a menor dose eficaz pelo menor tempo, considerar gastroproteção (IBP) e monitorizar o INR e os sinais de hemorragia.',
  explanation_en = 'Diclofenac, like other NSAIDs, increases the bleeding risk in warfarin patients through three pathways: reversible platelet aggregation inhibition, gastric mucosal injury (ulcer and GI bleeding risk) and possible interference with warfarin pharmacokinetics. The risk of serious gastrointestinal bleeding with the NSAID + anticoagulant combination is substantial and well documented. Whenever possible, use alternative analgesics (paracetamol at controlled doses); if diclofenac is unavoidable, use the lowest effective dose for the shortest time, consider gastroprotection (PPI) and monitor the INR and bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 6/18 — EPOETINA ALFA + WARFARINA (aumento da viscosidade/hematócrito)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A epoetina pode reduzir o efeito anticoagulante da warfarina (possível aumento do hematócrito e consumo de vitamina K). Monitorizar o INR durante o tratamento com eritropoietina.',
  summary_pro_en = 'Epoetin can reduce the anticoagulant effect of warfarin (possible haematocrit rise and vitamin K consumption). Monitor the INR during erythropoietin treatment.',
  explanation_pt = 'A epoetina alfa estimula a eritropoiese e pode alterar a resposta à warfarina: a produção acelerada de eritrócitos aumenta o consumo de vitamina K (necessária à síntese dos fatores de coagulação) e pode reduzir o INR, exigindo por vezes aumento da dose de warfarina. Há também relatos de variação em ambos os sentidos. A interação é mais relevante em doentes com insuficiência renal crónica em tratamento prolongado com epoetina. Recomenda-se monitorizar o INR com frequência ao iniciar e ajustar a epoetina e durante o tratamento, ajustando a dose de warfarina conforme necessário.',
  explanation_en = 'Epoetin alfa stimulates erythropoiesis and can alter the response to warfarin: the accelerated production of red cells increases vitamin K consumption (needed for synthesis of coagulation factors) and can lower the INR, sometimes requiring a warfarin dose increase. Reports also exist of variation in both directions. The interaction is most relevant in chronic kidney disease patients on prolonged epoetin treatment. The INR should be monitored frequently when starting and adjusting epoetin and during treatment, adjusting the warfarin dose as needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'epoetina_alfa'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'epoetina_alfa'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 7/18 — FENITOÍNA + WARFARINA (interação bidirecional CYP2C9)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Interação complexa e bidirecional: a fenitoína induz e inibe o CYP2C9 e a warfarina aumenta os níveis de fenitoína. Monitorizar INR e níveis de fenitoína ao iniciar, ajustar e suspender.',
  summary_pro_en = 'Complex bidirectional interaction: phenytoin induces and inhibits CYP2C9, and warfarin raises phenytoin levels. Monitor INR and phenytoin levels when starting, adjusting and stopping.',
  explanation_pt = 'A interação fenitoína-warfarina é uma das mais complexas da farmacologia clínica: a fenitoína induz o CYP2C9 e o CYP2C19 (o que pode reduzir o efeito da warfarina) mas também compete com a warfarina pela ligação às proteínas plasmáticas, e a própria warfarina inibe o metabolismo da fenitoína, elevando os seus níveis e o risco de toxicidade neurológica (nistagmo, ataxia, sedação). O resultado líquido no INR é imprevisível e pode oscilar nas primeiras semanas. Recomenda-se monitorizar o INR e os níveis séricos de fenitoína no início e sempre que se ajuste qualquer dos fármacos, com ajustes graduais das doses.',
  explanation_en = 'The phenytoin-warfarin interaction is one of the most complex in clinical pharmacology: phenytoin induces CYP2C9 and CYP2C19 (which can reduce warfarin''s effect) but also competes with warfarin for plasma protein binding, and warfarin itself inhibits phenytoin metabolism, raising its levels and the risk of neurological toxicity (nystagmus, ataxia, sedation). The net effect on the INR is unpredictable and can oscillate in the first weeks. The INR and serum phenytoin levels should be monitored at initiation and whenever either drug is adjusted, with gradual dose changes.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fenitoina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fenitoina'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 8/18 — FENOBARBITAL + WARFARINA (indução potente do CYP)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O fenobarbital induz fortemente o CYP2C9/CYP3A4 e pode REDUZIR muito o efeito da warfarina. Pode ser necessário aumentar a dose de warfarina com monitorização apertada; reajustar após suspender.',
  summary_pro_en = 'Phenobarbital strongly induces CYP2C9/CYP3A4 and can markedly REDUCE the effect of warfarin. The warfarin dose may need to be increased with close monitoring; re-adjust after stopping.',
  explanation_pt = 'O fenobarbital é um indutor potente do CYP2C9, CYP2C19 e CYP3A4, as enzimas que metabolizam a warfarina, e acelera a sua eliminação — o efeito anticoagulante diminui e o INR desce, com risco de tromboembolismo se a dose não for ajustada. O efeito indutor demora 1–3 semanas a desenvolver-se plenamente e persiste várias semanas após a suspensão do fenobarbital, altura em que o INR pode subir acentuadamente. Recomenda-se monitorizar o INR com frequência ao iniciar, durante e após o fenobarbital, aumentando a dose de warfarina conforme necessário e reajustando-a na fase de suspensão.',
  explanation_en = 'Phenobarbital is a potent inducer of CYP2C9, CYP2C19 and CYP3A4, the enzymes that metabolise warfarin, and accelerates its elimination — the anticoagulant effect decreases and the INR falls, with thromboembolism risk if the dose is not adjusted. The inducing effect takes 1–3 weeks to fully develop and persists for several weeks after phenobarbital is stopped, when the INR can rise sharply. The INR should be monitored frequently when starting, during and after phenobarbital, increasing the warfarin dose as needed and re-adjusting it during the withdrawal phase.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fenobarbital'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fenobarbital'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 9/18 — FITOMENADIONA + WARFARINA (antagonismo direto — reversão)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A vitamina K (fitomenadiona) antagoniza diretamente a warfarina e reduz o INR — é o antídoto usado na reversão. Administrar apenas com indicação (INR supraterapêutico ou hemorragia) e monitorizar a re-anticoagulação.',
  summary_pro_en = 'Vitamin K (phytomenadione) directly antagonises warfarin and lowers the INR — it is the antidote used for reversal. Administer only with an indication (supratherapeutic INR or bleeding) and monitor re-anticoagulation.',
  explanation_pt = 'A fitomenadiona (vitamina K1) é o antídoto da warfarina: repõe o cofator necessário à carboxilação dos fatores II, VII, IX e X e reverte o efeito anticoagulante, reduzindo o INR em horas. Esta interação é intencional na reversão de INR supraterapêutico ou hemorragia, mas acidental (ex.: suplementos multivitamínicos, alimentação rica em vitamina K) causa instabilidade do INR e risco de trombose. Após a administração de vitamina K, a warfarina pode demorar dias a semanas a voltar ao efeito terapêutico, e a dose deve ser reajustada com monitorização do INR. Em doentes anticoagulados, aconselhar consistência na ingestão de vitamina K e rever suplementos.',
  explanation_en = 'Phytomenadione (vitamin K1) is the antidote to warfarin: it replenishes the cofactor needed to carboxylate factors II, VII, IX and X and reverses the anticoagulant effect, lowering the INR within hours. This interaction is intentional in the reversal of supratherapeutic INR or bleeding, but accidental (e.g. multivitamin supplements, vitamin-K-rich diet) causes INR instability and thrombosis risk. After vitamin K administration, warfarin may take days to weeks to return to therapeutic effect, and the dose must be re-adjusted with INR monitoring. In anticoagulated patients, advise consistency in vitamin K intake and review supplements.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fitomenadiona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fitomenadiona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 10/18 — LEFLUNOMIDA + WARFARINA (elevação do INR)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'A leflunomida pode aumentar o INR em doentes com warfarina. Monitorizar o INR ao iniciar e ajustar a dose; casos de hemorragia grave descritos.',
  summary_pro_en = 'Leflunomide can raise the INR in warfarin patients. Monitor the INR when starting and adjust the dose; cases of severe bleeding described.',
  explanation_pt = 'A leflunomida (e o seu metabolito ativo teriflunomida) tem sido associada ao aumento do INR em doentes anticoagulados com warfarina, com relatos de hemorragia grave. O mecanismo não está totalmente esclarecido, mas envolve provavelmente interferência com o metabolismo da warfarina. O efeito pode aparecer semanas após o início da leflunomida. Recomenda-se monitorizar o INR com frequência ao iniciar a leflunomida e após ajustes de dose, e vigiar sinais de hemorragia; em caso de necessidade de suspensão rápida, considerar o procedimento de washout com colestiramina previsto no rótulo.',
  explanation_en = 'Leflunomide (and its active metabolite teriflunomide) has been associated with INR elevation in warfarin-anticoagulated patients, with reports of severe bleeding. The mechanism is not fully established but probably involves interference with warfarin metabolism. The effect can appear weeks after starting leflunomide. The INR should be monitored frequently when starting leflunomide and after dose changes, and bleeding signs watched for; if rapid discontinuation is needed, consider the cholestyramine washout procedure described in the label.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'leflunomida'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'leflunomida'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 11/18 — METAMIZOL + WARFARINA (risco hemorrágico aditivo + interação farmacocinética)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O metamizol pode potenciar a warfarina (interação farmacocinética e efeito antiagregante). Monitorizar o INR e vigiar hemorragia; preferir paracetamol como analgésico de primeira linha.',
  summary_pro_en = 'Metamizole can potentiate warfarin (pharmacokinetic interaction and antiplatelet effect). Monitor the INR and watch for bleeding; prefer paracetamol as first-line analgesic.',
  explanation_pt = 'O metamizol (dipirona) pode aumentar o efeito da warfarina por interação farmacocinética (inibição do metabolismo, com elevação do INR) e por um efeito antiagregante plaquetário próprio; foram descritos casos de hemorragia grave, incluindo hemorragia gastrointestinal. A EMA, na revisão do metamizol, refere a necessidade de monitorização do INR em doentes anticoagulados. Recomenda-se, sempre que possível, usar analgésicos alternativos (paracetamol em dose controlada); se o metamizol for utilizado, monitorizar o INR com frequência e alertar para sinais de hemorragia.',
  explanation_en = 'Metamizole (dipyrone) can increase the effect of warfarin through a pharmacokinetic interaction (metabolism inhibition, with INR elevation) and its own antiplatelet effect; cases of severe bleeding, including gastrointestinal bleeding, have been described. The EMA, in its metamizole review, mentions the need for INR monitoring in anticoagulated patients. Whenever possible, use alternative analgesics (paracetamol at controlled doses); if metamizole is used, monitor the INR frequently and alert for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'metamizol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metamizol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 12/18 — NAPROXENO + WARFARINA (risco hemorrágico aditivo)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'AINE + warfarina: aumento do risco hemorrágico (GI e geral). Evitar AINEs em anticoagulados; se inevitável, menor dose, gastroproteção e monitorizar o INR.',
  summary_pro_en = 'NSAID + warfarin: increased bleeding risk (GI and general). Avoid NSAIDs in anticoagulated patients; if unavoidable, lowest dose, gastroprotection and INR monitoring.',
  explanation_pt = 'O naproxeno, como os restantes AINEs, aumenta o risco hemorrágico em doentes com warfarina: inibe a agregação plaquetária (de forma prolongada, dada a sua semivida longa), lesa a mucosa gástrica e pode interferir com a farmacocinética da warfarina. A associação AINE + anticoagulante está associada a um risco substancial de hemorragia gastrointestinal grave. Sempre que possível, usar analgésicos alternativos; se o naproxeno for inevitável, usar a menor dose eficaz pelo menor tempo, considerar gastroproteção e monitorizar o INR e os sinais de hemorragia.',
  explanation_en = 'Naproxen, like other NSAIDs, increases the bleeding risk in warfarin patients: it inhibits platelet aggregation (prolongedly, given its long half-life), injures the gastric mucosa and can interfere with warfarin pharmacokinetics. The NSAID + anticoagulant combination is associated with a substantial risk of serious gastrointestinal bleeding. Whenever possible, use alternative analgesics; if naproxen is unavoidable, use the lowest effective dose for the shortest time, consider gastroprotection and monitor the INR and bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'naproxeno'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'naproxeno'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 13/18 — OMEPRAZOL + WARFARINA (inibição do CYP2C19 — efeito modesto)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O omeprazol inibe o CYP2C19 e pode aumentar ligeiramente o INR (habitualmente modesto, mas relevante em doentes sensíveis). Monitorizar o INR ao iniciar o IBP.',
  summary_pro_en = 'Omeprazole inhibits CYP2C19 and can slightly raise the INR (usually modest, but relevant in sensitive patients). Monitor the INR when starting the PPI.',
  explanation_pt = 'O omeprazol é um inibidor do CYP2C19, enzima que participa no metabolismo do R-warfarin; a inibição pode reduzir a clearance da warfarina e elevar o INR, embora o efeito seja geralmente modesto e variável entre doentes. Outros inibidores da bomba de protões com menos afinidade pelo CYP2C19 (ex.: pantoprazol) são por vezes preferidos em doentes anticoagulados. Recomenda-se monitorizar o INR quando se inicia ou suspende o omeprazol, sobretudo em doentes com INR limítrofe ou polimorfismos genéticos relevantes, e ajustar a dose conforme necessário.',
  explanation_en = 'Omeprazole inhibits CYP2C19, an enzyme involved in R-warfarin metabolism; the inhibition can reduce warfarin clearance and raise the INR, although the effect is generally modest and variable between patients. Other proton pump inhibitors with less CYP2C19 affinity (e.g. pantoprazole) are sometimes preferred in anticoagulated patients. The INR should be monitored when omeprazole is started or stopped, especially in patients with a borderline INR or relevant genetic polymorphisms, and the dose adjusted as needed.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'omeprazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'omeprazol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 14/18 — ORLISTAT + WARFARINA (redução da absorção de vitamina K)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O orlistat reduz a absorção de gorduras e vitaminas lipossolúveis, incluindo a vitamina K, podendo aumentar o INR. Monitorizar o INR ao iniciar e durante o tratamento.',
  summary_pro_en = 'Orlistat reduces absorption of fats and fat-soluble vitamins, including vitamin K, potentially raising the INR. Monitor the INR when starting and during treatment.',
  explanation_pt = 'O orlistat inibe as lipases gastrointestinais e reduz a absorção das gorduras da dieta e das vitaminas lipossolúveis, incluindo a vitamina K. Como a warfarina é um antagonista da vitamina K, a menor disponibilidade do cofator pode aumentar o efeito anticoagulante e o INR; casos de INR elevado e hemorragia foram descritos, sobretudo nas primeiras semanas de tratamento. Recomenda-se monitorizar o INR no início e durante o tratamento com orlistat e ajustar a dose de warfarina; manter ingestão consistente de vitamina K e vigiar sinais de hemorragia.',
  explanation_en = 'Orlistat inhibits gastrointestinal lipases and reduces absorption of dietary fats and fat-soluble vitamins, including vitamin K. Since warfarin is a vitamin K antagonist, the lower availability of the cofactor can increase the anticoagulant effect and the INR; cases of elevated INR and bleeding have been described, especially in the first weeks of treatment. The INR should be monitored at initiation and during orlistat treatment and the warfarin dose adjusted; maintain consistent vitamin K intake and watch for bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'orlistat'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'orlistat'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 15/18 — PARACETAMOL + WARFARINA (elevação do INR em doses altas/prolongadas)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O paracetamol em doses elevadas ou uso prolongado (>2 g/dia durante dias) pode aumentar o INR. Usar a menor dose eficaz e monitorizar o INR; o paracetamol é o analgésico preferido face aos AINEs.',
  summary_pro_en = 'Paracetamol at high doses or with prolonged use (>2 g/day for days) can raise the INR. Use the lowest effective dose and monitor the INR; paracetamol is preferred over NSAIDs.',
  explanation_pt = 'O paracetamol é o analgésico preferido em doentes anticoagulados por não ter o risco hemorrágico gastrointestinal dos AINEs, mas em doses elevadas ou uso prolongado pode aumentar o INR: o mecanismo envolve a depleção de glutatião e a interferência com a síntese dos fatores de coagulação dependentes de vitamina K (o metabolito NAPQI inibe a carboxilação dependente de vitamina K). Estudos mostram elevações do INR com doses ≥ 2 g/dia mantidas por vários dias. Recomenda-se usar a menor dose eficaz, não exceder 2–3 g/dia de forma continuada e monitorizar o INR em doentes que usam paracetamol cronicamente.',
  explanation_en = 'Paracetamol is the preferred analgesic in anticoagulated patients because it lacks the gastrointestinal bleeding risk of NSAIDs, but at high doses or with prolonged use it can raise the INR: the mechanism involves glutathione depletion and interference with the synthesis of vitamin K-dependent coagulation factors (the NAPQI metabolite inhibits vitamin K-dependent carboxylation). Studies show INR elevations with doses ≥ 2 g/day maintained for several days. Use the lowest effective dose, do not exceed 2–3 g/day continuously and monitor the INR in patients using paracetamol chronically.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 16/18 — PREDNISOLONA + WARFARINA (alteração variável do INR)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Os corticosteroides podem alterar o efeito da warfarina (habitualmente redução do INR, mas variável). Monitorizar o INR ao iniciar, ajustar e suspender a prednisolona.',
  summary_pro_en = 'Corticosteroids can alter the effect of warfarin (usually an INR decrease, but variable). Monitor the INR when starting, adjusting and stopping prednisolone.',
  explanation_pt = 'A prednisolona, como os restantes corticosteroides, pode modificar a resposta à warfarina: a maioria dos relatos mostra redução do INR (por indução enzimática e retenção de fluidos com hemodiluição), mas existem casos de aumento do efeito, e a resposta é imprevisível. A interação é mais relevante em ciclos prolongados ou doses altas (ex.: doenças inflamatórias crónicas, transplante). Recomenda-se monitorizar o INR com frequência ao iniciar, ajustar e suspender a prednisolona e ajustar a dose de warfarina conforme o resultado, reavaliando o INR após a suspensão do corticosteroide.',
  explanation_en = 'Prednisolone, like other corticosteroids, can modify the response to warfarin: most reports show an INR decrease (through enzyme induction and fluid retention with haemodilution), but cases of increased effect exist, and the response is unpredictable. The interaction is most relevant in prolonged courses or high doses (e.g. chronic inflammatory diseases, transplantation). The INR should be monitored frequently when starting, adjusting and stopping prednisolone and the warfarin dose adjusted accordingly, with INR re-evaluation after corticosteroid discontinuation.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'prednisolona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'prednisolona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 17/18 — RIVAROXABANO + WARFARINA (dupla anticoagulação)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Dois anticoagulantes em simultâneo: risco hemorrágico aditivo. Não associar; a transição entre warfarina e rivaroxabano exige protocolo com INR controlado.',
  summary_pro_en = 'Two anticoagulants at the same time: additive bleeding risk. Do not combine; switching between warfarin and rivaroxaban requires a protocol with controlled INR.',
  explanation_pt = 'A associação de warfarina e rivaroxabano (antagonista da vitamina K + inibidor direto do fator Xa) não tem indicação terapêutica e aumenta substancialmente o risco de hemorragia major, incluindo hemorragia intracraniana. A transição entre os dois fármacos deve seguir protocolo: ao mudar de warfarina para rivaroxabano, suspender a warfarina e iniciar o rivaroxabano quando o INR estiver abaixo do limiar (geralmente < 3,0); ao contrário, iniciar a warfarina em sobreposição com o rivaroxabano até o INR estar no intervalo terapêutico, suspendendo depois o rivaroxabano. A dupla anticoagulação prolongada é um erro de medicação — alertar o doente para sinais de hemorragia.',
  explanation_en = 'The combination of warfarin and rivaroxaban (vitamin K antagonist + direct factor Xa inhibitor) has no therapeutic indication and substantially increases the risk of major bleeding, including intracranial haemorrhage. Switching between the two drugs must follow a protocol: when changing from warfarin to rivaroxaban, stop warfarin and start rivaroxaban when the INR is below the threshold (usually < 3.0); conversely, start warfarin overlapping with rivaroxaban until the INR is in the therapeutic range, then stop rivaroxaban. Prolonged dual anticoagulation is a medication error — alert the patient to bleeding signs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'rivaroxabano'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- 18/18 — VALPROATO + WARFARINA (deslocação proteica e inibição enzimática)
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'O valproato liga-se às proteínas plasmáticas e pode deslocar a warfarina, aumentando o INR. Monitorizar o INR ao iniciar e ajustar a dose.',
  summary_pro_en = 'Valproate is protein-bound and can displace warfarin, raising the INR. Monitor the INR when starting and adjust the dose.',
  explanation_pt = 'O valproato liga-se extensamente às proteínas plasmáticas (90% ou mais) e pode deslocar a warfarina dos seus locais de ligação, aumentando a fração livre ativa e o efeito anticoagulante; pode também interferir com o metabolismo da warfarina. Existem relatos de elevação do INR e hemorragia quando o valproato é adicionado à warfarina. Recomenda-se monitorizar o INR no início e durante o tratamento e ajustar a dose de warfarina; o efeito é mais relevante em doentes com hipoalbuminemia (idosos, doença hepática), nos quais a fração livre de ambos os fármacos é maior.',
  explanation_en = 'Valproate is extensively protein-bound (90% or more) and can displace warfarin from its binding sites, increasing the active free fraction and the anticoagulant effect; it can also interfere with warfarin metabolism. Reports exist of INR elevation and bleeding when valproate is added to warfarin. The INR should be monitored at initiation and during treatment and the warfarin dose adjusted; the effect is more relevant in patients with hypoalbuminaemia (elderly, liver disease), in whom the free fraction of both drugs is higher.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'valproato'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'valproato'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

-- =====================================================================
-- FIM — 098: 18 explicações de pares moderados da warfarina (2/2)
-- =====================================================================
