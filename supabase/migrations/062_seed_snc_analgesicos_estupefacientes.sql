-- 062: Seed das 4 dimensões — Analgésicos/Antipiréticos, Estupefacientes e SNC (Fase B)
--   Subsecções do Prontuário: 2.10 (analgésicos/antipiréticos) · 2.12 (analgésicos estupefacientes)
--   · 2.13.1 (outros com ação no SNC — doença de Alzheimer).
--
-- Adiciona **8 fármacos novos** e preenche, para cada um, as 4 dimensões de interação:
--   drug_interactions        (fármaco-fármaco)      — Fluxo 1 · fonte DailyMed/FDA (+ referência adicional)
--   drug_food_interactions   (alimento/bebida)      — Fluxo 2 · fonte EMC-UK (canónica)
--   drug_disease_interactions(doença/condição)      — Fluxo 2 · fonte EMC-UK
--   drug_pregnancy_info      (gestação/lactação)    — Fluxo 2 · fonte EMC-UK
--
-- Fármacos novos (slugs): metamizol | morfina | codeina | fentanilo | hidromorfona |
--   buprenorfina | donepezilo | memantina. Nenhum existia em public.drugs (97 até 058 + 5 do 061).
-- Temos como PARCEIROS (já existentes em public.drugs): alprazolam, sertralina, fluoxetina,
-- itraconazol, varfarina, diclofenac, aspirina.
--
-- NOTA METAMIZOL (desvio de fonte documentado — ver docs/INTERACOES_FLUXO_PESQUISA.md §12):
--   O metamizol não tem SmPC EMC-UK (não aprovado no RU) nem rótulo FDA mono-ingrediente com conteúdo
--   clínico no DailyMed (a única SPL de dipirona é só marketing/packaging). Fonte primária:
--   (1) EMA — CHMP Article 31 referral "metamizole-containing medicinal products" (2019; EN; §4.6
--       gravidez/lactação + contraindicação no 3.º trimestre — base legal EU, aplicável em PT);
--   (2) SmPC nacional HALMED (Croácia) — Analgin 500 mg (metamizol): §4.3 contraindicações
--       (porfiria, défice G6PD, asma analgésica), §4.5 interações, §4.4 álcool;
--   (3) Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — corroboração.
--   Investigação de fonte indiana/asiática (CDSCO/SUGAM, Indian Pharmacopoeia) concluiu que a Índia
--   não publica SmPC clínicas em inglês citáveis; optou-se pela família EU/PT (EMA + SmPC nacional),
--   que é a que Portugal — e, via importação portuguesa, Angola — aplica legalmente.
--
-- Reexecução segura: ON CONFLICT ... DO NOTHING.  Fontes verificadas HTTP 200 em 2026-08.
-- NOTA: aplicada manualmente pelo utilizador no Supabase (o agente nunca executa).

-- ================================================================
-- 1. Novos fármacos em public.drugs
-- ================================================================
INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order) VALUES
  ('metamizol', 'Metamizol', 'Metamizole', 'Analgésico e antipirético (pirazolona)', 'Analgesic and antipyretic (pyrazolone)', ARRAY['dipirona', 'dipyrone', 'metamizol magnésico', 'Nolotil'], 'published', 98),
  ('morfina', 'Morfina', 'Morphine', 'Analgésico opioide', 'Opioid analgesic', ARRAY['morphine', 'morphine sulfate', 'MS Contin'], 'published', 99),
  ('codeina', 'Codeína', 'Codeine', 'Analgésico opioide (fraco)', 'Opioid analgesic (weak)', ARRAY['codeine phosphate'], 'published', 100),
  ('fentanilo', 'Fentanilo', 'Fentanyl', 'Analgésico opioide potente', 'Potent opioid analgesic', ARRAY['fentanil'], 'published', 101),
  ('hidromorfona', 'Hidromorfona', 'Hydromorphone', 'Analgésico opioide potente', 'Potent opioid analgesic', ARRAY['Dilaudid'], 'published', 102),
  ('buprenorfina', 'Buprenorfina', 'Buprenorphine', 'Analgésico opioide (agonista parcial)', 'Opioid analgesic (partial agonist)', ARRAY['buprenorphine'], 'published', 103),
  ('donepezilo', 'Donepezilo', 'Donepezil', 'Inibidor da acetilcolinesterase (doença de Alzheimer)', 'Acetylcholinesterase inhibitor (Alzheimer''s disease)', ARRAY['Aricept'], 'published', 104),
  ('memantina', 'Memantina', 'Memantine', 'Antagonista do recetor NMDA (doença de Alzheimer)', 'NMDA receptor antagonist (Alzheimer''s disease)', ARRAY['Axura', 'Ebixa'], 'published', 105);

-- ================================================================
-- 2. Fármaco-fármaco (drug_interactions) — Fluxo 1, fonte DailyMed/FDA
-- ================================================================
-- 11 pares: depressão do SNC (opioides×alprazolam), síndrome serotoninérgica
-- (opioides×sertralina), inibição do CYP3A4 (fentanilo/buprenorfina/donepezilo×
-- itraconazol) e potenciação de anticoagulantes/AAS (metamizol). Memantina tem
-- perfil de interações fármaco-fármaco escasso e documentado — fica coberta nas
-- dimensões alimento/doença/gestação.
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id), v.severity, v.summary_pt, v.summary_en,
       v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
       v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
       v.source_pt, v.source_en, 'published'
