-- =====================================================================
-- 159 — Quiz: tentativas (histórico)
-- ---------------------------------------------------------------------
-- Plano 2026-08-13-quiz. Só o histórico de tentativas é guardado; as
-- perguntas são montadas em tempo real a partir dos dados existentes
-- (flashcards, drug_pharmacology, interações, clinical_protocol_quizzes),
-- por isso não há tabela de perguntas. user_id NULL = modo "sem registo"
-- (não insere — o campo serve para futuras tentativas efémeras/análises).
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.quiz_attempts (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,  -- NULL = efémero
  mode            TEXT NOT NULL,          -- 'deck' | 'tipo' | 'rapido'
  deck_id         UUID REFERENCES public.flashcard_decks(id) ON DELETE SET NULL,
  question_source TEXT NOT NULL DEFAULT 'mixed',  -- 'flashcard'|'pharmacology'|'interaction'|'protocol'|'mixed'
  total           INTEGER NOT NULL DEFAULT 0,
  correct         INTEGER NOT NULL DEFAULT 0,
  details         JSONB NOT NULL DEFAULT '[]',  -- [{key, correct}] p/ análise futura
  started_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  finished_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- RLS (padrão do projeto)
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Cada utilizador vê/altera apenas as suas tentativas
CREATE POLICY "own_quiz_attempts_select" ON public.quiz_attempts
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "own_quiz_attempts_insert" ON public.quiz_attempts
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "own_quiz_attempts_update" ON public.quiz_attempts
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "own_quiz_attempts_delete" ON public.quiz_attempts
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Admin: tudo (padrão admin_users)
CREATE POLICY "admin_all_quiz_attempts" ON public.quiz_attempts
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- Índices
CREATE INDEX idx_quiz_attempts_user ON public.quiz_attempts(user_id, created_at DESC);
CREATE INDEX idx_quiz_attempts_source ON public.quiz_attempts(question_source, created_at DESC);

-- =====================================================================
-- FIM — 159: quiz_attempts
-- =====================================================================
