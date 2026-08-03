-- Migration 048: certificado público via SECURITY DEFINER (corrige página partida)
--
-- Contexto (auditoria "O Sentinela" #2):
--   O /certificado/[token]/page.js lia diretamente de inscricoes como anónimo,
--   mas a tabela tem RLS ATIVA E nenhuma policy SELECT para anon (confirmado:
--   relrowsecurity = true; pg_policies só tem INSERT anon + SELECT admin).
--   Consequência: a leitura anónima devolve 0 linhas → a verificação devolvia
--   sempre "Certificado inválido" (feature partida em produção).
--
--   Correção: capability URI via função SECURITY DEFINER:
--     - RLS continua a bloquear QUALQUER SELECT anónimo direto em inscricoes;
--     - a função devolve APENAS a linha cujo certificado_token coincide,
--       sem nunca expor a lista completa.
--     - SET search_path = public (hardening padrão).
--
--   NOTA DE SEGURANÇA: NÃO criar uma policy anon SELECT com
--   USING (certificado_token IS NOT NULL) — isso exporia TODAS as linhas com
--   token. O RPC é a única porta de leitura pública e está intencionalmente
--   fora do alcance das policies RLS.
--
-- Idempotente. Aplicar ANTES do deploy da página refatorada.

CREATE OR REPLACE FUNCTION public.get_certificado_by_token(p_token uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
STABLE
SET search_path = public
AS $function$
DECLARE
  v_out jsonb;
BEGIN
  SELECT jsonb_build_object(
    'nome',               i.nome,
    'created_at',         i.created_at,
    'compareceu',         i.compareceu,
    'certificado_token',  i.certificado_token,
    'evento', CASE
      WHEN e.id IS NULL THEN NULL
      ELSE jsonb_build_object(
        'id',                           e.id,
        'title',                        e.title,
        'date',                         e.date,
        'location',                     e.location,
        'certificado_cor',              e.certificado_cor,
        'certificado_texto',            e.certificado_texto,
        'certificado_logo_url',         e.certificado_logo_url,
        'certificado_carga_horaria',    e.certificado_carga_horaria,
        'certificado_assinante_1_nome', e.certificado_assinante_1_nome,
        'certificado_assinante_1_cargo',e.certificado_assinante_1_cargo,
        'certificado_assinante_2_nome', e.certificado_assinante_2_nome,
        'certificado_assinante_2_cargo',e.certificado_assinante_2_cargo
      )
    END
  )
  INTO v_out
  FROM public.inscricoes i
  LEFT JOIN public.events e ON e.id = i.evento_id
  WHERE i.certificado_token = p_token
  LIMIT 1;

  RETURN v_out; -- NULL se o token não existir
END;
$function$;

GRANT EXECUTE ON FUNCTION public.get_certificado_by_token(uuid)
  TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.get_certificado_by_token(uuid)
  IS 'Devolve o payload público de certificado para o token fornecido (capability). SECURITY DEFINER com search_path fixo (migration 048). RLS continua a bloquear SELECT anónimo direto em inscricoes.';