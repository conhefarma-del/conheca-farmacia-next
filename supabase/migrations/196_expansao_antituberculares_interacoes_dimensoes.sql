-- =====================================================================
-- 196 — Expansão: pares de interação + dimensões dos antituberculares novos
--
-- Fármacos: cicloserina, clofazimina, amicacina, etionamida,
--           protionamida, terizidona, capreomicina
-- Fontes: DailyMed/FDA (NIH/NLM), EMC-UK (MHRA)
-- Padrão: 7.4 (INSERT) + 7.6 (dimensões)
-- =====================================================================

-- =====================================================================
-- 1. PARES DE INTERAÇÃO
-- =====================================================================

-- Cicloserina × Fenitoína (competição renal + convulsões)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Cicloserina e fenitoína competem pela secreção tubular renal. A fenitoína pode elevar os níveis de cicloserina, aumentando o risco de efeitos neuropsiquiátricos.',
  'Cycloserine and phenytoin compete for renal tubular secretion. Phenytoin may raise cycloserine levels, increasing the risk of neuropsychiatric effects.',
  'Ambos são eliminados por secreção tubular renal. A coadministração pode elevar os níveis de cicloserina, potenciando efeitos neurológicos (confusão, convulsões).',
  'Both are eliminated by renal tubular secretion. Coadministration may raise cycloserine levels, potentiating neurological effects (confusion, seizures).',
  'Monitorizar função neurológica e níveis de cicloserina. Considerar redução de dose.',
  'Monitor neurological function and cycloserine levels. Consider dose reduction.',
  'Sintomas neuropsiquiátricos (confusão, psicose, convulsões), cefaleia, tonturas.',
  'Neuropsychiatric symptoms (confusion, psychosis, seizures), headache, dizziness.',
  'Psicose, convulsões (potencialmente graves).',
  'Psychosis, seizures (potentially serious).',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cicloserina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9 ; rótulo aprovado Fenitoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d53d1073-e89c-4f2a-bb6c-7e50a1ca4995',
  'DailyMed/FDA (NIH/NLM) — approved Cycloserine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9 ; approved Phenytoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d53d1073-e89c-4f2a-bb6c-7e50a1ca4995',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'cicloserina' AND b.slug = 'fenitoína'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Clofazimina × Rifampicina (indução CYP3A4 pode reduzir clofazimina)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A rifampicina pode reduzir os níveis de clofazimina por indução enzimática. Monitorizar resposta clínica.',
  'Rifampicin may reduce clofazimine levels via enzyme induction. Monitor clinical response.',
  'A rifampicina induz enzimas hepáticas que metabolizam a clofazimina, potencialmente reduzindo os seus níveis. O efeito clínico pode ser significativo em regimes de TB-MDR.',
  'Rifampicin induces hepatic enzymes that metabolise clofazimine, potentially reducing its levels. The clinical effect may be significant in MDR-TB regimens.',
  'Monitorizar resposta clínica e coloração da pele (indicador de acumulação). Considerar ajuste de dose se resposta inadequada.',
  'Monitor clinical response and skin discoloration (accumulation indicator). Consider dose adjustment if inadequate response.',
  'Resposta clínica, coloração da pele, visão.',
  'Clinical response, skin discoloration, vision.',
  'Falha terapêutica se níveis reduzidos.',
  'Therapeutic failure if levels reduced.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clofazimina (Lamprene): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04e52489-77af-4b7f-b20b-3c5742e7b75e',
  'DailyMed/FDA (NIH/NLM) — approved Clofazimine (Lamprene) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04e52489-77af-4b7f-b20b-3c5742e7b75e',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'clofazimina' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Amicacina × Furosemida (ototoxicidade aditiva)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'Amicacina e furosemida são ambos ototóxicos. A coadministração aumenta significativamente o risco de surdez e vestibulopatia.',
  'Amikacin and furosemide are both ototoxic. Coadministration significantly increases the risk of deafness and vestibulopathy.',
  'A amicacina causa ototoxicidade por destruição das células ciliadas cocleares e vestibulares. A furosemida potencia esta toxicidade por mecanismos não totalmente elucidados (possível competição pela secreção tubular e efeito na microcirculação coclear).',
  'Amikacin causes ototoxicity by destruction of cochlear and vestibular hair cells. Furosemide potentiates this toxicity through mechanisms not fully elucidated (possible competition for tubular secretion and effect on cochlear microcirculation).',
  'EVITAR coadministração sempre que possível. Se necessário, monitorizar audiograma semanalmente e suspender se houver deterioração auditiva.',
  'AVOID coadministration whenever possible. If necessary, monitor audiogram weekly and discontinue if auditory deterioration occurs.',
  'Audiograma basal e periódico, vestibular testes, creatinina sérica.',
  'Baseline and periodic audiogram, vestibular tests, serum creatinine.',
  'Surdez permanente, vestibulopatia (potencialmente irreversível).',
  'Permanent deafness, vestibulopathy (potentially irreversible).',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amicacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890 ; rótulo aprovado Furosemida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=92ef1c6c-b0aa-4d3e-8933-5c3f85c6e6c3',
  'DailyMed/FDA (NIH/NLM) — approved Amikacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890 ; approved Furosemide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=92ef1c6c-b0aa-4d3e-8933-5c3f85c6e6c3',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'amicacina' AND b.slug = 'furosemida'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Amicacina × Estreptomicina (ototoxicidade aditiva — evitar)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'Amicacina e estreptomicina são ambos aminoglicosídeos com ototoxicidade e nefrotoxicidade aditivas. CONTRAINDICADA a coadministração.',
  'Amikacin and streptomycin are both aminoglycosides with additive ototoxicity and nephrotoxicity. CONTRAINDICATED.',
  'Ambos danificam as células ciliadas cocleares e vestibulares por mecanismo idêntico. A associação potencia a toxicidade de forma aditiva, com risco elevado de surdez e nefrotoxicidade.',
  'Both damage cochlear and vestibular hair cells by identical mechanism. The combination potentiates toxicity additively, with high risk of deafness and nephrotoxicity.',
  'CONTRAINDICADO. Nunca associar dois aminoglicosídeos. Escolher apenas um.',
  'CONTRAINDICATED. Never combine two aminoglycosides. Choose only one.',
  'Audiograma, creatinina, eletrólitos.',
  'Audiogram, creatinine, electrolytes.',
  'Surdez bilateral, insuficiência renal aguda.',
  'Bilateral deafness, acute renal failure.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amicacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
  'DailyMed/FDA (NIH/NLM) — approved Amikacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'amicacina' AND b.slug = 'estreptomicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Etionamida × Isoniazida (hepatotoxicidade aditiva)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Etionamida e isoniazida são ambos hepatotóxicos. A coadministração aumenta o risco de hepatotoxicidade.',
  'Ethionamide and isoniazid are both hepatotoxic. Coadministration increases the risk of hepatotoxicity.',
  'Ambos causam hepatotoxicidade por mecanismos diferentes — a isoniazida por metabolitos reativos (hidrazina) e a etionamida por metabolitos sulfóxidos. A associação potencia o dano hepático.',
  'Both cause hepatotoxicity by different mechanisms — isoniazid via reactive metabolites (hydrazine) and ethionamide via sulfoxide metabolites. The combination potentiates liver damage.',
  'Monitorizar transaminases (ALT/AST) semanalmente nos primeiros 2 meses, depois mensalmente. Suspender se ALT >5x ULN ou sintomas de hepatotoxicidade.',
  'Monitor transaminases (ALT/AST) weekly for the first 2 months, then monthly. Discontinue if ALT >5x ULN or symptoms of hepatotoxicity.',
  'ALT/AST, bilirrubina, INR, sintomas (náuseas, icterícia, dor no hipocôndrio direito).',
  'ALT/AST, bilirubin, INR, symptoms (nausea, jaundice, right hypochondrial pain).',
  'Hepatite medicamentosa grave, insuficiência hepática.',
  'Severe drug-induced hepatitis, hepatic failure.',
  'EMC-UK (MHRA) — SmPC aprovada Etionamida: https://www.medicines.org.uk/emc/product/6740/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Isoniazida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6f269898-c9e5-4b73-b141-b5e8e6a4d7b3',
  'EMC-UK (MHRA) — approved Ethionamide SmPC: https://www.medicines.org.uk/emc/product/6740/smpc ; DailyMed/FDA (NIH/NLM) — approved Isoniazid label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6f269898-c9e5-4b73-b141-b5e8e6a4d7b3',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'etionamida' AND b.slug = 'isoniazida'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Capreomicina × Amicacina (ototoxicidade aditiva — evitar)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'Capreomicina e amicacina são ambos ototóxicos e nefrotoxicos. A coadministração aumenta significativamente o risco de toxicidade auditiva e renal.',
  'Capreomycin and amikacin are both ototoxic and nephrotoxic. Coadministration significantly increases the risk of auditory and renal toxicity.',
  'Ambos causam dano às células ciliadas cocleares e vestibulares. A associação potencia a ototoxicidade e a nefrotoxicidade.',
  'Both cause damage to cochlear and vestibular hair cells. The combination potentiates ototoxicity and nephrotoxicity.',
  'EVITAR coadministração. Se necessário, monitorizar audiograma e função renal semanalmente.',
  'AVOID coadministration. If necessary, monitor audiogram and renal function weekly.',
  'Audiograma, creatinina, eletrólitos, vestibular.',
  'Audiogram, creatinine, electrolytes, vestibular.',
  'Surdez, vestibulopatia, nefrotoxicidade.',
  'Deafness, vestibulopathy, nephrotoxicity.',
  'EMC-UK (MHRA) — SmPC aprovada Capreomicina: https://www.medicines.org.uk/emc/product/6852/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Amicacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
  'EMC-UK (MHRA) — approved Capreomycin SmPC: https://www.medicines.org.uk/emc/product/6852/smpc ; DailyMed/FDA (NIH/NLM) — approved Amikacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'capreomicina' AND b.slug = 'amicacina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Terizidona × Linezolida (mesmo mecanismo — evitar duplicação)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Terizidona e linezolida são ambas oxazolidinonas com mecanismo idêntico. A coadministração não oferece benefício aditivo e aumenta toxicidade.',
  'Terizidone and linezolid are both oxazolidinones with identical mechanism. Coadministration offers no additive benefit and increases toxicity.',
  'Ambas atuam na subunidade 50S do ribossoma. Não há sinergia — apenas duplicação de efeitos colaterais (neuropatia, mielossupressão).',
  'Both act on the 50S ribosomal subunit. No synergy — only duplication of side effects (neuropathy, myelosuppression).',
  'NÃO coadministrar. Escolher apenas uma oxazolidinona.',
  'DO NOT coadminister. Choose only one oxazolidinone.',
  'Hemograma, sintomas neurológicos.',
  'Blood count, neurological symptoms.',
  'Neuropatia grave, mielossupressão.',
  'Severe neuropathy, myelosuppression.',
  'EMC-UK (MHRA) — SmPC aprovada Terizidona: https://www.medicines.org.uk/emc/product/8044/smpc ; DailyMed/FDA (NIH/NLM) — rótulo aprovado Linezolida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=01415799-3799-4cd8-a04d-b4a196f6e2fa',
  'EMC-UK (MHRA) — approved Terizidone SmPC: https://www.medicines.org.uk/emc/product/8044/smpc ; DailyMed/FDA (NIH/NLM) — approved Linezolid label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=01415799-3799-4cd8-a04d-b4a196f6e2fa',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'terizidona' AND b.slug = 'linezolida'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. DIMENSÕES — ALIMENTO/DOENÇA/GRAVIDEZ
