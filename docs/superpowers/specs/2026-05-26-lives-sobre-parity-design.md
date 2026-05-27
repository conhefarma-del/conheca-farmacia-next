# Lives + Sobre Parity Design Spec

**Date**: 2026-05-26
**Goal**: Make Next.js pages `/pt/lives`, `/pt/lives/[slug]`, and `/pt/sobre` visually identical to their MPA counterparts (`lives-list.html`, `lives.html`, `sobre.html`).

## Principle

All Next.js components must use the **existing CSS classes** from `globals.css` (copied from `src/input.css`) — `event-hero`, `host-card-event`, `what-we-do-card`, `audience-item`, `pull-quote-section`, etc. — instead of recreating styles with inline Tailwind. This matches the pattern already used by article/event detail pages.

---

## Page 1: Lives Listing (`/pt/lives`)

### Files to modify
- `app/[lang]/(public)/lives/page.js` — minor: pass correct i18n keys
- `components/pages/LivesPageClient.jsx` — major rewrite
- `components/ui/LiveCard.jsx` — major rewrite to match MPA card structure
- `components/ui/TemporalFilter.jsx` — minor: spacing fix
- `components/ui/FilterButtons.jsx` — verify: uses correct `data-category` attr

### LivesPageClient.jsx — Current vs Target

**Current**: Uses generic `HeroSection`, `TemporalFilter`, `FilterButtons`, `LiveCard` components with Tailwind inline layout.

**Target**: Inline JSX matching MPA structure exactly:

```
<section class="events-hero">                    ← NOT articles-hero
  <div class="container-center">
    <div class="text-center py-12 md:py-16">
      <h1 class="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
      <p class="hero-subtitle text-center">      ← text-center override needed
    </div>
  </div>
</section>

<section class="events-filter-section">
  <div class="container-center">
    <div class="max-w-5xl mx-auto">
      <!-- Temporal Filter -->
      <div class="temporal-filter mb-12">         ← mb-12 not mb-8
        <button class="temporal-btn temporal-btn-active" data-status="upcoming">
        <button class="temporal-btn" data-status="past">
      </div>
      <!-- Category Filter -->
      <div class="category-filter">
        <button class="filter-btn" data-category="all">
        <button class="filter-btn" data-category="live">
        <button class="filter-btn" data-category="webinar">
        <button class="filter-btn" data-category="entrevista">
      </div>
    </div>
  </div>
</section>

<section class="events-grid-section bg-brand-bg-alt">   ← py-20 md:py-24
  <div class="container-center">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-8"> ← 2 cols, NOT 3
      <!-- LiveCard components -->
    </div>
    <!-- No Results -->
    <div class="text-center py-20">
      <div class="text-6xl mb-4">🔍</div>
      <h3 class="text-xl font-bold text-brand-deep">
      <p class="text-brand-deep/60">
    </div>
  </div>
</section>

<NewsletterSection />
```

### Filter i18n keys — must match MPA
- Temporal: `lives_page.filter_upcoming` / `lives_page.filter_past` (NOT `lives_page.proximas` / `lives_page.passadas`)
- Category all: `lives_page.filter_all` (NOT `content.todos`)
- Category live: `lives_page.filter_live`
- Category webinar: `lives_page.filter_webinar`
- Category entrevista: `lives_page.filter_entrevista`

### LiveCard.jsx — Current vs Target

**Current** (list variant): `event-card-img` class, badges using `event-badge`/`event-type-badge`, meta with SVG icons, `event-card-cta` buttons.

**Target** (matching MPA `lives-logic.js` card HTML):

```
<article class="event-card">
  <div class="event-card-header relative">
    <div class="event-card-date-box" style="background-color: ${categoryColor}">
      <div class="day">${day}</div>
      <div class="month">${month}</div>
    </div>
    <img class="event-card-image" ...>
  </div>
  <div class="event-card-content">
    <div class="flex flex-row flex-wrap items-center gap-2 mb-4">
      <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider"
            style="background-color: ${color}20; color: ${color}; border: 1px solid ${color}40">
        ${categoriaLabel}
      </span>
      <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider
                   bg-slate-100 text-slate-600 border border-slate-200">
        ${plataforma}
      </span>
    </div>
    <h3 class="event-card-title">${titulo}</h3>
    <p class="event-card-excerpt">${resumo}</p>
    <div class="event-card-meta">
      <div class="event-meta-item"><span>${hora}</span></div>
      <div class="event-meta-item"><span>${plataforma}</span></div>
    </div>
    <div class="event-card-actions mt-auto">
      <a class="btn btn-secondary btn-small">Saber mais</a>
      <a class="btn btn-primary btn-small" style="background-color: ${color}; border-color: ${color}">
        ${status === 'upcoming' ? 'Aceder Live' : 'Ver Gravação'}
      </a>
    </div>
  </div>
</article>
```

