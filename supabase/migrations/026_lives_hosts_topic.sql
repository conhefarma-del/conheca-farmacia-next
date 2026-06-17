-- Migration 026: Lives — multi-host JSONB + topic PT + drop singular columns
--
-- Contexto:
--   1) Live tinha colunas singulares host_name / host_role / host_organization,
--      limitando a 1 anfitrião. Events já suporta hosts[] JSONB via 022.
--      Vamos replicar o padrão: lives.hosts e live_translations.hosts são
--      JSONB arrays de { name, role, organization }.
--   2) Live_translations.topic já existe (migration 018). Mas a tabela
--      base lives não tinha topic — admins não conseguiam preencher
--      topic PT. Adicionar topic à tabela lives (nullable).
--
-- Esta migration é IDEMPOTENTE (safe-to-re-run):
--   * ADD COLUMN IF NOT EXISTS em todas as adições.
--   * DROP COLUMN IF EXISTS em todas as remoções.
--   * UPDATEs com WHERE clause conservadora (não sobrescreve valores não-vazios).
--   * Sanity checks no fim que fazem RAISE NOTICE + RAISE EXCEPTION se
--     algo correr mal.

-- ============================================================
-- BLOCO A — Hosts multi-valor (lives + live_translations)
-- ============================================================

ALTER TABLE lives
  ADD COLUMN IF NOT EXISTS hosts JSONB NOT NULL DEFAULT '[]'::jsonb;

ALTER TABLE live_translations
  ADD COLUMN IF NOT EXISTS hosts JSONB NOT NULL DEFAULT '[]'::jsonb;

-- Backfill: cada live com pelo menos uma das 3 colunas singulares
-- preenchida ganha um array de 1 elemento. Rows sem anfitrião ficam [].
-- Envolvido em DO $$ com dynamic SQL para ser idempotente se as
-- colunas singulares já tiverem sido dropadas (caso a migration tenha
-- sido parcialmente aplicada ou alguém as dropou manualmente).
DO $backfill_lives$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'lives'
      AND column_name IN ('host_name', 'host_role', 'host_organization')
  ) THEN
    EXECUTE $sql$
      UPDATE lives l
      SET hosts = jsonb_build_array(
        jsonb_build_object(
          'name', COALESCE(l.host_name, ''),
          'role', COALESCE(l.host_role, ''),
          'organization', COALESCE(l.host_organization, '')
        )
      )
      WHERE (l.hosts = '[]'::jsonb OR l.hosts IS NULL)
        AND (l.host_name IS NOT NULL OR l.host_role IS NOT NULL OR l.host_organization IS NOT NULL)
    $sql$;
  ELSE
    RAISE NOTICE 'Migration 026: lives colunas singulares já removidas, a saltar backfill';
  END IF;
END $backfill_lives$;

-- Backfill translations (mesma lógica). Como live_translations pode ter
-- múltiplas rows por live (pt + en), aplicamos por linha.
-- NB: live_translations tem apenas host_name/host_role (migration 018);
-- host_organization nunca existiu. Para preservar a forma do array {name,role,organization}
-- produzimos organization = '' para translations.
DO $backfill_lt$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'live_translations'
      AND column_name IN ('host_name', 'host_role')
  ) THEN
    EXECUTE $sql$
      UPDATE live_translations lt
      SET hosts = jsonb_build_array(
        jsonb_build_object(
          'name', COALESCE(lt.host_name, ''),
          'role', COALESCE(lt.host_role, ''),
          'organization', ''
        )
      )
      WHERE (lt.hosts = '[]'::jsonb OR lt.hosts IS NULL)
        AND (lt.host_name IS NOT NULL OR lt.host_role IS NOT NULL)
    $sql$;
  ELSE
    RAISE NOTICE 'Migration 026: live_translations colunas singulares já removidas, a saltar backfill';
  END IF;
END $backfill_lt$;

-- Drop colunas singulares (depois do backfill completo).
-- IF EXISTS torna idempotente.
ALTER TABLE lives
  DROP COLUMN IF EXISTS host_name,
  DROP COLUMN IF EXISTS host_role,
  DROP COLUMN IF EXISTS host_organization;

ALTER TABLE live_translations
  DROP COLUMN IF EXISTS host_name,
  DROP COLUMN IF EXISTS host_role;

-- ============================================================
-- BLOCO B — Topic PT em lives (live_translations.topic já existe)
-- ============================================================

ALTER TABLE lives ADD COLUMN IF NOT EXISTS topic TEXT;

-- Backfill conservador: copiar topic de translation PT (lang='pt')
-- para a tabela lives base. Só onde a translation PT existe e
-- a tabela lives ainda não tem topic.
UPDATE lives l
SET topic = lt.topic
FROM live_translations lt
WHERE lt.live_id = l.id
  AND lt.lang = 'pt'
  AND lt.topic IS NOT NULL
  AND l.topic IS NULL;

-- Sanity check: quantas rows ainda sem topic?
DO $$
DECLARE
  null_count INT;
BEGIN
  SELECT COUNT(*) INTO null_count FROM lives WHERE topic IS NULL;
  RAISE NOTICE 'Migration 026: % rows em lives.topic ainda NULL (admin preenche)', null_count;
END $$;

-- ============================================================
-- BLOCO C — Sanity checks finais
-- ============================================================

DO $$
DECLARE
  lives_hosts_ok BOOLEAN;
  trans_hosts_ok BOOLEAN;
  topic_ok BOOLEAN;
  singulares_lives INT;
  singulares_trans INT;
BEGIN
  -- Verificar que hosts JSONB existe nas duas tabelas
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'lives'
      AND column_name = 'hosts' AND data_type = 'jsonb'
  ) INTO lives_hosts_ok;

  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'live_translations'
      AND column_name = 'hosts' AND data_type = 'jsonb'
  ) INTO trans_hosts_ok;

  -- Verificar que topic TEXT existe em lives
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'lives'
      AND column_name = 'topic' AND data_type = 'text'
  ) INTO topic_ok;

  -- Verificar que colunas singulares foram removidas
  SELECT COUNT(*) INTO singulares_lives
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'lives'
    AND column_name IN ('host_name', 'host_role', 'host_organization');

  SELECT COUNT(*) INTO singulares_trans
  FROM information_schema.columns
  WHERE table_schema = 'public' AND table_name = 'live_translations'
    AND column_name IN ('host_name', 'host_role');

  RAISE NOTICE 'Migration 026 sanity: lives.hosts JSONB = %, live_translations.hosts JSONB = %, lives.topic TEXT = %, lives singulares restantes = %, live_translations singulares restantes = %',
    lives_hosts_ok, trans_hosts_ok, topic_ok, singulares_lives, singulares_trans;

  IF NOT lives_hosts_ok THEN
    RAISE EXCEPTION 'Migration 026 falhou: lives.hosts JSONB não existe';
  END IF;
  IF NOT trans_hosts_ok THEN
    RAISE EXCEPTION 'Migration 026 falhou: live_translations.hosts JSONB não existe';
  END IF;
  IF NOT topic_ok THEN
    RAISE EXCEPTION 'Migration 026 falhou: lives.topic TEXT não existe';
  END IF;
  IF singulares_lives > 0 THEN
    RAISE EXCEPTION 'Migration 026 falhou: ainda há % colunas singulares em lives', singulares_lives;
  END IF;
  IF singulares_trans > 0 THEN
    RAISE EXCEPTION 'Migration 026 falhou: ainda há % colunas singulares em live_translations', singulares_trans;
  END IF;
END $$;
