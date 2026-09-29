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
--    Formato longo: uma linha por par duplicado → sobrevivente
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m254_ids AS
SELECT d.id AS duplicado_id, s.id AS sobrevivente_id
FROM (VALUES
  ('losartano',                   'losartana'),
  ('sulfametoxazol-trimetoprima', 'cotrimoxazol')
) AS v(slug_dup, slug_sob)
JOIN public.drugs d ON d.slug = v.slug_dup
JOIN public.drugs s ON s.slug = v.slug_sob;

-- ---------------------------------------------------------------------
-- 2. Arquivar perfis e farmacologia dos duplicados
--    (sem conteúdo único — verificado na análise pré-migração)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles dp
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m254_t),
    updated_at  = now()
FROM _m254_ids i
WHERE dp.drug_id = i.duplicado_id
  AND dp.is_archived = false;

UPDATE public.drug_pharmacology ph
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m254_t),
    updated_at  = now()
FROM _m254_ids i
WHERE ph.drug_id = i.duplicado_id
  AND ph.is_archived = false;

-- ---------------------------------------------------------------------
-- 3. Remapear drug_target_roles dos duplicados → sobreviventes
-- ---------------------------------------------------------------------
INSERT INTO public.drug_target_roles (drug_id, target_id, role, is_archived, created_at)
SELECT i.sobrevivente_id, dtr.target_id, dtr.role, false, now()
FROM public.drug_target_roles dtr
CROSS JOIN _m254_ids i
WHERE dtr.drug_id = i.duplicado_id
ON CONFLICT (drug_id, target_id, role) DO NOTHING;

-- Arquivar as roles antigas (depois do INSERT, para o SELECT apanhar tudo)
UPDATE public.drug_target_roles dtr
SET is_archived = true
FROM _m254_ids i
WHERE dtr.drug_id = i.duplicado_id
  AND dtr.is_archived = false;

-- ---------------------------------------------------------------------
-- 4. Remapear drug_interactions dos duplicados → sobreviventes
--    ORDEM CORRETA (ERRO 7 do docs/ERROS_RECORRENTES_MIGRACOES.md):
--    o UNIQUE (drug_a_id, drug_b_id) dispara DURANTE o UPDATE de
--    remapeamento, logo as colisões têm de ser resolvidas ANTES:
--      4A: snapshot das linhas do duplicado com o seu par normalizado
--      4B: resolver colisões (severidade maior ganha, desempate =
--          sobrevivente) ARQUIVANDO perdedoras — sem tocar nos pares
--      4C: só então remapear as restantes, com guarda NOT EXISTS
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m254_rank AS
SELECT v.sev, v.rk FROM (VALUES
  ('critical', 4), ('moderate', 3), ('minor', 2), ('none', 1)
) AS v(sev, rk);

-- Pares a processar (duplicado → sobrevivente), com severidade e par normalizado
CREATE TEMP TABLE _m254_move AS
SELECT di.id AS linha_id,
       i.sobrevivente_id,
       i.duplicado_id,
       LEAST(di.drug_a_id, di.drug_b_id)  AS par_a,
       GREATEST(di.drug_a_id, di.drug_b_id) AS par_b,
       di.severity
FROM public.drug_interactions di
JOIN _m254_ids i
  ON di.drug_a_id = i.duplicado_id OR di.drug_b_id = i.duplicado_id
WHERE di.is_archived = false;

-- 4B. Colisões: para cada par destino que já existe no sobrevivente,
--     decide por severidade qual linha sobrevive (desempate: sobrevivente)
--     4B.1 arquiva a linha DO DUPLICADO quando a do sobrevivente é >=
UPDATE public.drug_interactions di
SET is_archived = true, updated_at = now()
FROM _m254_move t
JOIN public.drug_interactions keep
  ON keep.id <> t.linha_id
 AND keep.is_archived = false
 AND LEAST(keep.drug_a_id, keep.drug_b_id)  = t.par_a
 AND GREATEST(keep.drug_a_id, keep.drug_b_id) = t.par_b
WHERE di.id = t.linha_id
  AND (SELECT rk FROM _m254_rank WHERE sev = keep.severity)
    >= (SELECT rk FROM _m254_rank WHERE sev = t.severity);

--     4B.2 arquiva a linha DO SOBREVIVENTE quando a do duplicado é >
--     (só corre se a 4B.1 não arquivou já esta linha do duplicado)
UPDATE public.drug_interactions keep
SET is_archived = true, updated_at = now()
FROM _m254_move t
JOIN public.drug_interactions dup
  ON dup.id = t.linha_id
WHERE keep.id <> t.linha_id
  AND keep.is_archived = false
  AND dup.is_archived = false
  AND LEAST(keep.drug_a_id, keep.drug_b_id)  = t.par_a
  AND GREATEST(keep.drug_a_id, keep.drug_b_id) = t.par_b
  AND (SELECT rk FROM _m254_rank WHERE sev = t.severity)
    > (SELECT rk FROM _m254_rank WHERE sev = keep.severity);

-- 4C. Remapear as linhas remanescentes do duplicado (não arquivadas, sem
--     colisão viva no sobrevivente) — a guarda NOT EXISTS dá idempotência
UPDATE public.drug_interactions di
SET drug_a_id = CASE WHEN di.drug_a_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_a_id END,
    drug_b_id = CASE WHEN di.drug_b_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_b_id END,
    updated_at = now()
FROM _m254_ids m
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
-- 5. Arquivar os fármacos duplicados (soft-delete, padrão do projeto)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m254_t),
    archived_by = NULL,            -- migração sistema
    updated_at  = now()
FROM _m254_ids i
WHERE d.id = i.duplicado_id
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
