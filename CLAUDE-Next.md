# CLAUDE-Next.md

Guia Next.js App Router para o projeto "Conheça Farmácia". Este ficheiro documenta a arquitetura, comandos e padrões específicos do Next.js durante a migração gradual.

## Development Commands

```bash
# Next.js dev server (webpack — Turbopack bug com acentos no path no Windows)
npm run dev:next

# Next.js production build (webpack — Turbopack bug com acentos no path no Windows)
npm run build:next

# Vite dev server (site original, http://localhost:5173) — durante migração
npm run dev

# Vite production build — durante migração
npm run build
```

## Core Technologies

- **Framework**: Next.js 16.2.6 (App Router)
- **React**: 19.2.4
- **Styling**: Tailwind CSS v4 (`@tailwindcss/postcss`)
- **Backend**: Supabase (PostgreSQL, Auth, RLS, Edge Functions)
- **SSR**: `@supabase/ssr` para server-side rendering
- **i18n**: Dynamic `[lang]` route segment (PT/EN)

## Directory Structure (Next.js — Estado Atual)

```
├── app/
│   ├── layout.js                    # Root layout (<html>, <head>, <body>, fonts, ThemeProvider, anti-FOUC, globals.css)
│   ├── page.js                      # Root page (redirect middleware → /pt)
│   ├── [lang]/                      # Dynamic locale segment (pt, en)
│   │   ├── layout.js                # Language layout (LangProvider com translations — sem html/body)
│   │   ├── page.js                  # Homepage (HeroAnimated, FeaturedArticles/Events/Lives, StatsSection)
│   │   ├── (public)/
│   │   │   ├── layout.js            # Public layout (UtilityBar, Header, MobileDrawer, Footer)
│   │   │   ├── loading.jsx          # Homepage skeleton (hero + featured grids)
│   │   │   ├── error.jsx            # Error boundary global público
│   │   │   ├── artigos/
│   │   │   │   ├── page.js          # Artigos listagem (server → ArtigosPageClient)
│   │   │   │   ├── loading.jsx      # Skeleton listagem artigos (3-col grid)
│   │   │   │   ├── error.jsx        # Error boundary artigos
│   │   │   │   └── [slug]/
│   │   │   │       ├── page.js      # Artigo detalhe (ArticleContent, ShareSection, RelatedArticles)
│   │   │   │       └── loading.jsx  # Skeleton detalhe artigo
│   │   │   ├── eventos/
│   │   │   │   ├── page.js          # Eventos listagem (server → EventosPageClient)
│   │   │   │   ├── loading.jsx      # Skeleton listagem eventos (2-col grid)
│   │   │   │   ├── error.jsx        # Error boundary eventos
│   │   │   │   └── [slug]/
│   │   │   │       ├── page.js      # Evento detalhe (CapacityBar, SpeakersList, SimilarEvents)
│   │   │   │       └── loading.jsx  # Skeleton detalhe evento
│   │   │   ├── lives/
│   │   │   │   ├── page.js          # Lives listagem (server → LivesPageClient)
│   │   │   │   ├── loading.jsx      # Skeleton listagem lives (2-col grid)
│   │   │   │   ├── error.jsx        # Error boundary lives
│   │   │   │   └── [slug]/
│   │   │   │       ├── page.js      # Live detalhe (LiveAccessCard, MaterialsList, HostCard)
│   │   │   │       └── loading.jsx  # Skeleton detalhe live
│   │   │   ├── pesquisa/
│   │   │   │   └── page.js          # Pesquisa global (server → PesquisaPageClient)
│   │   │   ├── inscricao/
│   │   │   │   └── page.js          # Formulário inscrição (server → InscricaoPageClient)
│   │   │   ├── sobre/
│   │   │   │   └── page.js          # Sobre nós (server, i18n server-side)
│   │   │   └── unsubscribe/
│   │   │       └── page.js          # Cancelar subscrição (server → UnsubscribeClient)
│   │   └── (admin)/
│   │       ├── layout.js              # Admin protected layout (sidebar, topbar, AuthGuard, admin.css)
│   │       ├── dashboard/
│   │       │   └── page.js            # Dashboard (server: stats + timeline → StatsGrid, ActivityTimeline, DashboardCharts)
│   │       ├── artigos/
│   │       │   ├── page.js            # Lista artigos (server → ArtigosListPage client)
│   │       │   ├── new/page.js        # Novo artigo (server → ArticleForm client)
│   │       │   └── [id]/page.js       # Editar artigo (server: load → ArticleForm client)
│   │       ├── eventos/
│   │       │   ├── page.js            # Lista eventos (server → EventosListPage client)
│   │       │   ├── new/page.js        # Novo evento (server → EventForm client)
│   │       │   └── [id]/page.js       # Editar evento (server: load → EventForm client)
│   │       ├── lives/
│   │       │   ├── page.js            # Lista lives (server → LivesListPage client)
│   │       │   ├── new/page.js        # Nova live (server → LiveForm client)
│   │       │   └── [id]/page.js       # Editar live (server: load → LiveForm client)
│   │       ├── newsletter/
│   │       │   └── page.js            # Newsletter management (client: stats + SendAlertForm + SubscribersTable)
│   │       └── definicoes/
│   │           └── page.js            # Settings (client: Profile, Password, 2FA, GateQuestions)
│   │   └── admin/
│   │       └── page.js                # Login split-screen (Gate → Login → MFA state machine)
│   ├── sitemap.js                     # Sitemap dinâmico com i18n (pt/en), ISR 43200s
│   ├── robots.js                      # Robots.txt dinâmico (bloqueia /admin/)
│   └── not-found.jsx                  # Página 404
│
├── components/
│   ├── providers/
│   │   ├── ThemeProvider.jsx         # Dark mode context + toggle
│   │   └── LangProvider.jsx          # Language context provider (client)
│   ├── layout/
│   │   ├── Header.jsx                # Nav links, logo, hamburger (client, recebe onToggleDrawer)
│   │   ├── Footer.jsx                # Footer grid, links, social (server)
│   │   ├── UtilityBar.jsx            # Search input, language switcher (client)
│   │   ├── MobileDrawer.jsx          # Floating drawer menu (client)
│   │   ├── AdminSidebar.jsx          # Admin sidebar nav (client, gradient + Lucide icons + dark mode toggle + mobile hamburger)
│   │   └── AdminTopBar.jsx           # Admin top bar (client, search + user avatar)
│   ├── home/
│   │   ├── HeroAnimated.jsx          # Ticker animation (client, 5 frases com SVG icons)
│   │   ├── FeaturedArticles.jsx      # Grid 3 artigos (server)
│   │   ├── FeaturedEvents.jsx        # Grid 2 eventos (server)
│   │   ├── FeaturedLives.jsx         # Grid 2 lives (server)
│   │   └── StatsSection.jsx          # 4 stats com i18n (client)
│   ├── pages/
│   │   ├── ArtigosPageClient.jsx     # Filtros + pesquisa artigos (client, usa LangContext)
│   │   ├── EventosPageClient.jsx     # Filtros temporais + categoria eventos (client, usa LangContext)
│   │   ├── LivesPageClient.jsx       # Filtros temporais + categoria lives (client, usa LangContext)
│   │   ├── PesquisaPageClient.jsx    # Pesquisa global com filtros, sort, paginação, highlight (client)
│   │   ├── InscricaoPageClient.jsx   # Formulário inscrição com validação, honeypot, rate limiting (client)
│   │   └── UnsubscribeClient.jsx     # Cancelar subscrição: 3 estados loading/success/error (client)
│   ├── ui/
│   │   ├── ThemeToggle.jsx           # Sun/moon icon toggle (client, self-contained)
│   │   ├── LanguageSwitcher.jsx      # Globe dropdown, useRouter to switch [lang] (client)
│   │   ├── ArticleCard.jsx           # Card artigo (client, usa LangContext)
│   │   ├── EventCard.jsx             # Card evento (client, usa LangContext)
│   │   ├── LiveCard.jsx              # Card live (client, usa LangContext)
│   │   ├── Breadcrumb.jsx            # Navegação breadcrumb (server)
│   │   ├── HeroSection.jsx           # Wrapper hero (server)
│   │   ├── FilterButtons.jsx         # Filtros categoria (client, usa LangContext)
│   │   ├── TemporalFilter.jsx        # Toggle temporal (client)
│   │   └── NewsletterSection.jsx     # Form newsletter (client, usa LangContext)
│   ├── content/
│   │   ├── ArticleContent.jsx        # Markdown render (client, marked + DOMPurify, lazy loading em imagens)
│   │   ├── ShareSection.jsx          # WhatsApp/Facebook/LinkedIn/Web Share (client, usa LangContext)
│   │   ├── RelatedArticles.jsx       # Carousel artigos relacionados (client, usa LangContext)
│   │   ├── SimilarEvents.jsx         # Grid eventos similares (server)
│   │   ├── CapacityBar.jsx           # Barra capacidade com polling (client)
│   │   ├── SpeakersList.jsx          # Lista oradores (client)
│   │   ├── LiveAccessButton.jsx      # Botão acesso live com tracking via lib/api/analytics (client)
│   │   ├── MaterialLink.jsx          # Link material com download tracking via lib/api/analytics (client)
│   │   ├── ReadingTimeTracker.jsx    # Tracking tempo de leitura via lib/api/analytics (client)
│   │   ├── ViewCountTracker.jsx      # Tracking views artigo com dedup 24h (client)
│   │   ├── EventViewTracker.jsx      # Tracking views evento com dedup 24h (client)
│   │   ├── LiveViewTracker.jsx       # Tracking views live com dedup 24h (client)
│   │   ├── PageViewTracker.jsx       # Page view global com sessionStorage dedup (client, Suspense)
│   │   ├── LiveAccessTracker.jsx     # Tracking acessos live (client)
│   │   └── LiveDownloadTracker.jsx   # Tracking downloads live (client)
│   └── admin/
│       ├── AuthGuard.jsx             # Auth protection (client, session + admin_users + useIdleTimeout)
│       ├── AdminSidebarWrapper.jsx   # Client wrapper combining sidebar + topbar + content + logout handler
│       ├── StatsGrid.jsx             # Server: 6 stat cards com gradientes
│       ├── ActivityTimeline.jsx      # Server: audit_logs timeline com dots/badges
│       ├── ActivityChart.jsx         # Client: Chart.js page_views por período
│       ├── CategoryChart.jsx         # Client: Chart.js distribuição categorias
│       ├── DashboardCharts.jsx       # Client: wrapper ActivityChart + CategoryChart
│       ├── AnalyticsCard.jsx         # Card analytics reutilizável (views, shares, reading)
│       ├── ArtigosListPage.jsx       # Client: filtros + tabela + status toggle + delete
│       ├── EventosListPage.jsx       # Client: filtros + tabela temporal/categoria
│       ├── LivesListPage.jsx         # Client: filtros + tabela temporal/categoria
│       ├── ArticleForm.jsx           # Client: formulário completo artigo (create/edit)
│       ├── EventForm.jsx             # Client: formulário evento + HostEditor
│       ├── LiveForm.jsx              # Client: formulário live + materials
│       ├── MarkdownEditor.jsx        # Client: fullscreen overlay + DOMPurify preview
│       ├── ImageUpload.jsx           # Client: compress + upload (SEC-UPL-01: MIME + 5MB)
│       ├── HostEditor.jsx            # Client: linhas dinâmicas hosts (eventos)
│       ├── ReferenceEditor.jsx       # Client: linhas dinâmicas referências (artigos)
│       ├── ConfirmModal.jsx          # Client: modal genérico (danger/warning variants)
│       ├── TwoFactorSection.jsx      # Client: QR code + verify + disable 2FA
│       ├── GateQuestionsSection.jsx   # Client: RPC + SHA256 gate questions
│       ├── SendAlertForm.jsx         # Client: tipo + dropdown conteúdo + modo envio
│       ├── SubscribersTable.jsx      # Client: filtros + pesquisa + checkboxes + soft/hard delete
│       └── RemoveSubscriberModal.jsx # Client: modal remoção subscritor (soft + hard delete)
│
├── lib/
│   ├── supabase/
│   │   ├── server.js                 # createServerClient (cookies(), RSC + actions)
│   │   ├── client.js                 # createBrowserClient (use client)
│   │   └── middleware.js             # createServerClient for middleware (updateSession)
│   ├── api/
│   │   ├── normalize.js              # normalizeArticle, normalizeEvent, normalizeLive (puras)
│   │   ├── articles.js               # getArticles, getArticleBySlug, getFeaturedArticles
│   │   ├── events.js                 # getEvents, getEventBySlug, getFeaturedEvents, getSimilarEvents
│   │   ├── lives.js                  # getLives, getLiveBySlug, getFeaturedLives
│   │   ├── search.js                 # searchAllContent(query, type, order) — client-side Supabase ilike
│   │   ├── inscription.js            # validateField(), submitInscription() — client-side Edge Function + insert
│   │   └── analytics.js              # Server Actions: incrementViewCount, addReadingTime, trackPageView, etc. (use server)
│   ├── actions/                      # Server Actions (use server)
│   │   ├── auth.js                   # adminLogin, verifyMFA, getGateQuestions, verifyGateAnswers, adminLogout
│   │   ├── settings.js               # getAdminProfile, updateProfile, changePassword, enrollMFA, verifyMFAEnrollment, unenrollMFA, listMFAFactors, getGateQuestionsForEdit, saveGateQuestions
│   │   ├── content.js                # delete/toggle/create/update × 3 tipos + logAudit
│   │   ├── lists.js                  # getAllArticlesAdmin, getArticleStats, getTopArticles + eventos/lives
│   │   ├── dashboard.js              # getDashboardStats, getActivityTimeline, getPageViewsByPeriod, getCategoryDistribution
│   │   └── newsletter.js             # getSubscribers, getNewsletterStats, sendContentAlert, unsubscribe/reactivate/deleteSubscriber
│   ├── i18n.js                       # loadTranslations(lang), t(translations, keyPath) — server-side
│   ├── security.js                   # escapeHtml, escapeAttr, validateUrl (puras)
│   ├── constants.js                  # SITE_NAME, SITE_URL, category colors, valid categories
│   ├── analytics-dedup.js            # hasTracked(), markTracked() — localStorage 24h TTL (use client)
│   ├── seo.js                        # buildArticleSchema, buildEventSchema, buildLiveSchema, buildBreadcrumbSchema, buildOrganizationSchema, buildWebSiteSchema
│   └── contexts.js                   # LangContext, ThemeContext (use client)
│
├── hooks/
│   ├── useAuth.js                    # Session + admin check (client)
│   ├── useIdleTimeout.js             # 30min auto-logout (client)
│   └── useTheme.js                   # Re-export de ThemeProvider (client)
│
├── styles/
│   ├── globals.css                   # Tailwind v4 completo (copiado de src/input.css)
│   └── admin/
│       └── admin.css                 # Admin CSS isolado (importado APENAS no admin layout)
│
├── middleware.js                      # Root redirect / → /pt, x-lang header, session refresh, admin protection
│
├── public/                           # Static assets (partilhado com Vite)
│   ├── i18n/                         # Translation files (pt.json, en.json)
│   └── logo/                         # Logo variants
│
├── .env.local                        # NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY
├── next.config.mjs                   # Next.js config (images.remotePatterns para Supabase)
├── postcss.config.mjs                # PostCSS with @tailwindcss/postcss
├── jsconfig.json                     # Path aliases (@/*)
└── eslint.config.mjs                 # ESLint with eslint-config-next
```

