-- =====================================================================
-- 260: Lote 2 LNME (prioridade ALTA) — fármacos em drugs
-- =====================================================================
-- 29 fármacos da Lista Nacional de Medicamentos Essenciais de Angola
-- (LNME 2021, DR I Série n.º 176) em falta na base, prioridade alta:
-- uso comunitário/hospitalar geral em Angola.
--
-- Exclusões registadas (regra 13.1 — sem rótulo mono-ingrediente humano
-- no DailyMed):
--   * cloxacilina / flucloxacilina: nunca comercializadas nos EUA
--     (flucloxacilina só há produtos veterinários). Cobertura de Staph
--     aureus sensível fica assegurada pela dicloxacilina? — NÃO existente
--     na base; ficarão para lote futuro com fonte EMC-UK exclusiva.
--   * espectinomicina: só rótulos veterinários nos EUA (retirada do
--     mercado humano americano).
--   * permanganato de potássio: sem rótulo FDA (uso antisséptico externo).
--   * ciproterona: sem rótulo FDA humano (Europa).
--   * soro fisiológico / hemoderivados genéricos (albumina, imunoglobulina,
--     antitoxina tetânica, soro antiofídico): transferidos para Lote 3
--     ou excluídos por serem produtos biológicos/vacinas, não DCI.
--
-- Classes (drug_classes existentes) e sort_order 249–273.
-- =====================================================================

INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
SELECT v.slug, v.name_pt, v.name_en, v.class_pt, v.class_en, v.aliases::text[], v.status, v.sort_order
FROM (VALUES
  ('amoxicilina-acido-clavulanico', 'Amoxicilina + Ácido clavulânico', 'Amoxicillin + Clavulanic acid', 'Penicilina de largo espetro com inibidor de beta-lactamase', 'Broad-spectrum penicillin with beta-lactamase inhibitor', ARRAY['Augmentin', 'Clavulin', 'Curam'], 'published', 249),
  ('tetracaina', 'Tetracaína', 'Tetracaine', 'Anestésico local (éster) de superfície', 'Surface (ester) local anaesthetic', ARRAY['Pontocaina', 'Tetracaine HCl'], 'published', 250),
  ('bicarbonato-sodio', 'Bicarbonato de sódio', 'Sodium bicarbonate', 'Anticido sistémico / alcalinizante (eletrólito)', 'Systemic alkalinising agent (electrolyte)', ARRAY['NaHCO3', 'Bicarbonato'], 'published', 251),
  ('clorexidina', 'Clorexidina', 'Chlorhexidine', 'Antisséptico (biguanida) cutâneo/mucoso', 'Skin/mucosal antiseptic (biguanide)', ARRAY['Hibiscrub', 'Clorexidina aquosa'], 'published', 252),
  ('iodopovidona', 'Iodopovidona', 'Povidone-iodine', 'Antisséptico (iodóforo) cutâneo/mucoso', 'Skin/mucosal antiseptic (iodophor)', ARRAY['Betadine', 'PVPI'], 'published', 253),
  ('sulfato-zinco', 'Sulfato de zinco', 'Zinc sulfate', 'Mineral (zinco) para deficiência e suplementação', 'Mineral (zinc) for deficiency and supplementation', ARRAY['Zinco', 'Solvzinco'], 'published', 254),
  ('acido-ascorbico', 'Ácido ascórbico (vitamina C)', 'Ascorbic acid (vitamin C)', 'Vitamina hidrossolúvel (C)', 'Water-soluble vitamin (C)', ARRAY['Vitamina C', 'Redoxon'], 'published', 255),
  ('acido-folico', 'Ácido fólico', 'Folic acid', 'Vitamina B9 (antianémico)', 'Vitamin B9 (haematinic)', ARRAY['Folato', 'Vitamina B9'], 'published', 256),
  ('sulfato-ferroso', 'Sulfato ferroso', 'Ferrous sulfate', 'Ferropénico oral (antianémico)', 'Oral iron salt (haematinic)', ARRAY['Ferro', 'Feosol'], 'published', 257),
  ('vitamina-d', 'Vitamina D (colecalciferol)', 'Vitamin D (cholecalciferol)', 'Vitamina lipossolúvel (D3)', 'Fat-soluble vitamin (D3)', ARRAY['Colecalciferol', 'Vitamina D3'], 'published', 258),
  ('calcio', 'Cálcio (carbonato de cálcio)', 'Calcium (calcium carbonate)', 'Mineral (cálcio) oral para deficiência e antiácido', 'Oral mineral (calcium) for deficiency and antacid', ARRAY['Carbonato de cálcio', 'Calcionat'], 'published', 259),
  ('noreisterona', 'Noretisterona', 'Norethisterone', 'Gestagénio sintético (contracepção e ginecologia)', 'Synthetic progestogen (contraception and gynaecology)', ARRAY['Noretindrona', 'Primolut-N'], 'published', 260),
  ('levonorgestrel-etinilestradiol', 'Levonorgestrel + Etinilestradiol', 'Levonorgestrel + Ethinylestradiol', 'Contracetivo oral combinado (gestagénio + estrogénio)', 'Combined oral contraceptive (progestogen + oestrogen)', ARRAY['Pílula combinada', 'Microgynon', 'Levlen'], 'published', 261),
  ('desmopressina', 'Desmopressina', 'Desmopressin', 'Análogo da vasopressina (diabetes insípida, hemofilia ligeira)', 'Vasopressin analogue (diabetes insipidus, mild haemophilia)', ARRAY['DDAVP', 'Minirin', 'Desmotabs'], 'published', 262),
  ('neostigmina', 'Neostigmina', 'Neostigmine', 'Inibidor da colinesterase (reversão de bloqueio neuromuscular)', 'Cholinesterase inhibitor (neuromuscular blockade reversal)', ARRAY['Prostigmina'], 'published', 263),
  ('vecuronio', 'Vecurônio', 'Vecuronium', 'Bloqueante neuromuscular não despolarizante (aminoesteróide)', 'Non-depolarising neuromuscular blocker (aminosteroid)', ARRAY['Norcuron'], 'published', 264),
  ('suxametonio', 'Suxametónio', 'Succinylcholine', 'Bloqueante neuromuscular despolarizante (ultra-curto)', 'Depolarising neuromuscular blocker (ultra-short)', ARRAY['Succinilcolina', 'Anectine'], 'published', 265),
  ('bupivacaina', 'Bupivacaína', 'Bupivacaine', 'Anestésico local (amida) de longa duração', 'Long-acting (amide) local anaesthetic', ARRAY['Marcaina', 'Bupivacaina HCl'], 'published', 266),
  ('propofol', 'Propofol', 'Propofol', 'Anestésico geral intravenoso (fenol substituído)', 'Intravenous general anaesthetic (substituted phenol)', ARRAY['Diprivan'], 'published', 267),
  ('efedrina', 'Efedrina', 'Ephedrine', 'Simpatomimético indireto (vasopressor em obstetrícia/urgência)', 'Indirect sympathomimetic (vasopressor in obstetrics/emergency)', ARRAY['Efedrina sulfato'], 'published', 268),
  ('flumazenil', 'Flumazenil', 'Flumazenil', 'Antagonista dos benzodiazepínicos', 'Benzodiazepine antagonist', ARRAY['Anexate'], 'published', 269),
  ('clonidina', 'Clonidina', 'Clonidine', 'Agonista alfa-2 central (anti-hipertensivo)', 'Central alpha-2 agonist (antihypertensive)', ARRAY['Catapres'], 'published', 270),
  ('nitroprussiato', 'Nitroprussiato de sódio', 'Sodium nitroprusside', 'Vasodilatador arterial e venoso direto (urgência hipertensiva)', 'Direct arterial and venous vasodilator (hypertensive emergency)', ARRAY['Nipride', 'Nitroprussiato'], 'published', 271),
  ('heparina', 'Heparina não fracionada', 'Unfractionated heparin', 'Anticoagulante parentérico de ação imediata', 'Immediate-acting parenteral anticoagulant', ARRAY['Heparina sódica', 'Liquemine'], 'published', 272),
  ('dopamina', 'Dopamina', 'Dopamine', 'Vasopressor/inotrópico (catecolamina; choque)', 'Vasopressor/inotrope (catecholamine; shock)', ARRAY['Dopamina HCl', 'Revimine'], 'published', 273),
  ('dobutamina', 'Dobutamina', 'Dobutamine', 'Inotrópico β1-seletivo (insuficiência cardíaca aguda)', 'β1-selective inotrope (acute heart failure)', ARRAY['Dobutrex'], 'published', 274),
  ('noradrenalina', 'Noradrenalina', 'Norepinephrine', 'Vasopressor de primeira linha (choque séptico)', 'First-line vasopressor (septic shock)', ARRAY['Norepinefrina', 'Levophed'], 'published', 275),
  ('aminofilina', 'Aminofilina', 'Aminophylline', 'Broncodilatador (xantina; crise asmática grave)', 'Bronchodilator (xanthine; severe asthma attack)', ARRAY['Teofilina etilenodiamina', 'Cardophylin'], 'published', 276),
  ('metilprednisolona', 'Metilprednisolona', 'Methylprednisolone', 'Corticosteróide sistémico (pulso e parentérico)', 'Systemic corticosteroid (pulse and parenteral)', ARRAY['Medrol', 'Solumedrol', 'Depo-Medrol'], 'published', 277)
) AS v(slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM public.drugs d WHERE d.slug = v.slug);