FROM (VALUES
  ('morfina','alprazolam','critical',
   'A associação de morfina com alprazolam aumenta o risco de sedação profunda, depressão respiratória, coma e morte.',
   'Combining morphine with alprazolam increases the risk of profound sedation, respiratory depression, coma and death.',
   'Efeito aditivo de opioides e benzodiazepinas na depressão do sistema nervoso central e da respiração.',
   'Additive effect of opioids and benzodiazepines on central nervous system and respiratory depression.',
   'Evitar a associação sempre que possível; se inevitável, usar as menores doses eficazes e vigiar de perto.',
   'Avoid the combination whenever possible; if unavoidable, use the lowest effective doses and monitor closely.',
   'Frequência respiratória, saturação de oxigénio, nível de sedação e pupilas.',
   'Respiratory rate, oxygen saturation, level of sedation and pupillary response.',
   'Depressão respiratória (frequência < 10/min), sedação profunda ou coma exigem avaliação urgente e reversão com naloxona.',
   'Respiratory depression (rate < 10/min), deep sedation or coma require urgent assessment and reversal with naloxone.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Morfina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57ee014e-744e-65e1-e063-6394a90a8c93 ; rótulo aprovado Alprazolam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0cf8b567-201b-44fa-8fd3-c74023aff44f — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Morphine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57ee014e-744e-65e1-e063-6394a90a8c93 ; approved Alprazolam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0cf8b567-201b-44fa-8fd3-c74023aff44f — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('codeina','alprazolam','critical',
   'A codeína com alprazolam aumenta o risco de sedação, depressão respiratória e morte; em crianças a codeína é contraindicada.',
   'Codeine with alprazolam increases the risk of sedation, respiratory depression and death; codeine is contraindicated in children.',
   'Efeito aditivo na depressão do SNC; a codeína é metabolizada a morfina pela CYP2D6 e a depressão central soma-se à benzodiazepina.',
   'Additive CNS depression; codeine is metabolised to morphine by CYP2D6 and the central depression adds to the benzodiazepine.',
   'Evitar a associação; se necessária, usar doses mínimas e vigiar o doente de perto.',
   'Avoid the combination; if required, use minimum doses and monitor the patient closely.',
   'Ritmo respiratório, sedação, pupilas, sinais de toxicidade opioide.',
   'Respiratory pattern, sedation, pupils and signs of opioid toxicity.',
   'Sedação profunda, bradipneia ou hipóxia exigem reversão urgente (naloxona).',
   'Deep sedation, bradypnoea or hypoxia require urgent reversal (naloxone).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Codeína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c966d73-77c6-4514-954e-57aa06a080c6 ; rótulo aprovado Alprazolam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0cf8b567-201b-44fa-8fd3-c74023aff44f — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Codeine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c966d73-77c6-4514-954e-57aa06a080c6 ; approved Alprazolam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0cf8b567-201b-44fa-8fd3-c74023aff44f — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('hidromorfona','alprazolam','critical',
   'A hidromorfona com alprazolam potencia a depressão do SNC e da respiração, podendo ser fatal.',
   'Hydromorphone with alprazolam potentiates CNS and respiratory depression and may be fatal.',
   'Ação aditiva opioide-benzodiazepina na depressão respiratória e do SNC.',
   'Additive opioid-benzodiazepine action on respiratory and CNS depression.',
   'Evitar a coadministração; se inevitável, reduzir doses e garantir supervisão.',
   'Avoid coadministration; if unavoidable, reduce doses and ensure supervision.',
   'Frequência respiratória, SpO2, sedação, diâmetro pupilar.',
   'Respiratory rate, SpO2, sedation and pupil size.',
   'Bradipneia ou ausência de resposta ao estímulo exigem naloxona e suporte ventilatório.',
   'Bradypnoea or unresponsiveness require naloxone and ventilatory support.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Hidromorfona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c5c1cc8-c42b-46e3-ad68-8e22f57101f2 ; rótulo aprovado Alprazolam: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0cf8b567-201b-44fa-8fd3-c74023aff44f — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Hydromorphone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c5c1cc8-c42b-46e3-ad68-8e22f57101f2 ; approved Alprazolam label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0cf8b567-201b-44fa-8fd3-c74023aff44f — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)')
) AS v(slug_a, slug_b, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
       management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id), 'moderate', v.summary_pt, v.summary_en,
       v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
       v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
       v.source_pt, v.source_en, 'published'
