-- =====================================================================
-- 243 — Notas: adicionar coluna title
-- ---------------------------------------------------------------------
-- Permite ao utilizador dar um título às notas soltas e alterar
-- o título das notas de outros itens.
-- =====================================================================

-- Adicionar coluna title (nullable para backward compatibility)
ALTER TABLE public.saved_item_notes
  ADD COLUMN IF NOT EXISTS title TEXT;

-- Comentário
COMMENT ON COLUMN public.saved_item_notes.title IS 'Título opcional da nota. Para notas soltas, é o título visível. Para notas de itens, pode ser editado pelo utilizador.';
