-- =====================================================================
-- 283 — Fusão dos fármacos duplicados underscore/hífen (padrão da 254)
-- ---------------------------------------------------------------------
-- AUDITORIA (2026-10-01, dados verificados na BD):
--
--   cloreto_potassio (A12BA01, oral, sort 174) ≡ cloreto-potassio
--     (B05XA01, IV, sort 282) — mesmo princípio activo, nomes PT/EN
--     idênticos ("Cloreto de potássio"/"Potassium chloride").
--     ATC divergentes: A12BA01 (suplemento oral) vs B05XA01 (solução IV)
--     — formas do mesmo fármaco, não fármacos diferentes.
--   sulfato_magnesio (B05XA05, IV) ≡ sulfato-magnesio (B05XB01) —
--     igual; B05XA05 = MgSO4 solução injetável, B05XB01 = MgSO4 solução
--     para perfusão (BAN/DCI: a mesma substância).
--   acetilcisteina (R05CB01, mucolítico oral/inalação) ≡
--     n-acetilcisteina (V03AB23, antídoto IV) — igual; R05CB01 é a
--     indicação mucolítica, V03AB23 a antídoto do paracetamol.
--
-- DECISÃO: FUSÃO (não separação formal). Razões:
--   * Os pares fármaco-fármaco registados são do MESMO conteúdo clínico
--     e já divergem em severidade entre duplicados: enalapril × KCl é
--     moderate (underscore) e critical (hífen) — que é exactamente o
--     tipo de incoerência que confunde o utilizador do site;
--     digoxina × MgSO4 existe nos dois; as mesmas 2 condições de doença
--     (hipercaliemia, insuficiencia_renal_grave) estão registadas em
--     ambos os KCl.
--   * O site apresenta uma ficha por fármaco — dois registos com o
--     mesmo nome PT/EN produzem duas fichas idênticas ao utilizador.
--   * Os ATC divergentes documentam FORMAS (oral/IV, mucolítico/
--     antídoto), não substâncias diferentes; a ficha única pode citar
--     os dois códigos no texto (os ATC ficam arquivados com as linhas).
--
-- SOBREVIVENTES: os slugs canónicos com HÍFEN (Lotes 3/4, sort 282+,
-- perfis/farmacologia enriquecidos recentemente e já citados pelos
-- cruzamentos da 273 e pelas fichas em produção). Os underscore
-- (sort 137/174/175, seed antigo) são arquivados. Nota: o sobrevivente
-- KCl perde a classe oral A12BA01 do duplicado — mantém B05XA01; os
-- usos orais ficam documentados no texto do perfil.
--
-- ESTRATÉGIA (padrão 254, ERRO 7 respeitado): resolução de colisões
-- ANTES do remapeamento (severidade maior ganha, desempate = sobrevivente
-- — no caso enalapril × KCl prevalece o critical do sobrevivente);
-- perfis/farmacologia dos duplicados ARQUIVADOS (conteúdo não único:
-- os dados clínicos que importam estão nos sobreviventes enriquecidos
-- dos Lotes 3/4); soft-delete (is_archived = true), nunca DELETE.
-- Idempotente: reaplicar = 0 mudanças.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 0. Snapshot de tempo da janela
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m283_t AS
SELECT clock_timestamp() AS t1, clock_timestamp() AS t2;
UPDATE _m283_t SET t2 = t1 + interval '1 second';

-- ---------------------------------------------------------------------
-- 1. IDs dos duplicados (underscore) e sobreviventes (hífen)
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m283_ids AS
SELECT d.id AS duplicado_id, s.id AS sobrevivente_id
FROM (VALUES
  ('cloreto_potassio', 'cloreto-potassio'),
  ('sulfato_magnesio', 'sulfato-magnesio'),
  ('acetilcisteina',   'n-acetilcisteina')
) AS v(slug_dup, slug_sob)
JOIN public.drugs d ON d.slug = v.slug_dup
JOIN public.drugs s ON s.slug = v.slug_sob;

