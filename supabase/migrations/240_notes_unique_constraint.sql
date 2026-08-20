-- =====================================================================
-- 240 — Notas contínuas: constraint UNIQUE + index de pesquisa
-- =====================================================================

-- 1. Constraint: uma nota por (user_id, saved_item_id)
--    NOT CONFLICT para ignorar se já existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'unique_note_per_item'
  ) THEN
    ALTER TABLE public.saved_item_notes
      ADD CONSTRAINT unique_note_per_item
      UNIQUE (user_id, saved_item_id);
  END IF;
END $$;

-- 2. Index para pesquisa full-text por conteúdo (português)
CREATE INDEX IF NOT EXISTS idx_saved_notes_content_fts
  ON public.saved_item_notes
  USING gin(to_tsvector('portuguese', content));

-- 3. Index para ordenação por updated_at
CREATE INDEX IF NOT EXISTS idx_saved_notes_updated
  ON public.saved_item_notes(user_id, updated_at DESC);
