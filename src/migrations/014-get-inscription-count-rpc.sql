-- Migration 014: Create RPC get_inscription_count
-- Versiona a função que já existe no Supabase remoto mas não estava no repo.
-- Segura para re-executar (CREATE OR REPLACE).

CREATE OR REPLACE FUNCTION public.get_inscription_count(event_slug TEXT)
RETURNS INTEGER
LANGUAGE sql SECURITY DEFINER STABLE
AS $$
  SELECT COUNT(*)::INTEGER FROM public.inscricoes
  WHERE evento_slug = $1;
$$;

-- Conceder execução a utilizadores anónimos (a função é usada no frontend público)
GRANT EXECUTE ON FUNCTION public.get_inscription_count(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.get_inscription_count(TEXT) TO authenticated;