## Key Patterns

### App Router Conventions
- **Server Components** by default (layouts são Server Components)
- **Client Components** com `"use client"` para hooks, event listeners, browser APIs
- **Route Groups** `(public)` e `(admin)` para layouts diferentes sem afetar URL
- **`params` é uma Promise** (Next.js 15+) — sempre usar `const { lang } = await params`

### Root Layout Architecture

O root layout (`app/layout.js`) contém `<html>`, `<head>` e `<body>`. Usa `headers()` para obter o lang do header `x-lang` injetado pelo middleware:

```js
// app/layout.js
import { headers } from 'next/headers'
import ThemeProvider from '@/components/providers/ThemeProvider'
import '@/styles/globals.css'

export default async function RootLayout({ children }) {
  const headersList = await headers()
  const lang = headersList.get('x-lang') || 'pt'
  return (
    <html lang={lang} suppressHydrationWarning>
      <head>
        {/* fonts, anti-FOUC script */}
      </head>
      <body>
        <ThemeProvider>{children}</ThemeProvider>
      </body>
    </html>
  )
}
```

O `[lang]/layout.js` é um wrapper que APENAS providencia o `LangProvider` (sem `<html>`/`<body>`):

```js
// app/[lang]/layout.js
export default async function LangLayout({ children, params }) {
  const { lang } = await params
  const translations = loadTranslations(safeLang)
  return <LangProvider lang={safeLang} translations={translations}>{children}</LangProvider>
}
```

