-- =====================================================================
-- 250: Flockhart Table™ — listas curadas nos alvos CYP + drug_target_roles
--
-- Fonte: Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart
--   Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical
--   Pharmacology, Indiana University School of Medicine (atualizada 2021).
--   https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)
--
-- Conteúdo:
--   1. UPDATE em molecular_targets (8 alvos CYP): substrates/inhibitors/
--      inducers pt+en com listas CURADAS (evidência strong/moderate da
--      tabela; indutores: lista completa Flockhart, já seletiva).
--   2. INSERT em drug_target_roles: cruzamento nome Flockhart × drugs da BD
--      (qualquer evidência, match por nome/alias normalizado).
--
-- Idempotente: UPDATEs e ON CONFLICT DO NOTHING.
-- Aplica-se manualmente no Supabase (SQL editor).
-- =====================================================================

-- ============================================================
-- 1. Listas curadas nos alvos CYP (molecular_targets)
-- ============================================================
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): alosetrão, cafeína, clozapina, duloxetina, fezolinetante, fluvoxamina, haloperidol, lidocaína, melatonina, mexiletina, olanzapina, pirfenidona, pomalidomida, tacrina, tasimelteão, teofilina, tizanidina.',
  substrates_en = E'Substrates (strong/moderate evidence): alosetron, caffeine, clozapine, duloxetine, fezolinetant, fluvoxamine, haloperidol, lidocaine, melatonin, mexiletine, olanzapine, pirfenidone, pomalidomide, tacrine, tasimelteon, theophylline, tizanidine.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): ciprofloxacina, fluvoxamina, mexiletina, rucaparibe, vemurafenibe, viloxazina.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): ciprofloxacin, fluvoxamine, mexiletine, rucaparib, vemurafenib, viloxazine.',
  inducers_pt   = E'Indutores: beta-naftoflavona, brócolos, couve-de-bruxelas, carbamazepina, omeprazol, rifampicina, teriflunomida, tipranavir + ritonavir, tabaco (fumo).',
  inducers_en   = E'Inducers: beta-naphthoflavone, broccoli, brussel sprouts, carbamazepine, omeprazole, rifampin, teriflunomide, tipranavir and ritonavir, tobacco.',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp1a2';
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): boceprevir, bosentano, cafergot (ergotamina + cafeína), carbamazepina, codeína, colchicina, conivaptante.',
  substrates_en = E'Substrates (strong/moderate evidence): boceprevir, bosentan, cafergot, carbamazepine, codeine, colchicine, conivaptant.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): amlodipina, aprepitante, ceritinibe, ciprofloxacina, claritromicina, cobicistate, conivaptante, crizotinibe, delavirdina, diltiazem, dronedarona, eritromicina, fluconazol, idelalisibe, imatinibe, indinavir, itraconazol, cetoconazol, letermovir, lopinavir + ritonavir, mibefradil.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): amlodipine (3A5), aprepitant, ceritinib, ciprofloxacin, clarithromycin, cobicistat, conivaptant, crizotinib, delaviridine, diltiazem, dronedarone, erythromycin, fluconazole, idelalisib, imatinib, indinavir, itraconazole, ketoconazole, letermovir, lopinavir/ritonavir, mibefradil.',
  inducers_pt   = E'Indutores: betametasona, brigatinibe, carbamazepina, cenobamato, clobazam, dabrafenibe, dexametasona, efavirenz, elagolix, enzalutamida, eslicarbazepina, ivosidenibe, lorlatinibe, metilprednisolona, modafinila, nevirapina, oxcarbazepina, fenobarbital, fenitoína, pioglitazona, prednisolona, prednisona, rifabutina, rifampicina, sotorasibe, hipericão (St. John''s Wort), suzetrigina, telotristate, troglitazona, vemurafenibe.',
  inducers_en   = E'Inducers: betamethasone, brigatinib, carbamazepine, cenobamate, clobazam, dabrafenib, dexamethasone, efavirenz, elagolix, enzalutamide, eslicarbazepine, ivosidenib, lorlatinib, methylprednisolone, modafinil, nevirapine, oxcarbazepine, phenobarbital, phenytoin, pioglitazone, prednisolone, prednisone, rifabutin, rifampin, sotorasib, St. John''s Wort, suzetrigine, telotristat, troglitazone, vemurafenib.',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp3a4';
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): amitriptilina, anfetamina, atomoxetina, carvedilol, clorfenamina, clomipramina, codeína, debrisoquina, desipramina, deutetrabenazina, dextrometorfano, doxepina, duloxetina, eliglustat, encainida, escitalopram, fluoxetina, fluvoxamina, haloperidol, mefedrona, metoxianfetamina, metoclopramida, metoprolol, mexiletina, nebivolol, nortriptilina, oxicodona, paroxetina, perhexilina, perfenazina, propafenona.',
  substrates_en = E'Substrates (strong/moderate evidence): amitriptyline, amphetamine, atomoxetine, carvedilol, chlorpheniramine, clomipramine, codeine, debrisoquine, desipramine, deutetrabenazine, dextromethorphan, doxepin, duloxetine, eliglustat, encainide, escitalopram, fluoxetine, fluvoxamine, haloperidol, mephedrone, methoxyamphetamine, metoclopramide, metoprolol, mexiletine, nebivolol, nortriptyline, oxycodone, paroxetine, perhexiline, perphenazine, propafenone.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): abiraterona, bupropiona, cinacalceto, doxepina, dronedarona, duloxetina, fluoxetina, halofantrina, mirabegrão, moclobemida, paroxetina, perhexilina, quinidina, terbinafina.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): abiraterone, bupropion, cinacalcet, doxepin, dronedarone, duloxetine, fluoxetine, halofantrine, mirabegron, moclobemide, paroxetine, perhexiline, quinidine, terbinafine (oral).',
  inducers_pt   = E'Indutores (lista em revisão).',
  inducers_en   = E'Inducers (lista em revisão).',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp2d6';
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): carisoprodol, citalopram, clobazam, clopidogrel, ciclofosfamida, diazepam, doxepina, escitalopram, esomeprazol, labetalol, lansoprazol, mavacamten, moclobemida, omeprazol, pantoprazol, r-mefobarbital, s-mefenitoína, venlafaxina, voriconazol.',
  substrates_en = E'Substrates (strong/moderate evidence): carisoprodol, citalopram, clobazam, clopidogrel, cyclophosphamide, diazepam, doxepin, escitalopram, esomeprazole, labetalol, lansoprazole, mavacamten, moclobemide, omeprazole, pantoprazole, r-mephobarbital, s-mephenytoin, venlafaxine, voriconazole.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): cenobamato, esomeprazol, fluconazol, fluoxetina, fluvoxamina, cetoconazol, ticlopidina, voriconazol.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): cenobamate, esomeprazole, fluconazole, fluoxetine, fluvoxamine, ketoconazole, ticlopidine, voriconazole.',
  inducers_pt   = E'Indutores: efavirenz, enzalutamida, letermovir, prednisona, rifampicina, ritonavir, hipericão (St. John''s Wort), tipranavir + ritonavir.',
  inducers_en   = E'Inducers: efavirenz, enzalutamide, letermovir, prednisone, rifampin, ritonavir, St. John''s Wort, tipranavir and ritonavir.',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp2c19';
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): celecoxib, doxepina, flurbiprofeno, glimepirida, glibenclamida, meloxicam, fenitoína, piroxicam, ruxolitinibe, s-varfarina, siponimode, tolbutamida.',
  substrates_en = E'Substrates (strong/moderate evidence): celecoxib, doxepin, flurbiprofen, glimepiride, glyburide/glibenclamide, meloxicam, phenytoin, piroxicam, ruxolitinib, s-warfarin, siponimod, tolbutamide.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): amiodarona, fluconazol, metronidazol, fenilbutazona, sulfafenazol.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): amiodarone, fluconazole, metronidazole, phenylbutazone, sulfaphenazole.',
  inducers_pt   = E'Indutores: carbamazepina, dabrafenibe, enzalutamida, nevirapina, fenobarbital, rifampicina, secobarbital, hipericão (St. John''s Wort).',
  inducers_en   = E'Inducers: carbamazepine, dabrafenib, enzalutamide, nevirapine, phenobarbital, rifampin, secobarbital, St. John''s Wort.',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp2c9';
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): cerivastatina, enzalutamida, repaglinida, rosiglitazona, selexipague, tucatinibe.',
  substrates_en = E'Substrates (strong/moderate evidence): cerivastatin, enzalutamide, repaglinide, rosiglitazone, selexipag, tucatinib.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): clopidogrel, deferasirox, gemfibrozila, pirtobrutinibe, selpercatinibe, teriflunomida.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): clopidogrel, deferasirox, gemfibrozil, pirtobrutinib, selpercatinib, teriflunomide.',
  inducers_pt   = E'Indutores: rifampicina.',
  inducers_en   = E'Inducers: rifampin.',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp2c8';
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): bupropiona, efavirenz.',
  substrates_en = E'Substrates (strong/moderate evidence): bupropion, efavirenz.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): ticlopidina.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): ticlopidine.',
  inducers_pt   = E'Indutores: artemisinina, carbamazepina, dabrafenibe, efavirenz, lemborexanto, nevirapina, fenobarbital, fenitoína, rifampicina.',
  inducers_en   = E'Inducers: artemisinin, carbamazepine, dabrafenib, efavirenz, lemborexant, nevirapine, phenobarbital, phenytoin, rifampin.',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp2b6';
