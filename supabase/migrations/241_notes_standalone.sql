-- =====================================================================
-- 241 — Notas soltas: tornar saved_item_id nullable
-- =====================================================================

-- Tornar saved_item_id nullable para notas sem item associado
ALTER TABLE public.saved_item_notes
  ALTER COLUMN saved_item_id DROP NOT NULL;

-- Criar índice para buscas por notas soltas
CREATE INDEX IF NOT EXISTS idx_saved_item_notes_standalone
  ON public.saved_item_notes (user_id)
  WHERE saved_item_id IS NULL;

-- Criar índice para busca full-text nas notas (se não existir)
CREATE INDEX IF NOT EXISTS idx_saved_item_notes_fts
  ON public.saved_item_notes
  USING gin (to_tsvector('portuguese', content));

-- Comentário
COMMENT ON COLUMN public.saved_item_notes.saved_item_id IS 'FK para saved_items. NULL = nota solta (sem item associado)';
