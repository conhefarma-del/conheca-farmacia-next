-- =====================================================================
-- 237 — Desafio entre Amigos: tabela de convites
-- ---------------------------------------------------------------------
-- competition_invites: regista convites entre utilizadores para
-- competições amigáveis. Suporta convite por código (invitee_user_id
-- NULL) ou por pesquisa direta (invitee_user_id preenchido).
-- =====================================================================

-- =====================================================================
-- 1. Tabela
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.competition_invites (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  competition_id  UUID NOT NULL REFERENCES public.competitions(id) ON DELETE CASCADE,
  inviter_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invitee_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,  -- NULL = por código
  invite_code     TEXT NOT NULL,    -- código de acesso da competição
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  responded_at    TIMESTAMPTZ,
  -- Um convite por amigo por competição
  UNIQUE (competition_id, invitee_user_id)
);

-- =====================================================================
-- 2. RLS
-- =====================================================================
ALTER TABLE public.competition_invites ENABLE ROW LEVEL SECURITY;

-- Inviter: ler os seus convites enviados
CREATE POLICY inviter_read_invites ON public.competition_invites
  FOR SELECT TO authenticated
  USING (inviter_user_id = auth.uid());

-- Invitee: ler convites recebidos (onde sou o convidado)
CREATE POLICY invitee_read_invites ON public.competition_invites
  FOR SELECT TO authenticated
  USING (invitee_user_id = auth.uid());

-- Inviter: inserir convite (só para competições que criou)
CREATE POLICY inviter_insert_invite ON public.competition_invites
  FOR INSERT TO authenticated
  WITH CHECK (
    inviter_user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.competitions comp
      WHERE comp.id = competition_id
        AND comp.is_friend_challenge = true
        AND comp.created_by_user_id = auth.uid()
    )
  );

-- Invitee: atualizar convite (aceitar/rejeitar) — só o convidado
CREATE POLICY invitee_update_invite ON public.competition_invites
  FOR UPDATE TO authenticated
  USING (invitee_user_id = auth.uid())
  WITH CHECK (invitee_user_id = auth.uid());

-- Inviter: eliminar convite pendente (cancelar convite)
CREATE POLICY inviter_delete_invite ON public.competition_invites
  FOR DELETE TO authenticated
  USING (inviter_user_id = auth.uid() AND status = 'pending');

-- Admin: tudo
CREATE POLICY admin_all_invites ON public.competition_invites
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- =====================================================================
-- 3. Índices
-- =====================================================================
CREATE INDEX IF NOT EXISTS idx_invites_competition ON public.competition_invites(competition_id);
CREATE INDEX IF NOT EXISTS idx_invites_invitee ON public.competition_invites(invitee_user_id, status);
CREATE INDEX IF NOT EXISTS idx_invites_inviter ON public.competition_invites(inviter_user_id, status);
CREATE INDEX IF NOT EXISTS idx_invites_code ON public.competition_invites(invite_code);

-- =====================================================================
-- FIM — 237: competition_invites
-- =====================================================================
