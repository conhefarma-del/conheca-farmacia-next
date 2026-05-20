# Admin Design Alignment with Main Website

**Date:** 2026-05-18
**Status:** Approved
**Scope:** Align admin panel visual identity with main website design

---

## Problem Statement

The admin panel (`src/admin/`) uses a different visual language than the main website (`src/input.css`). This creates a disjointed user experience where the admin feels like a separate application rather than part of the same brand.

## Current State Analysis

### Main Website Design Tokens (`input.css`)
- **Colors:** `brand-primary: #00493a`, `brand-accent: #0a844f`, `brand-deep: #002a32`
- **Background:** `brand-bg: #ffffff`, `brand-bg-alt: #f9f9f9`
- **Typography:** Inter font family
- **Border radius:** `rounded-2xl` (16px) for cards, `rounded-lg` (8px) for inputs/buttons
- **Shadows:** `shadow-soft: 0 4px 20px rgba(0, 42, 50, 0.05)`, `shadow-md-soft: 0 10px 30px rgba(0, 42, 50, 0.08)`
- **Dark mode:** Full support with `html.dark` class toggle
- **Transitions:** Smooth 0.2s-0.3s transitions on all interactive elements
- **Hover effects:** `brightness-110`, `scale-[1.02]`, `translate-y-2`

### Admin Panel Current State (`admin.css`)
- **Colors:** Similar but not identical (`--admin-primary: #00493a`, `--admin-accent: #0a844f`)
- **Background:** `--admin-bg: #f9f9f9`, `--admin-card-bg: #ffffff` (inverted from website)
- **Border radius:** 8px for everything (smaller than website)
- **Shadows:** None defined
- **Dark mode:** Only `prefers-color-scheme` media query, no toggle
- **Transitions:** Minimal
- **Hover effects:** Basic color changes only

## Design Decisions

### 1. Color Variables Alignment

**Update admin CSS variables to match website:**

| Admin Variable | Current | New (matches website) |
|----------------|---------|----------------------|
| `--admin-bg` | `#f9f9f9` | `#ffffff` |
| `--admin-card-bg` | `#ffffff` | `#f9f9f9` |
| `--admin-text` | `#1a1a1a` | `#002a32` |
| `--admin-text-muted` | `#6b7280` | `#6b7280` (keep) |
| `--admin-border` | `#e5e7eb` | `#dddddd` |

**Keep as-is (already aligned):**
- `--admin-primary: #00493a`
- `--admin-accent: #0a844f`
- `--admin-primary-deep: #002a32`

**Add new variables:**
- `--shadow-soft: 0 4px 20px rgba(0, 42, 50, 0.05)`
- `--shadow-md-soft: 0 10px 30px rgba(0, 42, 50, 0.08)`

### 2. Border Radius Alignment

| Element | Admin Current | Website | New Admin |
|---------|---------------|---------|-----------|
| Cards | 8px | 16px | 16px |
| Inputs | 8px | 8px | 8px (keep) |
| Buttons | 8px | 8px | 8px (keep) |
| Sidebar | 0px | N/A | 0px (keep) |
| Badges | 4px | full | full |

### 3. Component Updates

#### Sidebar
- Keep current structure (already good)
- Update colors to use CSS variables
- Add dark mode support with `html.dark`

#### Top Bar
- Add `shadow-soft` for separation
- Use `border-brand-divider/30` for borders

#### Stat Cards
- Update border-radius to 16px
- Add `shadow-soft` at rest
- Add `shadow-md-soft` on hover
- Keep colorful gradients (already modern)

#### List Cards (articles, events, lives)
- Update to `rounded-2xl` (16px)
- Add `shadow-soft` at rest
- Add `shadow-md-soft` and `hover:-translate-y-2` on hover
- Use website colors for tags/badges

#### Forms
- Keep `rounded-lg` (8px) for inputs
- Add focus with `ring-2 ring-brand-accent` (matches website)
- Use `border-brand-divider` for borders
- Add `shadow-soft` at rest