-- ---------------------------------------------------------------------
-- 2. Arquivar perfis e farmacologia dos duplicados
--    (conteúdo não único — os sobreviventes têm os perfis enriquecidos
--    dos Lotes 3/4, incluindo os cruzamentos NPH × protamina da 273)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles dp
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m283_t),
    updated_at  = now()
FROM _m283_ids i
WHERE dp.drug_id = i.duplicado_id
  AND dp.is_archived = false;

UPDATE public.drug_pharmacology ph
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m283_t),
    updated_at  = now()
FROM _m283_ids i
WHERE ph.drug_id = i.duplicado_id
  AND ph.is_archived = false;

-- ---------------------------------------------------------------------
-- 3. Remapear drug_target_roles dos duplicados → sobreviventes
-- ---------------------------------------------------------------------
INSERT INTO public.drug_target_roles (drug_id, target_id, role, is_archived, created_at)
SELECT i.sobrevivente_id, dtr.target_id, dtr.role, false, now()
FROM public.drug_target_roles dtr
CROSS JOIN _m283_ids i
WHERE dtr.drug_id = i.duplicado_id
ON CONFLICT (drug_id, target_id, role) DO NOTHING;

UPDATE public.drug_target_roles dtr
SET is_archived = true
FROM _m283_ids i
WHERE dtr.drug_id = i.duplicado_id
  AND dtr.is_archived = false;

-- ---------------------------------------------------------------------
-- 4. Remapear drug_interactions (ordem do ERRO 7: colisões primeiro)
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m283_rank AS
SELECT v.sev, v.rk FROM (VALUES
  ('critical', 4), ('moderate', 3), ('minor', 2), ('none', 1)
) AS v(sev, rk);

CREATE TEMP TABLE _m283_move AS
SELECT di.id AS linha_id,
       i.sobrevivente_id,
       i.duplicado_id,
       LEAST(di.drug_a_id, di.drug_b_id)  AS par_a,
       GREATEST(di.drug_a_id, di.drug_b_id) AS par_b,
       di.severity
FROM public.drug_interactions di
JOIN _m283_ids i
  ON di.drug_a_id = i.duplicado_id OR di.drug_b_id = i.duplicado_id
WHERE di.is_archived = false;

-- 4B.1: arquiva a linha DO DUPLICADO quando a do sobrevivente é >=
UPDATE public.drug_interactions di
SET is_archived = true, updated_at = now()
FROM _m283_move t
JOIN public.drug_interactions keep
  ON keep.id <> t.linha_id
 AND keep.is_archived = false
 AND LEAST(keep.drug_a_id, keep.drug_b_id)  = t.par_a
 AND GREATEST(keep.drug_a_id, keep.drug_b_id) = t.par_b
WHERE di.id = t.linha_id
  AND (SELECT rk FROM _m283_rank WHERE sev = keep.severity)
    >= (SELECT rk FROM _m283_rank WHERE sev = t.severity);

-- 4B.2: arquiva a linha DO SOBREVIVENTE quando a do duplicado é >
UPDATE public.drug_interactions keep
SET is_archived = true, updated_at = now()
FROM _m283_move t
JOIN public.drug_interactions dup
  ON dup.id = t.linha_id
WHERE keep.id <> t.linha_id
  AND keep.is_archived = false
  AND dup.is_archived = false
  AND LEAST(keep.drug_a_id, keep.drug_b_id)  = t.par_a
  AND GREATEST(keep.drug_a_id, keep.drug_b_id) = t.par_b
  AND (SELECT rk FROM _m283_rank WHERE sev = t.severity)
    > (SELECT rk FROM _m283_rank WHERE sev = keep.severity);

-- 4C: remapear as restantes com guarda NOT EXISTS
UPDATE public.drug_interactions di
SET drug_a_id = CASE WHEN di.drug_a_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_a_id END,
    drug_b_id = CASE WHEN di.drug_b_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_b_id END,
    updated_at = now()
