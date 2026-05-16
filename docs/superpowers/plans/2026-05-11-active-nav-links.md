# Active Nav Links Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the drawer active-state bug (Início always highlighted on Netlify) and add active state + hover to desktop nav-links, with sub-page inheritance (evento.html → "Eventos").

**Architecture:** Replace the pathname-comparison logic in `setActiveDrawerLink()` with a `PAGE_SECTION_MAP` lookup that covers both `.html` and clean-URL paths (Netlify rewrite). Expand the function to also set `nav-link-active` on desktop `.nav-links` anchors. Add CSS pill-style active state and hover for `.nav-links a`.

**Tech Stack:** Vanilla JS, Tailwind CSS v4 (`@apply`), Vite

---

## Files to Modify

| File            | Change                                                                                                                       |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `src/script.js` | Replace `setActiveDrawerLink()` (lines 9-30) with `setActiveNavLink()` using `PAGE_SECTION_MAP`; update call site (line 102) |
| `src/input.css` | Add `.nav-links a:hover`, `.nav-links a.nav-link-active`, and dark-mode variants after line 182                              |
| `netlify.toml`  | Add missing `/lives` and `/lives-list` redirects                                                                             |

No HTML changes needed. No new files created.

---

### Task 1: Fix JS active-state logic and expand to desktop nav-links

**Files:**

- Modify: `src/script.js:9-30` (replace `setActiveDrawerLink`) and `src/script.js:102` (update call)

- [ ] **Step 1: Replace the `setActiveDrawerLink` function with `setActiveNavLink`**

In `src/script.js`, replace lines 8-30 (the comment + entire function) with:

```js
// Active page detection — maps current path to parent section
// Supports both .html paths (localhost) and clean URLs (Netlify)
const PAGE_SECTION_MAP = {
  "index.html": "index.html",
  "": "index.html",
  "artigos.html": "artigos.html",
  artigos: "artigos.html",
  "artigo.html": "artigos.html",
  artigo: "artigos.html",
  "eventos.html": "eventos.html",
  eventos: "eventos.html",
  "evento.html": "eventos.html",
  evento: "eventos.html",
  "inscricao.html": "eventos.html",
  inscricao: "eventos.html",
  "lives-list.html": "lives-list.html",
  "lives-list": "lives-list.html",
  "lives.html": "lives-list.html",
  lives: "lives-list.html",
  "sobre.html": "sobre.html",
  sobre: "sobre.html",
};

function setActiveNavLink() {
  const currentPath = window.location.pathname;
  const normalizedPath = currentPath.replace(/^\//, "").replace(/#.*$/, "");
  const activeHref = PAGE_SECTION_MAP[normalizedPath] || null;

  // Drawer links
  if (drawerLinks) {
    drawerLinks.querySelectorAll("a").forEach((link) => {
      const linkHref = link
        .getAttribute("href")
        .replace(/^\//, "")
        .replace(/#.*$/, "");
      if (activeHref && linkHref === activeHref) {
        link.classList.add("drawer-link-active");
      } else {
        link.classList.remove("drawer-link-active");
      }
    });
  }

  // Desktop nav links
  const navLinksEl = document.querySelector(".nav-links");
  if (navLinksEl) {
    navLinksEl.querySelectorAll("a").forEach((link) => {
      const linkHref = link
        .getAttribute("href")
        .replace(/^\//, "")
        .replace(/#.*$/, "");
      if (activeHref && linkHref === activeHref) {
        link.classList.add("nav-link-active");
      } else {
        link.classList.remove("nav-link-active");
      }
    });
  }
}
```

- [ ] **Step 2: Update the call site**

In `src/script.js`, replace line 102:

```js
// Old
setActiveDrawerLink();
// New
setActiveNavLink();
```

- [ ] **Step 3: Update the export in `initNavigation`**

In `src/script.js` line 105-115, no changes needed — `initNavigation` doesn't export `setActiveDrawerLink`. Verify no other file imports it:

Run: `grep -r "setActiveDrawerLink" src/`

Expected: No results (the function was only called internally on line 102, now replaced).

- [ ] **Step 4: Build and verify**

Run: `npm run build`

Expected: Build succeeds with no errors.

- [ ] **Step 5: Commit**

```bash
git add src/script.js
git commit -m "fix: replace setActiveDrawerLink with PAGE_SECTION_MAP for Netlify clean URLs + desktop nav active state"
```

---

### Task 2: Add CSS for nav-links active state and hover

**Files:**

- Modify: `src/input.css:178-182` (after `html.dark .nav-links a` block)

- [ ] **Step 1: Add hover and active state styles for `.nav-links a`**

In `src/input.css`, after line 182 (`}` closing `html.dark .nav-links a`), insert:

