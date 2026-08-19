-- =====================================================================
-- 226 — Códigos ATC (lote 3): 113 fármacos que ficaram sem classificação
-- ---------------------------------------------------------------------
-- Migrações 084 e 139 preencheram 191 fármacos, mas 113 ficaram vazios
-- porque foram criados em migrações posteriores (191 antirretrovirais,
-- 195 antituberculosos, 198 cardiovasculares, 202 antidiabéticos,
-- 205 antibióticos, 208 analgésicos, 211 nimesulida, 213 psicofármacos,
-- 216 antiepilépticos, 220 asma/COPD).
--
-- Códigos verificados no índice ATC/DDD oficial (WHO Collaborating
-- Centre for Drug Statistics Methodology, atcddd.fhi.no) em 2026-08.
-- Conteúdo factual (classificação oficial), não clínico.
-- Idempotente: reaplicar é seguro (UPDATEs re-escritos com valores
-- idênticos). Aplicar manualmente no Supabase (SQL editor).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Preenchimento (padrão 7.6: JOIN com condição ON d.slug = v.slug)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET atc_code = v.atc_code
FROM (VALUES
  -- ==================================================================
  -- A — Alimentary tract and metabolism
  -- ==================================================================
  -- A02 — Drugs for acid related disorders
  ('cimetidina', 'A02BA01'),
  -- A05 — Bile and liver therapy
  ('colestiramina', 'A05AC01'),
  -- A10 — Drugs used in diabetes
  -- A10B — Blood glucose lowering drugs, excl. insulins
  ('sitagliptina', 'A10BH01'),
  ('vildagliptina', 'A10BH02'),
  ('saxagliptina', 'A10BH03'),
  ('acarbose', 'A10BF02'),
  ('dapagliflozina', 'A10BK01'),
  ('canagliflozina', 'A10BK02'),
  ('empagliflozina', 'A10BK03'),
  -- A10B J — GLP-1 analogues
  ('liraglutida', 'A10BJ02'),
  ('dulaglutida', 'A10BJ06'),
  -- ==================================================================
  -- B — Blood and blood forming organs
  -- ==================================================================
  -- B01 — Antithrombotic agents
  ('ticagrelor', 'B01AC24'),
  ('acenocumarol', 'B01AA07'),
  -- B03 — Antianaemic preparations
  ('folinato_calcio', 'B03AD03'),
  -- ==================================================================
  -- C — Cardiovascular system
  -- ==================================================================
  -- C01 — Cardiac therapy
  ('isossorbida', 'C01DA14'),
  ('ivabradina', 'C01EB17'),
  -- C07 — Beta blocking agents
  ('propranolol', 'C07AA05'),
  ('metoprolol', 'C07AB02'),
  ('atenolol', 'C07AB03'),
  ('bisoprolol', 'C07AB07'),
  ('carvedilol', 'C07AG02'),
  -- C08 — Calcium channel blockers
  ('nifedipina', 'C08CA05'),
  ('verapamilo', 'C08DA03'),
  ('diltiazem', 'C08DB01'),
  -- C09 — Agents acting on the renin-angiotensin system
  ('lisinopril', 'C09AA03'),
  ('losartana', 'C09CA01'),
  -- C10 — Lipid modifying agents
  ('simvastatina', 'C10AA01'),
  ('rosuvastatina', 'C10AA07'),
  -- ==================================================================
  -- D — Dermatologicals
  -- ==================================================================
  -- D05 — Antipsoriatics
  ('acitretina', 'D05BB02'),
  -- D10 — Anti-acne preparations
  ('isotretinoina', 'D10BA01'),
  -- D06 — Antibiotics and chemotherapeutics for dermatological use
  ('mupirocina', 'D06AX09'),
  -- ==================================================================
  -- G — Genito-urinary system and sex hormones
  -- ==================================================================
  -- G03 — Sex hormones and modulators of the genital system
  ('medroxiprogesterona', 'G03DA02'),
  -- ==================================================================
  -- J — Antiinfectives for systemic use
  -- ==================================================================
  -- J01 — Antibacterials for systemic use
  ('cloranfenicol', 'J01BA01'),
  ('penicilina-g', 'J01CE09'),
  ('minociclina', 'J01AA08'),
  ('tetraciclina', 'J01AA07'),
  ('cefixima', 'J01DD08'),
  ('cefpodoxima', 'J01DD13'),
  ('clindamicina', 'J01FF01'),
  ('telitromicina', 'J01FA15'),
  ('ertapenem', 'J01DH03'),
  ('sulfametoxazol-trimetoprima', 'J01EW01'),
  -- J04 — Antimycobacterials
  -- J04A — Drugs for treatment of tuberculosis
  ('cicloserina', 'J04AB01'),
  ('capreomicina', 'J04AB30'),
  ('etionamida', 'J04AD03'),
  ('protionamida', 'J04AD01'),
  ('terizidona', 'J04AK03'),
  -- J04B — Drugs for treatment of leprosy
  ('clofazimina', 'J04BA01'),
  -- J05 — Antivirals for systemic use
  ('aciclovir', 'J05AB01'),
  ('didanosina', 'J05AF02'),
  ('estavudina', 'J05AF04'),
  ('tenofovir', 'J05AF07'),
  ('emtricitabina', 'J05AF09'),
  ('abacavir', 'J05AF06'),
  ('raltegravir', 'J05AJ01'),
  ('dolutegravir', 'J05AJ03'),
  ('etravirina', 'J05AG04'),
  ('rilpivirina', 'J05AG05'),
  ('darunavir', 'J05AE10'),
  ('lopinavir-ritonavir', 'J05AR10'),
  -- ==================================================================
  -- L — Antineoplastic and immunomodulating agents
  -- ==================================================================
  -- L01 — Antineoplastic agents
  ('ciclofosfamida', 'L01AA01'),
  -- L02 — Endocrine therapy
  ('megestrol', 'L02AB01'),
  ('flutamida', 'L02BB01'),
  ('degarelix', 'L02BX02'),
  -- L04 — Immunosuppressants
  ('micofenolato', 'L04AA06'),
  ('tacrolimus', 'L04AD02'),
  ('sirolimus', 'L04AH01'),
  -- ==================================================================
  -- M — Musculo-skeletal system
  -- ==================================================================
  -- M01 — Anti-inflammatory and antirheumatic products
  ('indometacina', 'M01AB01'),
  ('ketorolaco', 'M01AB15'),
  ('piroxicam', 'M01AC01'),
  ('meloxicam', 'M01AC06'),
  ('nimesulida', 'M01AX17'),
  ('penicilamina', 'M01CC01'),
  -- M03 — Muscle relaxants
  ('tizanidina', 'M03BX02'),
  -- M04 — Antigout preparations
  ('probenecida', 'M04AB01'),
  -- ==================================================================
  -- N — Nervous system
  -- ==================================================================
  -- N01 — Anesthetics
  ('cetamina', 'N01AX03'),
  -- N02 — Analgesics
  ('metadona', 'N02AC52'),
  -- N03 — Antiepileptics
  ('primidona', 'N03AA03'),
  ('eslicarbazepina', 'N03AF04'),
  ('oxcarbazepina', 'N03AF02'),
  ('etossuximida', 'N03CA04'),
  ('clonazepam', 'N03AE01'),
  ('topiramato', 'N03AX11'),
  ('gabapentina', 'N03AX12'),
  ('levetiracetam', 'N03AX14'),
  ('zonisamida', 'N03AX15'),
  ('pregabalina', 'N03AX16'),
  ('lacosamida', 'N03AX18'),
  -- N04 — Anti-Parkinson drugs
  ('amantadina', 'N04BB01'),
  ('levodopa', 'N04BA01'),
  -- N05 — Psycholeptics
  -- N05A — Antipsychotics
  ('pimozida', 'N05AG02'),
  ('risperidona', 'N05AX08'),
  ('aripiprazol', 'N05AX12'),
  ('olanzapina', 'N05AH03'),
  ('quetiapina', 'N05AH04'),
  -- N05B — Anxiolytics
  ('diazepam', 'N05BA01'),
  ('lorazepam', 'N05BA06'),
  -- N05C — Hypnotics and sedatives
  ('zolpidem', 'N05CF02'),
  -- N06 — Psychoanaleptics
  -- N06A — Antidepressants
  ('amitriptilina', 'N06AA09'),
  ('citalopram', 'N06AB04'),
  ('paroxetina', 'N06AB05'),
  ('escitalopram', 'N06AB10'),
  ('mirtazapina', 'N06AX11'),
  ('duloxetina', 'N06AX21'),
  ('venlafaxina', 'N06AX16'),
  -- N07 — Other nervous system drugs
  -- N07B — Drugs used in addictive disorders
  ('dissulfiram', 'N07BB01'),
  -- ==================================================================
  -- R — Respiratory system
  -- ==================================================================
  -- R03 — Drugs for obstructive airway diseases
  ('beclometasona', 'R03BA01'),
  ('fluticasona', 'R03BA05'),
  ('indacaterol', 'R03AC18'),
  ('roflumilast', 'R03DX07'),
  -- R06 — Antihistamines for systemic use
  ('azelastina', 'R06AX19'),
  -- ==================================================================
  -- S — Sensory organs
  -- ==================================================================
  -- S01 — Ophthalmologicals
  ('levocabastina', 'S01GX02'),
  -- ==================================================================
  -- V — Various
  -- ==================================================================
  ('naloxona', 'V03AB01')
) AS v(slug, atc_code)
WHERE d.slug = v.slug;
