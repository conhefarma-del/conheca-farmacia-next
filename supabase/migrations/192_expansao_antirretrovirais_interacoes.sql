-- =====================================================================
-- 192 — Expansão: pares de interação dos 11 antirretrovirais novos
--
-- Fármacos novos: tenofovir, emtricitabina, dolutegravir, lopinavir-ritonavir,
--                 darunavir, abacavir, raltegravir, etravirina, rilpivirina,
--                 estavudina, didanosina
-- Parceiros: fármacos já existentes na BD (lamivudina, zidovudina, efavirenz,
--            nevirapina, ritonavir, atazanavir, ciprofloxacina, metformina, etc.)
-- Fontes: DailyMed/FDA (NIH/NLM), EMC-UK (MHRA)
-- Padrão: 7.4 (INSERT com LEAST/GREATEST canónico)
-- =====================================================================

-- =====================================================================
-- 1. DOLUTEGRAVIR — interações críticas (indução/enzimática)
-- =====================================================================

-- Dolutegravir × Rifampicina (indução UGT1A1 → redução de ~54%)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'A rifampicina reduz os níveis de dolutegravir em ~54% por indução do UGT1A1. A dose de dolutegravir deve ser aumentada para 50 mg duas vezes ao dia quando coadministrado.',
  'Rifampicin reduces dolutegravir levels by ~54% via UGT1A1 induction. The dolutegravir dose must be increased to 50 mg twice daily when coadministered.',
  'A rifampicina é um potente indutor do UGT1A1, enzima responsável pela glucuronização do dolutegravir. Esta indução reduz significativamente os níveis plasmáticos do dolutegravir, comprometendo a supressão viral.',
  'Rifampicin is a potent inducer of UGT1A1, the enzyme responsible for dolutegravir glucuronidation. This induction significantly reduces dolutegravir plasma levels, compromising viral suppression.',
  'Aumentar a dose de dolutegravir para 50 mg duas vezes ao dia (em vez de 50 mg uma vez ao dia). Suspender rifampicina 2 semanas após a última dose e retomar dose normal de dolutegravir.',
  'Increase dolutegravir dose to 50 mg twice daily (instead of 50 mg once daily). Discontinue rifampicin 2 weeks after last dose and resume normal dolutegravir dose.',
  'Monitorizar carga viral 2-4 semanas após iniciar rifampicina. Considerar alternativa à rifampicina (ex.: rifabutina com ajuste de dose).',
  'Monitor viral load 2-4 weeks after starting rifampicin. Consider alternative to rifampicin (e.g. rifabutin with dose adjustment).',
  'Falha virológica se a dose não for ajustada. Níveis subterapêuticos de dolutegravir.',
  'Virological failure if dose is not adjusted. Subtherapeutic dolutegravir levels.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dolutegravir (Tivicay): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485bc9db-8665-9f5a-e063-6394a90a7921 ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04e52489-77af-4b7f-b20b-3c5742e7b75e',
  'DailyMed/FDA (NIH/NLM) — approved Dolutegravir (Tivicay) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485bc9db-8665-9f5a-e063-6394a90a7921 ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04e52489-77af-4b7f-b20b-3c5742e7b75e',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'dolutegravir' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Dolutegravir × Carbamazepina (indução UGT1A1/CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A carbamazepina pode reduzir os níveis de dolutegravir por indução enzimática. Considerar ajuste de dose ou alternativa.',
  'Carbamazepine may reduce dolutegravir levels via enzyme induction. Consider dose adjustment or alternative.',
  'A carbamazepina induz o UGT1A1 e o CYP3A4, enzimas envolvidas no metabolismo do dolutegravir, reduzindo os seus níveis plasmáticos.',
  'Carbamazepine induces UGT1A1 and CYP3A4, enzymes involved in dolutegravir metabolism, reducing its plasma levels.',
  'Considerar aumento da dose de dolutegravir para 50 mg duas vezes ao dia. Monitorizar carga viral. Alternativa: trocar carbamazepina por outro antiepiléptico.',
  'Consider increasing dolutegravir dose to 50 mg twice daily. Monitor viral load. Alternative: switch carbamazepine to another antiepileptic.',
  'Monitorizar carga viral e função hepática periodicamente.',
  'Monitor viral load and liver function periodically.',
  'Falha virológica se não houver ajuste de dose.',
  'Virological failure if no dose adjustment.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dolutegravir (Tivicay): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485bc9db-8665-9f5a-e063-6394a90a7921 ; rótulo aprovado Carbamazepina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a63e2ab0-ddf2-4718-b59c-5a96507151aa',
  'DailyMed/FDA (NIH/NLM) — approved Dolutegravir (Tivicay) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485bc9db-8665-9f5a-e063-6394a90a7921 ; approved Carbamazepine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a63e2ab0-ddf2-4718-b59c-5a96507151aa',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'dolutegravir' AND b.slug = 'carbamazepina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Dolutegravir × Fenitoína (indução UGT1A1)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'A fenitoína pode reduzir os níveis de dolutegravir por indução enzimática. Considerar ajuste de dose.',
  'Phenytoin may reduce dolutegravir levels via enzyme induction. Consider dose adjustment.',
  'A fenitoína induz o UGT1A1, enzima envolvida no metabolismo do dolutegravir.',
  'Phenytoin induces UGT1A1, an enzyme involved in dolutegravir metabolism.',
  'Considerar aumento da dose de dolutegravir para 50 mg duas vezes ao dia. Monitorizar carga viral.',
  'Consider increasing dolutegravir dose to 50 mg twice daily. Monitor viral load.',
  'Monitorizar carga viral e níveis de fenitoína.',
  'Monitor viral load and phenytoin levels.',
  'Falha virológica se não houver ajuste de dose.',
  'Virological failure if no dose adjustment.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Dolutegravir (Tivicay): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485bc9db-8665-9f5a-e063-6394a90a7921 ; rótulo aprovado Fenitoína: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d53d1073-e89c-4f2a-bb6c-7e50a1ca4995',
  'DailyMed/FDA (NIH/NLM) — approved Dolutegravir (Tivicay) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=485bc9db-8665-9f5a-e063-6394a90a7921 ; approved Phenytoin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d53d1073-e89c-4f2a-bb6c-7e50a1ca4995',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'dolutegravir' AND b.slug = 'fenitoína'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 2. RILPIVIRINA — interações com PPIs e antiácidos
-- =====================================================================

-- Rilpivirina × Omeprazol (PPI reduz absorção)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Os inibidores da bomba de protões (omeprazol) elevam o pH gástrico, reduzindo a absorção da rilpivirina em ~40-50%. Evitar coadministração ou usar alternativa.',
  'Proton pump inhibitors (omeprazole) raise gastric pH, reducing rilpivirine absorption by ~40-50%. Avoid coadministration or use alternative.',
  'A rilpivirina é uma base fraca que requer pH ácido para absorção adequada. O omeprazol eleva o pH gástrico, reduzindo significativamente a biodisponibilidade oral.',
  'Rilpivirine is a weak base that requires acidic pH for adequate absorption. Omeprazole raises gastric pH, significantly reducing oral bioavailability.',
  'Evitar coadministração. Se necessário, usar antiácidos (hidróxido de alumínio/magnésio) com pelo menos 4 horas de intervalo. Alternativa: H2-receptor antagonist (ranitidina) com pelo menos 12 horas de intervalo.',
  'Avoid coadministration. If necessary, use antacids (aluminium/magnesium hydroxide) with at least 4 hours apart. Alternative: H2-receptor antagonist (ranitidine) with at least 12 hours apart.',
  'Monitorizar carga viral se PPI for inevitável.',
  'Monitor viral load if PPI is unavoidable.',
  'Redução clinicamente significativa dos níveis de rilpivirina → risco de falha virológica.',
  'Clinically significant reduction in rilpivirine levels → risk of virological failure.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Rilpivirina (Edurant): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=03880372-2c68-45c6-a53a-f420c49541d6 ; rótulo aprovado Omeprazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=eb575720-d081-4261-ab09-432c30d13c07',
  'DailyMed/FDA (NIH/NLM) — approved Rilpivirine (Edurant) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=03880372-2c68-45c6-a53a-f420c49541d6 ; approved Omeprazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=eb575720-d081-4261-ab09-432c30d13c07',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'rilpivirina' AND b.slug = 'omeprazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- Rilpivirina × Antiácidos (quelação)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Antiácidos (hidróxido de alumínio/magnésio) podem reduzir a absorção da rilpivirina. Administrar com pelo menos 4 horas de intervalo.',
  'Antacids (aluminium/magnesium hydroxide) may reduce rilpivirine absorption. Administer at least 4 hours apart.',
  'Os antiácidos contendo catiões polivalentes (Al³⁺, Mg²⁺) podem formar complexos insolúveis com a rilpivirina, reduzindo a sua absorção.',
  'Antacids containing polyvalent cations (Al³⁺, Mg²⁺) may form insoluble complexes with rilpivirine, reducing its absorption.',
  'Administrar antiácidos pelo menos 4 horas antes ou 4 horas depois da rilpivirina.',
  'Administer antacids at least 4 hours before or 4 hours after rilpivirine.',
  'Monitorizar carga viral se antiácidos forem usados regularmente.',
  'Monitor viral load if antacids are used regularly.',
  'Redução da absorção de rilpivirina → risco de falha virológica.',
  'Reduced rilpivirine absorption → risk of virological failure.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Rilpivirina (Edurant): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=03880372-2c68-45c6-a53a-f420c49541d6',
  'DailyMed/FDA (NIH/NLM) — approved Rilpivirine (Edurant) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=03880372-2c68-45c6-a53a-f420c49541d6',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'rilpivirina' AND b.slug = 'antiacidos'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 3. TENOFOVIR — interação com Metformina (risco renal)
-- =====================================================================

-- Tenofovir × Metformina (risco de acidose láctica)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Tenofovir e metformina são ambos eliminados por via renal. A coadministração pode aumentar o risco de efeitos nefrotóxicos e acidose láctica. Monitorizar função renal.',
  'Tenofovir and metformine are both renally eliminated. Coadministration may increase the risk of nephrotoxic effects and lactic acidosis. Monitor renal function.',
  'Ambos os fármacos competem pela secreção tubular renal. O tenofovir pode reduzir a depuração da metformina, elevando os seus níveis. O risco de acidose láctica aumenta em doentes com insuficiência renal.',
  'Both drugs compete for renal tubular secretion. Tenofovir may reduce metformine clearance, increasing its levels. The risk of lactic acidosis increases in patients with renal impairment.',
  'Monitorizar função renal (creatinina, TFG) antes e durante o tratamento. Ajustar dose de metformina se TFG <30 mL/min. Considerar alternativa ao tenofovir (ex.: entecavir para hepatite B).',
  'Monitor renal function (creatinine, GFR) before and during treatment. Adjust metformine dose if GFR <30 mL/min. Consider alternative to tenofovir (e.g. entecavir for hepatitis B).',
  'Creatinina sérica, TFG, ácido láctico, sintomas de acidose láctica (náuseas, vómitos, dor abdominal, confusão).',
  'Serum creatinine, GFR, lactic acid, symptoms of lactic acidosis (nausea, vomiting, abdominal pain, confusion).',
  'Acidose láctica (raro mas potencialmente fatal). Insuficiência renal aguda.',
  'Lactic acidosis (rare but potentially fatal). Acute renal failure.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Tenofovir (Viread): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=33fd6418-fbdc-42ca-a50d-ce2a476a5418 ; rótulo aprovado Metformina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7b43f66c-8e1a-4a6b-b582-c1e5bb48d3df',
  'DailyMed/FDA (NIH/NLM) — approved Tenofovir (Viread) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=33fd6418-fbdc-42ca-a50d-ce2a476a5418 ; approved Metformine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7b43f66c-8e1a-4a6b-b582-c1e5bb48d3df',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'tenofovir' AND b.slug = 'metformina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 4. LOPINAVIR/RITONAVIR — interações com Estatinas (CYP3A4)
-- =====================================================================

-- Lopinavir-ritonavir × Atorvastatina (inibição CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'O lopinavir/ritonavir inibe potente o CYP3A4, elevando os níveis de atorvastatina em ~4-8 vezes. Risco elevado de miopatia e rabdomiólise. Evitar ou reduzir dose drasticamente.',
  'Lopinavir/ritonavir potently inhibits CYP3A4, raising atorvastatin levels ~4-8 fold. High risk of myopathy and rhabdomyolysis. Avoid or drastically reduce dose.',
  'O ritonavir (potenciador) inibe irreversivelmente o CYP3A4, enzima principal do metabolismo da atorvastatina. A AUC da atorvastatina aumenta significativamente.',
  'Ritonavir (booster) irreversibly inhibits CYP3A4, the main enzyme of atorvastatin metabolism. Atorvastatin AUC increases significantly.',
  'EVITAR a combinação. Se inevitável, limitar atorvastatina a 10 mg/dia e monitorizar CK. Alternativa: pravastatina ou rosuvastatina (não dependem de CYP3A4).',
  'AVOID the combination. If unavoidable, limit atorvastatin to 10 mg/day and monitor CK. Alternative: pravastatin or rosuvastatin (CYP3A4-independent).',
  'CK (creatina cinase), transaminases, sintomas de miopatia (dor muscular, fraqueza, urina escura).',
  'CK (creatine kinase), transaminases, myopathy symptoms (muscle pain, weakness, dark urine).',
  'Miopatia, rabdomiólise (potencialmente fatal), insuficiência renal.',
  'Myopathy, rhabdomyolysis (potentially fatal), renal failure.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Lopinavir + Ritonavir (Kaletra): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8290add3-4449-4e58-6c97-8fe1eec972e3 ; rótulo aprovado Atorvastatina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3143a3ff-f186-4a21-b217-ff73b0e9c85e',
  'DailyMed/FDA (NIH/NLM) — approved Lopinavir + Ritonavir (Kaletra) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8290add3-4449-4e58-6c97-8fe1eec972e3 ; approved Atorvastatin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3143a3ff-f186-4a21-b217-ff73b0e9c85e',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'lopinavir-ritonavir' AND b.slug = 'atorvastatina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 5. ETRAVIRINA — interações com Rifampicina (indução potente)
-- =====================================================================

-- Etravirina × Rifampicina (indução CYP3A4/CYP2C19)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'critical',
  'A rifampicina reduz os níveis de etravirina em ~80% por indução potente do CYP3A4/CYP2C19. CONTRAINDICADA a coadministração.',
  'Rifampicin reduces etravirine levels by ~80% via potent CYP3A4/CYP2C19 induction. CONTRAINDICATED.',
  'A rifampicina é um dos indutores enzimáticos mais potentes. A indução do CYP3A4 e CYP2C19 praticamente anula os níveis de etravirina, comprometendo a eficácia antirretroviral.',
  'Rifampicin is one of the most potent enzyme inducers. Induction of CYP3A4 and CYP2C19 virtually abolishes etravirine levels, compromising antiretroviral efficacy.',
  'CONTRAINDICADO. Não coadministrar. Alternativa: rifabutina (indução mais fraca) com ajuste de dose de etravirina para 400 mg duas vezes ao dia.',
  'CONTRAINDICATED. Do not coadminister. Alternative: rifabutin (weaker induction) with etravirine dose adjustment to 400 mg twice daily.',
  'Monitorizar carga viral se rifabutina for usada em vez de rifampicina.',
  'Monitor viral load if rifabutin is used instead of rifampicin.',
  'Falha virológica quase garantida se coadministrados.',
  'Virological failure virtually guaranteed if coadministered.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Etravirina (Intelence): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6a9cbc29-9f15-4b24-8d86-206b82887f3d ; rótulo aprovado Rifampicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04e52489-77af-4b7f-b20b-3c5742e7b75e',
  'DailyMed/FDA (NIH/NLM) — approved Etravirine (Intelence) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=6a9cbc29-9f15-4b24-8d86-206b82887f3d ; approved Rifampicin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=04e52489-77af-4b7f-b20b-3c5742e7b75e',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'etravirina' AND b.slug = 'rifampicina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 6. ABACAVIR × Lamivudina (combinação comum — sem interação adversa)
-- =====================================================================

-- Abacavir × Lamivudina (combinação intencional — none)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'none',
  'Abacavir e lamivudina são frequentemente associados em regimes de primeira linha (2 NRTIs). Não existe interação adversa clinicamente significativa.',
  'Abacavir and lamivudine are frequently combined in first-line regimens (2 NRTIs). There is no clinically significant adverse interaction.',
  'Ambos atuam como análogos de nucleosídeos/nucleotídeos da transcriptase reversa, mas não competem significativamente pelas mesmas vias metabólicas. A combinação é sinérgica e bem tolerada.',
  'Both act as nucleoside/nucleotide reverse transcriptase analogues, but do not significantly compete for the same metabolic pathways. The combination is synergistic and well tolerated.',
  'Nenhuma restrição. Dose padrão: abacavir 600 mg + lamivudina 300 mg, uma vez ao dia.',
  'No restrictions. Standard dose: abacavir 600 mg + lamivudine 300 mg, once daily.',
  'Avaliar HLA-B*5701 antes de iniciar abacavir. Monitorizar função renal.',
  'Assess HLA-B*5701 before starting abacavir. Monitor renal function.',
  'Nenhum.',
  'None.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Abacavir (Ziagen): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ca73b519-015a-436d-aa3c-af53492825a1 ; rótulo aprovado Lamivudina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb340b00-f2a8-48e7-af4b-07b3d6a1f5c3',
  'DailyMed/FDA (NIH/NLM) — approved Abacavir (Ziagen) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ca73b519-015a-436d-aa3c-af53492825a1 ; approved Lamivudine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb340b00-f2a8-48e7-af4b-07b3d6a1f5c3',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'abacavir' AND b.slug = 'lamivudina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 7. DIDANOSINA × ESTAVUDINA — competição + toxicidade mitocondrial
-- =====================================================================

-- Didanosina × Estavudina (toxicidade aditiva)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Didanosina e estavudina são ambos NRTIs com toxicidade mitocondrial aditiva. A coadministração aumenta o risco de neuropatia periférica, pancreatite e acidose láctica.',
  'Didanosine and stavudine are both NRTIs with additive mitochondrial toxicity. Coadministration increases the risk of peripheral neuropathy, pancreatitis and lactic acidosis.',
  'Ambos inibem a ADN polimerase mitocondrial, causando depleção de ADN mitocondrial. A associação potencia esta toxicidade.',
  'Both inhibit mitochondrial DNA polymerase, causing mitochondrial DNA depletion. The association potentiates this toxicity.',
  'EVITAR a coadministração. Se inevitável, monitorizar atentamente sintomas de neuropatia, dor abdominal e ácido láctico. Usar a menor dose possível de cada.',
  'AVOID coadministration. If unavoidable, carefully monitor for neuropathy symptoms, abdominal pain and lactic acid. Use the lowest possible dose of each.',
  'Sintomas de neuropatia periférica (formigueiro, dormência nos pés/mãos), dor abdominal, amilase sérica, ácido láctico.',
  'Peripheral neuropathy symptoms (tingling, numbness in feet/hands), abdominal pain, serum amylase, lactic acid.',
  'Neuropatia periférica grave, pancreatite, acidose láctica (potencialmente fatal).',
  'Severe peripheral neuropathy, pancreatitis, lactic acidosis (potentially fatal).',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Didanosina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=829e744d-7bd4-43dc-9b58-ffb016cb8e67 ; rótulo aprovado Estavudina (Zerit): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8bb73c56-74cb-4602-b9a3-57bd1082b434',
  'DailyMed/FDA (NIH/NLM) — approved Didanosine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=829e744d-7bd4-43dc-9b58-ffb016cb8e67 ; approved Stavudine (Zerit) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=8bb73c56-74cb-4602-b9a3-57bd1082b434',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'didanosina' AND b.slug = 'estavudina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 8. DARUNAVIR × Ketoconazol (inibição CYP3A4)
-- =====================================================================

-- Darunavir × Cetoconazol (inibição CYP3A4)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'O cetoconazol pode elevar os níveis de darunavir por inibição do CYP3A4. Limitar dose de cetoconazol a 200 mg/dia.',
  'Ketoconazole may raise darunavir levels via CYP3A4 inhibition. Limit ketoconazole dose to 200 mg/day.',
  'O cetoconazol é um inibidor potente do CYP3A4. O darunavir (potenciado por ritonavir) já tem os níveis elevados — a adição de cetoconazol pode causar toxicidade.',
  'Ketoconazole is a potent CYP3A4 inhibitor. Darunavir (boosted by ritonavir) already has elevated levels — adding ketoconazole may cause toxicity.',
  'Limitar cetoconazol a 200 mg/dia. Monitorizar función hepática e sinais de toxicidade.',
  'Limit ketoconazole to 200 mg/day. Monitor liver function and signs of toxicity.',
  'Transaminases, sintomas de toxicidade (náuseas, icterícia).',
  'Transaminases, toxicity symptoms (nausea, jaundice).',
  'Hepatotoxicidade, elevação excessiva dos níveis de darunavir.',
  'Hepatotoxicity, excessive elevation of darunavir levels.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Darunavir (Prezista): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=814301f9-c990-46a5-b481-2879a521a16f',
  'DailyMed/FDA (NIH/NLM) — approved Darunavir (Prezista) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=814301f9-c990-46a5-b481-2879a521a16f',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'darunavir' AND b.slug = 'cetoconazol'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 9. RALTEGRAVIR × Metformina (competição tubular)
-- =====================================================================

-- Raltegravir × Metformina (elevação de creatinina)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'minor',
  'O raltegravir pode elevar ligeiramente a creatinina sérica por inibição da secreção tubular (sem efeito na TFG real). Não requer ajuste de dose de metformina.',
  'Raltegravir may slightly elevate serum creatinine via inhibition of tubular secretion (no effect on actual GFR). No metformine dose adjustment required.',
  'O raltegravir inibe o transportador OCT2/creatinina no rim, elevando a creatinina sérica em 0,1-0,3 mg/dL sem alteração da função renal real.',
  'Raltegravir inhibits the OCT2/creatinine transporter in the kidney, raising serum creatinine by 0.1-0.3 mg/dL without actual renal function change.',
  'Não requer ajuste de dose. Interpretar a creatinina sérica no contexto do raltegravir — a elevação é aparente, não real.',
  'No dose adjustment required. Interpret serum creatinine in the context of raltegravir — the elevation is apparent, not real.',
  'Creatinina sérica (interprestar com cautela).',
  'Serum creatinine (interpret with caution).',
  'Nenhum clinicamente significativo.',
  'None clinically significant.',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Raltegravir (Isentress): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=89a5ec53-d956-4329-8004-0f40f51c88a3',
  'DailyMed/FDA (NIH/NLM) — approved Raltegravir (Isentress) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=89a5ec53-d956-4329-8004-0f40f51c88a3',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'raltegravir' AND b.slug = 'metformina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;

-- =====================================================================
-- 10. EMTRICITABINA × Lamivudina (competição — evitar duplicação)
-- =====================================================================

-- Emtricitabina × Lamivudina (mesmo mecanismo — evitar)
INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en,
   management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  'Emtricitabina e lamivudina têm mecanismo de ação idêntico (análogos da citosina). A coadministração não oferece benefício aditivo e pode aumentar a toxicidade.',
  'Emtricitabine and lamivudine have identical mechanisms of action (cytosine analogues). Coadministration offers no additional benefit and may increase toxicity.',
  'Ambos são análogos da citosina que atuam como terminadores de cadeia na transcriptase reversa. Não há sinergia clinicamente significativa — apenas duplicação de efeitos colaterais.',
  'Both are cytosine analogues that act as chain terminators on reverse transcriptase. There is no clinically significant synergy — only duplication of side effects.',
  'NÃO coadministrar. Escolher apenas um dos dois como backbone NRTI.',
  'DO NOT coadminister. Choose only one of the two as the NRTI backbone.',
  'Nenhum (não devem ser usados em conjunto).',
  'None (should not be used together).',
  'Nenhum (duplicação desnecessária).',
  'None (unnecessary duplication).',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado Emtricitabina (Emtriva): https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d6599395-3944-44f9-97f2-e0424c6b6a1f ; rótulo aprovado Lamivudina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb340b00-f2a8-48e7-af4b-07b3d6a1f5c3',
  'DailyMed/FDA (NIH/NLM) — approved Emtricitabine (Emtriva) label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d6599395-3944-44f9-97f2-e0424c6b6a1f ; approved Lamivudine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cb340b00-f2a8-48e7-af4b-07b3d6a1f5c3',
  'published')
FROM public.drugs a, public.drugs b
WHERE a.slug = 'emtricitabina' AND b.slug = 'lamivudina'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
