-- 037: consentimento de menor de idade na inscrição
--
-- 1. Nova coluna para registar o consentimento do responsável legal
--    quando o participante é menor de 18 anos (faixa_etaria = 'menor-18').
--    Evidência de consentimento (audit) conforme secção 2.1 da Política
--    de Privacidade e princípio da licitude da Lei 22/11.
-- 2. Recria submit_inscription_safe (mesma assinatura) para persistir
--    menor_consentimento e rejeitar inscrições de menores sem consentimento
--    (defesa em profundidade — a função só é alcançável via service_role,
--    por isso a validação principal fica no Zod da Server Action).

ALTER TABLE public.inscricoes
  ADD COLUMN IF NOT EXISTS menor_consentimento boolean NOT NULL DEFAULT false;

DROP FUNCTION IF EXISTS public.submit_inscription_safe(UUID, TEXT, JSONB);

CREATE FUNCTION public.submit_inscription_safe(
  p_evento_id UUID,
  p_email TEXT,
  p_form JSONB
)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_capacity INT;
  v_current_count INT;
  v_lower_email TEXT;
BEGIN
  v_lower_email := lower(trim(p_email));

  IF p_evento_id IS NULL OR v_lower_email IS NULL OR length(v_lower_email) = 0 THEN
    RETURN 'invalid_input';
  END IF;

  -- Menor sem consentimento do responsável legal → rejeita
  IF p_form->>'faixa_etaria' = 'menor-18'
     AND COALESCE((p_form->>'menor_consentimento')::boolean, false) = false THEN
    RETURN 'invalid_input';
  END IF;

  SELECT events.capacity INTO v_capacity
  FROM events
  WHERE events.id = p_evento_id
    AND events.status = 'published'
    AND events.is_archived = false
  FOR UPDATE;

  IF v_capacity IS NULL THEN
    RETURN 'event_not_found';
  END IF;

  SELECT count(*) INTO v_current_count
  FROM inscricoes
  WHERE inscricoes.evento_id = p_evento_id;

  IF v_current_count >= v_capacity THEN
    RETURN 'event_full';
  END IF;

  IF EXISTS (
    SELECT 1 FROM inscricoes
    WHERE inscricoes.evento_id = p_evento_id
      AND lower(inscricoes.email) = v_lower_email
  ) THEN
    RETURN 'duplicate';
  END IF;

  INSERT INTO inscricoes (
    nome, email, telefone, profissao, genero, faixa_etaria,
    nivel_escolaridade, menor_consentimento, origem_evento, evento_id, evento_slug,
    created_at
  ) VALUES (
    p_form->>'nome',
    v_lower_email,
    p_form->>'telefone',
    p_form->>'profissao',
    NULLIF(p_form->>'genero', ''),
    NULLIF(p_form->>'faixa_etaria', ''),
    NULLIF(p_form->>'nivel_escolaridade', ''),
    COALESCE((p_form->>'menor_consentimento')::boolean, false),
    NULLIF(p_form->>'origem_evento', ''),
    p_evento_id,
    NULLIF(p_form->>'evento_slug', ''),
    now()
  );

  RETURN 'ok';
END;
$$;

REVOKE ALL ON FUNCTION public.submit_inscription_safe(UUID, TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_inscription_safe(UUID, TEXT, JSONB) TO service_role;
