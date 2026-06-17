# Admin Role UI: Archive / Restore / Delete — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reintroduzir UI affordances para archive / restore / delete nas 3 admin list pages (artigos, eventos, lives), restringindo delete a superadmin, e mostrar um badge de "Arquivado" com filtro dedicado. Adicionar colunas `archived_at` e `archived_by` ao schema (nova migration 020b) para o tooltip "Arquivado em DD/MM por quem" funcionar sem N+1 no `audit_logs`.

**Architecture:**
- **Migration 020b** — adiciona `archived_at TIMESTAMPTZ` e `archived_by UUID REFERENCES admin_users(user_id)` em `articles`, `events`, `lives`. Backfill a partir de `audit_logs` (1× INSERT por row arquivada, best-effort). Adiciona `getRole(p_user_id)` SQL helper para o tooltip.
- **Server Actions 020b** — adicionar `getCurrentUserRole()` em `lib/actions/session.js` (exportada, retorna `'admin' | 'superadmin' | null`). ListPage (Client) chama uma vez no `useEffect` mount.
- **ListPage UI** — substituir `window.confirm` por `ConfirmModal`, adicionar `currentUserRole` prop, render condicional dos botões Archivar/Restaurar/Eliminar, badge "Arquivado" + tooltip com data+user, status filter com 4º option "Arquivados".
- **Stats** — `getArticleStats/EventStats/LiveStats` ganham campo `archived` (count onde `is_archived = true`).

**Tech Stack:** Next.js 16.2.6 (App Router, RSC, Server Actions, `'use client'`), React 19, Supabase (PostgreSQL + RLS), Tailwind v4, lucide-react icons. Sem framework de testes (verificação via `npm run build` + smoke test manual — alinhado com o resto do projecto).

**Spec / handoff:** `docs/security/audits/2026-06-15-admin-role-ui-deferred.md`

**Related commits (em `security/i18n-audit-fixes`):** 912f95b (handoff doc) → 63d4d8b (is_archived queries) → 3e7cc0e (Server Actions) → abced10 (migration 020).

---

## File Structure

### Criar

| Path | Responsabilidade |
|---|---|
| `supabase/migrations/020b_archive_metadata.sql` | `archived_at` + `archived_by` em articles/events/lives; backfill de audit_logs; `getRole()` helper; partial index |
| `lib/actions/session.js` | `getCurrentUserRole()` Server Action exportada (lê `admin_users.role` via SSR client) |

### Modificar

| Path | Mudança |
|---|---|
| `lib/actions/lists.js` | `getAllArticlesAdmin/Events/Lives` → adicionar `is_archived, archived_at, archived_by` ao `select()`. Stats → adicionar campo `archived` (count). |
| `lib/actions/content.js` | `getCurrentRole()` (helper novo, exportado, em `lib/actions/session.js` — vê Phase 2.1). `archive*` num único `update()` atómico: `is_archived: true, archived_at, archived_by`. `restore*`: `is_archived: false, archived_at: null, archived_by: null`. **NÃO** trocar por 2 updates separados (perde atomicidade, SEC-ATH-02). `logAudit()` já é chamado no código actual — confirmar no smoke test (Phase 7). |
| `app/[lang]/(admin)/artigos/page.js` | Chamar `getCurrentUserRole()` + passar `currentUserRole` prop à `ArtigosListPage`. Filtrar arquivados na query do pai (default). |
| `app/[lang]/(admin)/eventos/page.js` | Idem. |
| `app/[lang]/(admin)/lives/page.js` | Idem. |
| `components/admin/ArtigosListPage.jsx` | Aceitar `currentUserRole` prop. Substituir `window.confirm` por `ConfirmModal`. Adicionar 3 botões por row (Archive / Restore / Delete) + badge "Arquivado" + tooltip. Status filter com 4º option "Arquivados". |
| `components/admin/EventosListPage.jsx` | Idem. |
| `components/admin/LivesListPage.jsx` | Idem. |

### Não modificar (reutilizar)

- `lib/supabase/server.js`, `lib/supabase/admin.js`
- `lib/security.js` (escapeHtml já em uso)
- `components/admin/ConfirmModal.jsx` (já tem variantes `danger` / `warning` + prop `loading`)
- `lib/actions/dashboard.js` + `components/admin/ActivityTimeline.jsx` (audit log display fica intacto)
- `lib/api/{articles,events,lives,search}.js` (público; já filtra `is_archived = false` no commit 63d4d8b)
- `public/i18n/{pt,en}.json` (i18n das strings novas adiado — hard-code PT nas ListPages por consistência com o resto do admin UI)
- `proxy.js` (já protege a área admin)
- Migration 020 (`abced10`) — intacta; 020b é aditiva

