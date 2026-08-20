-- =====================================================================
-- 235 — Quiz Competição: armazenar perguntas na sessão
-- =====================================================================

-- Adicionar coluna questions para armazenar as perguntas geradas
-- (com correctIndex para validação server-side)
ALTER TABLE public.competition_sessions
  ADD COLUMN IF NOT EXISTS questions JSONB NOT NULL DEFAULT '[]';
