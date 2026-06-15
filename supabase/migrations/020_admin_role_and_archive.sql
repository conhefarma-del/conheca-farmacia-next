-- Migration 020: admin role hierarchy + soft delete (is_archived)
--
-- Contexto:
--   - Auditado por o-sentinela a 2026-06-15; superadmin permite separar
--     operações destrutivas (DELETE físico) de operações de redacção.
--   - Soft delete (is_archived) é a primitiva segura para admins; hard
--     delete fica reservado a superadmin.
--   - Tudo aditivo e idempotente: seguro de aplicar sobre o estado pós-019.
--
-- A) Coluna role em admin_users
-- B) Coluna is_archived em articles/events/lives
-- C) Índices parciais para queries públicas
-- D) Função is_current_user_superadmin()
-- E) UPDATE inicial do superadmin (f7256e68-7583-40e7-8975-331ad50ce603)
-- F) RLS: hard delete em articles/events/lives só superadmin
-- G) RLS: admin_users gerida só por superadmin

-- ============================================================
-- A) admin_users.role
-- ============================================================

ALTER TABLE public.admin_users
  ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'admin'
    CHECK (role IN ('admin', 'superadmin'));

COMMENT ON COLUMN public.admin_users.role
  IS 'admin: redacção (não pode DELETE físico). superadmin: gestão de admins + DELETE físico. Definido em migration 020.';

-- ============================================================
-- B) is_archived em articles/events/lives
-- ============================================================
-- ADD COLUMN ... DEFAULT FALSE desde Postgres 11 é metadata-only (sem rewrite).

ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.lives
  ADD COLUMN IF NOT EXISTS is_archived BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN public.articles.is_archived
  IS 'Soft delete: TRUE esconde o artigo das queries públicas. Hard delete (DELETE FROM) só para superadmin.';
COMMENT ON COLUMN public.events.is_archived
  IS 'Soft delete: TRUE esconde o evento das queries públicas. Hard delete só para superadmin.';
COMMENT ON COLUMN public.lives.is_archived
  IS 'Soft delete: TRUE esconde a live das queries públicas. Hard delete só para superadmin.';

-- ============================================================
-- C) Índices parciais (queries públicas: status=published AND is_archived=false)
-- ============================================================

CREATE INDEX IF NOT EXISTS articles_published_active_idx
  ON public.articles (published_at DESC)
  WHERE status = 'published' AND is_archived = FALSE;

CREATE INDEX IF NOT EXISTS events_published_active_idx
  ON public.events (date DESC)
  WHERE status = 'published' AND is_archived = FALSE;

CREATE INDEX IF NOT EXISTS lives_published_active_idx
  ON public.lives (date DESC)
  WHERE status = 'published' AND is_archived = FALSE;

-- ============================================================
-- D) Função is_current_user_superadmin()
-- ============================================================
-- SECURITY DEFINER + search_path fixo (mesmo padrão que 018).

CREATE OR REPLACE FUNCTION public.is_current_user_superadmin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE user_id = auth.uid() AND role = 'superadmin'
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_current_user_superadmin() TO authenticated, service_role;

COMMENT ON FUNCTION public.is_current_user_superadmin()
  IS 'Retorna TRUE se o user autenticado tem role = superadmin em admin_users. Define-se em migration 020.';

-- ============================================================
-- E) Promover o superadmin inicial
-- ============================================================
-- ATENÇÃO: o user_id abaixo é o admin principal do projecto. Para adicionar
-- outros superadmins no futuro, repetir o UPDATE via SQL Editor ou criar
-- uma Server Action gated por is_current_user_superadmin().

UPDATE public.admin_users
  SET role = 'superadmin'
  WHERE user_id = 'f7256e68-7583-40e7-8975-331ad50ce603';

-- ============================================================
-- F) RLS: DELETE em articles/events/lives só superadmin
-- ============================================================
-- As policies existentes de SELECT/INSERT/UPDATE (de migrations anteriores)
-- continuam inalteradas. Aqui restringimos só a porta do DELETE.

DROP POLICY IF EXISTS "admin_delete_articles" ON public.articles;
CREATE POLICY "admin_delete_articles" ON public.articles
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

DROP POLICY IF EXISTS "admin_delete_events" ON public.events;
CREATE POLICY "admin_delete_events" ON public.events
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

DROP POLICY IF EXISTS "admin_delete_lives" ON public.lives;
CREATE POLICY "admin_delete_lives" ON public.lives
  FOR DELETE TO authenticated
  USING (public.is_current_user_superadmin());

-- ============================================================
-- G) RLS: admin_users gerida só por superadmin
-- ============================================================
-- Antes: admin podia SELECT. Agora: superadmin ganha ALL (INSERT/UPDATE/DELETE),
-- admin mantém SELECT via policy anterior de 015 ("admin_only_select_admin_users").

DROP POLICY IF EXISTS "superadmin_manage_admin_users" ON public.admin_users;
CREATE POLICY "superadmin_manage_admin_users" ON public.admin_users
  FOR ALL TO authenticated
  USING (public.is_current_user_superadmin())
  WITH CHECK (public.is_current_user_superadmin());

-- ============================================================
-- H) Sanity check (idempotente)
-- ============================================================
-- Confirma que o teu user ficou com superadmin. Se a row não aparecer,
-- a migration reportou sucesso mas o user_id pode estar errado.

DO $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM public.admin_users
  WHERE user_id = 'f7256e68-7583-40e7-8975-331ad50ce603'
    AND role = 'superadmin';

  IF v_count = 0 THEN
    RAISE WARNING 'Migration 020: o user f7256e68-7583-40e7-8975-331ad50ce603 não está como superadmin. Confirma o user_id.';
  ELSE
    RAISE NOTICE 'Migration 020: superadmin promovido com sucesso.';
  END IF;
END $$;
