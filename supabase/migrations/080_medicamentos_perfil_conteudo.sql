-- =====================================================================
-- 080 — drug_profiles: indicações, efeitos secundários e precauções
-- ---------------------------------------------------------------------
-- Conteúdo dos 5 fármacos piloto (warfarina, ibuprofeno, ramipril,
-- espironolactona, sotalol), autorado a partir dos rótulos aprovados pela
-- FDA (DailyMed/NIH/NLM — secções INDICATIONS AND USAGE, ADVERSE REACTIONS,
-- CONTRAINDICATIONS e WARNINGS AND PRECAUTIONS) e corroborado pelo
-- Prontuário Terapêutico do INFARMED (11.ª ed., 2012, ficheiro offline
-- fontes_interacoes/prontuario_utf8.txt). Conteúdo autoral (não copiado),
-- em bullets separados por \n (renderizados como lista na página).
-- Idempotente: reaplicar é seguro (UPDATEs re-escritos com valores
-- idênticos). Aplicar manualmente no Supabase (SQL editor).
-- =====================================================================

ALTER TABLE public.drug_profiles
  ADD COLUMN IF NOT EXISTS indications_pt TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS indications_en TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS side_effects_pt TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS side_effects_en TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS precautions_pt TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS precautions_en TEXT NOT NULL DEFAULT '';

-- ---------------------------------------------------------------------
-- WARFARINA
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles
SET
  indications_pt = E'Profilaxia e tratamento da trombose venosa profunda e da sua extensão, incluindo o tromboembolismo pulmonar.\nProfilaxia e tratamento das complicações tromboembólicas da fibrilhação auricular.\nProfilaxia e tratamento das complicações tromboembólicas em doentes com próteses valvulares cardíacas.\nRedução do risco de morte, de novo enfarte do miocárdio e de eventos tromboembólicos após enfarte do miocárdio.',
  indications_en = E'Prophylaxis and treatment of deep vein thrombosis and its extension, including pulmonary embolism.\nProphylaxis and treatment of thromboembolic complications of atrial fibrillation.\nProphylaxis and treatment of thromboembolic complications in patients with heart valve prostheses.\nReduction of the risk of death, recurrent myocardial infarction and thromboembolic events after myocardial infarction.',
  side_effects_pt = E'Hemorragia (o efeito adverso mais importante), sobretudo nos primeiros meses de tratamento e quando o INR está acima do alvo.\nNáuseas, vómitos, diarreia ou desconforto abdominal.\nErupção cutânea, comichão ou queda de cabelo.\nRaramente, necrose da pele e reações de hipersensibilidade.\nProcure ajuda médica imediata se tiver hemorragias que não param, sangue na urina, fezes escuras, equimoses espontâneas, tonturas intensas ou fraqueza súbita.',
  side_effects_en = E'Bleeding (the most important adverse effect), especially in the first months of treatment and when the INR is above target.\nNausea, vomiting, diarrhoea or abdominal discomfort.\nSkin rash, itching or hair loss.\nRarely, skin necrosis and hypersensitivity reactions.\nSeek immediate medical help if you have bleeding that does not stop, blood in the urine, dark stools, spontaneous bruising, severe dizziness or sudden weakness.',
  precautions_pt = E'Requer análises regulares (INR) para ajustar a dose; nunca altere a dose por sua conta.\nInforme o seu médico sobre todos os medicamentos, suplementos e plantas medicinais que toma — muitos alteram o efeito da varfarina.\nEvite mudanças bruscas na ingestão de alimentos ricos em vitamina K (ex.: couves, espinafres, brócolos) e de álcool.\nNão tome anti-inflamatórios (AINE) sem orientação médica — aumentam o risco de hemorragia.\nSe tiver cirurgia ou extração dentária, avise que toma varfarina.',
  precautions_en = E'Requires regular blood tests (INR) to adjust the dose; never change the dose on your own.\nTell your doctor about all medicines, supplements and herbal products you take — many change the effect of warfarin.\nAvoid sudden changes in foods rich in vitamin K (e.g. leafy greens, broccoli) and in alcohol intake.\nDo not take anti-inflammatory drugs (NSAIDs) without medical advice — they increase the bleeding risk.\nIf you need surgery or a dental extraction, tell the team you take warfarin.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)',
  updated_at = now()
FROM public.drugs d
WHERE d.id = drug_profiles.drug_id AND d.slug = 'warfarina';

