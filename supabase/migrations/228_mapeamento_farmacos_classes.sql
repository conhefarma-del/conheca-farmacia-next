-- =====================================================================
-- 228 — Mapeamento de 43 fármacos ausentes na migração 227
-- ---------------------------------------------------------------------
-- Migração corretiva: adiciona class_id a 43 fármacos que não foram
-- capturados pelas WHERE clauses da 227 (class_pt diferente do esperado).
-- Idempotente: só atualiza drugs.class_id NULL.
-- =====================================================================

-- =====================================================================
-- Antibacterianos (11 fármacos)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antibacterianos')
WHERE class_id IS NULL AND slug IN (
  'amoxicilina',        -- Penicilina
  'azitromicina',       -- Macrólido (azálido)
  'ciprofloxacina',     -- Fluorquinolona
  'claritromicina',     -- Macrólido
  'doxiciclina',        -- Tetraciclina
  'eritromicina',       -- Macrólido
  'gentamicina',        -- Aminoglicosídeo
  'levofloxacina',      -- Fluorquinolona
  'moxifloxacina',      -- Fluorquinolona
  'tobramicina',        -- Aminoglicosídeo
  'vancomicina'         -- Glicopéptido
);

-- =====================================================================
-- Antimicobacteriais (1 fármaco — já mapeado na 227, mas reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimicobacteriais')
WHERE class_id IS NULL AND slug IN (
  'amantadina'          -- Antiparkinsónico / antiviral (reforço)
);

-- =====================================================================
-- Antivíricos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antivirais')
WHERE class_id IS NULL AND slug IN (
  'aciclovir'
);

-- =====================================================================
-- Antirretrovirais (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiretrovirais')
WHERE class_id IS NULL AND slug IN (
  'tenofovir', 'emtricitabina', 'dolutegravir', 'lopinavir-ritonavir',
  'darunavir', 'abacavir', 'raltegravir', 'etravirina', 'rilpivirina',
  'estavudina', 'didanosina'
);

-- =====================================================================
-- Antifúngicos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antifungicos')
WHERE class_id IS NULL AND slug IN (
  'fluconazol', 'cetoconazol', 'voriconazol', 'itraconazol', 'nistatina'
);

-- =====================================================================
-- Antimaláricos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimalaricos')
WHERE class_id IS NULL AND slug IN (
  'cloroquina', 'hidroxicloroquina', 'mefloquina', 'artemeter-lumefantrina',
  'artesunato', 'artesunato-amodiaquina', 'atovaquona-proguanil',
  'primaquina', 'tafenoquina', 'sulfadoxina-pirimetamina',
  'diidroartemisinina-piperaquina', 'quinina'
);

-- =====================================================================
-- Cardiovasculares (5 fármacos)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'cardiovasculares')
WHERE class_id IS NULL AND slug IN (
  'amlodipina',         -- Bloqueador dos canais de cálcio (DHP)
  'losartano',          -- ARA II
  'valsartana',         -- ARA II
  'digoxina',           -- Glicósido cardíaco
  'midodrina',          -- Simpaticomimético (agonista alfa-1)
  'lisinopril',         -- IECA (reforço)
  'metoprolol',         -- Betabloqueador (reforço)
  'atenolol',           -- Betabloqueador (reforço)
  'propranolol',        -- Betabloqueador (reforço)
  'carvedilol',         -- Betabloqueador (reforço)
  'bisoprolol',         -- Betabloqueador (reforço)
  'rosuvastatina',      -- Estatina (reforço)
  'simvastatina',       -- Estatina (reforço)
  'nifedipina',         -- BCC (reforço)
  'verapamilo',         -- BCC (reforço)
  'diltiazem',          -- BCC (reforço)
  'ivabradina',         -- Inibidor do canal If (reforço)
  'isossorbida'         -- Nitrato (reforço)
);

-- =====================================================================
-- Anticoagulantes (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anticoagulantes')
WHERE class_id IS NULL AND slug IN (
  'warfarina', 'dabigatrano', 'rivaroxabano', 'apixabano',
  'clopidogrel', 'ticagrelor', 'enoxaparina', 'fondaparinux',
  'acenocumarol', 'aspirina'
);

-- =====================================================================
-- Antiepilépticos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiepilepticos')
WHERE class_id IS NULL AND slug IN (
  'carbamazepina', 'fenitoina', 'valproato', 'lamotrigina',
  'levetiracetam', 'gabapentina', 'pregabalina', 'topiramato',
  'oxcarbazepina', 'eslicarbazepina', 'etossuximida', 'clonazepam',
  'zonisamida', 'lacosamida', 'primidona'
);

-- =====================================================================
-- Antipsicóticos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antipsicoticos')
WHERE class_id IS NULL AND slug IN (
  'risperidona', 'olanzapina', 'quetiapina', 'aripiprazol',
  'clozapina', 'haloperidol', 'pimozida'
);

-- =====================================================================
-- Antidepressivos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidepressivos')
WHERE class_id IS NULL AND slug IN (
  'fluoxetina', 'sertralina', 'paroxetina', 'citalopram',
  'escitalopram', 'venlafaxina', 'duloxetina', 'amitriptilina',
  'mirtazapina'
);

-- =====================================================================
-- Ansiolíticos e Hipnóticos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'ansioliticos')
WHERE class_id IS NULL AND slug IN (
  'diazepam', 'lorazepam', 'clonazepam', 'zolpidem', 'alprazolam'
);

-- =====================================================================
-- Analgésicos (8 fármacos)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'analgesicos')
WHERE class_id IS NULL AND slug IN (
  'morfina',             -- Analgésico opioide
  'fentanilo',           -- Analgésico opioide potente
  'tramadol',            -- Analgésico opioide
  'codeina',             -- Analgésico opioide (fraco)
  'buprenorfina',        -- Analgésico opioide (agonista parcial)
  'hidromorfona',        -- Analgésico opioide potente
  'metamizol',           -- Analgésico e antipirético (pirazolona)
  'paracetamol',         -- Analgésico e antipirético
  'metadona'             -- Opioide sintético (reforço — já mapeado em antidotos mas首要 é analgésico)
);

