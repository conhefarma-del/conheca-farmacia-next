-- =====================================================================
-- 231 — Forçar mapeamento de TODOS os fármacos para as classes corretas
-- ---------------------------------------------------------------------
-- As migrações 228/229/230 usavam WHERE class_id IS NULL, mas a 227
-- já tinha colocado esses fármacos em 'outros' via fallback. Resultado:
-- os fármacos ficaram presos em 'outros' mesmo depois das correções.
-- Esta migração força ATUALIZAR class_id para TODOS os fármacos,
-- independentemente do valor atual.
-- =====================================================================

-- =====================================================================
-- Antibacterianos (J01)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antibacterianos')
WHERE slug IN (
  'penicilina-g','sulfametoxazol-trimetoprima','clindamicina','cefepima','cefixima',
  'cefpodoxima','telitromicina','ertapenem','cloranfenicol','minociclina','tetraciclina',
  'fosfomicina','daptomicina','nitrofurantoina','amoxicilina','azitromicina',
  'ciprofloxacina','claritromicina','doxiciclina','eritromicina','gentamicina',
  'levofloxacina','moxifloxacina','tobramicina','vancomicina'
);

-- =====================================================================
-- Antimicobacteriais (J04)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimicobacteriais')
WHERE slug IN (
  'isoniazida','rifampicina','pirazinamida','etambutol','bedaquilina',
  'estreptomicina','cicloserina','clofazimina','amicacina','etionamida',
  'protionamida','terizidona','capreomicina','rifabutina'
);

-- =====================================================================
-- Antivirais (J05 não-HIV)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antivirais')
WHERE slug IN ('aciclovir');

-- =====================================================================
-- Antirretrovirais (J05A anti-HIV)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiretrovirais')
WHERE slug IN (
  'tenofovir','emtricitabina','dolutegravir','lopinavir-ritonavir','darunavir',
  'abacavir','raltegravir','etravirina','rilpivirina','estavudina','didanosina'
);

-- =====================================================================
-- Antifúngicos (J02)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antifungicos')
WHERE slug IN ('fluconazol','cetoconazol','voriconazol','itraconazol','nistatina');

-- =====================================================================
-- Antimaláricos (P01)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antimalaricos')
WHERE slug IN (
  'cloroquina','hidroxicloroquina','mefloquina','artemeter-lumefantrina',
  'artesunato','artesunato-amodiaquina','atovaquona-proguanil','primaquina',
  'tafenoquina','sulfadoxina-pirimetamina','diidroartemisinina-piperaquina','quinina'
);

-- =====================================================================
-- Cardiovasculares (C)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'cardiovasculares')
WHERE slug IN (
  'lisinopril','losartana','nifedipina','metoprolol','atenolol','propranolol',
  'carvedilol','bisoprolol','rosuvastatina','simvastatina','isossorbida',
  'verapamilo','diltiazem','ivabradina','tansulosina','finasterida','dutasterida',
  'amlodipina','valsartana','digoxina','midodrina','adrenalina'
);

-- =====================================================================
-- Anticoagulantes e Antitrombóticos (B01)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anticoagulantes')
WHERE slug IN (
  'warfarina','dabigatrano','rivaroxabano','apixabano','clopidogrel',
  'ticagrelor','enoxaparina','fondaparinux','acenocumarol','aspirina'
);

-- =====================================================================
-- Antiepilépticos (N03)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiepilepticos')
WHERE slug IN (
  'carbamazepina','fenitoina','valproato','lamotrigina','levetiracetam',
  'gabapentina','pregabalina','topiramato','oxcarbazepina','eslicarbazepina',
  'etossuximida','clonazepam','zonisamida','lacosamida','primidona'
);

-- =====================================================================
-- Antipsicóticos (N05A)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antipsicoticos')
WHERE slug IN (
  'risperidona','olanzapina','quetiapina','aripiprazol','clozapina',
  'haloperidol','pimozida'
);

-- =====================================================================
-- Antidepressivos (N06A)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidepressivos')
WHERE slug IN (
  'fluoxetina','sertralina','paroxetina','citalopram','escitalopram',
  'venlafaxina','duloxetina','amitriptilina','mirtazapina'
);

