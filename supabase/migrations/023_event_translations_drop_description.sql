-- Migration 023: drop event_translations.description.
--
-- Background (2026-06-16):
-- event_translations.description was added in migration 018 but the EN
-- admin form (BilingualTabs) had a "description" input that was always
-- empty on the EN side because the PT base table (events) does not have
-- a `description` column — PT event content is stored in events.excerpt
-- (and the long form is in the `hosts`/category fields, not a free-text
-- description). The input was dead UI; nothing ever wrote to the column.
--
-- With migration 022 (type + hosts JSONB + drop of singular host_*),
-- the admin form now uses the `excerpt` field for short text, so the
-- orphan `description` column can be dropped safely.
--
-- Note: this migration does NOT backfill or rename — the column is
-- known to be empty / unused in production. The previous
-- `description` form field is replaced by `excerpt` (which already
-- exists and IS populated by the PT admin form).

ALTER TABLE public.event_translations
  DROP COLUMN IF EXISTS description;
