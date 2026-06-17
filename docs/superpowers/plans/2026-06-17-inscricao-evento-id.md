# 2026-06-17 — InscricaoPage por evento_id (slug→UUID) + getEventInscriptionCount Service Role

## Objectivo

Resolver dois bugs relacionados que bloqueiam utilizadores EN/PT na página de inscrição:

1. **Bug EN/PT (detail page)**: `/eventos/[slug]` e `/events/[slug]` mostram "25 de 25" (ou outro valor total) em **PT e EN**. Causa: `getEventInscriptionCount` e `useCapacityPolling` chamam `from('inscricoes')` com o client **user-scoped** (RLS bloqueia SELECT para `anon`) → `error: {}` → silenciosamente devolve `0`. O detalhe da `/eventos` lista aparece correcto porque usa o RPC `get_events_with_inscription_counts` (público, com SECURITY DEFINER).

2. **Bug EN (inscrição)**: User clica "Inscrever-me" em `/en/events/[en-slug]` → `RegistrationButton` envia `?evento=<en-slug>` → `register/page.js` chama `getEventBySlug(evento)` **sem lang** → cai no lookup PT (`events.slug`) → `null` → mostra "Nenhum evento seleccionado" (InscricaoPageClient:128-152).

**Root cause comum**: o slug dos eventos é **traduzível** (PT em `events.slug`, EN em `event_translations.slug`), mas o `RegistrationButton` propaga o slug da lang actual e o client Supabase de utilizador anónimo não tem RLS de leitura em `inscricoes`.

**Fixes**:
- (A) `getEventInscriptionCount` muda para `createAdminClient` (Service Role) — Service Role bypassa RLS, devolve só `count` (não-PII, já exposto na UI).
- (B) `RegistrationButton` propaga `eventId` (UUID) em vez de slug. URL `?eventoId=<UUID>`. `InscricaoPage` resolve internamente para title/capacity/PT-slug (link canónico estável). Fallback para `?evento=<slug>` (legacy) preserva bookmarks antigos.

## Decisões locked-in (2026-06-17)

- **Contract URL**: `?eventoId=<UUID>` preferencial; `?evento=<slug>` fallback. Slug na URL = **sempre PT canónico** (resolve o problema de partilha entre línguas).
- **getEventInscriptionCount**: usa `createAdminClient()` (Service Role) — segue o mesmo padrão do RPC público `get_events_with_inscription_counts`. Não expõe PII (apenas count).
- **useCapacityPolling**: continua a usar `createBrowserClient` (browser) — manter client-side polling. **Mas**: precisa de bypass RLS para a contagem funcionar. Opção: também muda para `createAdminClient` (inseguro se exposto) — **NÃO**. Solução: Server Action (`apiGetEventCount`) que corre com Service Role no servidor e devolve só o count ao browser. Aplica o pattern `Use Server Action for Browser to Server Capability`.
- **Edge Function `validate-inscription`**: recebe slug como contract externo (estável), mas o slug enviado é sempre o PT canónico resolvido server-side.
- ## Mudança de scope (2026-06-17, 2.ª sessão)

**Bug adicional reportado**: `submitInscription` no browser falha com `error: {}` em `lib/api/inscription.js:121` (insert em `inscricoes`). Email de confirmação nunca dispara. Investigação: mesma classe de problema que o count (anon INSERT via browser client + Edge Function CORS allowlist fixa em `supabase/functions/validate-inscription/index.ts:5-8` que pode rejeitar o domínio actual de produção `conhecafarmacia.com`). Como o user escolheu a opção "Server Action + Service Role" via AskUserQuestion, este plano é estendido para incluir a `apiSubmitInscription`.

**Edge Function CORS check (audit 2026-06-17)**: `ALLOWED_ORIGINS` em `supabase/functions/validate-inscription/index.ts:5-8` = `['https://conheca-farmacia-next.vercel.app', 'http://localhost:3000']`. Se o domínio activo for diferente (após migração para `conhecafarmacia.com` — ver memory `email-templates-domain-migration`), o browser faz preflight OK mas a response é bloqueada por CORS mismatch → `response.json()` lança silenciosamente. Mesmo mover para Server Action **resolve CORS** porque a chamada passa a ser server-to-server (Authorization: Bearer service_role_key).

