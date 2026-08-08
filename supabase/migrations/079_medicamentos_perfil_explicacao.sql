-- =====================================================================
-- 079 — Perfil de fármaco + resumos profissional/explicação nas interações
-- ---------------------------------------------------------------------
-- (1) drug_profiles: 1:1 com public.drugs — conteúdo editorial da página
--     dedicada por fármaco (overview público + profissional, PT/EN).
-- (2) drug_interactions: novas colunas summary_pro_*/explanation_* —
--     resumo para profissionais e explicação longa por par (o summary_*
--     existente passa a ser o resumo do público leigo).
-- Seed piloto (conteúdo autoral, ancorado nas fontes citadas):
--   - 6 perfis (warfarina, ibuprofeno, ramipril, espironolactona,
--     sotalol, furosemida) com setIDs validados nas migrações 057/063/070;
--   - INSERT do par novo warfarina × ibuprofeno (moderate) — padrão 7.4,
--     com os campos novos preenchidos (par-modelo do documento de fluxo);
--   - UPDATE (padrão 7.1, WHERE independente da ordem) dos campos novos
--     em 2 pares existentes: ramipril × espironolactona (moderate) e
--     sotalol × furosemida (critical).
-- Idempotente: reaplicar é seguro (ON CONFLICT DO NOTHING; UPDATEs re-escritos
-- com valores idênticos). Aplicar manualmente no Supabase (SQL editor).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. DDL — drug_profiles
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.drug_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id UUID NOT NULL UNIQUE REFERENCES public.drugs(id) ON DELETE CASCADE,
  overview_public_pt TEXT NOT NULL DEFAULT '',
  overview_public_en TEXT NOT NULL DEFAULT '',
  overview_pro_pt TEXT NOT NULL DEFAULT '',
  overview_pro_en TEXT NOT NULL DEFAULT '',
  source_pt TEXT NOT NULL DEFAULT '',
  source_en TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS (mesmo padrão das restantes tabelas: admin_all + anon_read)
ALTER TABLE public.drug_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_all_drug_profiles" ON public.drug_profiles
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "anon_read_drug_profiles" ON public.drug_profiles
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE TRIGGER set_drug_profiles_updated_at
  BEFORE UPDATE ON public.drug_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ---------------------------------------------------------------------
-- 2. DDL — drug_interactions (resumo profissional + explicação longa)
-- ---------------------------------------------------------------------
ALTER TABLE public.drug_interactions
  ADD COLUMN IF NOT EXISTS summary_pro_pt TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS summary_pro_en TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS explanation_pt TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS explanation_en TEXT NOT NULL DEFAULT '';