O middleware injeta o header `x-lang` para que o root layout saiba o idioma sem depender de `headers().get('x-next-pathname')`:

```js
// middleware.js
const requestHeaders = new Headers(request.headers)
requestHeaders.set('x-lang', lang)
let supabaseResponse = NextResponse.next({ request: { headers: requestHeaders } })
```

### Supabase SSR (3 clients)

**Server** (`lib/supabase/server.js`):
```js
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options))
          } catch { /* Server Component */ }
        },
      },
    }
  )
}
```

**Browser** (`lib/supabase/client.js`):
```js
'use client'
import { createBrowserClient } from '@supabase/ssr'
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  )
}
```

**Middleware** (`lib/supabase/middleware.js`):
```js
// updateSession(request) — cookie proxy pattern para refresh de sessão
```

### i18n Strategy (Server-Side)

O i18n é server-side. As traduções são carregadas no layout `[lang]/layout.js` e disponibilizadas via `LangContext`:

```js
// lib/i18n.js
import fs from 'fs'
import path from 'path'

const SUPPORTED_LANGS = ['pt', 'en']
const DEFAULT_LANG = 'pt'

export function loadTranslations(lang) {
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const filePath = path.join(process.cwd(), 'public', 'i18n', `${safeLang}.json`)
  return JSON.parse(fs.readFileSync(filePath, 'utf8'))
}

export function t(translations, keyPath) {
  // Dot-notation lookup: "nav.inicio" → "Início"
  // Fallback: retorna keyPath se não encontrar
}
```

