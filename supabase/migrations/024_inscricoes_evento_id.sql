-- Migration 024: Add evento_id to inscricoes (replaces slug-based FK)
-- Reason: EN translated slugs broke inscricoes.evento_slug filtering;
--         useCapacityPolling returned 0 for /en/events/[slug].
--         evento_id (UUID) is stable across translations.

BEGIN;

-- 1. Add column (nullable for backfill safety)
ALTER TABLE inscricoes
  ADD COLUMN IF NOT EXISTS evento_id UUID REFERENCES events(id) ON DELETE SET NULL;

-- 2. Backfill from events.slug (5 of 9 rows match)
UPDATE inscricoes i
SET evento_id = e.id
FROM events e
WHERE e.slug = i.evento_slug
  AND i.evento_id IS NULL;

-- 3. Manual remap for orphan slugs (events were renamed):
--    001-farmacologia-clinica → farmacologia-clinica (id=98ad7592-...)
--    004-congresso-farmacia → congresso-farmacia-2026 (id=b9b18901-...)
UPDATE inscricoes
SET evento_id = '98ad7592-3cae-4dc4-9c46-643ad6c5e5b2'::uuid
WHERE evento_slug = '001-farmacologia-clinica' AND evento_id IS NULL;

UPDATE inscricoes
SET evento_id = 'b9b18901-235f-4d2a-ba3b-ffbbc1724902'::uuid
WHERE evento_slug = '004-congresso-farmacia' AND evento_id IS NULL;

-- 4. Partial index (polling by id on filtered subset)
CREATE INDEX IF NOT EXISTS idx_inscricoes_evento_id
  ON inscricoes(evento_id) WHERE evento_id IS NOT NULL;

-- 5. Audit: how many rows are still NULL?
DO $$
DECLARE
  null_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO null_count FROM inscricoes WHERE evento_id IS NULL;
  RAISE NOTICE 'inscricoes.evento_id backfill complete. NULL rows remaining: %', null_count;
END $$;

COMMIT;