-- =====================================================================
-- 234 — Quiz Competição: sessões, competições e leaderboard
-- ---------------------------------------------------------------------
-- Tabelas competitions e competition_sessions para o sistema de
-- competições inter-escolas. View competition_leaderboard para
-- ranking por competição.
-- =====================================================================

-- =====================================================================
-- 1. Competições (criadas pelo admin)
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.competitions (
  id                UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug              TEXT NOT NULL UNIQUE,
  name              TEXT NOT NULL,
  access_code       TEXT NOT NULL UNIQUE,     -- ex: 'CF-2026'
  description       TEXT NOT NULL DEFAULT '',
  -- Configuração
  question_types    TEXT[] NOT NULL DEFAULT '{pharmacology,interaction,flashcard,protocol,drug_class}',
  questions_count   INTEGER NOT NULL DEFAULT 10,
  time_per_question INTEGER NOT NULL DEFAULT 30,  -- segundos
  streak_bonus      BOOLEAN NOT NULL DEFAULT true,
  -- Escolas convidadas
  school_ids        UUID[] NOT NULL DEFAULT '{}',
  -- Estado
  status            TEXT NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','lobby','active','ended','cancelled')),
  started_at        TIMESTAMPTZ,
  ended_at          TIMESTAMPTZ,
  -- Timestamps
  created_by        UUID REFERENCES auth.users(id),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_competitions_status ON public.competitions(status);
CREATE INDEX IF NOT EXISTS idx_competitions_code ON public.competitions(access_code);
CREATE INDEX IF NOT EXISTS idx_competitions_slug ON public.competitions(slug);

-- =====================================================================
-- 2. Sessões de competição (um registo por aluno numa competição)
-- =====================================================================
CREATE TABLE IF NOT EXISTS public.competition_sessions (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  competition_id  UUID NOT NULL REFERENCES public.competitions(id) ON DELETE CASCADE,
  -- Identidade
  session_id      TEXT NOT NULL,            -- ID anónimo (gerado pelo servidor)
  user_id         UUID REFERENCES auth.users(id),  -- NULL = sem conta
  student_name    TEXT NOT NULL,
  -- Escola / turma
  school_id       UUID REFERENCES public.schools(id),
  class_id        UUID REFERENCES public.classes(id),
  -- Pontuação
  total_score     INTEGER NOT NULL DEFAULT 0,
  correct_count   INTEGER NOT NULL DEFAULT 0,
  total_answered  INTEGER NOT NULL DEFAULT 0,
  max_streak      INTEGER NOT NULL DEFAULT 0,
  current_streak  INTEGER NOT NULL DEFAULT 0,
  -- Detalhes
  answers         JSONB NOT NULL DEFAULT '[]',  -- [{qIdx, correct, points, streak_at}]
  finished_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Um aluno só participa uma vez por competição
  UNIQUE (competition_id, session_id)
);

CREATE INDEX IF NOT EXISTS idx_comp_sessions_comp ON public.competition_sessions(competition_id, total_score DESC);
CREATE INDEX IF NOT EXISTS idx_comp_sessions_school ON public.competition_sessions(school_id, total_score DESC);
CREATE INDEX IF NOT EXISTS idx_comp_sessions_class ON public.competition_sessions(class_id, total_score DESC);
CREATE INDEX IF NOT EXISTS idx_comp_sessions_user ON public.competition_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_comp_sessions_session ON public.competition_sessions(session_id);

-- =====================================================================
-- 3. RLS
-- =====================================================================
ALTER TABLE public.competitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competition_sessions ENABLE ROW LEVEL SECURITY;

-- Admin: tudo em competições
CREATE POLICY admin_all_competitions ON public.competitions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: ler competições ativas/lobby (para o formulário de entrada)
CREATE POLICY anon_read_competitions ON public.competitions
  FOR SELECT TO anon, authenticated
  USING (status IN ('lobby','active'));

-- Admin: tudo em sessões
CREATE POLICY admin_all_sessions ON public.competition_sessions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: ler sessões (para leaderboard público)
CREATE POLICY anon_read_sessions ON public.competition_sessions
  FOR SELECT TO anon, authenticated
  USING (true);

-- Anon: inserir sessão (para entrada sem conta)
CREATE POLICY anon_insert_session ON public.competition_sessions
  FOR INSERT TO anon, authenticated
  WITH CHECK (true);

-- Auth: atualizar a sua própria sessão (por session_id ou user_id)
CREATE POLICY own_session_update ON public.competition_sessions
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Anon: atualizar sessão por session_id (via header x-session-id)
CREATE POLICY anon_session_update ON public.competition_sessions
  FOR UPDATE TO anon
  USING (true)
  WITH CHECK (true);

-- =====================================================================
-- 4. View: leaderboard por competição (top N)
-- =====================================================================
CREATE OR REPLACE VIEW public.competition_leaderboard AS
SELECT
  cs.id,
  cs.competition_id,
  cs.student_name,
  cs.total_score,
  cs.correct_count,
  cs.total_answered,
  cs.max_streak,
  cs.school_id,
  s.name AS school_name,
  cs.class_id,
  c.name AS class_name,
  cs.finished_at,
  cs.created_at,
  RANK() OVER (
    PARTITION BY cs.competition_id
    ORDER BY cs.total_score DESC, cs.correct_count DESC, cs.created_at ASC
  ) AS position
FROM public.competition_sessions cs
LEFT JOIN public.schools s ON s.id = cs.school_id
LEFT JOIN public.classes c ON c.id = cs.class_id
WHERE cs.total_answered > 0;

-- =====================================================================
-- FIM — 234: competitions + sessions + leaderboard
-- =====================================================================