## Ficheiros a alterar (6)

| Ficheiro | Mudança |
|---|---|
| `lib/api/events.js` | `getEventInscriptionCount` → `createAdminClient` |
| `lib/actions/inscription.js` (novo) | Server Action `apiGetEventInscriptionCount(eventId)` para o polling browser → Service Role |
| `hooks/useCapacityPolling.js` | Chamar a Server Action em vez de `supabase.from('inscricoes')` directo |
| `app/[lang]/(public)/inscricao/page.js` | `searchParams.eventoId` preferencial; `?evento` fallback; resolve title/capacity server-side |
| `app/[lang]/(public)/register/page.js` | Mesmo |
| `components/content/RegistrationButton.jsx` | Prop `eventId` em vez de `eventSlug`; URL `?eventoId=<UUID>` |
| `app/[lang]/(public)/eventos/[slug]/page.js` | `eventId={event.id}` no `RegistrationButton` (passa a ser o contract) |
| `app/[lang]/(public)/events/[slug]/page.js` | Mesmo (mirror EN) |
| `components/pages/InscricaoPageClient.jsx` | Prop `eventoId` em vez de `eventoSlug`; chama `submitInscription(form, eventoId)` |
| `lib/api/inscription.js` | `submitInscription(form, eventoId)` — recebe ID directamente, sem lookup |
| `lib/actions/inscription.js` (estendido) | **NOVO**: `apiSubmitInscription(form, eventoId, eventoSlug)` — Server Action que corre Edge Function server-to-server + INSERT via Service Role + email fire-and-forget |
| `components/pages/InscricaoPageClient.jsx` (estendido) | `submitInscription` agora vem de `@/lib/actions/inscription` (Server Action) em vez de `@/lib/api/inscription` (client-side) |

## Detalhes das mudanças

### 1. `lib/api/events.js` → `getEventInscriptionCount` (Server Side)

**Antes**:
```js
export async function getEventInscriptionCount(eventId) {
  if (!eventId) return 0
  const supabase = await createClient()  // RLS bloqueia anon
  const { count, error } = await supabase
    .from('inscricoes')
    .select('*', { count: 'exact', head: true })
    .eq('evento_id', eventId)
  if (error) { console.error(...); return 0 }
  return count || 0
}
```

**Depois**:
```js
import { createClient } from '@/lib/supabase/admin'  // Service Role

export async function getEventInscriptionCount(eventId) {
  if (!eventId) return 0
  const supabase = createClient()  // Service Role, bypassa RLS
  const { count, error } = await supabase
    .from('inscricoes')
    .select('*', { count: 'exact', head: true })
    .eq('evento_id', eventId)
  if (error) { console.error(...); return 0 }
  return count || 0
}
```

**Justificação segurança** (auditada contra `SECURITY_GUIDELINES.md` SEC-ATH-04 / SEC-SQL-01):
- Service Role devolve apenas `count` (inteiro), não rows.
- Count é metadata pública já visível na UI (CapacityBar mostra "X/Y").
- RPC `get_events_with_inscription_counts` (público) já faz o mesmo.
- RLS protege **PII** (nome, email, telefone); count agregado não é PII.

### 2. `lib/actions/inscription.js` (novo — Server Action para polling)

**Padrão**: Server Action `apiGetEventInscriptionCount` que corre no servidor com `createAdminClient` e devolve só `{ count }` ao browser. O browser **nunca** toca em `inscricoes` directamente.

```js
'use server'
import { createClient } from '@/lib/supabase/admin'
import { requireRateLimit } from '@/lib/security/rate-limit'  // ver audit §3

export async function apiGetEventInscriptionCount(eventId) {
  if (!eventId || typeof eventId !== 'string') {
    throw new Error('Invalid eventId')
  }
  // Rate limit por IP — ver audit §3 (prevenir abuse de polling 30s)
  await requireRateLimit('polling', { max: 120, window: '1m' })  // 120 req/min ≈ polling 30s + margem

  const supabase = createClient()
  const { count, error } = await supabase
    .from('inscricoes')
    .select('*', { count: 'exact', head: true })
    .eq('evento_id', eventId)
  if (error) throw new Error('Count query failed')
  return { count: count || 0 }
}
```