Key differences from current LiveCard:
- `event-card-image` (not `event-card-img`)
- Date box uses `day`/`month` divs (not `event-card-day`/`event-card-month` spans)
- Badges: inline styles with `text-[10px] font-bold uppercase tracking-wider` (not `event-badge` class)
- Buttons: `btn btn-secondary btn-small` + `btn btn-primary btn-small` (not `event-card-cta`)
- Meta: plain `<span>` text (no SVG icons)
- Link: `lives.html?id=${slug}` → `/${lang}/lives/${slug}`

### TemporalFilter.jsx — Fix
- Change `mb-8` to `mb-12` to match MPA

### NewsletterSection i18n keys
- Verify keys used: `lives_page.newsletter_title`, `lives_page.newsletter_subtitle`, `lives_page.newsletter_email_placeholder`, `lives_page.newsletter_submit`, `lives_page.newsletter_privacy`

---

## Page 2: Live Detail (`/pt/lives/[slug]`)

### File to modify
- `app/[lang]/(public)/lives/[slug]/page.js` — major rewrite

### Current problems
1. Hero section uses Tailwind inline (`mb-6`, `flex flex-wrap gap-2`) instead of MPA classes (`event-hero`, `event-hero-content`, `event-category-badge`, `event-hero-title`)
2. Meta info uses emoji icons (`📅`, `🕐`, `📺`) in a 3-col grid instead of `event-meta-bar` with `event-meta-group`
3. Content sections use `bg-gray-50 dark:bg-gray-900 rounded-2xl p-6` instead of `event-details-card`
4. Host card uses inline Tailwind (`flex items-center gap-4`, `w-16 h-16`) instead of `host-card-event` classes
5. No `event-content-section` / `event-body-wrapper` structure

### Target structure (matching MPA `lives.html`)

```
<!-- Breadcrumb OUTSIDE main, before hero -->
<nav id="breadcrumb"><Breadcrumb items={...} /></nav>

<main>
  <!-- Live Hero Section — use event-hero classes -->
  <section class="event-hero">
    <div class="container-center">
      <div class="event-hero-content">
        <span class="event-category-badge" style="background-color: ${color}20; color: ${color}">
          ${categoriaLabel}
        </span>
        <h1 class="event-hero-title">${titulo}</h1>
        <div class="event-hero-image-wrapper">
          <img class="event-featured-image" src={imagem} alt={titulo} />
        </div>
        <div class="event-meta-bar">
          <div class="event-meta-group">
            <span class="event-meta-badge" style="background-color: ${color}20; color: ${color}">
              ${plataforma}
            </span>
            <span class="text-sm font-semibold text-brand-deep/70">
              ${formatDate(data)}
            </span>
          </div>
          <div class="event-meta-group">
            <span class="text-sm text-brand-deep/70">
              ${hora} — ${duration}
            </span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Live Content Section -->
  <section class="event-content-section">
    <div class="container-center">
      <div class="event-grid">
        <div class="event-body-wrapper">

          <!-- Description -->
          <div class="event-body mb-12">${resumo}</div>

          <!-- Quick Access Card -->
          <div class="event-details-card quick-access-card">
            <h2 class="text-2xl font-bold text-brand-deep mb-6">Acesso Rápido</h2>
            <a class="btn btn-primary btn-lg w-full">Aceder Agora</a>
            <!-- Credentials (conditional) -->
            <div class="live-credentials mt-6 p-4 bg-brand-bg-alt rounded-lg">
              <h3 class="text-lg font-bold text-brand-deep mb-3">Informações de Acesso</h3>
              <div>ID da Reunião: <span></span></div>
              <div>Senha: <span></span></div>
            </div>
          </div>

          <!-- Materials Section -->
          <div class="event-details-card mt-8">
            <h2 class="text-2xl font-bold text-brand-deep mb-4">Materiais de Apoio</h2>
            <ul class="materials-list space-y-2">
              <li><a style="color: ${color}">→ Material 1</a></li>
            </ul>
          </div>

          <!-- Host Card -->
          <div class="host-card-event mt-8">
            <div class="host-card-avatar" style="background-color: ${color}">${initials}</div>
            <div class="host-card-role">${cargo}</div>
            <div class="host-card-name">${nome}</div>
            <div class="host-card-organization">${organizacao}</div>
          </div>

        </div>
      </div>
    </div>
  </section>
</main>
```

