# 2026-06-16 — Event EN translation: type + multi-host + dead columns

## Objectivo

Resolver 3 problemas da tradução EN de eventos detectados no admin em 2026-06-16:

1. **Campo `description` inútil** — não pega nada do PT (a coluna `description` não existe em `event_translations` original; só `excerpt`). Mostrava caixa de input sem propósito.
2. **`type` (Presencial/Online/Híbrido) não traduzível** — `event_translations` não tinha coluna `type`, então o EN mostrava sempre o valor PT ("📍 Presencial").
3. **Multi-host assimétrico** — PT permite N hosts via `events.hosts` (JSONB array), mas a EN tinha 3 colunas singulares (`host_name`, `host_role`, `host_bio`) que só traduziam 1 host e nem sequer eram preenchidas pelo `BilingualTabs` antigo (que só expunha `host_role` + `host_bio`).

## Decisões locked

### Schema (`event_translations`)

- **Adicionar** `type TEXT` — para traduzir Presencial/Online/Híbrido
- **Adicionar** `hosts JSONB` — array de `{name, role, organization}` (espelha `events.hosts`)
- **DROP** `host_name`, `host_role`, `host_bio` (3 colunas singulares que estavam mortas)
- **Backfill** via `COALESCE(et.type, e.type)` e `COALESCE(et.hosts, e.hosts)` — idempotente, nunca sobrescreve valor EN manual

### `lib/api/translations.js` — `ENTITY_TRANSLATABLE_FIELDS.event`

Ordem final:
```js
event: [
  'title',
  'excerpt',
  'type',
  'location',
  'hosts',
  'category_label',
  'meta_description',
],
```

- **`FIELD_TO_COLUMN`**: removed `hostName/host_name`, `hostRole/host_role`, `hostBio/host_bio`. Added `type: 'type'`, `hosts: 'hosts'`.
- **`mergeEntity`**: removed `host` reconstruction block. Hosts are now merged wholesale como JSON array (não há mais objecto singular `host` aninhado).
- **`AUTHOR_HOST_FIELDS` Set**: mantido (filtra `author_name`/`host_name` se reaparecerem no input).

### `lib/actions/translation.js` — `ENTITY_FIELDS.event`

```js
event: ['title', 'excerpt', 'type', 'location', 'hosts', 'category_label', 'meta_description'],
```

- **HTML_FIELDS** permanece `Set(['content', 'description'])` — `description` continua na Set por segurança (eventualmente `live.description` ainda pode aparecer em payloads legacy, mas já não no form path).
- `callOpenRouter` envia `hosts` como JSONB (Gemma 4 31B trata como string serializada; o `JSON.parse` na response converte de volta). Se Gemma falhar, fallback é PT as-is via mergeEntity.

### `components/admin/BilingualTabs.jsx`

- Nova prop: `ptHosts = []` (default) — array de hosts do PT passado pelo parent
- Novo state: `enHosts` hidratado de `translation.hosts` (se já existir) OU espelhado de `ptHosts` (1 entrada vazia por host PT, com índice que referencia o host PT)
- Função `updateHost(index, key, value)` — actualiza 1 campo de 1 host
- `handleSave` faz merge de `enHosts` filtrado (sem entradas totalmente vazias) no payload: `const payload = { ...enValues, hosts: hostsPayload }`
- `fields.map()`:
  - `field.key === 'hosts'` → renderiza N cards com 3 inputs (name/role/organization), mostra "(PT: <nome>)" no header do card quando `ptHosts[index]?.name` existe
  - `field.key === 'type'` → renderiza `<select>` com opções `presencial` / `online` / `hibrido`
  - Resto inalterado

## Ficheiros tocados

✅ `supabase/migrations/022_event_translations_type_hosts_jsonb.sql` (NOVO)
✅ `lib/api/translations.js` (ENTITY_TRANSLATABLE_FIELDS, FIELD_TO_COLUMN, mergeEntity)
✅ `lib/actions/translation.js` (ENTITY_FIELDS)
✅ `components/admin/BilingualTabs.jsx` (ptHosts prop, enHosts state, hosts/type fields rendering)

## Pendente (próximo turno)

### 1. Editar `app/[lang]/admin/(protected)/eventos/[id]/page.js`

Substituir o array `fields` no `<BilingualTabs>` (linhas 48-58):