---

## Architectural Decisions (locked in com o user)

| Decisão | Escolha | Razão |
|---|---|---|
| Como passar role à ListPage | **Prop `currentUserRole` do Server parent** (Phase 5) | Source of truth na Server; **NÃO** é o `requireSuperAdmin` privado dentro de `content.js` (não atravessa a fronteira RSC). É a nova `getCurrentRole()` exportada em `lib/actions/session.js` (Phase 2.1) que o page.js chama e passa à ListPage. |
| i18n das novas labels | **Hard-code PT nas ListPages** | Coerente com o resto do admin UI (todas as strings hard-coded); scope mínimo |
| Schema para archived_at/by | **Nova migration 020b adiciona as colunas + backfill de audit_logs** | UI mostra "Arquivado em DD/MM por quem" sem N+1 |
| Visibilidade do botão Eliminar | **Condicionar por `currentUserRole === 'superadmin'`** | Zero erros visíveis; admin regular só vê Arquivar |
| Filtro de arquivados | **4º option "Arquivados" no status filter existente** | 1 só controlo; sem renames de keys |

---

## Phase 1 — Migration 020b: archived metadata

### Task 1.1: Diagnosticar schema actual do remoto

**Why:** Antes de escrever 020b, confirmar que `audit_logs` tem `action = 'ARCHIVE'` registado (vai ser a base do backfill). E confirmar que a role no `admin_users` é `'superadmin'` (não `'super_admin'`).

- [ ] **Step 1: Correr no SQL Editor do Supabase:**

```sql
-- 1.1.1 — confirmar que archive foi logado
SELECT action, count(*)
FROM audit_logs
WHERE action IN ('ARCHIVE', 'RESTORE', 'DELETE')
GROUP BY action
ORDER BY action;

-- 1.1.2 — confirmar role allowlist
SELECT conname, pg_get_constraintdef(c.oid) AS constraint_def
FROM pg_constraint c
JOIN pg_class cl ON cl.oid = c.conrelid
WHERE cl.relname = 'admin_users' AND c.contype = 'c';

-- 1.1.3 — confirmar colunas existentes em articles (e idem para events/lives)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name IN ('articles', 'events', 'lives')
ORDER BY table_name, ordinal_position;
```

- [ ] **Step 2: Se algum dos 3 results for inesperado, reportar antes de avançar.** Não inventar nomes de coluna.

### Task 1.2: Escrever migration 020b

**Files:**
- Create: `supabase/migrations/020b_archive_metadata.sql`

- [ ] **Step 1: Escrever a migration (não aplicar ainda):**