### 3. `hooks/useCapacityPolling.js` (chamada via Server Action)

**Antes**: linha 25-29 chamava `supabase.from('inscricoes')` no browser com RLS.

**Depois**:
```js
import { apiGetEventInscriptionCount } from '@/lib/actions/inscription'

const fetchCount = useCallback(async () => {
  if (!eventId) return
  try {
    setLoading(true)
    const { count } = await apiGetEventInscriptionCount(eventId)
    setInscriptionCount(count || 0)
    intervalRef.current = INITIAL_INTERVAL
    retriesRef.current = 0
  } catch {
    // backoff exponencial (existente)
  } finally {
    setLoading(false)
  }
}, [eventId])
```

**Justificação segurança**: o browser nunca vê o Service Role key. Server Action corre server-side e devolve só o count. O RLS continua a proteger PII — Service Role só lê `count` (não linhas).

### 4. `components/content/RegistrationButton.jsx`

**Antes** (linha 12, 41):
```jsx
export default function RegistrationButton({ eventSlug, capacity, initialCount = 0, isPast, lang }) {
  // ...
  return <Link href={`/${lang}/inscricao?evento=${eventSlug}`} ...>
```

**Depois**:
```jsx
export default function RegistrationButton({ eventId, capacity, initialCount = 0, isPast, lang }) {
  // ...
  return <Link href={`/${lang}/inscricao?eventoId=${eventId}`} ...>
```

> **Nota**: `lang` ainda é necessário para a URL (`/pt/inscricao` vs `/en/register`). O component mantém o prop.

### 5. `app/[lang]/(public)/inscricao/page.js` + `register/page.js`

**Antes** (linha 23, 31):
```js
const { evento } = await searchParams
// ...
if (evento) {
  const event = await getEventBySlug(evento)  // sem lang → cai no PT
  // ...
  initialCount = await getEventInscriptionCount(event.slug)  // propaga bug
}
```

**Depois** (slug canónico PT na URL, ID como contract interno):
```js
const { eventoId, evento } = await searchParams

let event = null
if (eventoId) {
  // Caminho novo: ?eventoId=<UUID> (preferencial)
  const supabase = await createClient()
  const { data } = await supabase
    .from('events')
    .select('id, slug, title, capacity')
    .eq('id', eventoId)
    .eq('status', 'published')
    .eq('is_archived', false)
    .single()
  event = data
} else if (evento) {
  // Fallback legacy: ?evento=<slug> (PT canónico, retro-compat)
  event = await getEventBySlug(evento, 'pt')
}

if (event) {
  eventTitle = event.title
  capacity = event.capacity || null
  // passa eventoId (UUID) para o client; InscricaoPageClient usa para submit + lookup
  initialCount = await getEventInscriptionCount(event.id)
}

return (
  <InscricaoPageClient
    lang={safeLang}
    eventoId={event?.id || null}        // antes: eventoSlug
    eventoSlug={event?.slug || null}    // novo: para breadcrumb back-link
    eventTitle={eventTitle}
    capacity={capacity}
    initialInscriptionCount={initialCount}
  />
)
```

> **Por que `createClient` (user-scoped) no lookup `events`**: a tabela `events` é **pública** (RLS permite SELECT para `anon` se `status='published' AND is_archived=false`). O Service Role não é necessário aqui. Mantém o padrão actual.

### 6. `components/pages/InscricaoPageClient.jsx`

**Mudanças**:
- Prop `eventoSlug` → `eventoId` (linha 13, 20, 44, 107, 159, 306)
- `useCapacityPolling(eventoId, initialInscriptionCount)` (era `eventoSlug`)
- `submitInscription(form, eventoId)` (linha 107)
- Breadcrumb link back: usa `eventoSlug` (PT canónico) em vez de `eventoId` — mais legível
- Hidden input linha 306: `<input type="hidden" name="evento_slug" value={eventoSlug || ''} />` → `<input type="hidden" name="evento_id" value={eventoId || ''} />`

### 7. `lib/api/inscription.js` → `submitInscription`

