-- Migration 046: segurança — SET search_path em is_current_user_admin()
--
-- Contexto (auditoria "O Sentinela" #8):
--   is_current_user_admin() era SECURITY DEFINER *sem* SET search_path fixo.
--   Um caller com search_path malicioso (ex.: um schema criado por uma role
--   com privilégios) podia sequestrar os objetos resolvidos dentro da função
--   (namespace hijacking). A função irmã is_current_user_superadmin() já usa
--   o padrão correto desde a migration 020 — aqui alinhamos a irmã.
--
--   Esta função é usada em policies RLS (admin_users, admin_access_questions,
--   e outras criadas em migrations posteriores), pelo que mantém EXECUTE
--   público por design. Só o search_path de execução é fixado.
--
-- Idempotente e aditivo: CREATE OR REPLACE não altera a assinatura.

CREATE OR REPLACE FUNCTION public.is_current_user_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_current_user_admin() TO authenticated, service_role;

COMMENT ON FUNCTION public.is_current_user_admin()
  IS 'Retorna TRUE se o user autenticado está em admin_users. SECURITY DEFINER com search_path fixo (migration 046). Usada em policies RLS de admin_users e afins.';