-- ---------------------------------------------------------------------
-- IBUPROFENO
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles
SET
  indications_pt = E'Alívio da dor ligeira a moderada: cefaleia, dores musculares, dor de dentes, dores das costas e dores menstruais.\nAlívio da dor ligeira da artrose e das dores associadas a constipações.\nRedução da febre.',
  indications_en = E'Relief of mild to moderate pain: headache, muscle aches, toothache, back pain and menstrual pain.\nRelief of mild arthritic pain and of aches associated with the common cold.\nReduction of fever.',
  side_effects_pt = E'Irritação do estômago, azia, náuseas ou desconforto abdominal.\nDor de cabeça, tonturas ou sonolência.\nAumento da tensão arterial e retenção de líquidos (inchaço).\nRisco de hemorragia gastrointestinal, sobretudo em idosos ou com uso prolongado.\nProcure ajuda imediata se tiver fezes escuras, vómitos com sangue, dor no peito, dificuldade em respirar ou fraqueza súbita.',
  side_effects_en = E'Stomach irritation, heartburn, nausea or abdominal discomfort.\nHeadache, dizziness or drowsiness.\nRaised blood pressure and fluid retention (swelling).\nRisk of gastrointestinal bleeding, especially in older people or with long-term use.\nSeek immediate help if you have dark stools, vomiting blood, chest pain, trouble breathing or sudden weakness.',
  precautions_pt = E'Tome a menor dose eficaz durante o menor tempo possível.\nNão combine com outros anti-inflamatórios (incluindo aspirina em doses altas) sem orientação médica.\nEvite em doentes com úlcera gástrica, hemorragia digestiva prévia ou doença renal/cardiovascular significativa — fale primeiro com o médico.\nNão tome nas 3 semanas antes ou depois de cirurgia cardíaca.\nCom varfarina ou outros anticoagulantes/antiagregantes, só com indicação médica.',
  precautions_en = E'Take the lowest effective dose for the shortest possible time.\nDo not combine with other anti-inflammatories (including high-dose aspirin) without medical advice.\nAvoid in patients with gastric ulcer, previous digestive bleeding or significant kidney/cardiovascular disease — talk to your doctor first.\nDo not take in the 3 weeks before or after heart surgery.\nWith warfarin or other anticoagulants/antiplatelets, only on medical advice.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)',
  updated_at = now()
FROM public.drugs d
WHERE d.id = drug_profiles.drug_id AND d.slug = 'ibuprofeno';

-- ---------------------------------------------------------------------
-- RAMIPRIL
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles
SET
  indications_pt = E'Tratamento da hipertensão arterial (isolado ou em associação com diuréticos tiazídicos).\nRedução do risco de enfarte do miocárdio, acidente vascular cerebral e morte cardiovascular em doentes com 55 anos ou mais com doença arterial coronária, AVC, doença vascular periférica ou diabetes com fator de risco cardiovascular adicional.\nTratamento da insuficiência cardíaca após enfarte do miocárdio.',
  indications_en = E'Treatment of high blood pressure (alone or with thiazide diuretics).\nReduction of the risk of myocardial infarction, stroke and cardiovascular death in patients aged 55 or over with coronary artery disease, stroke, peripheral vascular disease, or diabetes plus an additional cardiovascular risk factor.\nTreatment of heart failure after myocardial infarction.',
  side_effects_pt = E'Tosse seca persistente (o efeito secundário mais característico dos IECA).\nTonturas, sobretudo ao levantar (hipotensão), especialmente nas primeiras semanas.\nFadiga, dor de cabeça ou náuseas.\nAumento do potássio no sangue (hipercaliemia) — vigiado com análises.\nProcure ajuda imediata se tiver inchaço da face, lábios ou língua (angioedema) ou dificuldade em respirar.',
  side_effects_en = E'Persistent dry cough (the most characteristic ACE-inhibitor side effect).\nDizziness, especially when standing up (hypotension), particularly in the early weeks.\nFatigue, headache or nausea.\nRaised blood potassium (hyperkalaemia) — monitored with blood tests.\nSeek immediate help if you have swelling of the face, lips or tongue (angioedema) or trouble breathing.',
  precautions_pt = E'Não usar na gravidez (risco fetal) — use contraceção adequada e informe o médico se engravidar.\nEvitar a associação com outros fármacos que aumentam o potássio (ex.: espironolactona, suplementos de potássio) sem vigilância médica.\nInforme o médico se toma diuréticos ou anti-inflamatórios — o efeito na tensão arterial e nos rins precisa de vigilância.\nSe tiver histórico de angioedema ou alergia a IECA, não deve tomar ramipril.',
  precautions_en = E'Do not use in pregnancy (fetal risk) — use adequate contraception and tell your doctor if you become pregnant.\nAvoid combining with other drugs that raise potassium (e.g. spironolactone, potassium supplements) without medical supervision.\nTell your doctor if you take diuretics or anti-inflammatories — effects on blood pressure and kidneys need monitoring.\nIf you have a history of angioedema or ACE-inhibitor allergy, do not take ramipril.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ramipril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3806abdc-6aec-4252-bd79-e2c115b849aa — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Ramipril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3806abdc-6aec-4252-bd79-e2c115b849aa — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)',
  updated_at = now()
FROM public.drugs d
WHERE d.id = drug_profiles.drug_id AND d.slug = 'ramipril';

