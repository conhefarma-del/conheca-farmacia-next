-- 252: Pull quotes atribuíveis a um entrevistado
--
-- Antes: pull_quotes TEXT[] (só o texto) — a página pública atribuía
-- sempre a citação ao primeiro entrevistado (interviewees[0]).
-- Depois: pull_quotes JSONB — [{ "text": "...", "person": "Nome" }|null]
-- onde `person` é o nome do entrevistado (mesmo formato inline do JSONB
-- `interviewee`), null = atribuição automática (fallback ao 1.º).
-- Estratégia: coluna nova → backfill → drop/rename (ALTER USING com
-- subquery é frágil entre versões).
-- Idempotente: condicional a information_schema.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'interviews'
      AND data_type = 'jsonb'
      AND column_name = 'pull_quotes'
  ) THEN
    -- 1. Coluna JSONB nova
    ALTER TABLE public.interviews
      ADD COLUMN pull_quotes_new JSONB DEFAULT '[]'::jsonb;

    -- 2. Backfill: cada string → { text, person: null }
    UPDATE public.interviews
    SET pull_quotes_new = COALESCE((
      SELECT jsonb_agg(
               jsonb_build_object('text', elem, 'person', NULL)
               ORDER BY ord
             )
      FROM jsonb_array_elements_text(to_jsonb(pull_quotes))
           WITH ORDINALITY AS t(elem, ord)
    ), '[]'::jsonb)
    WHERE pull_quotes IS NOT NULL
      AND array_length(pull_quotes, 1) > 0;

    -- 3. Swap
    ALTER TABLE public.interviews DROP COLUMN pull_quotes;
    ALTER TABLE public.interviews RENAME COLUMN pull_quotes_new TO pull_quotes;
  END IF;
END $$;
