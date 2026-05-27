# Event Detail Page Parity — MPA → Next.js

**Date:** 2026-05-26
**Status:** Approved
**Scope:** Achieve full visual parity between `evento.html` (MPA) and `/[lang]/eventos/[slug]` (Next.js)

## Problem

The Next.js event detail page (`page.js`) uses inline Tailwind utility classes and a different layout structure than the MPA version. This causes visual differences:

- No hero section with background color
- No event details card (Tipo, Data, Horário, Localização)
- Registration button uses different styling
- SpeakersList uses wrong CSS class names (unstyled)
- Similar events section lacks background and uses 2-column instead of 3
- Date is not formatted (raw ISO string)
- Content lacks proper section wrappers

## Components to Modify

### 1. `app/[lang]/(public)/eventos/[slug]/page.js`

**Full rewrite** to use MPA CSS classes instead of inline Tailwind.

#### Hero Section
- Wrap in `<section className="event-hero">` with `<div className="event-hero-content">`
- Category badge: `<span className="event-category-badge">` with inline color style
- Title: `<h1 className="event-hero-title">`
- Image: `<div className="event-hero-image-wrapper">` containing `<Image>` with `className="event-featured-image"`
- Meta bar: `<div className="event-meta-bar">` with `<div className="event-meta-group">` items, each containing type badge + date + location + time

#### Event Details Card
- New section: `<div className="event-details-card">`
- Title: `<h2>` with `data-i18n="evento_detail.event_details_title"` / `tFn()`
- Grid: `<div className="event-details-grid">` with 4x `<div className="event-detail-item">`
- Items: Tipo de Evento, Data (formatted), Horário (with duration), Localização

#### Capacity Section
- Wrap CapacityBar in `<div className="event-capacity-section">`
- Title: `<h3>` with i18n key `evento_detail.available_spots`

#### Registration Button
- Past: `<span className="btn btn-secondary btn-lg">` disabled
- Full: `<span className="btn btn-primary btn-lg btn-disabled">` disabled
- Active: `<Link className="btn btn-primary btn-lg btn-inscrever">` with inline `backgroundColor: color`

#### Content Section Wrapper
- Wrap main content in `<section className="event-content-section">`

#### Similar Events
- Wrap in `<section className="event-related-section">`
- Grid: 3 columns on large screens (`lg:grid-cols-3`)
- Title: `tFn('evento_detail.related_events')`

#### Date Formatting
- Add `formatDate(dateStr, lang)` helper that returns localized long date (e.g., "25 de maio de 2026")
- Use `lang === 'en' ? 'en-US' : 'pt-PT'` locale

### 2. `components/content/SpeakersList.jsx`

**Fix CSS class names** to match globals.css definitions:

| Current (wrong) | Correct |
|---|---|
| `speaker-avatar` | `speaker-card-avatar` |
| `speaker-name` | `speaker-card-name` |
| `speaker-role` | `speaker-card-role` |
| `speaker-org` | `speaker-card-organization` |

**Add Show More/Show Less** button using `.speaker-show-more-btn` / `.speaker-show-less-btn` classes (defined in globals.css), replacing the current simple link.

- Mobile: show 2 initially
- Desktop: show 3 initially
- Button text: `Mostrar mais {N} palestrantes` / `Ocultar palestrantes`

### 3. `components/content/SimilarEvents.jsx`

- Accept `title` prop from Server Component parent (already has `tFn()`)
- Default to hardcoded "Eventos Similares" if no title prop

No need to add LangContext — Server Component parent passes translated title.

### 4. `components/content/CapacityBar.jsx`

No changes needed — already uses correct CSS classes.

### 5. `components/ui/EventCard.jsx`

No changes needed for the card itself.

## CSS Classes Used (all exist in globals.css)

- `.event-hero` — `bg-brand-bg-alt py-12 md:py-16`
- `.event-hero-content` — `max-w-5xl mx-auto`
- `.event-category-badge` — `text-xs font-bold uppercase tracking-wider px-3 py-1 rounded-full inline-block mb-6`
- `.event-hero-title` — `text-4xl md:text-6xl font-bold text-brand-deep leading-tight mb-8`
- `.event-hero-image-wrapper` — `w-full rounded-2xl overflow-hidden shadow-md-soft mb-8`
- `.event-featured-image` — `w-full h-auto object-cover`
- `.event-meta-bar` — `py-8 border-t border-brand-divider/30 flex flex-wrap items-center gap-8`
- `.event-meta-group` — `flex flex-wrap items-center gap-3`
- `.event-meta-badge` — `text-xs font-bold px-3 py-1 rounded-full inline-flex items-center`
- `.event-content-section` — `py-16 md:py-24 bg-brand-bg`
- `.event-details-card` — `bg-brand-bg-alt rounded-2xl p-8 mt-12`
- `.event-details-grid` — `grid grid-cols-1 md:grid-cols-2 gap-8`
- `.event-detail-item` — `flex flex-col`
- `.event-capacity-section` — `bg-brand-bg-alt rounded-2xl p-8`
- `.speakers-section` — `w-full`
- `.speakers-grid` — `grid grid-cols-2 md:grid-cols-3 gap-8`
- `.speaker-card` — card with bg, border, hover effects
- `.speaker-card-avatar` — `w-20 h-20 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-4`
- `.speaker-card-name` — `text-xl font-bold text-brand-deep mb-1`
- `.speaker-card-role` — `text-base text-brand-deep/60 mb-1`
- `.speaker-card-organization` — `text-sm text-brand-deep/50`
- `.speaker-show-more-btn` / `.speaker-show-less-btn` — outlined buttons with hover fill
- `.event-related-section` — `py-20 md:py-24 bg-brand-bg-alt`
- `.btn`, `.btn-primary`, `.btn-lg`, `.btn-inscrever`, `.btn-secondary`, `.btn-disabled` — global button classes

## Files Changed

1. `app/[lang]/(public)/eventos/[slug]/page.js` — rewrite layout
2. `components/content/SpeakersList.jsx` — fix class names + show more/less
3. `components/content/SimilarEvents.jsx` — add i18n

## Verification

1. Visual comparison: open both `evento.html?id=<slug>` and `/pt/eventos/<slug>` side by side
2. Check hero section has bg-brand-bg-alt background
3. Check event details card renders with 4 detail items
4. Check capacity section is wrapped in card
5. Check registration button uses correct classes and states
6. Check speakers cards have proper avatar/name/role/org styling
7. Check show more/less speakers button works
8. Check similar events section has bg alternado and 3-column grid
9. Check dates are formatted (not raw ISO)
10. Dark mode: verify all sections look correct
11. Mobile: verify responsive layout
