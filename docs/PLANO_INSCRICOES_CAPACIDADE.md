# Plano — Inscrições em eventos: concorrência, capacidade e cancelamento

**Projecto:** `conheca-farmacia-NEXT`
**Data:** 2026-11-12
**Âmbito:** fluxo público de inscrição, edição de capacidade no `/admin`, gestão de inscritos e cancelamento pelo participante com conta.
**Base:** análise estática de `lib/actions/inscription.js`, `lib/actions/content.js`, `lib/actions/account.js`, `components/admin/EventForm.jsx`, `components/admin/InscritosListPage.jsx`, `supabase/functions/validate-inscription/index.ts` e migrações `029`, `030`, `037`, `141`, `024`, `253`.

> Este documento é um plano. Nada aqui foi aplicado. As migrações propostas começam em **295** (a última existente é `294_admin_aal2_restrictive.sql`).

---

## 1. Resumo executivo

| Decisão | Estado |
|---|---|
| `FOR UPDATE` na inscrição | **Manter.** É necessário e está correcto. |
| Edição de capacidade no `/admin` | **Pode continuar**, mas passa a ser validada, atómica, confirmada e auditada. |
| Reduzir capacidade abaixo do nº de inscritos | Permitido **com confirmação explícita** (`force`); não cria overbooking. |
| `capacity` nula | Passa a significar **vagas ilimitadas**. Hoje significa “evento não encontrado”. |
| Cancelamento pelo participante | Já existe e funciona; passa de `DELETE` para `status = 'cancelada'`, com histórico, auditoria, libertação de vaga e promoção de lista de espera. |
| Contagem de vagas | Uma só definição: `inscricoes.status = 'confirmada'` por `evento_id`. |
| `INSERT` directo por `anon` | Revogar. A inscrição passa a ter um único caminho: a RPC com service role. |

**Invariante a garantir em todo o sistema:**

```
inscrições confirmadas de um evento <= events.capacity   (quando capacity não é NULL)
```

O invariante é mantido pela RPC de inscrição (lock + contagem + insert na mesma transacção), pela RPC de cancelamento (lock + update + promoção) e por um trigger como rede de segurança contra SQL manual.

---

## 2. Estado actual e problemas

### 2.1 Inscrição (caminho público)

```
Browser
  └─ Server Action apiSubmitInscription   (lib/actions/inscription.js)
       ├─ rate limit (DB + memória)
       ├─ Edge Function validate-inscription   → pré-checks (capacidade, duplicado)
       ├─ RPC submit_inscription_safe          → FOR UPDATE + count + duplicate + insert
       ├─ SELECT id, share_code por (evento_id, email)   ← não atómico
       ├─ UPDATE municipio / user_id                     ← separado
       └─ fetch send-inscription-email                   ← antes de responder
```

Problemas:

| # | Problema | Impacto |
|---|---|---|
| 1 | `IF v_capacity IS NULL THEN RETURN 'event_not_found'` | Evento sem capacidade não aceita inscrições, apesar de a UI mostrar o botão. |
| 2 | Edge calcula `capacity - count` com `capacity = NULL` → `NaN` | O pré-validador não bloqueia; a RPC rejeita com código errado. |
| 3 | `COUNT` por `evento_id` na RPC, por `evento_slug` na Edge | Linhas antigas sem `evento_id` contam num sítio e não no outro. |
| 4 | `INSERT` não trata `unique_violation` | Uma corrida que escape ao lock devolve `db_insert_error` em vez de `duplicate`. |
| 5 | `SELECT` do id depois da RPC + `UPDATE` de município | Três operações onde devia haver uma; falha parcial deixa a linha incompleta. |
| 6 | Política `"Public can insert inscricoes" FOR INSERT TO public` (migração `141`) | Com os grants por omissão do Supabase, `anon` pode inserir directamente e **ignorar a capacidade**. |
| 7 | Email enviado com `fetch` antes da resposta | Latência acrescentada e risco de perda se a função terminar. |

### 2.2 Capacidade no `/admin`

| # | Problema | Impacto |
|---|---|---|
| 1 | `<input type="number">` sem `min`, `max`, `required` | Aceita vazio, `0`, negativos e decimais (truncados por `parseInt`). |
| 2 | `capacity: formData.capacity ? parseInt(...) : null` | Vazio → `NULL`, sem intenção explícita. |
| 3 | `UPDATE events` cego | Nada impede reduzir para 3 com 80 inscritos. |
| 4 | Sem lock nem leitura do count | Entre contar e actualizar pode entrar uma inscrição; o valor fica abaixo do real. |
| 5 | `logAudit(..., { title })` | Não se sabe quem mudou, de quanto para quanto, nem porquê. |
| 6 | Formulário não mostra inscritos/vagas | O admin decide às cegas. |

