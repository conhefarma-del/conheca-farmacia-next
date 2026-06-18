-- Migration 029: atomic submission via SECURITY DEFINER RPC
-- Replaces the Edge Function's separate SELECT+COUNT+SELECT+INSERT pattern,
-- which is racy under concurrent submissions (duplicate + overbooking).

-- 1) UNIQUE constraint to backstop the RPC
CREATE UNIQUE INDEX IF NOT EXISTS inscricoes_evento_id_lower_email_key
  ON public.inscricoes (evento_id, lower(email))
  WHERE email IS NOT NULL;

-- 2) Atomic submit RPC
CREATE OR REPLACE FUNCTION public.submit_inscription_safe(
  p_evento_id UUID,
  p_email TEXT,
  p_form JSONB
)
RETURNS TABLE(id UUID, code TEXT)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_capacity INT;
  v_current_count INT;
  v_existing_id UUID;
  v_inserted_id UUID;
  v_lower_email TEXT;
BEGIN
  v_lower_email := lower(trim(p_email));

  -- Lock the event row to serialize capacity checks
  SELECT capacity INTO v_capacity
  FROM events
  WHERE id = p_evento_id
    AND status = 'published'
    AND is_archived = false
  FOR UPDATE;

  IF v_capacity IS NULL THEN
    id := NULL; code := 'event_not_found';
    RETURN NEXT; RETURN;
  END IF;

  SELECT count(*) INTO v_current_count
  FROM inscricoes
  WHERE evento_id = p_evento_id;

  IF v_current_count >= v_capacity THEN
    id := NULL; code := 'event_full';
    RETURN NEXT; RETURN;
  END IF;

  SELECT id INTO v_existing_id
  FROM inscricoes
  WHERE evento_id = p_evento_id
    AND lower(email) = v_lower_email
  LIMIT 1;

  IF v_existing_id IS NOT NULL THEN
    id := NULL; code := 'duplicate';
    RETURN NEXT; RETURN;
  END IF;

  INSERT INTO inscricoes (
    nome, email, telefone, profissao, genero, faixa_etaria,
    nivel_escolaridade, origem_evento, evento_id, evento_slug,
    created_at
  ) VALUES (
    p_form->>'nome',
    v_lower_email,
    p_form->>'telefone',
    p_form->>'profissao',
    NULLIF(p_form->>'genero', ''),
    NULLIF(p_form->>'faixa_etaria', ''),
    NULLIF(p_form->>'nivel_escolaridade', ''),
    NULLIF(p_form->>'origem_evento', ''),
    p_evento_id,
    NULLIF(p_form->>'evento_slug', ''),
    now()
  )
  RETURNING id INTO v_inserted_id;

  id := v_inserted_id; code := 'ok';
  RETURN NEXT;
END;
$$;

-- Service role can call; anon cannot (no GRANT to anon role).
REVOKE ALL ON FUNCTION public.submit_inscription_safe(UUID, TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_inscription_safe(UUID, TEXT, JSONB) TO service_role;