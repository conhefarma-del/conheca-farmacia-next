# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

```bash
# Dev server (http://localhost:3000)
npm run dev

# Production build
npm run build

# Start production server
npm run start

# Lint
npm run lint

# Format code
npm run format

# Vercel deploy (preview)
npx vercel

# Vercel deploy (production)
npx vercel --prod
```

## Project Architecture

### Core Technologies

- **Framework**: Next.js 16.2.6 (App Router)
- **React**: 19.2.4
- **Styling**: Tailwind CSS v4 (`@tailwindcss/postcss`)
- **Backend**: Supabase (PostgreSQL, Auth, RLS, Edge Functions)
- **SSR**: `@supabase/ssr` for server-side rendering
- **Deploy**: Vercel
- **i18n**: Dynamic `[lang]` route segment (PT/EN)

### Directory Structure
- Sempre restrinja buscas e comandos glob a subdiretórios específicos. Nunca use padrões genéricos como '**/*' na raiz do projeto.

```
├── app/
│   ├── layout.js                    # Root layout (html, body, fonts, ThemeProvider, globals.css)
│   ├── page.js                      # Root redirect → /pt
│   ├── not-found.jsx                # Global 404
│   ├── robots.js                    # Dynamic robots.txt
│   ├── sitemap.js                   # Dynamic sitemap.xml
│   ├── [lang]/                      # Dynamic locale segment
│   │   ├── layout.js                # Lang layout (LangProvider with translations)
│   │   ├── page.js                  # Homepage
│   │   ├── (public)/                # Public routes (header, footer)
│   │   │   ├── layout.js            # Public layout (Client — owns drawer + scroll state)
│   │   │   ├── artigos/             # PT: Articles list + [slug] detail
│   │   │   ├── articles/            # EN: Articles list + [slug] detail (mirror)
│   │   │   ├── eventos/             # PT: Events list + [slug] detail
│   │   │   ├── events/              # EN: Events list + [slug] detail (mirror)
│   │   │   ├── lives/               # Lives list + [slug] detail (shared PT/EN slug)
│   │   │   ├── inscricao/           # PT: Registration form
│   │   │   ├── register/            # EN: Registration form (mirror)
│   │   │   ├── pesquisa/            # PT: Search page
│   │   │   ├── search/              # EN: Search page (mirror)
│   │   │   ├── sobre/               # PT: About page
│   │   │   ├── about/               # EN: About page (mirror)
│   │   │   └── unsubscribe/         # Shared token-based unsubscribe
│   │   └── (admin)/                 # Admin routes (protected)
│   │       ├── layout.js            # Admin layout (sidebar, auth check)
│   │       ├── login/               # Login page
│   │       ├── dashboard/           # Dashboard
│   │       ├── artigos/             # CRUD articles (PT)
│   │       ├── eventos/             # CRUD events (PT)
│   │       ├── lives/               # CRUD lives (PT)
│   │       ├── newsletter/          # Newsletter management
│   │       ├── traducoes/           # Bulk translation page
│   │       └── definicoes/          # Settings (2FA, profile, password)
│
├── components/
│   ├── layout/                      # Public layout: Header, Footer, UtilityBar, MobileDrawer
│   ├── admin/                       # Admin-only: BilingualTabs, forms, lists, AuthGuard
│   ├── ui/                          # Reusable: ArticleCard, EventCard, LiveCard,
│   │                                #         LanguageSwitcher, ThemeToggle, Breadcrumb,
│   │                                #         NewsletterSection, HeroSection
│   ├── content/                     # PageViewTracker, MDX helpers
│   ├── home/                        # Homepage-specific sections
│   ├── pages/                       # Page-level composite components
│   ├── providers/                   # ThemeProvider, etc.
│   ├── i18n/                        # i18n client helpers
│   ├── Header.js, Footer.js         # (legacy flat layout — see components/layout/)
│   └── ...
│
├── lib/                             # Utilities
│   ├── supabase/
│   │   ├── server.js                # createClient() for Server Components
│   │   ├── client.js                # createBrowserClient() for Client Components
│   │   └── admin.js                 # createAdminClient() for admin operations
│   ├── api/                         # API functions
│   ├── actions/                     # Server Actions
│   │   ├── auth.js, content.js, dashboard.js, lists.js,
│   │   ├── newsletter.js, settings.js
│   │   └── translation.js           # OpenRouter auto-translate + save/merge
│   ├── i18n.js                      # Server-side i18n (loadTranslations, t)
│   ├── i18n-routes.js               # PT↔EN URL slug mapping (see Lição 48)
│   ├── contexts.js                  # LangContext, etc.
│   └── security.js                  # escapeHtml, escapeAttr, validateUrl
│
├── hooks/                           # Custom React hooks
├── styles/                          # globals.css + admin/admin.css
├── public/                          # Static assets (i18n, logos, content)
├── supabase/                        # Migrations + Edge Functions
├── proxy.js                         # Auth, i18n redirect, admin protection (Next.js 16)
├── next.config.mjs                  # Next.js config + security headers
├── vercel.json                      # Vercel security headers
└── CLAUDE-Next.md                   # Lessons learned (Next.js specific)
```

### Data Flow

