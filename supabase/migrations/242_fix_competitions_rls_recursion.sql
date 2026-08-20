-- =====================================================================
-- 242 — Fix: infinite recursion in competitions RLS policies
-- ---------------------------------------------------------------------
-- The friend_read_own_competitions policy on competitions checks
-- competition_sessions, and friend_read_sessions on competition_sessions
-- checks competitions — creating a circular reference.
-- 
-- Solution: Simplify policies to avoid circular dependency.
-- =====================================================================

-- Drop the problematic policies
DROP POLICY IF EXISTS friend_read_own_competitions ON public.competitions;
DROP POLICY IF EXISTS friend_read_sessions ON public.competition_sessions;

-- Recreate friend_read_own_competitions without subquery to competition_sessions
CREATE POLICY friend_read_own_competitions ON public.competitions
  FOR SELECT TO authenticated
  USING (
    is_friend_challenge = true
    AND created_by_user_id = auth.uid()
  );

-- Recreate friend_read_sessions without subquery to competitions
CREATE POLICY friend_read_sessions ON public.competition_sessions
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
  );