#### Buttons
- `btn-primary`: Add `hover:brightness-110 hover:scale-[1.02] active:scale-[0.98]`
- `btn-secondary`: Add `border-2 border-brand-primary` and hover effects
- `btn-danger`: Keep as-is (status colors are different)

### 4. Dark Mode Implementation

**Toggle button:** Add to sidebar (matches website pattern)
**localStorage:** Persist preference
**CSS Variables:**

```css
html.dark {
  --admin-bg: #0a0f0d;
  --admin-card-bg: #111816;
  --admin-text: #e5e7eb;
  --admin-text-muted: #94a3b8;
  --admin-border: #1f2927;
  --admin-divider: rgba(255, 255, 255, 0.1);
}
```

**Transitions:** Smooth 0.2s transitions between modes

---

### 5. Mobile Responsiveness

**Current State:**
- Admin pages have basic responsive styles but are not optimized for mobile
- Sidebar collapses on mobile but content doesn't adapt well
- Forms are too wide on small screens
- Tables overflow on mobile

**Mobile-First Approach:**

#### Sidebar (Mobile)
- Collapsible sidebar with hamburger menu
- Full-screen overlay when open
- Smooth slide-in animation
- Close on link click or outside click

#### Top Bar (Mobile)
- Stack search and actions vertically
- Reduce padding
- Hide non-essential icons

#### Stat Cards (Mobile)
- Single column layout
- Reduce padding
- Stack vertically

#### List Cards (Mobile)
- Single column layout
- Full-width cards
- Reduce image height
- Stack meta information vertically

#### Forms (Mobile)
- Single column grid
- Full-width inputs
- Stack form actions vertically
- Larger touch targets (min 44px)

#### Tables (Mobile)
- Horizontal scroll wrapper
- Sticky first column
- Compact cell padding

**Breakpoints:**
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

**CSS Media Queries:**
```css
@media (max-width: 768px) {
  .admin-sidebar {
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }
  .admin-sidebar.open {
    transform: translateX(0);
  }
  .admin-main-content {
    margin-left: 0;
  }
  .admin-stats-grid {
    grid-template-columns: 1fr;
  }
  .admin-form-grid {
    grid-template-columns: 1fr;
  }
  .admin-table-wrapper {
    overflow-x: auto;
  }
}
```

---

## Implementation Strategy

**Approach:** Incremental CSS updates (not full rewrite)

1. Update CSS variables in `:root` and add `html.dark` block
2. Update component styles (cards, buttons, forms)
3. Add shadow utilities
4. Add dark mode toggle to sidebar
5. Add dark mode JavaScript logic
6. Test all pages in both modes

## Files to Modify

- `src/admin/styles/admin.css` - Main CSS updates
- `src/admin/dashboard.html` - Add dark mode toggle
- `src/admin/artigos/index.html` - Add dark mode toggle
- `src/admin/eventos/index.html` - Add dark mode toggle
- `src/admin/lives/index.html` - Add dark mode toggle
- `src/admin/artigos/new.html` - Add dark mode toggle
- `src/admin/artigos/edit.html` - Add dark mode toggle
- `src/admin/eventos/new.html` - Add dark mode toggle
- `src/admin/eventos/edit.html` - Add dark mode toggle
- `src/admin/lives/new.html` - Add dark mode toggle
- `src/admin/lives/edit.html` - Add dark mode toggle
- `src/admin/lib/dark-mode.js` - New file for dark mode logic

## Success Criteria

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

---

## Spec Self-Review

### Placeholder Scan
- No TBD/TODO sections
- All values are explicit

### Internal Consistency
- Colors match between sections
- Border-radius values are consistent
- Shadow definitions are consistent

### Scope Check
- Focused on CSS updates and dark mode
- No unrelated refactoring
- Can be implemented in single plan

### Ambiguity Check
- All CSS values are specific
- Component behaviors are defined
- Dark mode variables are explicit

**Result:** Spec is ready for implementation planning.
