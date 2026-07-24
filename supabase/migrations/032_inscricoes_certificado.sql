-- 032: certificado de participação — token público + flag de participação
-- O certificado_token é UUID público, SEPARADO do shortRef (int8) do comprovativo.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE public.inscricoes
  ADD COLUMN IF NOT EXISTS certificado_token uuid UNIQUE DEFAULT gen_random_uuid(),
  ADD COLUMN IF NOT EXISTS compareceu boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS certificado_emitido_at timestamptz,
  ADD COLUMN IF NOT EXISTS certificado_emitido_por uuid;

CREATE INDEX IF NOT EXISTS inscricoes_certificado_token_idx
  ON public.inscricoes (certificado_token);
