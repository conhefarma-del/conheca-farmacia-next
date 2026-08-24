-- =====================================================================
-- 246 — Fix: friend challenge creator can update all competition sessions
-- ---------------------------------------------------------------------
-- BUG REPORTED: In /competicao/amigos only the creator (inviter) enters
-- the game — the invited user stays stuck in the lobby and never reads
-- the session questions.
--
-- ROOT CAUSE: when the creator starts the quiz, startFriendQuiz() (which
-- runs under the CREATOR'S authenticated context) writes `questions` and
-- `started_at` to EVERY player's competition_sessions row, then flips
-- the competition status to 'active'. The only UPDATE policies on
-- competition_sessions were:
--   - own_session_update      (user_id = auth.uid())  -> 234
--   - anon_session_update     (anon role)             -> 234
--   - admin_all_sessions      (admin)                 -> 234
-- There was NO policy letting the creator update the INVITED player's
-- session row. RLS therefore silently filtered that UPDATE out
-- (0 rows affected, no error thrown). Result:
--   - the creator's own session received questions  -> creator enters quiz
--   - the invited player's session kept questions='[]'
-- The invited player's lobby poll only transitions to the quiz when
-- their session.questions is non-empty, so the invited player stayed in
-- the lobby forever.
--
-- FIX: add an UPDATE policy that lets the creator of a friend-challenge
-- competition update any session belonging to that competition (needed
-- to write the generated questions + started_at at quiz start).
-- =====================================================================
DROP POLICY IF EXISTS friend_update_sessions_by_creator ON public.competition_sessions;

CREATE POLICY friend_update_sessions_by_creator ON public.competition_sessions
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.competitions comp
      WHERE comp.id = competition_sessions.competition_id
        AND comp.is_friend_challenge = true
        AND comp.created_by_user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.competitions comp
      WHERE comp.id = competition_sessions.competition_id
        AND comp.is_friend_challenge = true
        AND comp.created_by_user_id = auth.uid()
    )
  );

-- =====================================================================
-- FIM — 246: desbloquear update das sessões dos convidados pelo criador
-- =====================================================================
