-- =====================================================================
-- 255 — Lote 1 LNME (1/4): inserção dos 23 fármacos em public.drugs
-- ---------------------------------------------------------------------
-- Base: Lista Nacional de Medicamentos Essenciais de Angola (2021,
-- DR I Série n.º 176, 16/09/2021) cruzada com a BD — lacunas de
-- prioridade máxima (anti-helmínticos, saúde materna, cardiovascular,
-- anestesia/urgência, psiquiatria, antifúngicos, vitaminas, lepra).
--
-- Exclusões registadas (sem rótulo mono-ingrediente no DailyMed, regra
-- do Fluxo 3 sec. 13.1): insulina (rótulos de mistura só — lote próprio),
-- piridoxina (só em associações), cloxacilina/flucloxacilina (sem rótulo
-- FDA humano — cloxacilina é exclusivamente veterinária nos EUA).
--
-- Fontes: DailyMed (setIDs validados na API, ver _temp/_lote1_setids*.json)
-- + Prontuário Terapêutico INFARMED (11.ª ed., 2012, fontes_interacoes/
-- prontuario_utf8.txt) para os nomes DCI PT e factos clínicos.
--
-- Idempotente: slugs únicos (ON CONFLICT não existe em drugs sem
-- constraint de conflito em id serial — usar WHERE NOT EXISTS).
-- Companheiros: 256/257 (perfis) e 258/259 (farmacologia).
-- =====================================================================

INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
SELECT v.slug, v.name_pt, v.name_en, v.class_pt, v.class_en, v.aliases::text[], v.status, v.sort_order
FROM (VALUES
  ('albendazol', 'Albendazol', 'Albendazole', 'Anti-helmíntico (benzimidazol; largo espetro)', 'Anthelmintic (benzimidazole; broad-spectrum)', ARRAY['Albenza','Zentel'], 'published', 226),
  ('mebendazol', 'Mebendazol', 'Mebendazole', 'Anti-helmíntico (benzimidazol; intestinais)', 'Anthelmintic (benzimidazole; intestinal)', ARRAY['Vermox','Emverm'], 'published', 227),
  ('ivermectina', 'Ivermectina', 'Ivermectin', 'Anti-helmíntico (avermectina; nemátodos e ectoparasitas)', 'Anthelmintic (avermectin; nematodes and ectoparasites)', ARRAY['Stromectol'], 'published', 228),
  ('pirantel', 'Pirantel', 'Pyrantel', 'Anti-helmíntico (tetraidropirimidina; intestinais)', 'Anthelmintic (tetrahydropyrimidine; intestinal)', ARRAY['Pamoato de pirantel','Pin-X'], 'published', 229),
  ('oxitocina', 'Oxitocina', 'Oxytocin', 'Oxitócico (indução do parto e hemorragia pós-parto)', 'Oxytocic (labour induction and postpartum haemorrhage)', ARRAY['Pitocin','Synthocinol'], 'published', 230),
  ('misoprostol', 'Misoprostol', 'Misoprostol', 'Análogo da prostaglandina E1 (oxitócico; gastroproteção)', 'Prostaglandin E1 analogue (oxytocic; gastroprotection)', ARRAY['Cytotec','Gymiso'], 'published', 231),
  ('metilergometrina', 'Metilergometrina', 'Methylergometrine', 'Oxitócico (alcaloide do centeio ergotado; hemostasia uterina)', 'Oxytocic (ergot alkaloid; uterine haemostasis)', ARRAY['Methergine','Metilergonovina'], 'published', 232),
  ('metildopa', 'Metildopa', 'Methyldopa', 'Anti-hipertensivo central (agente metilado; hipertensão na gravidez)', 'Central antihypertensive (methylated agent; hypertension in pregnancy)', ARRAY['Aldomet'], 'published', 233),
  ('hidralazina', 'Hidralazina', 'Hydralazine', 'Vasodilatador arterial direto (anti-hipertensivo)', 'Direct arterial vasodilator (antihypertensive)', ARRAY['Apresoline'], 'published', 234),
  ('lidocaina', 'Lidocaína', 'Lidocaine', 'Anestésico local (amida; antiarrítmico classe Ib)', 'Local anaesthetic (amide; class Ib antiarrhythmic)', ARRAY['Xilocaína','Xylocaine'], 'published', 235),
  ('midazolam', 'Midazolam', 'Midazolam', 'Benzodiazepina de ação curta (sedação e anestesia)', 'Short-acting benzodiazepine (sedation and anaesthesia)', ARRAY['Versed','Dormicum'], 'published', 236),
  ('atropina', 'Atropina', 'Atropine', 'Anticolinérgico (bradicardia; pré-medicação anestésica)', 'Anticholinergic (bradycardia; anaesthetic premedication)', ARRAY['Sulfato de atropina'], 'published', 237),
  ('clorpromazina', 'Clorpromazina', 'Chlorpromazine', 'Antipsicótico típico (fenotiazina)', 'Typical antipsychotic (phenothiazine)', ARRAY['Largactil','Thorazine'], 'published', 238),
  ('prometazina', 'Prometazina', 'Promethazine', 'Anti-histamínico H1 de 1.ª geração (sedativo; antiemético)', 'First-generation antihistamine (sedating; antiemetic)', ARRAY['Fenergan','Phenergan'], 'published', 239),
  ('hidroxizina', 'Hidroxizina', 'Hydroxyzine', 'Anti-histamínico H1 de 1.ª geração (ansiolítico; prurido)', 'First-generation antihistamine (anxiolytic; pruritus)', ARRAY['Atarax','Vistaril'], 'published', 240),
  ('imipramina', 'Imipramina', 'Imipramine', 'Antidepressivo tricíclico (inibidor da recaptação de monoaminas)', 'Tricyclic antidepressant (monoamine reuptake inhibitor)', ARRAY['Tofranil'], 'published', 241),
  ('clotrimazol', 'Clotrimazol', 'Clotrimazole', 'Antifúngico azólico (imidazol; tópico e vaginal)', 'Azole antifungal (imidazole; topical and vaginal)', ARRAY['Canesten','Gino-Canesten'], 'published', 242),
  ('miconazol', 'Miconazol', 'Miconazole', 'Antifúngico azólico (imidazol; tópico e vaginal)', 'Azole antifungal (imidazole; topical and vaginal)', ARRAY['Daktarin','Monistat'], 'published', 243),
  ('terbinafina', 'Terbinafina', 'Terbinafine', 'Antifúngico alilamina (sistémico; dermatofitoses)', 'Allylamine antifungal (systemic; dermatophytoses)', ARRAY['Lamisil'], 'published', 244),
  ('griseofulvina', 'Griseofulvina', 'Griseofulvin', 'Antifúngico (dermatofitoses de cabelo e unhas)', 'Antifungal (hair and nail dermatophytoses)', ARRAY['Grisactin','Fulcin'], 'published', 245),
  ('retinol', 'Retinol (vitamina A)', 'Retinol (vitamin A)', 'Vitamina lipossolúvel A (suplementação e deficiência)', 'Fat-soluble vitamin A (supplementation and deficiency)', ARRAY['Vitamina A','Aquasol A'], 'published', 246),
  ('tiamina', 'Tiamina (vitamina B1)', 'Thiamine (vitamin B1)', 'Vitamina hidrossolúvel B1 (deficiência; encefalopatia de Wernicke)', 'Water-soluble vitamin B1 (deficiency; Wernicke encephalopathy)', ARRAY['Vitamina B1','Benerva'], 'published', 247),
  ('dapsona', 'Dapsona', 'Dapsone', 'Antileprótico (sulfona; dermite herpetiforme)', 'Antileprotic (sulfone; dermatitis herpetiformis)', ARRAY['DDS','Acnedap'], 'published', 248)
) AS v(slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM public.drugs d WHERE d.slug = v.slug);