-- =====================================================================
-- -- class_id (FK drug_classes) + atc_code
-- =====================================================================

UPDATE public.drugs d
SET class_id = c.id,
    atc_code = v.atc_code
FROM (VALUES
  ('amoxicilina-acido-clavulanico', 'antibacterianos', 'J01CR02'),
  ('tetracaina', 'anestesicos', 'N01BA03'),
  ('bicarbonato-sodio', 'nutricao', 'B05CB01'),
  ('clorexidina', 'dermatologicos', 'D08AC02'),
  ('iodopovidona', 'dermatologicos', 'D08AG01'),
  ('sulfato-zinco', 'nutricao', 'A12CB03'),
  ('acido-ascorbico', 'nutricao', 'A11GA01'),
  ('acido-folico', 'nutricao', 'B03BB01'),
  ('sulfato-ferroso', 'nutricao', 'B03AA07'),
  ('vitamina-d', 'nutricao', 'A11CC05'),
  ('calcio', 'nutricao', 'A02AC01'),
  ('noreisterona', 'hormonas', 'G03DC02'),
  ('levonorgestrel-etinilestradiol', 'hormonas', 'G03AA07'),
  ('desmopressina', 'hormonas', 'H01BA02'),
  ('neostigmina', 'outros', 'V03AB15'),
  ('vecuronio', 'anestesicos', 'M03AC03'),
  ('suxametonio', 'anestesicos', 'M03AB01'),
  ('bupivacaina', 'anestesicos', 'N01BB01'),
  ('propofol', 'anestesicos', 'N01AX10'),
  ('efedrina', 'cardiovasculares', 'C01CA26'),
  ('flumazenil', 'antidotoss', 'V03AB25'),
  ('clonidina', 'cardiovasculares', 'C02AC01'),
  ('nitroprussiato', 'cardiovasculares', 'C02DD01'),
  ('heparina', 'anticoagulantes', 'B01AB01'),
  ('dopamina', 'cardiovasculares', 'C01CA24'),
  ('dobutamina', 'cardiovasculares', 'C01CA07'),
  ('noradrenalina', 'cardiovasculares', 'C01CA03'),
  ('aminofilina', 'respiratorios', 'R03DA05'),
  ('metilprednisolona', 'imunossupressores', 'H02AB04')
) AS v(slug, class_slug, atc_code)
JOIN public.drug_classes c ON c.slug = v.class_slug
WHERE d.slug = v.slug
  AND (d.class_id IS NULL OR d.atc_code IS NULL OR d.atc_code <> v.atc_code);