FROM _m283_ids m
WHERE (di.drug_a_id = m.duplicado_id OR di.drug_b_id = m.duplicado_id)
  AND di.is_archived = false
  AND NOT EXISTS (
    SELECT 1 FROM public.drug_interactions x
    WHERE x.id <> di.id
      AND x.is_archived = false
      AND LEAST(x.drug_a_id, x.drug_b_id) = LEAST(
            CASE WHEN di.drug_a_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_a_id END,
            CASE WHEN di.drug_b_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_b_id END)
      AND GREATEST(x.drug_a_id, x.drug_b_id) = GREATEST(
            CASE WHEN di.drug_a_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_a_id END,
            CASE WHEN di.drug_b_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_b_id END)
  );

-- ---------------------------------------------------------------------
-- 5. Remapear drug_disease_interactions e drug_food_interactions
--    (duplicados: colisão = mesma condição/entidade já no sobrevivente;
--     resolve-se arquivando a linha do duplicado — nunca merge de texto)
-- ---------------------------------------------------------------------
UPDATE public.drug_disease_interactions ddi
SET is_archived = true, updated_at = now()
FROM _m283_ids i
JOIN public.drug_disease_interactions keep
  ON keep.drug_id = i.sobrevivente_id
 AND keep.is_archived = false
 AND keep.condition_slug = ddi.condition_slug
WHERE ddi.drug_id = i.duplicado_id
  AND ddi.is_archived = false;

UPDATE public.drug_disease_interactions ddi
SET drug_id = i.sobrevivente_id, updated_at = now()
FROM _m283_ids i
WHERE ddi.drug_id = i.duplicado_id
  AND ddi.is_archived = false
  AND NOT EXISTS (
    SELECT 1 FROM public.drug_disease_interactions x
    WHERE x.drug_id = i.sobrevivente_id
      AND x.condition_slug = ddi.condition_slug
      AND x.is_archived = false
  );

UPDATE public.drug_food_interactions dfi
SET is_archived = true, updated_at = now()
FROM _m283_ids i
JOIN public.drug_food_interactions keep
  ON keep.drug_id = i.sobrevivente_id
 AND keep.is_archived = false
 AND keep.entity_slug = dfi.entity_slug
WHERE dfi.drug_id = i.duplicado_id
  AND dfi.is_archived = false;

UPDATE public.drug_food_interactions dfi
SET drug_id = i.sobrevivente_id, updated_at = now()
FROM _m283_ids i
WHERE dfi.drug_id = i.duplicado_id
  AND dfi.is_archived = false
  AND NOT EXISTS (
    SELECT 1 FROM public.drug_food_interactions x
    WHERE x.drug_id = i.sobrevivente_id
      AND x.entity_slug = dfi.entity_slug
      AND x.is_archived = false
  );

-- ---------------------------------------------------------------------
-- 6. Arquivar os fármacos duplicados (soft-delete, padrão do projeto)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m283_t),
    archived_by = NULL,
    updated_at  = now()
FROM _m283_ids i
WHERE d.id = i.duplicado_id
  AND d.is_archived = false;

COMMIT;

-- =====================================================================
-- Verificação pós-migração (executar à parte, expectativas):
--   SELECT slug, is_archived FROM drugs
--     WHERE slug IN ('cloreto_potassio','sulfato_magnesio','acetilcisteina',
--                    'cloreto-potassio','sulfato-magnesio','n-acetilcisteina');
--   → os 3 underscore = true; os 3 hífen = false
--   SELECT count(*) FROM drug_interactions
--     WHERE (drug_a_id IN (SELECT id FROM drugs WHERE slug='cloreto_potassio')
--         OR drug_b_id IN (SELECT id FROM drugs WHERE slug='cloreto_potassio'))
--       AND is_archived = false;  → 0 (idem sulfato_magnesio, acetilcisteina)
--   Par enalapril × KCl: sobrevive 1 linha critical (sobrevivente),
--     moderate arquivada; digoxina × MgSO4: sobrevive 1 linha.
-- =====================================================================