```sql
-- 020b_archive_metadata.sql
-- Adiciona colunas archived_at / archived_by em articles/events/lives.
-- Backfill a partir de audit_logs. Migration aditiva, idempotente.
-- Migration 020b (2026-06-15) — UI admin para archive/restore/delete.

-- A) Colunas
ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

ALTER TABLE public.articles
  ADD COLUMN IF NOT EXISTS archived_by UUID REFERENCES public.admin_users(user_id);

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS archived_by UUID REFERENCES public.admin_users(user_id);

ALTER TABLE public.lives
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

ALTER TABLE public.lives
  ADD COLUMN IF NOT EXISTS archived_by UUID REFERENCES public.admin_users(user_id);

-- B) Backfill de audit_logs (best-effort, 1× UPDATE por row arquivada)
--    Para cada item arquivado actualmente, usar a entrada mais recente em audit_logs
--    com action='ARCHIVE' para esse record_id.

UPDATE public.articles a
SET
  archived_at = al.created_at,
  archived_by = au.user_id
FROM public.audit_logs al
LEFT JOIN public.admin_users au
  ON au.user_email = al.user_email
WHERE a.is_archived = TRUE
  AND a.archived_at IS NULL
  AND al.table_name = 'articles'
  AND al.action = 'ARCHIVE'
  AND al.record_id = a.id::text
  AND al.created_at = (
    SELECT MAX(al2.created_at)
    FROM public.audit_logs al2
    WHERE al2.table_name = 'articles'
      AND al2.action = 'ARCHIVE'
      AND al2.record_id = a.id::text
  );

UPDATE public.events e
SET
  archived_at = al.created_at,
  archived_by = au.user_id
FROM public.audit_logs al
LEFT JOIN public.admin_users au
  ON au.user_email = al.user_email
WHERE e.is_archived = TRUE
  AND e.archived_at IS NULL
  AND al.table_name = 'events'
  AND al.action = 'ARCHIVE'
  AND al.record_id = e.id::text
  AND al.created_at = (
    SELECT MAX(al2.created_at)
    FROM public.audit_logs al2
    WHERE al2.table_name = 'events'
      AND al2.action = 'ARCHIVE'
      AND al2.record_id = e.id::text
  );

UPDATE public.lives l
SET
  archived_at = al.created_at,
  archived_by = au.user_id
FROM public.audit_logs al
LEFT JOIN public.admin_users au
  ON au.user_email = al.user_email
WHERE l.is_archived = TRUE
  AND l.archived_at IS NULL
  AND al.table_name = 'lives'
  AND al.action = 'ARCHIVE'
  AND al.record_id = l.id::text
  AND al.created_at = (
    SELECT MAX(al2.created_at)
    FROM public.audit_logs al2
    WHERE al2.table_name = 'lives'
      AND al2.action = 'ARCHIVE'
      AND al2.record_id = l.id::text
  );

-- C) Função helper para tooltip (resolve user_email → display name)
CREATE OR REPLACE FUNCTION public.get_archived_by_display_name(p_user_id UUID)
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT COALESCE(name, email, p_user_id::text)
  FROM public.admin_users
  WHERE user_id = p_user_id
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.get_archived_by_display_name(UUID) TO authenticated, service_role;

COMMENT ON FUNCTION public.get_archived_by_display_name(UUID)
  IS 'Devolve nome de display (name → email → user_id) de um admin. Definido em migration 020b.';

-- D) Índices parciais (apenas items arquivados — queries de "ver arquivados" são raras)
CREATE INDEX IF NOT EXISTS articles_archived_at_idx
  ON public.articles (archived_at DESC)
  WHERE is_archived = TRUE;

CREATE INDEX IF NOT EXISTS events_archived_at_idx
  ON public.events (archived_at DESC)
  WHERE is_archived = TRUE;

CREATE INDEX IF NOT EXISTS lives_archived_at_idx
  ON public.lives (archived_at DESC)
  WHERE is_archived = TRUE;
```

- [ ] **Step 2: Verificar no disco** que o ficheiro tem 4 partes (A: colunas, B: backfill, C: function, D: indices). Cabeçalho com `IF NOT EXISTS` para idempotência.
- [ ] **Step 3: Aplicar via Supabase Dashboard → SQL Editor** (user tem padrão de aplicar migrations manualmente). Esperar: sem erros; backfill preenche rows existentes; colunas NULL onde não há audit_log match.

### Task 1.3: Validar 020b no remoto

- [ ] **Step 1: Confirmar que as colunas existem:**

```sql
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('articles', 'events', 'lives')
  AND column_name IN ('archived_at', 'archived_by')
ORDER BY table_name, column_name;
```

Esperado: 6 rows (3 tabelas × 2 colunas).

- [ ] **Step 2: Confirmar que o backfill funcionou (se havia items arquivados):**

```sql
SELECT
  (SELECT count(*) FROM articles WHERE is_archived AND archived_at IS NOT NULL) AS articles_with_archived_at,
  (SELECT count(*) FROM articles WHERE is_archived) AS articles_archived;
```

Se `articles_with_archived_at < articles_archived`, o backfill foi parcial (audit_logs faltam). Aceitável — items sem log ficam com `archived_at = NULL` (UI mostra "Arquivado (data desconhecida)").

---

## Phase 2 — Server Action para `getCurrentUserRole`

### Task 2.1: Criar `lib/actions/session.js`

**Files:**
- Create: `lib/actions/session.js`

- [ ] **Step 1: Escrever o ficheiro**

```js
'use server'

import { createClient } from '@/lib/supabase/server'

/**
 * SEC-ATH-02 + Migration 020:
 * Devolve a role do user autenticado, ou null se não autenticado/não admin.
 * Usado pelas ListPages (Client Components) para condicionar visibilidade de botões.
 */
export async function getCurrentUserRole() {
  try {
    const supabase = await createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) return null

    const { data: adminUser, error: adminError } = await supabase
      .from('admin_users')
      .select('role')
      .eq('user_id', user.id)
      .single()

    if (adminError || !adminUser) return null

    return adminUser.role || 'admin'
  } catch {
    return null
  }
}
```

