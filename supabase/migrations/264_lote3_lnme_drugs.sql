-- =====================================================================
-- 264: Lote 3 LNME (prioridade MÉDIA) — fármacos em drugs
-- =====================================================================
-- 12 fármacos da LNME Angola em falta, prioridade média: endocrinologia
-- ginecológica, tireoide, hemostasia, eletrólitos e antídotos.
--
-- JÁ EXISTENTES na base (não inseridos aqui):
--   * metilergometrina (sort 232) — equivalente clínico da ergometrina
--   * colecalciferol (sort 171) — vitamina D3 já registada no Lote 2 como
--     vitamina-d (colecalciferol); não duplicar
--   * ácido fólico (Lote 2, sort 256)
--
-- Exclusões registadas (regra 13.1):
--   * ciproterona: sem rótulo FDA humano (Europa) — ficaria para lote
--     futuro com fonte EMC-UK exclusiva.
--   * soro antiofídico, antitoxinas: produtos biológicos/vacinas, não DCI.
--   * albumina, imunoglobulinas: hemoderivados (rótulos existem mas são
--     produtos biológicos; ficam para lote próprio).
-- =====================================================================

INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
SELECT v.slug, v.name_pt, v.name_en, v.class_pt, v.class_en, v.aliases::text[], v.status, v.sort_order
FROM (VALUES
  ('clomifeno', 'Clomifeno', 'Clomiphene', 'Antiestrogénio (modulador seletivo do recetor de estrogénio)', 'Antioestrogen (selective oestrogen receptor modulator)', ARRAY['Citrato de clomifeno', 'Clomid', 'Dufine'], 'published', 274),
  ('testosterona', 'Testosterona', 'Testosterone', 'Androgénio (ester de testosterona injetável)', 'Androgen (injectable testosterone ester)', ARRAY['Cipionato de testosterona', 'Depo-Testosterone'], 'published', 275),
  ('progesterona', 'Progesterona', 'Progesterone', 'Gestagénio natural (micronizado oral)', 'Natural progestogen (oral micronised)', ARRAY['Utrogestan', 'Prometrium'], 'published', 276),
  ('carbimazol', 'Carbimazol', 'Carbimazole', 'Antitiroideu (tionamida)', 'Antithyroid (thionamide)', ARRAY['Neo-Mercazole'], 'published', 277),
  ('propiltiouracilo', 'Propiltiouracilo', 'Propylthiouracil', 'Antitiroideu (tionamida)', 'Antithyroid (thionamide)', ARRAY['PTU'], 'published', 278),
  ('piridoxina', 'Piridoxina (vitamina B6)', 'Pyridoxine (vitamin B6)', 'Vitamina hidrossolúvel (B6)', 'Water-soluble vitamin (B6)', ARRAY['Vitamina B6', 'Benadon'], 'published', 279),
  ('acido-tranexamico', 'Ácido tranexâmico', 'Tranexamic acid', 'Antifibrinolítico (lisina análoga)', 'Antifibrinolytic (lysine analogue)', ARRAY['Cyklokapron', 'Exacyl'], 'published', 280),
  ('protamina', 'Protamina', 'Protamine', 'Antídoto da heparina (polipeptídeo básico)', 'Heparin antidote (basic polypeptide)', ARRAY['Protamina sulfato'], 'published', 281),
  ('cloreto-potassio', 'Cloreto de potássio', 'Potassium chloride', 'Eletrólito (potássio)', 'Electrolyte (potassium)', ARRAY['KCl', 'Potássio'], 'published', 282),
  ('sulfato-magnesio', 'Sulfato de magnésio', 'Magnesium sulfate', 'Eletrólito (magnésio) / anticonvulsivo em eclampsia', 'Electrolyte (magnesium) / anticonvulsant in eclampsia', ARRAY['MgSO4', 'Sulfato magnésico'], 'published', 283),
  ('gluconato-calcio', 'Gluconato de cálcio', 'Calcium gluconate', 'Eletrólito (cálcio) parentérico', 'Parenteral electrolyte (calcium)', ARRAY['Cálcio IV', 'Calcium Sandoz'], 'published', 284),
  ('n-acetilcisteina', 'N-acetilcisteína', 'Acetylcysteine', 'Antídoto do paracetamol / mucolítico', 'Paracetamol antidote / mucolytic', ARRAY['NAC', 'Fluimucil', 'Parvolex'], 'published', 285),
  ('deferoxamina', 'Deferoxamina', 'Deferoxamine', 'Quelante de ferro (antídoto de sobrecarga férrica)', 'Iron chelator (iron overload antidote)', ARRAY['Desferal', 'Desferrioxamina'], 'published', 286)
) AS v(slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM public.drugs d WHERE d.slug = v.slug);

-- =====================================================================
-- -- class_id (FK drug_classes) + atc_code
-- =====================================================================

UPDATE public.drugs d
SET class_id = c.id,
    atc_code = v.atc_code
FROM (VALUES
  ('clomifeno', 'hormonas', 'G02GB01'),
  ('testosterona', 'hormonas', 'G03BA03'),
  ('progesterona', 'hormonas', 'G03DA04'),
  ('carbimazol', 'hormonas', 'H03BB01'),
  ('propiltiouracilo', 'hormonas', 'H03BB02'),
  ('piridoxina', 'nutricao', 'A11HA02'),
  ('acido-tranexamico', 'anticoagulantes', 'B02AA02'),
  ('protamina', 'antidotoss', 'V03AB14'),
  ('cloreto-potassio', 'nutricao', 'B05XA01'),
  ('sulfato-magnesio', 'nutricao', 'B05XB01'),
  ('gluconato-calcio', 'nutricao', 'B05XA07'),
  ('n-acetilcisteina', 'antidotoss', 'V03AB23'),
  ('deferoxamina', 'antidotoss', 'V03AC01')
) AS v(slug, class_slug, atc_code)
JOIN public.drug_classes c ON c.slug = v.class_slug
WHERE d.slug = v.slug
  AND (d.class_id IS NULL OR d.atc_code IS NULL OR d.atc_code <> v.atc_code);
