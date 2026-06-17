-- Migration 025: featured_langs TEXT[] (per-language featured toggle).
--
-- Background (2026-06-17):
-- Today the homepage (`/pt` and `/en`) is served by a single
-- `app/[lang]/(public)/page.js` that calls `getFeaturedArticles(3)`,
-- `getFeaturedEvents(2)`, `getFeaturedLives(2)` WITHOUT passing `lang`.
-- Those functions filter on the boolean `featured = true` and return the
-- base PT row without merging the translation table — so the `/en`
-- homepage renders PT titles even when an EN translation exists.
--
-- Goal: the admin must be able to mark a featured item for PT, for EN, or
-- for both — independently. This migration adds `featured_langs TEXT[]`
-- alongside the legacy `featured BOOLEAN` (kept for retro-compat) and
-- updates the public RPC to project the new column.
--
-- Decisions (locked in with the user 2026-06-17):
--   1. `featured_langs TEXT[] NOT NULL DEFAULT ARRAY['pt','en']`
--   2. Backfill: `featured=true` → ARRAY['pt','en']; `featured=false` → ARRAY[]::TEXT[]
--   3. CHECK constraint (subset of {'pt','en'}) via `pg_constraint` lookup so
--      the migration is safe to re-run.
--   4. `CREATE OR REPLACE FUNCTION` for the RPC (the new RETURNS TABLE
--      swaps `featured BOOLEAN` for `featured_langs TEXT[]`; that is a
--      shape change, so the OR REPLACE will succeed because there are
--      no other overloads and `get_events_with_inscription_counts` has no
--      callers pinned to the old shape).
--
-- Idempotency: every DDL uses `IF NOT EXISTS` (or a `DO $$` lookup for
-- the CHECK constraint, which lacks native IF NOT EXISTS). The backfill
-- uses `IS DISTINCT FROM` so re-runs are no-ops.

-- ============================================================================
-- 1. Coluna featured_langs
-- ============================================================================
ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS featured_langs TEXT[] NOT NULL DEFAULT ARRAY['pt','en'];

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS featured_langs TEXT[] NOT NULL DEFAULT ARRAY['pt','en'];

ALTER TABLE public.lives
  ADD COLUMN IF NOT EXISTS featured_langs TEXT[] NOT NULL DEFAULT ARRAY['pt','en'];

COMMENT ON COLUMN public.articles.featured_langs IS 'Idiomas em que o artigo aparece na homepage (pt/en). Substitui featured BOOLEAN. Migration 025.';
COMMENT ON COLUMN public.events.featured_langs  IS 'Idiomas em que o evento aparece na homepage (pt/en). Substitui featured BOOLEAN. Migration 025.';
COMMENT ON COLUMN public.lives.featured_langs   IS 'Idiomas em que a live aparece na homepage (pt/en). Substitui featured BOOLEAN. Migration 025.';

-- ============================================================================
-- 2. CHECK constraint: featured_langs <@ ARRAY['pt','en']
-- ============================================================================
-- ALTER TABLE ... ADD CONSTRAINT não suporta IF NOT EXISTS — usamos
-- pg_constraint para detectar presença e apenas adicionar quando falta.
DO $$
DECLARE
  tbl TEXT;
  constraint_name TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY['articles', 'events', 'lives']
  LOOP
    constraint_name := tbl || '_featured_langs_check';
    IF NOT EXISTS (
      SELECT 1
      FROM pg_constraint c
      JOIN pg_class t ON t.oid = c.conrelid
      JOIN pg_namespace n ON n.oid = t.relnamespace
      WHERE n.nspname = 'public'
        AND t.relname = tbl
        AND c.conname = constraint_name
    ) THEN
      EXECUTE format(
        'ALTER TABLE public.%I ADD CONSTRAINT %I CHECK (featured_langs <@ ARRAY[%L, %L]::TEXT[])',
        tbl, constraint_name, 'pt', 'en'
      );
    END IF;
  END LOOP;
END $$;

-- ============================================================================
-- 3. Backfill idempotente a partir de featured BOOLEAN
-- ============================================================================
-- Apenas corre se a coluna `featured` ainda existe (safety net para
-- futuro DROP). Usa IS DISTINCT FROM para re-runs serem no-op.

DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'articles'
      AND column_name = 'featured'
  ) THEN
    UPDATE public.articles
    SET featured_langs = ARRAY['pt','en']
    WHERE featured = true
      AND featured_langs IS DISTINCT FROM ARRAY['pt','en'];

    UPDATE public.articles
    SET featured_langs = ARRAY[]::TEXT[]
    WHERE featured = false
      AND featured_langs IS DISTINCT FROM ARRAY[]::TEXT[];
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'events'
      AND column_name = 'featured'
  ) THEN
    UPDATE public.events
    SET featured_langs = ARRAY['pt','en']
    WHERE featured = true
      AND featured_langs IS DISTINCT FROM ARRAY['pt','en'];

    UPDATE public.events
    SET featured_langs = ARRAY[]::TEXT[]
    WHERE featured = false
      AND featured_langs IS DISTINCT FROM ARRAY[]::TEXT[];
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'lives'
      AND column_name = 'featured'
  ) THEN
    UPDATE public.lives
    SET featured_langs = ARRAY['pt','en']
    WHERE featured = true
      AND featured_langs IS DISTINCT FROM ARRAY['pt','en'];

    UPDATE public.lives
    SET featured_langs = ARRAY[]::TEXT[]
    WHERE featured = false
      AND featured_langs IS DISTINCT FROM ARRAY[]::TEXT[];
  END IF;
END $$;

-- ============================================================================
-- 4. Índice para query de homepage (lang overlap)
-- ============================================================================
-- A homepage faz `.contains('featured_langs', [lang])` + status+is_archived
-- filters. Um GIN index em featured_langs ajuda quando o array é grande.
-- Para datasets pequenos o planner usa seq scan; o índice é prophylático.
CREATE INDEX IF NOT EXISTS articles_featured_langs_gin
  ON public.articles USING GIN (featured_langs);

CREATE INDEX IF NOT EXISTS events_featured_langs_gin
  ON public.events USING GIN (featured_langs);

CREATE INDEX IF NOT EXISTS lives_featured_langs_gin
  ON public.lives USING GIN (featured_langs);

-- ============================================================================
-- 5. RPC: get_events_with_inscription_counts — project featured_langs
-- ============================================================================
-- A coluna `featured BOOLEAN` é substituída por `featured_langs TEXT[]`
-- no RETURNS TABLE. O front (EventosPage, FeaturedEvents) já lê
-- `featured_langs` directamente da DB e o RPC é o único caminho público
-- para eventos, pelo que esta é a única mudança de shape necessária.
--
-- PostgreSQL não permite alterar o `RETURNS TABLE` shape via
-- `CREATE OR REPLACE FUNCTION` (erro 42P13: "cannot change return type
-- of existing function"). É obrigatório `DROP FUNCTION` antes.
-- `IF EXISTS` torna a operação safe-to-re-run.
DROP FUNCTION IF EXISTS get_events_with_inscription_counts();

CREATE OR REPLACE FUNCTION get_events_with_inscription_counts()
RETURNS TABLE (
  id UUID,
  slug TEXT,
  title TEXT,
  excerpt TEXT,
  image_url TEXT,
  category TEXT,
  category_label TEXT,
  date DATE,
  "time" TIME,
  end_time TIME,
  location TEXT,
  type TEXT,
  capacity INT,
  hosts JSONB,
  status TEXT,
  featured_langs TEXT[],
  registration_link TEXT,
  inscription_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.id, e.slug, e.title, e.excerpt, e.image_url,
    e.category, e.category_label, e.date, e.time, e.end_time,
    e.location, e.type, e.capacity, e.hosts, e.status,
    e.featured_langs, e.registration_link,
    COUNT(i.id)::BIGINT AS inscription_count
  FROM events e
  LEFT JOIN inscricoes i ON i.evento_slug = e.slug
  WHERE e.status = 'published'
  GROUP BY e.id, e.slug, e.title, e.excerpt, e.image_url,
    e.category, e.category_label, e.date, e.time, e.end_time,
    e.location, e.type, e.capacity, e.hosts, e.status,
    e.featured_langs, e.registration_link
  ORDER BY e.date ASC;
END;
$$;

-- ============================================================================
-- 6. Sanity check final
-- ============================================================================
DO $$
DECLARE
  col_count INT;
  rpc_signature_ok BOOLEAN;
BEGIN
  SELECT COUNT(*) INTO col_count
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN ('articles', 'events', 'lives')
    AND column_name = 'featured_langs';
  RAISE NOTICE '025: % colunas featured_langs criadas (esperado: 3)', col_count;

  -- Confirmar que o RPC foi substituído e projecta featured_langs.
  -- O RETURNS TABLE de uma função NÃO aparece em information_schema.columns
  -- (que lista colunas de tabelas/views). Os nomes dos OUT parameters vivem
  -- em pg_proc.proargnames. Verificamos que "featured_langs" está lá.
  SELECT EXISTS (
    SELECT 1
    FROM pg_proc p
    WHERE p.proname = 'get_events_with_inscription_counts'
      AND p.pronamespace = 'public'::regnamespace
      AND 'featured_langs' = ANY(p.proargnames)
  ) INTO rpc_signature_ok;

  IF rpc_signature_ok THEN
    RAISE NOTICE '025: RPC get_events_with_inscription_counts projecta featured_langs ✓';
  ELSE
    RAISE EXCEPTION '025: RPC get_events_with_inscription_counts NÃO projecta featured_langs — verificar CREATE OR REPLACE';
  END IF;
END $$;