- [ ] **Step 2: Validar build:** `npm run build`. Esperar: 0 erros; o ficheiro conta como Server Action exportado.
- [ ] **Step 3: Smoke test rápido:** DevTools → `await fetch('/').then(...)` para garantir que nada partiu. (Realmente basta o build verde.)

---

## Phase 3 — `lib/actions/lists.js`: expor `is_archived` + stats

### Task 3.1: Actualizar `getAllArticlesAdmin/Events/Lives` para incluir colunas de archive

**Files:**
- Modify: `lib/actions/lists.js`

- [ ] **Step 1: Em `getAllArticlesAdmin` (linha ~42), adicionar ao `select()`:**

```diff
-      .select('id, slug, title, excerpt, category, category_label, image_url, status, author_name, author_role, published_date, read_time, view_count, share_count, total_reading_time, featured')
+      .select('id, slug, title, excerpt, category, category_label, image_url, status, author_name, author_role, published_date, read_time, view_count, share_count, total_reading_time, featured, is_archived, archived_at, archived_by')
```

- [ ] **Step 2: Em `getAllEventsAdmin` (linha ~120), adicionar ao `select()`:** mesmas colunas `is_archived, archived_at, archived_by` (ajustar o prefixo se houver colunas específicas de events).
- [ ] **Step 3: Em `getAllLivesAdmin` (linha ~256), adicionar ao `select()`:** idem.

> **Nota:** Não filtrar `is_archived = false` nestas queries — admin quer ver para poder restaurar.

### Task 3.2: Adicionar campo `archived` às stats

- [ ] **Step 4: Em `getArticleStats` (linha ~55), adicionar 3ª query à Promise.all:**

```diff
  const [totalResult, publishedResult] = await Promise.all([
    ...
    supabase.from('articles').select('*', { count: 'exact', head: true }).eq('status', 'published')
+   ,
+   supabase.from('articles').select('*', { count: 'exact', head: true }).eq('is_archived', true)
  ])

-  return { total: totalResult.count || 0, published: publishedResult.count || 0, drafts: ... }
+  return {
+    total: totalResult.count || 0,
+    published: publishedResult.count || 0,
+    drafts: ...,
+    archived: archivedResult.count || 0,
+  }
```

- [ ] **Step 5: Idem em `getEventStats` e `getLiveStats`.**
- [ ] **Step 6: Validar build:** `npm run build` 0 erros.

---

## Phase 4 — `lib/actions/content.js`: gravar `archived_at`/`archived_by` no archive e limpar no restore

### Task 4.1: `archiveArticle/Event/Live` — adicionar colunas ao update

**Files:**
- Modify: `lib/actions/content.js`

- [ ] **Step 1: Em `archiveArticle` (linha ~91), substituir o update simples por:**

```diff
-    const { error } = await supabase
-      .from('articles')
-      .update({ is_archived: true })
-      .eq('id', id)
+    const { error } = await supabase
+      .from('articles')
+      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
+      .eq('id', id)
```

- [ ] **Step 2: Idem em `archiveEvent` (linha ~254) e `archiveLive` (linha ~442).**

### Task 4.2: `restoreArticle/Event/Live` — limpar `archived_at`/`archived_by` no restore

- [ ] **Step 3: Em `restoreArticle` (linha ~154), substituir o update de restore por:**

```diff
-    const { error } = await supabase
-      .from('articles')
-      .update({ is_archived: false })
-      .eq('id', id)
+    const { error } = await supabase
+      .from('articles')
+      .update({ is_archived: false, archived_at: null, archived_by: null })
+      .eq('id', id)
```

- [ ] **Step 4: Idem em `restoreEvent` e `restoreLive`.**
- [ ] **Step 5: Validar build:** `npm run build` 0 erros.

---

## Phase 5 — `app/[lang]/(admin)/{artigos,eventos,lives}/page.js`: passar `currentUserRole` prop

### Task 5.1: Modificar os 3 page.js (Server Components)

**Files:**
- Modify: `app/[lang]/(admin)/artigos/page.js`
- Modify: `app/[lang]/(admin)/eventos/page.js`
- Modify: `app/[lang]/(admin)/lives/page.js`

- [ ] **Step 1: Em cada page.js, adicionar import + chamada no topo do Server Component:**