```css
/* Desktop nav-links hover */
.nav-links a:hover {
  background: rgba(0, 73, 58, 0.06);
  border-radius: 10px;
}

/* Desktop nav-links active state (pill style) */
.nav-links a.nav-link-active {
  background: rgba(0, 73, 58, 0.12);
  color: var(--color-brand-primary);
  font-weight: 600;
  border-radius: 10px;
}

/* Dark mode nav-links hover */
html.dark .nav-links a:hover {
  background: rgba(255, 255, 255, 0.08);
}

/* Dark mode nav-links active */
html.dark .nav-links a.nav-link-active {
  background: rgba(255, 255, 255, 0.12);
  color: var(--color-brand-deep);
}

/* Dark mode drawer-link-active (previously missing) */
html.dark .drawer-links li a.drawer-link-active {
  background: rgba(255, 255, 255, 0.12);
  color: var(--color-brand-deep);
}
```

- [ ] **Step 2: Add padding to nav-links anchors for pill background visibility**

The current `.nav-links a` rule (line 177-179) uses `@apply` but has no padding, so the pill background won't be visible. Need to add padding.

In `src/input.css`, change line 178:

```css
/* Old */
.nav-links a {
  @apply text-brand-deep font-medium transition-colors duration-300 hover:text-brand-accent;
}

/* New */
.nav-links a {
  @apply text-brand-deep font-medium transition-colors duration-300;
  padding: 0.375rem 0.75rem;
  border-radius: 10px;
}

/* New hover — only color change, background handled by the :hover rule below */
.nav-links a:hover {
  color: var(--color-brand-accent);
  background: rgba(0, 73, 58, 0.06);
  border-radius: 10px;
}
```

Then remove the duplicate `.nav-links a:hover` from Step 1 (since we just defined it here). The final insertion after line 182 should be:

```css
/* Desktop nav-links active state (pill style) */
.nav-links a.nav-link-active {
  background: rgba(0, 73, 58, 0.12);
  color: var(--color-brand-primary);
  font-weight: 600;
  border-radius: 10px;
}

/* Dark mode nav-links hover */
html.dark .nav-links a:hover {
  background: rgba(255, 255, 255, 0.08);
}

/* Dark mode nav-links active */
html.dark .nav-links a.nav-link-active {
  background: rgba(255, 255, 255, 0.12);
  color: var(--color-brand-deep);
}

/* Dark mode drawer-link-active (previously missing) */
html.dark .drawer-links li a.drawer-link-active {
  background: rgba(255, 255, 255, 0.12);
  color: var(--color-brand-deep);
}
```

- [ ] **Step 3: Build and verify**

Run: `npm run build`

Expected: Build succeeds. The compiled CSS in `dist/` contains `.nav-links a:hover`, `.nav-links a.nav-link-active`, and dark-mode variants.

- [ ] **Step 4: Commit**

```bash
git add src/input.css
git commit -m "feat: add pill-style active state and hover to desktop nav-links + dark mode"
```

---

### Task 3: Add missing Netlify redirects for lives pages

**Files:**

- Modify: `netlify.toml` (add after line 43, before `[[headers]]`)

- [ ] **Step 1: Add /lives and /lives-list redirects**

In `netlify.toml`, after the `/sobre` redirect block (line 43), insert before the first `[[headers]]` block:

```toml

[[redirects]]
 from = "/lives-list"
 to = "/lives-list.html"
 status = 200

[[redirects]]
 from = "/lives"
 to = "/lives.html"
 status = 200
```

- [ ] **Step 2: Commit**

```bash
git add netlify.toml
git commit -m "fix: add missing Netlify clean-URL redirects for lives pages"
```

---

### Task 4: Visual verification

- [ ] **Step 1: Run dev server**

Run: `npm run dev`

- [ ] **Step 2: Verify desktop (>=769px)**

Open http://localhost:5173. Expected:

- Nav links visible: Início has pill background (active)
- Click "Artigos" → artigos.html loads → "Artigos" has pill background, "Início" no longer active
- Hover over any nav-link: subtle background appears + text color changes

- [ ] **Step 3: Verify sub-pages**

Open http://localhost:5173/evento.html (or navigate to an event). Expected:

- "Eventos" has pill active state in both desktop nav-links and drawer

- [ ] **Step 4: Verify mobile (<769px)**

Resize to mobile width. Expected:

- Nav links hidden, hamburger visible
- Open drawer → correct link has active background
- "Início" is NOT active when on artigos.html

- [ ] **Step 5: Verify dark mode**

Toggle dark mode. Expected:

- Desktop nav active: light background pill
- Desktop nav hover: subtle light background
- Drawer active: light background
- All text colors appropriate for dark mode

- [ ] **Step 6: Final commit if any fixes needed**

---

## Self-Review

1. **Spec coverage:** Bug fix (Início always active on Netlify)? Yes — `PAGE_SECTION_MAP` with clean URLs. Desktop active state? Yes — Task 2 CSS + Task 1 JS. Sub-page inheritance? Yes — map entries like `'evento.html': 'eventos.html'`. Hover? Yes — Task 2 CSS. Pill style? Yes — `border-radius: 10px` + background.
2. **Placeholder scan:** No TBDs, TODOs, or vague steps. All code shown inline.
3. **Type consistency:** `nav-link-active` class used in both JS (Task 1) and CSS (Task 2). `drawer-link-active` kept as-is. `PAGE_SECTION_MAP` keys match both `.html` and clean-URL paths. `setActiveNavLink` replaces `setActiveDrawerLink` consistently.