**Reduzir abaixo do count não cria overbooking**: as inscrições existentes mantêm-se e o evento fica fechado. O problema é o estado implícito e a falta de aviso/auditoria.

### 2.3 Cancelamento pelo participante (conta)

Já implementado em `lib/actions/account.js:73` (`cancelarInscricao`) e `components/account/CancelInscriptionButton.jsx`:

- autorização por **e-mail da sessão confirmada** (`email_confirmed_at`), porque `inscricoes` não tem `user_id` garantido;
- recusa se `compareceu = true` ou se a data do evento já passou;
- `DELETE` da linha;
- `revalidatePath('/perfil/eventos')`.

O que falta:

| # | Problema | Impacto |
|---|---|---|
| 1 | `DELETE` | Perde histórico, autor, motivo e impossibilita lista de espera. |
| 2 | Sem auditoria | Não se sabe quem cancelou nem quando. |
| 3 | Sem email de confirmação | O participante não tem prova do cancelamento. |
| 4 | Sem `FOR UPDATE` no evento | A libertação de vaga e a promoção de lista de espera não são serializáveis com inscrições. |
| 5 | Índice único `(evento_id, lower(email))` | Com soft-delete, impede voltar a inscrever-se depois de cancelar. Tem de passar a índice parcial. |
| 6 | `loadInscricoes` não filtra estado | Canceladas continuariam a aparecer como activas. |
| 7 | Sem cancelamento pelo admin | Só o participante consegue cancelar. |

---

## 3. Concorrência: race condition e `FOR UPDATE`

### 3.1 Porque é necessário

O padrão anterior (contar → inserir em chamadas separadas) é TOCTOU:

```
T1: SELECT count(*) → 99        T2: SELECT count(*) → 99
T1: INSERT (100/100)            T2: INSERT (101/100)   ← overbooking
```

Em `READ COMMITTED`, mesmo um `INSERT ... SELECT` com `COUNT` continua racy: o snapshot de T2 não vê a linha não commitada de T1. As soluções possíveis:

| Solução | Custo | Escolha |
|---|---|---|
| `SELECT ... FOR UPDATE` na linha do evento | Lock curto por evento | **Adoptada** |
| `SERIALIZABLE` + retry | Retries e erros 40001 | Não |
| Advisory lock por evento | Gestão manual de chaves | Não |
| Coluna contador com `UPDATE ... SET n = n + 1 WHERE n < capacity` | Desnormaliza e complica cancelamentos | Não |