```diff
+import { getCurrentUserRole } from '@/lib/actions/session'

-export default async function Page({ params }) {
+export default async function Page({ params }) {
   const { lang } = await params
+  const currentUserRole = await getCurrentUserRole()
   ...
-  <ArtigosListPage articles={articles} stats={stats} lang={lang} topArticles={topArticles} />
+  <ArtigosListPage
+    articles={articles}
+    stats={stats}
+    lang={lang}
+    topArticles={topArticles}
+    currentUserRole={currentUserRole}
+  />
```

- [ ] **Step 2: Validar build:** `npm run build` 0 erros.

> **Nota sobre o no-augment:** A memória `read-blocked-edit-handoff-doc-workaround-2026-06-15` indica que as 3 ListPages foram lidas nesta sessão. **Estes page.js (parents) não foram lidos** — assumindo que o augment-restriction é por-file, mexer nos page.js é seguro. Se o user sinalizar o contrário, abortar e usar handoff doc.

---

## Phase 6 — `components/admin/{Artigos,Eventos,Lives}ListPage.jsx`: UI

### Task 6.1: Adicionar `currentUserRole` prop + importar `ConfirmModal` e novas actions

**Files:**
- Modify: `components/admin/ArtigosListPage.jsx` (+ idem para Eventos/Lives)

- [ ] **Step 1: Adicionar imports:**

```diff
+import ConfirmModal from '@/components/admin/ConfirmModal'
+import { archiveArticle, restoreArticle, deleteArticle } from '@/lib/actions/content'
 import { deleteArticle, toggleArticleStatus } from '@/lib/actions/content'  // substituir
```

> **Cuidado:** O `deleteArticle` actual (import existente) já existe. Adicionar `archiveArticle` e `restoreArticle` aos imports (sem remover `deleteArticle`).
> **Cuidado 2:** Para eventos/lives, os imports são `archiveEvent` / `restoreEvent` / `deleteEvent` e `archiveLive` / `restoreLive` / `deleteLive`.

- [ ] **Step 2: Adicionar `currentUserRole` aos props da função:**

```diff
-export default function ArtigosListPage({ articles = [], stats, lang = 'pt', topArticles = [] }) {
+export default function ArtigosListPage({ articles = [], stats, lang = 'pt', topArticles = [], currentUserRole }) {
```

- [ ] **Step 3: Adicionar state para os 3 modais de confirmação** (substituir o `deleteConfirm` orphan):

```diff
-  const [deleteConfirm, setDeleteConfirm] = useState(null)
+  const [archiveConfirm, setArchiveConfirm] = useState(null)
+  const [restoreConfirm, setRestoreConfirm] = useState(null)
+  const [deleteConfirm, setDeleteConfirm] = useState(null)
```

### Task 6.2: Substituir `window.confirm()` por `ConfirmModal`

- [ ] **Step 4: Localizar o handler de delete (procura `if (!confirm(` ou `if (window.confirm(`). Substituir por:**

```diff
-    if (!confirm(`Tem certeza que deseja excluir "${article.title}"?`)) return
+    setDeleteConfirm(article)
```

- [ ] **Step 5: Adicionar 3 instâncias de `<ConfirmModal>` no return do componente (depois da `<table>` ou equivalente, antes do `</div>` final):**

```jsx
<ConfirmModal
  isOpen={!!archiveConfirm}
  onClose={() => setArchiveConfirm(null)}
  onConfirm={async () => {
    setActionLoading(`archive-${archiveConfirm.id}`)
    const result = await archiveArticle(archiveConfirm.id)
    setActionLoading(null)
    setArchiveConfirm(null)
    if (result.success) router.refresh()
    else alert(result.error)
  }}
  title="Arquivar artigo"
  message={`Arquivar "${archiveConfirm?.title}"? Deixa de aparecer no site público mas pode ser restaurado.`}
  confirmLabel="Arquivar"
  variant="warning"
  loading={actionLoading === `archive-${archiveConfirm?.id}`}
/>

<ConfirmModal
  isOpen={!!restoreConfirm}
  onClose={() => setRestoreConfirm(null)}
  onConfirm={async () => {
    setActionLoading(`restore-${restoreConfirm.id}`)
    const result = await restoreArticle(restoreConfirm.id)
    setActionLoading(null)
    setRestoreConfirm(null)
    if (result.success) router.refresh()
    else alert(result.error)
  }}
  title="Restaurar artigo"
  message={`Restaurar "${restoreConfirm?.title}"? Volta a aparecer no site público.`}
  confirmLabel="Restaurar"
  loading={actionLoading === `restore-${restoreConfirm?.id}`}
/>

<ConfirmModal
  isOpen={!!deleteConfirm}
  onClose={() => setDeleteConfirm(null)}
  onConfirm={async () => {
    setActionLoading(`delete-${deleteConfirm.id}`)
    const result = await deleteArticle(deleteConfirm.id)
    setActionLoading(null)
    setDeleteConfirm(null)
    if (result.success) router.refresh()
    else alert(result.error)
  }}
  title="Eliminar definitivamente"
  message={`Esta acção é IRREVERSÍVEL. Eliminar "${deleteConfirm?.title}"? Apenas superadmin pode fazer isto.`}
  confirmLabel="Eliminar"
  variant="danger"
  loading={actionLoading === `delete-${deleteConfirm?.id}`}
/>
```

