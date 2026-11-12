-- 295: estado da inscrição, cancelamento e contrato de capacidade
--
-- 1. `status` explícito em inscricoes: confirmada | cancelada | lista_espera.
--    O cancelamento deixa de apagar a linha (perde-se o histórico) e passa a
--    marcar `cancelada`, com autor e motivo.
-- 2. Os dois índices únicos existentes passam a parciais: uma inscrição
--    cancelada não pode impedir a pessoa de se inscrever outra vez.
-- 3. `events.capacity NULL` = vagas ilimitadas; 0 e negativos são inválidos.
-- 4. A contagem pública de inscrições passa a contar só as confirmadas e a
--    ligar por `evento_id` (fonte de verdade desde a 024).

begin;

-- ---------------------------------------------------------------------
-- 1. Colunas de estado
-- ---------------------------------------------------------------------
alter table public.inscricoes
  add column if not exists status text not null default 'confirmada',
  add column if not exists cancelada_em timestamptz,
  add column if not exists cancelada_por uuid references auth.users(id) on delete set null,
  add column if not exists motivo_cancelamento text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'inscricoes_status_check'
      and conrelid = 'public.inscricoes'::regclass
  ) then
    alter table public.inscricoes
      add constraint inscricoes_status_check
      check (status in ('confirmada', 'cancelada', 'lista_espera'));
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 2. Contrato de capacidade
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'events_capacity_positive'
      and conrelid = 'public.events'::regclass
  ) then
    alter table public.events
      add constraint events_capacity_positive
      check (capacity is null or capacity > 0) not valid;

    alter table public.events validate constraint events_capacity_positive;
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 3. Índices únicos parciais
-- ---------------------------------------------------------------------
-- O legado (email, evento_slug) é uma constraint; o índice só desaparece
-- depois de a constraint ser removida.
alter table public.inscricoes drop constraint if exists unique_email_evento;
drop index if exists public.inscricoes_evento_id_lower_email_key;

create unique index if not exists inscricoes_evento_id_lower_email_ativa_key
  on public.inscricoes (evento_id, lower(email))
  where evento_id is not null and status <> 'cancelada';

create unique index if not exists unique_email_evento_ativa
  on public.inscricoes (email, evento_slug)
  where status <> 'cancelada';

create index if not exists idx_inscricoes_evento_status
  on public.inscricoes (evento_id, status);

-- ---------------------------------------------------------------------
-- 4. Contagem pública: só confirmadas, por evento_id
-- ---------------------------------------------------------------------
create or replace function public.get_events_with_inscription_counts()
returns table (
  id uuid, slug text, title text, excerpt text, image_url text,
  category text, category_label text, date date,
  "time" time without time zone, end_time time without time zone,
  location text, type text, capacity integer, hosts jsonb, status text,
  featured boolean, registration_link text,
  platform text, access_link text, meeting_id text, password text,
  materials text, topic text, registration_enabled boolean,
  inscription_count bigint
)
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  return query
  select
    e.id, e.slug, e.title, e.excerpt, e.image_url,
    e.category, e.category_label, e.date, e.time, e.end_time,
    e.location, e.type, e.capacity, e.hosts, e.status,
    e.featured, e.registration_link,
    e.platform, e.access_link, e.meeting_id, e.password, e.materials,
    e.topic, e.registration_enabled,
    count(i.id)::bigint as inscription_count
  from events e
  left join inscricoes i
    on i.evento_id = e.id
   and i.status = 'confirmada'
  where e.status = 'published'
  group by e.id, e.slug, e.title, e.excerpt, e.image_url,
    e.category, e.category_label, e.date, e.time, e.end_time,
    e.location, e.type, e.capacity, e.hosts, e.status,
    e.featured, e.registration_link,
    e.platform, e.access_link, e.meeting_id, e.password, e.materials,
    e.topic, e.registration_enabled
  order by e.date asc;
end;
$function$;

commit;
