-- =====================================================================
-- 227 — Tabela drug_classes + FK em drugs + seed + mapeamento
-- ---------------------------------------------------------------------
-- Cria a tabela drug_classes com ~30 classes amplas agrupando os 234
-- class_pt específicos existentes. Adiciona class_id FK à tabela drugs.
-- Seed com descrições placeholder (DailyMed/EMC/HealthCanada).
-- Mapeamento automático via WHERE clauses no class_pt existente.
-- =====================================================================

-- =====================================================================
-- 1. Tabela drug_classes
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.drug_classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  atc_prefix TEXT NOT NULL DEFAULT '',
  sort_order INT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_drug_classes_slug ON public.drug_classes(slug);

-- RLS
ALTER TABLE public.drug_classes ENABLE ROW LEVEL SECURITY;

-- Admin: full access
CREATE POLICY admin_all_drug_classes ON public.drug_classes
  FOR ALL
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- Anon: read published
CREATE POLICY anon_read_drug_classes ON public.drug_classes
  FOR SELECT
  USING (status = 'published' AND NOT is_archived);

-- =====================================================================
-- 2. FK em drugs
-- =====================================================================
ALTER TABLE public.drugs
  ADD COLUMN IF NOT EXISTS class_id UUID REFERENCES public.drug_classes(id) ON DELETE SET NULL;

-- =====================================================================
-- 3. Seed: ~30 classes amplas
-- =====================================================================
INSERT INTO public.drug_classes
  (slug, name_pt, name_en, description_pt, description_en, atc_prefix, sort_order)
