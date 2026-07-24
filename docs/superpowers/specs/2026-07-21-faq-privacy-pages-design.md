# FAQ & Privacy Policy Pages — Design Spec

**Date:** 2026-07-21  
**Status:** Draft for Review  
**Scope:** Two new public pages under `/[lang]/faq` and `/[lang]/politica-privacidade`  
**Source Content:** `policiesfc/CF-FAQ-Website.md` + `policiesfc/CF-Politica-Privacidade-Cookies.md`

---

## 1. Overview

Create two new public pages under the `[lang]` route group:

| Route | Source File | UI Pattern |
|-------|-------------|------------|
| `/[lang]/faq` | `policiesfc/CF-FAQ-Website.md` | Horizontal tabs: "Geral" / "Parceiros e Patrocinadores" |
| `/[lang]/politica-privacidade` | `policiesfc/CF-Politica-Privacidade-Cookies.md` | Single-page scroll with anchored sidebar TOC |

Both pages use the existing `PublicLayout` (UtilityBar + Header + Footer + MobileDrawer). No admin/auth required.

---

## 2. Information Architecture

### 2.1 FAQ Page (`/[lang]/faq`)

```
FAQ Page
├── Horizontal Tab Bar (sticky on scroll)
│   ├── Tab 1: "Geral" (default active)
│   └── Tab 2: "Parceiros e Patrocinadores"
└── Tab Panels (vertical stack, only one visible)
    ├── Panel "Geral": 5 Q&A pairs (2 with [a confirmar] — hidden until filled)
    └── Panel "Parceiros e Patrocinadores": 3 Q&A pairs (all [a confirmar] — hidden)
```

**Content mapping from source:**

| Source Section | Tab | Q&A Count | Notes |
|---|---|---|---|
| Separador 1: Geral | Geral | 5 | Q3, Q4 marked `[a confirmar]` → hide until content approved |
| Separador 2: Parceiros e Patrocinadores | Parceiros e Patrocinadores | 3 | All 3 marked `[a confirmar]` → hide entire panel until at least one Q&A ready |

