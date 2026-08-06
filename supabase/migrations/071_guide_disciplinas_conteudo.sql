-- 071: Study guides — novos campos de conteúdo por disciplina
-- Adiciona conteúdo explicativo facultativo e bilingue a guide_disciplines:
--   practice_*  → "No dia a dia do profissional" (disciplinas-chave)
--   learning_*  → "Importância durante a formação" (todas as disciplinas)
-- Ambos são opcionais (default ''): a UI só renderiza blocos quando há texto.

ALTER TABLE public.guide_disciplines
  ADD COLUMN IF NOT EXISTS practice_pt TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS practice_en TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS learning_pt TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS learning_en TEXT NOT NULL DEFAULT '';