-- ---------------------------------------------------------------------
-- ESPIRONOLACTONA
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles
SET
  indications_pt = E'Tratamento da insuficiência cardíaca (NYHA classe III-IV com fração de ejeção reduzida) para aumentar a sobrevivência, controlar o edema e reduzir hospitalizações.\nTratamento da hipertensão arterial como terapêutica adicional em doentes não controlados com outros fármacos.\nTratamento do edema associado a cirrose hepática ou síndrome nefrótica.',
  indications_en = E'Treatment of heart failure (NYHA class III-IV with reduced ejection fraction) to increase survival, manage oedema and reduce hospitalisations.\nTreatment of high blood pressure as add-on therapy in patients not controlled on other agents.\nTreatment of oedema associated with liver cirrhosis or nephrotic syndrome.',
  side_effects_pt = E'Aumento do potássio no sangue (hipercaliemia) — o efeito adverso mais importante; vigiado com análises.\nGinecomastia (aumento do peito nos homens), geralmente reversível e dependente da dose.\nTonturas, sonolência, dor de cabeça ou cãibras nas pernas.\nAlterações menstruais, redução da libido ou dificuldade de ereção.\nNáuseas, vómitos, diarreia ou desconforto abdominal.',
  side_effects_en = E'Raised blood potassium (hyperkalaemia) — the most important adverse effect; monitored with blood tests.\nGynaecomastia (breast enlargement in men), usually reversible and dose-dependent.\nDizziness, drowsiness, headache or leg cramps.\nMenstrual irregularities, reduced libido or erectile difficulty.\nNausea, vomiting, diarrhoea or abdominal discomfort.',
  precautions_pt = E'Não usar se tiver potássio elevado no sangue ou doença de Addison.\nEvite suplementos de potássio e substitutos de sal com potássio durante o tratamento.\nRequer análises regulares (potássio e função renal), especialmente ao iniciar ou ajustar a dose.\nInforme o médico se toma IECA/ARA II, AINE, lítio ou digoxina.',
  precautions_en = E'Do not use if you have high blood potassium or Addison\'s disease.\nAvoid potassium supplements and potassium-containing salt substitutes during treatment.\nRequires regular blood tests (potassium and kidney function), especially when starting or adjusting the dose.\nTell your doctor if you take ACE inhibitors/ARBs, NSAIDs, lithium or digoxin.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Espironolactona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57d1c333-c229-54aa-e063-6394a90a84ce — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Spironolactone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57d1c333-c229-54aa-e063-6394a90a84ce — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)',
  updated_at = now()
FROM public.drugs d
WHERE d.id = drug_profiles.drug_id AND d.slug = 'espironolactona';

-- ---------------------------------------------------------------------
-- SOTALOL
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles
SET
  indications_pt = E'Tratamento de arritmias ventriculares graves documentadas (ex.: taquicardia ventricular sustentada).\nManutenção do ritmo sinusal normal (atraso da recorrência) em doentes com fibrilhação/flutter auricular muito sintomáticos.\nNota: não demonstrou aumentar a sobrevivência; reservado para casos selecionados, sob supervisão especializada.',
  indications_en = E'Treatment of documented, life-threatening ventricular arrhythmias (e.g. sustained ventricular tachycardia).\nMaintenance of normal sinus rhythm (delay of recurrence) in highly symptomatic patients with atrial fibrillation/flutter.\nNote: not shown to increase survival; reserved for selected cases under specialist supervision.',
  side_effects_pt = E'Batimento cardíaco lento (bradicardia), cansaço e fraqueza.\nTonturas, dor de cabeça ou falta de ar.\nNáuseas, vómitos ou diarreia.\nAlterações do ritmo cardíaco (proarrítmia, incluindo torsades de pointes) — mais frequentes com potássio baixo ou doses elevadas.\nProcure ajuda imediata se tiver desmaios, palpitações fortes, falta de ar súbita ou dor no peito.',
  side_effects_en = E'Slow heart rate (bradycardia), fatigue and weakness.\nDizziness, headache or shortness of breath.\nNausea, vomiting or diarrhoea.\nHeart rhythm disturbances (proarrhythmia, including torsades de pointes) — more likely with low potassium or high doses.\nSeek immediate help if you faint, have strong palpitations, sudden shortness of breath or chest pain.',
  precautions_pt = E'O início e os aumentos de dose fazem-se habitualmente em meio hospitalar, com monitorização contínua do ECG.\nNão suspender bruscamente (risco de angina ou enfarte) — a redução é gradual, sob orientação médica.\nRequer potássio e magnésio normais antes de iniciar; análises regulares durante o tratamento.\nEvitar outros fármacos que prolongam o intervalo QT (ex.: amiodarona, certos antibióticos) sem orientação médica.\nContraindicado em asma ou doença broncospástica, bloqueio AV avançado e certas síndromes de QT longo.',
  precautions_en = E'Initiation and dose increases are usually done in hospital with continuous ECG monitoring.\nDo not stop abruptly (risk of angina or heart attack) — withdrawal is gradual, under medical guidance.\nRequires normal potassium and magnesium before starting; regular blood tests during treatment.\nAvoid other QT-prolonging drugs (e.g. amiodarone, certain antibiotics) without medical advice.\nContraindicated in asthma or bronchospastic disease, high-degree AV block and certain long-QT syndromes.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sotalol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9a36d95c-6e93-4e57-befe-b5274f359244 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Sotalol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9a36d95c-6e93-4e57-befe-b5274f359244 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)',
  updated_at = now()
FROM public.drugs d
WHERE d.id = drug_profiles.drug_id AND d.slug = 'sotalol';
