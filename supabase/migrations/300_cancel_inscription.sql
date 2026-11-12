-- 300: cancelamento de inscrição
--
-- Substitui o DELETE de `lib/actions/account.js` por um UPDATE de estado,
-- com autor, motivo e data. Mantém o histórico e permite reinscrição (o
-- índice único da 295 é parcial).
--
-- O lock na linha do evento respeita a ordem events -> inscricoes usada pela
-- RPC de inscrição. Sem ele, a promoção de lista de espera podia correr em
-- paralelo com uma inscrição e quebrar o invariante.
--
-- A autorização principal continua na Server Action (sessão + e-mail
-- confirmado). `p_email` e `p_is_admin` são defesa em profundidade.

begin;

create or replace function public.cancel_inscription(
  p_id text,
  p_email text,
  p_actor uuid default null,
  p_motivo text default null,
  p_is_admin boolean default false
)
returns table (code text, promoted_id text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_event uuid;
  v_row_email text;
  v_status text;
  v_attended boolean;
  v_date date;
  v_capacity int;
  v_count int;
  v_promoted bigint;
begin
  select i.evento_id, i.email, i.status, i.compareceu
    into v_event, v_row_email, v_status, v_attended
  from inscricoes i
  where i.id::text = p_id
  for update;

  if not found then
    return query select 'not_found'::text, null::text;
    return;
  end if;

  if not p_is_admin
     and lower(trim(coalesce(v_row_email, ''))) <> lower(trim(coalesce(p_email, ''))) then
    return query select 'forbidden'::text, null::text;
    return;
  end if;

  if v_status = 'cancelada' then
    return query select 'already_cancelled'::text, null::text;
    return;
  end if;

  if v_attended then
    return query select 'attended'::text, null::text;
    return;
  end if;

  if v_event is not null then
    select e.date, e.capacity into v_date, v_capacity
    from events e
    where e.id = v_event
    for update;

    if v_date is not null and v_date < current_date then
      return query select 'event_started'::text, null::text;
      return;
    end if;
  end if;

  update inscricoes
  set status = 'cancelada',
      cancelada_em = now(),
      cancelada_por = p_actor,
      motivo_cancelamento = nullif(trim(coalesce(p_motivo, '')), '')
  where id::text = p_id;

  -- Promoção de lista de espera, apenas se houver vaga real. Se a capacidade
  -- foi forçada abaixo do count, não se promove ninguém.
  select count(*) into v_count
  from inscricoes
  where evento_id = v_event and status = 'confirmada';

  if v_event is not null
     and (v_capacity is null or v_count < v_capacity) then
    select i.id into v_promoted
    from inscricoes i
    where i.evento_id = v_event
      and i.status = 'lista_espera'
    order by i.created_at
    limit 1
    for update skip locked;

    if v_promoted is not null then
      update inscricoes set status = 'confirmada' where id = v_promoted;
    end if;
  end if;

  return query select 'ok'::text, v_promoted::text;
end;
$$;

revoke all on function public.cancel_inscription(text, text, uuid, text, boolean)
  from public, anon, authenticated;
grant execute on function public.cancel_inscription(text, text, uuid, text, boolean)
  to service_role;

commit;
