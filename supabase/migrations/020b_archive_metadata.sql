-- 020b_archive_metadata.sql
-- Adiciona archived_at + archived_by a articles/events/lives.
-- Migration 020 (2026-06-15) criou is_archived; agora guardamos quando e por quem.

-- ============================================================================
-- 1. Colunas archived_at + archived_by
-- ============================================================================
ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS archived_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS archived_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

ALTER TABLE public.lives
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS archived_by UUID REFERENCES auth.users(id) ON DELETE SET NULL;

COMMENT ON COLUMN public.articles.archived_at IS 'Quando foi arquivado (soft delete). NULL = não arquivado. Migration 020b.';
COMMENT ON COLUMN public.articles.archived_by IS 'UUID do admin que arquivou. Migration 020b.';
COMMENT ON COLUMN public.events.archived_at  IS 'Quando foi arquivado (soft delete). NULL = não arquivado. Migration 020b.';
COMMENT ON COLUMN public.events.archived_by  IS 'UUID do admin que arquivou. Migration 020b.';
COMMENT ON COLUMN public.lives.archived_at   IS 'Quando foi arquivado (soft delete). NULL = não arquivado. Migration 020b.';
COMMENT ON COLUMN public.lives.archived_by   IS 'UUID do admin que arquivou. Migration 020b.';

-- ============================================================================
-- 2. Índice em archived_at para listagem ordenada (admin: "arquivados mais recentes")
-- ============================================================================
CREATE INDEX IF NOT EXISTS articles_archived_at_idx ON public.articles (archived_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS events_archived_at_idx  ON public.events  (archived_at DESC NULLS LAST);
CREATE INDEX IF NOT EXISTS lives_archived_at_idx   ON public.lives   (archived_at DESC NULLS LAST);

-- ============================================================================
-- 3. Sanity check final
-- ============================================================================
DO $$
DECLARE
  col_count INT;
BEGIN
  SELECT COUNT(*) INTO col_count
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN ('articles', 'events', 'lives')
    AND column_name IN ('archived_at', 'archived_by');
  RAISE NOTICE '020b: % colunas archived_at/archived_by criadas (esperado: 6 = 2 cols × 3 tabelas)', col_count;
END $$;