### Key changes
- Breadcrumb: move OUTSIDE `<main>`, before hero section
- Hero: use `event-hero` > `container-center` > `event-hero-content` classes
- Category badge: `event-category-badge` with inline style for color
- Image: `event-hero-image-wrapper` > `event-featured-image`
- Meta bar: `event-meta-bar` > `event-meta-group` with badges (NOT emoji grid)
- Content: `event-content-section` > `event-grid` > `event-body-wrapper`
- Quick access: `event-details-card quick-access-card` (NOT `bg-gray-50`)
- Credentials: `live-credentials mt-6 p-4 bg-brand-bg-alt rounded-lg`
- Materials: `event-details-card mt-8` with `→ Material N` links
- Host: `host-card-event mt-8` with `host-card-avatar` (w-20 h-20), `host-card-role`, `host-card-name`, `host-card-organization`
- Buttons: `btn btn-primary btn-lg w-full` (NOT `event-card-cta`)

---

## Page 3: Sobre (`/pt/sobre`)

### File to modify
- `app/[lang]/(public)/sobre/page.js` — major rewrite

### Current problems
1. Hero uses `HeroSection` (articles-hero class) instead of `hero` class
2. Breadcrumb is INSIDE HeroSection as children — must be OUTSIDE, before hero
3. Missão section: `bg-brand-bg` instead of `bg-brand-bg-alt` (wrong alternation)
4. O Que Fazemos: `bg-brand-bg-alt` instead of `bg-brand-bg` (inverted), no SVG icons
5. Público-Alvo: `bg-brand-bg` instead of `bg-brand-bg-alt`, no SVG icons (uses bullets instead)
6. Pull Quote: inline `<blockquote>` inside Público-Alvo instead of separate full-width section
7. Missing `section-padding` class on sections

### Target structure (matching MPA `sobre.html`)

```
<!-- Breadcrumb OUTSIDE hero -->
<nav><Breadcrumb items={...} /></nav>

<!-- Section 1: Hero -->
<section class="hero">
  <div class="container-center">
    <div class="text-center py-12 md:py-16">
      <h1 class="hero-title">Sobre Nós</h1>
      <p class="hero-subtitle text-center">${hero_subtitle}</p>
    </div>
  </div>
</section>

<!-- Section 2: Nossa Missão — bg-brand-bg-alt -->
<section class="section-padding bg-brand-bg-alt">
  <div class="container-center">
    <div class="mission-section">
      <h2 class="section-title">Nossa Missão</h2>
      <div class="mission-text text-center">
        <p class="mb-6">${missao_p1}</p>
        <p>${missao_p2}</p>
      </div>
    </div>
  </div>
</section>

<!-- Section 3: O Que Fazemos — bg-brand-bg -->
<section class="section-padding bg-brand-bg">
  <div class="container-center">
    <h2 class="section-title">O Que Fazemos</h2>
    <div class="what-we-do-grid">
      <div class="what-we-do-card">
        <img src="/assets/icons/Asset 20-verde.svg" class="icon-wrapper" />
        <h3 class="text-xl font-bold text-brand-deep mb-3">${card1_title}</h3>
        <p class="text-brand-deep/70 text-sm leading-relaxed">${card1_text}</p>
      </div>
      <div class="what-we-do-card">
        <img src="/assets/icons/Asset 16-verde.svg" class="icon-wrapper" />
        <h3 class="text-xl font-bold text-brand-deep mb-3">${card2_title}</h3>
        <p class="text-brand-deep/70 text-sm leading-relaxed">${card2_text}</p>
      </div>
    </div>
  </div>
</section>

<!-- Section 4: Público-Alvo — bg-brand-bg-alt -->
<section class="section-padding bg-brand-bg-alt">
  <div class="container-center">
    <h2 class="section-title">A Quem Nos Dirigimos</h2>
    <div class="audience-grid">
      <div class="audience-item">
        <img src="/assets/icons/Asset 6-verde.svg" class="audience-icon" />
        <span class="audience-label">${profissionais}</span>
      </div>
      <div class="audience-item">
        <img src="/assets/icons/Asset 5-verde.svg" class="audience-icon" />
        <span class="audience-label">${estudantes}</span>
      </div>
      <div class="audience-item">
        <img src="/assets/icons/Asset 13-verde.svg" class="audience-icon" />
        <span class="audience-label">${instituicoes}</span>
      </div>
      <div class="audience-item">
        <img src="/assets/icons/Asset 38-verde.svg" class="audience-icon" />
        <span class="audience-label">${clinicas}</span>
      </div>
    </div>
  </div>
</section>

<!-- Section 5: Pull Quote — SEPARATE full-width section -->
<section class="pull-quote-section">
  <div class="pull-quote-container">
    <p class="pull-quote-text">${pull_quote}</p>
  </div>
</section>

<!-- Newsletter -->
<NewsletterSection />
```