-- =====================================================================
-- Antiparkinsonianos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiparkinsonianos')
WHERE class_id IS NULL AND slug IN (
  'amantadina', 'levodopa'
);

-- =====================================================================
-- Antidiabéticos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidiabeticos')
WHERE class_id IS NULL AND slug IN (
  'metformina', 'glibenclamida', 'gliclazida', 'glimepirida',
  'sitagliptina', 'vildagliptina', 'saxagliptina',
  'dapagliflozina', 'canagliflozina', 'empagliflozina',
  'liraglutida', 'dulaglutida', 'pioglitazona', 'acarbose'
);

-- =====================================================================
-- Respiratórios (5 fármacos)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'respiratorios')
WHERE class_id IS NULL AND slug IN (
  'salbutamol', 'salmeterol', 'formoterol', 'budesonida', 'fluticasona',
  'beclometasona', 'tiotropio', 'ipratropio', 'montelukast', 'roflumilast',
  'indacaterol', 'teofilina', 'acetilcisteina', 'poractant_alfa',
  'azelastina',         -- Anti-histamínico tópico nasal
  'dextrometorfano',    -- Antitússico
  'pseudoefedrina',     -- Descongestionante nasal
  'cetirizina',         -- Anti-histamínico H1
  'desloratadina',      -- Anti-histamínico H1
  'fexofenadina',       -- Anti-histamínico H1
  'levocabastina',      -- Anti-histamínico tópico
  'levocetirizina'      -- Anti-histamínico H1
);

-- =====================================================================
-- Gastrointestinais (2 fármacos)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'gastrointestinais')
WHERE class_id IS NULL AND slug IN (
  'omeprazol', 'famotidina', 'cimetidina', 'metoclopramida', 'domperidona',
  'loperamida', 'ondansetron', 'sucralfato', 'acido_ursodesoxicolico',
  'butilbrometo_hioscina', 'mesalazina', 'sulfassalazina', 'nistatina',
  'orlistat',           -- Inibidor das lipases (anti-obesidade)
  'colestiramina'       -- Sequestrante de ácidos biliares
);

-- =====================================================================
-- Hormonas e Endocrinologia (4 fármacos)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'hormonas')
WHERE class_id IS NULL AND slug IN (
  'levotiroxina', 'tiamazol', 'estradiol', 'medroxiprogesterona',
  'degarelix', 'anastrozol', 'tamoxifeno', 'flutamida', 'calcitriol',
  'colecalciferol', 'acido_folico', 'folinato_calcio',
  'dexametasona',       -- Corticosteroide sistémico
  'prednisolona',       -- Corticosteroide
  'epoetina_alfa',      -- Eritropoietina
  'filgrastim',         -- G-CSF
  'acido_tranexamico'   -- Antifibrinolítico
);

-- =====================================================================
-- Imunossupressores (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'imunossupressores')
WHERE class_id IS NULL AND slug IN (
  'tacrolimus', 'micofenolato', 'sirolimus', 'ciclosporina',
  'azatioprina', 'metotrexato', 'leflunomida'
);

-- =====================================================================
-- Musculoesqueléticos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'musculoesqueleticos')
WHERE class_id IS NULL AND slug IN (
  'ibuprofeno', 'diclofenaco', 'naproxeno', 'celecoxib', 'ketorolaco',
  'piroxicam', 'meloxicam', 'nimesulida', 'indometacina', 'colchicina',
  'alopurinol', 'febuxostat', 'penicilamina', 'alendronato', 'tizanidina'
);

-- =====================================================================
-- Antídotos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidotoss')
WHERE class_id IS NULL AND slug IN (
  'naloxona', 'dissulfiram'
);

-- =====================================================================
-- Nutrição e Eletrólitos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'nutricao')
WHERE class_id IS NULL AND slug IN (
  'aminoacidos', 'emulsao_lipidica', 'glicose', 'cloreto_potassio',
  'sulfato_magnesio', 'acido_ascorbico', 'cianocobalamina', 'ferro', 'zinco',
  'carbonato_calcio'     -- Sais minerais (cálcio)
);

-- =====================================================================
-- Anti-helmínticos e Antiparasitários (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anti_helminticos')
WHERE class_id IS NULL AND slug IN (
  'praziquantel', 'metronidazol'
);

-- =====================================================================
-- Dermatológicos (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'dermatologicos')
WHERE class_id IS NULL AND slug IN (
  'isotretinoina', 'acitretina', 'mupirocina'
);

-- =====================================================================
-- Outros do Sistema Nervoso (reforço)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'snc_outros')
WHERE class_id IS NULL AND slug IN (
  'donepezilo', 'memantina'
);

-- =====================================================================
-- Cardiovasculares (reforço — adrenalin etc.)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'cardiovasculares')
WHERE class_id IS NULL AND slug IN (
  'adrenalina'          -- Simpaticomimético (catecolamina α/β)
);

-- =====================================================================
-- Fallback: qualquer fármaco publicado sem class_id vai para 'outros'
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'outros')
WHERE class_id IS NULL AND status = 'published';
