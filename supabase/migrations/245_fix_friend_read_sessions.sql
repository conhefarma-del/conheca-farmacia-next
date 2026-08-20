-- =====================================================================
-- 245 — Fix: friend_read_sessions policy
-- ---------------------------------------------------------------------
-- The previous policy only allowed users to read their own sessions,
-- which broke the lobby (couldn't see other players).
-- 
-- Fix: Allow reading all sessions in competitions created by the user.
-- =====================================================================

-- Drop the restrictive policy
DROP POLICY IF EXISTS friend_read_sessions ON public.competition_sessions;

-- Recreate with correct permissions:
-- 1. Users can read their own sessions
-- 2. Creators can read all sessions in their competitions
CREATE POLICY friend_read_sessions ON public.competition_sessions
  FOR SELECT TO authenticated
  USING (
    user_id = auth.uid()
    OR competition_id IN (
      SELECT id FROM public.competitions
      WHERE created_by_user_id = auth.uid()
    )
  );
