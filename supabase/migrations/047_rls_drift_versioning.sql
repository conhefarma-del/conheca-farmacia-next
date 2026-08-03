-- Migration 047: versionar RLS "à deriva" — newsletter (tabela + policies + RPCs)
--
-- Contexto (auditoria "O Sentinela" #2):
--   A tabela newsletter, as suas policies e as funções
--   subscribe_newsletter/unsubscribe_newsletter foram criadas fora das
--   migrations (dashboard) e não estavam versionadas. Esta migration espelha
--   o estado atual da DB e aplica o hardening padrão:
--
--   1. CREATE TABLE IF NOT EXISTS com o esquema exato em produção
--      (inclui CHECK de status com 'bounced' e default uuid_generate_v4()).
--   2. Policies recriadas de forma idêntica às atuais; as de admin passam a
--      usar is_current_user_admin() (lógica igual ao EXISTS original, e a
--      função ganhou SET search_path na migration 046).
--   3. RPCs com SET search_path = public (SECURITY DEFINER sem search_path
--      fixo = mesmo risco de namespace hijacking que a 046 corrigiu).
--   4. subscribe_newsletter: contrato CORRIGIDO. A versão anterior devolvia
--      {success:false, error:'...'} como data para duplicados/email inválido;
--      o client só lê error da chamada supabase.rpc, por isso um duplicado
--      era mostrado como "sucesso" e disparava email de boas-vindas. Agora
--      duplicado/inválido lançam RAISE EXCEPTION (o client mapeia
--      error.message que contenha 'already' para o estado 'exists'). O resto
--      (validação, reativação de unsubscribed/bounced, token gerado no
--      default) mantém-se exatamente igual.
--
-- Idempotente e aditivo.

-- 0) Extensão usada no default de unsubscribe_token
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1) Tabela (espelho do estado atual)
CREATE TABLE IF NOT EXISTS public.newsletter (
  id                uuid                     NOT NULL DEFAULT gen_random_uuid(),
  email             text                     NOT NULL,
  nome              text,
  data_inscricao    timestamp with time zone          DEFAULT now(),
  status            text                             DEFAULT 'active'::text,
  created_at        timestamp with time zone          DEFAULT now(),
  updated_at        timestamp with time zone          DEFAULT now(),
  unsubscribe_token uuid                             DEFAULT uuid_generate_v4(),
  CONSTRAINT newsletter_pkey PRIMARY KEY (id),
  CONSTRAINT newsletter_email_key UNIQUE (email),
  CONSTRAINT newsletter_status_check
    CHECK (status = ANY (ARRAY['active'::text, 'unsubscribed'::text, 'bounced'::text]))
);

ALTER TABLE public.newsletter ENABLE ROW LEVEL SECURITY;

COMMENT ON TABLE public.newsletter
  IS 'Subscritores da newsletter. Versionada na migration 047 (era drift do dashboard).';

-- 2) Policies — espelho das atuais (roles confirmados via pg_policies)

DROP POLICY IF EXISTS "Public can insert newsletter subscriptions" ON public.newsletter;
CREATE POLICY "Public can insert newsletter subscriptions" ON public.newsletter
  FOR INSERT TO anon
  WITH CHECK (
    (email IS NOT NULL)
    AND (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)
    AND (length(email) <= 254)
  );

DROP POLICY IF EXISTS "Admins can read newsletter" ON public.newsletter;
CREATE POLICY "Admins can read newsletter" ON public.newsletter
  FOR SELECT TO authenticated
  USING (public.is_current_user_admin());

DROP POLICY IF EXISTS "Admins can manage newsletter" ON public.newsletter;
CREATE POLICY "Admins can manage newsletter" ON public.newsletter
  FOR ALL TO public
  USING (public.is_current_user_admin())
  WITH CHECK (public.is_current_user_admin());

-- 3) RPCs
-- 3.1 unsubscribe_newsletter — corpo original + SET search_path fixo
CREATE OR REPLACE FUNCTION public.unsubscribe_newsletter(p_token uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_updated INT;
BEGIN
  UPDATE public.newsletter
    SET status = 'unsubscribed', updated_at = NOW()
    WHERE unsubscribe_token = p_token AND status = 'active';

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  IF v_updated = 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Token inválido ou já cancelado.');
  END IF;

  RETURN jsonb_build_object('success', true, 'message', 'Subscrição cancelada com sucesso.');
END;
$function$;

-- 3.2 subscribe_newsletter — comportamento preservado (reativação incl.) +
--     hardening + contrato corrigido (ver cabeçalho da migration)
CREATE OR REPLACE FUNCTION public.subscribe_newsletter(p_email text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_email TEXT;
  v_existing RECORD;
BEGIN
  v_email := lower(trim(p_email));
  IF v_email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR length(v_email) > 254 THEN
    RAISE EXCEPTION 'Email inválido.';
  END IF;

  SELECT id, status INTO v_existing FROM public.newsletter WHERE email = v_email LIMIT 1;

  IF FOUND THEN
    IF v_existing.status = 'active' THEN
      RAISE EXCEPTION 'Este email já está subscrito (already subscribed).';
    END IF;
    UPDATE public.newsletter SET status = 'active', updated_at = NOW() WHERE id = v_existing.id;
    RETURN jsonb_build_object('success', true, 'message', 'Subscrição reativada com sucesso!');
  END IF;

  INSERT INTO public.newsletter (email) VALUES (v_email);
  RETURN jsonb_build_object('success', true, 'message', 'Subscrição realizada com sucesso!');
END;
$function$;

GRANT EXECUTE ON FUNCTION public.subscribe_newsletter(text) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.unsubscribe_newsletter(uuid) TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.subscribe_newsletter(text)
  IS 'Subscrição pública. SECURITY DEFINER com search_path fixo (migration 047). Duplicados/email inválido → RAISE EXCEPTION (contrato com NewsletterSection.jsx).';
COMMENT ON FUNCTION public.unsubscribe_newsletter(uuid)
  IS 'Cancelamento via token. SECURITY DEFINER com search_path fixo (migration 047).';