**Flow:**
1. `app/[lang]/layout.js` → `loadTranslations(lang)` → `LangProvider` com `{ lang, translations, t }`
2. Client Components usam `useContext(LangContext)` para aceder a `t()`
3. **NUNCA passar `t` como prop de Server Component para Client Component** — funções não podem atravessar a fronteira Server→Client

### Translation Keys (17 namespaces)

| Namespace | Exemplo de uso |
|-----------|---------------|
| `nav.inicio`, `nav.artigos` | Navigation links |
| `hero.title`, `hero.subtitle` | Homepage hero |
| `search.placeholder` | Search input |
| `footer.descricao`, `footer.direitos` | Footer content |
| `artigos_page.hero_title` | Articles listing |
| `evento_detail.register_btn` | Event detail |

**Chaves corretas do footer:** `footer.descricao`, `footer.navegacao`, `footer.contacto`, `footer.redes_sociais`, `footer.direitos` (NÃO `footer.redes` nem `footer.copyright`).

### List Page Pattern (Server → Client split)

As páginas de listagem seguem o padrão: Server Component busca dados, Client Component faz filtragem/interação:

```js
// app/[lang]/(public)/artigos/page.js (Server Component)
import ArtigosPageClient from '@/components/pages/ArtigosPageClient'

export default async function ArtigosPage({ params }) {
  const articles = await getArticles()
  return <ArtigosPageClient articles={articles} categories={ARTICLE_CATEGORIES} lang={safeLang} />
}
```