-- =====================================================================
-- Ansiolíticos e Hipnóticos (N05B/N05C)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'ansioliticos')
WHERE slug IN ('diazepam','lorazepam','clonazepam','zolpidem','alprazolam');

-- =====================================================================
-- Analgésicos (N02)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'analgesicos')
WHERE slug IN (
  'morfina','fentanilo','tramadol','codeina','buprenorfina',
  'hidromorfona','metadona','paracetamol','metamizol'
);

-- =====================================================================
-- Antiparkinsonianos (N04)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antiparkinsonianos')
WHERE slug IN ('amantadina','levodopa');

-- =====================================================================
-- Antidiabéticos (A10)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidiabeticos')
WHERE slug IN (
  'metformina','glibenclamida','gliclazida','glimepirida','sitagliptina',
  'vildagliptina','saxagliptina','dapagliflozina','canagliflozina',
  'empagliflozina','liraglutida','dulaglutida','pioglitazona','acarbose'
);

-- =====================================================================
-- Respiratórios (R03/R05/R06/R07)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'respiratorios')
WHERE slug IN (
  'salbutamol','salmeterol','formoterol','budesonida','fluticasona',
  'beclometasona','tiotropio','ipratropio','montelukast','roflumilast',
  'indacaterol','teofilina','acetilcisteina','poractant_alfa','azelastina',
  'dextrometorfano','pseudoefedrina','cetirizina','desloratadina',
  'fexofenadina','levocabastina','levocetirizina'
);

-- =====================================================================
-- Gastrointestinais (A02/A03/A04/A05/A07/A08)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'gastrointestinais')
WHERE slug IN (
  'omeprazol','famotidina','cimetidina','metoclopramida','domperidona',
  'loperamida','ondansetron','sucralfato','acido_ursodesoxicolico',
  'butilbrometo_hioscina','mesalazina','sulfassalazina',
  'orlistat','colestiramina'
);

-- =====================================================================
-- Hormonas e Endocrinologia (H)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'hormonas')
WHERE slug IN (
  'levotiroxina','tiamazol','estradiol','medroxiprogesterona','degarelix',
  'anastrozol','tamoxifeno','flutamida','calcitriol','colecalciferol',
  'acido_folico','folinato_calcio','dexametasona','prednisolona',
  'epoetina_alfa','filgrastim','acido_tranexamico'
);

-- =====================================================================
-- Imunossupressores (L04)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'imunossupressores')
WHERE slug IN (
  'tacrolimus','micofenolato','sirolimus','ciclosporina',
  'azatioprina','metotrexato','leflunomida'
);

-- =====================================================================
-- Antineoplásicos (L01/L02)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antineoplasicos')
WHERE slug IN ('ciclofosfamida');

-- =====================================================================
-- Musculoesqueléticos (M)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'musculoesqueleticos')
WHERE slug IN (
  'ibuprofeno','diclofenaco','naproxeno','celecoxib','ketorolaco',
  'piroxicam','meloxicam','nimesulida','indometacina','colchicina',
  'alopurinol','febuxostat','penicilamina','alendronato','tizanidina',
  'probenecida'
);

-- =====================================================================
-- Urológicos (G04)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'urologicos')
WHERE slug IN ('sildenafil','tadalafil','vardenafil');

-- =====================================================================
-- Antídotos (V03)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antidotoss')
WHERE slug IN ('naloxona','dissulfiram');

-- =====================================================================
-- Outros do Sistema Nervoso (N)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'snc_outros')
WHERE slug IN ('donepezilo','memantina');

-- =====================================================================
-- Nutrição e Eletrólitos (B05/A11/A12)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'nutricao')
WHERE slug IN (
  'aminoacidos','emulsao_lipidica','glicose','cloreto_potassio',
  'sulfato_magnesio','acido_ascorbico','cianocobalamina','ferro',
  'zinco','carbonato_calcio'
);

-- =====================================================================
-- Anti-helmínticos e Antiparasitários (P02)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anti_helminticos')
WHERE slug IN ('praziquantel','metronidazol');

-- =====================================================================
-- Dermatológicos (D)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'dermatologicos')
WHERE slug IN ('isotretinoina','acitretina','mupirocina');

-- =====================================================================
-- Anestésicos (N01)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'anestesicos')
WHERE slug IN ('cetamina');
