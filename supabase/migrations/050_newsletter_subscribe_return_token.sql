-- Migration 050: subscribe_newsletter devolve unsubscribe_token (corrige #9)
--
-- Contexto (auditoria "O Sentinela" #9):
--   sendWelcomeEmail() lia the newsletter via SELECT anon — mas a tabela tem
--   RLS bloqueado para anon, logo o SELECT devolvia 0 linhas e o email de
--   boas-vindas nunca era enviado ("Subscritor não encontrado").
--
--   Correção: a RPC subscribe_newsletter (SECURITY DEFINER, por isso fora do
--   alcance do RLS) passa a DEVOLVER o unsubscribe_token no JSON de sucesso.
--   O client NewsletterSection.jsx envia esse token ao sendWelcomeEmail, que
--   deixa de precisar de ler a tabela anonimamente.
--
--   É seguro devolver o token ao caller: este acabou de subscrever esse email,
--   é o token da própria subscrição e já vai no próprio email de boas-vindas.
--
--   Mantém o contrato anterior ({success, message}) e o hardening (search_path
--   fixo, RAISE com 'already' para duplicado/reativação). Supersede a definição
--   da migration 047 para esta função (idempotente: CREATE OR REPLACE).

CREATE OR REPLACE FUNCTION public.subscribe_newsletter(p_email text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_email     TEXT;
  v_existing  RECORD;
  v_token     uuid;
BEGIN
  v_email := lower(trim(p_email));
  IF v_email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR length(v_email) > 254 THEN
    RAISE EXCEPTION 'Email inválido.';
  END IF;

  SELECT id, status, unsubscribe_token INTO v_existing
  FROM public.newsletter
  WHERE email = v_email
  LIMIT 1;

  IF FOUND THEN
    IF v_existing.status = 'active' THEN
      RAISE EXCEPTION 'Este email já está subscrito (already subscribed).';
    END IF;
    UPDATE public.newsletter SET status = 'active', updated_at = NOW() WHERE id = v_existing.id;
    RETURN jsonb_build_object(
      'success', true,
      'message', 'Subscrição reativada com sucesso!',
      'unsubscribe_token', v_existing.unsubscribe_token
    );
  END IF;

  INSERT INTO public.newsletter (email) VALUES (v_email)
  RETURNING unsubscribe_token INTO v_token;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Subscrição realizada com sucesso!',
    'unsubscribe_token', v_token
  );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.subscribe_newsletter(text) TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.subscribe_newsletter(text)
  IS 'Subscrição pública. SECURITY DEFINER com search_path fixo. Devolve unsubscribe_token no sucesso (migration 050) para alimentar sendWelcomeEmail sem ler newsletter como anon.';