```jsx
// components/pages/ArtigosPageClient.jsx (Client Component)
'use client'
import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'

export default function ArtigosPageClient({ articles, categories, lang }) {
  const { t } = useContext(LangContext)  // NÃO receber t como prop!
  // ... filtros, pesquisa, renderização
}
```

### Detail Page Pattern

As páginas de detalhe são Server Components que usam `generateStaticParams` + `generateMetadata`:

```js
export async function generateStaticParams() {
  const articles = await getArticles()
  return articles.map((a) => ({ slug: a.slug }))
}

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const article = await getArticleBySlug(slug)
  return { title: `${article.title} — Conheça Farmácia`, ... }
}
```

### Event Handlers in Server Components

**NUNCA usar `onClick` inline em Server Components.** Extrair para Client Component:

```jsx
// components/content/LiveAccessButton.jsx
'use client'
export default function LiveAccessButton({ href, color, label, liveSlug, rpcName }) {
  const handleClick = async () => {
    const { createClient } = await import('@/lib/supabase/client')
    const supabase = createClient()
    await supabase.rpc(rpcName, { live_slug: liveSlug })
  }
  return <a href={href} onClick={handleClick} ...>{label}</a>
}
```

### Middleware (3 preocupações)

1. **Root redirect**: `pathname === '/'` → redirect para `/pt`
2. **Session refresh**: Para todos os requests com lang válido, cria Supabase client e chama `getUser()`
3. **Admin protection**:
   - `/{lang}/admin` (login): se autenticado + admin_users → redirect para dashboard
   - `/{lang}/admin/*`: verificar session + admin_users; redirect para login se não autenticado