VALUES
  ('antibacterianos', 'Antibacterianos', 'Antibacterials',
   'Os antibacterianos são medicamentos que combatem infeções bacterianas. Incluem múltiplas classes como penicilinas, cefalosporinas, macrólidos, fluorquinolonas, aminoglicosídeos e outros. Cada sub-classe atua por mecanismo distinto — desde a inibição da síntese da parede celular (beta-lactâmicos) até à bloqueio da síntese proteica (aminoglicosídeos, macrólidos). A escolha depende do espectro de atividade, farmacocinética e perfil de segurança.',
   'Antibacterials are drugs that fight bacterial infections. They include multiple classes such as penicillins, cephalosporins, macrolides, fluoroquinolones, aminoglycosides and others. Each sub-class acts by a distinct mechanism — from inhibition of cell wall synthesis (beta-lactams) to blockade of protein synthesis (aminoglycosides, macrolides). Choice depends on spectrum of activity, pharmacokinetics, and safety profile.',
   'J01', 10),

  ('antimicobacteriais', 'Antimicobacteriais', 'Antimycobacterials',
   'Os antimicobacteriais são usados para tratar tuberculose e lepra. Incluem fármacos de primeira linha (isoniazida, rifampicina, pirazinamida, etambutol) e de segunda linha (amikacina, capreomicina, clofazimina, cicloserina, etionamida). O tratamento da tuberculose exige terapêutica combinada prolongada (mínimo 6 meses) para prevenir resistência.',
   'Antimycobacterials are used to treat tuberculosis and leprosy. They include first-line drugs (isoniazid, rifampicin, pyrazinamide, ethambutol) and second-line agents (amikacin, capreomycin, clofazimine, cycloserine, ethionamide). TB treatment requires prolonged combination therapy (minimum 6 months) to prevent resistance.',
   'J04', 15),

  ('antivirais', 'Antivíricos', 'Antivirals',
   'Os antivíricos tratam infeções virais. Incluem análogos nucleósidos/nucleotídeos (aciclovir, tenofovir), inibidores da protease (darunavir), inibidores da integrase (dolutegravir) e inibidores da neuraminidase. Diferem dos antibacterianos por atuarem dentro das células hospedeiras, interferindo no ciclo de replicação viral.',
   'Antivirals treat viral infections. They include nucleos(t)ide analogues (acyclovir, tenofovir), protease inhibitors (darunavir), integrase inhibitors (dolutegravir) and neuraminidase inhibitors. Unlike antibacterials, they act inside host cells, interfering with the viral replication cycle.',
   'J05', 20),

  ('antiretrovirais', 'Antirretrovirais', 'Antiretrovirals',
   'Os antirretrovirais são usados no tratamento da infeção pelo VIH/SIDA. Agrupam-se em NRTIs, INTRIs, INSTIs, IPs e Farmacocenéticos. O tratamento padrão combina 3 ou mais fármacos de diferentes classes (terapêutica antirretroviral de elevada atividade — TARV) para suprimir a replicação viral e prevenir resistência.',
   'Antiretrovirals are used to treat HIV/AIDS. They include NRTIs, NNRTIs, INSTIs, PIs and Pharmacokinetic enhancers. Standard treatment combines 3+ drugs from different classes (highly active antiretroviral therapy — HAART) to suppress viral replication and prevent resistance.',
   'J05', 25),

  ('antifungicos', 'Antifúngicos', 'Antifungals',
   'Os antifúngicos tratam infeções por fungos. Incluem poliênicos (nistatina, anfotericina B), azóis (fluconazol, cetoconazol, voriconazol) e equinocandinas. Os azóis inibem a 14-alfa-desmetilase do CYP51, comprometendo a integridade da membrana fúngica.',
   'Antifungals treat fungal infections. They include polyenes (nystatin, amphotericin B), azoles (fluconazole, ketoconazole, voriconazole) and echinocandins. Azoles inhibit 14-alpha-demethylase (CYP51), compromising fungal membrane integrity.',
   'J02', 30),

  ('antimalaricos', 'Antimaláricos', 'Antimalarials',
   'Os antimaláricos prevenem e tratam a malária. Incluem cloroquina, hidroxicloroquina, mefloquina, artemeter-lumefantrina e sulfadoxina-pirimetamina. As combinações com artemisinina (ACT) são o padrão de ouro para malária não-complicada por P. falciparum.',
   'Antimalarials prevent and treat malaria. They include chloroquine, hydroxychloroquine, mefloquine, artemether-lumefantrine and sulfadoxine-pyrimethamine. Artemisinin-based combinations (ACTs) are the gold standard for uncomplicated P. falciparum malaria.',
   'P01', 35),

  ('cardiovasculares', 'Cardiovasculares', 'Cardiovasculars',
   'Os cardiovasculars incluem IECA, BRA, bloqueadores dos canais de cálcio, betabloqueadores, diuréticos, estatinas, nitratos e antiarrítmicos. Atuam no sistema cardiovascular para tratar hipertensão, insuficiência cardíaca, arritmias e doenças ateroscleróticas.',
   'Cardiovasculars include ACE inhibitors, ARBs, calcium channel blockers, beta-blockers, diuretics, statins, nitrates and antiarrhythmics. They act on the cardiovascular system to treat hypertension, heart failure, arrhythmias and atherosclerotic disease.',
   'C', 40),

  ('anticoagulantes', 'Anticoagulantes e Antitrombóticos', 'Anticoagulants & Antithrombotics',
   'Os anticoagulantes e antitrombóticos prevenem e tratam tromboses. Incluem cumarínicos (varfarina), DOACs (dabigatrano, rivaroxabano, apixabano), antiagregantes plaquetários (aspirina, clopidogrel, ticagrelor) e heparinas (enoxaparina). A choice depends on indication, renal function and drug interactions.',
   'Anticoagulants and antithrombotics prevent and treat thrombosis. They include coumarins (warfarin), DOACs (dabigatran, rivaroxaban, apixaban), antiplatelet agents (aspirin, clopidogrel, ticagrelor) and heparins (enoxaparin). Choice depends on indication, renal function and drug interactions.',
   'B01', 45),

  ('antiepilepticos', 'Antiepilépticos', 'Antiepileptics',
   'Os antiepilépticos controlam convulsões e epilepsia. Incluem bloqueadores de canais de sódio (fenitoína, carbamazepina, lamotrigina), moduladores de GABA (valproato, benzodiazepinas), e fármacos de mecanismo variado (levetiracetam, gabapentina, pregabalina, topiramato).',
   'Antiepileptics control seizures and epilepsy. They include sodium channel blockers (phenytoin, carbamazepine, lamotrigine), GABA modulators (valproate, benzodiazepines), and drugs with varied mechanisms (levetiracetam, gabapentin, pregabalin, topiramate).',
   'N03', 50),

  ('antipsicoticos', 'Antipsicóticos', 'Antipsychotics',
   'Os antipsicóticos tratam esquizofrenia, perturbações bipolares e outros distúrbios psicóticos. Dividem-se em típicos (haloperidol, pimozida) e atípicos (risperidona, olanzapina, quetiapina, aripiprazol, clozapina). Os atípicos têm menor risco de efeitos extrapiramidais mas maior risco metabólico.',
   'Antipsychotics treat schizophrenia, bipolar disorder and other psychotic disorders. They include typical (haloperidol, pimozide) and atypical (risperidone, olanzapine, quetiapine, aripiprazole, clozapine) agents. Atypicals have lower risk of extrapyramidal effects but higher metabolic risk.',
   'N05A', 55),

  ('antidepressivos', 'Antidepressivos', 'Antidepressants',
   'Os antidepressivos tratam a depressão e perturbações de ansiedade. Incluem ISRS (fluoxetina, sertralina, paroxetina, escitalopram, citalopram), IRSN (venlafaxina, duloxetina), tricíclicos (amitriptilina) e NaSSA (mirtazapina). Os ISRS são primeira linha pela melhor tolerabilidade.',
   'Antidepressants treat depression and anxiety disorders. They include SSRIs (fluoxetine, sertraline, paroxetine, escitalopram, citalopram), SNRIs (venlafaxine, duloxetine), tricyclics (amitriptyline) and NaSSA (mirtazapine). SSRIs are first-line due to better tolerability.',
   'N06A', 60),

  ('ansioliticos', 'Ansiolíticos e Hipnóticos', 'Anxiolytics & Hypnotics',
   'Os ansiolíticos e hipnóticos tratam ansiedade e insónia. Incluem benzodiazepinas (diazepam, lorazepam, clonazepam), Z-drugs (zolpidem) e outros. As benzodiazepinas potenciam o GABA no recetor GABA-A, produzindo efeitos ansiolíticos, sedativos e relaxantes musculares.',
   'Anxiolytics and hypnotics treat anxiety and insomnia. They include benzodiazepines (diazepam, lorazepam, clonazepam), Z-drugs (zolpidem) and others. Benzodiazepines potentiate GABA at the GABA-A receptor, producing anxiolytic, sedative and muscle relaxant effects.',
   'N05B', 65),

  ('analgesicos', 'Analgésicos', 'Analguesics',
   'Os analgésicos aliviam a dor. Incluem opióides (morfina, fentanilo, tramadol, metadona, codeina), AINE (ibuprofeno, naproxeno, diclofenaco) e paracetamol. Os opióides atuam nos recetores mu, kappa e delta; os AINE inibem COX-1/COX-2 reduzindo prostaglandinas.',
   'Analguesics relieve pain. They include opioids (morphine, fentanyl, tramadol, methadone, codeine), NSAIDs (ibuprofen, naproxen, diclofenac) and paracetamol. Opioids act on mu, kappa and delta receptors; NSAIDs inhibit COX-1/COX-2 reducing prostaglandins.',
   'N02', 70),

  ('antiparkinsonianos', 'Antiparkinsonianos', 'Anti-Parkinson Drugs',
   'Os antiparkinsonianos tratam a doença de Parkinson. Incluem levodopa (precursor da dopamina), agonistas dopaminérgicos, inibidores da MAO-B, inibidores da COMT e amantadina. A levodopa + inhibidor da descarboxilase é a terapêutica de referência.',
   'Anti-Parkinson drugs treat Parkinson\'s disease. They include levodopa (dopamine precursor), dopamine agonists, MAO-B inhibitors, COMT inhibitors and amantadine. Levodopa + decarboxylase inhibitor is the standard therapy.',
   'N04', 75),

  ('antidiabeticos', 'Antidiabéticos', 'Antidiabetics',
   'Os antidiabéticos tratam a diabetes mellitus tipo 2. Incluem metformina (biguanida), sulfonilureias (glibenclamida, gliclazida), inibidores da DPP-4 (sitagliptina), inibidores do SGLT2 (dapagliflozina), agonistas do GLP-1 (liraglutida) e tiazolidinedionas (pioglitazona).',
   'Antidiabetics treat type 2 diabetes mellitus. They include metformin (biguanide), sulfonylureas (glibenclamide, gliclazide), DPP-4 inhibitors (sitagliptin), SGLT2 inhibitors (dapagliflozin), GLP-1 agonists (liraglutide) and thiazolidinediones (pioglitazone).',
   'A10', 80),

  ('respiratorios', 'Respiratórios', 'Respiratory Drugs',
   'Os respiratórios tratam doenças obstrutivas das vias aéreas (asma, DPOC). Incluem broncodilatadores (SABA como salbutamol, LABA como salmeterol/formoterol, LAMA como tiotropio), corticosteroides inalados (budesonida, fluticasona), e antagonistas dos leucotrienos (montelucaste).',
   'Respiratory drugs treat obstructive airway diseases (asthma, COPD). They include bronchodilators (SABA like salbutamol, LABA like salmeterol/formoterol, LAMA like tiotropium), inhaled corticosteroids (budesonide, fluticasone), and leukotriene antagonists (montelukast).',
   'R03', 85),

  ('gastrointestinais', 'Gastrointestinais', 'Gastrointestinal Drugs',
   'Os gastrointestinais tratam doenças do trato digestivo. Incluem IBP (omeprazol), antagonistas H2 (famotidina), procinéticos (metoclopramida, domperidona), antiácidos, antidiarreicos (loperamida) e mucolíticos (acetilcisteína).',
   'Gastrointestinal drugs treat digestive tract diseases. They include PPIs (omeprazole), H2 antagonists (famotidine), prokinetics (metoclopramide, domperidone), antacids, antidiarrheals (loperamide) and mucolytics (acetylcysteine).',
   'A02', 90),

  ('hormonas', 'Hormonas e Endocrinologia', 'Hormones & Endocrinology',
   'As hormonas e moduladores endócrinos incluem levotiroxina, tiamazol, estradiol, medroxiprogesterona, degarelix, anastrozol, tamoxifeno, calcitriol, colecalciferol e folinato de cálcio. Atuam no sistema endócrino para substituir hormonas em falta ou bloquear a sua ação.',
   'Hormones and endocrine modulators include levothyroxine, thiamazole, estradiol, medroxyprogesterone, degarelix, anastrozole, tamoxifen, calcitriol, cholecalciferol and calcium folinate. They act on the endocrine system to replace deficient hormones or block their action.',
   'H', 95),

  ('imunossupressores', 'Imunossupressores', 'Immunosuppressants',
   'Os imunossupressores preveem e tratam a rejeição de transplantes e doenças autoimunes. Incluem tacrolimus (inibidor da calcineurina), micofenolato (inibidor da IMPDH), sirolimus (inibidor do mTOR), ciclosporina, azatioprina e metotrexato.',
   'Immunosuppressants prevent and treat transplant rejection and autoimmune diseases. They include tacrolimus (calcineurin inhibitor), mycophenolate (IMPDH inhibitor), sirolimus (mTOR inhibitor), ciclosporin, azathioprine and methotrexate.',
   'L04', 100),

  ('antineoplasicos', 'Antineoplásicos', 'Antineoplastics',
   'Os antineoplásicos tratam o cancro. Incluem citotóxicos alquilantes (ciclofosfamida), hormonais (anastrozol, tamoxifeno, degarelix, flutamida, megestrol) e moduladores do recetor de estrogénio. A quimioterapia combina frequentemente múltiplos agentes.',
   'Antineoplastics treat cancer. They include alkylating agents (cyclophosphamide), hormonal agents (anastrozole, tamoxifen, degarelix, flutamide, megestrol) and selective estrogen receptor modulators. Chemotherapy often combines multiple agents.',
   'L', 105),

  ('musculoesqueleticos', 'Musculoesqueléticos', 'Musculoskeletal Drugs',
   'Os musculoesqueléticos tratam doenças do sistema musculoesquelético. Incluem AINE (ibuprofeno, diclofenaco, nimesulida), antagotosos (colchicina, alopurinol, febuxostat), bifosfonatos (alendronato) e relaxantes musculares (tizanidina).',
   'Musculoskeletal drugs treat musculoskeletal diseases. They include NSAIDs (ibuprofen, diclofenac, nimesulide), antigout agents (colchicine, allopurinol, febuxostat), bisphosphonates (alendronate) and muscle relaxants (tizanidine).',
   'M', 110),

  ('antidotoss', 'Antídotos', 'Antidotes',
   'Os antídotos neutralizam ou拮抗am venenos e efeitos adversos de fármacos. Incluem naloxona (antagonista opioide — resgate de overdose de opioides), carvão ativado (adsorvente — maioria dos venenos), dissulfiram (inibidor da ALDH — dependência alcoólica) e folinato de cálcio (resgate do metotrexato).',
   'Antidotes neutralize or antagonize poisons and adverse drug effects. They include naloxone (opioid antagonist — opioid overdose rescue), activated charcoal (adsorbent — most poisons), disulfiram (ALDH inhibitor — alcohol dependence) and calcium folinate (methotrexate rescue).',
   'V03', 115),

  ('snc_outros', 'Outros do Sistema Nervoso', 'Other Nervous System Drugs',
   'Outros fármacos do sistema nervoso incluem anticolinesterásicos para Alzheimer (donepezilo, memantina), antiespasmódicos (hioscina), levodopa, cetamina (anestésico dissociativo), agonistas alfa-2 (tizanidina) e outros que atuam no SNC.',
   'Other nervous system drugs include anticholinesterase for Alzheimer\'s (donepezil, memantine), antispasmodics (scopolamine), levodopa, ketamine (dissociative anaesthetic), alpha-2 agonists (tizanidine) and others acting on the CNS.',
   'N', 120),

  ('nutricao', 'Nutrição e Eletrólitos', 'Nutrition & Electrolytes',
   'Nutrição e eletrólitos incluem soluções de aminoácidos, emulsões lipídicas, glicose, cloreto de potássio, sulfato de magnésio, ácido ascórbico, ácido fólico, cianocobalamina, ferro, zinco, colecalciferol e calcitriol. Usados em nutrição parentérica, correção de deficiências e suporte nutricional.',
   'Nutrition and electrolytes include amino acid solutions, lipid emulsions, glucose, potassium chloride, magnesium sulfate, ascorbic acid, folic acid, cyanocobalamin, iron, zinc, cholecalciferol and calcitriol. Used in parenteral nutrition, deficiency correction and nutritional support.',
   'B05', 125),

  ('anti_helminticos', 'Anti-helmínticos e Antiparasitários', 'Anthelmintics & Antiparasitics',
   'Anti-helmínticos e antiparasitários tratam infeções por parasitas. Incluem praziquantel (céstodos e tremátodos), metronidazol (protozoários), cotrimoxazol (Pneumocystis) e ivermectina.',
   'Anthelmintics and antiparasitics treat parasitic infections. They include praziquantel (cestodes and trematodes), metronidazole (protozoa), co-trimoxazole (Pneumocystis) and ivermectin.',
   'P02', 130),

  ('dermatologicos', 'Dermatológicos', 'Dermatologicals',
   'Os dermatológicos tratam doenças da pele. Incluem retinóides sistémicos (isotretinoína para acne severa, acitretina para psoríase), antibióticos tópicos (mupirocina) e antifúngicos tópicos.',
   'Dermatologicals treat skin diseases. They include systemic retinoids (isotretinoin for severe acne, acitretin for psoriasis), topical antibiotics (mupirocin) and topical antifungals.',
   'D', 135),

  ('anestesicos', 'Anestésicos', 'Anaesthetics',
   'Os anestésicos induzem perda reversível de consciência e/ou sensação. Incluem cetamina (anestésico dissociativo — antagonista NMDA) e outros usados em contexto hospitalar.',
   'Anaesthetics induce reversible loss of consciousness and/or sensation. They include ketamine (dissociative anaesthetic — NMDA antagonist) and others used in hospital settings.',
   'N01', 140),

  ('outros', 'Outros', 'Others',
   'Fármacos que não se encaixam nas classes acima, incluindo fatores de crescimento hematopoiético (filgrastim, epoetina alfa), surfactante pulmonar, anti-alérgicos e outros.',
   'Drugs not fitting the above classes, including haematopoietic growth factors (filgrastim, epoetin alfa), pulmonary surfactant, anti-allergics and others.',
   'V', 145)

ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- 4. Mapeamento: UPDATE drugs SET class_id
-- =====================================================================