**Antes** (linhas 64-76): lookup UUID a partir do slug.

**Depois**: recebe `eventoId` directamente. Lookup removido.
```js
export async function submitInscription(formData, eventoId) {
  if (!eventoId) {
    throw new Error('eventoId é obrigatório')
  }
  // ... resto do código igual, mas usa eventoId directamente
  // ... Edge Function recebe eventoSlug resolvido server-side (passado pelo InscricaoPage parent)
}
```

> **Sub-questão**: Edge Function `validate-inscription` ainda recebe `evento_slug`. Manter contract — InscricaoPage resolve `event.id` → `event.slug` (PT canónico) e passa ambos ao client.

## Auditoria contra `SECURITY_GUIDELINES.md` (2026-06-17)

Verificadas todas as secções relevantes:

| Sec | Regra | Aplicação | Status |
|---|---|---|---|
| SEC-AM-01 | Sem IP/ports/stack em HTML | Não aplicável | ✓ |
| SEC-AM-02 | Env vars em Vercel/local | Service Role key em env var (não no client) | ✓ |
| SEC-ATH-01 | 3 clients Supabase scopes | `admin.js` adicionado ao scope Server (browser nunca importa) | ✓ |
| SEC-ATH-02 | `createAdminClient` em `lib/supabase/admin.js` com `SUPABASE_SERVICE_ROLE_KEY` | Usado em `getEventInscriptionCount` + `apiGetEventInscriptionCount` | ✓ |
| SEC-ATH-03 | Nunca passar Service Role ao client | **BLOQUEADO**: `apiGetEventInscriptionCount` é Server Action; browser chama via RPC, não vê a key | ✓ |
| SEC-ATH-04 | RLS protege PII | Count agregado não é PII; SELECT real continua bloqueado para anon | ✓ |
| SEC-FORM-01 | Honeypot | InscricaoPageClient mantém honeypot (linha 294-303) | ✓ |
| SEC-FORM-02 | Rate limit submit | `RATE_LIMIT_MS = 5000` existente (linha 11) | ✓ |
| SEC-FORM-03 | Sanitização | `validateField` mantém XSS check (inscription.js:31) | ✓ |
| **NOVO** | **Rate limit polling** | Server Action `apiGetEventInscriptionCount` precisa de rate limit por IP (prevenir abuse de polling). Ver audit §3 abaixo | ⚠ adicionar |
| SEC-SQL-01 | Não expor PII via SQL directo | Count é não-PII; SELECT rows continua protegido por RLS; INSERT em `inscricoes` via Service Role **não expõe PII a terceiros** — só à própria DB (escrita, não leitura) | ✓ |
| SEC-OPT-01 | Cache control admin | Não aplicável (rota pública) | ✓ |
| **NOVO** | **CORS Edge Function** | `apiSubmitInscription` chama Edge Function server-to-server com `Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}` — bypass completo do CORS allowlist do browser. Edge Function não recebe CORS do origin do user. | ✓ |
| **NOVO** | **Service Role INSERT PII** | INSERT em `inscricoes` (que tem nome, email, telefone = PII) via Service Role é seguro **porque**: (1) PII vem do próprio utilizador via form, (2) o Service Role **grava** na DB mas **não devolve PII ao browser** — `select('id')` apenas; (3) RLS continua a bloquear leitura directa por anon, mantendo PII protegida. Mesmo padrão já é usado no RPC `get_events_with_inscription_counts` (SECURITY DEFINER). | ✓ |
| **NOVO** | **Edge Function CORS allowlist outdated** | Allowlist em `supabase/functions/validate-inscription/index.ts:5-8` exclui o domínio actual `conhecafarmacia.com` (verificado na memory `email-templates-domain-migration`). Mover para Server Action resolve sem mexer na Edge Function. **Decisão**: NÃO editar Edge Function neste plano — Server Action cobre o caso. Edge Function fica como defence-in-depth (apenas aceita domínios conhecidos). | ✓ |

### §3 — Rate limit polling (gap identificado na auditoria)

**Problema**: `useCapacityPolling` faz 1 request a cada 30s por aba. 10 abas abertas × 2min = 20 req/min. Sem rate limit, atacante pode abrir 1000 tabs e forçar 1000 count queries (cada uma = Service Role query ao Supabase, ainda que `head: true`).

