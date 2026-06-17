# 2026-06-16 — Inscricoes evento_id (slug→UUID FK fix)

## Objectivo

Resolver bug: `/en/events/[slug]` mostra "Available Spots" sempre a 100% porque `useCapacityPolling` filtra `inscricoes.evento_slug` mas o slug EN foi traduzido (divergente do PT base).

**Root cause**: 6/6 eventos EN têm `event_translations.slug` diferente de `events.slug`. Polling devolve sempre 0.

**Fix**: Introduzir `inscricoes.evento_id` (UUID FK para `events.id`) como source-of-truth. Mantém `evento_slug` legado por enquanto, mas write path passa a gravar **só** `evento_id` (user escolheu: "Remover evento_slug, só evento_id" no write). Read path filtra por `evento_id`.

## Auditoria pré-backfill (9 inscrições)

| Slug (inscricoes.evento_slug) | Count | Match | evento_id (UUID) |
|---|---|---|---|
| `uso-racional-medicamentos` | 4 | ✓ | `b3f81738-...` |
| `workshop-farmacocinetica` | 1 | ✓ | `160557c7-...` |
| `001-farmacologia-clinica` | 3 | ✗ órfão | `98ad7592-...` (farmacologia-clinica) |
| `004-congresso-farmacia` | 1 | ✗ órfão | `b9b18901-...` (congresso-farmacia-2026) |

**Resultado esperado após migration**: 9/9 com `evento_id`, 0 órfãos.

## Migration `024_inscricoes_evento_id.sql`

Localização: `supabase/migrations/024_inscricoes_evento_id.sql`

Conteúdo:
- `ALTER TABLE inscricoes ADD COLUMN evento_id UUID REFERENCES events(id) ON DELETE SET NULL`
- `UPDATE ... FROM events WHERE e.slug = i.evento_slug` (backfill automático)
- 2x `UPDATE` explícitos para os slugs órfãos (com os UUIDs da auditoria)
- `CREATE INDEX idx_inscricoes_evento_id ... WHERE evento_id IS NOT NULL` (partial index)
- Bloco `DO $$` para log de NULLs remanescentes

**Aplicar via Supabase Dashboard SQL Editor** (padrão já documentado em memory `user-splits-migration-and-push-parallel`).

Validar pós-apply:
```sql
SELECT COUNT(*) FROM inscricoes WHERE evento_id IS NULL;
-- esperado: 0
```

## Read path — mudanças

### `lib/api/events.js` → `getEventInscriptionCount`

**Antes**: recebe `slug`, query `.eq('evento_slug', slug)`.
**Depois**: recebe `eventId`, query `.eq('evento_id', eventId)`.

```js
// pseudo-código
export async function getEventInscriptionCount(eventId) {
  const { count } = await supabase
    .from('inscricoes')
    .select('*', { count: 'exact', head: true })
    .eq('evento_id', eventId)
  return count || 0
}
```

### `hooks/useCapacityPolling.js`

**Antes**: prop `eventSlug`, filtra `evento_slug`.
**Depois**: prop `eventId`, filtra `evento_id`.

```js
// pseudo-código
useEffect(() => {
  const fetch = async () => {
    const { count } = await supabase
      .from('inscricoes')
      .select('*', { count: 'exact', head: true })
      .eq('evento_id', eventId)
    setCount(count || 0)
  }
  // ...
}, [eventId])
```

### `app/[lang]/(public)/{eventos,events}/[slug]/page.js`

**Antes**: `<CapacityBar eventSlug={event.slug} initialCount={inscriptionCount} />`
**Depois**: `<CapacityBar eventId={event.id} initialCount={inscriptionCount} />`

E mudar a chamada `getEventInscriptionCount(event.slug)` → `getEventInscriptionCount(event.id)`.

### `components/content/CapacityBar.jsx`

Mudar prop `eventSlug` → `eventId` e passar ao hook.

## Write path — mudanças

### Onde gravar (formulário de inscrição /pt/inscricao)

A localizar:
- Edge Function `submit-inscricao` (?)
- Server Action `lib/actions/newsletter.js` (?)
- API route `/api/inscricao` (?)

**Antes**: payload inclui `evento_slug`.
**Depois**: payload inclui **só** `evento_id` (UUID). Lookup do UUID a partir do slug do form:
```js
// pseudo-código
const { data: ev } = await supabase.from('events').select('id').eq('slug', formEventSlug).single()
const evento_id = ev.id
await supabase.from('inscricoes').insert({ ..., evento_id })
```

**Não escrever `evento_slug`** — user decidiu "Remover evento_slug, só evento_id".

## Riscos & Mitigações

- **Schema migration falhar** (FK violations): pré-validate com `SELECT id FROM events` que os UUIDs hard-coded (`98ad7592-...`, `b9b18901-...`) ainda existem. Se alguém apagar esses eventos entretanto, o `UPDATE` falha com FK violation; ajustar antes.
- **Write path antigo grava `evento_slug`**: pode continuar a funcionar (coluna ainda existe), mas deixa de ser "source-of-truth". Backfill de novas inscrições que escrevem só slug → id requer actualizar todas as fontes em paralelo.
- **`useCapacityPolling` em ciclo**: id estável, polling mantém-se funcional.
- **Falta referência cruzada**: o slug pode ser útil para auditoria/reporting futuro. Considerar adicionar `evento_slug` como coluna gerada (`GENERATED ALWAYS AS (...) STORED`) — deferido para próxima iteração.

## Plano de execução

1. **User aplica migration 024 via Dashboard** (em paralelo com passo 2).
2. **Auditar pós-apply** (eu): `SELECT COUNT(*) FROM inscricoes WHERE evento_id IS NULL` → esperado 0.
3. **Actualizar `lib/api/events.js`** (`getEventInscriptionCount`) — 1 file.
4. **Actualizar `hooks/useCapacityPolling.js`** — 1 file.
5. **Actualizar `components/content/CapacityBar.jsx`** (prop rename) — 1 file.
6. **Actualizar `app/[lang]/(public)/eventos/[slug]/page.js`** + mirror EN — 2 files.
7. **Localizar write path de inscrição** — `grep -rn "evento_slug" lib/ supabase/`.
8. **Actualizar write path** — substituir `evento_slug` por `evento_id` com lookup.
9. **Testar**: criar inscrição em PT, confirmar que `evento_id` está gravado. Carregar `/en/events/<slug-en>`, confirmar barra actualizada.

## Detalhes da sessão

- **Reportado**: "Available Spots em /en/events/[id] está sempre a 100% mesmo com inscrições reais"
- **Investigação**: Phase 1 systematic-debugging + 2 scripts Node (`scripts-check-slug.mjs`, `scripts-audit-backfill.mjs`, `scripts-investigate-orphans.mjs`) contra Supabase com Service Role; scripts apagados após validação
- **Decisões locked via AskUserQuestion**:
  - Migration: evento_id UUID como source-of-truth (não slug lookup)
  - Write path: remover evento_slug, gravar só evento_id
  - Auditoria pré-backfill: sim (encontrados 4/9 órfãos)
  - Órfãos: investigar e remapear (001 → farmacologia-clinica, 004 → congresso-farmacia-2026)
- **Estado**: migration 024 escrita, handoff doc criado, read path + write path pendentes