-- ---------------------------------------------------------------------
-- 3. Seed piloto — perfis de fármaco (6 fármacos)
--    Fontes: rótulos aprovados pela FDA (DailyMed/NIH/NLM), setIDs já
--    validados na API nas migrações 057/063/070.
-- ---------------------------------------------------------------------
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)
SELECT d.id, v.overview_public_pt, v.overview_public_en, v.overview_pro_pt, v.overview_pro_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('warfarina',
   'A varfarina é um medicamento anticoagulante oral — um "diluidor do sangue" — usado para prevenir e tratar coágulos nas veias, nos pulmões ou no coração. Reduz a capacidade do sangue para coagular, o que exige análises regulares (INR) para acertar a dose certa para cada pessoa.',
   'Warfarin is an oral anticoagulant — a "blood thinner" — used to prevent and treat blood clots in the veins, lungs or heart. It reduces the blood''s ability to clot, which requires regular blood tests (INR) to find the right dose for each person.',
   'Anticoagulante cumarínico antagonista da vitamina K. Indicado na profilaxia e tratamento do tromboembolismo venoso, na fibrilhação auricular e em próteses valvulares mecânicas. Janela terapêutica estreita (INR 2–3 na maioria das indicações) e múltiplas interações farmacocinéticas, alimentares e com plantas medicinais.',
   'Coumarin anticoagulant, vitamin K antagonist. Indicated for prophylaxis and treatment of venous thromboembolism, atrial fibrillation and mechanical heart valves. Narrow therapeutic window (INR 2–3 in most indications) and numerous pharmacokinetic, dietary and herbal interactions.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
   'DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057'),
  ('ibuprofeno',
   'O ibuprofeno é um anti-inflamatório não esteroide (AINE) usado para aliviar a dor, a febre e a inflamação. Está disponível sem receita, mas pode aumentar o risco de hemorragia e de problemas no estômago ou nos rins, sobretudo em tratamentos prolongados ou combinado com outros medicamentos.',
   'Ibuprofen is a non-steroidal anti-inflammatory drug (NSAID) used to relieve pain, fever and inflammation. Available without prescription, it can raise the risk of bleeding and of stomach or kidney problems, especially with long-term use or when combined with other medicines.',
   'AINE não seletivo (inibidor reversível da COX-1/COX-2). Analgésico, antipirético e anti-inflamatório de uso frequente; efeitos adversos dose-dependentes a nível gastrointestinal, renal e cardiovascular. Interações relevantes com anticoagulantes, antiagregantes, IECA/ARA II e diuréticos.',
   'Non-selective NSAID (reversible COX-1/COX-2 inhibitor). Commonly used analgesic, antipyretic and anti-inflammatory; dose-dependent gastrointestinal, renal and cardiovascular adverse effects. Relevant interactions with anticoagulants, antiplatelets, ACE inhibitors/ARBs and diuretics.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
   'DailyMed/FDA (NIH/NLM) — approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e'),
  ('ramipril',
   'O ramipril é um medicamento para a tensão arterial alta e para a insuficiência cardíaca. Pertence à classe dos inibidores da enzima de conversão (IECA) e ajuda o coração e os vasos sanguíneos a trabalharem com menos esforço. Pode provocar tosse seca e, raramente, inchaço da face (angioedema).',
   'Ramipril is a medicine for high blood pressure and heart failure. It belongs to the ACE-inhibitor class and helps the heart and blood vessels work with less effort. It can cause a dry cough and, rarely, swelling of the face (angioedema).',
   'IECA (pró-fármaco do ramiprilato). Indicado na hipertensão, na insuficiência cardíaca com fração de ejeção reduzida e após enfarte do miocárdio. Efeitos de classe: tosse seca, hipercaliemia, deterioração renal com duplo bloqueio do eixo RAAS; teratogénico (evitar na gravidez).',
   'ACE inhibitor (prodrug of ramiprilat). Indicated in hypertension, heart failure with reduced ejection fraction and after myocardial infarction. Class effects: dry cough, hyperkalaemia, renal deterioration with dual RAAS blockade; teratogenic (avoid in pregnancy).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ramipril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3806abdc-6aec-4252-bd79-e2c115b849aa',
   'DailyMed/FDA (NIH/NLM) — approved Ramipril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3806abdc-6aec-4252-bd79-e2c115b849aa'),
  ('espironolactona',
   'A espironolactona é um diurético "poupador de potássio" usado para tratar a retenção de líquidos e a insuficiência cardíaca, e também para controlar a tensão arterial. Como o nome sugere, ajuda o corpo a não perder potássio, pelo que o seu nível de potássio deve ser vigiado com análises.',
   'Spironolactone is a "potassium-sparing" diuretic used to treat fluid retention and heart failure, and also to control blood pressure. As the name suggests, it helps the body retain potassium, so your potassium level needs to be checked with blood tests.',
   'Antagonista competitivo da aldosterona (diurético poupador de potássio). Indicado na insuficiência cardíaca com fração de ejeção reduzida, hipertensão resistente, ascite e hiperaldosteronismo. Risco de hipercaliemia e ginecomastia; monitorizar potássio e função renal.',
   'Competitive aldosterone antagonist (potassium-sparing diuretic). Indicated in heart failure with reduced ejection fraction, resistant hypertension, ascites and hyperaldosteronism. Risk of hyperkalaemia and gynaecomastia; monitor potassium and renal function.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Espironolactona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57d1c333-c229-54aa-e063-6394a90a84ce',
   'DailyMed/FDA (NIH/NLM) — approved Spironolactone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=57d1c333-c229-54aa-e063-6394a90a84ce'),
  ('sotalol',
   'O sotalol é um medicamento para ritmos cardíacos irregulares (antiarrítmico). Acalma o ritmo do coração e é usado quando outros tratamentos não funcionaram. Exige monitorização médica apertada, incluindo eletrocardiogramas, porque pode alterar a condução elétrica do coração.',
   'Sotalol is a medicine for irregular heart rhythms (an antiarrhythmic). It calms the heart''s rhythm and is used when other treatments have not worked. It requires close medical monitoring, including ECGs, because it can change the heart''s electrical conduction.',
   'Antiarrítmico classe III com betabloqueio não seletivo. Prolonga o intervalo QT com risco de torsades de pointes, aumentado por hipocaliemia/hipomagnesiemia e por fármacos que prolongam o QT. Requer titulação em meio hospitalar e monitorização de ECG e eletrólitos.',
   'Class III antiarrhythmic with non-selective beta-blockade. Prolongs the QT interval with a risk of torsades de pointes, increased by hypokalaemia/hypomagnesaemia and by QT-prolonging drugs. Requires hospital titration and ECG/electrolyte monitoring.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sotalol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9a36d95c-6e93-4e57-befe-b5274f359244',
   'DailyMed/FDA (NIH/NLM) — approved Sotalol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9a36d95c-6e93-4e57-befe-b5274f359244'),
  ('furosemida',
   'A furosemida é um diurético de ação forte usado para eliminar o excesso de líquidos do corpo, por exemplo em doentes com insuficiência cardíaca ou problemas renais. Pode baixar demasiado o potássio e a tensão arterial, por isso é importante fazer análises regulares.',
   'Furosemide is a strong diuretic used to remove excess fluid from the body, for example in heart failure or kidney disease. It can lower potassium and blood pressure too much, so regular blood tests are important.',
   'Diurético de ansa de alta potência. Indicado no edema por insuficiência cardíaca, hepática ou renal e na hipertensão. Causa hipocaliemia, hipomagnesiemia, hiponatremia e hipovolémia; ototoxicidade com doses elevadas ou perfusão rápida.',
   'High-ceiling loop diuretic. Indicated for oedema due to heart, liver or renal failure and for hypertension. Causes hypokalaemia, hypomagnesaemia, hyponatraemia and hypovolaemia; ototoxicity with high doses or rapid infusion.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Furosemida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6d9caaab-d874-4cf1-b9fe-408452a18998',
   'DailyMed/FDA (NIH/NLM) — approved Furosemide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6d9caaab-d874-4cf1-b9fe-408452a18998')
) AS v(slug, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en,
       source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- 4. INSERT par novo — warfarina × ibuprofeno (moderate)
--    Padrão 7.4 do documento de fluxo: LEAST/GREATEST canónico nas colunas
--    (CHECK drug_a_id < drug_b_id) + ON CONFLICT DO NOTHING.
-- ---------------------------------------------------------------------
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   summary_pro_pt, summary_pro_en, explanation_pt, explanation_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Tomar ibuprofeno com varfarina aumenta o risco de hemorragia, sobretudo no estômago e nos intestinos. Sempre que possível, prefira paracetamol e fale com o seu médico antes de usar anti-inflamatórios.',
  'Taking ibuprofen with warfarin increases the risk of bleeding, mainly in the stomach and intestines. Whenever possible, prefer paracetamol and talk to your doctor before using anti-inflammatories.',
  'AINE + cumarínico: risco hemorrágico aumentado por lesão gastrointestinal direta e inibição plaquetária (COX-1). Preferir paracetamol; se o AINE for inevitável, usar a menor dose eficaz, pelo menor tempo, com proteção gástrica (IBP).',
  'NSAID + coumarin: increased bleeding risk from direct GI injury and platelet inhibition (COX-1). Prefer paracetamol; if the NSAID is unavoidable, use the lowest effective dose for the shortest time with gastric protection (PPI).',
  'O ibuprofeno aumenta o risco de hemorragia nos doentes a tomar varfarina por dois mecanismos: lesão direta da mucosa gastrointestinal e inibição reversível da COX-1, que reduz a produção de tromboxano A2 e prejudica a agregação plaquetária. O efeito sobre o INR é variável, mas o aumento do risco hemorrágico — em particular de hemorragia gastrointestinal alta — está bem documentado mesmo com doses ocasionais de AINE. Em doentes que necessitam de analgesia, o paracetamol é a alternativa preferida; se um AINE for mesmo necessário, deve usar-se a menor dose eficaz durante o menor tempo possível, considerar proteção gástrica com inibidor da bomba de protões e manter vigilância de sinais de hemorragia (fezes escuras, equimoses espontâneas, hemorragias).',
  'Ibuprofen increases the bleeding risk in patients taking warfarin through two mechanisms: direct injury to the gastrointestinal mucosa and reversible COX-1 inhibition, which reduces thromboxane A2 production and impairs platelet aggregation. The effect on the INR is variable, but the overall increase in bleeding risk — particularly upper gastrointestinal bleeding — is well documented even with occasional NSAID doses. In patients needing analgesia, paracetamol is the preferred alternative; if an NSAID is truly required, the lowest effective dose for the shortest time should be used, gastric protection with a proton pump inhibitor may be considered, and surveillance for bleeding signs (dark stools, spontaneous bruising, bleeding) maintained.',
  'O AINE inibe a COX-1 plaquetária (efeito antiagregante) e lesa a mucosa gástrica, somando-se à anticoagulação da varfarina.',
  'The NSAID inhibits platelet COX-1 (antiplatelet effect) and injures the gastric mucosa, adding to warfarin anticoagulation.',
  'Preferir paracetamol; se o AINE for inevitável, dose mínima e curso curto com proteção gástrica; informar o doente do risco hemorrágico.',
  'Prefer paracetamol; if the NSAID is unavoidable, use a minimal short course with gastric protection; inform the patient of the bleeding risk.',
  'INR, sinais de hemorragia; hemoglobina em uso prolongado.',
  'INR, bleeding signs; haemoglobin with prolonged use.',
  'Hemorragia, fezes escuras ou equimoses espontâneas — avaliação imediata.',
  'Bleeding, dark stools or spontaneous bruising — seek immediate evaluation.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Varfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)',
  'DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'warfarina' AND b.slug = 'ibuprofeno'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- ---------------------------------------------------------------------
-- 5. UPDATE campos novos — ramipril × espironolactona (moderate, existe)
--    WHERE independente da ordem (regra de ouro do documento de fluxo).
-- ---------------------------------------------------------------------
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'IECA + antagonista da aldosterona: efeito aditivo na retenção de potássio, com risco de hipercaliemia, sobretudo com TFG reduzida, diabetes ou idade avançada. Monitorizar potássio e creatinina.',
  summary_pro_en = 'ACE inhibitor + aldosterone antagonist: additive potassium retention, with a hyperkalaemia risk, especially with reduced GFR, diabetes or advanced age. Monitor potassium and creatinine.',
  explanation_pt = 'A associação de um IECA (ramipril) com um diurético poupador de potássio (espironolactona) reduz a excreção de potássio por duas vias: o ramipril diminui a produção de aldosterona e a espironolactona bloqueia o recetor da aldosterona no túbulo distal. O resultado é a retenção de potássio, clinicamente relevante sobretudo em doentes com função renal diminuída, diabetes ou idade avançada. Esta combinação é frequente na insuficiência cardíaca com fração de ejeção reduzida, onde o benefício está comprovado — o que se exige é vigilância: potássio e creatinina cerca de 1 semana após iniciar ou ajustar, e reavaliação se houver piora renal. A hipercaliemia grave manifesta-se por fraqueza muscular, parestesias e arritmias e exige correção imediata.',
  explanation_en = 'Combining an ACE inhibitor (ramipril) with a potassium-sparing diuretic (spironolactone) reduces potassium excretion through two pathways: ramipril lowers aldosterone production and spironolactone blocks the aldosterone receptor in the distal tubule. The result is potassium retention, clinically relevant especially in patients with reduced renal function, diabetes or advanced age. This combination is common in heart failure with reduced ejection fraction, where the benefit is proven — what is required is surveillance: potassium and creatinine about 1 week after starting or adjusting, and reassessment if renal function worsens. Severe hyperkalaemia presents with muscle weakness, paraesthesias and arrhythmias and requires immediate correction.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ramipril'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ramipril'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'));