`FOR UPDATE` bloqueia apenas escritores da **mesma linha**; leituras continuam livres; eventos diferentes não se bloqueiam ([Postgres — Explicit Locking](https://www.postgresql.org/docs/current/explicit-locking.html)).

**Nuance decisiva:** no Supabase, cada chamada PostgREST faz auto-commit. Um `FOR UPDATE` numa chamada e o `INSERT` noutra não partilham transacção e o lock é libertado imediatamente. Por isso **tudo tem de estar dentro de uma única função** — que é o desenho actual da RPC. Não tentar “lock na Server Action e insert depois”; não funciona.

### 3.2 Fluxo actual (manter)

```
RPC submit_inscription_safe (uma transacção)
  BEGIN
    SELECT capacity FROM events WHERE id = $1 AND published ... FOR UPDATE
    SELECT count(*) FROM inscricoes WHERE evento_id = $1
    IF cheio → 'event_full'
    IF duplicado → 'duplicate'
    INSERT INTO inscricoes ...
  COMMIT   ← lock libertado
```

- Lock mantido apenas durante count + insert (milissegundos).
- Sem chamadas de rede dentro da transacção (Edge e email ficam fora).
- Ordem de locks fixa: **`events` → `inscricoes`**. Todas as funções devem respeitá-la para evitar deadlocks.
- O `UPDATE` de capacidade do admin também toca a linha do evento: se a RPC estiver a contar, o admin espera; se o admin estiver a actualizar, a RPC espera. É o comportamento desejado.

### 3.3 O que muda na RPC (versão 3)

1. Distinguir “evento inexistente” de “capacidade nula” com `FOUND`.
2. `capacity NULL` = ilimitado.
3. Contar só `status = 'confirmada'`.
4. Duplicado só entre inscrições não canceladas.
5. `unique_violation` → `'duplicate'`.
6. Devolver `id` e `share_code` no `RETURNING`.
7. Receber `user_id` e `municipio`, eliminando o `SELECT`/`UPDATE` posteriores.

```sql
-- 296_submit_inscription_v3.sql
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

  select e.capacity into v_capacity
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
    nullif(p_form->>'origem_evento', ''),
    p_evento_id,
    nullif(p_form->>'evento_slug', ''),
    'confirmada',
    nullif(p_form->>'municipio', ''),
    nullif(p_form->>'user_id', '')::uuid,
    now()
  )
  returning inscricoes.id, inscricoes.share_code into v_id, v_share;

  return query select 'ok'::text, v_id::text, v_share;

exception
  when unique_violation then
    -- backstop: alguém inseriu fora do lock (admin, SQL manual, migração)
    return query select 'duplicate'::text, null::text, null::text;
end;
$$;

revoke all on function public.submit_inscription_v3(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.submit_inscription_v3(uuid, text, jsonb) to service_role;
```

**Notas de implementação**

- `not found` é definido pela última instrução `SELECT ... INTO`; é a forma correcta de distinguir de `capacity IS NULL`.
- O bloco `exception` reverte o `INSERT` para o savepoint e devolve `duplicate`; não deixa lixo.
- `id` é devolvido como `text` para acomodar linhas antigas com UUID e novas com `bigint`.
- `share_code` tem default/trigger da migração `253`; o `RETURNING` apanha o valor final.
- A função antiga só é removida depois de o caller novo estar em produção (ver §8, rollout).

### 3.4 Chamadas concorrentes — comportamento esperado

| Cenário | Resultado |
|---|---|
| Duas inscrições na última vaga | Uma `ok`, uma `event_full`. Nunca duas `ok`. |
| Mesmo e-mail em simultâneo, duas vias | Uma `ok`, uma `duplicate` (pelo `EXISTS` ou pelo índice parcial). |
| Inscrição durante redução de capacidade | Serializa no lock; se a redução commitar primeiro e ficar abaixo do count, a inscrição vê `event_full`. |
| Cancelamento durante inscrição | Serializa no lock do evento; a vaga libertada só é vista depois do commit. |
| Duas chamadas `RPC` em eventos diferentes | Não se bloqueiam. |

### 3.5 Riscos do lock

| Risco | Mitigação |
|---|---|
| Lock preso por transacção longa | Nenhuma chamada de rede dentro da RPC; `statement_timeout` do projecto. |
| Deadlock com cancelamento/promoção | Ordem fixa `events` → `inscricoes` em todas as funções. |
| Evento muito concorrido (milhares/s) | Improvável neste domínio; o lock dura um `COUNT` + `INSERT`. Se necessário, medir com `pg_stat_activity`/`pg_blocking_pids()`. |
| Admin bloqueado ao editar capacidade | Espera milissegundos; é intencional. |

---

## 4. P0 — Rede de segurança da capacidade

### P0.1 Contrato de `capacity`

`NULL` = ilimitado. Valores positivos = limite. `0` e negativos são inválidos.

```sql
-- 295_capacity_contrato.sql
alter table public.events
  add constraint events_capacity_positive
  check (capacity is null or capacity > 0) not valid;

alter table public.events validate constraint events_capacity_positive;
```

- A Edge e a UI tratam `capacity == null` como “vagas ilimitadas” (sem barra, sem “completo”).
- A RPC já não confunde `NULL` com inexistente (§3.3).
- `capacity = 0` deixa de ser uma forma implícita de fechar inscrições; para isso existe `registration_enabled` e o `status` do evento.

### P0.2 Edição atómica da capacidade

```sql
-- 297_set_event_capacity.sql
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
  where evento_id = p_event_id and status = 'confirmada';

  if p_capacity is not null and p_capacity < v_count and not p_force then
    return jsonb_build_object(
      'ok', false, 'code', 'below_count', 'count', v_count
    );
  end if;

  update events set capacity = p_capacity where id = p_event_id;

  return jsonb_build_object('ok', true, 'count', v_count);
end;
$$;

revoke all on function public.set_event_capacity(uuid, int, boolean) from public, anon, authenticated;
grant execute on function public.set_event_capacity(uuid, int, boolean) to service_role;
```

- `updateEvent` deixa de escrever `capacity` no `UPDATE` geral e chama esta RPC quando o valor mudou.
- Duas fases na UI: tenta sem `force`; se vier `below_count`, mostra confirmação e repete com `force: true`.
- A RPC corre numa transacção: o lock do evento impede que uma inscrição entre entre o `COUNT` e o `UPDATE`.

### P0.3 Trigger de invariante (backstop)

```sql
-- 298_guard_event_capacity.sql
create or replace function public.guard_event_capacity()
returns trigger
language plpgsql
as $$
begin
  if new.capacity is not null then
    if (select count(*) from inscricoes
        where evento_id = new.id and status = 'confirmada') > new.capacity then
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
```

Cobre SQL manual e migrações futuras. Custo: um `COUNT` por alteração de capacidade (irrelevante à escala actual).

### P0.4 Formulário de evento

`components/admin/EventForm.jsx`:

- `min={1}`, `step={1}`, `inputMode="numeric"`.
- Checkbox **“Sem limite de vagas”** que envia `capacity: null` explicitamente.
- Texto de contexto: `82 inscritos · 18 vagas` (dados vindos do servidor na página de edição).
- Aviso inline quando `novoValor < inscritos`: “Reduzir para X fecha o evento. As 82 inscrições mantêm-se.”
- Confirmação com `window.confirm` ou diálogo do design system antes do `force`.

### P0.5 Auditoria

`logAudit` passa a gravar:

```js
{
  title: eventData.title,
  capacity_anterior: existingEvent.capacity,
  capacity_nova: capacity,
  inscritos_no_momento: result.count,
  forcado: force === true,
}
```

A leitura de `existingEvent` já existe (`select('slug')`); passa a `select('slug, capacity')`.

### P0.6 Contagem única

- Edge `validate-inscription`: contar por `evento_id` (recebe o id; o slug é legado) e usar `status = 'confirmada'`.
- `lib/api/events.js`: uma função `getEventInscriptionCount(eventId)` com a mesma expressão.
- UI: `capacity == null` → não mostrar barra/saldo; `count >= capacity` → completo.
- Ideal: view `public.event_capacity` com `(event_id, capacity, confirmed_count)` e `security_invoker = true`, para não duplicar a regra.

---

## 5. P1 — Fluxo completo de inscrição e gestão

### P1.1 Fechar o `INSERT` directo do `anon`

A migração `141` mantém:

```sql
CREATE POLICY "Public can insert inscricoes" ON public.inscricoes
  FOR INSERT TO public
  WITH CHECK (email IS NOT NULL AND length(email) <= 254 AND nome IS NOT NULL AND length(nome) >= 3);
```

Como todas as inscrições passam pela Server Action com service role, esta política é desnecessária e permite contornar capacidade e duplicados.

```sql
-- 299_rls_inscricoes_fechar_anon.sql
drop policy if exists "Public can insert inscricoes" on public.inscricoes;
revoke insert on public.inscricoes from anon, authenticated;
```

Confirmar antes em produção:

```sql
select grantee, privilege_type
from information_schema.role_table_grants
where table_name = 'inscricoes';

select policyname, cmd, roles, qual, with_check
from pg_policies where tablename = 'inscricoes';
```

### P1.2 Estado explícito da inscrição

```sql
-- 295 (continuação)
alter table public.inscricoes
  add column if not exists status text not null default 'confirmada'
    check (status in ('confirmada', 'cancelada', 'lista_espera')),
  add column if not exists cancelada_em timestamptz,
  add column if not exists cancelada_por uuid references auth.users(id) on delete set null,
  add column if not exists motivo_cancelamento text;

drop index if exists public.inscricoes_evento_id_lower_email_key;

create unique index inscricoes_evento_id_lower_email_ativa_key
  on public.inscricoes (evento_id, lower(email))
  where status <> 'cancelada';

create index if not exists idx_inscricoes_evento_status
  on public.inscricoes (evento_id, status);
```

- O índice **parcial** é obrigatório: com `status`, o índice único antigo impediria voltar a inscrever-se depois de cancelar.
- `status` conta para capacidade apenas quando `confirmada`.
- `lista_espera` é opcional (ver P1.5) mas o valor já fica no `CHECK` para evitar outra migração.

### P1.3 Cancelamento pelo participante (detalhe completo)

#### Regras de negócio

| Regra | Decisão |
|---|---|
| Quem pode cancelar | O dono da inscrição: `user_id` igual ao da sessão **ou** e-mail da sessão confirmado igual ao da inscrição. |
| Quando | Até à data do evento (comparação por dia); depois disso, recusar (`event_started`). |
| Se já compareceu | Recusar (`attended`); presença é registo de operação. |
| Se já cancelada | Sucesso idempotente (`already_cancelled`), sem alterar dados. |
| Vaga | Libertada imediatamente; a próxima inscrição pode ocupá-la. |
| Reinscrição | Permitida: o índice parcial deixa criar nova linha `confirmada`. |
| Histórico | A linha cancelada mantém-se; a UI mostra-a como histórico (ou esconde-a da lista activa). |
| Admin | Pode cancelar qualquer inscrição, com motivo obrigatório; mesma RPC, `p_actor` = admin. |

#### RPC

```sql
-- 300_cancel_inscription.sql
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
  v_email text;
  v_status text;
  v_attended boolean;
  v_date date;
  v_promoted bigint;
begin
  select i.evento_id, i.email, i.status, i.compareceu
    into v_event, v_email, v_status, v_attended
  from inscricoes i
  where i.id::text = p_id
  for update;

  if not found then
    return query select 'not_found'::text, null::text;
    return;
  end if;

  if not p_is_admin
     and lower(trim(coalesce(v_email, ''))) <> lower(trim(coalesce(p_email, ''))) then
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

  -- Mesma ordem de locks da inscrição: events -> inscricoes.
  select e.date into v_date from events e where e.id = v_event for update;

  if v_date is not null and v_date < current_date then
    return query select 'event_started'::text, null::text;
    return;
  end if;

  update inscricoes
  set status = 'cancelada',
      cancelada_em = now(),
      cancelada_por = p_actor,
      motivo_cancelamento = nullif(trim(coalesce(p_motivo, '')), '')
  where id::text = p_id;

  -- Promoção de lista de espera (se existir)
  select i.id into v_promoted
  from inscricoes i
  where i.evento_id = v_event and i.status = 'lista_espera'
  order by i.created_at
  limit 1
  for update skip locked;

  if v_promoted is not null then
    update inscricoes set status = 'confirmada' where id = v_promoted;
  end if;

  return query select 'ok'::text, v_promoted::text;
end;
$$;

revoke all on function public.cancel_inscription(text, text, uuid, text, boolean)
  from public, anon, authenticated;
grant execute on function public.cancel_inscription(text, text, uuid, text, boolean)
  to service_role;
```

> O `UPDATE` acontece depois do lock do evento para manter a ordem `events` → `inscricoes`.

Notas:

- `p_id text` acomoda `bigint` e UUID legado; o custo do cast é irrelevante nesta tabela.
- A verificação de e-mail dentro da RPC é defesa em profundidade: a autorização principal continua na Server Action, que é quem conhece a sessão.
- `current_date` é UTC. A Server Action já compara a data local; manter as duas verificações (a da action dá a mensagem certa, a da RPC protege contra chamadas directas).
- `p_is_admin` só pode ser `true` quando a Server Action confirmou o papel; a RPC é service-role, por isso a flag é confiável apenas nesse contexto.
- A promoção respeita a capacidade porque acabou de sair uma confirmada. Se no futuro a promoção for automática por aumento de capacidade, aí também tem de entrar o lock e o `COUNT`.

#### Server Action

`lib/actions/account.js` — `cancelarInscricao`:

```js
const { data, error } = await admin.rpc('cancel_inscription', {
  p_id: id,
  p_email: user.email,
  p_actor: user.id,
  p_motivo: null,
  p_is_admin: false,
})

const code = data?.[0]?.code
if (error) return { ok: false, error: 'FALHOU' }
if (code === 'not_found') return { ok: false, error: 'NAO_ENCONTRADA' }
if (code === 'forbidden') return { ok: false, error: 'SEM_PERMISSAO' }
if (code === 'attended') return { ok: false, error: 'JA_DECORREU' }
if (code === 'event_started') return { ok: false, error: 'JA_DECORREU' }
if (code !== 'ok' && code !== 'already_cancelled') {
  return { ok: false, error: 'FALHOU' }
}

revalidatePath('/perfil/eventos')
after(() => sendCancellationEmail(...))
return { ok: true }
```

- Remove o `SELECT` da inscrição e o `DELETE`; mantém a validação de formato do id, a sessão e o `email_confirmed_at`.
- `after()` garante que o email sai depois da resposta ([Next.js `after`](https://nextjs.org/docs/app/api-reference/functions/after)).
- `already_cancelled` devolve sucesso: duplo clique não é erro.

#### UI

`components/account/CancelInscriptionButton.jsx`:

- manter `useActionState`;
- mensagem de sucesso “Inscrição cancelada. A vaga foi libertada.”;
- em `already_cancelled`, tratar como sucesso e refrescar;
- remover o `window.confirm` ou substituir por confirmação inline consistente com o design system (opcional, mas o texto actual “não pode ser desfeita” deixa de ser verdade — passa a haver histórico e reinscrição).

`lib/account-inscricoes.js` — `loadInscricoes`:

- por omissão, `select` continua o mesmo mas a página filtra `status !== 'cancelada'` para a lista activa;
- a página `/perfil/eventos` pode mostrar uma secção “Canceladas” (histórico) com `cancelada_em`;
- `COLUNAS` passa a incluir `status`, `cancelada_em`.

#### Reinscrição

- O formulário público continua a funcionar; o índice parcial permite nova linha.
- A RPC de duplicados ignora canceladas (`status <> 'cancelada'`).
- `loadInscricoes` pode devolver duas linhas para o mesmo evento (uma cancelada, uma confirmada) — a UI deve mostrar apenas a confirmada na lista activa.

#### Casos-limite

| Caso | Resultado |
|---|---|
| Duplo clique / duplo submit | `ok` e `already_cancelled`; nenhum efeito duplicado. |
| Cancelar inscrição de outra pessoa | `forbidden`. |
| Cancelar no dia do evento | Permitido (`date >= current_date`); depois do dia, `event_started`. |
| Cancelar depois de `compareceu = true` | `attended`. |
| Cancelar e voltar a inscrever | Permitido; nova linha `confirmada`, nova vaga ocupada. |
| Evento entretanto despublicado/arquivado | A RPC de cancelamento não exige `published`; o participante deve poder cancelar. |
| Capacidade reduzida abaixo do count e depois um cancelamento | Vaga libertada, mas o evento continua acima do limite; o trigger não é reavaliado no cancelamento (só em `UPDATE capacity`). Estado transitório aceitável; a UI mostra 0 vagas. |

### P1.4 Gestão de inscritos no `/admin`

- `getAllInscricoesAdmin` devolve **DTO mínimo**: `id, nome, email_mascarado, evento_id, evento_titulo, created_at, compareceu, status`. Sem telefone, sem `share_code`, sem `certificado_token`.
- Paginação e filtro no servidor (`range`, `eq`, `ilike`), não no cliente.
- Export CSV por Route Handler autenticado (`/api/admin/inscricoes/export`), com `requireAdmin`.
- Botão “Cancelar inscrição” no admin → mesma RPC com `p_is_admin: true` e motivo obrigatório.
- Filtro por estado (confirmadas / canceladas / lista de espera) e contador por evento no cabeçalho.
- `marcarCompareceu` deixa de escrever `certificado_emitido_at`; presença e emissão são actos distintos.

### P1.5 Lista de espera (opcional, mas recomendada)

- Quando `event_full`, o formulário oferece “Entrar na lista de espera” → `INSERT` com `status = 'lista_espera'` (sem contar para a capacidade).
- Promoção automática no cancelamento (já prevista na RPC) e quando a capacidade aumenta (na RPC `set_event_capacity`, promovendo por ordem de chegada até ao novo limite).
- Email ao promovido com prazo para confirmar; se não confirmar, volta a promover o seguinte. Isto exige `status = 'convocado'` ou um `promovido_em` — deixar para uma fase seguinte se o volume não justificar.

### P1.6 Email e contagem

- `send-inscription-email` e o novo `send-cancellation-email` chamados com `after()`.
- Contagem pública: Route Handler `GET /api/events/[id]/capacity` com `Cache-Control: public, s-maxage=10, stale-while-revalidate=30`, em vez da Server Action a cada 30 s por visitante. Alternativa: view pública `event_capacity` + Realtime, sem expor `inscricoes`.
- A Edge `validate-inscription` passa a receber `evento_id`, conta por id e trata `capacity = null` como ilimitado.

### P1.7 `user_id` e reivindicação de inscrições

- A RPC passa a gravar `user_id` no `INSERT` quando há sessão (via `p_form`).
- `reclamarInscricoes` continua a fazer backfill por e-mail antes de mudar o endereço.
- `loadInscricoes` já lê por `user_id` e por e-mails da conta; com `status`, filtrar canceladas na lista activa.

---

## 6. P2 — Robustez

1. **Concorrência optimista na edição do evento.** `updateEvent` reescreve todos os campos; dois admins perdem alterações. Adicionar `updated_at` e `where updated_at = $esperado`, devolvendo `conflict`.
2. **Testes de concorrência automatizados.** Script com `Promise.all` de 20 submissões contra staging + `psql` em duas sessões para validar o lock; ver §9.
3. **Testes de contrato das RPCs.** Casos: capacidade nula, zero, negativa, cheia, duplicado, cancelada, menor sem consentimento, `unique_violation`.
4. **Observabilidade.** Contadores `event_full`, `duplicate`, `db_insert_error`, `cancel_ok`, `cancel_forbidden`; alerta se `count > capacity` (só possível por SQL manual antes do trigger) e se um evento publicado tiver `capacity is null` quando a política for “obrigatória”.
5. **`statement_timeout` e `idle_in_transaction_session_timeout`** no projecto, para que um lock acidental não bloqueie inscrições.
6. **Documentação operacional.** Runbook: como inspecionar locks (`pg_stat_activity`, `pg_blocking_pids()`), como reverter capacidade, como cancelar em massa.
7. **Backups/restauro.** Antes de aplicar 295 (mudança de índice único), confirmar que o PITR está activo.

---

## 7. Modelo de dados final (resumo)

```
events
  capacity int NULL CHECK (capacity > 0)     -- NULL = ilimitado
  1 ─── n inscricoes

inscricoes
  id            bigint (legado: uuid)
  evento_id     uuid
  email         text
  status        text  'confirmada' | 'cancelada' | 'lista_espera'
  cancelada_em  timestamptz
  cancelada_por uuid
  motivo_cancelamento text
  user_id       uuid NULL
  municipio     text NULL
  compareceu    boolean
  share_code    text
  certificado_token text

índices
  unique (evento_id, lower(email)) WHERE status <> 'cancelada'
  (evento_id, status)
```

---

## 8. Ordem de migrações e rollout

| Ordem | Ficheiro | Conteúdo | Compatibilidade |
|---|---|---|---|
| 1 | `295_inscricoes_status_e_capacity_check.sql` | `status`, colunas de cancelamento, índice parcial, check de capacidade | Retrocompatível (`default 'confirmada'`) |
| 2 | `296_submit_inscription_v3.sql` | Nova RPC com `RETURNING`, `FOUND`, `unique_violation` | Aditiva; a antiga mantém-se |
| 3 | `297_set_event_capacity.sql` | RPC de capacidade com `force` | Aditiva |
| 4 | `298_guard_event_capacity.sql` | Trigger de invariante | Requer 295 |
| 5 | `299_rls_inscricoes_fechar_anon.sql` | Revoga `INSERT` de `anon`/`authenticated` | Só depois de o código usar service role (já usa) |
| 6 | `300_cancel_inscription.sql` | RPC de cancelamento | Aditiva |

**Deploy do código, na mesma janela:**

1. `lib/actions/inscription.js` passa a chamar `submit_inscription_v3` e remove o `SELECT`/`UPDATE` posteriores.
2. `lib/actions/content.js` usa `set_event_capacity` e regista auditoria.
3. `lib/actions/account.js` usa `cancel_inscription`.
4. `EventForm.jsx`, `InscritosListPage.jsx`, `CancelInscriptionButton.jsx` e `loadInscricoes` actualizados.

**Rollback:** manter `submit_inscription_safe` (v2) durante uma release. Se for preciso reverter, o código antigo continua a funcionar; a coluna `status` tem default e o índice parcial aceita o fluxo antigo (que inseria sempre `confirmada`). A revogação de `INSERT` do `anon` (299) é a única alteração que exige reverter a política se o formulário antigo for restaurado.

**Antes de 295:** confirmar que não existem duplicados activos que impeçam a criação do índice parcial:

```sql
select evento_id, lower(email), count(*)
from inscricoes
group by 1, 2
having count(*) > 1;
```

---

## 9. Testes

### 9.1 Concorrência (staging)

```js
// 20 submissões simultâneas para a última vaga
const results = await Promise.all(
  Array.from({ length: 20 }, (_, i) =>
    fetch('/api/test/inscription', { method: 'POST', body: JSON.stringify({ ...dados, email: `t${i}@x.pt` }) })
      .then(r => r.json())
  )
)
const ok = results.filter(r => r.code === 'ok').length
// expectativa: ok === vagas disponíveis; restantes event_full
```

- Repetir com o mesmo e-mail em todas: exactamente uma `ok`, restantes `duplicate`.
- Correr com `capacity = 1`, `capacity = null` e `capacity = 0` (deve falhar na escrita).

### 9.2 Cancelamento

| Teste | Esperado |
|---|---|
| Cancelar própria inscrição | `ok`; `status = cancelada`; count desce 1 |
| Cancelar duas vezes | segunda `already_cancelled`; count inalterado |
| Cancelar com e-mail de outra conta | `forbidden`; nada alterado |
| Cancelar após `compareceu = true` | `attended` |
| Cancelar após a data | `event_started` |
| Cancelar e reinscrever | nova linha `confirmada`; índice parcial permite |
| Cancelar admin | `ok` com `p_is_admin: true` e motivo |
| Cancelar com lista de espera | primeiro promovido; count mantém-se |

### 9.3 Capacidade

| Teste | Esperado |
|---|---|
| Aumentar 50 → 100 | `ok` |
| Reduzir 100 → 50 sem `force` (80 inscritos) | `below_count`, count 80, nada alterado |
| Reduzir com `force` | `ok`, evento fechado |
| `capacity = null` | inscrições aceites |
| `capacity = 0` / negativo | `invalid_capacity` |
| Reduzir em simultâneo com inscrição | serializa; nunca `count > capacity` |
| `UPDATE` manual abaixo do count | trigger `23514` |

---

## 10. Critérios de aceitação

- [ ] Evento com `capacity` nula aceita inscrições (tratado como ilimitado).
- [ ] Evento cheio devolve `event_full`; duplicado devolve `duplicate`; nunca `db_insert_error` por `23505`.
- [ ] 20 submissões concorrentes na última vaga produzem exactamente uma `ok`.
- [ ] A RPC devolve `id` e `share_code`; não há `SELECT`/`UPDATE` posteriores no caller.
- [ ] O `anon` já não consegue inserir em `inscricoes` directamente.
- [ ] Editar capacidade mostra inscritos/vagas, avisa e pede confirmação abaixo do count.
- [ ] Reduzir abaixo do count sem `force` é recusado; com `force` é auditado.
- [ ] Trigger impede `count > capacity` mesmo por SQL manual.
- [ ] Cancelar inscrição própria grava `status`, `cancelada_em`, `cancelada_por`, liberta vaga e revalida `/perfil/eventos`.
- [ ] Cancelar duas vezes é idempotente.
- [ ] Cancelar inscrição de outra pessoa é recusado.
- [ ] É possível reinscrever-se depois de cancelar.
- [ ] A lista de inscritos do admin não envia telefone, `share_code` nem `certificado_token` ao browser.
- [ ] `marcarCompareceu` não emite certificado.
- [ ] Email de confirmação e de cancelamento usam `after()`.
- [ ] Auditoria regista capacidade antiga/nova, inscritos, autor e motivo.

---

## 11. Riscos e não-objectivos

**Riscos**

- `CREATE INDEX` numa tabela grande bloqueia escritas; `inscricoes` é pequena, mas confirmar o tamanho antes. Em produção com muito volume, criar o índice fora de transacção (`CONCURRENTLY`) num passo separado.
- A mudança do índice único pode falhar se existirem duplicados activos; correr a query de verificação antes.
- A RPC de cancelamento com `p_is_admin` confia na flag; só pode ser chamada por service role, que já é o caso.
- A comparação de datas é feita em UTC na RPC e em hora local na action; documentar e testar a fronteira da meia-noite.

**Não-objectivos**

- Sistema de bilhética ou pagamentos.
- Check-in por QR code.
- Reescrever a Edge Function ou removê-la nesta fase (passa a ser pré-validação, não autoridade).
- Migrar `inscricoes.id` de `bigint` para `uuid`.

---

## 12. Referências oficiais

- Next.js — *How to think about data security*: Server Actions são endpoints POST; autorização dentro de cada acção; DTOs mínimos; DAL server-only. <https://nextjs.org/docs/app/guides/data-security>
- Next.js — *`after`*: agendar trabalho após a resposta (email, logging). <https://nextjs.org/docs/app/api-reference/functions/after>
- Next.js — *Revalidating*: `revalidatePath`/`updateTag` depois de mutações. <https://nextjs.org/docs/app/getting-started/revalidating>
- Supabase — *Securing your API*: grants + RLS; `service_role` só no servidor; funções recebem `EXECUTE` de `PUBLIC` por omissão e devem ser revogadas. <https://supabase.com/docs/guides/api/securing-your-api>
- Supabase — *Row Level Security*. <https://supabase.com/docs/guides/database/postgres/row-level-security>
- Supabase — *Connection management*: locks em transacções abertas, `idle in transaction`, diagnóstico com `pg_blocking_pids()`. <https://supabase.com/docs/guides/database/connection-management>
- PostgreSQL — *Explicit Locking*: `FOR UPDATE`, locks de linha e conflitos. <https://www.postgresql.org/docs/current/explicit-locking.html>
- PostgreSQL — *Transaction Isolation*: `READ COMMITTED` e visibilidade de linhas não commitadas. <https://www.postgresql.org/docs/current/transaction-iso.html>
