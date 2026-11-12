-- Teste funcional das RPCs de inscrição, capacidade e cancelamento.
--
-- Corre numa transacção e termina com ROLLBACK: não deixa dados.
--   psql "$SUPABASE_DB_URL" -f supabase/tests/inscricoes_rpc.test.sql
--
-- Espera ver: TESTES_FUNCIONAIS_OK

begin;

do $$
declare
  v_event uuid;
  v_cap jsonb;
  v_code text;
  v_id bigint;
  v_count int;
begin
  insert into public.events (slug, title, category, category_label, date, status, capacity)
  values ('teste-rpc-inscricao', 'Teste RPC', 'workshop', 'Workshop', current_date + 7, 'published', null)
  returning id into v_event;

  -- 1. capacidade nula = ilimitada
  select code into v_code from public.submit_inscription_v3(
    v_event, 'a@teste.pt',
    jsonb_build_object('nome', 'Ana Teste', 'telefone', '+351912345678', 'profissao', 'farmaceutico', 'evento_slug', 'teste-rpc-inscricao')
  );
  if v_code <> 'ok' then raise exception 'falhou capacidade nula: %', v_code; end if;

  -- 2. duplicado
  select code into v_code from public.submit_inscription_v3(
    v_event, 'a@teste.pt',
    jsonb_build_object('nome', 'Ana Teste', 'telefone', '+351912345678', 'profissao', 'farmaceutico', 'evento_slug', 'teste-rpc-inscricao')
  );
  if v_code <> 'duplicate' then raise exception 'falhou duplicado: %', v_code; end if;

  -- 3. evento cheio
  update public.events set capacity = 1 where id = v_event;

  select code into v_code from public.submit_inscription_v3(
    v_event, 'b@teste.pt',
    jsonb_build_object('nome', 'Bruno Teste', 'telefone', '+351912345679', 'profissao', 'farmaceutico', 'evento_slug', 'teste-rpc-inscricao')
  );
  if v_code <> 'event_full' then raise exception 'falhou cheio: %', v_code; end if;

  -- 4. lista de espera quando cheio
  v_code := public.join_waitlist(
    v_event, 'espera@teste.pt',
    jsonb_build_object('nome', 'Espera Teste', 'telefone', '+351912345681', 'profissao', 'farmaceutico', 'evento_slug', 'teste-rpc-inscricao')
  );
  if v_code <> 'ok' then raise exception 'falhou lista de espera: %', v_code; end if;

  v_code := public.join_waitlist(
    v_event, 'espera@teste.pt',
    jsonb_build_object('nome', 'Espera Teste', 'telefone', '+351912345681', 'profissao', 'farmaceutico', 'evento_slug', 'teste-rpc-inscricao')
  );
  if v_code <> 'duplicate' then raise exception 'falhou duplicado na espera: %', v_code; end if;

  -- 5. cancelar liberta a vaga e promove a lista de espera
  select id into v_id from public.inscricoes
  where evento_id = v_event and email = 'a@teste.pt' and status = 'confirmada';

  select code into v_code from public.cancel_inscription(v_id::text, 'a@teste.pt', null, null, false);
  if v_code <> 'ok' then raise exception 'falhou cancelar: %', v_code; end if;

  select count(*) into v_count from public.inscricoes
  where evento_id = v_event and email = 'espera@teste.pt' and status = 'confirmada';
  if v_count <> 1 then raise exception 'nao promoveu a lista de espera'; end if;

  -- 6. reinscrição depois de cancelar
  update public.events set capacity = 5 where id = v_event;

  select code into v_code from public.submit_inscription_v3(
    v_event, 'a@teste.pt',
    jsonb_build_object('nome', 'Ana Teste', 'telefone', '+351912345678', 'profissao', 'farmaceutico', 'evento_slug', 'teste-rpc-inscricao')
  );
  if v_code <> 'ok' then raise exception 'falhou reinscricao: %', v_code; end if;

  -- 7. cancelar inscrição de outra pessoa
  select id into v_id from public.inscricoes
  where evento_id = v_event and email = 'a@teste.pt' and status = 'confirmada';

  select code into v_code from public.cancel_inscription(v_id::text, 'outra@teste.pt', null, null, false);
  if v_code <> 'forbidden' then raise exception 'falhou forbidden: %', v_code; end if;

  -- 8. reduzir abaixo do count sem force
  v_cap := public.set_event_capacity(v_event, 1, false);
  if v_cap->>'code' <> 'below_count' then raise exception 'falhou below_count: %', v_cap; end if;

  -- 9. reduzir com force
  v_cap := public.set_event_capacity(v_event, 1, true);
  if (v_cap->>'ok')::boolean is not true then raise exception 'falhou force: %', v_cap; end if;

  -- 10. trigger bloqueia escrita directa abaixo do count
  begin
    update public.events set capacity = 1 where id = v_event;
    raise exception 'trigger nao disparou';
  exception
    when check_violation then null;
  end;

  -- 11. capacidade zero é inválida
  v_cap := public.set_event_capacity(v_event, 0, false);
  if v_cap->>'code' <> 'invalid_capacity' then raise exception 'falhou capacidade zero: %', v_cap; end if;

  -- 12. cancelar depois de o evento decorrer
  update public.events set date = current_date - 1 where id = v_event;

  select id into v_id from public.inscricoes
  where evento_id = v_event and email = 'espera@teste.pt' and status = 'confirmada';

  select code into v_code from public.cancel_inscription(v_id::text, 'espera@teste.pt', null, null, false);
  if v_code <> 'event_started' then raise exception 'falhou evento passado: %', v_code; end if;
end $$;

select 'TESTES_FUNCIONAIS_OK' as resultado;

rollback;
