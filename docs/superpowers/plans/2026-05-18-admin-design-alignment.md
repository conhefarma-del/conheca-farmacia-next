# Admin Design Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align admin panel visual identity with main website design, including dark mode and mobile responsiveness.

**Architecture:** Incremental CSS updates to `admin.css` + new dark mode module + HTML updates for dark mode toggle. Mobile responsiveness via media queries.

**Tech Stack:** CSS (variables, transitions, media queries), JavaScript (dark mode toggle, localStorage)

---

## File Structure

| File | Responsibility |
|------|---------------|
| `src/admin/styles/admin.css` | All admin styles, CSS variables, dark mode, responsive |
| `src/admin/lib/dark-mode.js` | Dark mode toggle logic, localStorage persistence |
| `src/admin/dashboard.html` | Add dark mode toggle button |
| `src/admin/artigos/index.html` | Add dark mode toggle button |
| `src/admin/eventos/index.html` | Add dark mode toggle button |
| `src/admin/lives/index.html` | Add dark mode toggle button |
| `src/admin/artigos/new.html` | Add dark mode toggle button |
| `src/admin/artigos/edit.html` | Add dark mode toggle button |
| `src/admin/eventos/new.html` | Add dark mode toggle button |
| `src/admin/eventos/edit.html` | Add dark mode toggle button |
| `src/admin/lives/new.html` | Add dark mode toggle button |
| `src/admin/lives/edit.html` | Add dark mode toggle button |

---

### Task 1: Update CSS Variables

**Files:**
- Modify: `src/admin/styles/admin.css:1-43`

- [ ] **Step 1: Update `:root` variables**

Replace the `:root` block (lines 1-43) with aligned variables:

```css
:root {
  /* Brand Colors - aligned with input.css */
  --admin-primary: #00493a;
  --admin-primary-hover: #005c4a;
  --admin-primary-deep: #002a32;
  --admin-accent: #0a844f;

  /* UI Colors - aligned with input.css */
  --admin-bg: #ffffff;
  --admin-card-bg: #f9f9f9;
  --admin-text: #002a32;
  --admin-text-muted: #6b7280;
  --admin-border: #dddddd;
  --admin-divider: rgba(0, 73, 58, 0.1);

  /* Status Colors */
  --admin-success: #0a844f;
  --admin-success-bg: #e6f4ea;
  --admin-danger: #ef4444;
  --admin-danger-bg: #fee2e2;
  --admin-warning: #f59e0b;
  --admin-warning-bg: #fef3c7;

  /* Stat Card Colors - Modern Gradients */
  --stat-green: #10b981;
  --stat-green-light: #059669;
  --stat-purple: #8b5cf6;
  --stat-purple-light: #7c3aed;
  --stat-orange: #f97316;
  --stat-orange-light: #ea580c;
  --stat-blue: #3b82f6;
  --stat-blue-light: #2563eb;
  --stat-black: #1f2937;
  --stat-black-light: #111827;
  --stat-pink: #ec4899;
  --stat-pink-light: #db2777;
  --stat-cyan: #06b6d4;
  --stat-cyan-light: #0891b2;

  /* Typography */
  --font-sans: "Inter", -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-mono: "JetBrains Mono", 'Monaco', 'Consolas', monospace;

  /* Shadows - aligned with input.css */
  --shadow-soft: 0 4px 20px rgba(0, 42, 50, 0.05);
  --shadow-md-soft: 0 10px 30px rgba(0, 42, 50, 0.08);
}
```

- [ ] **Step 2: Add dark mode variables**

Add after the `:root` block:

```css
/* Dark Mode - aligned with input.css */
html.dark {
  --admin-bg: #0a0f0d;
  --admin-card-bg: #111816;
  --admin-text: #e5e7eb;
  --admin-text-muted: #94a3b8;
  --admin-border: #1f2927;
  --admin-divider: rgba(255, 255, 255, 0.1);
  --admin-success-bg: #064e3b;
  --admin-danger-bg: #7f1d1d;
  --admin-warning-bg: #78350f;
}

html.dark body {
  background-color: var(--admin-bg);
  color: var(--admin-text);
}
```

- [ ] **Step 3: Validate CSS syntax**

Run: `npx stylelint src/admin/styles/admin.css --fix` or manually verify no syntax errors.

- [ ] **Step 4: Commit**

```bash
git add src/admin/styles/admin.css
git commit -m "feat(admin): align CSS variables with main website design"
```

---

### Task 2: Update Card Styles

**Files:**
- Modify: `src/admin/styles/admin.css` (card-related styles)

