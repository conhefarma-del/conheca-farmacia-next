-- Migration 015: Security hardening Phase 3 — is_current_user_admin() + RLS fixes
-- Applied: 2026-06-03

-- 1. Criar função reutilizável is_current_user_admin()
CREATE OR REPLACE FUNCTION public.is_current_user_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM admin_users WHERE user_id = auth.uid()
  );
$$;

-- 2. RLS: admin_users SELECT — restringir a admins (antes: qual=true, qualquer autenticado podia ler)
DROP POLICY IF EXISTS "Admin users can read admin_users" ON admin_users;
CREATE POLICY "admin_only_select_admin_users" ON admin_users
  FOR SELECT TO authenticated
  USING (is_current_user_admin());

-- 3. RLS: admin_access_questions — corrigir with_check null
DROP POLICY IF EXISTS "Admins can manage access questions" ON admin_access_questions;
CREATE POLICY "admin_manage_access_questions" ON admin_access_questions
  FOR ALL TO authenticated
  USING (is_current_user_admin())
  WITH CHECK (is_current_user_admin());
