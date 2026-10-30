-- ============================================================
-- 293 · As RPCs de auditoria de auth deixam de ser públicas
--
-- A 031 criou `log_auth_attempt`, `check_rate_limit` e
-- `check_gate_lockout` como SECURITY DEFINER, mas não revogou o
-- EXECUTE que o Postgres dá a PUBLIC por omissão. Com a anon key —
-- pública, logo nas mãos de qualquer visitante — era possível
-- escrever em `auth_attempts`, a tabela que serve de juiz aos
-- rate-limits. Daí saíam três abusos:
--
--   1. forjar falhas com o hash do e-mail de outra pessoa até
--      `check_rate_limit` a bloquear (DoS de login/inscrição);
--   2. forjar falhas com `p_user_id` alheio em attempt='gate' até
--      `check_gate_lockout` bloquear o quiz dessa pessoa;
--   3. gravar `success = true` para apagar o rasto de um brute force
--      real.
--
-- Quem passa a poder chamar: só o service_role. O único chamador
-- (`lib/actions/inscription.js`) usa `createAdminClient()`.
--
-- Aplicar: python scripts/apply-migration.py supabase/migrations/293_auth_rpc_revoke_public.sql
-- ============================================================

do $$
declare
  assinatura text;
  assinaturas text[] := array[
    'public.log_auth_attempt(inet, text, text, boolean, uuid)',
    'public.check_rate_limit(inet, text, text, integer, integer)',
    'public.check_gate_lockout(uuid, integer, integer)'
  ];
begin
  foreach assinatura in array assinaturas loop
    if to_regprocedure(assinatura) is null then
      raise notice 'função ausente, ignorada: %', assinatura;
      continue;
    end if;

    execute format(
      'revoke execute on function %s from public, anon, authenticated',
      assinatura
    );
    execute format('grant execute on function %s to service_role', assinatura);
  end loop;
end $$;

-- ------------------------------------------------------------
-- Verificação
-- ------------------------------------------------------------
-- select p.proname, r.rolname
--   from pg_proc p
--   join pg_namespace n on n.oid = p.pronamespace
--   cross join (values ('anon'), ('authenticated'), ('service_role')) as r(rolname)
--  where n.nspname = 'public'
--    and p.proname in ('log_auth_attempt','check_rate_limit','check_gate_lockout')
--    and has_function_privilege(r.rolname, p.oid, 'execute')
--  order by 1, 2;
--   → esperado: só service_role em cada uma.