-- ---------------------------------------------------------------------
-- 6. UPDATE campos novos — sotalol × furosemida (critical, existe)
-- ---------------------------------------------------------------------
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diurético de ansa + sotalol: a hipocaliemia/hipomagnesiemia induzida pelo diurético aumenta o risco de torsades de pointes num fármaco que prolonga o QT. Corrigir eletrólitos antes e monitorizar o ECG.',
  summary_pro_en = 'Loop diuretic + sotalol: diuretic-induced hypokalaemia/hypomagnesaemia increases the risk of torsades de pointes with a QT-prolonging drug. Correct electrolytes first and monitor the ECG.',
  explanation_pt = 'O sotalol prolonga o intervalo QT e o risco de torsades de pointes aumenta quando o potássio (e o magnésio) séricos descem. A furosemida, ao depletar estes eletrólitos, cria o ambiente eletrofisiológico para arritmias ventriculares polimórficas potencialmente fatais. A associação não é proibida, mas exige disciplina: repor o potássio para pelo menos 4,0 mEq/L antes de iniciar o sotalol, corrigir a hipomagnesiemia, monitorizar o QT e os eletrólitos durante o tratamento e evitar outros fármacos que prolonguem o QT.',
  explanation_en = 'Sotalol prolongs the QT interval and the risk of torsades de pointes rises as serum potassium (and magnesium) fall. Furosemide, by depleting these electrolytes, creates the electrophysiological environment for potentially fatal polymorphic ventricular arrhythmias. The combination is not prohibited but demands discipline: correct potassium to at least 4.0 mEq/L before starting sotalol, correct hypomagnesaemia, monitor the QT and electrolytes during treatment and avoid other QT-prolonging drugs.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sotalol'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sotalol'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));
