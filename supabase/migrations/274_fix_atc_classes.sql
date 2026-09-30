-- =====================================================================
-- 274 — Correção de códigos ATC e ligações class_id (auditoria 2026-09-30)
-- ---------------------------------------------------------------------
-- Auditoria aos 375 fármacos: ATC ausente = 0; formato inválido = 0;
-- classes vazias = 0. Corrigidos aqui:
--
--   1. tiamazol: tinha H03BB02 (que é o ATC do propiltiouracilo). Pelo WHO ATC
--      index, H03BB01 = thiamazole (methimazole) e H03BB02 = propylthiouracil.
--      O carbimazol é profármaco do tiamazol e já partilha H03BB01 — o tiamazol
--      passa a H03BB01, ficando ambos coerentes.
--
--   2. dopamina: tinha C01CA24 (que é epinephrine/adrenalina). O ATC da
--      dopamina é C01CA04. A adrenalina mantém C01CA24.
--
--   3. acido_folico: class_id 'hormonas' → 'nutricao' (o duplicado acido-folico
--      do Lote 2 já está em nutricao; B03BB01 é hematinico, Grupo 8 "Nutrição"
--      do Prontuário).
--
--   4. acido_tranexamico: class_id 'hormonas' → 'anticoagulantes' (o duplicado
--      acido-tranexamico já está em anticoagulantes; B02AA02 = antifibrinolítico,
--      Grupo 4.3 "Anticoagulantes e antitrombóticos" do Prontuário).
--
-- Correcções ATC: 2 fármacos. Correcções class_id: 2 fármacos.
-- Guarda: WHERE d.atc_code IS DISTINCT FROM v.atc_code (idempotente).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. dopamina: C01CA24 (adrenalina) → C01CA04 (dopamine, WHO ATC index)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET atc_code = 'C01CA04'
FROM (VALUES ('dopamina')) AS v(slug)
WHERE d.slug = v.slug
  AND d.atc_code IS DISTINCT FROM 'C01CA04';

-- ---------------------------------------------------------------------
-- 2. tiamazol: H03BB02 (propiltiouracilo) → H03BB01 (thiamazole; partilhado
--    com carbimazol — mesmo princípio activo, profármaco)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET atc_code = 'H03BB01'
FROM (VALUES ('tiamazol')) AS v(slug)
WHERE d.slug = v.slug
  AND d.atc_code IS DISTINCT FROM 'H03BB01';

-- ---------------------------------------------------------------------
-- 3. acido_folico: classe 'hormonas' → 'nutricao' (alinhar com acido-folico)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET class_id = c.id
FROM (VALUES ('acido_folico')) AS v(slug)
JOIN public.drug_classes c ON c.slug = 'nutricao'
WHERE d.slug = v.slug
  AND EXISTS (
    SELECT 1 FROM public.drugs dd
    JOIN public.drug_classes cc ON cc.id = dd.class_id
    WHERE dd.slug = 'acido_folico' AND cc.slug = 'hormonas'
  );

-- ---------------------------------------------------------------------
-- 4. acido_tranexamico: classe 'hormonas' → 'anticoagulantes'
--    (alinhar com acido-tranexamico)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET class_id = c.id
FROM (VALUES ('acido_tranexamico')) AS v(slug)
JOIN public.drug_classes c ON c.slug = 'anticoagulantes'
WHERE d.slug = v.slug
  AND EXISTS (
    SELECT 1 FROM public.drugs dd
    JOIN public.drug_classes cc ON cc.id = dd.class_id
    WHERE dd.slug = 'acido_tranexamico' AND cc.slug = 'hormonas'
  );

-- =====================================================================
-- Notas de auditoria (sem correcção necessária):
--   * Duplicados ATC legítimos (pares canónico/duplicado da migração 254,
--     ambos activos): losartano(ARCHIV)/losartana C09CA01;
--     amoxicilina-clavulanato/amoxicilina-acido-clavulanico J01CR02;
--     acido_ascorbico/acido-ascorbico A11GA01; acido_folico/acido-folico
--     B03BB01; acido_tranexamico/acido-tranexamico B02AA02; ferro/
--     sulfato-ferroso B03AA07; colecalciferol/vitamina-d A11CC05.
--   * adrenalina C01CA24: correcto (único detentor após fix da dopamina).
--   * tiamazol H03BB01 e carbimazol H03BB01 ficam partilhados — correcto
--     pelo WHO ATC index (carbimazol é profármaco do tiamazol/metimazol).
--   * Multi-letras por classe (ex.: hormonas com H/B/L/A/G) reflectem a
--     organização funcional interna do site, não erro de ATC.
-- =====================================================================
