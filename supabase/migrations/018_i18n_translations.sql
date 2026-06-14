-- Migration 018: i18n content translation tables
-- Adds: article_translations, event_translations, live_translations, translation_logs
-- All 3 content tables share the same shape (PK composite: entity_id + lang).
-- RLS: public SELECT, admin-only INSERT/UPDATE/DELETE.

-- ============================================================================
-- 1. article_translations
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.article_translations (
  article_id        UUID        NOT NULL REFERENCES public.articles(id) ON DELETE CASCADE,
  lang              CHAR(2)     NOT NULL CHECK (lang IN ('pt', 'en')),
  slug              TEXT        NOT NULL,
  title             TEXT        NOT NULL,
  excerpt           TEXT,
  content           TEXT,
  category          TEXT,
  category_label    TEXT,
  author_name       TEXT,
  author_role       TEXT,
  author_bio        TEXT,
  meta_description  TEXT,
  auto_translated   BOOLEAN     NOT NULL DEFAULT TRUE,
  translated_at     TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (article_id, lang)
);

CREATE UNIQUE INDEX IF NOT EXISTS article_translations_slug_lang_uq
  ON public.article_translations (slug, lang);

CREATE INDEX IF NOT EXISTS article_translations_article_id_idx
  ON public.article_translations (article_id);

-- ============================================================================
-- 2. event_translations
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.event_translations (
  event_id          UUID        NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  lang              CHAR(2)     NOT NULL CHECK (lang IN ('pt', 'en')),
  slug              TEXT        NOT NULL,
  title             TEXT        NOT NULL,
  description       TEXT,
  location          TEXT,
  host_name         TEXT,
  host_role         TEXT,
  host_bio          TEXT,
  meta_description  TEXT,
  auto_translated   BOOLEAN     NOT NULL DEFAULT TRUE,
  translated_at     TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (event_id, lang)
);

CREATE UNIQUE INDEX IF NOT EXISTS event_translations_slug_lang_uq
  ON public.event_translations (slug, lang);

CREATE INDEX IF NOT EXISTS event_translations_event_id_idx
  ON public.event_translations (event_id);

-- ============================================================================
-- 3. live_translations
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.live_translations (
  live_id           UUID        NOT NULL REFERENCES public.lives(id) ON DELETE CASCADE,
  lang              CHAR(2)     NOT NULL CHECK (lang IN ('pt', 'en')),
  slug              TEXT        NOT NULL,
  title             TEXT        NOT NULL,
  description       TEXT,
  host_name         TEXT,
  host_role         TEXT,
  topic             TEXT,
  meta_description  TEXT,
  auto_translated   BOOLEAN     NOT NULL DEFAULT TRUE,
  translated_at     TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (live_id, lang)
);

CREATE UNIQUE INDEX IF NOT EXISTS live_translations_slug_lang_uq
  ON public.live_translations (slug, lang);

CREATE INDEX IF NOT EXISTS live_translations_live_id_idx
  ON public.live_translations (live_id);

-- ============================================================================
-- 4. translation_logs (auditoria + rate limit)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.translation_logs (
  id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type   TEXT         NOT NULL CHECK (entity_type IN ('article', 'event', 'live')),
  entity_id     UUID         NOT NULL,
  lang          CHAR(2)      NOT NULL CHECK (lang IN ('pt', 'en')),
  char_count    INTEGER      NOT NULL DEFAULT 0,
  model         TEXT         NOT NULL,
  cost_estimate NUMERIC(10,6) NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS translation_logs_created_at_idx
  ON public.translation_logs (created_at DESC);

-- ============================================================================
-- 5. RLS — public read, admin write
-- ============================================================================
ALTER TABLE public.article_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_translations   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_translations    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.translation_logs     ENABLE ROW LEVEL SECURITY;

-- Public SELECT on translations
DROP POLICY IF EXISTS "public_read_article_translations"  ON public.article_translations;
DROP POLICY IF EXISTS "public_read_event_translations"    ON public.event_translations;
DROP POLICY IF EXISTS "public_read_live_translations"     ON public.live_translations;

CREATE POLICY "public_read_article_translations"
  ON public.article_translations FOR SELECT TO public USING (TRUE);

CREATE POLICY "public_read_event_translations"
  ON public.event_translations FOR SELECT TO public USING (TRUE);

CREATE POLICY "public_read_live_translations"
  ON public.live_translations FOR SELECT TO public USING (TRUE);

-- Admin INSERT/UPDATE/DELETE on translations
DROP POLICY IF EXISTS "admin_write_article_translations" ON public.article_translations;
DROP POLICY IF EXISTS "admin_write_event_translations"   ON public.event_translations;
DROP POLICY IF EXISTS "admin_write_live_translations"    ON public.live_translations;

CREATE POLICY "admin_write_article_translations"
  ON public.article_translations FOR ALL TO authenticated
  USING (is_current_user_admin())
  WITH CHECK (is_current_user_admin());

CREATE POLICY "admin_write_event_translations"
  ON public.event_translations FOR ALL TO authenticated
  USING (is_current_user_admin())
  WITH CHECK (is_current_user_admin());

CREATE POLICY "admin_write_live_translations"
  ON public.live_translations FOR ALL TO authenticated
  USING (is_current_user_admin())
  WITH CHECK (is_current_user_admin());

-- translation_logs: admin read/write only (server action)
DROP POLICY IF EXISTS "admin_read_translation_logs"   ON public.translation_logs;
DROP POLICY IF EXISTS "admin_write_translation_logs"  ON public.translation_logs;

CREATE POLICY "admin_read_translation_logs"
  ON public.translation_logs FOR SELECT TO authenticated
  USING (is_current_user_admin());

CREATE POLICY "admin_write_translation_logs"
  ON public.translation_logs FOR INSERT TO authenticated
  WITH CHECK (is_current_user_admin());

-- ============================================================================
-- 6. updated_at trigger
-- ============================================================================
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS article_translations_set_updated_at ON public.article_translations;
CREATE TRIGGER article_translations_set_updated_at
  BEFORE UPDATE ON public.article_translations
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS event_translations_set_updated_at ON public.event_translations;
CREATE TRIGGER event_translations_set_updated_at
  BEFORE UPDATE ON public.event_translations
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS live_translations_set_updated_at ON public.live_translations;
CREATE TRIGGER live_translations_set_updated_at
  BEFORE UPDATE ON public.live_translations
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
