-- =====================================================================
-- 146 — Contador de leituras dos artigos científicos (vistas)
-- ---------------------------------------------------------------------
-- Coluna `view_count` + RPC `increment_scientific_view` para o ordenar
-- por "mais lido" na listagem pública. O RPC é SECURITY DEFINER e só
-- incrementa um contador de artigos publicados — não expõe dados.
-- Idempotente: ADD COLUMN IF NOT EXISTS + CREATE OR REPLACE.
-- =====================================================================

ALTER TABLE public.scientific_articles
  ADD COLUMN IF NOT EXISTS view_count INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_sci_articles_views
  ON public.scientific_articles(view_count DESC);

-- RPC de incremento — anon/authenticated só podem incrementar (nunca
-- ler/alterar a linha diretamente: o UPDATE na tabela é admin-only).
CREATE OR REPLACE FUNCTION public.increment_scientific_view(p_article_id UUID)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  UPDATE public.scientific_articles
  SET view_count = view_count + 1
  WHERE id = p_article_id
    AND status = 'published'
    AND is_archived = false;
$$;

REVOKE ALL ON FUNCTION public.increment_scientific_view(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.increment_scientific_view(UUID) TO anon, authenticated;

-- =====================================================================
-- FIM — 146: contador de leituras
-- =====================================================================