- [ ] **Step 1: Update `.admin-card` styles**

Find and replace the `.admin-card` rule:

```css
.admin-card {
  background: var(--admin-card-bg);
  border: 1px solid var(--admin-border);
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: var(--shadow-soft);
  transition: box-shadow 0.2s, transform 0.2s;
}
```

- [ ] **Step 2: Add card hover effect**

Add after `.admin-card`:

```css
.admin-card:hover {
  box-shadow: var(--shadow-md-soft);
}
```

- [ ] **Step 3: Update stat card styles**

Find `.admin-stat-card` or similar and update:

```css
.admin-stat-card,
[class*="stat-card"] {
  border-radius: 16px;
  box-shadow: var(--shadow-soft);
  transition: box-shadow 0.2s, transform 0.2s;
}

.admin-stat-card:hover,
[class*="stat-card"]:hover {
  box-shadow: var(--shadow-md-soft);
  transform: translateY(-2px);
}
```

- [ ] **Step 4: Update dashboard card styles**

Find `.admin-dashboard-card` and update:

```css
.admin-dashboard-card {
  background: var(--admin-card-bg);
  border: 1px solid var(--admin-border);
  border-radius: 16px;
  padding: 24px;
  box-shadow: var(--shadow-soft);
}
```

- [ ] **Step 5: Commit**

```bash
git add src/admin/styles/admin.css
git commit -m "feat(admin): update card styles with 16px radius and soft shadows"
```

---

### Task 3: Update Button Styles

**Files:**
- Modify: `src/admin/styles/admin.css` (button-related styles)

- [ ] **Step 1: Update `.admin-btn` base styles**

Find and replace the `.admin-btn` rule:

```css
.admin-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  font-family: var(--font-sans);
  cursor: pointer;
  border: none;
  text-decoration: none;
  transition: all 0.2s;
}
```

- [ ] **Step 2: Update `.admin-btn-primary` with hover effects**

```css
.admin-btn-primary {
  background: var(--admin-primary);
  color: white;
}

.admin-btn-primary:hover {
  background: var(--admin-primary-hover);
  filter: brightness(1.1);
  transform: scale(1.02);
}

.admin-btn-primary:active {
  transform: scale(0.98);
}
```

- [ ] **Step 3: Update `.admin-btn-secondary` with border**

```css
.admin-btn-secondary {
  background: var(--admin-bg);
  color: var(--admin-primary);
  border: 2px solid var(--admin-primary);
}

.admin-btn-secondary:hover {
  background: var(--admin-primary);
  color: white;
  transform: scale(1.02);
}

.admin-btn-secondary:active {
  transform: scale(0.98);
}
```

- [ ] **Step 4: Update `.admin-btn-danger`**

```css
.admin-btn-danger {
  background: var(--admin-danger);
  color: white;
}

.admin-btn-danger:hover {
  background: #dc2626;
  transform: scale(1.02);
}

.admin-btn-danger:active {
  transform: scale(0.98);
}
```

- [ ] **Step 5: Update `.admin-btn-sm`**

```css
.admin-btn-sm {
  padding: 6px 12px;
  font-size: 13px;
}
```

- [ ] **Step 6: Commit**

```bash
git add src/admin/styles/admin.css
git commit -m "feat(admin): update button styles with hover effects matching website"
```

---

### Task 4: Update Form Styles

**Files:**
- Modify: `src/admin/styles/admin.css` (form-related styles)

- [ ] **Step 1: Update input styles**

Find and replace `.admin-input`, `.admin-textarea` rules:

```css
.admin-input,
.admin-textarea {
  width: 100%;
  padding: 10px 14px;
  border: 1px solid var(--admin-border);
  border-radius: 8px;
  font-size: 14px;
  font-family: var(--font-sans);
  transition: border-color 0.2s, box-shadow 0.2s;
  background: var(--admin-card-bg);
  color: var(--admin-text);
  box-sizing: border-box;
}

.admin-input:focus,
.admin-textarea:focus {
  outline: none;
  border-color: var(--admin-accent);
  box-shadow: 0 0 0 3px rgba(10, 132, 79, 0.1);
}

.admin-input::placeholder,
.admin-textarea::placeholder {
  color: var(--admin-text-muted);
  opacity: 0.7;
}
```

- [ ] **Step 2: Update form group styles**

```css
.admin-form-group {
  margin-bottom: 20px;
}

.admin-form-group label {
  display: block;
  font-weight: 500;
  margin-bottom: 8px;
  color: var(--admin-text);
  font-size: 14px;
}
```

