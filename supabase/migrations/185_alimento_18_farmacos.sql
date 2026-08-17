-- =====================================================================
-- 185: Dimensão alimento/bebida (drug_food_interactions) para os 18
--      fármacos da BD sem nenhuma interação alimentar registada
--      (auditoria de cobertura por vertente — docs/INTERACOES_FLUXO_PESQUISA.md)
--
-- Âncoras:
--   * Sumo de toranja (CYP3A4) — diltiazem, verapamilo, tacrolimus,
--     sirolimus, pimozida (DailyMed/PubMed)
--   * Jejum recomendado — micofenolato (DailyMed CellCept)
--   * Vitamina K + álcool — acenocumarol ("V. Varfarina", QUADRO 2)
--   * Sem interação alimentar relevante — tópicos/IV/inalados/SC
--     (mupirocina, levocabastina, cetamina, cloranfenicol, ertapenem,
--     indacaterol, ticagrelor, probenecida, eslicarbazepina, cimetidina,
--     degarelix)
--
-- Conteúdo autorado PT/EN, ancorado nas fontes citadas (nunca inventar);
-- texto corrido sem \n. Idempotente: ON CONFLICT (drug_id, entity_slug)
-- DO NOTHING — reaplicar é seguro. Não depende de migrações novas
-- (todos os fármacos já existem na BD).
-- =====================================================================

INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity,
   mechanism_pt, mechanism_en, advice_pt, advice_en,
   source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
       v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
       v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  -- =====================================================================
  -- SUMO DE TORANJA (CYP3A4) — 5 fármacos
  -- =====================================================================

  -- Diltiazem × Sumo de toranja
  ('diltiazem', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'O sumo de toranja inibe o CYP3A4 intestinal e aumenta a exposição sistémica ao diltiazem (estudo em voluntários saudáveis documenta aumento da exposição com a coadministração). O diltiazem é metabolizado pelo CYP3A4.',
   'Grapefruit juice inhibits intestinal CYP3A4 and increases systemic exposure to diltiazem (a study in healthy volunteers documents increased exposure with coadministration). Diltiazem is metabolised by CYP3A4.',
   'Evitar o sumo de toranja durante o tratamento; se o consumo for inevitável, vigiar efeitos (hipotensão, bradicardia).',
   'Avoid grapefruit juice during treatment; if intake is unavoidable, monitor effects (hypotension, bradycardia).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cardizem (diltiazem): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f3e7ecef-f360-4987-a4f5-933214130ab2 ; PubMed: Coadministration of grapefruit juice increases systemic exposure of diltiazem (Bailey et al.)',
   'DailyMed/FDA (NIH/NLM) — approved Cardizem (diltiazem) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f3e7ecef-f360-4987-a4f5-933214130ab2 ; PubMed: Coadministration of grapefruit juice increases systemic exposure of diltiazem (Bailey et al.)', 1),

  -- Verapamilo × Sumo de toranja
  ('verapamilo', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'O verapamilo é substrato do CYP3A4; o sumo de toranja inibe esta enzima no intestino e pode aumentar as concentrações plasmáticas do verapamilo, com risco de hipotensão e bradicardia.',
   'Verapamil is a CYP3A4 substrate; grapefruit juice inhibits this enzyme in the gut and may raise verapamil plasma concentrations, with risk of hypotension and bradycardia.',
   'Evitar o sumo de toranja durante o tratamento com verapamilo.',
   'Avoid grapefruit juice during treatment with verapamil.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Verapamil Hydrochloride tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ed1e0c14-3571-43f9-88fc-5a4d2b598263',
   'DailyMed/FDA (NIH/NLM) — approved Verapamil Hydrochloride tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ed1e0c14-3571-43f9-88fc-5a4d2b598263', 1),

  -- Tacrolimus × Sumo de toranja
  ('tacrolimus', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'O rótulo do tacrolimus instrui: "Not to eat grapefruit or drink grapefruit juice in combination with tacrolimus". O sumo de toranja inibe o CYP3A4, aumentando as concentrações do tacrolimus e o risco de nefrotoxicidade e neurotoxicidade.',
   'The tacrolimus label instructs: "Not to eat grapefruit or drink grapefruit juice in combination with tacrolimus". Grapefruit juice inhibits CYP3A4, raising tacrolimus concentrations and the risk of nephrotoxicity and neurotoxicity.',
   'Não comer toranja nem beber sumo de toranja durante o tratamento com tacrolimus.',
   'Do not eat grapefruit or drink grapefruit juice during treatment with tacrolimus.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tacrolimus capsule: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55467f4b-8437-43a3-b6d9-1bc2a13b4c11',
   'DailyMed/FDA (NIH/NLM) — approved Tacrolimus capsule label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55467f4b-8437-43a3-b6d9-1bc2a13b4c11', 1),

  -- Sirolimus × Sumo de toranja
  ('sirolimus', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'O rótulo do sirolimus instrui: "Do not take sirolimus with grapefruit juice". O sumo de toranja inibe o CYP3A4 e a glicoproteína-P, aumentando as concentrações do sirolimus e o risco de toxicidade.',
   'The sirolimus label instructs: "Do not take sirolimus with grapefruit juice". Grapefruit juice inhibits CYP3A4 and P-glycoprotein, raising sirolimus concentrations and the risk of toxicity.',
   'Não tomar sirolimus com sumo de toranja; manter a toma de forma consistente (sempre com ou sempre sem alimentos).',
   'Do not take sirolimus with grapefruit juice; keep dosing consistent (always with or always without food).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sirolimus tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6a85ad01-8144-4d9c-e053-2991aa0a4f85',
   'DailyMed/FDA (NIH/NLM) — approved Sirolimus tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6a85ad01-8144-4d9c-e053-2991aa0a4f85', 1),

  -- Pimozida × Sumo de toranja
  ('pimozida', 'sumo_toranja', 'Sumo de toranja', 'Grapefruit juice', 'moderate',
   'O rótulo da pimozida instrui: "Because substances in grapefruit juice may inhibit the metabolism of pimozide by CYP 3A4, patients should be advised to avoid grapefruit juice". O aumento das concentrações da pimozida pode prolongar o intervalo QT.',
   'The pimozide label instructs: "Because substances in grapefruit juice may inhibit the metabolism of pimozide by CYP 3A4, patients should be advised to avoid grapefruit juice". Raised pimozide concentrations may prolong the QT interval.',
   'Evitar sumo de toranja e toranja durante o tratamento com pimozida.',
   'Avoid grapefruit juice and grapefruit during treatment with pimozide.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Pimozide tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4e954fc2-fdff-486c-beb6-2b8ace717081',
   'DailyMed/FDA (NIH/NLM) — approved Pimozide tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4e954fc2-fdff-486c-beb6-2b8ace717081', 1),

  -- =====================================================================
  -- JEJUM RECOMENDADO — micofenolato
  -- =====================================================================
  ('micofenolato', 'toma_em_jejum', 'Toma em jejum', 'Empty-stomach administration', 'moderate',
   'O rótulo do CellCept recomenda: "It is recommended that CELLCEPT be administered on an empty stomach". A administração com alimentos reduz a Cmax do ácido micofenólico (até 40%), embora a AUC total se mantenha semelhante.',
   'The CellCept label recommends: "It is recommended that CELLCEPT be administered on an empty stomach". Administration with food lowers mycophenolic acid Cmax (up to 40%), although total AUC remains similar.',
   'Preferir a toma em jejum; se a intolerância gastrointestinal obrigar, pode tomar com alimentos desde que de forma consistente.',
   'Prefer empty-stomach administration; if gastrointestinal intolerance requires it, it may be taken with food provided this is consistent.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado CellCept (micofenolato de mofetil): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40',
   'DailyMed/FDA (NIH/NLM) — approved CellCept (mycophenolate mofetil) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37241e87-4af4-4dc3-a1aa-ea6f20d8dc40', 1),

  -- =====================================================================
  -- ACENOCUMAROL — vitamina K + álcool ("V. Varfarina", QUADRO 2)
  -- =====================================================================
  ('acenocumarol', 'vitamina_k', 'Vitamina K (alimentar)', 'Vitamin K (dietary)', 'moderate',
   'O acenocumarol, como os restantes cumarínicos, é antagonista da vitamina K; alimentos ricos em vitamina K (brócolos, couves, espinafres, fígado) antagonizam o seu efeito e alteram o INR conforme a variação da ingestão (Prontuário QUADRO 2: "Acenocumarol: V. Varfarina").',
   'Acenocoumarol, like other coumarins, is a vitamin K antagonist; foods rich in vitamin K (broccoli, leafy greens, spinach, liver) counteract its effect and shift the INR as dietary intake varies (Prontuário QUADRO 2: "Acenocoumarol: see Warfarin").',
   'Manter uma ingestão alimentar de vitamina K estável e consistente; monitorizar o INR após alterações alimentares significativas.',
   'Keep dietary vitamin K intake stable and consistent; monitor INR after significant dietary changes.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin)', 1),

  ('acenocumarol', 'alcool', 'Álcool', 'Alcohol', 'moderate',
   'O QUADRO 2 da Varfarina remete "V. também: Álcool"; o consumo agudo elevado de álcool pode inibir o metabolismo dos cumarínicos e aumentar o INR, enquanto o consumo crónico elevado pode induzi-lo e reduzir o efeito anticoagulante.',
   'The QUADRO 2 entry for warfarin refers "See also: Alcohol"; acute heavy alcohol intake may inhibit coumarin metabolism and raise INR, while chronic heavy intake may induce it and reduce the anticoagulant effect.',
   'Aconselhar contra o consumo excessivo ou em padrão binge; o consumo moderado é aceitável desde que estável, com monitorização do INR se os hábitos mudarem.',
   'Advise against heavy or binge drinking; moderate intake is acceptable if consistent, with INR monitoring if drinking habits change.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Anexo 7, QUADRO 2 (Anticoagulantes orais: Acenocumarol — V. Varfarina)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Annex 7, Table 2 (Oral anticoagulants: Acenocoumarol — see Warfarin)', 2),

  -- =====================================================================
  -- SEM INTERAÇÃO ALIMENTAR RELEVANTE — 11 fármacos
  -- =====================================================================
  ('mupirocina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'A mupirocina é usada por via tópica (pomada/creme) com absorção sistémica mínima; os alimentos não afetam a sua utilização.',
   'Mupirocin is used topically (ointment/cream) with minimal systemic absorption; food does not affect its use.',
   'Pode aplicar independentemente das refeições.',
   'May be applied regardless of meals.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Mupirocin Ointment: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=06a4ee22-d8f8-4a8a-8666-82b14f2d8476',
   'DailyMed/FDA (NIH/NLM) — approved Mupirocin Ointment label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=06a4ee22-d8f8-4a8a-8666-82b14f2d8476', 1),

  ('levocabastina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'A levocabastina é usada por via tópica (colírio/ sprays nasais); a absorção sistémica é mínima e não há interação alimentar documentada.',
   'Levocabastine is used topically (eye drops/nasal sprays); systemic absorption is minimal and no food interaction is documented.',
   'Pode usar independentemente das refeições.',
   'May be used regardless of meals.',
   'Prontuário Terapêutico do INFARMED (11.ª ed., 2012) — Levocabastina (anti-histamínico tópico)',
   'Prontuário Terapêutico do INFARMED (11th ed., 2012) — Levocabastine (topical antihistamine)', 1),

  ('cetamina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'A cetamina é administrada por via intravenosa em contexto hospitalar; os alimentos não afetam a sua farmacocinética.',
   'Ketamine is given intravenously in the hospital setting; food does not affect its pharmacokinetics.',
   'Não aplicável — administração intravenosa; seguir as instruções de jejum pré-procedimento.',
   'Not applicable — intravenous administration; follow pre-procedure fasting instructions.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ketamine Hydrochloride Injection: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dd8eff00-b92e-4f48-8b57-0464484d6ddf',
   'DailyMed/FDA (NIH/NLM) — approved Ketamine Hydrochloride Injection label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=dd8eff00-b92e-4f48-8b57-0464484d6ddf', 1),

  ('cloranfenicol', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'O cloranfenicol não tem interações alimentares clinicamente significativas documentadas; pode ser administrado com ou sem alimentos.',
   'Chloramphenicol has no clinically significant food interactions documented; it may be given with or without food.',
   'Pode tomar com ou sem alimentos; em caso de náuseas, tomar com alimentos.',
   'May be taken with or without food; if nausea occurs, take with food.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Chloramphenicol tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2897e83b-6282-4e0c-bd8e-f389871259b2',
   'DailyMed/FDA (NIH/NLM) — approved Chloramphenicol tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2897e83b-6282-4e0c-bd8e-f389871259b2', 1),

  ('ertapenem', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'O ertapenem é administrado por via intravenosa; os alimentos não afetam a sua farmacocinética.',
   'Ertapenem is given intravenously; food does not affect its pharmacokinetics.',
   'Não aplicável — administração intravenosa.',
   'Not applicable — intravenous administration.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Invanz (ertapenem): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=33f3b99b-fa82-42e0-26bf-f49891ae3d22',
   'DailyMed/FDA (NIH/NLM) — approved Invanz (ertapenem) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=33f3b99b-fa82-42e0-26bf-f49891ae3d22', 1),

  ('indacaterol', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'O indacaterol é administrado por via inalatória; os alimentos não afetam a sua utilização.',
   'Indacaterol is given by inhalation; food does not affect its use.',
   'Pode inalar independentemente das refeições.',
   'May be inhaled regardless of meals.',
   'EMC-UK (MHRA) — SmPC aprovada Onbrez Breezhaler (indacaterol): https://www.medicines.org.uk/emc/product/7794/smpc',
   'EMC-UK (MHRA) — approved Onbrez Breezhaler (indacaterol) SmPC: https://www.medicines.org.uk/emc/product/7794/smpc', 1),

  ('ticagrelor', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'O rótulo do ticagrelor indica: "Ingestion of a high-fat meal had no effect on ticagrelor Cmax... You may take BRILINTA with or without food". Não há restrição alimentar.',
   'The ticagrelor label states: "Ingestion of a high-fat meal had no effect on ticagrelor Cmax... You may take BRILINTA with or without food". There is no dietary restriction.',
   'Pode tomar com ou sem alimentos, a horas fixas.',
   'May be taken with or without food, at fixed times.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Brilinta (ticagrelor): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1547e2b6-8858-178e-e063-6394a90abb23',
   'DailyMed/FDA (NIH/NLM) — approved Brilinta (ticagrelor) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=1547e2b6-8858-178e-e063-6394a90abb23', 1),

  ('probenecida', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'O rótulo do probenecid não documenta interação alimentar clinicamente significativa; para reduzir a irritação gastrointestinal, a toma com alimentos é razoável.',
   'The probenecid label documents no clinically significant food interaction; taking with food is reasonable to reduce gastrointestinal irritation.',
   'Pode tomar com alimentos para melhor tolerância gastrointestinal; manter uma hidratação abundante.',
   'May be taken with food for better gastrointestinal tolerance; maintain abundant hydration.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Probenecid tablet (Marlex): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d',
   'DailyMed/FDA (NIH/NLM) — approved Probenecid tablet label (Marlex): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5d552de5-2d18-4464-bcaf-0311fa3f080d', 1),

  ('eslicarbazepina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'O rótulo da eslicarbazepina indica: "Eslicarbazepine acetate tablets can be taken with or without food". Não há restrição alimentar.',
   'The eslicarbazepine label states: "Eslicarbazepine acetate tablets can be taken with or without food". There is no dietary restriction.',
   'Pode tomar com ou sem alimentos, a horas fixas.',
   'May be taken with or without food, at fixed times.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Eslicarbazepine Acetate tablet: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=28efe9d2-9d7b-4a7c-8458-098456d06604',
   'DailyMed/FDA (NIH/NLM) — approved Eslicarbazepine Acetate tablet label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=28efe9d2-9d7b-4a7c-8458-098456d06604', 1),

  ('cimetidina', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'A cimetidina não tem interação alimentar clinicamente significativa; a absorção não é afetada de forma relevante pelos alimentos.',
   'Cimetidine has no clinically significant food interaction; absorption is not relevantly affected by food.',
   'Pode tomar com ou sem alimentos; as tomas habituais são após as refeições e ao deitar.',
   'May be taken with or without food; usual dosing is after meals and at bedtime.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cimetidine: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=06c0a509-026f-44e0-9975-a94a8de51d43',
   'DailyMed/FDA (NIH/NLM) — approved Cimetidine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=06c0a509-026f-44e0-9975-a94a8de51d43', 1),

  ('degarelix', 'sem_interacao_alimentar', 'Sem interação alimentar relevante', 'No relevant food interaction', 'none',
   'O degarelix é administrado por via subcutânea; os alimentos não afetam a sua farmacocinética.',
   'Degarelix is given subcutaneously; food does not affect its pharmacokinetics.',
   'Não aplicável — administração subcutânea.',
   'Not applicable — subcutaneous administration.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Firmagon (degarelix): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b',
   'DailyMed/FDA (NIH/NLM) — approved Firmagon (degarelix) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ab11dd8a-0fd9-4013-89ab-e114557c7e4b', 1)
) AS v(slug, entity_slug, entity_pt, entity_en, severity,
       mechanism_pt, mechanism_en, advice_pt, advice_en,
       source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- =====================================================================
-- FIM — 19 entradas alimento (18 fármacos; acenocumarol com 2: vitamina
-- K + álcool). Aplicar no Supabase e depois ./revalidar.sh
-- =====================================================================