**Antes:**
```js
fields={[
  { key: 'title', label: 'Title' },
  { key: 'slug', label: 'Slug' },
  { key: 'excerpt', label: 'Excerpt', type: 'textarea', rows: 2 },
  { key: 'description', label: 'Description', type: 'textarea', rows: 6 },
  { key: 'location', label: 'Location' },
  { key: 'category_label', label: 'Category' },
  { key: 'host_role', label: 'Host role' },
  { key: 'host_bio', label: 'Host bio', type: 'textarea', rows: 3 },
  { key: 'meta_description', label: 'Meta description', type: 'textarea', rows: 2 },
]}
```

**Depois:**
```js
fields={[
  { key: 'title', label: 'Title' },
  { key: 'slug', label: 'Slug' },
  { key: 'excerpt', label: 'Excerpt', type: 'textarea', rows: 2 },
  { key: 'type', label: 'Type' },
  { key: 'location', label: 'Location' },
  { key: 'hosts', label: 'Hosts' },
  { key: 'category_label', label: 'Category' },
  { key: 'meta_description', label: 'Meta description', type: 'textarea', rows: 2 },
]}
```

E adicionar prop `ptHosts={event.hosts || []}` no `<BilingualTabs>` (linha 44-60).

**Nota:** O select `app/[lang]/admin/(protected)/events/[id]/page.js` (mirror EN da rota) também pode precisar do mesmo tratamento, mas como é mirror que re-exporta, verificar se há redirect ou cópia física.

### 2. Editar render nos componentes públicos

**`components/ui/EventCard.jsx`** — actualmente faz:
```js
event.type?.toLowerCase() === 'online' ? '💻 Online' : '📍 Presencial'
```

Mudar para usar `event.type` traduzido (vindo de `mergeEntity`). O `type` agora vem em PT ('presencial'/'online'/'hibrido') e precisamos de:
- Se `lang === 'en'` e `event.type` foi traduzido (values EN no futuro) → mostrar label EN
- Senão → mostrar label PT com emoji

Como o `type` em PT é 'presencial'/'online'/'hibrido' (lowercase), e o EN no card provavelmente vai usar valores iguais ou strings diferentes, o ideal é uma função helper `getEventTypeLabel(type, lang)` que mapeia para label localized.

**`app/[lang]/(public)/eventos/[slug]/page.js`** — substituir o hardcode do type/hosts pelos campos do `event` object depois de `mergeEntity`.

**`app/[lang]/(public)/events/[slug]/page.js`** — idem para o mirror EN.

### 3. (Opcional) Aplicar migration 022

User aplica via Supabase Dashboard SQL Editor em paralelo (padrão documentado em `user-splits-migration-and-push-parallel.md`).

Migration 022:
```sql
ALTER TABLE public.event_translations
  ADD COLUMN IF NOT EXISTS type  TEXT,
  ADD COLUMN IF NOT EXISTS hosts JSONB;

UPDATE public.event_translations et
   SET type  = COALESCE(et.type, e.type),
       hosts = COALESCE(et.hosts, e.hosts)
   FROM public.events e
  WHERE et.event_id = e.id
    AND (et.type IS NULL OR et.hosts IS NULL);

ALTER TABLE public.event_translations
  DROP COLUMN IF EXISTS host_name,
  DROP COLUMN IF EXISTS host_role,
  DROP COLUMN IF EXISTS host_bio;
```

## Verificação

Após próximo turno completar as edições pendentes:

1. Restart do dev server (`Ctrl+C` + `npm run dev`) — HMR não recompila Server Components
2. Hard refresh no browser em `/pt/admin/eventos/<id>`
3. Verificar que a tab EN mostra:
   - Title, Slug, Excerpt, Type (dropdown), Location, Hosts (N cards), Category, Meta description
   - **NÃO** mostra mais `description`/`host_role`/`host_bio`
4. Carregar em "Auto-traduzir do PT" → confirmar que `type` e `hosts` vêm preenchidos
5. Visitar `/en/events/<slug-en>` → confirmar que "📍 In Person" ou equivalente aparece (se admin tiver traduzido)
6. Visitar `/pt/events/<slug>` → manter label PT

## Memory updates a fazer após fechar

- Marcar task #3 (BilingualTabs) e #5 (page.js) e #4 (render) como completed no TaskList
- Adicionar memory `event-en-translation-type-hosts-2026-06-16.md` com lições:
  - Padrão para detectar "campo inútil": comparar `ENTITY_TRANSLATABLE_FIELDS` com `select('*').limit(1)` da tabela real
  - Padrão para "campo singular vs JSONB array" em tradução: usar cards com índice, mostrar PT como subtitle
  - DROP de colunas mortas é OK se houver prova objectiva de que não são escritas
