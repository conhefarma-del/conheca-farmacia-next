-- Migration: Fix RLS policies - remove public SELECT from sensitive tables
-- Date: 2026-05-19
-- Security: Only admins can read inscricoes, event_registrations, newsletter

-- 1. INSCRICOES: Remove public SELECT, keep admin-only
DROP POLICY IF EXISTS "allow_anon_select" ON inscricoes;
DROP POLICY IF EXISTS "allow_authenticated_read" ON inscricoes;

CREATE POLICY "Admins can read inscricoes"
ON inscricoes FOR SELECT
USING (
  EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid())
);

-- 2. EVENT_REGISTRATIONS: Remove public SELECT (counts)
DROP POLICY IF EXISTS "Public can view event registration counts" ON event_registrations;

-- 3. NEWSLETTER: Remove public SELECT (counts)
DROP POLICY IF EXISTS "Public can view newsletter counts" ON newsletter;