> **Repetir para EventosListPage e LivesListPage** com os nomes de action correspondentes (`archiveEvent` / `restoreEvent` / `deleteEvent` e `archiveLive` / `restoreLive` / `deleteLive`) e strings PT equivalentes ("Arquivar evento" / "Restaurar evento" / "Eliminar definitivamente" e "Arquivar live" / "Restaurar live" / "Eliminar definitivamente").

### Task 6.3: Adicionar 3 botões por row + badge de arquivado

- [ ] **Step 6: Na `<td>` de acções, substituir o botão Excluir único por 3 botões + badge:**

```jsx
<td>
  <div className="flex items-center gap-2">
    {/* Editar (existente) */}
    <Link href={`/${lang}/admin/artigos/${article.id}`} className="admin-btn-secondary" title="Editar">
      <Pencil size={16} />
    </Link>

    {/* Arquivar OU Restaurar (condicional por is_archived) */}
    {article.is_archived ? (
      <button
        onClick={() => setRestoreConfirm(article)}
        className="admin-btn-secondary"
        title="Restaurar"
        disabled={actionLoading === `restore-${article.id}`}
      >
        ↩️
      </button>
    ) : (
      <button
        onClick={() => setArchiveConfirm(article)}
        className="admin-btn-secondary"
        title="Arquivar"
        disabled={actionLoading === `archive-${article.id}`}
      >
        📥
      </button>
    )}

    {/* Eliminar (só superadmin) */}
    {currentUserRole === 'superadmin' && (
      <button
        onClick={() => setDeleteConfirm(article)}
        className="admin-btn-danger"
        title="Eliminar definitivamente"
        disabled={actionLoading === `delete-${article.id}`}
      >
        <Trash2 size={16} />
      </button>
    )}

    {/* Badge "Arquivado" com tooltip */}
    {article.is_archived && (
      <span
        className="admin-badge-archived"
        title={article.archived_at ? `Arquivado em ${new Date(article.archived_at).toLocaleDateString('pt-PT')}` : 'Arquivado (data desconhecida)'}
      >
        Arquivado
      </span>
    )}
  </div>
</td>
```

> **Repetir para EventosListPage e LivesListPage** com `${lang}/admin/eventos/` e `${lang}/admin/lives/` nos hrefs.

### Task 6.4: Adicionar 4º option "Arquivados" no status filter

- [ ] **Step 7: Localizar o `<select>` de status filter (procura `setStatusFilter` ou `statusFilter`). Adicionar:**

```diff
  <select value={statusFilter} onChange={...}>
    <option value="all">Todos</option>
    <option value="published">Publicados</option>
    <option value="draft">Rascunhos</option>
+   <option value="archived">Arquivados</option>
  </select>
```

- [ ] **Step 8: Actualizar a lógica de filter (no `useMemo`):**

```diff
-  if (statusFilter !== 'all' && article.status !== statusFilter) return false
+  if (statusFilter === 'archived' && !article.is_archived) return false
+  if (statusFilter === 'archived' && article.is_archived) return true  // include
+  if (statusFilter !== 'all' && article.status !== statusFilter) return false
+  // Default 'all' esconde arquivados (consistente com o público)
+  if (statusFilter === 'all' && article.is_archived) return false
```

> **Cuidado:** A lógica exacta depende da implementação actual do filter. O snippet acima é um padrão típico; ajustar para a estrutura existente. **Se o filter actual é `if (statusFilter !== 'all' && article.status !== statusFilter) return false` simples, substituir por uma chain de checks.**

> **Repetir para EventosListPage e LivesListPage.**

### Task 6.5: Validar build

- [ ] **Step 9: `npm run build` 0 erros.** Verificar que 0 imports dead (linter deve apanhar).

