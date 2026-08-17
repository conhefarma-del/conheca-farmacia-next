-- =====================================================================
-- 168: Grupo 17 do Prontuário Terapêutico — Medicamentos usados no
--      tratamento de intoxicações (antídotos)
-- Adiciona 2 fármacos novos (folinato de cálcio, penicilamina) e 5 pares
-- de interação, todos ancorados em rótulos FDA/DailyMed validados
-- (a 2026-08-17) e/ou no Prontuário Terapêutico (INFARMED, 11.ª ed.).
--
-- Fármacos novos:
--   folinato de cálcio (leucovorina) — antídoto/prevenção da toxicidade
--     dos antagonistas do ácido fólico (metotrexato, trimetoprim) e
--     "resgate" após quimioterapia com metotrexato em doses altas;
--   penicilamina — antídoto quelante na intoxicação por metais pesados,
--     doença de Wilson, cistinúria e artrite reumatóide.
--
-- Pares (documentados nos rótulos/prontuário):
--   Folinato de cálcio × Fenitoína    (moderate) — rótulo FDA: "Certain
--     Antiepileptic Drugs: Increase monitoring for seizure activity...
--     Certain antiepileptic drugs may reduce the effectiveness of
--     leucovorin"; prontuário: "Pode reduzir a actividade terapêutica da
--     fenitoína e do fenobarbital".
--   Folinato de cálcio × Fenobarbital (moderate) — mesmo fundamento.
--   Penicilamina × Antiácidos         (moderate) — "Food, antacids, and
--     iron reduce absorption of the drug" (rótulo); prontuário: "Antiácidos
--     (reduzem a absorção)".
--   Penicilamina × Ferro              (moderate) — "iron reduce absorption
--     of the drug" (rótulo); prontuário: "Sulfato ferroso (reduz as suas
--     concentrações séricas)".
--   Penicilamina × Zinco              (moderate) — "zinc... reduce
--     absorption of the drug" (rótulo) — mesmo mecanismo de quelação.
--
-- Nota de omissão — Grupo 18 (Vacinas e imunoglobulinas): as vacinas não
-- têm interações fármaco-fármaco clássicas (são imunizantes, não fármacos
-- no modelo de interações); a única interação documentada no prontuário é
-- entre imunoglobulinas e vacinas de vírus vivos atenuados ("O tratamento
-- com imunoglobulinas pode diminuir a eficácia de vacinas de vírus vivos
-- atenuados tais como antiparotidite, febre amarela, rubéola e sarampo"),
-- que é uma precaução de calendário vacinal entre biológicos — não é um
-- par fármaco-fármaco do modelo drug_interactions. Sem pares artificiais.
-- Também sem pares: acetilcisteína (já existe na BD — incompatibilidade
-- química com antibióticos é de administração, não interação farmacológica),
-- desferroxamina (interação com procloroperazina — não existe na BD),
-- flumazenilo/naloxona (antagonistas — interação terapêutica intencional),
-- mesna (interações desconhecidas) e sevelâmero (interações desconhecidas).
--
-- Fontes: rótulos aprovados FDA/DailyMed (NIH/NLM) — setIDs obtidos na
-- API pública v2 (spls.json?drug_name=...) e revalidados pelo endpoint
-- XML (spls/{setid}.xml) com confirmação do fabricante a 2026-08-17:
--   folinato de cálcio (Leading Pharma)  c8102043-79f2-421a-b849-94bac19007a6
--   penicilamina (Bausch/CUPRIMINE)      80e736d3-2017-4d68-94b4-38255c3c59c6
-- Parceiros: setIDs reutilizados das citações já existentes na BD
-- (regra da secção 15.2 — não revalidar do zero).
--
-- Metodologia (ver docs/INTERACOES_FLUXO_PESQUISA.md):
--   * pares canónicos (drug_a_id < drug_b_id) via LEAST/GREATEST sobre ids por slug;
--   * sem pares artificiais: só pares documentados nos rótulos aprovados/prontuário;
--   * idempotente (UNIQUE (drug_a_id, drug_b_id), ON CONFLICT DO NOTHING).
-- =====================================================================

INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
VALUES
  ('folinato_calcio', 'Folinato de cálcio', 'Calcium folinate', 'Antídoto (resgate do metotrexato / antagonista do ácido fólico)', 'Antidote (methotrexate rescue / folic acid antagonist)', ARRAY['Folinato de cálcio', 'Leucovorina', 'Leucovorin'], 'published', 200),
  ('penicilamina', 'Penicilamina', 'Penicillamine', 'Antídoto quelante (metais pesados) / agente antirreumático', 'Chelating antidote (heavy metals) / antirheumatic agent', ARRAY['Penicilamina', 'Cuprimine'], 'published', 201);

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status, updated_at)
VALUES
  (LEAST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
        (SELECT id FROM public.drugs WHERE slug = 'fenitoina')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
            (SELECT id FROM public.drugs WHERE slug = 'fenitoina')),
   'moderate',
   'Folinato de cálcio + fenitoína: os antiepiléticos podem reduzir a eficácia do folinato — vigiar a atividade convulsiva.',
   'Calcium folinate + phenytoin: antiepileptics may reduce folinate effectiveness — monitor seizure activity.',
   'O rótulo FDA do leucovorina documenta: "Certain Antiepileptic Drugs: Increase monitoring for seizure activity in leucovorin-treated patients... Certain antiepileptic drugs may reduce the effectiveness of leucovorin". O prontuário regista o mesmo em sentido inverso: "Pode reduzir a actividade terapêutica da fenitoína e do fenobarbital". A interação é bidirecional e relevante quando o folinato é usado como resgate do metotrexato em doentes epiléticos.',
   'The FDA leucovorin label documents: "Certain Antiepileptic Drugs: Increase monitoring for seizure activity in leucovorin-treated patients... Certain antiepileptic drugs may reduce the effectiveness of leucovorin". The Prontuário records the same in the opposite direction: "May reduce the therapeutic activity of phenytoin and phenobarbital". The interaction is bidirectional and relevant when folinate is used as methotrexate rescue in epileptic patients.',
   'Vigiar a atividade convulsiva em doentes a tomar folinato com antiepiléticos; monitorizar a resposta ao folinato (ex.: recuperação hematológica após metotrexato).',
   'Monitor seizure activity in patients taking folinate with antiepileptics; monitor response to folinate (e.g., haematological recovery after methotrexate).',
   'Vigilância clínica de convulsões e, quando aplicável, dos níveis de fenitoína.',
   'Clinical monitoring for seizures and, when applicable, phenytoin levels.',
   'Crise convulsiva de novo, níveis sub-terapêuticos de fenitoína ou ausência de recuperação hematológica esperada.',
   'New-onset seizure, subtherapeutic phenytoin levels or absence of expected haematological recovery.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; rótulo aprovado Fenitoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cbd9005-7df2-47ee-adb3-7244c1c69bc3 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Folinato de cálcio, 17',
   'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; approved Phenytoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cbd9005-7df2-47ee-adb3-7244c1c69bc3 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Calcium folinate, 17', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
        (SELECT id FROM public.drugs WHERE slug = 'fenobarbital')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'folinato_calcio'),
            (SELECT id FROM public.drugs WHERE slug = 'fenobarbital')),
   'moderate',
   'Folinato de cálcio + fenobarbital: os antiepiléticos podem reduzir a eficácia do folinato — vigiar a atividade convulsiva.',
   'Calcium folinate + phenobarbital: antiepileptics may reduce folinate effectiveness — monitor seizure activity.',
   'O rótulo FDA do leucovorina inclui os antiepiléticos em geral ("Certain Antiepileptic Drugs... may reduce the effectiveness of leucovorin") e o prontuário regista explicitamente a fenitoína e o fenobarbital: "Pode reduzir a actividade terapêutica da fenitoína e do fenobarbital". A relevância clínica é a mesma da fenitoína — vigilância da atividade convulsiva.',
   'The FDA leucovorin label includes antiepileptics in general ("Certain Antiepileptic Drugs... may reduce the effectiveness of leucovorin") and the Prontuário explicitly records phenytoin and phenobarbital: "May reduce the therapeutic activity of phenytoin and phenobarbital". The clinical relevance is the same as phenytoin — monitoring of seizure activity.',
   'Vigiar a atividade convulsiva e a resposta ao folinato em doentes com barbitúricos.',
   'Monitor seizure activity and response to folinate in patients on barbiturates.',
   'Vigilância clínica de convulsões durante a associação.',
   'Clinical monitoring for seizures during the combination.',
   'Crise convulsiva de novo ou ausência da resposta esperada ao folinato.',
   'New-onset seizure or absence of expected response to folinate.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Leucovorina cálcica (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; rótulo aprovado Fenobarbital: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Folinato de cálcio, 17',
   'DailyMed/FDA (NIH/NLM) — approved Calcium Leucovorin label (Leading Pharma): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c8102043-79f2-421a-b849-94bac19007a6 ; approved Phenobarbital label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ef4e97a7-cd18-47a9-a016-2eca5481a87e ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Calcium folinate, 17', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
        (SELECT id FROM public.drugs WHERE slug = 'antiacidos')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
            (SELECT id FROM public.drugs WHERE slug = 'antiacidos')),
   'moderate',
   'Penicilamina + antiácidos: os antiácidos reduzem a absorção da penicilamina — separar a toma.',
   'Penicillamine + antacids: antacids reduce penicillamine absorption — separate administration.',
   'O rótulo FDA da penicilamina documenta: "Food, antacids, and iron reduce absorption of the drug", e o prontuário regista "Antiácidos (reduzem a absorção)". Os catiões (alumínio, magnésio) dos antiácidos quelam a penicilamina no trato gastrointestinal, reduzindo a sua biodisponibilidade e a eficácia do tratamento (intoxicação por metais, doença de Wilson, artrite reumatóide).',
   'The FDA penicillamine label documents: "Food, antacids, and iron reduce absorption of the drug", and the Prontuário records "Antacids (reduce absorption)". The cations (aluminium, magnesium) of antacids chelate penicillamine in the GI tract, reducing its bioavailability and the efficacy of treatment (heavy metal poisoning, Wilson disease, rheumatoid arthritis).',
   'Administrar a penicilamina em jejum, 1 hora antes ou 2 horas depois das refeições, e separar dos antiácidos por pelo menos 2 horas.',
   'Give penicillamine on an empty stomach, 1 hour before or 2 hours after meals, and separate from antacids by at least 2 hours.',
   'Avaliação da resposta clínica ao tratamento (ex.: cuprúria na doença de Wilson) durante a associação.',
   'Assessment of clinical response to treatment (e.g., cupruria in Wilson disease) during the combination.',
   'Falta de resposta terapêutica ou reaparecimento de sintomas na toma conjunta com antiácidos.',
   'Lack of therapeutic response or recurrence of symptoms when taking antacids together.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; rótulo aprovado Antiácidos: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a13ac81-0c63-48c1-bbb0-f6e67f97b896 ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Penicilamina, 17',
   'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; approved Antacids label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0a13ac81-0c63-48c1-bbb0-f6e67f97b896 ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Penicillamine, 17', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
        (SELECT id FROM public.drugs WHERE slug = 'ferro')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
            (SELECT id FROM public.drugs WHERE slug = 'ferro')),
   'moderate',
   'Penicilamina + ferro: o ferro reduz a absorção da penicilamina — separar a toma.',
   'Penicillamine + iron: iron reduces penicillamine absorption — separate administration.',
   'O rótulo FDA documenta que o ferro reduz a absorção da penicilamina ("Food, antacids, and iron reduce absorption of the drug") e o prontuário regista "Sulfato ferroso (reduz as suas concentrações séricas)". O ferro quelata a penicilamina no trato gastrointestinal; a associação pode reduzir a eficácia do quelante e, em sentido inverso, a penicilamina pode agravar défices de ferro.',
   'The FDA label documents that iron reduces penicillamine absorption ("Food, antacids, and iron reduce absorption of the drug") and the Prontuário records "Ferrous sulphate (reduces its serum concentrations)". Iron chelates penicillamine in the GI tract; the combination may reduce the chelator efficacy and, conversely, penicillamine may worsen iron deficiency.',
   'Separar a toma de penicilamina e ferro por pelo menos 2 horas; administrar a penicilamina em jejum.',
   'Separate penicillamine and iron by at least 2 hours; give penicillamine on an empty stomach.',
   'Vigiar a resposta clínica e o hemograma (ferro) durante a associação.',
   'Monitor clinical response and blood count (iron) during the combination.',
   'Falta de resposta ao tratamento quelante ou agravamento de anemia ferropriva.',
   'Lack of response to chelating treatment or worsening of iron-deficiency anaemia.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; rótulo aprovado Ferro: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73d1f079-d8eb-44f4-b33d-05fb25b80c8f ; Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Penicilamina, 17',
   'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; approved Iron label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73d1f079-d8eb-44f4-b33d-05fb25b80c8f ; Prontuário Terapêutico do INFARMED (11th ed., 2012) — Penicillamine, 17', 'published', now()),

  (LEAST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
        (SELECT id FROM public.drugs WHERE slug = 'zinco')),
   GREATEST((SELECT id FROM public.drugs WHERE slug = 'penicilamina'),
            (SELECT id FROM public.drugs WHERE slug = 'zinco')),
   'moderate',
   'Penicilamina + zinco: o zinco reduz a absorção da penicilamina — separar a toma.',
   'Penicillamine + zinc: zinc reduces penicillamine absorption — separate administration.',
   'O rótulo FDA documenta o zinco entre os agentes que reduzem a absorção da penicilamina ("Food, antacids, and iron reduce absorption of the drug" — a formulação "antacid, zinc, or iron-containing preparation" confirma o zinco). O zinco quelata a penicilamina no trato gastrointestinal, reduzindo a biodisponibilidade; relevante na doença de Wilson (onde o zinco também é usado como terapêutica) e em suplementação.',
   'The FDA label documents zinc among the agents that reduce penicillamine absorption (the formulation "antacid, zinc, or iron-containing preparation" confirms zinc). Zinc chelates penicillamine in the GI tract, reducing bioavailability; relevant in Wilson disease (where zinc is also used as therapy) and in supplementation.',
   'Separar a toma de penicilamina e de preparações com zinco por pelo menos 2 horas.',
   'Separate penicillamine and zinc-containing preparations by at least 2 hours.',
   'Vigiar a resposta clínica ao tratamento quelante durante a associação.',
   'Monitor clinical response to chelating treatment during the combination.',
   'Falta de resposta ao tratamento ou interferência na terapêutica da doença de Wilson.',
   'Lack of response to treatment or interference with Wilson disease therapy.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Penicilamina (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; rótulo aprovado Zinco: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c527d138-e32c-418f-9573-a3d8a796279f',
   'DailyMed/FDA (NIH/NLM) — approved Penicillamine label (CUPRIMINE): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=80e736d3-2017-4d68-94b4-38255c3c59c6 ; approved Zinc label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c527d138-e32c-418f-9573-a3d8a796279f', 'published', now())
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
