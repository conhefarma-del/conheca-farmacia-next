-- ============================================================
-- MIGRAÇÃO V2: Actualização da tabela inscricoes
-- Projecto: Conheça Farmácia
-- Data: 2026-04-25
-- Instruções: Colar e executar no SQL Editor do Supabase
-- URL: https://supabase.com/dashboard/project/tbqsazriorqzexjwhekw/editor
-- ============================================================


-- ============================================================
-- PASSO 1: Adicionar novas colunas (IF NOT EXISTS é seguro)
-- ============================================================

ALTER TABLE public.inscricoes
  ADD COLUMN IF NOT EXISTS genero TEXT,
  ADD COLUMN IF NOT EXISTS faixa_etaria TEXT,
  ADD COLUMN IF NOT EXISTS nivel_escolaridade TEXT;


-- ============================================================
-- PASSO 2: Preencher NULLs existentes antes de aplicar NOT NULL
-- (protecção para os 14 registos já existentes)
-- ============================================================

UPDATE public.inscricoes SET nome        = 'N/D'   WHERE nome        IS NULL;
UPDATE public.inscricoes SET email       = 'N/D'   WHERE email       IS NULL;
UPDATE public.inscricoes SET telefone    = 'N/D'   WHERE telefone    IS NULL;
UPDATE public.inscricoes SET profissao   = 'outro' WHERE profissao   IS NULL;
UPDATE public.inscricoes SET evento_slug = 'N/D'   WHERE evento_slug IS NULL;


-- ============================================================
-- PASSO 3: Aplicar constraints NOT NULL nas colunas obrigatórias
-- ============================================================

ALTER TABLE public.inscricoes
  ALTER COLUMN nome        SET NOT NULL,
  ALTER COLUMN email       SET NOT NULL,
  ALTER COLUMN telefone    SET NOT NULL,
  ALTER COLUMN profissao   SET NOT NULL,
  ALTER COLUMN evento_slug SET NOT NULL;


-- ============================================================
-- PASSO 4: Verificar resultado final
-- (deve mostrar todas as colunas com os tipos e nullable corretos)
-- ============================================================

SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name   = 'inscricoes'
  AND table_schema = 'public'
ORDER BY ordinal_position;
