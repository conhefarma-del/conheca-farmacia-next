-- =====================================================================
-- Migração 254 — Consolidação de fármacos duplicados em public.drugs
-- =====================================================================
-- Problemas corrigidos (relatório LNME↔BD, 2026-09-29):
--   1. Duplicado: "Losartano" (losartano, ARA II, seed antigo)
--      vs. "Losartana" (losartana, BRA, forma DCI PT correta).
--   2. Duplicado: "Sulfametoxazol + Trimetoprima" (J01EW01, código ATC
--      inválido para a associação) vs. "Cotrimoxazol" (J01EE01, correto).
--   3. Antiácidos: atc_code "A02AD" incompleto → "A02AD01" (hidróxido
--      de alumínio, principal representante da classe na LNME).
--
-- Estratégia (soft-delete, sem perda de dados):
--   * O sobrevivente é a entrada com nome DCI PT correto e melhor
--     código ATC (losartana, cotrimoxazol).
--   * Todos os pares de drug_interactions do duplicado são remapeados
--     para o sobrevivente. Quando o remapeamento cria um par canónico
--     já existente, mantém-se a linha com MAIOR severidade
--     (critical > moderate > minor > none) e arquiva-se a outra.
--   * drug_target_roles também é remapeado (ON CONFLICT DO NOTHING).
--   * drug_profiles/drug_pharmacology dos duplicados são arquivados
--     (sem conteúdo único, verificado antes da migração).
--   * O duplicado fica is_archived = true (padrão admin do projeto:
--     archive/restore/eliminar), nunca DELETE físico.
--   * Idempotente: reaplicar não altera nada (os remapeamentos são
--     guardados por WHERE, e o archive é reescrito com valores iguais).
--   * Janela t1→t2 é única por statement para segurança em retraces.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- 0. Snapshot de tempo da janela
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m254_t AS
SELECT clock_timestamp() AS t1, clock_timestamp() AS t2;
UPDATE _m254_t SET t2 = t1 + interval '1 second';

-- ---------------------------------------------------------------------
-- 1. IDs dos duplicados e sobreviventes (por slug, estável entre BDs)
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m254_ids AS
SELECT
  (SELECT id FROM public.drugs WHERE slug = 'losartano')                    AS losartano_id,
  (SELECT id FROM public.drugs WHERE slug = 'losartana')                    AS losartana_id,
  (SELECT id FROM public.drugs WHERE slug = 'sulfametoxazol-trimetoprima')  AS sulfametoxazol_id,
  (SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol')                 AS cotrimoxazol_id;

-- ---------------------------------------------------------------------
-- 2. Arquivar perfis e farmacologia dos duplicados
--    (sem conteúdo único — verificado na análise pré-migração)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles dp
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m254_t),
    updated_at  = now()
FROM _m254_ids i
WHERE (dp.drug_id = i.losartano_id OR dp.drug_id = i.sulfametoxazol_id)
  AND dp.is_archived = false;

UPDATE public.drug_pharmacology ph
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m254_t),
    updated_at  = now()
FROM _m254_ids i
WHERE (ph.drug_id = i.losartano_id OR ph.drug_id = i.sulfametoxazol_id)
  AND ph.is_archived = false;

-- ---------------------------------------------------------------------
-- 3. Remapear drug_target_roles dos duplicados → sobreviventes
-- ---------------------------------------------------------------------
INSERT INTO public.drug_target_roles (drug_id, target_id, role, is_archived, created_at)
SELECT i.losartana_id, dtr.target_id, dtr.role, false, now()
FROM public.drug_target_roles dtr
CROSS JOIN _m254_ids i
WHERE dtr.drug_id = i.losartano_id
ON CONFLICT (drug_id, target_id, role) DO NOTHING;

INSERT INTO public.drug_target_roles (drug_id, target_id, role, is_archived, created_at)
SELECT i.cotrimoxazol_id, dtr.target_id, dtr.role, false, now()
FROM public.drug_target_roles dtr
CROSS JOIN _m254_ids i
WHERE dtr.drug_id = i.sulfametoxazol_id
ON CONFLICT (drug_id, target_id, role) DO NOTHING;

-- Arquivar as roles antigas (depois do INSERT, para o SELECT apanhar tudo)
UPDATE public.drug_target_roles dtr
SET is_archived = true
FROM _m254_ids i
WHERE (dtr.drug_id = i.losartano_id OR dtr.drug_id = i.sulfametoxazol_id)
  AND dtr.is_archived = false;

-- ---------------------------------------------------------------------
-- 4. Remapear drug_interactions dos duplicados → sobreviventes
--    Passo A: normalizar a orientação (drug_a_id < drug_b_id)
--    Passo B: inserir no sobrevivente; colisões de par resolvidas pela
--             severidade maior; linhas perdedoras → is_archived.
-- ---------------------------------------------------------------------

-- 4A. Losartano → Losartana
-- (CASE inline no SET: a tabela-alvo do UPDATE não pode ser referenciada
--  num JOIN LATERAL da cláusula FROM — ver docs/ERROS_RECORRENTES_MIGRACOES.md,
--  ERRO 6)
UPDATE public.drug_interactions di
SET drug_a_id = i.losartana_id,
    drug_b_id = CASE WHEN di.drug_a_id = i.losartano_id THEN di.drug_b_id ELSE di.drug_a_id END,
    updated_at = now()
FROM _m254_ids i
WHERE (di.drug_a_id = i.losartano_id OR di.drug_b_id = i.losartano_id)
  AND di.drug_a_id > di.drug_b_id;

UPDATE public.drug_interactions di
SET drug_a_id = i.losartana_id,
    drug_b_id = CASE WHEN di.drug_a_id = i.losartano_id THEN di.drug_b_id ELSE di.drug_a_id END,
    updated_at = now()
