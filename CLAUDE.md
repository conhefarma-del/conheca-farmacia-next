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
├── middleware.js                     # Auth, i18n redirect, admin protection
├── next.config.mjs                  # Next.js config + security headers
├── vercel.json                      # Vercel security headers
└── CLAUDE-Next.md                   # Detailed Next.js guide + lessons learned
```

### Data Flow

1. **Server Components**: Fetch data directly from Supabase via `lib/supabase/server.js`
2. **Server Actions**: Mutations via `lib/actions/` (create, update, delete)
3. **Client Components**: Use `createBrowserClient()` for real-time features
4. **Middleware**: Handles auth, i18n redirect (`/` → `/pt`), admin protection
5. **i18n**: Server-side via `lib/i18n.js` + `public/i18n/*.json`

### Key Patterns

- **Server vs Client**: `'use server'` for actions, `'use client'` for interactive components
- **i18n**: `const dict = await getDictionary(lang)` in Server Components, `useLang()` context in Client Components
- **Dark Mode**: `html.dark` class, CSS variables, `ThemeProvider` in root layout
- **Admin**: Protected by middleware (session + admin_users table check)
- **Security Headers**: `vercel.json` (primary) + `next.config.mjs` (fallback)

## Lições Aprendidas (Erros a Evitar)

### 1. Edição de Ficheiros JavaScript

**Problema**: Quando editar funções em ficheiros JS, garantir que todas as chaves de abertura têm correspondente de fecho e não deixar código incompleto.

**Solução**: Após qualquer edição, validar com build:
```bash
npm run build 2>&1 | tail -20
```

### 2. Substituição de Funções em Ficheiros Existentes

**Problema**: Ao substituir funções inteiras, o padrão de busca pode não ser exato devido a diferenças de whitespace, linhas em branco, ou comentários adjacentes.

**Solução**: Ler o ficheiro completo primeiro, identificar marcadores únicos, usar Python para substituições complexas.

### 3. Validação de Sintaxe Após Edição

**Problema**: Ficheiros JS com erro de sintaxe causam build failures.

**Solução**: Após qualquer edição, validar com build:
```bash
npm run build 2>&1 | tail -20
```

### 4. Git - Lidar com Line Endings (CRLF vs LF)

No Windows, Git converte LF para CRLF automaticamente. Warnings são normais — não alterar manualmente.

### 5. Debounce em Event Listeners

**Problema**: Event listeners como `input` disparam a cada caractere, causando múltiplas chamadas de API.

**Solução**:
```javascript
let debounceTimer;
searchInput.addEventListener('input', (e) => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(async () => { /* ... */ }, 300);
});
```

### 6. XSS Protection em User Input

**Problema**: Mostrar conteúdo de pesquisa (títulos, nomes) pode injetar HTML malicioso.

**Solução**: Usar `escapeHtml()` de `lib/security.js` antes de inserir no DOM.

### 7. Edição de Ficheiros JSON

**Problema**: Ficheiros JSON são sensíveis a aspas duplas, trailing commas, e não suportam comentários.

**Solução**: Validar com `JSON.parse()`:
```bash
node -e "JSON.parse(require('fs').readFileSync('package.json'))"
```

### 8. CSP — No Inline Scripts

Nunca usar `onclick=`, `onsubmit=`, inline `<script>` sem `type="module"`, ou `style=""`. Sempre usar `.addEventListener()`. CSP bloqueia handlers inline.

### 9. Dark Mode Toggle Classes

SVG icons devem usar `class="sun-icon"` e `class="moon-icon"` (nunca `theme-icon-light`/`theme-icon-dark`). O drawer toggle é `<button class="drawer-theme-toggle">` diretamente.

### 10. i18n — Nunca Hardcoded Strings

Todas as strings visíveis devem usar `data-i18n` (MPA) ou `t('key')` (Next.js). Traduções ficam em `public/i18n/`.

### 11. Next.js — params é Promise

Em Server Components, `params` é uma Promise. Sempre fazer `const { lang } = await params`.

### 12. Next.js — cookies() é Async

Em middleware e Server Components, `cookies()` é async. Sempre `const cookieStore = await cookies()`.

### 13. Next.js — Server vs Client Components

- `'use server'` no topo = Server Action (pode aceder a Supabase, não pode usar hooks)
- `'use client'` no topo = Client Component (pode usar hooks, não pode aceder diretamente a Supabase server)
- Server Components são o padrão — só adicionar `'use client'` quando necessário

### 14. Next.js — Security Headers

Security headers estão em `vercel.json` (Vercel) e `next.config.mjs` (fallback para outros hosts). Não duplicar no middleware.

### 15. Next.js — Build Verification

Após qualquer alteração, verificar build:
```bash
npm run build 2>&1 | tail -20
```
O build Next.js valida syntax, imports, e routes automaticamente.

> Para lições detalhadas sobre Next.js (Server Components, drawer state, i18n, etc.), ver `CLAUDE-Next.md`.