1. **Server Components**: Fetch data directly from Supabase via `lib/supabase/server.js`
2. **Server Actions**: Mutations via `lib/actions/` (create, update, delete)
3. **Client Components**: Use `createBrowserClient()` for real-time features
4. **Proxy**: Handles auth, i18n redirect (`/` → `/pt`), admin protection
5. **i18n — UI labels**: Server-side via `lib/i18n.js` + `public/i18n/*.json`
6. **i18n — URL slugs**: PT/EN têm directórios espelhados. Ver `lib/i18n-routes.js` (Lição 48) e `i18n Strategy` abaixo

### Key Patterns

- **Server vs Client**: `'use server'` for actions, `'use client'` for interactive components
- **i18n (labels)**: `const dict = await getDictionary(lang)` in Server Components, `useLang()` context in Client Components
- **i18n (URL)**: Usar `getSectionHref(lang, 'artigos')` para secções estáticas; `getLocalizedPath(pathname, newLang)` para pathname dinâmico. NUNCA `\`\${lang}/artigos\`` hardcoded — não navega para o mirror EN
- **Dark Mode**: `html.dark` class, CSS variables, `ThemeProvider` in root layout
- **Admin**: Protected by proxy (session + admin_users table check)
- **Security Headers**: `vercel.json` (primary) + `next.config.mjs` (fallback)
- **Public layout state**: Utility bar + header stacking state lives in `app/[lang]/(public)/layout.js` (Client Component) — see `Public Layout Fixed Stacking` in memory

### Supabase SSR Clients

3 clients with different scopes:

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

**Proxy** (`lib/supabase/middleware.js`):
```js
// updateSession(request) — cookie proxy pattern para refresh de sessão
```

### i18n Strategy (Two Layers)

**Layer 1 — UI labels (server-side dictionary):**
- `public/i18n/{pt,en}.json` — ficheiros JSON carregados em `app/[lang]/layout.js`
- Server: `loadTranslations(lang)` (cached) → `t(translations, 'key.path')`
- Client: `useContext(LangContext)` → `t('key.path')`
- **NUNCA passar `t` como prop de Server Component para Client Component** — funções não atravessam a fronteira RSC

**Layer 2 — URL slugs (mirrored directories):**
- PT e EN têm directórios físicos separados: `artigos/` ↔ `articles/`, `eventos/` ↔ `events/`, `sobre/` ↔ `about/`, `pesquisa/` ↔ `search/`, `inscricao/` ↔ `register/`
- `lives/` e `unsubscribe/` são partilhados (slug único)
- `lib/i18n-routes.js` centraliza o mapeamento. **NUNCA trocar só o segmento `lang` por substituição de string** — `/pt/artigos/foo` precisa de ir para `/en/articles/foo`, não `/en/artigos/foo` (404)

```js
import { getSectionHref, getLocalizedPath } from '@/lib/i18n-routes'

// Secção estática
const href = getSectionHref(lang, 'artigos')  // /pt/artigos ou /en/articles

// Pathname dinâmico (LanguageSwitcher)
const next = getLocalizedPath('/pt/artigos/abc', 'en')  // /en/articles/abc
```

Quando adicionar uma nova secção PT, criar também o mirror EN (mesmo que re-exporte do PT no início). Adicionar a entrada em `PT_TO_EN` em `lib/i18n-routes.js`.

### Vercel Insights

- `@vercel/analytics` e `@vercel/speed-insights` integrados em `app/layout.js` (dentro de `<ThemeProvider>`, depois de `{children}`)
- Subpath imports: `import { Analytics } from '@vercel/analytics/next'` e `import { SpeedInsights } from '@vercel/speed-insights/next'`
- Não precisam de env vars adicionais — funcionam out-of-the-box
- Em dev: visíveis como console warnings/headers; em produção: visíveis no dashboard Vercel

### Proxy (Next.js 16)

O proxy (anteriormente middleware) faz tripla proteção para rotas admin:
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

### Image Upload

`ImageUpload` valida MIME type (`image/jpeg`, `image/png`, `image/webp`, `image/gif`) e tamanho (5MB) antes de fazer upload. Usa canvas para comprimir (max 1200px width, quality 0.85). Upload para Supabase Storage com nome sanitizado (`replace(/[^a-zA-Z0-9._-]/g, '_')`).

### Auth & Security

- **Auth Guard**: `AuthGuard` component que envolve todas as rotas admin
- **Idle Timeout**: 30 minutos de inatividade → auto-logout
- **2FA**: TOTP implementation em `definicoes/`
- **RLS**: Row Level Security em todas as tabelas
- **XSS Protection**: `escapeHtml()` em user input
- **CSP**: No inline scripts, usar `.addEventListener()`

## Lessons Learned

This file is the project entry point — it stays short and points to the details. Detailed patterns and historical bug fixes live in `CLAUDE-Next.md` (47 lições) and in `~/.openclaude/.../memory/` (working notes). As of 2026-06-15:

- `CLAUDE-Next.md` covers #1–#47: Supabase patterns, Next.js 16 specifics (proxy.js, force-dynamic, OpenGraph), Vercel/Netlify migration, security helpers
- Newer lições #48–#54 (this session): i18n URL mirrors, sticky header sliding with utility bar, Server Actions not as wrapper props, BilingualTabs setEnValues, OpenRouter BYOK + free model switching, OpenRouter env var HMR caveat, Vercel Analytics+Speed Insights

When adding a new lesson, prefer memory over CLAUDE.md unless it's a project-wide invariant.