- [ ] **Step 3: Update form grid**

```css
.admin-form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0 24px;
}
```

- [ ] **Step 4: Update form actions**

```css
.admin-form-actions {
  display: flex;
  gap: 12px;
  align-items: center;
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid var(--admin-border);
}
```

- [ ] **Step 5: Update error message**

```css
.admin-error-message {
  background: var(--admin-danger-bg);
  color: var(--admin-danger);
  padding: 12px 16px;
  border-radius: 8px;
  font-size: 14px;
  margin-bottom: 16px;
}
```

- [ ] **Step 6: Commit**

```bash
git add src/admin/styles/admin.css
git commit -m "feat(admin): update form styles with focus rings matching website"
```

---

### Task 5: Update Table and List Styles

**Files:**
- Modify: `src/admin/styles/admin.css` (table-related styles)

- [ ] **Step 1: Add table wrapper for mobile scroll**

```css
.admin-table-wrapper {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  border-radius: 16px;
  border: 1px solid var(--admin-border);
  background: var(--admin-card-bg);
  box-shadow: var(--shadow-soft);
}
```

- [ ] **Step 2: Update table styles**

```css
.admin-table {
  width: 100%;
  border-collapse: collapse;
}

.admin-table th,
.admin-table td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid var(--admin-border);
  font-size: 14px;
  color: var(--admin-text);
}

.admin-table th {
  background: var(--admin-card-bg);
  font-weight: 600;
  color: var(--admin-text-muted);
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.admin-table tr:hover {
  background: var(--admin-bg);
}
```

- [ ] **Step 3: Commit**

```bash
git add src/admin/styles/admin.css
git commit -m "feat(admin): update table styles with rounded corners and shadows"
```

---

### Task 6: Create Dark Mode Module

**Files:**
- Create: `src/admin/lib/dark-mode.js`

- [ ] **Step 1: Create dark-mode.js**

```javascript
/**
 * Dark Mode Toggle for Admin Panel
 * Persists preference in localStorage
 * Syncs with html.dark class
 */

const STORAGE_KEY = 'admin-dark-mode';

function isDarkMode() {
  return document.documentElement.classList.contains('dark');
}

function setDarkMode(enabled) {
  document.documentElement.classList.toggle('dark', enabled);
  localStorage.setItem(STORAGE_KEY, enabled ? 'true' : 'false');
  updateToggleIcon();
}

function toggleDarkMode() {
  setDarkMode(!isDarkMode());
}

function updateToggleIcon() {
  const toggleBtn = document.getElementById('dark-mode-toggle');
  if (!toggleBtn) return;

  const sunIcon = toggleBtn.querySelector('.sun-icon');
  const moonIcon = toggleBtn.querySelector('.moon-icon');

  if (isDarkMode()) {
    sunIcon.style.display = 'none';
    moonIcon.style.display = 'block';
  } else {
    sunIcon.style.display = 'block';
    moonIcon.style.display = 'none';
  }
}

function initDarkMode() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored === 'true') {
    document.documentElement.classList.add('dark');
  }
  updateToggleIcon();
}

export { initDarkMode, toggleDarkMode, isDarkMode };
```

- [ ] **Step 2: Validate syntax**

Run: `node --check src/admin/lib/dark-mode.js`

- [ ] **Step 3: Commit**

```bash
git add src/admin/lib/dark-mode.js
git commit -m "feat(admin): add dark mode toggle module with localStorage"
```

---

### Task 7: Add Dark Mode Toggle to Sidebar

**Files:**
- Modify: `src/admin/dashboard.html`
- Modify: `src/admin/artigos/index.html`
- Modify: `src/admin/eventos/index.html`
- Modify: `src/admin/lives/index.html`

- [ ] **Step 1: Add toggle button HTML to dashboard.html**

Find the sidebar footer section and add the toggle button before the logout link:

```html
<div class="admin-sidebar-footer">
  <button id="dark-mode-toggle" class="admin-sidebar-btn" title="Alternar modo escuro">
    <svg class="sun-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" width="20" height="20">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
    </svg>
    <svg class="moon-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" width="20" height="20" style="display:none">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
    </svg>
  </button>
  <a href="#" id="logout-btn">
    <!-- existing logout SVG -->
    Sair
  </a>
</div>
```

- [ ] **Step 2: Add import and init to dashboard.html script**

Find the `<script type="module">` block and add:

```javascript
import { initDarkMode, toggleDarkMode } from '../lib/dark-mode.js';

// Init dark mode
initDarkMode();

// Dark mode toggle
document.getElementById('dark-mode-toggle')?.addEventListener('click', toggleDarkMode);
```

