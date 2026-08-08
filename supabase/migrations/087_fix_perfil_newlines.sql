-- =====================================================================
-- 087 — Corrige newlines literais ("\n") nas listas de drug_profiles
-- ---------------------------------------------------------------------
-- As migrações 083 e 085 guardaram as listas (indicações, efeitos
-- secundários, precauções) em E-strings com "\\n" (duplo). Num E-string
-- PostgreSQL, "\\" é um backslash escapado — o valor fica armazenado com
-- o literal "\n" (backslash + n) em vez de uma quebra de linha real.
-- O frontend divide por quebras de linha reais, pelo que o "\n" literal
-- ficava visível na página pública.
--
-- Esta migração substitui o literal "\n" por uma quebra de linha real em
-- todas as colunas de texto de drug_profiles. Idempotente: reaplicar é
-- seguro (após a primeira passagem já não existe "\n" literal para
-- substituir). As migrações 083/085 foram corrigidas na origem
-- ("\\n" -> "\n"), pelo que bases novas aplicadas a partir daqui não
-- precisam desta correção (o UPDATE torna-se um no-op).
-- =====================================================================

UPDATE public.drug_profiles SET
  overview_public_pt = replace(overview_public_pt, E'\\n', E'\n'),
  overview_public_en = replace(overview_public_en, E'\\n', E'\n'),
  overview_pro_pt    = replace(overview_pro_pt,    E'\\n', E'\n'),
  overview_pro_en    = replace(overview_pro_en,    E'\\n', E'\n'),
  indications_pt     = replace(indications_pt,     E'\\n', E'\n'),
  indications_en     = replace(indications_en,     E'\\n', E'\n'),
  side_effects_pt    = replace(side_effects_pt,    E'\\n', E'\n'),
  side_effects_en    = replace(side_effects_en,    E'\\n', E'\n'),
  precautions_pt     = replace(precautions_pt,     E'\\n', E'\n'),
  precautions_en     = replace(precautions_en,     E'\\n', E'\n'),
  updated_at = now();