**Hidden content handling:** Questions marked `[a confirmar]` are excluded from render until content is approved. If an entire tab has 0 visible Q&As, hide the tab entirely (don't show empty tab).

### 2.2 Privacy Policy Page (`/[lang]/politica-privacidade`)

```
Privacy Policy Page
├── Sticky Sidebar TOC (desktop) / Collapsible TOC (mobile)
│   ├── 1. Quem somos
│   ├── 2. Que dados recolhemos
│   │   └── 2.1 Dados de menores de idade
│   ├── 3. Finalidade do tratamento
│   ├── 4. Partilha de dados com terceiros
│   ├── 5. Armazenamento e segurança
│   ├── 6. Prazo de conservação dos dados
│   ├── 7. Direitos do titular dos dados
│   ├── 8. Cookies
│   │   ├── 8.1 Cookies estritamente necessários
│   │   ├── 8.2 Cookies de análise (Google Analytics) — [a implementar]
│   │   ├── 8.3 Cookies de conteúdo incorporado (YouTube) — [a implementar]
│   │   └── 8.4 Gestão de preferências de cookies
│   ├── 9. Sobre a natureza da Conheça Farmácia
│   └── 10. Alterações a esta política
└── Main Content Area (scroll-spy highlights active TOC item)
```

**Content mapping:** Direct 1:1 mapping from source markdown sections. Sections marked `[a implementar]` or `[...]` placeholders render as-is with a subtle "pendente" badge — content exists but is marked pending.

---

## 3. Component Architecture

### 3.1 New Components

| Component | Location | Purpose |
|---|---|---|
| `FAQTabs` | `components/faq/FAQTabs.jsx` | Horizontal tab bar + panel switching |
| `FAQPanel` | `components/faq/FAQPanel.jsx` | Accordion-style Q&A list for one tab |
| `FAQItem` | `components/faq/FAQItem.jsx` | Single Q&A accordion item |
| `PrivacyTOC` | `components/privacy/PrivacyTOC.jsx` | Sticky sidebar TOC with scroll-spy |
| `PrivacyContent` | `components/privacy/PrivacyContent.jsx` | Main content area with anchored sections |
| `PendingBadge` | `components/ui/PendingBadge.jsx` | Reusable "pendente" badge for `[a confirmar]` / `[a implementar]` |

### 3.2 New Pages

| Page | Path | Layout |
|---|---|---|
| `FAQPage` | `app/[lang]/(public)/faq/page.jsx` | `PublicLayout` |
| `PrivacyPage` | `app/[lang]/(public)/politica-privacidade/page.jsx` | `PublicLayout` |

### 3.3 Data Layer

| File | Purpose |
|---|---|
| `lib/content/faq.js` | Structured FAQ data (tabs → questions → {question, answer, pending}) |
| `lib/content/privacy.js` | Structured privacy policy sections (hierarchical sections with anchors) |

**Data format (FAQ):**
```js
export const faqData = {
  tabs: [
    {
      id: 'geral',
      label: { pt: 'Geral', en: 'General' },
      questions: [
        { id: 'q1', question: '...', answer: '...', pending: false },
        { id: 'q3', question: '...', answer: '[a confirmar]', pending: true },
      ]
    },
    { id: 'parceiros', label: { pt: 'Parceiros e Patrocinadores', en: 'Partners & Sponsors' }, questions: [...] }
  ]
}
```

**Data format (Privacy):**
```js
export const privacySections = [
  { id: 'quem-somos', title: { pt: '1. Quem somos', en: '1. Who we are' }, content: '...', level: 1 },
  { id: 'que-dados', title: { pt: '2. Que dados recolhemos', en: '2. What data we collect' }, content: '...', level: 1, children: [
    { id: 'menores', title: { pt: '2.1 Dados de menores', en: '2.1 Minors data' }, content: '...', level: 2 }
  ]},
  // ... etc
]
```

---

## 4. UI/UX Design

### 4.1 FAQ Page

**Tab Bar:**
- Horizontal, full-width on mobile, centered max-width on desktop
- Active tab: bottom border `border-b-2 border-primary-600`, text `text-primary-600 font-medium`
- Inactive tab: `text-muted-foreground hover:text-foreground`
- Sticky on scroll (`sticky top-14 z-10 bg-background/95 backdrop-blur-sm`)
- Keyboard accessible: `role="tablist"`, `role="tab"`, `aria-selected`, arrow key navigation

**Accordion Panels:**
- Each Q&A is a `<details>` / `<summary>` native accordion
- `summary`: question text, `text-lg font-medium`, chevron icon rotates on open
- `div[role="region"]`: answer text, `prose prose-muted max-w-none`
- Smooth height animation via CSS `height: auto` + `transition: max-height`
- Only one open at a time (optional: `name` attribute on `<details>` for native exclusive)

**Pending content:**
- Questions with `pending: true` → render `PendingBadge` instead of answer, accordion disabled
- Entire tab with 0 non-pending questions → hide tab entirely

### 4.2 Privacy Policy Page

**Layout:**
- Desktop (≥1024px): Two-column grid `grid-cols-[280px_1fr]`, gap-8
  - Left: `PrivacyTOC` sticky `top-20 max-h-[calc(100vh-10rem)] overflow-y-auto`
  - Right: `PrivacyContent` `prose prose-lg max-w-3xl`
- Tablet (768–1023px): TOC becomes collapsible drawer (hamburger in header), content full-width
- Mobile (<768px): TOC hidden by default, toggle button in header area

**TOC Component:**
- Nested `<nav aria-label="Índice">` with `<ol>`/`<li>` reflecting heading levels
- Links: `href="#section-id"`, smooth scroll
- Active item (scroll-spy): `text-primary-600 font-medium` + left border accent
- IntersectionObserver on content headings (`h2`, `h3`) to update active state

**Content:**
- Markdown-rendered via `prose` (Tailwind Typography)
- Section IDs from `id` field in data
- Pending badges inline next to section titles where applicable

**Pending badge:**
```jsx
<span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300 ml-2">
  Pendente
</span>
```

---

## 5. Internationalization (i18n)

- All user-facing strings in data files use `{ pt: '...', en: '...' }` objects
- Page components read `lang` from `LangContext` and select appropriate locale
- URL structure: `/pt/faq`, `/en/faq`, `/pt/politica-privacidade`, `/en/politica-privacidade`
- `getSectionHref` from `lib/i18n-routes` used for any cross-links

---

## 6. Routing & Navigation

Add to `lib/i18n-routes.js` `PAGE_SECTION_MAP`:
```js
faq: 'faq',
politicaPrivacidade: 'politica-privacidade',
```

Add to `UtilityBar`/`Header` nav links if needed (Footer already has "Termos, Privacidade e Cookies" link — update href to `/${lang}/politica-privacidade`).

Add FAQ link to Footer "Geral" column.

---

## 7. Styling & Theming

- Use existing Tailwind config: `prose`, `prose-muted`, `prose-lg`, `max-w-3xl`
- Colors: `primary-600`, `muted-foreground`, `background`, `border`
- Dark mode via existing `ThemeProvider` / `dark:` variants
- Transitions: `transition-colors duration-200`, `transition-all duration-300`
- Responsive breakpoints: `sm:`, `md:`, `lg:`, `xl:`

---

## 8. Accessibility

- FAQ tabs: `role="tablist"`, `role="tab"`, `aria-selected`, `aria-controls`, `tabindex`, arrow keys
- Accordions: native `<details>`/`<summary>` (native keyboard support)
- Privacy TOC: `nav[aria-label]`, skip link for keyboard users
- Focus visible: `focus-visible:ring-2 focus-visible:ring-primary-500`
- Color contrast: `text-muted-foreground` meets WCAG AA on light/dark
- Reduced motion: `@media (prefers-reduced-motion: reduce)` disables scroll animations

---

## 9. Content Management

**Source of truth:** `policiesfc/*.md` files (checked into repo).

**Workflow:**
1. Content team updates `.md` files in `policiesfc/`
2. Developer runs `npm run sync:content` (new script) → parses `.md` → writes `lib/content/faq.js` + `lib/content/privacy.js`
3. Commit + deploy

**Sync script spec (future):** Parse markdown headings (`##`, `###`) and Q&A patterns (`**Q**\nA`) into structured JS. For v1, manually author the JS data files from the markdown.

---

## 10. Acceptance Criteria

### FAQ Page
- [ ] `/pt/faq` and `/en/faq` render under `PublicLayout`
- [ ] Two tabs: "Geral" / "Parceiros e Patrocinadores" (localized)
- [ ] Tab switching works via click + keyboard (←/→)
- [ ] Only non-pending Q&As render; pending show "Pendente" badge
- [ ] "Parceiros" tab hidden if all 3 Q&As pending
- [ ] Accordion works (native `<details>`), one open at a time
- [ ] Sticky tab bar on scroll
- [ ] Dark mode works
- [ ] Mobile responsive (tabs scroll horizontally on small screens)

### Privacy Policy Page
- [ ] `/pt/politica-privacidade` and `/en/politica-privacidade` render under `PublicLayout`
- [ ] Desktop: sticky TOC left, content right
- [ ] Tablet: collapsible TOC drawer
- [ ] Mobile: TOC hidden behind toggle
- [ ] Scroll-spy highlights active section in TOC
- [ ] Smooth scroll to section on TOC click
- [ ] Pending badges show on sections marked `[a implementar]` / `[...]`
- [ ] Dark mode works
- [ ] Footer "Termos, Privacidade e Cookies" link points to `/${lang}/politica-privacidade`

---

## 11. Out of Scope (v1)

- Automated markdown→JS sync script (manual for v1)
- Cookie consent banner (marked `[a implementar]` in source)
- Google Analytics / YouTube-nocookie implementation
- FAQ search/filter
- PDF export of privacy policy

**In Scope (v1):** Admin UI for editing FAQ tabs/questions and Privacy Policy sections — added to Admin sidebar under a new "Conteúdo Legal" section, using existing AdminListPage patterns with BilingualTabs for PT/EN editing.

---

## 12. Admin UI for Content Management (v1)

### 12.1 Overview
Add a new "Conteúdo Legal" section to the Admin sidebar with two routes:
- `/[lang]/admin/conteudo-legal/faq` — Manage FAQ tabs and questions
- `/[lang]/admin/conteudo-legal/politica-privacidade` — Manage Privacy Policy sections

Both use the existing Admin layout (AdminSidebar + AdminTopBar) and follow established patterns from Artigos/Eventos/Lives list pages.

### 12.2 Admin Sidebar Update
Add to `components/layout/AdminSidebar.jsx` links array:
```js
{ href: `/${lang}/admin/conteudo-legal/faq`, label: 'FAQ', icon: HelpCircle },
{ href: `/${lang}/admin/conteudo-legal/politica-privacidade`, label: 'Política de Privacidade', icon: Shield },
```
(Import `HelpCircle`, `Shield` from `lucide-react`)

### 12.3 FAQ Admin Page (`/[lang]/admin/conteudo-legal/faq`)

**Data model (in DB):**
```sql
-- New table: faq_tabs
id UUID PK, slug TEXT UNIQUE, sort_order INT, created_at, updated_at

-- New table: faq_questions
id UUID PK, tab_id FK→faq_tabs.id, question_pt TEXT, question_en TEXT,
answer_pt TEXT, answer_en TEXT, pending BOOLEAN DEFAULT true, sort_order INT,
created_at, updated_at
```

**UI:**
- Server Component page (`page.js`) fetches tabs + questions via Server Action
- Client Component (`FAQAdminListPage`) renders:
  - Tab list (reorderable via drag-drop or sort_order input)
  - For each tab: question list (reorderable)
  - BilingualTabs for editing question/answer PT/EN
  - Pending toggle (checkbox)
  - Delete question (soft delete → archive pattern)
- Actions: Create tab, Edit tab, Archive tab, Create question, Edit question, Archive question
- Role enforcement: admin can archive; superadmin can restore/hard delete

### 12.4 Privacy Policy Admin Page (`/[lang]/admin/conteudo-legal/politica-privacidade`)

**Data model (in DB):**
```sql
-- New table: privacy_sections
id UUID PK, parent_id FK→privacy_sections.id (nullable), title_pt TEXT, title_en TEXT,
content_pt TEXT, content_en TEXT, anchor_slug TEXT UNIQUE, level INT (1=h2, 2=h3),
pending BOOLEAN DEFAULT false, sort_order INT, created_at, updated_at
```

**UI:**
- Server Component page fetches hierarchical sections via Server Action
- Client Component (`PrivacyAdminListPage`) renders:
  - Nested sortable list (nestable up to level 2)
  - BilingualTabs for title/content PT/EN
  - Pending toggle
  - Delete (archive pattern)
- Actions: Create section, Edit section, Archive section
- Role enforcement: same as FAQ

### 12.5 Server Actions
New file: `lib/actions/legalContent.js`
- `getFAQTabs()`, `getFAQQuestions(tabId)`
- `createFAQTab()`, `updateFAQTab()`, `archiveFAQTab()`, `restoreFAQTab()`, `deleteFAQTab()`
- `createFAQQuestion()`, `updateFAQQuestion()`, `archiveFAQQuestion()`, `restoreFAQQuestion()`, `deleteFAQQuestion()`
- `getPrivacySections()`, `createPrivacySection()`, `updatePrivacySection()`, `archivePrivacySection()`, `restorePrivacySection()`, `deletePrivacySection()`
- `reorderFAQTabs()`, `reorderFAQQuestions()`, `reorderPrivacySections()`

### 12.6 Public Data Layer Update
`lib/content/faq.js` and `lib/content/privacy.js` become **Server Actions** (not static files):
- `getPublicFAQData()` → reads from DB, filters `pending=false`, returns structured data for public FAQ page
- `getPublicPrivacyData()` → reads from DB, returns all sections (pending shown with badge)

This eliminates the manual markdown→JS sync step — content edits in Admin immediately reflect on public pages.

### 12.7 Migrations
- `021_faq_tabs.sql` — create `faq_tabs`, `faq_questions` with RLS
- `022_privacy_sections.sql` — create `privacy_sections` with RLS
- Seed script for initial data from `policiesfc/*.md`

### 12.8 Acceptance Criteria (Admin)
- [ ] "Conteúdo Legal" section appears in AdminSidebar
- [ ] FAQ admin: list tabs, list questions per tab, bilingual edit, pending toggle, reorder, archive/restore
- [ ] Privacy admin: nested section list, bilingual edit, pending toggle, reorder, archive/restore
- [ ] Role enforcement: admin=archive, superadmin=restore/delete
- [ ] Public pages read live data from DB (no static JS files)
- [ ] Changes in Admin reflect immediately on public pages (no rebuild needed)

---

## 13. Open Questions (Resolve Before Implementation)

1. **Tab visibility rule:** Hide "Parceiros e Patrocinadores" tab entirely while all 3 Q&As are pending? (Spec says yes — confirm)
2. **Privacy TOC on mobile:** Hamburger in header vs. floating action button? (Spec says header toggle — confirm)
3. **Pending badge wording:** "Pendente" (PT) / "Pending" (EN) — confirm
4. **Footer link update:** Confirm Footer "Termos, Privacidade e Cookies" should point to `/${lang}/politica-privacidade` (not old `/termos`)
5. **FAQ link in Footer:** Add to "Geral" column? Confirm label: "Perguntas Frequentes" / "FAQ"

---

*Design complete. Awaiting user review before implementation plan.*