4. **x-lang header**: Injeta o lang para o root layout saber o idioma

### Drawer State Pattern

O drawer mobile usa **callback lifting** — o estado vive no `PublicLayout`:

```jsx
// app/[lang]/(public)/layout.js
const [drawerOpen, setDrawerOpen] = useState(false)
<Header onToggleDrawer={() => setDrawerOpen(!drawerOpen)} />
<MobileDrawer open={drawerOpen} onClose={() => setDrawerOpen(false)} />
```

**NUNCA** criar estado local `drawerOpen` no Header — isso quebra o drawer.

### ThemeToggle (Self-Contained)

O ThemeToggle gerencia o seu próprio estado (localStorage + `document.documentElement.classList`). NÃO precisa de ThemeProvider. O `hooks/useTheme.js` existe mas não é usado atualmente.

### Environment Variables

```
NEXT_PUBLIC_SUPABASE_URL=https://tbqsazriorqzexjwhekw.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
```
Usar `.env.local` para Next.js. O `.env` com `VITE_` permanece para o Vite.

## Migration Phases

| Phase | Status | Description |
|-------|--------|-------------|
| Fase 0 | ✅ COMPLETA | Environment setup (Next.js 16 + React 19 + Tailwind v4) |
| Fase 1 | ✅ COMPLETA | Foundation: `[lang]` layout, Supabase SSR, middleware, i18n, components |
| Fase 2 | ✅ COMPLETA | Content pages: homepage, artigos, eventos, lives (listagens + detalhes) |
| Fase 3 | ✅ COMPLETA | Search, forms, newsletter, sobre, 404, unsubscribe |
| Fase 4 | ✅ COMPLETA | Admin CMS: auth (gate+MFA), dashboard, lists, forms, newsletter, settings; 14 rotas admin, 39 total; 8/8 SEC passaram |
| Fase 5 | ✅ COMPLETA | Performance (loading skeletons, error boundaries, image optimization), SEO (sitemap, robots, JSON-LD, hreflang), Analytics (server actions, dedup, PageViewTracker) |
| Fase 6 | PENDENTE | Cutover: remove Vite, deploy Next.js |

## Lições Aprendidas (Next.js)

### 1. params é uma Promise (Next.js 15+)

Sempre usar `await params` em Server Components:
```js
export default async function MyLayout({ children, params }) {
  const { lang } = await params  // ✅
  // params.lang ❌ — é undefined
}
```

### 2. Root Layout com Route Groups

O root layout (`app/layout.js`) DEVE ter `<html>` e `<body>` — é obrigatório pelo Next.js. Para suportar `[lang]` dinâmico, o root layout usa `headers()` para obter o lang do header `x-lang` injetado pelo middleware. O `[lang]/layout.js` NÃO tem `<html>`/`<body>` — apenas providencia o `LangProvider`.

### 3. Tailwind v4 com PostCSS (não Vite plugin)

Next.js usa webpack (ou Turbopack). O plugin `@tailwindcss/vite` não funciona. Usar `@tailwindcss/postcss` em `postcss.config.mjs`.

### 4. Server vs Client Components

- Layouts são Server Components por defeito
- Usar `"use client"` apenas para hooks, event listeners, browser APIs
- Server Components podem importar e renderizar Client Components como filhos
- **NUNCA passar funções como props de Server para Client Components** — usar `LangContext` nos Client Components

