-- =====================================================================
-- 153 — Contador de visualizações das entrevistas
-- ---------------------------------------------------------------------
-- A tabela `interviews` já tem a coluna `view_count` (migração 152).
-- Esta migração adiciona a RPC `increment_interview_view` — SECURITY
-- DEFINER, só incrementa um contador de entrevistas publicadas — e o
-- índice de ordenação por mais vistas. Idempotente.
-- =====================================================================

CREATE INDEX IF NOT EXISTS idx_interviews_views
  ON public.interviews(view_count DESC);

-- RPC de incremento — anon/authenticated só podem incrementar (nunca
-- ler/alterar a linha diretamente: o UPDATE na tabela é admin-only).
CREATE OR REPLACE FUNCTION public.increment_interview_view(p_interview_id UUID)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  UPDATE public.interviews
  SET view_count = view_count + 1
  WHERE id = p_interview_id
    AND status = 'published'
    AND is_archived = false;
$$;

REVOKE ALL ON FUNCTION public.increment_interview_view(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.increment_interview_view(UUID) TO anon, authenticated;

-- =====================================================================
-- FIM — 153: contador de visualizações das entrevistas
-- =====================================================================
