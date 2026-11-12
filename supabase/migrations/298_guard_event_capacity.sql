-- 298: backstop do invariante de capacidade
--
-- Mesmo com SQL manual, migração ou admin a escrever directamente em
-- `events.capacity`, a linha do evento não pode ficar abaixo do número de
-- inscrições confirmadas. O trigger conta dentro da transacção do UPDATE,
-- com a linha do evento já bloqueada — a mesma ordem de locks da RPC de
-- inscrição (events -> inscricoes).

begin;

create or replace function public.guard_event_capacity()
returns trigger
language plpgsql
as $$
begin
  -- A RPC set_event_capacity marca esta flag (local à transacção) quando o
  -- admin confirma explicitamente uma redução abaixo do número de inscritos.
  -- Fora desse caminho, o invariante é sempre protegido.
  if current_setting('app.capacity_below_count_ok', true) = 'on' then
    return new;
  end if;

  if new.capacity is not null then
    if (
      select count(*) from inscricoes
      where evento_id = new.id and status = 'confirmada'
    ) > new.capacity then
      raise exception 'capacidade abaixo do numero de inscritos'
        using errcode = '23514';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_guard_event_capacity on public.events;

create trigger trg_guard_event_capacity
before update of capacity on public.events
for each row execute function public.guard_event_capacity();

commit;