### Key changes
- Breadcrumb: move OUTSIDE HeroSection, render before hero as `<nav>`
- Hero: use `class="hero"` (NOT `articles-hero`)
- Background alternation: hero → `bg-brand-bg-alt` → `bg-brand-bg` → `bg-brand-bg-alt` → pull-quote → newsletter
- Add `section-padding` class to all content sections
- Add `section-title` class to all h2 headings
- O Que Fazemos: add SVG icons (`/assets/icons/Asset 20-verde.svg`, `/assets/icons/Asset 16-verde.svg`)
- Público-Alvo: add SVG icons (`/assets/icons/Asset 6-verde.svg`, `Asset 5-verde.svg`, `Asset 13-verde.svg`, `Asset 38-verde.svg`), use `audience-item`/`audience-icon`/`audience-label` classes
- Pull Quote: separate `<section class="pull-quote-section">` with `pull-quote-container` and `pull-quote-text`

### HeroSection.jsx modification
The `HeroSection` component currently hardcodes `articles-hero` class. Need to add a `variant` or `className` prop:
- `className="hero"` for sobre page
- `className="events-hero"` for lives listing
- Default: `articles-hero` (for artigos/eventos pages)

---

## Shared: Breadcrumb Position

All 3 pages must have breadcrumb **between header and hero**, not inside the hero section.

The `(public)/layout.js` renders: `<UtilityBar>` → `<Header>` → `<MobileDrawer>` → `{children}` → `<Footer>`.

Breadcrumb must be the first element inside `{children}`, before any hero section.

For the live detail page, the breadcrumb is currently at the right position (before the section), but uses `max-w-7xl mx-auto px-4 pt-8` wrapper. Should use same wrapper style as MPA (just `<nav id="breadcrumb">`).

---

## Summary of all file changes

| # | File | Change Type | Description |
|---|------|-------------|-------------|
| 1 | `components/pages/LivesPageClient.jsx` | Rewrite | Use events-hero, events-filter-section, events-grid-section classes; fix i18n keys; 2-col grid |
| 2 | `components/ui/LiveCard.jsx` | Rewrite | Match MPA card: event-card-image, date-box day/month divs, text-[10px] badges, btn btn-secondary/primary btn-small, event-card-actions |
| 3 | `components/ui/TemporalFilter.jsx` | Minor | mb-12 instead of mb-8 |
| 4 | `app/[lang]/(public)/lives/[slug]/page.js` | Rewrite | Use event-hero, event-content-section, event-details-card, host-card-event classes; breadcrumb outside main; no emoji |
| 5 | `app/[lang]/(public)/sobre/page.js` | Rewrite | Use hero, section-padding, mission-section, what-we-do-grid with icons, audience-grid with icons, pull-quote-section; fix bg alternation; breadcrumb outside hero |
| 6 | `components/ui/HeroSection.jsx` | Minor | Add variant prop for hero/events-hero/articles-hero |

### i18n keys to verify in JSON files
- `lives_page.filter_upcoming`, `lives_page.filter_past`, `lives_page.filter_all`, `lives_page.filter_live`, `lives_page.filter_webinar`, `lives_page.filter_entrevista`
- `lives_page.newsletter_title`, `lives_page.newsletter_subtitle`, `lives_page.newsletter_email_placeholder`, `lives_page.newsletter_submit`, `lives_page.newsletter_privacy`
- `live_detail.acesso_rapido` or `live_detail.quick_access`
- `live_detail.credenciais` or `live_detail.access_info`
- `live_detail.materiais` or `live_detail.support_materials`
- `live_detail.anfitriao`
- `lives_page.no_results_title`, `lives_page.no_results_text`
- `sobre.missao_title`, `sobre.missao_p1`, `sobre.missao_p2`
- `sobre.oque_title`, `sobre.card1_title`, `sobre.card1_text`, `sobre.card2_title`, `sobre.card2_text`
- `sobre.publico_title`, `sobre.publico_profissionais`, `sobre.publico_estudantes`, `sobre.publico_instituicoes`, `sobre.publico_clinicas`
- `sobre.pull_quote`
