-- Migration 028: ADD COLUMN excerpt to live_translations.
--
-- Background (2026-06-17):
-- Migration 018 created live_translations with a `description` column but
-- no `excerpt` column. The PT base table (lives) stores live summary in
-- `excerpt` (not `description`).
--
-- Migration 027 dropped `description` (dead — the BilingualTabs form
-- never wrote to it; PT source was lives.excerpt which has no
-- corresponding translation column). The BilingualTabs was updated to
-- write `excerpt` instead, mirroring the events pattern (event_-
-- translations has `excerpt` since migration 023). But the `excerpt`
-- column on live_translations was never created.
--
-- Result after 027: upsert sent `{excerpt, ...}` but the table has no
-- `excerpt` column → PostgREST error: "Could not find the 'excerpt'
-- column of 'live_translations' in the schema cache".
--
-- This migration adds the missing `excerpt` column so the auto-translate
-- upsert can succeed.

ALTER TABLE public.live_translations
  ADD COLUMN IF NOT EXISTS excerpt TEXT;