- [ ] **Step 3: Repeat for artigos/index.html**

Add the same toggle HTML and script import.

- [ ] **Step 4: Repeat for eventos/index.html**

Add the same toggle HTML and script import.

- [ ] **Step 5: Repeat for lives/index.html**

Add the same toggle HTML and script import.

- [ ] **Step 6: Commit**

```bash
git add src/admin/dashboard.html src/admin/artigos/index.html src/admin/eventos/index.html src/admin/lives/index.html
git commit -m "feat(admin): add dark mode toggle to all index pages"
```

---

### Task 8: Add Dark Mode Toggle to Form Pages

**Files:**
- Modify: `src/admin/artigos/new.html`
- Modify: `src/admin/artigos/edit.html`
- Modify: `src/admin/eventos/new.html`
- Modify: `src/admin/eventos/edit.html`
- Modify: `src/admin/lives/new.html`
- Modify: `src/admin/lives/edit.html`

- [ ] **Step 1: Add toggle button HTML to artigos/new.html**

Same sidebar footer HTML as Task 7.

- [ ] **Step 2: Add import and init to artigos/new.html script**

Same script additions as Task 7.

- [ ] **Step 3: Repeat for artigos/edit.html**

- [ ] **Step 4: Repeat for eventos/new.html**

- [ ] **Step 5: Repeat for eventos/edit.html`

- [ ] **Step 6: Repeat for lives/new.html**

- [ ] **Step 7: Repeat for lives/edit.html**

- [ ] **Step 8: Commit**

```bash
git add src/admin/artigos/new.html src/admin/artigos/edit.html src/admin/eventos/new.html src/admin/eventos/edit.html src/admin/lives/new.html src/admin/lives/edit.html
git commit -m "feat(admin): add dark mode toggle to all form pages"
```

---

### Task 9: Add Mobile Responsiveness

**Files:**
- Modify: `src/admin/styles/admin.css`

- [ ] **Step 1: Add mobile sidebar styles**

```css
/* Mobile Sidebar */
@media (max-width: 768px) {
  .admin-sidebar {
    transform: translateX(-100%);
    transition: transform 0.3s ease;
    position: fixed;
    z-index: 1000;
  }

  .admin-sidebar.open {
    transform: translateX(0);
  }

  .admin-sidebar-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 999;
  }

  .admin-sidebar-overlay.active {
    display: block;
  }

  .admin-main-content {
    margin-left: 0;
  }

  .admin-hamburger {
    display: flex;
  }
}
```

- [ ] **Step 2: Add mobile top bar styles**

```css
@media (max-width: 768px) {
  .admin-top-bar {
    padding: 12px 16px;
    flex-wrap: wrap;
  }

  .admin-search-container {
    max-width: 100%;
    order: 2;
    width: 100%;
  }

  .admin-top-actions {
    order: 1;
    width: 100%;
    justify-content: flex-end;
  }
}
```

- [ ] **Step 3: Add mobile stat cards**

```css
@media (max-width: 768px) {
  .admin-stats-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .admin-stat-card {
    padding: 16px;
  }
}
```

- [ ] **Step 4: Add mobile form styles**

```css
@media (max-width: 768px) {
  .admin-form-grid {
    grid-template-columns: 1fr;
  }

  .admin-form-actions {
    flex-direction: column;
  }

  .admin-form-actions .admin-btn {
    width: 100%;
    justify-content: center;
    min-height: 44px;
  }

  .admin-input,
  .admin-textarea,
  select.admin-input {
    min-height: 44px;
    font-size: 16px; /* Prevents zoom on iOS */
  }
}
```

- [ ] **Step 5: Add mobile table styles**

```css
@media (max-width: 768px) {
  .admin-table-wrapper {
    border-radius: 12px;
    margin: 0 -16px;
    width: calc(100% + 32px);
  }

  .admin-table th,
  .admin-table td {
    padding: 8px 12px;
    font-size: 13px;
  }
}
```

- [ ] **Step 6: Add mobile card styles**

```css
@media (max-width: 768px) {
  .admin-card {
    border-radius: 12px;
    padding: 16px;
  }

  .admin-content {
    padding: 16px;
  }

  .admin-page-title {
    font-size: 22px;
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add src/admin/styles/admin.css
git commit -m "feat(admin): add mobile responsive styles"
```

---

### Task 10: Add Hamburger Menu for Mobile

**Files:**
- Modify: `src/admin/dashboard.html`
- Modify: `src/admin/artigos/index.html`
- Modify: `src/admin/eventos/index.html`
- Modify: `src/admin/lives/index.html`
- Modify: `src/admin/artigos/new.html`
- Modify: `src/admin/artigos/edit.html`
- Modify: `src/admin/eventos/new.html`
- Modify: `src/admin/eventos/edit.html`
- Modify: `src/admin/lives/new.html`
- Modify: `src/admin/lives/edit.html`

- [ ] **Step 1: Add hamburger button HTML**

Add after `<body class="admin-dashboard">` in each file:

```html
<!-- Mobile Hamburger -->
<button class="admin-hamburger" id="hamburger-btn" aria-label="Abrir menu">
  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" width="24" height="24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
  </svg>
</button>
<div class="admin-sidebar-overlay" id="sidebar-overlay"></div>
```

- [ ] **Step 2: Add hamburger CSS**

```css
.admin-hamburger {
  display: none;
  position: fixed;
  top: 16px;
  left: 16px;
  z-index: 1001;
  background: var(--admin-primary);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px;
  cursor: pointer;
  box-shadow: var(--shadow-soft);
}

.admin-hamburger:hover {
  background: var(--admin-primary-hover);
}
```

- [ ] **Step 3: Add hamburger JavaScript**

Add to each page's script block:

```javascript
// Mobile hamburger menu
const hamburgerBtn = document.getElementById('hamburger-btn');
const sidebar = document.querySelector('.admin-sidebar');
const sidebarOverlay = document.getElementById('sidebar-overlay');

function toggleSidebar() {
  sidebar.classList.toggle('open');
  sidebarOverlay.classList.toggle('active');
}

hamburgerBtn?.addEventListener('click', toggleSidebar);
sidebarOverlay?.addEventListener('click', toggleSidebar);

// Close sidebar on link click (mobile)
sidebar?.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => {
    if (window.innerWidth <= 768) {
      sidebar.classList.remove('open');
      sidebarOverlay.classList.remove('active');
    }
  });
});
```

- [ ] **Step 4: Commit**

```bash
git add src/admin/dashboard.html src/admin/artigos/index.html src/admin/eventos/index.html src/admin/lives/index.html src/admin/artigos/new.html src/admin/artigos/edit.html src/admin/eventos/new.html src/admin/eventos/edit.html src/admin/lives/new.html src/admin/lives/edit.html src/admin/styles/admin.css
git commit -m "feat(admin): add hamburger menu for mobile navigation"
```

---

### Task 11: Final Testing and Cleanup

**Files:**
- All modified files

- [ ] **Step 1: Test dark mode toggle**

1. Open `http://localhost:5173/src/admin/dashboard.html`
2. Click dark mode toggle
3. Verify colors change
4. Refresh page
5. Verify dark mode persists
6. Click toggle again
7. Verify light mode returns

