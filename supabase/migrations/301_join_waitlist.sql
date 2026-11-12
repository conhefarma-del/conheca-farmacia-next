-- 301: lista de espera
--
-- Quando o evento está cheio, a pessoa pode entrar na lista de espera sem
-- ocupar vaga. A promoção acontece na RPC de cancelamento (300), por ordem
-- de chegada. Duplicados activos (confirmada ou já em espera) são recusados.

begin;

create or replace function public.join_waitlist(
  p_evento_id uuid,
  p_email text,
  p_form jsonb
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_slug text;
  v_email text := lower(trim(p_email));
begin
  if p_evento_id is null or v_email is null or length(v_email) = 0 then
    return 'invalid_input';
  end if;

  if p_form->>'faixa_etaria' = 'menor-18'
     and coalesce((p_form->>'menor_consentimento')::boolean, false) = false then
    return 'invalid_input';
  end if;

  select e.slug into v_slug
  from events e
  where e.id = p_evento_id
    and e.status = 'published'
    and e.is_archived = false
  for update;

  if not found then
    return 'event_not_found';
  end if;

  if exists (
    select 1 from inscricoes i
    where i.evento_id = p_evento_id
      and lower(i.email) = v_email
      and i.status in ('confirmada', 'lista_espera')
  ) then
    return 'duplicate';
  end if;

  insert into inscricoes (
    nome, email, telefone, profissao, genero, faixa_etaria,
    nivel_escolaridade, menor_consentimento, origem_evento,
    evento_id, evento_slug, status, municipio, user_id, created_at
  ) values (
    p_form->>'nome',
    v_email,
    p_form->>'telefone',
    p_form->>'profissao',
    nullif(p_form->>'genero', ''),
    nullif(p_form->>'faixa_etaria', ''),
    nullif(p_form->>'nivel_escolaridade', ''),
    coalesce((p_form->>'menor_consentimento')::boolean, false),
    coalesce(nullif(p_form->>'origem_evento', ''), 'outro'),
    p_evento_id,
    coalesce(nullif(p_form->>'evento_slug', ''), v_slug),
    'lista_espera',
    nullif(p_form->>'municipio', ''),
    nullif(p_form->>'user_id', '')::uuid,
    now()
  );

  return 'ok';
exception
  when unique_violation then
    return 'duplicate';
end;
$$;

revoke all on function public.join_waitlist(uuid, text, jsonb)
  from public, anon, authenticated;
grant execute on function public.join_waitlist(uuid, text, jsonb)
  to service_role;

commit;