-- =====================================================================

-- Interações Alimento
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en, severity, mechanism_pt, mechanism_en,
   advice_pt, advice_en, source_pt, source_en, sort_order, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en, v.severity,
  v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en,
  v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('cicloserina', 'alimentos', 'Alimentos', 'Food', 'minor',
   'Alimentos não afetam significativamente a absorção da cicloserina.',
   'Food does not significantly affect cycloserine absorption.',
   'Pode ser administrado com ou sem alimentos.',
   'Can be taken with or without food.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cicloserina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9',
   'DailyMed/FDA (NIH/NLM) — approved Cycloserine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9', 1),
  ('clofazimina', 'alimentos_gordura', 'Alimentos ricos em gordura', 'Fatty foods', 'moderate',
   'A absorção da clofazimina é melhorada por alimentos gordos.',
   'Clofazimine absorption is improved by fatty food.',
   'Tomar com alimentos que contenham gordura.',
   'Take with food containing fat.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clofazimina (Lamprene): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250',
   'DailyMed/FDA (NIH/NLM) — approved Clofazimine (Lamprene) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250', 1),
  ('etionamida', 'alimentos', 'Alimentos', 'Food', 'moderate',
   'Alimentos melhoram a absorção e reduzem náuseas. Alimentos ricos em tiramina podem causar reação semelhante ao cheese.',
   'Food improves absorption and reduces nausea. Tyramine-rich foods may cause cheese-like reaction.',
   'Tomar sempre com alimentos. Evitar alimentos ricos em tiramina (queijo curado, carnes processadas, fermentados).',
   'Always take with food. Avoid tyramine-rich foods (cured cheese, processed meats, fermented foods).',
   'EMC-UK (MHRA) — SmPC aprovada Etionamida: https://www.medicines.org.uk/emc/product/6740/smpc',
   'EMC-UK (MHRA) — approved Ethionamide SmPC: https://www.medicines.org.uk/emc/product/6740/smpc', 1),
  ('etionamida', 'tiramina', 'Alimentos ricos em tiramina', 'Tyramine-rich foods', 'moderate',
   'A etionamida pode inibir a MAO, causando reação hipertensiva com alimentos ricos em tiramina.',
   'Ethionamide may inhibit MAO, causing hypertensive reaction with tyramine-rich foods.',
   'Evitar: queijo curado, carnes curadas, molho de soja, cerveja, vinho tinto.',
   'Avoid: cured cheese, cured meats, soy sauce, beer, red wine.',
   'EMC-UK (MHRA) — SmPC aprovada Etionamida: https://www.medicines.org.uk/emc/product/6740/smpc',
   'EMC-UK (MHRA) — approved Ethionamide SmPC: https://www.medicines.org.uk/emc/product/6740/smpc', 2)
) AS v(slug, entity_slug, entity_pt, entity_en, severity, mechanism_pt, mechanism_en,
       advice_pt, advice_en, source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;

-- Interações Doença
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity,
   reason_pt, reason_en, advice_pt, advice_en, source_pt, source_en, sort_order, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en, v.interaction_type, v.severity,
  v.reason_pt, v.reason_en, v.advice_pt, v.advice_en,
  v.source_pt, v.source_en, v.sort_order, 'published'
FROM public.drugs d
JOIN (VALUES
  ('cicloserina', 'epilepsia', 'Epilepsia', 'Epilepsy', 'precaution', 'moderate',
   'A cicloserina pode baixar o limiar de convulsões. Doentes com epilepsia têm risco aumentado.',
   'Cycloserine may lower the seizure threshold. Patients with epilepsy are at increased risk.',
   'Evitar em doentes com epilepsia não controlada. Usar a menor dose possível.',
   'Avoid in patients with uncontrolled epilepsy. Use the lowest possible dose.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cicloserina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9',
   'DailyMed/FDA (NIH/NLM) — approved Cycloserine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9', 1),
  ('amicacina', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment', 'contraindication', 'critical',
   'A amicacina é eliminada por filtração glomerular. Insuficiência renal causa acumulação e toxicidade.',
   'Amikacin is eliminated by glomerular filtration. Renal impairment causes accumulation and toxicity.',
   'Avaliar TFG antes de iniciar. Ajustar dose e intervalo conforme TFG. Monitorizar níveis séricos (pico e vale).',
   'Assess GFR before initiation. Adjust dose and interval according to GFR. Monitor serum levels (peak and trough).',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amicacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
   'DailyMed/FDA (NIH/NLM) — approved Amikacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890', 1),
  ('amicacina', 'hepatite', 'Doença hepática', 'Liver disease', 'precaution', 'moderate',
   'A amicacina não é metabolizada hepaticamente, mas a doença hepática grave pode afetar a eliminação indiretamente.',
   'Amikacin is not hepatically metabolised, but severe liver disease may affect elimination indirectly.',
   'Monitorizar função renal e níveis séricos. Não requer ajuste específico para doença hepática.',
   'Monitor renal function and serum levels. No specific adjustment for liver disease required.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amicacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
   'DailyMed/FDA (NIH/NLM) — approved Amikacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890', 2),
  ('clofazimina', 'prolongamento_qt', 'Prolongamento do intervalo QT', 'QT prolongation', 'precaution', 'moderate',
   'A clofazimina pode causar prolongamento do QT. Doentes com QT prolongado ou fatores de risco têm risco aumentado de arritmias.',
   'Clofazimine may cause QT prolongation. Patients with prolonged QT or risk factors are at increased risk of arrhythmias.',
   'ECG basal antes de iniciar. Evitar com outros fármacos prolongadores do QT.',
   'Baseline ECG before initiation. Avoid with other QT-prolonging drugs.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clofazimina (Lamprene): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250',
   'DailyMed/FDA (NIH/NLM) — approved Clofazimine (Lamprene) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250', 1)
) AS v(slug, condition_slug, condition_pt, condition_en, interaction_type, severity,
       reason_pt, reason_en, advice_pt, advice_en, source_pt, source_en, sort_order)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;

-- Gravidez/Lactação
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en,
  v.trimester_pt, v.trimester_en, v.lactation_pt, v.lactation_en,
  v.contraception_pt, v.contraception_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('cicloserina', 'caution',
   'Estudos em animais demonstraram efeitos sobre o SNC. Dados em humanos limitados. Usar apenas quando benefício justifica risco.',
   'Animal studies demonstrated CNS effects. Limited human data. Use only when benefit outweighs risk.',
   'Evitar no 1.º trimestre. Usar no 2.º/3.º trimestres apenas para TB-MDR grave.',
   'Avoid in 1st trimester. Use in 2nd/3rd trimesters only for severe MDR-TB.',
   'Não se sabe se é excretada no leite materno. Recomenda-se amamentação artificial.',
   'Unknown if excreted in breast milk. Artificial feeding is recommended.',
   'Contraceção fiável é recomendada.',
   'Reliable contraception is recommended.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Cicloserina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9',
   'DailyMed/FDA (NIH/NLM) — approved Cycloserine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8e7e2665-7a3d-3f54-9f92-5fe845f02ef9'),
  ('clofazimina', 'caution',
   'A OMS recomenda o uso durante a gravidez para hanseníase multi-bacilar quando o benefício justifica o risco.',
   'WHO recommends use during pregnancy for multibacillary leprosy when benefit outweighs risk.',
   'Pode ser usado no 2.º e 3.º trimestres quando indicado.',
   'Can be used in the 2nd and 3rd trimesters when indicated.',
   'Excretado no leite materno. Recomenda-se amamentação artificial.',
   'Excreted in breast milk. Artificial feeding is recommended.',
   'Contraceção fiável é recomendada.',
   'Reliable contraception is recommended.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clofazimina (Lamprene): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250',
   'DailyMed/FDA (NIH/NLM) — approved Clofazimine (Lamprene) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=2e07448f-f888-4747-80ab-570c1b621250'),
  ('amicacina', 'contraindicada',
   'CONTRAINDICADO na gravidez. Aminoglicosídeos causam ototoxicidade fetal (surdez congénita).',
   'CONTRAINDICATED in pregnancy. Aminoglycosides cause fetal ototoxicity (congenital deafness).',
   'CONTRAINDICADO em todos os trimestres.',
   'CONTRAINDICATED in all trimesters.',
   'Não aplicável (contraindicado na gravidez).',
   'Not applicable (contraindicated in pregnancy).',
   'Contraceção fiável é obrigatória.',
   'Reliable contraception is mandatory.',
   'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amicacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890',
   'DailyMed/FDA (NIH/NLM) — approved Amikacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=f260ff2a-76a0-4672-9516-91c344b67890'),
  ('etionamida', 'caution',
   'Estudos em animais demonstraram efeitos sobre o feto. Dados em humanos limitados. Usar apenas para TB-MDR grave.',
   'Animal studies demonstrated fetal effects. Limited human data. Use only for severe MDR-TB.',
   'Evitar no 1.º trimestre. Usar no 2.º/3.º trimestres apenas quando outras opções estão esgotadas.',
   'Avoid in 1st trimester. Use in 2nd/3rd trimesters only when other options are exhausted.',
   'Não se sabe se é excretada no leite materno. Recomenda-se amamentação artificial.',
   'Unknown if excreted in breast milk. Artificial feeding is recommended.',
   'Contraceção fiável é recomendada.',
   'Reliable contraception is recommended.',
   'EMC-UK (MHRA) — SmPC aprovada Etionamida: https://www.medicines.org.uk/emc/product/6740/smpc',
   'EMC-UK (MHRA) — approved Ethionamide SmPC: https://www.medicines.org.uk/emc/product/6740/smpc'),
  ('capreomicina', 'contraindicada',
   'CONTRAINDICADO na gravidez. Peptídeos cíclicos causam ototoxicidade fetal.',
   'CONTRAINDICATED in pregnancy. Cyclic peptides cause fetal ototoxicity.',
   'CONTRAINDICADO em todos os trimestres.',
   'CONTRAINDICATED in all trimesters.',
   'Não aplicável (contraindicado na gravidez).',
   'Not applicable (contraindicated in pregnancy).',
   'Contraceção fiável é obrigatória.',
   'Reliable contraception is mandatory.',
   'EMC-UK (MHRA) — SmPC aprovada Capreomicina: https://www.medicines.org.uk/emc/product/6852/smpc',
   'EMC-UK (MHRA) — approved Capreomycin SmPC: https://www.medicines.org.uk/emc/product/6852/smpc')
) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