-- antibacterianos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antibacterianos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antibiótico%' OR class_pt ILIKE '%Antibacteriano%'
  OR slug IN ('penicilina-g','sulfametoxazol-trimetoprima','clindamicina','cefepima','cefixima',
    'cefpodoxima','telitromicina','ertapenem','cloranfenicol','minociclina','tetraciclina',
    'fosfomicina','daptomicina','aciclovir','nitrofurantoina')
);

-- antimicobacteriais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimicobacteriais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antituberculoso%' OR class_pt ILIKE '%Tubercul%'
  OR slug IN ('isoniazida','rifampicina','pirazinamida','etambutol','bedaquilina',
    'estreptomicina','cicloserina','clofazimina','amicacina','etionamida','protionamida',
    'terizidona','capreomicina','rifabutina')
);

-- antivirais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antivirais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antivírico%' OR class_pt ILIKE '%Antivir%'
);

-- antiretrovirais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiretrovirais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antirretroviral%'
  OR slug IN ('tenofovir','emtricitabina','dolutegravir','lopinavir-ritonavir','darunavir',
    'abacavir','raltegravir','etravirina','rilpivirina','estavudina','didanosina')
);

-- antifungicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antifungicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antifúngico%'
  OR slug IN ('fluconazol','cetoconazol','voriconazol','itraconazol','nistatina')
);

