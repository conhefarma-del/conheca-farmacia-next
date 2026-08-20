-- =====================================================================
-- 244 — Fix: competition sessions uniqueness and join logic
-- ---------------------------------------------------------------------
-- 1. Add UNIQUE constraint on (competition_id, user_id) to prevent
--    duplicate sessions for the same user in the same competition.
-- 2. Clean up existing duplicates (keep only the first session per user).
-- =====================================================================

-- Step 1: Remove duplicate sessions (keep only the first one per user per competition)
WITH duplicates AS (
  SELECT id, 
    ROW_NUMBER() OVER (
      PARTITION BY competition_id, user_id 
      ORDER BY created_at ASC
    ) as rn
  FROM public.competition_sessions
  WHERE user_id IS NOT NULL
)
DELETE FROM public.competition_sessions
WHERE id IN (
  SELECT id FROM duplicates WHERE rn > 1
);

-- Step 2: Add UNIQUE constraint on (competition_id, user_id)
-- Only for non-null user_id (logged-in users)
CREATE UNIQUE INDEX IF NOT EXISTS idx_competition_sessions_unique_user
  ON public.competition_sessions(competition_id, user_id)
  WHERE user_id IS NOT NULL;