FROM _m254_ids i
WHERE (di.drug_a_id = i.losartano_id OR di.drug_b_id = i.losartano_id)
  AND CASE WHEN di.drug_a_id = i.losartano_id THEN di.drug_b_id ELSE di.drug_a_id END > i.losartana_id;

-- 4A. Sulfametoxazol → Cotrimoxazol (mesmo padrão CASE inline)
UPDATE public.drug_interactions di
SET drug_a_id = i.cotrimoxazol_id,
    drug_b_id = CASE WHEN di.drug_a_id = i.sulfametoxazol_id THEN di.drug_b_id ELSE di.drug_a_id END,
    updated_at = now()
FROM _m254_ids i
WHERE (di.drug_a_id = i.sulfametoxazol_id OR di.drug_b_id = i.sulfametoxazol_id)
  AND di.drug_a_id > di.drug_b_id;

UPDATE public.drug_interactions di
SET drug_a_id = i.cotrimoxazol_id,
    drug_b_id = CASE WHEN di.drug_a_id = i.sulfametoxazol_id THEN di.drug_b_id ELSE di.drug_a_id END,
    updated_at = now()
FROM _m254_ids i
WHERE (di.drug_a_id = i.sulfametoxazol_id OR di.drug_b_id = i.sulfametoxazol_id)
  AND CASE WHEN di.drug_a_id = i.sulfametoxazol_id THEN di.drug_b_id ELSE di.drug_a_id END > i.cotrimoxazol_id;

-- 4B. Colisões de par no sobrevivente: severidade maior ganha
--     ranking: critical=4 > moderate=3 > minor=2 > none=1
CREATE TEMP TABLE _m254_rank AS
SELECT v.sev, v.rk FROM (VALUES
  ('critical', 4), ('moderate', 3), ('minor', 2), ('none', 1)
) AS v(sev, rk);

-- 4B.1 Losartana: arquiva as linhas remapeadas que perderem
UPDATE public.drug_interactions di
SET is_archived = true, updated_at = now()
FROM _m254_ids i
JOIN public.drug_interactions keep
  ON keep.drug_a_id = i.losartana_id AND keep.drug_b_id = di.drug_b_id
WHERE di.drug_a_id = i.losartana_id
  AND di.is_archived = false
  AND keep.is_archived = false
  AND keep.id <> di.id
  AND (SELECT rk FROM _m254_rank WHERE sev = keep.severity)
    >= (SELECT rk FROM _m254_rank WHERE sev = di.severity);

-- 4B.2 Cotrimoxazol: idem
UPDATE public.drug_interactions di
SET is_archived = true, updated_at = now()
FROM _m254_ids i
JOIN public.drug_interactions keep
  ON keep.drug_a_id = i.cotrimoxazol_id AND keep.drug_b_id = di.drug_b_id
WHERE di.drug_a_id = i.cotrimoxazol_id
  AND di.is_archived = false
  AND keep.is_archived = false
  AND keep.id <> di.id
  AND (SELECT rk FROM _m254_rank WHERE sev = keep.severity)
    >= (SELECT rk FROM _m254_rank WHERE sev = di.severity);

-- 4B.3 Se a linha remapeada GANHOU (severidade maior), é ela que fica:
--     arquiva a linha pré-existente do sobrevivente
UPDATE public.drug_interactions keep
SET is_archived = true, updated_at = now()
FROM _m254_ids i
JOIN public.drug_interactions di
  ON di.drug_a_id = i.losartana_id AND di.drug_b_id = keep.drug_b_id
WHERE keep.drug_a_id = i.losartana_id
  AND keep.is_archived = false
  AND di.is_archived = false
  AND keep.id <> di.id
  AND (SELECT rk FROM _m254_rank WHERE sev = di.severity)
    > (SELECT rk FROM _m254_rank WHERE sev = keep.severity);

UPDATE public.drug_interactions keep
SET is_archived = true, updated_at = now()
FROM _m254_ids i
JOIN public.drug_interactions di
  ON di.drug_a_id = i.cotrimoxazol_id AND di.drug_b_id = keep.drug_b_id
WHERE keep.drug_a_id = i.cotrimoxazol_id
  AND keep.is_archived = false
  AND di.is_archived = false
  AND keep.id <> di.id
  AND (SELECT rk FROM _m254_rank WHERE sev = di.severity)
    > (SELECT rk FROM _m254_rank WHERE sev = keep.severity);

-- ---------------------------------------------------------------------
-- 5. Arquivar os fármacos duplicados (soft-delete, padrão do projeto)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m254_t),
    archived_by = NULL,            -- migração sistema
    updated_at  = now()
FROM _m254_ids i
WHERE (d.id = i.losartano_id OR d.id = i.sulfametoxazol_id)
  AND d.is_archived = false;

-- ---------------------------------------------------------------------
-- 6. Correção do ATC dos antiácidos (A02AD → A02AD01)
-- ---------------------------------------------------------------------
UPDATE public.drugs
SET atc_code = 'A02AD01', updated_at = now()
WHERE slug = 'antiacidos'
  AND atc_code = 'A02AD';

COMMIT;

-- =====================================================================
-- Verificação pós-migração (executar à parte, expectativas):
--   SELECT slug, is_archived FROM drugs
--     WHERE slug IN ('losartano','losartana','sulfametoxazol-trimetoprima','cotrimoxazol');
--   → losartano=true, sulfametoxazol-trimetoprima=true, restantes false
--   SELECT count(*) FROM drug_interactions
--     WHERE (drug_a_id IN (SELECT id FROM drugs WHERE slug='losartano')
--         OR drug_b_id IN (SELECT id FROM drugs WHERE slug='losartano'))
--       AND is_archived = false;
--   → 0
-- =====================================================================