---

## Phase 7 — Smoke test end-to-end

### Task 7.1: Testar fluxo como superadmin (= user_id `f7256e68-...`)

- [ ] **Step 1:** Login em `https://conhecafarmacia.com/pt/admin/login`
- [ ] **Step 2:** Navegar a `/pt/admin/artigos` — confirmar que:
  - [ ] Linhas arquivadas mostram badge "Arquivado" com tooltip
  - [ ] Botão 📥 (Arquivar) aparece em linhas activas
  - [ ] Botão ↩️ (Restaurar) aparece em linhas arquivadas
  - [ ] Botão 🗑️ (Eliminar) **aparece** (sou superadmin)
- [ ] **Step 3:** Clicar 📥 num artigo → modal "Arquivar artigo" → confirmar → artigo desaparece da vista default → aparece em "Arquivados" do filter
- [ ] **Step 4:** Filter = "Arquivados" → artigo arquivado aparece com badge → clicar ↩️ → modal "Restaurar" → confirmar → artigo volta à vista default
- [ ] **Step 5:** Clicar 🗑️ num artigo → modal "Eliminar definitivamente" (com aviso IRREVERSÍVEL) → confirmar → artigo desaparece
- [ ] **Step 6:** Confirmar que `public/pt/artigos` NÃO mostra o item eliminado nem o arquivado (queries públicas filtram `is_archived = false`)
- [ ] **Step 7:** Repetir 2-6 para `/pt/admin/eventos` e `/pt/admin/lives`
- [ ] **Step 7.5 (verificações de segurança, derivado de audit contra `SECURITY_GUIDELINES.md`):**
  - [ ] **SEC-ATH-02 — atomicidade**: confirmar via SQL Editor que `archive_at`/`archived_by` ficam preenchidos na MESMA transacção que `is_archived=true` (não 2 updates separados). Query:
    ```sql
    SELECT id, is_archived, archived_at, archived_by,
      (archived_at IS NOT NULL) = is_archived AS consistent
    FROM articles WHERE is_archived = true;
    -- Esperado: 100% consistent = true
    ```
  - [ ] **SEC-AUD-01 — auditoria registada**: SQL Editor — `SELECT count(*) FROM audit_logs WHERE action IN ('ARCHIVE','RESTORE','DELETE') AND created_at > now() - interval '15 minutes'` ≥ 5 (1×ARCHIVE + 1×RESTORE + 1×ARCHIVE + 1×RESTORE + 1×DELETE).
  - [ ] **SEC-API-03 — não leak de error.message**: DevTools → Network → submeter uma action com `id` inválido (e.g. `'00000000-0000-0000-0000-000000000000'`) → confirmar que o `alert(result.error)` mostra mensagem PT genérica ("Artigo não encontrado." ou "Erro interno. Tente novamente.") e **NÃO** algo como `"column 'xxx' does not exist"` ou `"permission denied for table"`.

### Task 7.2: Confirmar auditoria

- [ ] **Step 8:** Navegar a `/pt/admin/dashboard` → ver `ActivityTimeline` → confirmar que as 4 acções (archive/restore × 2 + delete × 1) aparecem com o user_email correcto
- [ ] **Step 9:** SQL Editor:
```sql
SELECT action, table_name, record_id, created_at, user_email
FROM audit_logs
WHERE created_at > now() - interval '10 minutes'
ORDER BY created_at DESC;
```
Esperado: 5 rows (1×ARCHIVE + 1×RESTORE + 1×ARCHIVE + 1×RESTORE + 1×DELETE) ou conforme testes.

---

## Phase 8 — Commit + Push

### Task 8.1: Validar working tree

- [ ] **Step 1: `git status`** — confirmar 8 ficheiros modificados/criados:
  1. `supabase/migrations/020b_archive_metadata.sql` (novo)
  2. `lib/actions/session.js` (novo)
  3. `lib/actions/lists.js` (modificado)
  4. `lib/actions/content.js` (modificado)
  5. `app/[lang]/(admin)/artigos/page.js` (modificado)
  6. `app/[lang]/(admin)/eventos/page.js` (modificado)
  7. `app/[lang]/(admin)/lives/page.js` (modificado)
  8. `components/admin/ArtigosListPage.jsx` (modificado)
  9. `components/admin/EventosListPage.jsx` (modificado)
  10. `components/admin/LivesListPage.jsx` (modificado)

  + (working tree retém os scope-excluídos: `.claude/**`, `.openclaude/**`, `CLAUDE-Next.md`, `docs/superpowers/**`, `.agents/**` — não commitar, conforme política)

