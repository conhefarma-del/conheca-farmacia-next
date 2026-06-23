-- Migration 031: Security hardening — auth rate limiting, gate lockout, RLS fixes
-- Part of Sentinela audit 2026-06-23

-- =============================================================================
-- 1) auth_attempts table — logs every login/gate attempt for rate limiting
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.auth_attempts (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ip        INET,
  email     TEXT,                     -- hashed (djb2 8-char hex) — never raw PII
  attempt   TEXT NOT NULL,            -- 'login' | 'gate' | 'inscription'
  success   BOOLEAN NOT NULL DEFAULT FALSE,
  user_id   UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_auth_attempts_ip_attempt ON public.auth_attempts (ip, attempt, created_at);
CREATE INDEX idx_auth_attempts_email_attempt ON public.auth_attempts (email, attempt, created_at);

-- RLS: only admins can read auth_attempts
ALTER TABLE public.auth_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can read auth_attempts"
  ON public.auth_attempts FOR SELECT
  TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- Service role can always insert (used by RPCs)
CREATE POLICY "Service role can insert auth_attempts"
  ON public.auth_attempts FOR INSERT
  TO service_role
  WITH CHECK (true);

-- =============================================================================
-- 2) RPC: check_rate_limit — generic rate limiter
--     Returns true if rate limit is HIT (caller should reject).
--     Params: p_ip, p_email_hash, p_attempt_type, p_max_attempts, p_window_seconds
-- =============================================================================
CREATE OR REPLACE FUNCTION public.check_rate_limit(
  p_ip            INET DEFAULT NULL,
  p_email_hash    TEXT DEFAULT NULL,
  p_attempt_type  TEXT DEFAULT 'login',
  p_max_attempts  INT  DEFAULT 5,
  p_window_seconds INT DEFAULT 300
)
RETURNS BOOLEAN   -- true = rate limited (reject), false = ok (proceed)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COUNT(*) >= p_max_attempts
  FROM public.auth_attempts
  WHERE attempt = p_attempt_type
    AND created_at > now() - (p_window_seconds || ' seconds')::interval
    AND (
      (p_ip IS NOT NULL AND ip = p_ip)
      OR
      (p_email_hash IS NOT NULL AND email = p_email_hash)
    );
$$;

-- =============================================================================
-- 3) RPC: log_auth_attempt — insert a record into auth_attempts
--     Uses SECURITY DEFINER so client-side anon can insert via RPC
--     (not directly into the table — RLS blocks them).
-- =============================================================================
CREATE OR REPLACE FUNCTION public.log_auth_attempt(
  p_ip            INET DEFAULT NULL,
  p_email_hash    TEXT DEFAULT NULL,
  p_attempt_type  TEXT DEFAULT 'login',
  p_success       BOOLEAN DEFAULT FALSE,
  p_user_id       UUID DEFAULT NULL
)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  INSERT INTO public.auth_attempts (ip, email, attempt, success, user_id)
  VALUES (p_ip, p_email_hash, p_attempt_type, p_success, p_user_id);
$$;

-- =============================================================================
-- 4) RPC: check_gate_lockout — gate questions lockout (3 fails = 5min block)
--     Returns JSON: { locked: bool, remaining_attempts: int, lockout_until: timestamptz|null }
-- =============================================================================
CREATE OR REPLACE FUNCTION public.check_gate_lockout(
  p_user_id       UUID,
  p_max_fails     INT  DEFAULT 3,
  p_lockout_secs  INT  DEFAULT 300
)
RETURNS JSONB
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'locked',
      -- locked if >= p_max_fails failures in the window
      (SELECT COUNT(*) FROM public.auth_attempts
       WHERE attempt = 'gate'
         AND user_id = p_user_id
         AND success = false
         AND created_at > now() - (p_lockout_secs || ' seconds')::interval
      ) >= p_max_fails,
    'remaining_attempts',
      GREATEST(0, p_max_fails - (
        SELECT COUNT(*) FROM public.auth_attempts
        WHERE attempt = 'gate'
          AND user_id = p_user_id
          AND success = false
          AND created_at > now() - (p_lockout_secs || ' seconds')::interval
      )),
    'lockout_until',
      CASE WHEN (
        SELECT COUNT(*) FROM public.auth_attempts
        WHERE attempt = 'gate'
          AND user_id = p_user_id
          AND success = false
          AND created_at > now() - (p_lockout_secs || ' seconds')::interval
      ) >= p_max_fails
      THEN (
        SELECT min(created_at) + (p_lockout_secs || ' seconds')::interval
        FROM public.auth_attempts
        WHERE attempt = 'gate'
          AND user_id = p_user_id
          AND success = false
          AND created_at > now() - (p_lockout_secs || ' seconds')::interval
      )
      ELSE NULL
      END
  );
$$;

-- =============================================================================
-- 5) Fix DELETE policies — remove permissive "Admin users can delete" policies
--    that override the superadmin-only ones (OR logic in RLS).
--    Applies to: articles, events, lives
-- =============================================================================

-- articles: drop the permissive admin DELETE policy
DROP POLICY IF EXISTS "Admin users can delete articles" ON public.articles;

-- events: drop the permissive admin DELETE policy
DROP POLICY IF EXISTS "Admin users can delete events" ON public.events;

-- lives: drop the permissive admin DELETE policy
DROP POLICY IF EXISTS "Admin users can delete lives" ON public.lives;

-- =============================================================================
-- 6) Fix UPDATE policies — add WITH CHECK to articles, events, lives
--    Currently UPDATE only has USING (qual), no WITH CHECK.
--    This allows admins to write any values including changing ownership.
-- =============================================================================

-- articles: replace UPDATE policy with one that has WITH CHECK
DROP POLICY IF EXISTS "Admin users can update articles" ON public.articles;
CREATE POLICY "Admin users can update articles"
  ON public.articles FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- events: replace UPDATE policy with one that has WITH CHECK
DROP POLICY IF EXISTS "Admin users can update events" ON public.events;
CREATE POLICY "Admin users can update events"
  ON public.events FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- lives: replace UPDATE policy with one that has WITH CHECK
DROP POLICY IF EXISTS "Admin users can update lives" ON public.lives;
CREATE POLICY "Admin users can update lives"
  ON public.lives FOR UPDATE
  TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));
