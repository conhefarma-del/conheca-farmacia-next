-- Migration 027: drop live_translations.description.
--
-- Background (2026-06-17):
-- live_translations.description was added in migration 018 but the EN
-- admin form (BilingualTabs) had a "description" input that was always
-- empty on the EN side because the PT base table (lives) does not have
-- a `description` column — PT live content is stored in lives.excerpt.
-- The input was dead UI; nothing ever wrote to the column.
--
-- Mirrors migration 023 (same fix applied to events). The BilingualTabs
-- `fields` array for lives now uses `excerpt` instead of `description`
-- and `meta_description` is removed (lives has no PT meta_description
-- either). ENTITY_FIELDS.live and ENTITY_TRANSLATABLE_FIELDS.live in
-- lib/{actions,api}/translations.{js} are updated in lockstep.
--
-- Note: this migration does NOT backfill or rename — the column is
-- known to be empty / unused in production. The previous
-- `description` form field is replaced by `excerpt` (which already
-- exists and IS populated by the PT admin form).

ALTER TABLE public.live_translations
  DROP COLUMN IF EXISTS description;