FROM (VALUES
  ('codeina','sertralina',
   'A codeína com sertralina aumenta o risco de síndrome serotoninérgica e pode alterar o efeito analgésico.',
   'Codeine with sertraline increases the risk of serotonin syndrome and may alter the analgesic effect.',
   'A codeína e a sertralina aumentam a serotonina no SNC; além disso a sertralina (inibição da CYP2D6) pode reduzir a conversão da codeína em morfina.',
   'Codeine and sertraline both raise CNS serotonin; also sertraline (CYP2D6 inhibition) may reduce codeine to morphine conversion.',
   'Vigiar sinais de serotoninergismo; se o efeito analgésico for insuficiente, considerar um analgésico alternativo.',
   'Monitor for serotonin excess; if analgesia is inadequate, consider an alternative analgesic.',
   'Agitação, febre, tremores, hiperreflexia, rigidez muscular.',
   'Agitation, fever, tremor, hyperreflexia, muscle rigidity.',
   'Febre alta com rigidez e alteração do estado mental exigem suspensão e tratamento urgente.',
   'High fever with rigidity and altered mental state require discontinuation and urgent treatment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Codeína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c966d73-77c6-4514-954e-57aa06a080c6 ; rótulo aprovado Sertralina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Codeine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c966d73-77c6-4514-954e-57aa06a080c6 ; approved Sertraline label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('fentanilo','sertralina',
   'O fentanilo com sertralina aumenta o risco de síndrome serotoninérgica.',
   'Fentanyl with sertraline increases the risk of serotonin syndrome.',
   'Ambos aumentam a serotonina no SNC; o fentanilo também reduz o limiar convulsivo que a sertralina pode influenciar.',
   'Both raise CNS serotonin; fentanyl also lowers the seizure threshold that sertraline may influence.',
   'Vigiar sinais de serotoninergismo nas primeiras semanas de associação.',
   'Monitor for signs of serotonin excess during the first weeks of combination.',
   'Tremores, hiperreflexia, mioclonias, agitação, hipertermia.',
   'Tremor, hyperreflexia, myoclonus, agitation, hyperthermia.',
   'Síndrome serotoninérgica grave exige a suspensão imediata de ambos.',
   'Severe serotonin syndrome requires immediate withdrawal of both drugs.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fentanilo: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e15a7e9b-8025-49dd-9a6d-bafcccf1959f ; rótulo aprovado Sertralina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Fentanyl label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e15a7e9b-8025-49dd-9a6d-bafcccf1959f ; approved Sertraline label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('buprenorfina','sertralina',
   'A buprenorfina com sertralina aumenta o risco de síndrome serotoninérgica.',
   'Buprenorphine with sertraline increases the risk of serotonin syndrome.',
   'Ambos aumentam a serotonina no SNC; a buprenorfina associa-se também a depressão respiratória que a sertralina pode mascarar.',
   'Both raise CNS serotonin; buprenorphine also causes respiratory depression that sertraline may mask.',
   'Vigiar sinais de serotoninergismo; ajustar doses com precaução.',
   'Monitor for serotonin excess; titrate doses with caution.',
   'Agitação, febre, tremores, hiperreflexia, clonias.',
   'Agitation, fever, tremor, hyperreflexia, clonus.',
   'Sinais de serotoninergismo grave exigem suspensão imediata e suporte.',
   'Signs of severe serotonin excess require immediate withdrawal and supportive care.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Buprenorfina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=713db2c6-0544-4633-b874-cfbeaf93db89 ; rótulo aprovado Sertralina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Buprenorphine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=713db2c6-0544-4633-b874-cfbeaf93db89 ; approved Sertraline label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('fentanilo','itraconazol',
   'O itraconazol (inibidor do CYP3A4) aumenta as concentrações de fentanilo, com risco de sedação e depressão respiratória.',
   'Itraconazole (CYP3A4 inhibitor) increases fentanyl concentrations, with risk of sedation and respiratory depression.',
   'O fentanilo é metabolizado principalmente pela CYP3A4; o itraconazol inibe esta enzima e reduz o clearance do opioide.',
   'Fentanyl is mainly metabolised by CYP3A4; itraconazole inhibits this enzyme and reduces opioid clearance.',
   'Reduzir a dose de fentanilo e vigiar de perto; evitar a associação se possível.',
   'Reduce the fentanyl dose and monitor closely; avoid the combination if possible.',
   'Sedação, frequência respiratória, sinais de toxicidade opioide.',
   'Sedation, respiratory rate and signs of opioid toxicity.',
   'Depressão respiratória exige suspensão temporária e suporte com naloxona.',
   'Respiratory depression requires temporary withdrawal and support with naloxone.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fentanilo: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e15a7e9b-8025-49dd-9a6d-bafcccf1959f ; rótulo aprovado Itraconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Fentanyl label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=e15a7e9b-8025-49dd-9a6d-bafcccf1959f ; approved Itraconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)')
) AS v(slug_a, slug_b, summary_pt, summary_en, mechanism_pt, mechanism_en,
       management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id), 'moderate', v.summary_pt, v.summary_en,
       v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
       v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
       v.source_pt, v.source_en, 'published'