-- antimalaricos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimalaricos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antimalárico%'
  OR slug IN ('cloroquina','hidroxicloroquina','mefloquina','artemeter-lumefantrina',
    'artesunato','artesunato-amodiaquina','atovaquona-proguanil','primaquina',
    'tafenoquina','sulfadoxina-pirimetamina','diidroartemisinina-piperaquina','quinina')
);

-- cardiovasculares
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'cardiovasculares')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%IECA%' OR class_pt ILIKE '%inibidor%enzima%conversora%'
  OR class_pt ILIKE '%BRA%' OR class_pt ILIKE '%Bloqueador%angiotensina%'
  OR class_pt ILIKE '%Bloqueador%canais%cálcio%' OR class_pt ILIKE '%Betabloqueador%'
  OR class_pt ILIKE '%Diurético%' OR class_pt ILIKE '%Estatin%'
  OR class_pt ILIKE '%Nitrato%' OR class_pt ILIKE '%Antiarrítmico%'
  OR class_pt ILIKE '%Glicósido%cardíaco%' OR class_pt ILIKE '%Alfabloqueante%'
  OR class_pt ILIKE '%Inibidor%canal%If%' OR class_pt ILIKE '%Inibidor%5-alfa-redutase%'
  OR slug IN ('lisinopril','losartana','nifedipina','metoprolol','atenolol','propranolol',
    'carvedilol','bisoprolol','rosuvastatina','simvastatina','isossorbida','verapamilo',
    'diltiazem','ivabradina','tansulosina','finasterida','dutasterida')
);

