-- =====================================================================
-- 229 — Correção de mapeamento: 3 fármacos em classe errada
-- ---------------------------------------------------------------------
-- Probenecida (M04AB01) → musculoesqueleticos (antigotoso)
-- Aciclovir (J05AB01) → antivirais (não antibacteriano)
-- Mupirocina já está em dermatologicos — OK
-- =====================================================================

-- Probenecida: de antibacterianos → musculoesqueleticos
UPDATE public.drugs
SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'musculoesqueleticos')
WHERE slug = 'probenecida';

-- Aciclovir: de antibacterianos → antivirais
UPDATE public.drugs
SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'antivirais')
WHERE slug = 'aciclovir';
