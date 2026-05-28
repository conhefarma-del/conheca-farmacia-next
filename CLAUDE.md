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
│   │   │   ├── layout.js            # Public layout
│   │   │   ├── artigos/             # Articles list + [slug] detail
│   │   │   ├── eventos/             # Events list + [slug] detail
│   │   │   ├── lives/               # Lives list + [slug] detail
│   │   │   ├── inscricao/           # Registration form
│   │   │   ├── pesquisa/            # Search page
│   │   │   ├── sobre/               # About page
│   │   │   └── unsubscribe/         # Newsletter unsubscribe
│   │   └── (admin)/                 # Admin routes (protected)
│   │       ├── layout.js            # Admin layout (sidebar, auth check)
│   │       ├── login/               # Login page
│   │       ├── dashboard/           # Dashboard
│   │       ├── artigos/             # CRUD articles
│   │       ├── eventos/             # CRUD events
│   │       ├── lives/               # CRUD lives
│   │       ├── newsletter/          # Newsletter management
│   │       └── definicoes/          # Settings (2FA, profile, password)
│
├── components/                      # React components
│   ├── Header.js, Footer.js         # Layout components
│   ├── UtilityBar.js, MobileDrawer.js
│   ├── ArticleCard.js, EventCard.js, LiveCard.js
│   ├── MarkdownEditor.js, ImageUpload.js
│   └── ...
│
├── lib/                             # Utilities
│   ├── supabase/
│   │   ├── server.js                # createClient() for Server Components
│   │   ├── client.js                # createBrowserClient() for Client Components
│   │   └── admin.js                 # createAdminClient() for admin operations
│   ├── api/                         # API functions
│   ├── actions/                     # Server Actions
│   ├── i18n.js                      # Server-side i18n
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
5. **i18n**: Server-side via `lib/i18n.js` + `public/i18n/*.json`

### Key Patterns

- **Server vs Client**: `'use server'` for actions, `'use client'` for interactive components
- **i18n**: `const dict = await getDictionary(lang)` in Server Components, `useLang()` context in Client Components
- **Dark Mode**: `html.dark` class, CSS variables, `ThemeProvider` in root layout
- **Admin**: Protected by proxy (session + admin_users table check)
- **Security Headers**: `vercel.json` (primary) + `next.config.mjs` (fallback)

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

For Next.js-specific lessons and detailed patterns, see `CLAUDE-Next.md`.