-- anticoagulantes
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anticoagulantes')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Anticoagulante%' OR class_pt ILIKE '%Antiagregante%'
  OR class_pt ILIKE '%Heparina%' OR class_pt ILIKE '%Antitrombótico%'
  OR slug IN ('warfarina','dabigatrano','rivaroxabano','apixabano','clopidogrel',
    'ticagrelor','enoxaparina','fondaparinux','acenocumarol','aspirina')
);

-- antiepilepticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiepilepticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antiepiléptico%' OR class_pt ILIKE '%Antiepilético%'
  OR slug IN ('carbamazepina','fenitoina','valproato','lamotrigina','levetiracetam',
    'gabapentina','pregabalina','topiramato','oxcarbazepina','eslicarbazepina',
    'etossuximida','clonazepam','zonisamida','lacosamida','primidona')
);

-- antipsicoticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antipsicoticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antipsicótico%' OR class_pt ILIKE '%neuroléptico%'
  OR slug IN ('risperidona','olanzapina','quetiapina','aripiprazol','clozapina',
    'haloperidol','pimozida')
);

-- antidepressivos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidepressivos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%ISRS%' OR class_pt ILIKE '%IRSN%'
  OR class_pt ILIKE '%Antidepressivo%' OR class_pt ILIKE '%Inibidor%recaptação%serotonina%'
  OR class_pt ILIKE '%tricíclico%' OR class_pt ILIKE '%NaSSA%'
  OR slug IN ('fluoxetina','sertralina','paroxetina','citalopram','escitalopram',
    'venlafaxina','duloxetina','amitriptilina','mirtazapina')
);

-- ansioliticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'ansioliticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Benzodiazepina%' OR class_pt ILIKE '%ansiolítico%'
  OR class_pt ILIKE '%Hipnótico%' OR class_pt ILIKE '%sedativo%'
  OR slug IN ('diazepam','lorazepam','clonazepam','zolpidem','alprazolam')
);

-- antiparkinsonianos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiparkinsonianos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antiparkinsónico%' OR class_pt ILIKE '%precursor%dopamina%'
  OR slug IN ('amantadina','levodopa')
);

-- antidiabeticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidiabeticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%antidiabético%' OR class_pt ILIKE '%Biguanida%'
  OR class_pt ILIKE '%Sulfonilureia%' OR class_pt ILIKE '%DPP-4%'
  OR class_pt ILIKE '%SGLT2%' OR class_pt ILIKE '%GLP-1%'
  OR class_pt ILIKE '%Tiazolidinediona%' OR class_pt ILIKE '%alfa-glucosidase%'
  OR slug IN ('metformina','glibenclamida','gliclazida','glimepirida','sitagliptina',
    'vildagliptina','saxagliptina','dapagliflozina','canagliflozina','empagliflozina',
    'liraglutida','dulaglutida','pioglitazona','acarbose')
);

-- respiratorios
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'respiratorios')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Broncodilatador%' OR class_pt ILIKE '%Corticosteroide%inal%'
  OR class_pt ILIKE '%Corticosteroide inalado%' OR class_pt ILIKE '%CSI%'
  OR class_pt ILIKE '%LTRA%' OR class_pt ILIKE '%leucotrieno%'
  OR class_pt ILIKE '%Mucolítico%' OR class_pt ILIKE '%Surfactante%'
  OR class_pt ILIKE '%PDE4%' OR class_pt ILIKE '%fosfodiesterase%'
  OR slug IN ('salbutamol','salmeterol','formoterol','budesonida','fluticasona',
    'beclometasona','tiotropio','ipratropio','montelukast','roflumilast',
    'indacaterol','teofilina','acetilcisteina','poractant_alfa')
);