-- =====================================================================
-- class_id (FK drug_classes) + atc_code
-- =====================================================================
UPDATE public.drugs d
SET class_id = c.id,
    atc_code = v.atc_code,
    updated_at = now()
FROM (VALUES
  ('albendazol',        'anti_helminticos', 'P02CA03'),
  ('mebendazol',        'anti_helminticos', 'P02CA01'),
  ('ivermectina',       'anti_helminticos', 'P02CF01'),
  ('pirantel',          'anti_helminticos', 'P02CC01'),
  ('oxitocina',         'hormonas',         'H01BB02'),
  ('misoprostol',       'hormonas',         'G02AD06'),
  ('metilergometrina',  'hormonas',         'G02AB01'),
  ('metildopa',         'cardiovasculares', 'C02AB01'),
  ('hidralazina',       'cardiovasculares', 'C02DB02'),
  ('lidocaina',         'anestesicos',      'N01BB02'),
  ('midazolam',         'anestesicos',      'N05CD08'),
  ('atropina',          'anestesicos',      'N01BA01'),
  ('clorpromazina',     'antipsicoticos',   'N05AA01'),
  ('prometazina',       'ansioliticos',     'R06AD07'),
  ('hidroxizina',       'ansioliticos',     'N05BB01'),
  ('imipramina',        'antidepressivos',  'N06AA02'),
  ('clotrimazol',       'antifungicos',     'D01AC01'),
  ('miconazol',         'antifungicos',     'D01AC02'),
  ('terbinafina',       'antifungicos',     'D01BA02'),
  ('griseofulvina',     'antifungicos',     'D01BA01'),
  ('retinol',           'nutricao',         'A11CA01'),
  ('tiamina',           'nutricao',         'A11DA01'),
  ('dapsona',           'antibacterianos',  'J04BA02')
) AS v(slug, class_slug, atc_code)
JOIN public.drug_classes c ON c.slug = v.class_slug
WHERE d.slug = v.slug
  AND (d.class_id IS NULL OR d.atc_code IS NULL OR d.atc_code <> v.atc_code);
