-- =====================================================================
-- 236 — Desafio entre Amigos: campos novos em competitions + sessions
-- ---------------------------------------------------------------------
-- Adiciona suporte a competições síncronas 2-4 jogadores entre amigos
-- com conta no website. Campos: is_friend_challenge, max_players,
-- lobby_timeout, is_ready, started_at.
-- =====================================================================

-- =====================================================================
-- 1. Competitions — campos novos
-- =====================================================================
ALTER TABLE public.competitions
  ADD COLUMN IF NOT EXISTS is_friend_challenge  BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS created_by_user_id   UUID REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS max_players          INTEGER NOT NULL DEFAULT 4
    CHECK (max_players >= 2 AND max_players <= 4),
  ADD COLUMN IF NOT EXISTS lobby_timeout_seconds INTEGER NOT NULL DEFAULT 120;

-- Índice para query "minhas competições de amigos"
CREATE INDEX IF NOT EXISTS idx_competitions_friend
  ON public.competitions(created_by_user_id, status)
  WHERE is_friend_challenge = true;

-- =====================================================================
-- 2. Competition sessions — campos novos
-- =====================================================================
ALTER TABLE public.competition_sessions
  ADD COLUMN IF NOT EXISTS is_ready   BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ;

-- =====================================================================
-- 3. RLS — competições de amigos
-- =====================================================================

-- Utilizador autenticado: ler competições de amigos onde é participant
-- (a sessionliga o user à competição)
CREATE POLICY friend_read_own_competitions ON public.competitions
  FOR SELECT TO authenticated
  USING (
    is_friend_challenge = true
    AND (
      created_by_user_id = auth.uid()
      OR EXISTS (
        SELECT 1 FROM public.competition_sessions cs
        WHERE cs.competition_id = competitions.id
          AND cs.user_id = auth.uid()
      )
    )
  );

-- Utilizador autenticado: criar competição de amigos (só com conta)
CREATE POLICY friend_insert_competition ON public.competitions
  FOR INSERT TO authenticated
  WITH CHECK (
    is_friend_challenge = true
    AND created_by_user_id = auth.uid()
  );

-- Utilizador autenticado: atualizar competição de amigos (só o criador)
CREATE POLICY friend_update_own_competition ON public.competitions
  FOR UPDATE TO authenticated
  USING (
    is_friend_challenge = true
    AND created_by_user_id = auth.uid()
  )
  WITH CHECK (
    is_friend_challenge = true
    AND created_by_user_id = auth.uid()
  );

-- =====================================================================
-- 4. RLS — sessões de amigos
-- =====================================================================

-- Auth: ler sessões de competições de amigos onde participo ou sou owner
CREATE POLICY friend_read_sessions ON public.competition_sessions
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.competitions comp
      WHERE comp.id = competition_sessions.competition_id
        AND comp.is_friend_challenge = true
        AND (
          comp.created_by_user_id = auth.uid()
          OR competition_sessions.user_id = auth.uid()
        )
    )
  );

-- Auth: inserir sessão em competição de amigos (só com conta)
CREATE POLICY friend_insert_session ON public.competition_sessions
  FOR INSERT TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.competitions comp
      WHERE comp.id = competition_id
        AND comp.is_friend_challenge = true
    )
  );

-- =====================================================================
-- FIM — 236: desafio entre amigos (schema)
-- =====================================================================
