-- Migration 021: add excerpt and category_label to event_translations
-- These columns were defined in ENTITY_TRANSLATABLE_FIELDS.event
-- (lib/api/translations.js) and in the BilingualTabs admin form
-- (app/[lang]/admin/(protected)/eventos/[id]/page.js), but they were
-- missing from the event_translations table created in migration 018.
-- Result: the saveTranslationAction upsert silently dropped these
-- values, so /en/events/[slug] kept showing the PT excerpt and the PT
-- category label (e.g. "Congresso") even after manual translation.
--
-- This migration is purely additive (no DROP / RENAME / data backfill
-- is safe — leaving existing rows with NULL is the right behaviour
-- because the mergeEntity helper falls back to the PT row whenever
-- the translation value is NULL).

ALTER TABLE public.event_translations
  ADD COLUMN IF NOT EXISTS excerpt        TEXT,
  ADD COLUMN IF NOT EXISTS category_label TEXT;
