# Admin Role UI — Handoff for Next Session

**Date:** 2026-06-15
**Status:** UI partially blocked by "no augment" restriction on this session.
**Branch:** `security/i18n-audit-fixes`

## Context

Migration 020 added a `role` column to `admin_users` (`admin` / `superadmin`)
and a `is_archived` soft-delete column on `articles`, `events`, `lives`.
The Server Actions layer (`lib/actions/content.js`) was updated to expose:

- `archiveX(id)` — admin + superadmin (soft delete)
- `deleteX(id)` — superadmin only (hard delete, replaces old `requireAdmin` version)
- `restoreX(id)` — superadmin only

Public queries (`lib/api/articles.js`, `events.js`, `lives.js`, `search.js`,
`translations.js`) now filter `is_archived = false`. Default value `false`
means no public behaviour change for non-archived rows.

## What's missing (UI)

The admin list pages still call the old `deleteArticle` / `deleteEvent` /
`deleteLive`. After this commit, a regular `admin` who clicks "Excluir" will
see the error message "Operação restrita a superadmin." — the action
itself is correct (RLS + Server Action both block), but the UX is poor:
the button should not be visible to regular admins, and an "Arquivar"
button should be the primary destructive action for them.

### Files needing changes (read these FIRST in the next session, then edit)

1. `components/admin/ArtigosListPage.jsx`
2. `components/admin/EventosListPage.jsx`
3. `components/admin/LivesListPage.jsx`
4. `app/[lang]/admin/(protected)/artigos/page.js`
5. `app/[lang]/admin/(protected)/eventos/page.js`
6. `app/[lang]/admin/(protected)/lives/page.js`

### Changes required

**A) Server Component (`page.js`) — fetch and pass role**

```js
import { requireAdmin } from '@/lib/actions/content' // or new helper

// In the async function, fetch role:
const { user, role } = await requireAdmin() ?? { user: null, role: 'admin' }
// Pass to client component:
return <ArtigosListPage articles={...} currentUserRole={role} ... />
```

If the project already has a separate `getCurrentUserRole()` helper in
`lib/actions/auth.js` or similar, prefer using that instead of calling
`requireAdmin` from the page (which would couple page to the destructive
action's guard).

**B) Client Component (`XxxListPage.jsx`) — accept role prop, gate buttons**

```jsx
export default function ArtigosListPage({ articles, ..., currentUserRole = 'admin' }) {
  const isSuper = currentUserRole === 'superadmin'
  // ...
  // Replace the single "Excluir" button with:
  <td>
    <div className="admin-actions">
      <Link href={...}>...</Link>
      {article.is_archived ? (
        isSuper && <button onClick={() => handleRestore(article.id, article.title)}>Restaurar</button>
      ) : (
        <button onClick={() => handleArchive(article.id, article.title)}>Arquivar</button>
      )}
      {isSuper && !article.is_archived && (
        <button className="admin-btn admin-btn-danger" onClick={() => handleDelete(...)}>Eliminar</button>
      )}
    </div>
  </td>
}
```

The handlers:

```js
const handleArchive = useCallback(async (id, title) => {
  if (!confirm(`Arquivar "${title}"?`)) return
  setActionLoading(`archive-${id}`)
  try {
    const result = await archiveArticle(id)
    if (!result.success) alert(result.error)
    else router.refresh()
  } catch { alert('Erro ao arquivar artigo.') }
  finally { setActionLoading(null) }
}, [router])
```

Same pattern for `restoreArticle` (super only) and `deleteArticle` (super only).

**C) Add a "show archived" filter**

Add a fourth `<select>` to the filters row with options "Apenas activos" (default,
`is_archived = false`) and "Apenas arquivados" and "Todos". This is a UX win
because superadmins need a way to see and restore archived items.

## Verification plan

After UI changes:

1. Login as regular admin (`f7256e68...` is superadmin — create a second
   test admin to verify the "admin" role experience).
2. Confirm "Eliminar" button is **not visible** for non-archived items.
3. Confirm "Arquivar" button is visible, click it, confirm row disappears
   from public site (`/pt/artigos`) but is still visible in admin list when
   "Apenas arquivados" filter is selected.
4. Login as superadmin, confirm "Eliminar" + "Restaurar" buttons appear.
5. Smoke test: archive → restore → delete sequence on a test event.

## Out of scope

- Audit log UI for ARCHIVE/DELETE/RESTORE actions (current `logAudit` is
  enough; surface in admin dashboard is a separate task).
- Bulk archive/restore (one-by-one buttons only for now).
- Auto-archive of past events / old articles.