UPDATE public.molecular_targets SET
  substrates_pt = E'Substratos (evidência forte/moderada): halotano, isoflurano.',
  substrates_en = E'Substrates (strong/moderate evidence): halothane, isoflurane.',
  inhibitors_pt = E'Inibidores (evidência forte/moderada): dietilditiocarbamato, dissulfiram.',
  inhibitors_en = E'Inhibitors (strong/moderate evidence): diethyl-dithiocarbamate, disulfiram.',
  inducers_pt   = E'Indutores: álcool (etanol), isoniazida.',
  inducers_en   = E'Inducers: ethanol, isoniazid.',
  source_pt     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (atualizada 2021). https://drug-interactions.medicine.iu.edu/ (acessado 2026-09-13)',
  source_en     = 'Flockhart Table™ (IU School of Medicine, 2021) — Flockhart DA, Thacker D, McDonald C, Desta Z. The Flockhart Cytochrome P450 Drug-Drug Interaction Table. Division of Clinical Pharmacology, Indiana University School of Medicine (Updated 2021). https://drug-interactions.medicine.iu.edu/ (accessed 2026-09-13)'
WHERE slug = 'cyp2e1';

-- ============================================================
-- 2. drug_target_roles — cruzamento Flockhart × drugs da BD
-- ============================================================
INSERT INTO public.drug_target_roles (drug_id, target_id, role, source_pt, source_en)
VALUES
  ('a0000000-0000-4000-8000-000000000019', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('98e3afa9-5213-4f9e-91a2-194d4ecb4137', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('7ddaeb3e-aea2-45bc-b0c7-7af580f81adf', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('880a0a7a-5918-4bba-9e92-4205e5f9c191', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000011', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('3bb17be1-d8f1-420a-af8a-bf16d83c0ef4', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000032', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('97ebbfca-fc6a-42af-bfc5-3726a72dcab8', 'eed3d18e-6b46-4d8c-942d-447e050e093c', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('2e46d899-a12b-46e5-badb-6252b6ed5365', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('10d937e9-1a59-4a71-8b40-cfd66184b258', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000013', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('715e751d-a2c2-4793-81a8-b926f19512d4', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('5ccb4781-4771-4ad9-ac22-63ae1ca28047', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('856e7cc4-ce58-442c-ac50-a9a2f17e63b1', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('6e773ea4-af5d-4e9e-a0a2-9e0d24550931', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-00000000001b', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('d54ddaa0-6301-4c2b-8a65-eae494de06a4', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('c763c53b-ae3d-4903-8a20-dbc1aa8528c5', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('848be951-a167-41b3-a44b-5d02b53960f1', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('98e3afa9-5213-4f9e-91a2-194d4ecb4137', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('7ddaeb3e-aea2-45bc-b0c7-7af580f81adf', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('1b098ae7-dc88-4fcb-8072-99e9626c49d4', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('44c250f5-73d8-4389-bd6a-40d447b72649', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('7111594c-fdc2-4448-9e81-f0f7c0120b36', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('3bb17be1-d8f1-420a-af8a-bf16d83c0ef4', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000012', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000010', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('38d0cf24-e81e-4fe6-a6e5-e7d61193f8d6', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('3e9a4af3-325c-411f-baa0-2b9c9f475adc', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000032', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('c312f532-cce3-419e-b196-227cf7fe7360', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('c27e5799-bf24-45c4-9327-a6ead39ff525', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('f9bfdbb8-2604-40b4-a4a6-dba5b5602872', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('2f1264e8-9e26-4f82-819a-b619987762d9', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('03c874e5-8aba-4c29-bee6-29fa5bd39562', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('10b45270-974b-4fa0-9085-e4603acdc9e1', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('983657d6-b34f-473a-8327-8b41fb61bf19', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('b31a9bf1-e9ce-4ae7-acf7-15792c0c972b', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000018', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-00000000001e', 'c6106696-b474-474e-a4cc-529849e80797', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('d54ddaa0-6301-4c2b-8a65-eae494de06a4', 'c6106696-b474-474e-a4cc-529849e80797', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('6f8216ad-9b0f-4b11-ae1a-57c5f68e0cd4', 'c6106696-b474-474e-a4cc-529849e80797', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('856e7cc4-ce58-442c-ac50-a9a2f17e63b1', 'c6106696-b474-474e-a4cc-529849e80797', 'inducer', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('97ebbfca-fc6a-42af-bfc5-3726a72dcab8', 'c6106696-b474-474e-a4cc-529849e80797', 'inducer', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000017', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000013', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('1490be64-f53b-482a-906d-2934bac13b32', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('6e773ea4-af5d-4e9e-a0a2-9e0d24550931', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000019', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000016', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('7ddaeb3e-aea2-45bc-b0c7-7af580f81adf', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('1478dd25-2092-470e-944a-4b74b9d95cd4', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('f9c72510-c647-447a-8b23-9bac7d27697d', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000014', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('3bb17be1-d8f1-420a-af8a-bf16d83c0ef4', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000010', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('983657d6-b34f-473a-8327-8b41fb61bf19', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000018', '51f934ac-56dd-4052-8b6f-146c790c2373', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('c6dbe686-4775-4a2b-a537-aaa6168e0aff', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000015', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('1f20aa77-126d-4631-b31b-9903ef85dd4c', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000019', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000016', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('7ddaeb3e-aea2-45bc-b0c7-7af580f81adf', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('44c250f5-73d8-4389-bd6a-40d447b72649', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('1478dd25-2092-470e-944a-4b74b9d95cd4', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000014', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('38d0cf24-e81e-4fe6-a6e5-e7d61193f8d6', '51f934ac-56dd-4052-8b6f-146c790c2373', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000017', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000015', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('715e751d-a2c2-4793-81a8-b926f19512d4', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-00000000001b', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000016', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('3bb17be1-d8f1-420a-af8a-bf16d83c0ef4', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000018', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('150342c1-53fe-4bd5-9a4f-9eeac48d97c7', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('97ebbfca-fc6a-42af-bfc5-3726a72dcab8', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'inducer', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('38d0cf24-e81e-4fe6-a6e5-e7d61193f8d6', '80f44812-8242-43b4-be0b-c3c6182e21c9', 'inducer', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('a0000000-0000-4000-8000-000000000017', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('c6dbe686-4775-4a2b-a537-aaa6168e0aff', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('6fa876ba-a930-4c63-af09-a07d527a0372', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('3740a5d0-76b7-4b13-a6ff-9abc5ddffa11', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('d6d10ed6-fd00-42cf-89bd-68218e111007', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('b9179307-842d-4953-91f0-5ec48891bf95', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('97ebbfca-fc6a-42af-bfc5-3726a72dcab8', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('150342c1-53fe-4bd5-9a4f-9eeac48d97c7', '0fe7cba7-f722-4c5e-a194-7d1c2e74530f', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('715e751d-a2c2-4793-81a8-b926f19512d4', '4599d0ca-fdcf-4b84-ab00-c7fd4f1715e0', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('97ebbfca-fc6a-42af-bfc5-3726a72dcab8', '4599d0ca-fdcf-4b84-ab00-c7fd4f1715e0', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('97ebbfca-fc6a-42af-bfc5-3726a72dcab8', '6844bb79-fae5-4fba-b238-6c0c8fd97362', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('44c250f5-73d8-4389-bd6a-40d447b72649', '6844bb79-fae5-4fba-b238-6c0c8fd97362', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('983657d6-b34f-473a-8327-8b41fb61bf19', '6844bb79-fae5-4fba-b238-6c0c8fd97362', 'substrate', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('715e751d-a2c2-4793-81a8-b926f19512d4', '6844bb79-fae5-4fba-b238-6c0c8fd97362', 'inhibitor', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('97ebbfca-fc6a-42af-bfc5-3726a72dcab8', '6844bb79-fae5-4fba-b238-6c0c8fd97362', 'inducer', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)'),
  ('150342c1-53fe-4bd5-9a4f-9eeac48d97c7', '840331fe-1680-4351-9ecd-5cb7d0b3aa20', 'inducer', 'Flockhart Table™ (IU School of Medicine, 2021)', 'Flockhart Table™ (IU School of Medicine, 2021)')
ON CONFLICT (drug_id, target_id, role) DO NOTHING;