### 5. Drawer State: Callback Lifting

Quando dois componentes irmãos precisam de estado partilhado (Header + MobileDrawer), o estado vive no componente pai (PublicLayout) e é passado via props/callbacks.

### 6. CSS Isolation com Route Groups

`styles/admin/admin.css` é importado APENAS no layout `(admin)/layout.js`. Os seletores usam prefixos `.admin-*`. Nunca importar admin CSS no layout público.

### 7. i18n Server-Side (não fetch)

O Next.js não precisa de `fetch('/i18n/pt.json')`. Usar `fs.readFileSync` diretamente em Server Components. O cache em memória evita re-leitura.

### 8. Nunca Top-Level Await em main.js

Regra herdada do Vite: `main.js` NUNCA pode conter `await`. Usar `i18nReady` non-blocking pattern.

### 9. Turbopack Bug com Caracteres Acentuados no Path (Windows)

Turbopack não suporta caracteres acentuados (ç, ã, é) no path do diretório do projeto. Erro: `couldn't find build manifest`. Solução: usar `--webpack` em ambos os scripts:

```json
"dev:next": "next dev --webpack",
"build:next": "next build --webpack"
```

### 10. Funções Não Atravessam a Fronteira Server→Client

Server Components NÃO podem passar funções (como `t`) como props para Client Components. O Next.js serializa props com `JSON.stringify` — funções não são serializáveis. Solução: Client Components obtêm `t` de `useContext(LangContext)`.

### 11. onClick Não Funciona em Server Components

Event handlers (`onClick`, `onSubmit`, etc.) requerem interatividade e só funcionam em Client Components. Nunca usar `onClick` com async function inline num Server Component. Extrair para um Client Component (`'use client'`).

### 12. Breadcrumb Component Recebe `items` (não `levels`)

O componente `Breadcrumb` (`components/ui/Breadcrumb.jsx`) recebe prop `items` (array de `{ label, href }`). NÃO usar `levels` ou `t` como prop — o Breadcrumb não precisa de tradução pois recebe labels já traduzidos.

### 13. Search: Client-Side com Supabase ilike

A pesquisa usa busca client-side via Supabase `ilike` em 3 tabelas (articles, events, lives). O componente `PesquisaPageClient.jsx` faz merge dos resultados, sort, e paginação client-side (15/página). Destaque de termos usa `escapeHtml()` antes do regex para prevenir XSS. URL params via `useSearchParams` + `useRouter`.

```js
// lib/api/search.js
export async function searchAllContent(query, type = 'todos', order = 'recente') {
  // Busca em paralelo: articles, events, lives
  // Merge + sort client-side
}
```

### 14. Inscription Form: Edge Function + Honeypot

O formulário de inscrição (`InscricaoPageClient.jsx`) segue o padrão:
- Validação client-side com whitelist para selects e regex para email/telefone
- Edge Function `validate-inscription` para server-side validation + duplicate check
- Insert via `supabase.from('event_registrations').insert()`
- Honeypot anti-spam (campo hidden `name="website"`, `tabIndex={-1}`)
- Rate limiting (5s entre submissões)
- Auto-redirect para evento após 3 segundos

### 15. NewsletterSection i18n Keys

O `NewsletterSection.jsx` usa chaves do namespace `artigos_page`:
- `artigos_page.newsletter_title`, `artigos_page.newsletter_subtitle`
- `artigos_page.newsletter_email_placeholder`, `artigos_page.newsletter_submit`
- `artigos_page.newsletter_success`, `artigos_page.newsletter_exists`, `artigos_page.newsletter_error`

**IMPORTANTE:** As 3 chaves de estado (success, exists, error) foram adicionadas em Fase 3. Antes disso, o componente renderizava raw key paths.

### 16. `font-display` no Tailwind v4 @theme

Para usar `Fraunces` como fonte display, adicionar ao `@theme` em `globals.css`:
```css
@theme {
  --font-display: "Fraunces", Georgia, serif;
}
```
Depois usar `font-display` como classe Tailwind (ex: `<p className="font-display italic">`).

### 17. Unsubscribe: Token via searchParams

