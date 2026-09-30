-- =====================================================================
-- 268: Lote 4 (próprio) — fármacos sem rótulo DailyMed + insulinas
-- =====================================================================
-- 7 fármacos: insulina regular + insulina NPH (LNME 2021, antidiabéticos)
-- e os 5 excluídos dos Lotes 2/3 por falta de rótulo mono-ingrediente
-- humano no DailyMed (regra 13.1), agora com EMC-UK como fonte principal:
--
--   * insulina-regular     — rótulos FDA existem, mas Actrapid (Novo Nordisk)
--                            é o padrão LNME/angolano: fonte primária EMC-UK
--                            (Actrapid 100 IU/ml, emc/product/3849)
--   * insulina-nph         — idem (Insulatard 100 IU/ml, emc/product/3848)
--   * flucloxacilina       — nunca comercializada nos EUA (só veterinária);
--                            fonte: EMC-UK Flucloxacillin 500 mg Capsules
--                            (emc/product/12636)
--   * espectinomicina      — retirada do mercado humano americano;
--                            sem SmPC UK ativa (Trobicin retirado) — fonte
--                            primária: Prontuário INFARMED/OMS; citar EMC-UK
--                            apenas para contexto de classe (aminoglicosídeo)
--   * permanganato-potassio— sem rótulo FDA; uso antisséptico externo;
--                            fonte: BNF/SPS NHS + Prontuário (solução 1:10.000)
--   * ciproterona          — sem rótulo FDA humano; disponível como acetato de
--                            ciproterona (associação co-cyprindiol, EMC-UK
--                            emc/product/9760; DCI individual G03HA01)
--
-- ATC codes (WHO): A10AB01 (insulina regular humana), A10AC01 (isofânica/NPH),
-- J01CF05 (flucloxacilina), J01XX04 (espectinomicina), B05XA?→D08AX07
-- (permanganato de potássio), G03HA01 (ciproterona + EE) / G03HB01.
-- sort_order 287–293.
-- =====================================================================

INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
SELECT v.slug, v.name_pt, v.name_en, v.class_pt, v.class_en, v.aliases::text[], v.status, v.sort_order
FROM (VALUES
  ('insulina-regular', 'Insulina regular (humana)', 'Regular insulin (human)', 'Antidiabético (insulina de ação rápida/solúvel)', 'Antidiabetic (rapid-acting/soluble insulin)', ARRAY['Actrapid', 'Insulina solúvel', 'Humulin R'], 'published', 287),
  ('insulina-nph', 'Insulina isofânica (NPH)', 'Isophane insulin (NPH)', 'Antidiabético (insulina de ação intermédia)', 'Antidiabetic (intermediate-acting insulin)', ARRAY['Insulatard', 'Humulin I', 'Insulina NPH'], 'published', 288),
  ('flucloxacilina', 'Flucloxacilina', 'Flucloxacillin', 'Penicilina anti-estafilocócica (isoxazolilpenicilina)', 'Anti-staphylococcal penicillin (isoxazolylpenicillin)', ARRAY['Floxapen', 'Flucloxacilina sódica'], 'published', 289),
  ('espectinomicina', 'Espectinomicina', 'Spectinomycin', 'Aminoglicosídeo (antigonorróico injectável)', 'Aminoglycoside (injectable antigonorrhoeal)', ARRAY['Trobicin', 'Actinospectacina'], 'published', 290),
  ('permanganato-potassio', 'Permanganato de potássio', 'Potassium permanganate', 'Antisséptico/astringente tópico (oxidante)', 'Topical antiseptic/astringent (oxidant)', ARRAY['KMnO4', 'Cristais de permanganato'], 'published', 291),
  ('ciproterona', 'Acetato de ciproterona', 'Cyproterone acetate', 'Antiandrogénio esteróide (com estrogénio em dermatologia)', 'Steroidal antiandrogen (with oestrogen in dermatology)', ARRAY['Androcur', 'Co-cyprindiol', 'Diane-35'], 'published', 292)
) AS v(slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM public.drugs d WHERE d.slug = v.slug);

-- =====================================================================
-- class_id (FK drug_classes) + atc_code
-- =====================================================================

UPDATE public.drugs d
SET class_id = c.id,
    atc_code = v.atc_code
FROM (VALUES
  ('insulina-regular', 'antidiabeticos', 'A10AB01'),
  ('insulina-nph', 'antidiabeticos', 'A10AC01'),
  ('flucloxacilina', 'antibacterianos', 'J01CF05'),
  ('espectinomicina', 'antibacterianos', 'J01XX04'),
  ('permanganato-potassio', 'dermatologicos', 'D08AX07'),
  ('ciproterona', 'dermatologicos', 'G03HA01')
) AS v(slug, class_slug, atc_code)
JOIN public.drug_classes c ON c.slug = v.class_slug
WHERE d.slug = v.slug
  AND (d.class_id IS NULL OR d.atc_code IS NULL OR d.atc_code <> v.atc_code);
