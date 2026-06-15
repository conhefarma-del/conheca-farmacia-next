-- Migration 019: Atomic translation rate limit (CRIT-01)
-- Replaces the SELECT-then-INSERT pattern in lib/actions/translation.js that
-- had a TOCTOU race window between the read of `translation_logs` and the
-- append of the new row. Under concurrent translations, two requests could
-- each read `used < DAILY_CHAR_LIMIT`, both insert, and the actual daily
-- spend could exceed the limit.
--
-- Pattern: maintain a single row per UTC day in a small `translation_quota`
-- table. Increment is done in a single statement
-- (INSERT ... ON CONFLICT ... DO UPDATE) and returns a boolean indicating
-- whether the new total is still under the limit. Because the row-level
-- write is serialized by Postgres, no two callers can both pass the check.

-- ============================================================================
-- 1. Quota table — one row per UTC day
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.translation_quota (
  usage_date    DATE        PRIMARY KEY,
  chars_used    BIGINT      NOT NULL DEFAULT 0,
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 2. Atomic check-and-increment RPC
-- ============================================================================
-- Returns TRUE if p_chars were added and the running total for the day is
-- below the supplied p_limit. Returns FALSE if the resulting total would
-- exceed the limit (in which case no increment is applied).
--
-- The function is SECURITY DEFINER because the underlying table is admin-only
-- and the call site is the server action (which already requires admin).
-- search_path is pinned to avoid the SECURITY DEFINER search_path trap.
CREATE OR REPLACE FUNCTION public.check_and_increment_translation_quota(
  p_chars  INTEGER,
  p_limit  BIGINT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_today      DATE := (NOW() AT TIME ZONE 'UTC')::DATE;
  v_new_total  BIGINT;
BEGIN
  IF p_chars <= 0 THEN
    RETURN TRUE;
  END IF;

  -- Upsert the day's row, then read back the post-update total atomically.
  -- INSERT ... ON CONFLICT ... DO UPDATE acquires a row-level write lock
  -- for the duration of the statement, so concurrent callers serialize here.
  INSERT INTO public.translation_quota (usage_date, chars_used, updated_at)
    VALUES (v_today, p_chars, NOW())
    ON CONFLICT (usage_date) DO UPDATE
      SET chars_used = public.translation_quota.chars_used + EXCLUDED.chars_used,
          updated_at = NOW()
    RETURNING chars_used INTO v_new_total;

  IF v_new_total > p_limit THEN
    -- Roll back the increment we just performed so the running total
    -- reflects the actual successful spend, not rejected attempts.
    UPDATE public.translation_quota
      SET chars_used = chars_used - p_chars, updated_at = NOW()
      WHERE usage_date = v_today;
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END;
$$;

REVOKE ALL ON FUNCTION public.check_and_increment_translation_quota(INTEGER, BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_and_increment_translation_quota(INTEGER, BIGINT) TO service_role;

-- ============================================================================
-- 3. RLS on the quota table — admins only via service_role RPC
-- ============================================================================
ALTER TABLE public.translation_quota ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin_read_translation_quota" ON public.translation_quota;
CREATE POLICY "admin_read_translation_quota" ON public.translation_quota
  FOR SELECT TO authenticated
  USING (is_current_user_admin());

-- Direct INSERT/UPDATE from the client is not allowed: the only writer is
-- the SECURITY DEFINER RPC above, which runs as the function owner.
DROP POLICY IF EXISTS "no_direct_write_translation_quota" ON public.translation_quota;
CREATE POLICY "no_direct_write_translation_quota" ON public.translation_quota
  FOR ALL TO authenticated
  USING (FALSE)
  WITH CHECK (FALSE);
