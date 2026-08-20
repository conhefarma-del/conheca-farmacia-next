-- =====================================================================
-- 239_guardados_notes.sql
-- Tabela de anotações para guardados + RLS
-- =====================================================================

-- 1. Tabela de anotações
CREATE TABLE public.saved_item_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  saved_item_id UUID NOT NULL REFERENCES public.saved_items(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL CHECK (char_length(content) > 0 AND char_length(content) <= 2000),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Índices
CREATE INDEX idx_saved_notes_item ON public.saved_item_notes(saved_item_id);
CREATE INDEX idx_saved_notes_user ON public.saved_item_notes(user_id);

-- 3. RLS
ALTER TABLE public.saved_item_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users read own notes"
  ON public.saved_item_notes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users insert own notes"
  ON public.saved_item_notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own notes"
  ON public.saved_item_notes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users delete own notes"
  ON public.saved_item_notes FOR DELETE
  USING (auth.uid() = user_id);

-- 4. Trigger para updated_at automático
CREATE OR REPLACE FUNCTION public.update_saved_note_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_saved_note_update
  BEFORE UPDATE ON public.saved_item_notes
  FOR EACH ROW
  EXECUTE FUNCTION public.update_saved_note_timestamp();

-- 5. Comentários
COMMENT ON TABLE public.saved_item_notes IS 'Anotações pessoais para itens guardados';
COMMENT ON COLUMN public.saved_item_notes.content IS 'Conteúdo da anotação (máx. 2000 caracteres)';
COMMENT ON COLUMN public.saved_item_notes.updated_at IS 'Atualizado automaticamente via trigger';