-- gastrointestinais
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'gastrointestinais')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%IBP%' OR class_pt ILIKE '%anti-ulceroso%'
  OR class_pt ILIKE '%Antiácido%' OR class_pt ILIKE '%Procinético%'
  OR class_pt ILIKE '%Antiemético%' OR class_pt ILIKE '%Antidiarreico%'
  OR class_pt ILIKE '%ácido%biliar%' OR class_pt ILIKE '%H2%'
  OR slug IN ('omeprazol','famotidina','cimetidina','metoclopramida','domperidona',
    'loperamida','ondansetron','antiacidos','sucralfato','acido_ursodesoxicolico',
    'butilbrometo_hioscina','mesalazina','sulfassalazina','nistatina')
);

-- hormonas
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'hormonas')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Hormona%' OR class_pt ILIKE '%Estrogénio%'
  OR class_pt ILIKE '%Progestagénio%' OR class_pt ILIKE '%Antitiroideu%'
  OR class_pt ILIKE '%Aromatase%' OR class_pt ILIKE '%SERM%'
  OR class_pt ILIKE '%Modulador%estrogénio%'
  OR slug IN ('levotiroxina','tiamazol','estradiol','medroxiprogesterona','megestrol',
    'degarelix','anastrozol','tamoxifeno','flutamida','calcitriol','colecalciferol',
    'acido_folico','folinato_calcio')
);

