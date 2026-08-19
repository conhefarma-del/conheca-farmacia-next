-- =====================================================================
-- 232 — Últimos 13 fármacos presos em 'outros'
-- ---------------------------------------------------------------------
-- Fármacos que nunca foram capturados por nenhuma migração anterior
-- por terem slugs diferentes dos usados nas WHERE clauses.
-- =====================================================================

-- =====================================================================
-- Antibacterianos: amoxicilina-clavulanato, benzilpenicilina-benzatina,
-- cefalexina, cefazolina, cefotaxima, ceftazidima, ceftriaxona,
-- cefuroxima, fenoximetilpenicilina, piperacilina-tazobactam
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antibacterianos')
WHERE slug IN (
  'amoxicilina-clavulanato',   -- J01CR02
  'benzilpenicilina-benzatina', -- J01CE08
  'cefalexina',                 -- J01DB01
  'cefazolina',                 -- J01DB04
  'cefotaxima',                 -- J01DD01
  'ceftazidima',                -- J01DD02
  'ceftriaxona',                -- J01DD04
  'cefuroxima',                 -- J01DC02
  'fenoximetilpenicilina',      -- J01CE02
  'piperacilina-tazobactam'     -- J01CR05
);

-- =====================================================================
-- Cardiovasculares: etilefrina, losartana
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'cardiovasculares')
WHERE slug IN (
  'etilefrina',  -- C01CA01 (simpaticomimético agonista alfa/beta)
  'losartana'    -- C09CA01 (ARA II)
);

-- =====================================================================
-- Antipsicóticos: lítio (mood stabilizer)
-- =====================================================================
UPDATE public.drugs SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antipsicoticos')
WHERE slug IN (
  'litio'  -- N05AN01 (estabilizador do humor — primeira linha em perturbação bipolar)
);
