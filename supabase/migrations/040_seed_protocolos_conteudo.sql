-- 040: Seed de conteúdo editorial para os protocolos clínicos
-- Conteúdo real (PT/EN) para os 5 protocolos que entraram como cards na 039:
--   ITU recorrente · DM2 início terapêutico · Desidratação <5 anos ·
--   Ansiedade generalizada · Notificação de RAM
-- + badges de recomendação/evidência nos passos cuja classificação é
--   consensual nas principais normas (OMS, ADA, NICE, EAU) — editáveis
--   no Admin (ProtocolContentForm).
-- Aplica-se por slug (INSERT...SELECT), portanto funciona quer a 039 já
-- tenha sido aplicada quer as duas corram em conjunto.

DO $$
DECLARE
  it_id  UUID;
  dm_id  UUID;
  des_id UUID;
  anx_id UUID;
  ram_id UUID;
BEGIN
  SELECT id INTO it_id  FROM public.clinical_protocols WHERE slug = 'infeccao-urinaria-recorrente-adulto';
  SELECT id INTO dm_id  FROM public.clinical_protocols WHERE slug = 'diabetes-tipo-2-inicio-terapeutico';
  SELECT id INTO des_id FROM public.clinical_protocols WHERE slug = 'desidratacao-aguda-menores-5-anos';
  SELECT id INTO anx_id FROM public.clinical_protocols WHERE slug = 'ansiedade-generalizada-cuidados-primarios';
  SELECT id INTO ram_id FROM public.clinical_protocols WHERE slug = 'notificacao-reaccao-adversa';

  -- ============================================================
  -- 1) INFECÇÃO URINÁRIA RECORRENTE — ADULTO
  -- ============================================================
  UPDATE public.clinical_protocols SET
    summary_pt = 'Adulto com ITU de repetição (≥2 ITU não complicadas em 6 meses ou ≥3 em 12 meses). Acção: confirmar o diagnóstico com urinálise e urocultura antes de tratar, excluir causas tratáveis e esgotar as medidas não-antibióticas antes de propor profilaxia.',
    summary_en = 'Adult with recurrent UTI (≥2 uncomplicated UTIs in 6 months or ≥3 in 12 months). Action: confirm the diagnosis with urinalysis and urine culture before treating, exclude treatable causes and exhaust non-antibiotic measures before proposing prophylaxis.',
    safety_notes_pt = 'A profilaxia antibiótica prolongada é decisão médica e deve ser revista a cada 6–12 meses. Nitrofurantoína está contra-indicada se eGFR < 30 mL/min. Não usar profilaxia antibiótica em grávidas sem orientação especializada.',
    safety_notes_en = 'Long-term antibiotic prophylaxis is a medical decision and should be reviewed every 6–12 months. Nitrofurantoin is contraindicated when eGFR < 30 mL/min. Do not use antibiotic prophylaxis in pregnancy without specialist guidance.',
    red_flags_pt = 'Febre alta com calafrios, dor lombar ou náuseas → suspeitar pielonefrite e referenciar. Hematúria macroscópica, dor pélvica ou ITU no homem → investigar causa urológica/estrutural. Recorrência persistente apesar de profilaxia → reavaliar.',
    red_flags_en = 'High fever with chills, flank pain or nausea → suspect pyelonephritis and refer. Macroscopic haematuria, pelvic pain or UTI in men → investigate urological/structural causes. Persisting recurrence despite prophylaxis → reassess.',
    source_pt = 'Norma DGS — Infeção Urinária: Diagnóstico e Terapêutica em Cuidados de Saúde Primários',
    source_en = 'DGS Guideline — Urinary Tract Infection: Diagnosis and Treatment in Primary Care',
    source_url = 'https://uroweb.org/guidelines/urological-infections',
    updated_at = '2026-03-01 10:00:00+00'
  WHERE id = it_id;

  INSERT INTO public.clinical_protocol_steps
    (protocol_id, label_pt, label_en, title_pt, title_en, body_pt, body_en,
     recommendation, evidence, drugs, status, sort_order) VALUES
  (it_id, 'Confirmar', 'Confirm',
   'Confirmar o diagnóstico', 'Confirm the diagnosis',
   'Recorrência: ≥2 ITU não complicadas em 6 meses ou ≥3 em 12 meses. Confirmar com urinálise (nitritos, leucócitos) e urocultura antes de iniciar antibiótico. Sem urocultura não se assume recorrência bacteriana.',
   'Recurrence: ≥2 uncomplicated UTIs in 6 months or ≥3 in 12 months. Confirm with urinalysis (nitrites, leucocytes) and urine culture before starting an antibiotic. Without culture, bacterial recurrence cannot be assumed.',
   'conditional', 'moderate',
   '[{"label_pt":"Urinálise + urocultura","label_en":"Urinalysis + urine culture"}]', 'published', 1),
  (it_id, 'Excluir', 'Exclude',
   'Causas e factores de risco', 'Causes and risk factors',
   'Relação sexual, espermicidas, obstrução urinária, diabetes descompensada, menopausa. ITU no homem, hematúria ou recorrência persistente: pensar em causa urológica e referenciar.',
   'Sexual intercourse, spermicides, urinary obstruction, decompensated diabetes, menopause. UTI in men, haematuria or persistent recurrence: consider a urological cause and refer.',
   NULL, NULL,
   '[]', 'published', 2),
  (it_id, 'Intervir', 'Intervene',
   'Medidas não-antibióticas', 'Non-antibiotic measures',
   'Hidratação adequada, micção após o coito e hábitos de higiene. D-manose 2 g/dia ou extrato de cranberry podem reduzir recorrências. Estrogénio vaginal tópico na pós-menopausa (decisão médica).',
   'Adequate hydration, post-coital voiding and hygiene habits. D-mannose 2 g/day or cranberry extract may reduce recurrence. Topical vaginal oestrogen in post-menopause (medical decision).',
   'conditional', 'moderate',
   '[{"label_pt":"D-manose","label_en":"D-mannose","dose":"2 g/dia"},{"label_pt":"Cranberry","label_en":"Cranberry","dose":"36 mg PAC/dia"}]', 'published', 3),
  (it_id, 'Profilaxia', 'Prophylaxis',
   'Profilaxia antibiótica (prescrição médica)', 'Antibiotic prophylaxis (medical prescription)',
   'Se as recorrências continuam apesar das medidas não-antibióticas: profilaxia contínua (ex. nitrofurantoína 50 mg/dia ou trimetoprim) ou pós-coito, durante 6–12 meses. Rever periodicamente a indicação.',
   'If recurrences continue despite non-antibiotic measures: continuous prophylaxis (e.g. nitrofurantoin 50 mg/day or trimethoprim) or post-coital, for 6–12 months. Review the indication periodically.',
   'conditional', 'moderate',
   '[{"label_pt":"Nitrofurantoína","label_en":"Nitrofurantoin","dose":"50 mg/dia (profilaxia)"},{"label_pt":"Trimetoprim","label_en":"Trimethoprim","dose":"100 mg/dia (profilaxia)"}]', 'published', 4);

  INSERT INTO public.clinical_protocol_references (protocol_id, title_pt, title_en, url, status, sort_order) VALUES
    (it_id, 'EAU — Infeções Urológicas', 'EAU — Urological Infections', 'https://uroweb.org/guidelines/urological-infections', 'published', 1),
    (it_id, 'ESCMID — Posição sobre ITU de repetição', 'ESCMID — Position on recurrent UTI', 'https://www.escmid.org', 'published', 2),
    (it_id, 'Infarmed — Características do Medicamento', 'Infarmed — Summary of Product Characteristics', 'https://www.infarmed.pt', 'published', 3);

  INSERT INTO public.clinical_protocol_quizzes
    (protocol_id, question_pt, question_en, option_a_pt, option_a_en, option_b_pt, option_b_en,
     option_c_pt, option_c_en, option_d_pt, option_d_en, correct_index, explanation_pt, explanation_en, status, sort_order) VALUES
  (it_id,
   'Qual é o critério de ITU de repetição no adulto?',
   'What defines recurrent UTI in adults?',
   '≥2 ITU não complicadas em 6 meses ou ≥3 em 12 meses', '≥2 uncomplicated UTIs in 6 months or ≥3 in 12 months',
   'Qualquer episódio único por ano', 'Any single episode per year',
   '≥5 episódios num mês', '≥5 episodes in one month',
   'Qualquer ITU no homem', 'Any UTI in men',
   0,
   'Define-se ITU de repetição como ≥2 ITU não complicadas em 6 meses ou ≥3 em 12 meses.',
   'Recurrent UTI is defined as ≥2 uncomplicated UTIs in 6 months or ≥3 in 12 months.',
   'published', 1),
  (it_id,
   'Que exames confirmam a ITU antes do antibiótico na recorrência?',
   'Which tests confirm a UTI before antibiotics in recurrence?',
   'Glicemia em jejum e ECG', 'Fasting glucose and ECG',
   'Urinálise e urocultura', 'Urinalysis and urine culture',
   'Raio-X do tórax', 'Chest X-ray',
   'Nenhum — trata-se empiricamente', 'None — treat empirically',
   1,
   'A urinálise (nitritos, leucócitos) e a urocultura confirmam a infecção bacteriana antes de iniciar antibiótico.',
   'Urinalysis (nitrites, leucocytes) and urine culture confirm bacterial infection before starting an antibiotic.',
   'published', 2),
  (it_id,
   'Qual é a dose habitual de nitrofurantoína em profilaxia contínua?',
   'What is the usual nitrofurantoin dose for continuous prophylaxis?',
   '400 mg/dia', '400 mg/day',
   '20 mg/dia', '20 mg/day',
   '50 mg/dia', '50 mg/day',
   '500 mg/dia', '500 mg/day',
   2,
   'A profilaxia contínua com nitrofurantoína usa tipicamente 50 mg/dia, por prescrição médica, durante 6–12 meses.',
   'Continuous prophylaxis with nitrofurantoin typically uses 50 mg/day, by medical prescription, for 6–12 months.',
   'published', 3);

  -- ============================================================
  -- 2) DIABETES TIPO 2 — INÍCIO TERAPÊUTICO
  -- ============================================================
  UPDATE public.clinical_protocols SET
    summary_pt = 'Doente com DM2 e HbA1c acima do alvo. Acção: avaliar o perfil (função renal, idade, risco de hipoglicémia, doença cardiovascular), iniciar metformina como primeira linha salvo contra-indicação e adicionar um segundo agente dirigido se o alvo não for atingido.',
    summary_en = 'Patient with type 2 diabetes and HbA1c above target. Action: assess the profile (renal function, age, hypoglycaemia risk, cardiovascular disease), start metformin as first line unless contraindicated and add a targeted second agent if the target is not reached.',
    safety_notes_pt = 'Metformina: suspender se eGFR < 30 mL/min e usar com precaução entre 30–45. Sulfonilureias e insulina aumentam o risco de hipoglicémia — educar o doente para os sinais de alerta. iSGLT2 e iGLP1 não estão recomendados na gravidez.',
    safety_notes_en = 'Metformin: stop if eGFR < 30 mL/min and use with caution between 30–45. Sulphonylureas and insulin increase the risk of hypoglycaemia — teach the patient the warning signs. SGLT2i and GLP1-RA are not recommended in pregnancy.',
    red_flags_pt = 'Cetoacidose (náuseas, vómitos, dor abdominal, respiração de Kussmaul), hipoglicémia grave com alteração de consciência, úlcera do pé diabético ou perda de visão → encaminhar de imediato.',
    red_flags_en = 'Ketoacidosis (nausea, vomiting, abdominal pain, Kussmaul breathing), severe hypoglycaemia with altered consciousness, diabetic foot ulcer or vision loss → refer immediately.',
    source_pt = 'Norma DGS — Abordagem Terapêutica da Diabetes Mellitus Tipo 2',
    source_en = 'DGS Guideline — Therapeutic Approach to Type 2 Diabetes Mellitus',
    source_url = 'https://diabetesjournals.org/care',
    updated_at = '2026-02-01 10:00:00+00'
  WHERE id = dm_id;

  INSERT INTO public.clinical_protocol_steps
    (protocol_id, label_pt, label_en, title_pt, title_en, body_pt, body_en,
     recommendation, evidence, drugs, status, sort_order) VALUES
  (dm_id, 'Avaliar', 'Assess',
   'Perfil do doente e alvo terapêutico', 'Patient profile and therapeutic target',
   'HbA1c alvo (habitualmente <7%, individualizar), função renal (eGFR), IMC, história de doença cardiovascular, risco de hipoglicémia e preferências do doente.',
   'Target HbA1c (usually <7%, individualised), renal function (eGFR), BMI, history of cardiovascular disease, hypoglycaemia risk and patient preferences.',
   NULL, NULL,
   '[{"label_pt":"HbA1c","label_en":"HbA1c"}]', 'published', 1),
  (dm_id, 'Iniciar', 'Initiate',
   'Metformina em primeira linha', 'Metformin as first line',
   'Salvo contra-indicação, iniciar metformina e titular gradualmente (500–2000 mg/dia) para reduzir efeitos gastrointestinais. Rever função renal antes de iniciar.',
   'Unless contraindicated, start metformin and titrate gradually (500–2000 mg/day) to reduce gastrointestinal effects. Check renal function before starting.',
   'strong', 'high',
   '[{"label_pt":"Metformina","label_en":"Metformin","dose":"500–2000 mg/dia"}]', 'published', 2),
  (dm_id, 'Adicionar', 'Add',
   'Segundo agente dirigido', 'Targeted second agent',
   'Se HbA1c acima do alvo após 3 meses (ou HbA1c muito elevada à apresentação): iSGLT2 ou iGLP1 em doentes com doença cardiovascular ou alto risco; sulfonilureia ou iDPP4 conforme o perfil e o custo.',
   'If HbA1c remains above target after 3 months (or very high at presentation): SGLT2i or GLP1-RA in patients with cardiovascular disease or high risk; sulphonylurea or DPP4i depending on profile and cost.',
   'strong', 'high',
   '[{"label_pt":"iSGLT2","label_en":"SGLT2i","dose":"conforme fármaco"},{"label_pt":"iGLP1","label_en":"GLP1-RA","dose":"conforme fármaco"}]', 'published', 3),
  (dm_id, 'Monitorizar', 'Monitor',
   'Reavaliação e educação', 'Reassessment and education',
   'Rever HbA1c e adesão a cada 3 meses. Educar sobre sinais de hipoglicémia, revisão anual do pé, vigilância da retina e vacinação.',
   'Review HbA1c and adherence every 3 months. Teach hypoglycaemia signs, annual foot review, retinal surveillance and vaccination.',
   NULL, NULL,
   '[{"label_pt":"Glicemia capilar","label_en":"Capillary glucose"}]', 'published', 4);

  INSERT INTO public.clinical_protocol_references (protocol_id, title_pt, title_en, url, status, sort_order) VALUES
    (dm_id, 'ADA — Standards of Care in Diabetes', 'ADA — Standards of Care in Diabetes', 'https://diabetesjournals.org/care', 'published', 1),
    (dm_id, 'Norma DGS — Diabetes Mellitus', 'DGS Guideline — Diabetes Mellitus', 'https://www.dgs.pt', 'published', 2),
    (dm_id, 'Infarmed — Antidiabéticos', 'Infarmed — Antidiabetic medicines', 'https://www.infarmed.pt', 'published', 3);

  INSERT INTO public.clinical_protocol_quizzes
    (protocol_id, question_pt, question_en, option_a_pt, option_a_en, option_b_pt, option_b_en,
     option_c_pt, option_c_en, option_d_pt, option_d_en, correct_index, explanation_pt, explanation_en, status, sort_order) VALUES
  (dm_id,
   'Qual é o antidiabético de primeira linha na DM2, salvo contra-indicação?',
   'Which antidiabetic is first line in type 2 diabetes, unless contraindicated?',
   'Metformina', 'Metformin',
   'Insulina glargina', 'Insulin glargine',
   'Glibenclamida', 'Glibenclamide',
   'Sitagliptina', 'Sitagliptin',
   0,
   'A metformina é a primeira linha na DM2, com titulação gradual para reduzir efeitos gastrointestinais.',
   'Metformin is first line in type 2 diabetes, titrated gradually to reduce gastrointestinal effects.',
   'published', 1),
  (dm_id,
   'Em que doentes se preferem iSGLT2/iGLP1 como segundo agente?',
   'In which patients are SGLT2i/GLP1-RA preferred as second agent?',
   'Apenas em doentes jovens', 'Only in young patients',
   'Doença cardiovascular ou alto risco', 'Cardiovascular disease or high risk',
   'Em todas as grávidas', 'In all pregnant women',
   'Nunca — usar sempre sulfonilureia', 'Never — always use a sulphonylurea',
   1,
   'Os iSGLT2 e iGLP1 estão recomendados em doentes com doença cardiovascular ou de alto risco cardiovascular.',
   'SGLT2i and GLP1-RA are recommended in patients with cardiovascular disease or high cardiovascular risk.',
   'published', 2),
  (dm_id,
   'Com que frequência se reavalia a HbA1c após iniciar tratamento?',
   'How often is HbA1c reassessed after starting treatment?',
   'Uma vez por ano', 'Once a year',
   'A cada 5 anos', 'Every 5 years',
   'A cada 3 meses até atingir o alvo', 'Every 3 months until the target is reached',
   'Nunca — medir apenas sintomas', 'Never — measure symptoms only',
   2,
   'A HbA1c é reavaliada a cada 3 meses até atingir o alvo, juntamente com a adesão.',
   'HbA1c is reassessed every 3 months until the target is reached, together with adherence.',
   'published', 3);

  -- ============================================================
  -- 3) DESIDRATAÇÃO AGUDA — MENORES DE 5 ANOS
  -- ============================================================
  UPDATE public.clinical_protocols SET
    summary_pt = 'Criança <5 anos com diarreia ou vómitos. Acção: avaliar a gravidade (Planos A/B/C da OMS), reidratar por via oral com soro de rehidratação oral (SRO) em pequenos volumes frequentes, manter o aleitamento e referenciar se houver sinais de perigo.',
    summary_en = 'Child under 5 with diarrhoea or vomiting. Action: assess severity (WHO Plans A/B/C), rehydrate orally with oral rehydration salts (ORS) in frequent small volumes, maintain breastfeeding and refer if danger signs are present.',
    safety_notes_pt = 'Usar SRO (hiposódica) e nunca água pura ou refrigerantes. Oferecer em pequenos volumes frequentes com colher/chávena. Não suspender o aleitamento materno. Zinco 10–20 mg/dia durante 10–14 dias reduz a duração da diarreia (se recomendação local).',
    safety_notes_en = 'Use ORS (hypo-osmolar) and never plain water or soft drinks. Offer frequent small volumes with a spoon/cup. Do not stop breastfeeding. Zinc 10–20 mg/day for 10–14 days shortens diarrhoea duration (if locally recommended).',
    red_flags_pt = 'Letargia, olhos fundos, prega cutânea que volta muito lentamente, ausência de lágrimas, boca e língua secas, incapacidade de beber → desidratação grave (Plano C): referenciar de imediato para reidratação IV.',
    red_flags_en = 'Lethargy, sunken eyes, skin pinch returning very slowly, no tears, dry mouth and tongue, inability to drink → severe dehydration (Plan C): refer immediately for IV rehydration.',
    source_pt = 'OMS — Tratamento da Diarreia: Plano A, B e C',
    source_en = 'WHO — Treatment of Diarrhoea: Plans A, B and C',
    source_url = 'https://www.who.int',
    updated_at = '2025-11-01 10:00:00+00'
  WHERE id = des_id;

  INSERT INTO public.clinical_protocol_steps
    (protocol_id, label_pt, label_en, title_pt, title_en, body_pt, body_en,
     recommendation, evidence, drugs, status, sort_order) VALUES
  (des_id, 'Avaliar', 'Assess',
   'Determinar o plano (OMS A/B/C)', 'Determine the plan (WHO A/B/C)',
   'Avaliar: estado geral, olhos fundos, prega cutânea, lágrimas, boca/língua e sede. Plano A (sem desidratação), Plano B (ligeira a moderada), Plano C (grave).',
   'Assess: general state, sunken eyes, skin pinch, tears, mouth/tongue and thirst. Plan A (no dehydration), Plan B (mild to moderate), Plan C (severe).',
   'strong', 'high',
   '[]', 'published', 1),
  (des_id, 'Plano B', 'Plan B',
   'Reidratação oral com SRO', 'Oral rehydration with ORS',
   'Administrar SRO 75 mL/kg em pequenos volumes frequentes durante 4 horas (colher/chávena, a cada 5–10 minutos). Reavaliar a criança durante a reidratação e ensinar a mãe/pai a continuar em casa.',
   'Give ORS 75 mL/kg in frequent small volumes over 4 hours (spoon/cup, every 5–10 minutes). Reassess the child during rehydration and teach the mother/father to continue at home.',
   'strong', 'high',
   '[{"label_pt":"SRO","label_en":"ORS","dose":"75 mL/kg em 4h"}]', 'published', 2),
  (des_id, 'Manter', 'Maintain',
   'Continuar aleitamento e alimentação', 'Maintain breastfeeding and feeding',
   'Manter o aleitamento materno e reiniciar a dieta habitual assim que possível. Zinco 10–20 mg/dia durante 10–14 dias reduz a duração e a gravidade da diarreia.',
   'Maintain breastfeeding and restart the usual diet as soon as possible. Zinc 10–20 mg/day for 10–14 days reduces the duration and severity of diarrhoea.',
   'strong', 'moderate',
   '[{"label_pt":"Zinco","label_en":"Zinc","dose":"10–20 mg/dia (10–14 dias)"}]', 'published', 3),
  (des_id, 'Referenciar', 'Refer',
   'Plano C — desidratação grave', 'Plan C — severe dehydration',
   'Criança que não consegue beber, letárgica ou com prega cutânea que volta muito lentamente: referenciação imediata para reidratação IV. Reavaliar na comunidade após a alta.',
   'A child who cannot drink, is lethargic or has a skin pinch returning very slowly: immediate referral for IV rehydration. Reassess in the community after discharge.',
   'strong', 'high',
   '[]', 'published', 4);

  INSERT INTO public.clinical_protocol_references (protocol_id, title_pt, title_en, url, status, sort_order) VALUES
    (des_id, 'OMS — Diarreia: tratamento e reidratação', 'WHO — Diarrhoea: treatment and rehydration', 'https://www.who.int', 'published', 1),
    (des_id, 'UNICEF — Kit de SRO e zinco', 'UNICEF — ORS and zinc kit', 'https://www.unicef.org', 'published', 2),
    (des_id, 'Norma DGS — Saúde Infantil e Juvenil', 'DGS Guideline — Child and Adolescent Health', 'https://www.dgs.pt', 'published', 3);

  INSERT INTO public.clinical_protocol_quizzes
    (protocol_id, question_pt, question_en, option_a_pt, option_a_en, option_b_pt, option_b_en,
     option_c_pt, option_c_en, option_d_pt, option_d_en, correct_index, explanation_pt, explanation_en, status, sort_order) VALUES
  (des_id,
   'Quantos mL/kg de SRO se administram no Plano B em 4 horas?',
   'How many mL/kg of ORS are given in Plan B over 4 hours?',
   '75 mL/kg', '75 mL/kg',
   '10 mL/kg', '10 mL/kg',
   '200 mL/kg', '200 mL/kg',
   '5 mL/kg', '5 mL/kg',
   0,
   'No Plano B administram-se 75 mL/kg de SRO em pequenos volumes frequentes durante 4 horas.',
   'In Plan B, 75 mL/kg of ORS is given in frequent small volumes over 4 hours.',
   'published', 1),
  (des_id,
   'O que fazer perante uma criança com desidratação grave (Plano C)?',
   'What to do with a child in severe dehydration (Plan C)?',
   'Continuar apenas com aleitamento', 'Continue only with breastfeeding',
   'Referenciação imediata para reidratação IV', 'Immediate referral for IV rehydration',
   'Administrar refrigerante', 'Give soft drinks',
   'Nada — a criança recupera sozinha', 'Nothing — the child recovers alone',
   1,
   'A desidratação grave exige referenciação imediata para reidratação intravenosa.',
   'Severe dehydration requires immediate referral for intravenous rehydration.',
   'published', 2),
  (des_id,
   'Qual suplemento reduz a duração da diarreia em crianças?',
   'Which supplement shortens the duration of diarrhoea in children?',
   'Cálcio', 'Calcium',
   'Ferro', 'Iron',
   'Zinco', 'Zinc',
   'Vitamina C', 'Vitamin C',
   2,
   'O zinco (10–20 mg/dia, 10–14 dias) reduz a duração e a gravidade da diarreia aguda.',
   'Zinc (10–20 mg/day, 10–14 days) reduces the duration and severity of acute diarrhoea.',
   'published', 3);

  -- ============================================================
  -- 4) ANSIEDADE GENERALIZADA — CUIDADOS PRIMÁRIOS
  -- ============================================================
  UPDATE public.clinical_protocols SET
    summary_pt = 'Doente com ansiedade e preocupação persistentes. Acção: confirmar os critérios de perturbação de ansiedade generalizada (TAG), explicar o ciclo da ansiedade, começar por intervenções não-farmacológicas e evitar benzodiazepinas de longa duração; referenciar se risco de suicídio ou comorbilidade.',
    summary_en = 'Patient with persistent anxiety and worry. Action: confirm the criteria for generalised anxiety disorder (GAD), explain the anxiety cycle, start with non-pharmacological interventions and avoid long-term benzodiazepines; refer if suicide risk or comorbidity.',
    safety_notes_pt = 'Benzodiazepinas apenas a curto prazo (≤4 semanas) e por prescrição médica, com descontinuação gradual. Evitar em idosos (risco de quedas e confusão). ISRS exigem titulação lenta e aviso de agravamento transitório no início.',
    safety_notes_en = 'Benzodiazepines only short term (≤4 weeks) and by medical prescription, with gradual discontinuation. Avoid in older people (risk of falls and confusion). SSRIs require slow titration and a warning about transient worsening at the start.',
    red_flags_pt = 'Ideação suicida, ataques de pânico com sintomas cardiovasculares, sintomas psicóticos, consumo de álcool ou substâncias, incapacidade funcional grave → referenciação prioritária.',
    red_flags_en = 'Suicidal ideation, panic attacks with cardiovascular symptoms, psychotic symptoms, alcohol or substance use, severe functional impairment → priority referral.',
    source_pt = 'NICE CG113 — Perturbação de Ansiedade Generalizada',
    source_en = 'NICE CG113 — Generalised Anxiety Disorder',
    source_url = 'https://www.nice.org.uk/guidance/cg113',
    updated_at = '2025-09-01 10:00:00+00'
  WHERE id = anx_id;

  INSERT INTO public.clinical_protocol_steps
    (protocol_id, label_pt, label_en, title_pt, title_en, body_pt, body_en,
     recommendation, evidence, drugs, status, sort_order) VALUES
  (anx_id, 'Confirmar', 'Confirm',
   'Confirmar o diagnóstico de TAG', 'Confirm the diagnosis of GAD',
   'Preocupação excessiva e ansiedade na maioria dos dias durante ≥6 meses, com ≥3 sintomas somáticos (tensão muscular, irritabilidade, insónia, fadiga, dificuldade de concentração).',
   'Excessive worry and anxiety on most days for ≥6 months, with ≥3 somatic symptoms (muscle tension, irritability, insomnia, fatigue, difficulty concentrating).',
   NULL, NULL,
   '[]', 'published', 1),
  (anx_id, 'Educar', 'Educate',
   'Explicar e intervir no estilo de vida', 'Explain and intervene on lifestyle',
   'Explicar o ciclo da ansiedade, higiene do sono, redução de cafeína e álcool, exercício regular e técnicas de respiração. Envolver a rede de apoio.',
   'Explain the anxiety cycle, sleep hygiene, reducing caffeine and alcohol, regular exercise and breathing techniques. Involve the support network.',
   NULL, NULL,
   '[{"label_pt":"Cafeína","label_en":"Caffeine","dose":"reduzir"}]', 'published', 2),
  (anx_id, 'Intervir', 'Intervene',
   'TCC e, se necessário, ISRS', 'CBT and, if needed, SSRIs',
   'Terapia cognitivo-comportamental (TCC) como primeira linha. Em sintomas moderados-graves, ISRS (ex. sertralina) por prescrição médica, com titulação lenta e aviso de efeitos iniciais.',
   'Cognitive behavioural therapy (CBT) as first line. In moderate-to-severe symptoms, SSRIs (e.g. sertraline) by medical prescription, with slow titration and warning of initial effects.',
   'strong', 'high',
   '[{"label_pt":"Sertralina","label_en":"Sertraline","dose":"50 mg/dia (titulação médica)"}]', 'published', 3),
  (anx_id, 'Acompanhar', 'Follow up',
   'Rever e descontinuar BZD', 'Review and taper benzodiazepines',
   'Rever a cada 2–4 semanas. Benzodiazepinas apenas a curto prazo (≤4 semanas) com descontinuação gradual; evitar em idosos. Reavaliar resposta ao ISRS às 4–6 semanas.',
   'Review every 2–4 weeks. Benzodiazepines only short term (≤4 weeks) with gradual tapering; avoid in older people. Reassess SSRI response at 4–6 weeks.',
   'strong', 'moderate',
   '[{"label_pt":"Benzodiazepinas","label_en":"Benzodiazepines","dose":"≤4 semanas"}]', 'published', 4);

  INSERT INTO public.clinical_protocol_references (protocol_id, title_pt, title_en, url, status, sort_order) VALUES
    (anx_id, 'NICE CG113 — Ansiedade Generalizada', 'NICE CG113 — Generalised Anxiety Disorder', 'https://www.nice.org.uk/guidance/cg113', 'published', 1),
    (anx_id, 'OMS — Saúde Mental', 'WHO — Mental Health', 'https://www.who.int', 'published', 2),
    (anx_id, 'Norma DGS — Saúde Mental', 'DGS Guideline — Mental Health', 'https://www.dgs.pt', 'published', 3);

  INSERT INTO public.clinical_protocol_quizzes
    (protocol_id, question_pt, question_en, option_a_pt, option_a_en, option_b_pt, option_b_en,
     option_c_pt, option_c_en, option_d_pt, option_d_en, correct_index, explanation_pt, explanation_en, status, sort_order) VALUES
  (anx_id,
   'Qual é a duração mínima dos sintomas para considerar TAG?',
   'What is the minimum symptom duration to consider GAD?',
   '6 meses', '6 months',
   '2 semanas', '2 weeks',
   '48 horas', '48 hours',
   '3 dias', '3 days',
   0,
   'O TAG exige ansiedade e preocupação na maioria dos dias durante pelo menos 6 meses.',
   'GAD requires anxiety and worry on most days for at least 6 months.',
   'published', 1),
  (anx_id,
   'Qual é a primeira linha não-farmacológica no TAG?',
   'What is the first-line non-pharmacological treatment in GAD?',
   'Benzodiazepinas', 'Benzodiazepines',
   'Terapia cognitivo-comportamental', 'Cognitive behavioural therapy',
   'Sertralina imediata', 'Immediate sertraline',
   'Apenas higiene do sono', 'Sleep hygiene only',
   1,
   'A terapia cognitivo-comportamental (TCC) é a primeira linha não-farmacológica recomendada.',
   'Cognitive behavioural therapy (CBT) is the recommended first-line non-pharmacological treatment.',
   'published', 2),
  (anx_id,
   'Durante quanto tempo se usam benzodiazepinas no TAG?',
   'How long are benzodiazepines used in GAD?',
   'Indefinidamente', 'Indefinitely',
   '5 anos', '5 years',
   'Máximo 4 semanas', 'Maximum 4 weeks',
   'Apenas em crianças', 'Only in children',
   2,
   'As benzodiazepinas usam-se apenas a curto prazo (≤4 semanas), com descontinuação gradual.',
   'Benzodiazepines are used only short term (≤4 weeks), with gradual discontinuation.',
   'published', 3);

  -- ============================================================
  -- 5) NOTIFICAÇÃO DE REACÇÃO ADVERSA
  -- ============================================================
  UPDATE public.clinical_protocols SET
    summary_pt = 'Suspeita de reacção adversa a medicamento (RAM). Acção: recolher os dados mínimos (doente, fármaco suspeito, reacção e cronologia), avaliar a gravidade e notificar no Portal RAM do Infarmed — mesmo sem certeza de causalidade.',
    summary_en = 'Suspected adverse drug reaction (ADR). Action: collect the minimum data (patient, suspected drug, reaction and chronology), assess severity and report on the Infarmed RAM Portal — even without certainty of causality.',
    safety_notes_pt = 'Notificar sempre que exista suspeita — não é preciso certeza de causalidade. Dados mínimos: doente identificável, fármaco suspeito, reacção e notificador com contacto. Reacções graves devem ser notificadas com urgência.',
    safety_notes_en = 'Always report when there is suspicion — certainty of causality is not required. Minimum data: identifiable patient, suspected drug, reaction and reporter with contact. Serious reactions must be reported urgently.',
    red_flags_pt = 'Reacção cutânea grave (bolhas, descamação, febre — suspeita de SJS/NET), angioedema, anafilaxia, discrasia sanguínea ou lesão hepática/renal → contacto imediato com o médico prescritor.',
    red_flags_en = 'Severe cutaneous reaction (blisters, peeling, fever — suspicion of SJS/TEN), angioedema, anaphylaxis, blood dyscrasia or hepatic/renal injury → immediate contact with the prescribing physician.',
    source_pt = 'Infarmed — Portal RAM: Notificação de Reações Adversas',
    source_en = 'Infarmed — RAM Portal: Adverse Reaction Reporting',
    source_url = 'https://www.infarmed.pt/web/infarmed/portal-ram',
    updated_at = '2026-01-01 10:00:00+00'
  WHERE id = ram_id;

  INSERT INTO public.clinical_protocol_steps
    (protocol_id, label_pt, label_en, title_pt, title_en, body_pt, body_en,
     recommendation, evidence, drugs, status, sort_order) VALUES
  (ram_id, 'Recolher', 'Collect',
   'Dados mínimos da suspeita', 'Minimum data of the suspicion',
   'Doente identificável (idade, sexo), fármaco suspeito com dose e duração, descrição da reacção, cronologia (início e evolução) e outros fármacos em uso.',
   'Identifiable patient (age, sex), suspected drug with dose and duration, description of the reaction, chronology (onset and evolution) and other drugs in use.',
   NULL, NULL,
   '[]', 'published', 1),
  (ram_id, 'Avaliar', 'Assess',
   'Gravidade e causalidade', 'Severity and causality',
   'Avaliar a gravidade (morte, perigo de vida, hospitalização, incapacidade, anomalia congénita) e a causalidade de forma simplificada: cronologia plausível, melhoria com a suspensão, reaparecimento com a reexposição.',
   'Assess severity (death, life-threatening, hospitalisation, disability, congenital anomaly) and causality in a simplified way: plausible chronology, improvement on withdrawal, recurrence on re-exposure.',
   NULL, NULL,
   '[{"label_pt":"Escala de Naranjo","label_en":"Naranjo scale","dose":"avaliação causal"}]', 'published', 2),
  (ram_id, 'Notificar', 'Report',
   'Preencher no Portal RAM', 'Complete the report on the RAM Portal',
   'Notificar no Portal RAM do Infarmed — mesmo sem certeza de causalidade. Reacções graves devem ser notificadas com urgência. Guardar o número de registo da notificação.',
   'Report on the Infarmed RAM Portal — even without certainty of causality. Serious reactions must be reported urgently. Keep the registration number of the report.',
   NULL, NULL,
   '[{"label_pt":"Portal RAM","label_en":"RAM Portal"}]', 'published', 3),
  (ram_id, 'Gerir', 'Manage',
   'Orientar o doente e o prescritor', 'Guide the patient and the prescriber',
   'Reacções graves: suspender o fármaco suspeito (com indicação médica), informar o prescritor, registar no processo e contra-indicar no futuro. Acompanhar o desfecho da reacção.',
   'Serious reactions: stop the suspected drug (with medical advice), inform the prescriber, record in the chart and contraindicate in the future. Follow up the outcome of the reaction.',
   NULL, NULL,
   '[]', 'published', 4);

  INSERT INTO public.clinical_protocol_references (protocol_id, title_pt, title_en, url, status, sort_order) VALUES
    (ram_id, 'Infarmed — Portal RAM', 'Infarmed — RAM Portal', 'https://www.infarmed.pt/web/infarmed/portal-ram', 'published', 1),
    (ram_id, 'OMS — Farmacovigilância Internacional', 'WHO — International Pharmacovigilance', 'https://www.who.int', 'published', 2),
    (ram_id, 'MedDRA — Terminologia de RAM', 'MedDRA — ADR terminology', 'https://www.meddra.org', 'published', 3);

  INSERT INTO public.clinical_protocol_quizzes
    (protocol_id, question_pt, question_en, option_a_pt, option_a_en, option_b_pt, option_b_en,
     option_c_pt, option_c_en, option_d_pt, option_d_en, correct_index, explanation_pt, explanation_en, status, sort_order) VALUES
  (ram_id,
   'Onde se notifica uma reação adversa em Portugal?',
   'Where is an adverse reaction reported in Portugal?',
   'Portal RAM do Infarmed', 'Infarmed RAM Portal',
   'No serviço de urgência', 'At the emergency department',
   'Na Segurança Social', 'At Social Security',
   'Apenas na farmácia comunitária', 'Only at the community pharmacy',
   0,
   'A notificação de RAM é feita no Portal RAM do Infarmed, mesmo sem certeza de causalidade.',
   'ADR reporting is done on the Infarmed RAM Portal, even without certainty of causality.',
   'published', 1),
  (ram_id,
   'É preciso ter certeza de causalidade para notificar uma RAM?',
   'Is certainty of causality required to report an ADR?',
   'Sim, sempre', 'Yes, always',
   'Não — a suspeita é suficiente', 'No — suspicion is enough',
   'Só nas reações graves', 'Only in serious reactions',
   'Só se o doente exigir', 'Only if the patient demands it',
   1,
   'Notifica-se por suspeita: não é necessária certeza de causalidade.',
   'Reporting is based on suspicion: certainty of causality is not required.',
   'published', 2),
  (ram_id,
   'Qual é um dado mínimo para a notificação de RAM?',
   'What is minimum data for an ADR report?',
   'Número do bilhete de identidade', 'Identity card number',
   'Receita original', 'Original prescription',
   'Doente identificável, fármaco suspeito e reacção', 'Identifiable patient, suspected drug and reaction',
   'Diagnóstico confirmado por biópsia', 'Diagnosis confirmed by biopsy',
   2,
   'Os dados mínimos são: doente identificável, fármaco suspeito, reacção e notificador com contacto.',
   'The minimum data are: identifiable patient, suspected drug, reaction and reporter with contact.',
   'published', 3);

  -- ============================================================
  -- Badges de evidência na Hipertensão AR (passo 3: espironolactona)
  -- Classificação consensual: recomendação forte, evidência moderada.
  -- ============================================================
  UPDATE public.clinical_protocol_steps SET
    recommendation = 'strong',
    evidence = 'moderate'
  WHERE protocol_id IN (SELECT id FROM public.clinical_protocols WHERE slug = 'hipertensao-arterial-resistente')
    AND sort_order = 3;

END $$;