**Auditoria 2026-06-17**:
- `lib/security/` **não existe** no projecto.
- `lib/actions/translation.js` tem rate limit via RPC atómico `check_and_increment_translation_quota` (Postgres) — overkill para polling.
- Vercel/Cloudflare têm rate limit built-in (ver `vercel.json` / proxy.js) — sem código novo necessário.

**Decisão final**: **rate limit in-memory simples em `lib/actions/inscription.js`** (não criar `lib/security/` separado, não criar migration nova). Padrão:

```js
// Top of lib/actions/inscription.js
const _rateMap = new Map()  // IP -> { count, resetAt }
const POLL_LIMIT = { max: 120, windowMs: 60_000 }  // 120 req/min/IP

function checkPollRate(ip) {
  const now = Date.now()
  const entry = _rateMap.get(ip)
  if (!entry || entry.resetAt < now) {
    _rateMap.set(ip, { count: 1, resetAt: now + POLL_LIMIT.windowMs })
    return true
  }
  if (entry.count >= POLL_LIMIT.max) return false
  entry.count += 1
  return true
}
```

**Limites**:
- 120 req/min/IP = 2 req/s = cobre 1 tab em 30s + 1 tab em 30s = OK
- 1000 tabs = 1000 req/30s = 2000 req/min → BLOQUEADO (passa 120 req/min)
- Limpeza: TTL automático via `entry.resetAt` (lazy GC no próximo request)

**Não usar para**:
- `submitInscription` (tem rate limit próprio de 5s entre submits — InscricaoPageClient:11)
- Outras Server Actions

**Tarefas adicionais**:
- Implementar `checkPollRate` em `lib/actions/inscription.js` (não criar ficheiro novo)
- Passar IP via `headers()` do Next.js 16 (já há precedente em outras Server Actions)

## Riscos e mitigações

| Risco | Mitigação |
|---|---|
| `getEventInscriptionCount` agora é Service Role — se for chamado de contexto público, depende da hygiene do input (eventId é UUID, validado por `if (!eventId) return 0`) | Já validado. Adicionar check `typeof eventId !== 'string' \|\| !UUID_REGEX.test(eventId)` |
| URL `?eventoId=<UUID>` é partilhável — visitor vê URL com UUID feio | Aceitável — é o contract interno; breadcrumb e back-link usam slug PT |
| Bookmarks antigos com `?evento=<pt-slug>` partilhados em EN continuam a funcionar (resolvem para PT) | Sim — fallback `getEventBySlug(evento, 'pt')` cobre |
| Bookmarks antigos com `?evento=<en-slug>` partilhados em EN **partem-se** | Aceitável — user pediu "slug PT canónico na URL" |
| Edge Function `validate-inscription` recebe slug em vez de ID | Manter contract — slug é estável para API externa, ID é interno |

## Plano de testes (após aplicar)

1. `/pt/eventos/congresso-farmacia-2026` → CapacityBar deve mostrar "X vagas disponíveis de 25" com X = contagem real de `inscricoes`
2. `/en/events/congresso-pharmacy-2026` (slug EN) → mesmo comportamento (EN detail page)
3. `/pt/eventos/uso-racional-medicamentos` → clicar "Inscrever-me" → `/pt/inscricao?eventoId=<UUID>` → InscricaoPageClient deve mostrar form com título correcto
4. `/en/events/uso-racional-medicamentos` → clicar "Inscrever-me" → `/en/register?eventoId=<UUID>` → mesmo
5. Submeter inscrição em EN com email novo → `submitInscription` deve inserir com `evento_id = <UUID>` (validar com `scripts-verify-db.mjs` ou equivalente)
6. Smoke rate limit: abrir DevTools, forçar 200 polling requests em 1 min → deve começar a falhar com 429 ou similar
7. Hard refresh em `/eventos/<slug>` → contagem mantém-se (não pisca para 0)
8. `npm run lint` em todos os ficheiros alterados

## Memory updates