-- imunossupressores
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'imunossupressores')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Imunossupressor%' OR class_pt ILIKE '%DMARD%'
  OR slug IN ('tacrolimus','micofenolato','sirolimus','ciclosporina','azatioprina',
    'metotrexato','leflunomida')
);

-- antineoplasicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antineoplasicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Citotóxico%' OR class_pt ILIKE '%antitumoral%'
  OR slug IN ('ciclofosfamida')
);

-- musculoesqueleticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'musculoesqueleticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%AINE%' OR class_pt ILIKE '%Anti-inflamatório%'
  OR class_pt ILIKE '%antigotoso%' OR class_pt ILIKE '%Uricosúrico%'
  OR class_pt ILIKE '%Relaxante%muscular%'
  OR slug IN ('ibuprofeno','diclofenaco','naproxeno','celecoxib','ketorolaco',
    'piroxicam','meloxicam','nimesulida','indometacina','colchicina','alopurinol',
    'febuxostat','penicilamina','alendronato','tizanidina')
);

-- antidotoss
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidotoss')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Antídoto%' OR class_pt ILIKE '%anti-alcoólico%'
  OR slug IN ('naloxona','dissulfiram')
);

-- snc_outros
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'snc_outros')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Acetilcolinesterase%' OR class_pt ILIKE '%Alzheimer%'
  OR class_pt ILIKE '%Antiespasmódico%'
  OR slug IN ('donepezilo','memantina','levodopa')
);

-- nutricao
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'nutricao')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Nutrição%' OR class_pt ILIKE '%Eletrólito%'
  OR class_pt ILIKE '%Vitamina%' OR class_pt ILIKE '%Sais%minerais%'
  OR class_pt ILIKE '%Oligoelemento%'
  OR slug IN ('aminoacidos','emulsao_lipidica','glicose','cloreto_potassio',
    'sulfato_magnesio','acido_ascorbico','cianocobalamina','ferro','zinco')
);

-- anti_helminticos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anti_helminticos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Anti-helmíntico%' OR class_pt ILIKE '%Bacteriano%antiparasitário%'
  OR slug IN ('praziquantel','metronidazol','cotrimoxazol')
);

-- dermatologicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'dermatologicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Retinóide%' OR class_pt ILIKE '%tópico%dérmico%'
  OR slug IN ('isotretinoina','acitretina','mupirocina')
);

-- anestesicos
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anestesicos')
WHERE class_id IS NULL AND (
  class_pt ILIKE '%Anestésico%'
  OR slug IN ('cetamina')
);

-- outros (fallback: drugs still without class_id)
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'outros')
WHERE class_id IS NULL AND status = 'published';