A página unsubscribe lê `?token=` via `useSearchParams()` no Client Component. O RPC `unsubscribe_newsletter` é chamado com o token. A página não deve ser indexada (`robots: { index: false }`).

### 18. About Page: Server Component com HeroSection

A página sobre (`app/[lang]/(public)/sobre/page.js`) é um Server Component puro — sem Client Component. Usa `HeroSection` wrapper + `Breadcrumb` + `NewsletterSection`. As traduções são carregadas server-side via `loadTranslations()` + `t()`. O `NewsletterSection` é o único Client Component (renderizado como filho do Server Component).

### 19. Admin Route Group Architecture

O admin usa dois route groups dentro de `app/[lang]/admin/`:
- `admin/page.js` — Login (SEM sidebar, herda apenas root layout)
- `admin/(protected)/layout.js` — Layout com sidebar + topbar + AuthGuard

O `AdminSidebarWrapper` é um Client Component que combina `AdminSidebar` + `AdminTopBar` + content area e gere o estado mobile (sidebar open/close) e o handler de logout.

### 20. Server Actions com requireAdmin() Pattern

Todas as Server Actions de mutação (INSERT/UPDATE/DELETE) usam um helper `requireAdmin()` que faz dupla verificação:
1. `supabase.auth.getUser()` — verifica sessão ativa
2. `supabase.from('admin_users').select('user_id').eq('user_id', user.id)` — verifica na tabela admin_users

Este helper vive em cada ficheiro de actions (não importado de módulo partilhado) para evitar dependências circulares. Retorna `{ supabase, user }` ou `null`.

### 21. Admin CSS Variable System

`styles/admin/admin.css` define todas as variáveis em `:root` e sobrescreve em `html.dark`:
- `--admin-bg`, `--admin-card-bg`, `--admin-input-bg`, `--admin-text`, `--admin-text-muted`, `--admin-border`, `--admin-divider`
- Stat card colors: `--stat-green`, `--stat-blue`, etc. (gradientes)
- Dark mode: `--admin-success-bg`, `--admin-danger-bg`, `--admin-warning-bg`

O CSS é importado APENAS no `(protected)/layout.js`. O toggle dark mode vive no `AdminSidebar` footer.

### 22. Stats Grid Mobile Scroll Pattern

Para grids de stats que precisam de scroll horizontal em mobile:
- Wrapper `.admin-stats-scroll` com `display: contents` no desktop
- Em `@media (max-width: 768px)`: `display: flex`, `overflow-x: auto`, `scroll-snap-type: x mandatory`
- Cards com `flex: 0 0 calc(50% - 6px)` e `scroll-snap-align: start`

### 23. MarkdownEditor com DOMPurify (SEC-XSS-05)

O `MarkdownEditor` é um Client Component com:
- Textarea base + botões "Expandir" e "Pré-visualizar"
- Editor fullscreen overlay (controla `document.body.style.overflow`)
- Preview usa `marked.parse()` + `DOMPurify.sanitize()` com `ALLOWED_TAGS`, `ALLOWED_ATTR`, `ALLOWED_URI_REGEXP`
- `dangerouslySetInnerHTML` recebe APENAS HTML sanitizado

### 24. Idle Timeout em AuthGuard (SEC-ATH-03)

O `useIdleTimeout()` é chamado DENTRO do `AuthGuard`, que envolve TODAS as páginas protected. Timeout de 30 minutos. Eventos: click, keydown, mousemove, scroll, touchstart. Auto-logout: `signOut()` + redirect.

### 25. ImageUpload com Compressão Client-Side (SEC-UPL-01)

`ImageUpload` valida MIME type (`image/jpeg`, `image/png`, `image/webp`, `image/gif`) e tamanho (5MB) antes de fazer upload. Usa canvas para comprimir (max 1200px width, quality 0.85). Upload para Supabase Storage com nome sanitizado (`replace(/[^a-zA-Z0-9._-]/g, '_')`).

### 26. middleware.js: Admin Protection

O middleware faz tripla proteção para rotas admin:
1. Rota `/admin` (login): se autenticado + admin_users → redirect para dashboard
2. Rotas `/admin/*`: verifica `getUser()` + `admin_users`. Se falha, faz `signOut()` + redirect para login
3. Todas as rotas: injeta header `x-lang` para o root layout
