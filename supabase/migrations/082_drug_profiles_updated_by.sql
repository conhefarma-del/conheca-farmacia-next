-- =====================================================================
-- 082 — drug_profiles: rastreio de quem atualizou o perfil
-- ---------------------------------------------------------------------
-- Adiciona updated_by (quem guardou o perfil pela última vez) à tabela
-- drug_profiles, no padrão de archived_by das restantes tabelas (UUID
-- simples, sem FK — consistente com 043/079). A server action
-- saveDrugProfile (admin) preenche esta coluna com o id do utilizador.
-- Idempotente: reaplicar é seguro (ADD COLUMN IF NOT EXISTS).
-- =====================================================================

ALTER TABLE public.drug_profiles
  ADD COLUMN IF NOT EXISTS updated_by UUID;

COMMENT ON COLUMN public.drug_profiles.updated_by
  IS 'UUID do admin que guardou o perfil pela última vez (preenchido por saveDrugProfile em lib/actions/medicamentos.js).';
