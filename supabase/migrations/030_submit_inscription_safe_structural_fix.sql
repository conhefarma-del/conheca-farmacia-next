-- Migration 030: structural fix for submit_inscription_safe
--
-- The original 029 had two structural bugs in the RETURNS TABLE(id, code):
--   1. SELECT id INTO v_existing_id FROM inscricoes (and SELECT id INTO ...)
--      had a bare 'id' column reference that was ambiguous with the
--      output column 'id' declared in RETURNS TABLE.
--   2. RETURNING inscricoes.id INTO v_inserted_id followed by id := v_inserted_id
--      caused 22P02 ("invalid input syntax for type uuid: '67'") because
--      PL/pgSQL interpreted the bare 'id' as a sequence value when
--      assigning to the output column.
--
-- Fix: refactor the function to return only TEXT (the code). The caller
-- does a separate SELECT on the new row to get the id. This eliminates
-- the RETURNS TABLE ambiguity entirely while keeping the same external
-- behavior for the caller.
--
-- Applied via execute_sql (not apply_migration) because the apply_migration
-- MCP tool was not propagating the function body changes. Verified working:
--   SELECT submit_inscription_safe(<event_id>, 'test@x.com', '{}'::jsonb);
--   returns 'ok' on success, 'event_not_found'|'event_full'|'duplicate' on validation.

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
  );

  RETURN 'ok';
END;
$$;

REVOKE ALL ON FUNCTION public.submit_inscription_safe(UUID, TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_inscription_safe(UUID, TEXT, JSONB) TO service_role;
