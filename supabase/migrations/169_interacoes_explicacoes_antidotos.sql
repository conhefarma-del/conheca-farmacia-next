-- =====================================================================
-- 169: Fluxo 4 — Explicações longas dos pares do grupo 17 (Antídotos)
-- Preenche a camada editorial de profundidade (summary_pro_pt/en +
-- explanation_pt/en) dos 5 pares criados na migração 168.
--
-- Método (Fluxo 4, secção 15 do docs/INTERACOES_FLUXO_PESQUISA.md):
--   * summary_pro_*: 1–2 frases, tom profissional, com a ação prática;
--   * explanation_*: 3–5 frases — mecanismo, consequência clínica, grupos
--     de risco e orientação prática; texto corrido, sem \n;
--   * conteúdo autorado e ancorado nos rótulos citados na migração 168
--     (setIDs validados na API DailyMed) e no Prontuário Terapêutico.
--
-- Fontes (DailyMed/FDA — NIH/NLM), setIDs validados a 2026-08-17:
--   Folinato de cálcio (Leading Pharma)  c8102043-79f2-421a-b849-94bac19007a6
--   Penicilamina (CUPRIMINE, Bausch)     80e736d3-2017-4d68-94b4-38255c3c59c6
--   (parceiros: setIDs reutilizados da BD — regra 15.2)
--
-- Âncoras confirmadas no texto dos rótulos:
--   * Folinato de cálcio: "Certain Antiepileptic Drugs: Increase monitoring
--     for seizure activity in leucovorin-treated patients... Certain
--     antiepileptic drugs may reduce the effectiveness of leucovorin";
--     prontuário: "Pode reduzir a actividade terapêutica da fenitoína e do
--     fenobarbital".
--   * Penicilamina: "Food, antacids, and iron reduce absorption of the drug";
--     prontuário: "Antiácidos (reduzem a absorção)"; "Sulfato ferroso
--     (reduz as suas concentrações séricas)"; o rótulo confirma o zinco na
--     formulação "antacid, zinc, or iron-containing preparation".
-- Idempotente: WHERE canónico LEAST/GREATEST sobre ids por slug — reaplicar é
-- seguro. Aplicar na ordem 168 → 169.
-- =====================================================================

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Folinato de cálcio + fenitoína: vigiar a atividade convulsiva — os antiepiléticos podem reduzir a eficácia do folinato (e o folinato pode reduzir a atividade da fenitoína).',
  summary_pro_en = 'Calcium folinate + phenytoin: monitor seizure activity — antiepileptics may reduce folinate effectiveness (and folinate may reduce phenytoin activity).',
  explanation_pt = 'O rótulo FDA do leucovorina documenta na secção de interações que certos antiepiléticos podem reduzir a eficácia do folinato ("Certain Antiepileptic Drugs: Increase monitoring for seizure activity in leucovorin-treated patients... Certain antiepileptic drugs may reduce the effectiveness of leucovorin"), e o Prontuário Terapêutico regista a interação no sentido inverso — o folinato "pode reduzir a actividade terapêutica da fenitoína e do fenobarbital". A interação é, portanto, bidirecional e clinicamente relevante no doente epilético que recebe folinato como resgate do metotrexato ou no tratamento da toxicidade por antagonistas do ácido fólico: a fenitoína pode comprometer a recuperação hematológica esperada, e o folinato pode desestabilizar o controlo convulsivo. A vigilância clínica de crises e, quando aplicável, a monitorização dos níveis séricos de fenitoína são a orientação prática. Não é uma interação que exija suspensão, mas sim monitorização ativa durante a associação.',
  explanation_en = 'The FDA leucovorin label documents in the interactions section that certain antiepileptics may reduce folinate effectiveness ("Certain Antiepileptic Drugs: Increase monitoring for seizure activity in leucovorin-treated patients... Certain antiepileptic drugs may reduce the effectiveness of leucovorin"), and the Prontuário Terapêutico records the interaction in the opposite direction — folinate "may reduce the therapeutic activity of phenytoin and phenobarbital". The interaction is therefore bidirectional and clinically relevant in the epileptic patient receiving folinate as methotrexate rescue or for the treatment of folic acid antagonist toxicity: phenytoin may compromise the expected haematological recovery, and folinate may destabilise seizure control. Clinical monitoring for seizures and, when applicable, serum phenytoin level monitoring are the practical guidance. This is not an interaction requiring discontinuation, but active monitoring during the combination.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; rótulo aprovado Fenitoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cbd9005-7df2-47ee-adb3-7244c1c69bc3 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Folinato de cálcio, 17',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; approved Phenytoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cbd9005-7df2-47ee-adb3-7244c1c69bc3 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Calcium folinate, 17'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenitoina'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenitoina'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Folinato de cálcio + fenobarbital: vigiar a atividade convulsiva — os antiepiléticos podem reduzir a eficácia do folinato (e o folinato pode reduzir a atividade do fenobarbital).',
  summary_pro_en = 'Calcium folinate + phenobarbital: monitor seizure activity — antiepileptics may reduce folinate effectiveness (and folinate may reduce phenobarbital activity).',
  explanation_pt = 'O mesmo fundamento da interação com a fenitoína aplica-se ao fenobarbital: o rótulo FDA do leucovorina cobre os antiepiléticos em geral ("Certain Antiepileptic Drugs... may reduce the effectiveness of leucovorin") e o Prontuário Terapêutico nomeia explicitamente a fenitoína e o fenobarbital — o folinato "pode reduzir a actividade terapêutica" de ambos. No doente epilético em resgate do metotrexato ou com toxicidade por antagonistas do ácido fólico, o fenobarbital pode atenuar a resposta ao folinato, e o folinato pode interferir com o controlo convulsivo. A vigilância clínica de crises durante a associação é a orientação prática; não há contraindicação de uso simultâneo, apenas monitorização ativa.',
  explanation_en = 'The same rationale as the phenytoin interaction applies to phenobarbital: the FDA leucovorin label covers antiepileptics in general ("Certain Antiepileptic Drugs... may reduce the effectiveness of leucovorin") and the Prontuário Terapêutico explicitly names phenytoin and phenobarbital — folinate "may reduce the therapeutic activity" of both. In the epileptic patient undergoing methotrexate rescue or with folic acid antagonist toxicity, phenobarbital may attenuate the response to folinate, and folinate may interfere with seizure control. Clinical monitoring for seizures during the combination is the practical guidance; there is no contraindication to concomitant use, only active monitoring.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; rótulo aprovado Fenobarbital: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Folinato de cálcio, 17',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; approved Phenobarbital label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Calcium folinate, 17'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
                        (SELECT id FROM public.drugs WHERE slug = 'fenobarbital'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
                           (SELECT id FROM public.drugs WHERE slug = 'fenobarbital'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Penicilamina + antiácidos: os catiões dos antiácidos quelam a penicilamina e reduzem a sua absorção — separar a toma por pelo menos 2 horas.',
  summary_pro_en = 'Penicillamine + antacids: antacid cations chelate penicillamine and reduce its absorption — separate administration by at least 2 hours.',
  explanation_pt = 'O rótulo FDA da penicilamina é explícito: "Food, antacids, and iron reduce absorption of the drug", e o Prontuário Terapêutico regista "Antiácidos (reduzem a absorção)". Os catiões divalentes e trivalentes dos antiácidos (alumínio, magnésio) formam quelatos com a penicilamina no trato gastrointestinal, reduzindo a biodisponibilidade oral do quelante — um efeito com consequências diretas na eficácia do tratamento da intoxicação por metais pesados, da doença de Wilson e da artrite reumatóide. A orientação prática é separar a toma: administrar a penicilamina em jejum (1 hora antes ou 2 horas depois das refeições) e afastar os antiácidos por pelo menos 2 horas. Nos doentes com doença de Wilson em que o controlo da cuprúria é o marcador de eficácia, a toma simultânea pode levar a falsa falta de resposta.',
  explanation_en = 'The FDA penicillamine label is explicit: "Food, antacids, and iron reduce absorption of the drug", and the Prontuário Terapêutico records "Antacids (reduce absorption)". The divalent and trivalent cations of antacids (aluminium, magnesium) form chelates with penicillamine in the GI tract, reducing the oral bioavailability of the chelator — an effect with direct consequences for the efficacy of treatment of heavy metal poisoning, Wilson disease and rheumatoid arthritis. The practical guidance is to separate administration: give penicillamine on an empty stomach (1 hour before or 2 hours after meals) and keep antacids at least 2 hours apart. In Wilson disease patients where cupruria control is the efficacy marker, simultaneous intake may lead to false lack of response.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; rótulo aprovado Antiácidos: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a13ac81-0c63-48c1-bbb0-f6e67f97b896 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Penicilamina, 17',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; approved Antacids label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a13ac81-0c63-48c1-bbb0-f6e67f97b896 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Penicillamine, 17'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
                        (SELECT id FROM public.drugs WHERE slug = 'antiacidos'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
                           (SELECT id FROM public.drugs WHERE slug = 'antiacidos'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Penicilamina + ferro: o ferro quelata a penicilamina e reduz a sua absorção — separar a toma por pelo menos 2 horas.',
  summary_pro_en = 'Penicillamine + iron: iron chelates penicillamine and reduces its absorption — separate administration by at least 2 hours.',
  explanation_pt = 'O rótulo FDA documenta que o ferro reduz a absorção da penicilamina ("Food, antacids, and iron reduce absorption of the drug") e o Prontuário Terapêutico regista "Sulfato ferroso (reduz as suas concentrações séricas)". O ferro forma quelatos com a penicilamina no trato gastrointestinal, reduzindo a biodisponibilidade do quelante e, em sentido inverso, o tratamento prolongado com penicilamina pode agravar défices de ferro (perdas urinárias do metal e interferência na absorção). A interação é relevante nos doentes em tratamento quelante que também necessitam de suplementação de ferro — comum na doença de Wilson com anemia associada e em intoxicações crónicas. A orientação prática é separar a toma por pelo menos 2 horas e administrar a penicilamina em jejum, vigiando a resposta clínica ao tratamento.',
  explanation_en = 'The FDA label documents that iron reduces penicillamine absorption ("Food, antacids, and iron reduce absorption of the drug") and the Prontuário Terapêutico records "Ferrous sulphate (reduces its serum concentrations)". Iron forms chelates with penicillamine in the GI tract, reducing the chelator bioavailability and, conversely, prolonged penicillamine treatment may worsen iron deficiency (urinary metal losses and absorption interference). The interaction is relevant in chelation patients who also need iron supplementation — common in Wilson disease with associated anaemia and in chronic poisonings. The practical guidance is to separate administration by at least 2 hours and give penicillamine on an empty stomach, monitoring clinical response to treatment.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; rótulo aprovado Ferro: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73d1f079-d8eb-44f4-b33d-05fb25b80c8f ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Penicilamina, 17',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; approved Iron label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73d1f079-d8eb-44f4-b33d-05fb25b80c8f ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Penicillamine, 17'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
                        (SELECT id FROM public.drugs WHERE slug = 'ferro'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
                           (SELECT id FROM public.drugs WHERE slug = 'ferro'));

UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Penicilamina + zinco: o zinco quelata a penicilamina e reduz a sua absorção — separar a toma por pelo menos 2 horas.',
  summary_pro_en = 'Penicillamine + zinc: zinc chelates penicillamine and reduces its absorption — separate administration by at least 2 hours.',
  explanation_pt = 'O rótulo FDA da penicilamina inclui o zinco entre os agentes que reduzem a absorção do fármaco (a formulação "antacid, zinc, or iron-containing preparation" confirma o zinco explicitamente). O zinco quelata a penicilamina no trato gastrointestinal, reduzindo a biodisponibilidade oral — um efeito com significado clínico particular na doença de Wilson, onde o zinco é ele próprio usado como terapêutica de manutenção (induz metalotioneína e bloqueia a absorção intestinal do cobre) e a penicilamina como quelante de primeira linha: a toma simultânea compromete ambos os mecanismos. A orientação prática é separar as tomas por pelo menos 2 horas e vigiar a resposta ao tratamento quelante (cuprúria, sintomas neurológicos).',
  explanation_en = 'The FDA penicillamine label includes zinc among the agents that reduce drug absorption (the wording "antacid, zinc, or iron-containing preparation" explicitly confirms zinc). Zinc chelates penicillamine in the GI tract, reducing oral bioavailability — an effect of particular clinical significance in Wilson disease, where zinc is itself used as maintenance therapy (induces metallothionein and blocks intestinal copper absorption) and penicillamine as first-line chelator: simultaneous intake compromises both mechanisms. The practical guidance is to separate doses by at least 2 hours and monitor response to chelating treatment (cupruria, neurological symptoms).',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; rótulo aprovado Zinco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c527d138-e32c-418f-9573-a3d8a796279f',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; approved Zinc label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c527d138-e32c-418f-9573-a3d8a796279f'
WHERE drug_a_id = LEAST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
                        (SELECT id FROM public.drugs WHERE slug = 'zinco'))
  AND drug_b_id = GREATEST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
                           (SELECT id FROM public.drugs WHERE slug = 'zinco'));