- Adicionar entrada em `MEMORY.md`: "InscricaoPage ID-based 2026-06-17" — descreve o contract `?eventoId=<UUID>` + fallback slug, e o pattern `Server Action para browser→Service Role`.
- Atualizar `memory/project/inscricoes-evento-id-migration-024-2026-06-16.md` se relevante.

## Handoff doc

Este ficheiro é o plano E o handoff doc. Não criar ficheiro separado.

## Critérios de done

- [ ] `getEventInscriptionCount` retorna count real em PT e EN (validar com `scripts-verify-db.mjs`)
- [ ] `RegistrationButton` envia `?eventoId=<UUID>` em PT e EN
- [ ] `/pt/inscricao?eventoId=<UUID>` carrega título do evento correctamente
- [ ] `/en/register?eventoId=<UUID>` carrega título do evento correctamente
- [ ] Submissão de inscrição em EN grava `evento_id` correcto na DB
- [ ] Rate limit polling activo (testar com curl loop)
- [ ] `npm run lint` verde
- [ ] Build verde (`npm run build`) — opcional, user prefere dev server
- [ ] Audit contra SECURITY_GUIDELINES.md revista
- [ ] Memory `MEMORY.md` actualizado

---

## Apêndice — Error Handling i18n (2026-06-17, 2 commits)

Após deploy do plano principal, o utilizador reportou que erros de inscrição mostravam sempre a mesma mensagem genérica ("Não foi possível validar/submeter a inscrição") independentemente da causa real (email duplicado, evento cheio, rate limit, etc.). O WhatsApp CTA estava misturado com a mensagem, escondendo o motivo específico.

### Problema

`apiSubmitInscription` (Server Action) faz `throw new Error('Não foi possível validar a inscrição. Tenta novamente.')` em **todos** os caminhos de erro da Edge Function, perdendo o `error: "..."` descritivo que a Edge Function devolve. Resultado: 8+ cenários de erro colapsam no mesmo texto genérico no client.

### Solução em 2 commits

**Commit 1 — Telemetria/structured logging** (já aplicado, ainda não commitado):

- Adicionado `logInscriptionError(code, ctx)` no topo de `lib/actions/inscription.js`.
- Cada `throw` agora regista `[inscription.submit]` com `code` semântico + `emailHash` (não email raw) + `eventoId/slug` + `ts`.
- 11 códigos: `invalid_event_id | invalid_event_slug | rate_limited | misconfigured | validation_unreachable | event_not_found | event_full | validation_failed | duplicate | db_insert_error | db_insert_no_id`.
- **Sem mudança de UX** — strings de throw mantêm-se para backward-compat.
- **Objectivo**: confirmar em prod (via Vercel logs) quais categorias realmente ocorrem antes de assumir o mapping i18n.

**Commit 2 — i18n mapping de 8+ categorias** (já aplicado, ainda não commitado):

- Adicionado bloco `inscricao_error.codes` em `public/i18n/pt.json` e `en.json` (11 chaves cada).
- `InscricaoPageClient.jsx` catch refactorizado: parseia `err.message` (string legacy `'duplicate'` ou `JSON.stringify({code,detail})` futuro) e mapeia para `t('inscricao_error.codes.${code}')` com fallback para `t('inscricao_error.message')`.
- Backward-compat mantida: o formato legacy `'duplicate'` ainda funciona, e o client parseia JSON com segurança se o Server Action evoluir para emitir erros estruturados.

### Próximos passos opcionais (não bloqueantes)

- Migrar `apiSubmitInscription` para emitir `Error(JSON.stringify({code, detail}))` em todos os throws (mantém fallback legacy). Permite ao client mostrar a `detail` da Edge Function (ex: "Campo 'telefone' inválido") dentro da mensagem genérica.
- Adicionar 429 + 500 buckets separados em Vercel log drains para alertas automatizados.

### Ficheiros tocados (apêndice)

- `lib/actions/inscription.js` — adicionado `logInscriptionError`, `hashEmail`, instrumentação de 11 throws
- `components/pages/InscricaoPageClient.jsx` — catch refactorizado para mapear code → i18n
- `public/i18n/pt.json` — bloco `inscricao_error.codes` (11 entradas)
- `public/i18n/en.json` — bloco `inscricao_error.codes` (11 entradas)

