-- Migration 022: replace singular host_* columns with JSONB hosts,
-- add translatable type column to event_translations.
--
-- Background (2026-06-16):
-- 1. events.type is a hardcoded string ('presencial' / 'online' /
--    'hibrido') that EN clients were rendering as a literal emoji +
--    label, e.g. "📍 Presencial" in /en/events/[slug]. There was no
--    field in event_translations to translate it, so the EN card
--    always showed the PT value. We add a `type` column.
-- 2. The PT form uses HostEditor (N hosts in a JSONB array). The EN
--    form had three singular columns (host_name / host_role /
--    host_bio) that translated at most one host, and they weren't
--    even being populated by the BilingualTabs (which only exposed
--    host_role + host_bio). We add a JSONB `hosts` column that
--    mirrors the events.hosts shape and DROP the three singular
--    columns that the new EN flow will no longer use.
--
-- Why DROP the old columns:
-- - They were never populated by the admin (BilingualTabs only
--   exposed 2 of 3 fields, and the read path in content.js used
--   `formData.host_name` directly, which EventForm never sent
--   because it sends `hosts` JSONB instead).
-- - Leaving them around would invite the same silent-orphaning
--   pattern that the i18n audit found for excerpt/category_label.
--
-- Backfill (safe, idempotent):
-- For every event_translations row that has a matching events row,
-- copy events.type and events.hosts into the new columns when
-- they are NULL. We use COALESCE so a future manual EN value is
-- never overwritten by the backfill.

ALTER TABLE public.event_translations
  ADD COLUMN IF NOT EXISTS type  TEXT,
  ADD COLUMN IF NOT EXISTS hosts JSONB;

-- Backfill from base events row (only fills NULL slots).
UPDATE public.event_translations et
   SET type  = COALESCE(et.type, e.type),
       hosts = COALESCE(et.hosts, e.hosts)
   FROM public.events e
  WHERE et.event_id = e.id
    AND (et.type IS NULL OR et.hosts IS NULL);

-- Drop the three singular host columns. They are unused by the
-- new HostEditor-backed EN flow.
ALTER TABLE public.event_translations
  DROP COLUMN IF EXISTS host_name,
  DROP COLUMN IF EXISTS host_role,
  DROP COLUMN IF EXISTS host_bio;
