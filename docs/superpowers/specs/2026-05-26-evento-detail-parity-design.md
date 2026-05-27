---
name: Event Detail Page Parity — MPA → Next.js
description: Spec for making the Next.js event detail page visually identical to the MPA evento.html
---

# Event Detail Page Parity Spec

## Goal
Make `app/[lang]/(public)/eventos/[slug]/page.js` visually identical to the MPA `evento.html` by reusing existing CSS classes from `globals.css`.

## Differences Found

### 1. Hero Section
- **MPA**: `event-hero` wrapper (bg-brand-bg-alt py-12), `event-hero-content` (max-w-5xl), `event-hero-title` (text-4xl md:text-6xl), `event-hero-image-wrapper` with natural height, `event-meta-bar` with `event-meta-badge`
- **Next.js**: No wrapper, inline Tailwind, smaller title (text-3xl lg:text-5xl), next/image fill with fixed height, grid with emojis instead of meta bar

### 2. Content Structure  
- **MPA**: `event-content-section` (py-16 bg-brand-bg), `event-body-wrapper`, `event-body` for description, `event-details-card` (bg-alt rounded-2xl 4-item grid), `event-capacity-section` (card with bg-alt), `btn btn-primary btn-lg btn-inscrever`
- **Next.js**: No content section wrapper, prose for description, no event details card, no card wrapper for capacity, Link with inline styles

### 3. Speakers
- **MPA**: `speaker-card-avatar`, `speaker-card-name`, `speaker-card-role`, `speaker-card-organization`, `speaker-show-more-btn`/`speaker-show-less-btn`, `speaker-card--hidden` CSS class
- **Next.js**: `speaker-avatar`, `speaker-name`, `speaker-role`, `speaker-org`, text-brand-accent link for show/hide, JS slice() for hiding

### 4. Similar Events
- **MPA**: `event-related-section` (py-20 bg-alt, 3-col grid), custom card HTML
- **Next.js**: Inline Tailwind (2-col grid), SimilarEvents component

## Changes Required

### `app/[lang]/(public)/eventos/[slug]/page.js`
1. Wrap hero in `section.event-hero > div.container-center > div.event-hero-content`
2. Use `span.event-category-badge` for category
3. Use `h1.event-hero-title` for title
4. Use `div.event-hero-image-wrapper > img.event-featured-image` (or Image with same classes)
5. Use `div.event-meta-bar` with `div.event-meta-group` > `span.event-meta-badge` for type/date/location/time
6. Wrap content in `section.event-content-section > div.container-center > div.event-body-full`
7. Use `div.event-body-wrapper` > `div.event-body` for description
8. Add `div.event-details-card` with `div.event-details-grid` (4 items: type, date, time, location)
9. Wrap capacity in `div.event-capacity-section` (card bg-alt)
10. Use `button.btn.btn-primary.btn-lg.btn-inscrever` for registration
11. Use `div.speakers-section` with proper title class
12. Use `section.event-related-section` for similar events (3-col grid)

### `components/content/SpeakersList.jsx`
1. Change `speaker-avatar` → `speaker-card-avatar`
2. Change `speaker-name` → `speaker-card-name`
3. Change `speaker-role` → `speaker-card-role`
4. Change `speaker-org` → `speaker-card-organization`
5. Use `speaker-show-more-btn`/`speaker-show-less-btn` classes
6. Use `speaker-card--hidden` CSS class instead of JS slice

### `components/content/CapacityBar.jsx`
1. Wrap in card-style section matching MPA `event-capacity-section`
2. Use `capacity-status` with `status-dot` and `status-text`

### `components/content/SimilarEvents.jsx`
1. Use `section.event-related-section` wrapper
2. Use 3-col grid like MPA
3. Use `section-title` class for heading
4. Translate heading with i18n

## Files to Modify
- `app/[lang]/(public)/eventos/[slug]/page.js` (major rewrite)
- `components/content/SpeakersList.jsx` (class names + show/hide)
- `components/content/CapacityBar.jsx` (card wrapper)
- `components/content/SimilarEvents.jsx` (section wrapper + grid)
