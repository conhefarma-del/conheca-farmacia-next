-- 297: alteração de capacidade atómica
--
-- O /admin passa a chamar esta RPC em vez de escrever `capacity` no UPDATE
-- geral do evento. O lock na linha do evento mantém o invariante
-- "confirmadas <= capacity" mesmo com inscrições a entrar em paralelo.
--
-- `p_force = true` permite reduzir abaixo do número de inscritos: o evento
-- fica fechado, mas as inscrições existentes mantêm-se (nunca há overbooking).

begin;

create or replace function public.set_event_capacity(
  p_event_id uuid,
  p_capacity int,
  p_force boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count int;
begin
  if p_capacity is not null and p_capacity <= 0 then
    return jsonb_build_object('ok', false, 'code', 'invalid_capacity');
  end if;

  perform 1 from events where id = p_event_id for update;
  if not found then
    return jsonb_build_object('ok', false, 'code', 'event_not_found');
  end if;

  select count(*) into v_count
  from inscricoes
  where evento_id = p_event_id
    and status = 'confirmada';

  if p_capacity is not null and p_capacity < v_count and not p_force then
    return jsonb_build_object(
      'ok', false,
      'code', 'below_count',
      'count', v_count
    );
  end if;

  -- A redução forçada é a única excepção ao trigger da 298. A flag é local
  -- à transacção, por isso não abre a porta a SQL manual noutra sessão.
  if p_force and p_capacity is not null and p_capacity < v_count then
    perform set_config('app.capacity_below_count_ok', 'on', true);
  end if;

  update events set capacity = p_capacity where id = p_event_id;

  -- A flag não pode sobreviver à chamada: o PostgREST termina a transacção,
  -- mas uma chamada dentro de outra transacção não deve abrir a porta ao
  -- trigger para o resto do trabalho.
  perform set_config('app.capacity_below_count_ok', 'off', true);

  return jsonb_build_object('ok', true, 'count', v_count);
end;
$$;

revoke all on function public.set_event_capacity(uuid, int, boolean)
  from public, anon, authenticated;
grant execute on function public.set_event_capacity(uuid, int, boolean)
  to service_role;

commit;
