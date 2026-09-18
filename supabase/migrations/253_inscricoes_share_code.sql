-- 253: share_code em inscricoes — gate de acesso para o PDF do comprovativo
--
-- O PDF do comprovativo contém PII (nome, email). O id da inscrição é
-- sequencial e previsível (000123…), por isso o endpoint do PDF exige
-- id + share_code (secreto, aleatório). O link completo vive na página
-- de sucesso e no modal admin.
-- Idempotente: condicional a information_schema.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'inscricoes'
      AND column_name = 'share_code'
  ) THEN
    ALTER TABLE public.inscricoes
      ADD COLUMN share_code TEXT NOT NULL DEFAULT encode(gen_random_bytes(16), 'hex');
  END IF;
END $$;

-- Backfill de linhas pré-253 que possam ter ficado com null/vazio
-- (defensivo: o DEFAULT já cobre inserts novos, inclusive via RPC 029).
UPDATE public.inscricoes
SET share_code = encode(gen_random_bytes(16), 'hex')
WHERE share_code IS NULL OR share_code = '';

-- Unicidade (defesa; colisões de 128 bits são improváveis)
CREATE UNIQUE INDEX IF NOT EXISTS inscricoes_share_code_key
  ON public.inscricoes (share_code);
