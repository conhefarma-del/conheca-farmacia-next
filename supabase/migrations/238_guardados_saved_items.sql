-- =====================================================================
-- 238_guardados_saved_items.sql
-- Tabela de guardados (bookmarks) + RLS
-- =====================================================================

-- 1. Tabela principal
CREATE TABLE public.saved_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL CHECK (item_type IN ('drug', 'interaction', 'drug_class', 'molecular_target', 'article')),
  item_id UUID NOT NULL,
  item_slug TEXT NOT NULL,
  item_name TEXT NOT NULL,
  item_subtitle TEXT,
  item_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, item_type, item_id)
);

-- 2. Índices
CREATE INDEX idx_saved_items_user ON public.saved_items(user_id);
CREATE INDEX idx_saved_items_type ON public.saved_items(user_id, item_type);
CREATE INDEX idx_saved_items_search ON public.saved_items(user_id, item_name text_pattern_ops);

-- 3. RLS
ALTER TABLE public.saved_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own saved items"
  ON public.saved_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own saved items"
  ON public.saved_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users delete own saved items"
  ON public.saved_items FOR DELETE
  USING (auth.uid() = user_id);

-- 4. Comentários
COMMENT ON TABLE public.saved_items IS 'Itens guardados (bookmarks) pelos utilizadores';
COMMENT ON COLUMN public.saved_items.item_type IS 'Tipo: drug, interaction, drug_class, molecular_target, article';
COMMENT ON COLUMN public.saved_items.item_id IS 'ID do item na tabela correspondente';
COMMENT ON COLUMN public.saved_items.item_slug IS 'Slug para link rápido (denormalized)';
COMMENT ON COLUMN public.saved_items.item_name IS 'Nome display (denormalized para performance)';
COMMENT ON COLUMN public.saved_items.item_subtitle IS 'Subtítulo ex: classe do medicamento';
COMMENT ON COLUMN public.saved_items.item_image_url IS 'Thumbnail se disponível';
