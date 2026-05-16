# Desktop Nav Links Restoration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restore desktop navigation links (Início, Artigos, Eventos, Lives, Sobre Nós) in the header, visible only on desktop (>=769px), while keeping the hamburger/drawer working on mobile.

**Architecture:** Add a `nav-links` `<ul>` inside `header-right` in each HTML page, before the theme toggle. The CSS uses `hidden md:flex` to show links only on desktop. The hamburger remains `md:hidden` (mobile-only). No JS changes needed — the drawer already works independently.

**Tech Stack:** HTML, Tailwind CSS v4 (`@apply`), vanilla JS (unchanged)

---

## Files to Modify

| File              | Change                                                                                         |
| ----------------- | ---------------------------------------------------------------------------------------------- |
| `src/input.css`   | Add `.nav-links` base styles + desktop/mobile responsive rules; remove duplicate media queries |
| `index.html`      | Add `<ul class="nav-links">` inside `header-right` before theme toggle                         |
| `artigos.html`    | Same as index.html                                                                             |
| `artigo.html`     | Same as index.html                                                                             |
| `eventos.html`    | Same as index.html                                                                             |
| `evento.html`     | Same as index.html                                                                             |
| `inscricao.html`  | Same as index.html                                                                             |
| `lives.html`      | Same as index.html                                                                             |
| `lives-list.html` | Same as index.html                                                                             |
| `sobre.html`      | Same as index.html                                                                             |

No new files created. No JS changes.

---

### Task 1: Restore nav-links CSS in input.css

**Files:**

- Modify: `src/input.css:165-1726` (replace duplicate media queries with clean nav-links styles)

- [ ] **Step 1: Add .nav-links base styles after .hamburger rules (line ~185)**

Insert after the `.hamburger span` block, before `.drawer`:

```css
/* Desktop Navigation Links */
.nav-links {
  @apply hidden md:flex items-center gap-8;
}

.nav-links a {
  @apply text-brand-deep font-medium transition-colors duration-300 hover:text-brand-accent;
}

html.dark .nav-links a {
  color: var(--color-brand-deep);
}
```

- [ ] **Step 2: Clean up duplicate .header-right media queries (lines 1650-1726)**

Replace all three duplicate `@media` blocks (lines 1650-1726) with a single clean pair:

```css
/* Desktop: nav links + toggle button */
@media (min-width: 769px) {
  .header-right {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .header-right .nav-links {
    display: flex;
    align-items: center;
  }

  .header-right .theme-toggle {
    margin-left: 1rem;
  }
}

/* Mobile: toggle button next to hamburger, both visible */
@media (max-width: 768px) {
  .header-right {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .header-right .theme-toggle {
    order: 1;
    margin-left: auto;
    margin-right: 0.5rem;
  }

  .header-right .hamburger {
    order: 2;
  }
}
```

- [ ] **Step 3: Build and verify CSS compiles**

Run: `npm run build`

Expected: Build succeeds with no errors.

- [ ] **Step 4: Commit**

```bash
git add src/input.css
git commit -m "feat: restore desktop nav-links CSS styles"
```

---

### Task 2: Add nav-links HTML to all 9 pages

**Files:**

- Modify: `index.html` (line 29, inside `<div class="header-right">`)
- Modify: `artigos.html` (same position)
- Modify: `artigo.html` (same position)
- Modify: `eventos.html` (same position)
- Modify: `evento.html` (same position)
- Modify: `inscricao.html` (same position)
- Modify: `lives.html` (same position)
- Modify: `lives-list.html` (same position)
- Modify: `sobre.html` (same position)

- [ ] **Step 1: Add nav-links to index.html**

Inside `<div class="header-right">`, insert **before** the theme toggle button:

```html
<ul class="nav-links">
  <li><a href="index.html#inicio">Início</a></li>
  <li><a href="artigos.html">Artigos</a></li>
  <li><a href="eventos.html">Eventos</a></li>
  <li><a href="lives-list.html">Lives</a></li>
  <li><a href="sobre.html">Sobre Nós</a></li>
</ul>
```

- [ ] **Step 2: Add nav-links to artigos.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 3: Add nav-links to artigo.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 4: Add nav-links to eventos.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 5: Add nav-links to evento.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 6: Add nav-links to inscricao.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 7: Add nav-links to lives.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 8: Add nav-links to lives-list.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 9: Add nav-links to sobre.html**

Same HTML, inserted before the theme toggle button in `header-right`.

- [ ] **Step 10: Build and verify**

Run: `npm run build`

Expected: Build succeeds. In `dist/`, all HTML files contain `<ul class="nav-links">`.

- [ ] **Step 11: Commit**

```bash
git add index.html artigos.html artigo.html eventos.html evento.html inscricao.html lives.html lives-list.html sobre.html
git commit -m "feat: add desktop nav links to header on all pages"
```

---

### Task 3: Visual verification

- [ ] **Step 1: Run dev server**

Run: `npm run dev`

- [ ] **Step 2: Verify desktop (>=769px)**

Open http://localhost:5173 at desktop width. Expected:

- Logo on left
- Nav links (Início, Artigos, Eventos, Lives, Sobre Nós) visible between logo and theme toggle
- Theme toggle button visible
- Hamburger button hidden

- [ ] **Step 3: Verify mobile (<769px)**

Resize to mobile width. Expected:

- Logo on left
- Theme toggle button visible (right side)
- Hamburger button visible (far right)
- Nav links hidden
- Drawer opens on hamburger click with all 5 links

- [ ] **Step 4: Verify dark mode**

Toggle dark mode. Expected:

- Nav links text color changes to light color
- All other behavior unchanged

- [ ] **Step 5: Final commit if any fixes needed**

---

## Self-Review

1. **Spec coverage:** Desktop links restored? Yes (Task 2). Mobile drawer preserved? Yes (no drawer HTML/JS changed). CSS responsive? Yes (Task 1).
2. **Placeholder scan:** No TBDs, TODOs, or vague steps. All code shown inline.
3. **Type consistency:** `nav-links` class used consistently in CSS and HTML. No naming conflicts with existing `drawer-links`.