FROM (VALUES
  ('buprenorfina','itraconazol',
   'O itraconazol aumenta as concentrações de buprenorfina, potenciando sedação e depressão respiratória.',
   'Itraconazole increases buprenorphine concentrations, potentiating sedation and respiratory depression.',
   'A buprenorfina é metabolizada pela CYP3A4; a inibição pelo itraconazol reduz o seu metabolismo.',
   'Buprenorphine is metabolised by CYP3A4; inhibition by itraconazole reduces its metabolism.',
   'Usar com precaução; considerar redução de dose e monitorização da sedação.',
   'Use with caution; consider dose reduction and sedation monitoring.',
   'Sinais de sobredosagem opioide: miose, sedação, bradipneia.',
   'Signs of opioid overdose: miosis, sedation, bradypnoea.',
   'Depressão respiratória persistente exige avaliação urgente.',
   'Persistent respiratory depression requires urgent assessment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Buprenorfina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=713db2c6-0544-4633-b874-cfbeaf93db89 ; rótulo aprovado Itraconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Buprenorphine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=713db2c6-0544-4633-b874-cfbeaf93db89 ; approved Itraconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('donepezilo','itraconazol',
   'O itraconazol aumenta as concentrações de donepezilo, com risco de efeitos colinérgicos.',
   'Itraconazole increases donepezil concentrations, with a risk of cholinergic effects.',
   'O donepezilo é metabolizado pela CYP3A4 e CYP2D6; o itraconazol inibe a CYP3A4 e eleva o nível do fármaco.',
   'Donepezil is metabolised by CYP3A4 and CYP2D6; itraconazole inhibits CYP3A4 and raises the drug level.',
   'Vigiar sintomas colinérgicos (náuseas, bradicardia, diarreia); considerar redução de dose.',
   'Monitor cholinergic symptoms (nausea, bradycardia, diarrhoea); consider dose reduction.',
   'Bradicardia, síncope, queixas gastrointestinais, agitação.',
   'Bradycardia, syncope, gastrointestinal complaints, agitation.',
   'Bradicardia sintomática ou síncope exigem avaliação cardiológica.',
   'Symptomatic bradycardia or syncope require cardiology assessment.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Donepezilo: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=98e451e1-e4d7-4439-a675-c5457ba20975 ; rótulo aprovado Itraconazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
   'DailyMed/FDA (NIH/NLM) — approved Donepezil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=98e451e1-e4d7-4439-a675-c5457ba20975 ; approved Itraconazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a4d555fa-787c-40fb-bb7d-b0d4f7318fd0 — with additional reference: Prontuário Terapêutico do INFARMED (11th ed., 2012)'),
  ('metamizol','warfarina',
   'O metamizol pode potenciar o efeito dos anticoagulantes orais, aumentando o risco hemorrágico.',
   'Metamizole may potentiate the effect of oral anticoagulants, increasing bleeding risk.',
   'Mecanismo não totalmente esclarecido; o metamizol pode potenciar o efeito dos cumarínicos e aumentar o risco de hemorragia gastrointestinal.',
   'Mechanism not fully established; metamizole may enhance coumarin anticoagulants and increase gastrointestinal bleeding risk.',
   'Monitorizar o INR e sinais de hemorragia; se possível, preferir paracetamol como analgésico.',
   'Monitor INR and signs of bleeding; where possible prefer paracetamol as analgesic.',
   'INR, equimoses, hemorragias, queda do valor de hemoglobina.',
   'INR, bruising, bleeding and fall in haemoglobin.',
   'INR acima do alvo ou hemorragia ativa exigem ajuste do anticoagulante.',
   'INR above target or active bleeding require anticoagulant adjustment.',
   'EMA — Metamizole (referência Article 31): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products ; rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012) e SmPC nacional Analgin 500 mg (HALMED)',
   'EMA — Metamizole (Article 31 referral): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — with additional references: Prontuário Terapêutico do INFARMED (11th ed., 2012) and national Analgin 500 mg SmPC (HALMED)'),
  ('metamizol','aspirina',
   'O metamizol pode reduzir o efeito antiagregante do ácido acetilsalicílico em baixa dose.',
   'Metamizole may reduce the antiplatelet effect of low-dose acetylsalicylic acid.',
   'O metamizol interfere com a inibição da COX-1 plaquetária pelo AAS, podendo diminuir a cardioproteção.',
   'Metamizole interferes with aspirin COX-1 platelet inhibition, which may reduce cardioprotection.',
   'Evitar a coadministração quando o AAS é usado para prevenção cardiovascular.',
   'Avoid coadministration when aspirin is used for cardiovascular prevention.',
   'Risco cardiovascular e adesão à antiagregação do doente.',
   'Patient cardiovascular risk and adherence to antiplatelet therapy.',
   'Novo evento isquémico com uso de AAS requer revisão da estratégia antitrombótica.',
   'New ischaemic event while on aspirin requires review of the antithrombotic strategy.',
   'EMA (referência Article 31) — Metamizole: https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products ; rótulo aprovado Aspirina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012) e SmPC nacional Analgin 500 mg (HALMED)',
   'EMA (Article 31 referral) — Metamizole: https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products ; approved Aspirin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366 — with additional references: Prontuário Terapêutico do INFARMED (11th ed., 2012) and national Analgin 500 mg SmPC (HALMED)')
) AS v(slug_a, slug_b, summary_pt, summary_en, mechanism_pt, mechanism_en,
       management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;


-- ================================================================
-- 3. Alimento / Bebida (drug_food_interactions) — Fluxo 2, fonte EMC-UK
-- ================================================================
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity,
   mechanism_pt, mechanism_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
       v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('morfina', 'alcool', 'Álcool (etanol)', 'Alcohol (ethanol)', 'moderate',
   'O álcool potencia os efeitos depressores do SNC da morfina, com risco de sedação e depressão respiratória.',
   'Alcohol enhances the CNS-depressant effects of morphine, with risk of sedation and respiratory depression.',
   'Recomendar a evicção do consumo de álcool durante o tratamento.',
   'Advise avoiding alcohol consumption during treatment.',
   'EMC-UK (MHRA) — SmPC aprovada MST Continus (Morfina): https://www.medicines.org.uk/emc/product/7664/smpc',
   'EMC-UK (MHRA) — approved MST Continus (Morphine) SmPC: https://www.medicines.org.uk/emc/product/7664/smpc', 1),
  ('codeina', 'alcool', 'Álcool (etanol)', 'Alcohol (ethanol)', 'moderate',
   'O álcool potencia os efeitos depressores do SNC e o risco de sobredosagem da codeína.',
   'Alcohol potentiates the CNS-depressant effects and the overdose risk of codeine.',
   'Recomendar a evicção do consumo de álcool durante o tratamento.',
   'Advise avoiding alcohol consumption during treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Codeine Linctus (Codeína): https://www.medicines.org.uk/emc/product/4512/smpc',
   'EMC-UK (MHRA) — approved Codeine Linctus (Codeine) SmPC: https://www.medicines.org.uk/emc/product/4512/smpc', 1),
  ('fentanilo', 'alcool', 'Álcool (etanol)', 'Alcohol (ethanol)', 'moderate',
   'O álcool potencia a depressão respiratória e a sedação do fentanilo; o consumo simultâneo pode ser fatal.',
   'Alcohol potentiates the respiratory depression and sedation of fentanyl; simultaneous use may be fatal.',
   'Contraindicar o consumo de álcool enquanto durar o tratamento com fentanilo.',
   'Alcohol is contraindicated during fentanyl treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Durogesic DTrans (Fentanilo): https://www.medicines.org.uk/emc/product/6942/smpc',
   'EMC-UK (MHRA) — approved Durogesic DTrans (Fentanyl) SmPC: https://www.medicines.org.uk/emc/product/6942/smpc', 1),
  ('hidromorfona', 'alcool', 'Alcool (etanol)', 'Alcohol (ethanol)', 'moderate',
   'O álcool aumenta os efeitos depressores do SNC da hidromorfona.',
   'Alcohol increases the CNS-depressant effects of hydromorphone.',
   'Evitar o consumo de álcool durante o tratamento.',
   'Avoid alcohol during treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Palladone SR (Hidromorfona): https://www.medicines.org.uk/emc/product/1018/smpc',
   'EMC-UK (MHRA) — approved Palladone SR (Hydromorphone) SmPC: https://www.medicines.org.uk/emc/product/1018/smpc', 1),
('buprenorfina', 'alcool', 'Álcool (etanol)', 'Alcohol (ethanol)', 'moderate',
   'O álcool potencia os efeitos depressores do SNC da buprenorfina.',
   'Alcohol potentiates the CNS-depressant effects of buprenorphine.',
   'Avoid alcohol during treatment.',
   'Avoid alcohol during treatment.',
   'EMC-UK (MHRA) — SmPC aprovado BuTrans (Buprenorfina): https://www.medicines.org.uk/emc/product/7645/smpc',
   'EMC-UK (MHRA) — approved BuTrans (Buprenorphine) SmPC: https://www.medicines.org.uk/emc/product/7645/smpc', 1),
  ('donepezilo', 'alcool', 'Álcool (etanol)', 'Alcohol (ethanol)', 'minor',
   'O álcool pode reduzir os níveis de donepezilo e aumentar os efeitos adversos.',
   'Alcohol may reduce donepezil levels and increase adverse effects.',
   'Limitar o consumo de álcool durante o tratamento.',
   'Limit alcohol consumption during treatment.',
   'EMC-UK (MHRA) — SmPC aprovada Aricept (Donepezilo): https://www.medicines.org.uk/emc/product/13283/smpc',
   'EMC-UK (MHRA) — approved Aricept (Donepezil) SmPC: https://www.medicines.org.uk/emc/product/13283/smpc', 1),
  ('memantina', 'dieta', 'Mudanças drásticas de dieta', 'Drastic dietary changes', 'minor',
   'Alterações drásticas da dieta podem alcalinarizar a urina e alterar a excreção da memantina.',
   'Drastic dietary changes may alkalinise the urine and alter memantine elimination.',
   'Evitar mudanças drásticas de dieta; vigiar estados que alterem o pH urinário.',
   'Avoid drastic dietary changes; monitor conditions that alter urine pH.',
   'EMC-UK (MHRA) — SmPC aprovada Ebixa (Memantina): https://www.medicines.org.uk/emc/product/8222/smpc',
   'EMC-UK (MHRA) — approved Ebixa (Memantine) SmPC: https://www.medicines.org.uk/emc/product/8222/smpc', 1),
  ('metamizol', 'alcool', 'Álcool (etanol)', 'Alcohol (ethanol)', 'moderate',
   'O álcool potencia o efeito do metamizol e aumenta o risco de depressão do SNC.',
   'Alcohol enhances the effect of metamizole and may increase the risk of CNS depression.',
   'Recomendar a evicção do consumo de álcool durante o tratamento com metamizol.',
   'Advise avoiding alcohol consumption during metamizole treatment.',
   'SmPC nacional Analgin 500 mg (HALMED) — interação do metamizol com o álcool ; EMA — Metamizole (Article 31 referral): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products',
   'National Analgin 500 mg SmPC (HALMED) — metamizole interaction with alcohol ; EMA — Metamizole (Article 31 referral): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products', 1)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
       mechanism_pt, mechanism_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug;

-- ================================================================
-- 4. Doença / Condição (drug_disease_interactions) — Fluxo 2, fonte EMC-UK
-- ================================================================
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
('morfina', 'depressao_respiratoria', 'Depressão respiratória (hipoxias/hipocapnia)', 'Respiratory depression (hypoxias/hypocapnia)', 'contraindication', 'critical',
   'A morfina pode provocar ou agravar a depressão respiratória, riso em doentes com insuficiência respiratória.',
   'Morphine may cause or worsen respiratory depression, a risk in patients with respiratory insufficiency.',
   'Contraindicada na depressão respiratória grave; usar com extrema cautela noutras insuficiências respiratórias.',
   'Contraindicated in severe respiratory depression; use with extreme caution in other respiratory insufficiency.',
   'EMC-UK (MHRA) — SmPC aprovada MST Continus (Morfina): https://www.medicines.org.uk/emc/product/7664/smpc',
   'EMC-UK (MHRA) — approved MST Continus SmPC: https://www.medicines.org.uk/emc/product/7664/smpc', 1),
  ('morfina', 'ileo_paralitico', 'Íleo paralítico', 'Paralytic ileus', 'contraindication', 'critical',
   'Os opioides reduzem a motilidade gastrointestinal e podem causar ou agravar o íleo paralítico.',
   'Opioids reduce gastrointestinal motility and may cause or worsen paralytic ileus.',
   'Contraindicado em doentes com íleo paralitico; vigiar obstipação grave.',
   'Contraindicated in paralytic ileus; monitor for severe constipation.',
   'EMC-UK (MHRA) — SmPC aprovada MST Continus (Morfina): https://www.medicines.org.uk/emc/product/7664/smpc',
   'EMC-UK (MHRA) — approved MST Continus SmPC: https://www.medicines.org.uk/emc/product/7664/smpc', 2),
  ('codeina', 'asma_grave', 'Asma grave do doente / asma induzida por opioides', 'Severe asthma / opioid-induced asthma', 'contraindication', 'critical',
   'A codeína pode causar broncospasmo e exacerbar a asma.',
   'Codeine may cause bronchospasm and worsen asthma.',
   'Contraindicada em asma grave e em doentes com broncoespasmo induzido por opioides.',
   'Contraindicated in severe asthma and in patients with opioid-induced bronchospasm.',
   'EMC-UK (MHRA) — SmPC aprovada Codeine Linctus (Codeína): https://www.medicines.org.uk/emc/product/4512/smpc',
   'EMC-UK (MHRA) — approved Codeine Linctus SmPC: https://www.medicines.org.uk/emc/product/4512/smpc', 1),
  ('codeina', 'criancas', 'Crianças (idade < 12 anos)', 'Children (age < 12 years)', 'contraindication', 'critical',
   'A codeína não é recomendada em crianças (metabolism from genetics); risco de depressão respiratória grave.',
   'Codeine is not recommended in children due to genetic metabolism variability; risk of severe respiratory depression.',
   'Contraindicada em crianças < 12 anos e em populations de metabolizadores ultra-rápidos.',
   'Contraindicated in children < 12 years and ultra-rapid metabolisers.',
   'EMC-UK (MHRA) — SmPC aprovada Codeine Linctus: https://www.medicines.org.uk/emc/product/4512/smpc',
   'EMC-UK (MHRA) — approved Codeine Linctus SmPC: https://www.medicines.org.uk/emc/product/4512/smpc', 2)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug;


INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('fentanilo', 'depressao_respiratoria', 'Depressão respiratória grave', 'Severe respiratory depression', 'contraindication', 'critical',
   'O fentanilo deprime o centro respiratório e é contraindicado na depressão respiratória grave.',
   'Fentanyl depresses the respiratory centre and is contraindicated in severe respiratory depression.',
   'Contraindicado; em doenças pulmonares crónicas usar com precaução e vigiar a respiração.',
   'Contraindicated; use with caution and monitor respiration in chronic pulmonary disease.',
   'EMC-UK (MHRA) — SmPC aprovada Durogesic DTrans (Fentanilo): https://www.medicines.org.uk/emc/product/6942/smpc',
   'EMC-UK (MHRA) — approved Durogesic DTrans (Fentanyl) SmPC: https://www.medicines.org.uk/emc/product/6942/smpc', 1),
  ('fentanilo', 'febre', 'Febre / calor externo', 'Fever / external heat', 'precaution', 'moderate',
   'A febre ou o calor externo aumentam a libertação de fentanilo do adesivo transdérmico.',
   'Fever or external heat increases fentanyl release from the transdermal patch.',
   'Aconselhar a evitar fontes de calor (sauna, banho quente, sol) e vigiar sinais de sobredosagem.',
   'Advise avoiding heat sources (sauna, hot bath, sun) and monitor for overdose signs.',
   'EMC-UK (MHRA) — SmPC aprovada Durogesic DTrans (Fentanilo): https://www.medicines.org.uk/emc/product/6942/smpc',
   'EMC-UK (MHRA) — approved Durogesic DTrans (Fentanyl) SmPC: https://www.medicines.org.uk/emc/product/6942/smpc', 2),
  ('hidromorfona', 'depressao_respiratoria', 'Depressão respiratória grave / DPOC grave', 'Severe respiratory depression / severe COPD', 'contraindication', 'critical',
   'A hidromorfona pode causar ou agravar a depressão respiratória.',
   'Hydromorphone may cause or worsen respiratory depression.',
   'Contraindicada na depressão respiratória grave; precaução na DPOC, asma e apneia do sono.',
   'Contraindicated in severe respiratory depression; caution in COPD, asthma and sleep apnoea.',
   'EMC-UK (MHRA) — SmPC aprovada Palladone SR (Hidromorfona): https://www.medicines.org.uk/emc/product/1018/smpc',
   'EMC-UK (MHRA) — approved Palladone SR (Hydromorphone) SmPC: https://www.medicines.org.uk/emc/product/1018/smpc', 1),
  ('hidromorfona', 'ileo_paralitico', 'Íleo paralítico / abdómen agudo', 'Paralytic ileus / acute abdomen', 'contraindication', 'critical',
   'Os opioides reduzem a motilidade gastrointestinal e podem agravar o íleo paralítico.',
   'Opioids reduce GI motility and may worsen paralytic ileus.',
   'Contraindicada em doentes com íleo paralitico ou abdómen agudo.',
   'Contraindicated in patients with paralytic ileus or acute abdomen.',
   'EMC-UK (MHRA) — SmPC aprovada Palladone SR (Hidromorfona): https://www.medicines.org.uk/emc/product/1018/smpc',
   'EMC-UK (MHRA) — approved Palladone SR (Hydromorphone) SmPC: https://www.medicines.org.uk/emc/product/1018/smpc', 2)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug;

INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('buprenorfina', 'insuf_respiratoria', 'Insuficiência respiratória grave', 'Severe respiratory impairment', 'contraindication', 'critical',
   'A buprenorfina pode causar depressão respiratória clinicamente significativa.',
   'Buprenorphine may cause clinically significant respiratory depression.',
   'Contraindicada na insuficiência respiratória grave.',
   'Contraindicated in severe respiratory impairment.',
   'EMC-UK (MHRA) — SmPC aprovado BuTrans (Buprenorfina): https://www.medicines.org.uk/emc/product/7645/smpc',
   'EMC-UK (MHRA) — approved BuTrans (Buprenorphine) SmPC: https://www.medicines.org.uk/emc/product/7645/smpc', 1),
  ('buprenorfina', 'dependencia_opioides', 'Doentes dependentes de opioides', 'Opioid-dependent patients', 'contraindication', 'critical',
   'Pode precipitar síndrome de privação em doentes dependentes de opioides agonistas plenos.',
   'May precipitate withdrawal in patients dependent on full opioid agonists.',
   'Contraindicada em doentes dependentes, exceto em programas estruturados.',
   'Contraindicated in dependent patients, except in structured programmes.',
   'EMC-UK (MHRA) — SmPC aprovado BuTrans (Buprenorfina): https://www.medicines.org.uk/emc/product/7645/smpc',
   'EMC-UK (MHRA) — approved BuTrans (Buprenorphine) SmPC: https://www.medicines.org.uk/emc/product/7645/smpc', 2)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug;

INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
       v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('donepezilo', 'doenca_no_sinusal', 'Doença do nó sinusal / distúrbios de condução', 'Sick sinus syndrome / conduction disorders', 'precaution', 'moderate',
   'O donepezilo, colinomimético, pode causar bradicardia e bloquear a condução cardíaca.',
   'Donepezil, a cholinesterase inhibitor, may cause bradycardia and cardiac conduction block.',
   'Usar com precaução em doentes com síndrome do nó sinusal ou distúrbios de condução; vigiar o ECG.',
   'Use with caution in sick sinus syndrome or conduction disorders; monitor the ECG.',
   'EMC-UK (MHRA) — SmPC aprovada Aricept (Donepezilo): https://www.medicines.org.uk/emc/product/13283/smpc',
   'EMC-UK (MHRA) — approved Aricept (Donepezil) SmPC: https://www.medicines.org.uk/emc/product/13283/smpc', 1),
  ('donepezilo', 'ulcera_peptica', 'História de úlcera péptica / uso de AINE', 'History of peptic ulcer / NSAID use', 'precaution', 'moderate',
   'O aumento da atividade colinérgica pode aumentar o risco de hemorragia e úlcera gastrointestinal.',
   'Increased cholinergic activity may increase the risk of gastrointestinal bleeding and ulceration.',
   'Vigiar sintomas gastrointestinais e considerar precaução com AINE em simultâneo.',
   'Monitor gastrointestinal symptoms and use caution with concurrent NSAIDs.',
   'EMC-UK (MHRA) — SmPC aprovada Aricept (Donepezilo): https://www.medicines.org.uk/emc/product/13283/smpc',
   'EMC-UK (MHRA) — approved Aricept (Donepezil) SmPC: https://www.medicines.org.uk/emc/product/13283/smpc', 2),
  ('memantina', 'epilepsia', 'Epilepsia / convulsões', 'Epilepsy / seizures', 'precaution', 'moderate',
   'A memantina pode reduzir o limiar convulsivo.',
   'Memantine may lower the convulsion threshold.',
   'Usar com precaução em doentes com epilepsia ou história de convulsões.',
   'Use with caution in patients with epilepsy or a history of seizures.',
   'EMC-UK (MHRA) — SmPC aprovada Ebixa (Memantina): https://www.medicines.org.uk/emc/product/8222/smpc',
   'EMC-UK (MHRA) — approved Ebixa (Memantine) SmPC: https://www.medicines.org.uk/emc/product/8222/smpc', 1),
  ('metamizol', 'agranulocitose_historico', 'História de agranulocitose induzida por metamizol', 'History of metamizole-induced agranulocytosis', 'contraindication', 'critical',
   'Risco recorrente e potencialmente fatal de agranulocitose após exposição prévia.',
   'Recurrent and potentially fatal risk of agranulocytosis after previous exposure.',
   'Contra indicado; advertir para sinais de infecção que exijam hemograma imediato.',
   'Contraindicated; warn about signs of infection requiring an immediate blood count.',
   'SmPC nacional Analgin 500 mg (HALMED) ; EMA — Metamizole (Article 31 referral): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products',
   'National Analgin 500 mg SmPC (HALMED) ; EMA — Metamizole (Article 31 referral): https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products', 1)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug;

-- ================================================================
-- ================================================================
-- 5. Gestação / Lactação (drug_pregnancy_info, 1:1 por fármaco) — Fluxo 2, fonte EMC-UK
-- ================================================================
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('morfina', 'caution',
   'A morfina atravessa a placenta; o uso crónico pode provocar síndrome de abstinência neonatal e depressão respiratória no recém-nascido.',
   'Morphine crosses the placenta; chronic use may cause neonatal withdrawal syndrome and respiratory depression in the neonate.',
   'Não recomendada a menos que o benefício justifique o risco; o uso no trabalho de parto pode deprimir a respiração do recém-nascido.',
   'Not recommended unless benefit outweighs risk; use in labour may depress neonatal respiration.',
   'Excretada no leite; não recomendada durante a amamentação.',
   'Excreted into breast milk; not recommended while breastfeeding.',
   'Com uso crónico, aconselhar sobre contraceção eficaz.',
   'With chronic use, advise on effective contraception.',
   'EMC-UK (MHRA) — SmPC aprovada MST Continus (Morfina): https://www.medicines.org.uk/emc/product/7664/smpc',
   'EMC-UK (MHRA) — approved MST Continus (Morphine) SmPC: https://www.medicines.org.uk/emc/product/7664/smpc'),
  ('codeina', 'caution',
   'A codeína atravessa a placenta e pode causar privação e depressão respiratória no neonato.',
   'Codeine crosses the placenta and may cause withdrawal and respiratory depression in the neonate.',
   'Não recomendada; o uso no parto pode induzir depressão respiratória neonatal.',
   'Not recommended; labour use may induce neonatal respiratory depression.',
   'Contraindicada na lactação (risco de toxicidade em mães metabolizadoras ultra-rápidas).',
   'Contraindicated in breastfeeding (risk of toxicity in ultra-rapid metaboliser mothers).',
   'Recomendar evitar em idade fértil; preferir analgésico alternativo.',
   'Advise avoiding in fertile age; prefer an alternative analgesic.',
   'EMC-UK (MHRA) — SmPC aprovada Codeine Linctus (Codeína): https://www.medicines.org.uk/emc/product/4512/smpc',
   'EMC-UK (MHRA) — approved Codeine Linctus (Codeine) SmPC: https://www.medicines.org.uk/emc/product/4512/smpc'),
  ('fentanilo', 'caution',
   'O fentanilo atravessa a placenta e pode causar privação neonatal e depressão respiratória se usado perto do termo.',
   'Fentanyl crosses the placenta and may cause neonatal withdrawal and respiratory depression near term.',
   'Não recomendado durante a gravidez, exceto se não existirem alternativas.',
   'Not recommended during pregnancy unless alternatives are unavailable.',
   'Não recomendado durante a amamentação; aguardar 48–72 h após remoção do adesivo.',
   'Not recommended while nursing; wait 48–72 h after patch removal.',
   'Com uso crónico, aconselhar contraceção eficaz.',
   'With chronic use, advise effective contraception.',
   'EMC-UK (MHRA) — SmPC aprovada Durogesic (Fentanilo): https://www.medicines.org.uk/emc/product/6942/smpc',
   'EMC-UK (MHRA) — approved Durogesic (Fentanyl) SmPC: https://www.medicines.org.uk/emc/product/6942/smpc'),
  ('hidromorfona', 'caution',
   'A hidromorfona atravessa a placenta e pode provocar privação neonatal se usada cronicamente.',
   'Hydromorphone crosses the placenta and may cause neonatal withdrawal with chronic use.',
   'Não recomendada a menos que seja claramente necessária; no parto pode deprimir a respiração neonatal.',
   'Not recommended unless clearly necessary; in labour may depress neonatal respiration.',
   'Excretada no leite; não recomendada durante a amamentação.',
   'Excreted into breast milk; not recommended while breastfeeding.',
   'Em uso crónico, aconselhar contraceção eficaz.',
   'With chronic use, advise effective contraception.',
   'EMC-UK (MHRA) — SmPC aprovada Palladone (Hidromorfona): https://www.medicines.org.uk/emc/product/1018/smpc',
   'EMC-UK (MHRA) — approved Palladone (Hydromorphone) SmPC: https://www.medicines.org.uk/emc/product/1018/smpc'),
  ('buprenorfina', 'caution',
   'A buprenorfina atravessa a placenta; o uso crónico pode causar abstinência neonatal.',
   'Buprenorphine crosses the placenta; chronic use may cause neonatal withdrawal.',
   'Não recomendada a menos que o benefício justifique o risco.',
   'Not recommended unless benefit outweighs risk.',
   'Excretada no leite; evitar durante a amamentação.',
   'Excreted into breast milk; avoid while breastfeeding.',
   'Aconselhar contraceção eficaz no uso crónico.',
   'Advise effective contraception with chronic use.',
   'EMC-UK (MHRA) — SmPC aprovado BuTrans (Buprenorfina): https://www.medicines.org.uk/emc/product/7645/smpc',
   'EMC-UK (MHRA) — approved BuTrans (Buprenorphine) SmPC: https://www.medicines.org.uk/emc/product/7645/smpc'),
  ('donepezilo', 'caution',
   'Dados limitados em humanos; a utilização deve ser evitada exceto quando essencial.',
   'Limited human data; use should be avoided unless clearly necessary.',
   'Não recomendado durante a gravidez.',
   'Not recommended during pregnancy.',
   'Excretado no leite; mulheres em tratamento devem evitar amamentar.',
   'Excreted in milk; treated women should avoid breastfeeding.',
   'Aconselhar contraceção eficaz.',
   'Advise effective contraception.',
   'EMC-UK (MHRA) — SmPC aprovada Aricept (Donepezilo): https://www.medicines.org.uk/emc/product/13283/smpc',
   'EMC-UK (MHRA) — approved Aricept (Donepezil) SmPC: https://www.medicines.org.uk/emc/product/13283/smpc'),
  ('memantina', 'caution',
   'Dados limitados; a segurança na gravidez é desconhecida.',
   'Limited data; safety in pregnancy is unknown.',
   'Não recomendado durante a gravidez.',
   'Not recommended during pregnancy.',
   'Excretado no leite; evitar durante a amamentação.',
   'Excreted in milk; avoid while breastfeeding.',
   'Aconselhar contraceção eficaz.',
   'Advise effective contraception.',
   'EMC-UK (MHRA) — SmPC aprovada Ebixa (Memantina): https://www.medicines.org.uk/emc/product/8222/smpc',
   'EMC-UK (MHRA) — approved Ebixa (Memantine) SmPC: https://www.medicines.org.uk/emc/product/8222/smpc'),
  ('metamizol', 'contraindicated',
   'O metamizol está contraindicado no terceiro trimestre (risco de toxicidade renal fetal e de encerramento prematuro do canal arterial).',
   'Metamizole is contraindicated in the third trimester (risk of fetal renal toxicity and premature closure of the ductus arteriosus).',
   'Contraindicado no terceiro trimestre; nos dois primeiros trimestres evitar, exceto uso de curta duração.',
   'Contraindicated in the third trimester; in the first two trimesters avoid unless short-term use is needed.',
   'Excretado no leite; evitar durante a amamentação.',
   'Excreted in milk; avoid while breastfeeding.',
   'Aconselhar contraceção eficaz.',
   'Advise effective contraception.',
   'EMA — Metamizole (Article 31 referral), contraindicação no 3.º trimestre: https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products',
   'EMA — Metamizole (Article 31 referral), 3rd-trimester contraindication: https://www.ema.europa.eu/en/medicines/human/referrals/metamizole-containing-medicinal-products')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en,
       source_pt, source_en)
ON d.slug = v.slug;
