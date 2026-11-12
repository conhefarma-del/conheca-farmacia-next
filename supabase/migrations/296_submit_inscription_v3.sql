-- 296: RPC de inscrição v3
--
-- Substitui (sem remover ainda) `submit_inscription_safe`:
--   * `capacity NULL` passa a significar vagas ilimitadas, em vez de
--     "evento não encontrado" (`NOT FOUND` distingue os dois casos);
--   * conta e verifica duplicados só entre inscrições confirmadas;
--   * devolve `id` e `share_code` no RETURNING, eliminando o SELECT/UPDATE
--     posteriores do caller;
--   * grava `user_id` e `municipio` na mesma transacção;
--   * converte `unique_violation` em `duplicate` (backstop do índice parcial);
--   * preenche `evento_slug`/`origem_evento`, que são NOT NULL, a partir do
--     evento e de um valor aceite pelo CHECK da 014.
--
-- O `FOR UPDATE` continua a serializar contagem + duplicado + insert por
-- evento. A função antiga fica disponível para rollback até a release seguinte.

begin;

create or replace function public.submit_inscription_v3(
  p_evento_id uuid,
  p_email text,
  p_form jsonb
)
returns table (code text, id text, share_code text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_capacity int;
  v_slug text;
  v_count int;
  v_email text := lower(trim(p_email));
  v_id bigint;
  v_share text;
begin
  if p_evento_id is null or v_email is null or length(v_email) = 0 then
    return query select 'invalid_input'::text, null::text, null::text;
    return;
  end if;

  if p_form->>'faixa_etaria' = 'menor-18'
     and coalesce((p_form->>'menor_consentimento')::boolean, false) = false then
    return query select 'invalid_input'::text, null::text, null::text;
    return;
  end if;

  select e.capacity, e.slug
    into v_capacity, v_slug
  from events e
  where e.id = p_evento_id
    and e.status = 'published'
    and e.is_archived = false
  for update;

  if not found then
    return query select 'event_not_found'::text, null::text, null::text;
    return;
  end if;

  select count(*) into v_count
  from inscricoes i
  where i.evento_id = p_evento_id
    and i.status = 'confirmada';

  if v_capacity is not null and v_count >= v_capacity then
    return query select 'event_full'::text, null::text, null::text;
    return;
  end if;

  if exists (
    select 1 from inscricoes i
    where i.evento_id = p_evento_id
      and lower(i.email) = v_email
      and i.status <> 'cancelada'
  ) then
    return query select 'duplicate'::text, null::text, null::text;
    return;
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
    'confirmada',
    nullif(p_form->>'municipio', ''),
    nullif(p_form->>'user_id', '')::uuid,
    now()
  )
  returning inscricoes.id, inscricoes.share_code into v_id, v_share;

  return query select 'ok'::text, v_id::text, v_share;

exception
  when unique_violation then
    -- Corrida que escapou ao FOR UPDATE (admin, SQL manual, migração):
    -- o índice parcial é o backstop e o caller recebe o código correcto.
    return query select 'duplicate'::text, null::text, null::text;
end;
$$;

revoke all on function public.submit_inscription_v3(uuid, text, jsonb)
  from public, anon, authenticated;
grant execute on function public.submit_inscription_v3(uuid, text, jsonb)
  to service_role;

commit;