- [ ] **Step 2: Test mobile responsiveness**

1. Open browser DevTools (F12)
2. Toggle device toolbar (Ctrl+Shift+M)
3. Select iPhone 14 or similar
4. Verify hamburger menu appears
5. Click hamburger
6. Verify sidebar slides in
7. Click a link
8. Verify sidebar closes
9. Navigate to a form page
10. Verify form is single column

- [ ] **Step 3: Test all pages in both modes**

For each page, verify in both light and dark mode:
- Dashboard
- Artigos index, new, edit
- Eventos index, new, edit
- Lives index, new, edit

- [ ] **Step 4: Run build**

Run: `npm run build`

Expected: Build succeeds with no errors.

- [ ] **Step 5: Final commit if needed**

If any fixes were needed:

```bash
git add -A
git commit -m "fix(admin): final polish for design alignment"
```

---

## Summary

- **Tasks:** 11
- **Files modified:** 13
- **Files created:** 1 (`src/admin/lib/dark-mode.js`)
- **Estimated time:** 45-60 minutes

## Success Criteria Checklist

- [ ] Admin uses same color palette as website
- [ ] Cards have 16px border-radius and soft shadows
- [ ] Buttons have hover effects matching website
- [ ] Forms have focus rings matching website
- [ ] Dark mode works with toggle in sidebar
- [ ] Dark mode persists via localStorage
- [ ] All admin pages work in both modes
- [ ] Transitions are smooth (0.2s-0.3s)
- [ ] Sidebar collapses to hamburger menu on mobile
- [ ] Forms stack to single column on mobile
- [ ] Stat cards stack vertically on mobile
- [ ] Tables scroll horizontally on mobile
- [ ] Touch targets are minimum 44px on mobile
- [ ] No horizontal overflow on any page