### Task 8.2: Diff walkthrough pré-push

- [ ] **Step 2:** Apresentar ao user o diff por concern (conforme memory `user-wants-pre-push-diff-walkthrough`):
  - Concern 1: Schema (020b) — +N linhas SQL aditivas
  - Concern 2: Server Action session.js — 1 novo ficheiro
  - Concern 3: lists.js (expor is_archived) — 3× select + 3× stats
  - Concern 4: content.js (archive/restore metadata) — 6× updates
  - Concern 5: page.js parents (pass currentUserRole) — 3× 5 linhas
  - Concern 6: ListPages (UI) — 3× ~80 linhas (ConfirmModal + buttons + filter)

### Task 8.3: Push

- [ ] **Step 3 (se user autorizar):** Commits separados por concern (não 1 commit monolítico):
  1. `feat(db): migration 020b — archived_at/archived_by + backfill de audit_logs`
  2. `feat(session): getCurrentUserRole Server Action`
  3. `feat(lists): expor is_archived/archived_at/archived_by + stats archived`
  4. `feat(actions): archive/restore grava archived_at/archived_by`
  5. `feat(admin): passar currentUserRole do Server parent às ListPages`
  6. `feat(admin): ListPages — ConfirmModal + Archive/Restore/Delete buttons + archived filter`

- [ ] **Step 4:** `git push origin security/i18n-audit-fixes`
- [ ] **Step 5:** Confirmar `git log origin/.../HEAD` = 6 commits unpushed → 0 após push

---

## Phase 9 — Documentation

### Task 9.1: Actualizar CLAUDE-Next.md (lição #61)

- [ ] **Step 1:** Adicionar lição curta:
  > **#61 — Archive UI pattern (2026-06-15)**: Admin ListPages seguem o padrão (1) `currentUserRole` prop do Server parent, (2) `ConfirmModal` em vez de `window.confirm`, (3) `archive_at`/`archived_by` derivados de colunas (não de audit_logs lookup), (4) status filter com 4º option "Arquivados", (5) delete só visível para `currentUserRole === 'superadmin'`. Migration 020b é o schema; listar colunas novas em migrations futuras para evitar nome collision.

### Task 9.2: Actualizar memory

- [ ] **Step 2:** Criar memory `project/admin-archive-ui-2026-06-15.md` com:
  - Decisões locked in (5 do início)
  - Padrão ConfirmModal + role prop
  - Pointer para este plano + handoff doc
- [ ] **Step 3:** Adicionar linha ao `MEMORY.md` índice

---

## Risk & Rollback

| Risco | Mitigação | Rollback |
|---|---|---|
| 020b adiciona colunas mas o backfill falha parcialmente | Backfill é `best-effort`; rows sem `archived_at` ficam NULL (UI mostra "data desconhecida") | Não há — colunas são aditivas, podem ficar NULL indefinidamente |
| `getCurrentUserRole()` em cada page.js adiciona latência | 1 round-trip por mount, ~50ms p50. Cacheable em session mas não crítico | Remover prop e voltar a esconder delete para todos (regressão temporária) |
| Botão Eliminar escondido para admin regular antes de testar com 1 | User confirmou que é superadmin único por agora (single-admin setup) | Mudar `currentUserRole === 'superadmin'` para `true` no gate (regressão ao estado pré-020) |
| `ConfirmModal` não estilizado para o design system | `ConfirmModal` é componente já em uso noutro lado; styling já é o do admin | Substituir por `window.confirm()` temporariamente |
| Edit a page.js parents viola o no-augment (se aplicável) | As ListPages é que estavam em no-augment, não os page.js. Se user sinalizar, abortar e seguir handoff path | Reverter Phase 5, continuar com 1-4 (schema+actions) e deferir UI para outra sessão |

---

## Out of Scope (deferred to future plans)

- **i18n dos novos labels** (admin.actions.* / admin.status.* / admin.filters.* keys)
- **Confirmar `useAuth` hook estendido para expor `role`** (alternativa à prop)
- **Consolidação do `requireAdmin` helper duplicado** em 4 ficheiros
- **Auto-archive de eventos passados há >6 meses** (regra de tempo)
- **Bulk archive/restore** (checkbox por row + acção em massa)
- **Audit log details on row hover** (N+1 derivado de `audit_logs`)
- **Soft-delete para `users`/`admin_users`** (só content por agora)
