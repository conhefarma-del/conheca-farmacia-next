# Fase 6 — Cutover: Vite → Next.js + Vercel Deployment

> **Agentic worker:** usar `superpowers:executing-plans` para executar este plano.

## Goal

Remover todos os resíduos do Vite/MPA, configurar deploy na Vercel com security headers, e atualizar documentação para refletir a arquitetura Next.js final.

## Architecture

3 sub-fases sequenciais:
1. **6.1 — Limpeza de resíduos Vite** — remover ficheiros obsoletos
2. **6.2 — Configuração Vercel** — vercel.json com security headers + i18n rewrites
3. **6.3 — Documentação** — atualizar CLAUDE.md e CLAUDE-Next.md

## Tech Stack

- Next.js 16.2.6 (App Router)
- Vercel (deploy platform)
- Tailwind CSS v4 (`@tailwindcss/postcss`)
- Supabase SSR (`@supabase/ssr`)

---

## Sub-fase 6.1 — Limpeza de Resíduos Vite

### Task 1: Remover tailwind.config.js obsoleto

**Ficheiros:**
- DELETE `tailwind.config.js`

**Passos:**
- [ ] 1. Verificar que `tailwind.config.js` referencia apenas padrões Vite (`./*.html`, `./src/**/*`)
- [ ] 2. Confirmar que `postcss.config.mjs` com `@tailwindcss/postcss` é suficiente para Next.js
- [ ] 3. Apagar `tailwind.config.js`
- [ ] 4. `npm run build -- --no-lint 2>&1 | tail -10` — Esperado: sucesso
- [ ] 5. Commit: `git add -A && git commit -m "chore(6.1): remove obsolete tailwind.config.js"`

---

### Task 2: Limpar .env com variáveis VITE_

**Ficheiros:**
- DELETE `.env`
- KEEP `.env.local` (variáveis NEXT_PUBLIC_*)

**Passos:**
- [ ] 1. Verificar conteúdo de `.env` — deve conter apenas `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`
- [ ] 2. Verificar que `.env.local` tem `NEXT_PUBLIC_SUPABASE_URL` e `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- [ ] 3. Apagar `.env`
- [ ] 4. `npm run build -- --no-lint 2>&1 | tail -10` — Esperado: sucesso
- [ ] 5. Commit: `git add -A && git commit -m "chore(6.1): remove .env with VITE_ variables"`

---

### Task 3: Remover diretórios temporários nextjs-temp/ e next-temp/

**Ficheiros:**
- DELETE `nextjs-temp/` (scaffold create-next-app)
- DELETE `next-temp/` (scaffold com node_modules)

**Passos:**
- [ ] 1. Confirmar que nenhum ficheiro destes diretórios é usado pelo projeto principal
- [ ] 2. `rm -rf nextjs-temp/ next-temp/`
- [ ] 3. Commit: `git add -A && git commit -m "chore(6.1): remove nextjs-temp and next-temp scaffolds"`

---

### Task 4: Remover public/js/404-page.js antigo

**Ficheiros:**
- DELETE `public/js/404-page.js`

**Passos:**
- [ ] 1. Verificar que `app/not-found.jsx` é a página 404 atual do Next.js
- [ ] 2. Verificar que nenhum componente importa `public/js/404-page.js`
- [ ] 3. Apagar `public/js/404-page.js`
- [ ] 4. `npm run build -- --no-lint 2>&1 | tail -10` — Esperado: sucesso
- [ ] 5. Commit: `git add -A && git commit -m "chore(6.1): remove legacy 404-page.js from public/js"`

---

### Task 5: Remover netlify.toml e .netlify/

**Ficheiros:**
- DELETE `netlify.toml`
- DELETE `.netlify/` (cache Netlify)

**Passos:**
- [ ] 1. Verificar que `netlify.toml` não é referenciado por nenhum script ou config
- [ ] 2. Apagar `netlify.toml`
- [ ] 3. `rm -rf .netlify/`
- [ ] 4. Commit: `git add -A && git commit -m "chore(6.1): remove netlify.toml and .netlify cache"`

---

### Task 6: Verificar limpeza completa

**Passos:**
- [ ] 1. `npm run build -- --no-lint 2>&1 | tail -20` — Esperado: sucesso, 39 rotas
- [ ] 2. Verificar que não há ficheiros Vite restantes:
  ```bash
  ls -la tailwind.config.js vite.config.js main.js .env 2>&1
  # Todos devem dar "No such file"
  ```
- [ ] 3. Verificar que diretórios temporários foram removidos:
  ```bash
  ls -d nextjs-temp next-temp .netlify 2>&1
  # Todos devem dar "No such file"
  ```

---

## Sub-fase 6.2 — Configuração Vercel

### Task 7: Criar vercel.json com security headers

**Ficheiros:**
- CREATE `vercel.json`

**Passos:**
- [ ] 1. Criar `vercel.json` com security headers baseados nos que existiam no `netlify.toml`:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "X-Permitted-Cross-Domain-Policies", "value": "none" },
        { "key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=()" },
        { "key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: blob: https://*.supabase.co; connect-src 'self' https://*.supabase.co wss://*.supabase.co; frame-ancestors 'none'; base-uri 'self'; form-action 'self'" }
      ]
    },
    {
      "source": "/_next/static/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ]
}
```

- [ ] 2. Commit: `git add vercel.json && git commit -m "feat(6.2): add vercel.json with security headers"`

---

### Task 8: Atualizar next.config.mjs com headers de segurança como fallback

**Ficheiros:**
- MODIFY `next.config.mjs`

**Passos:**
- [ ] 1. Ler `next.config.mjs` atual
- [ ] 2. Adicionar `headers()` async function com os mesmos security headers como fallback (caso o deploy não seja na Vercel):

```js
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.supabase.co',
        pathname: '/storage/v1/object/public/**',
      },
    ],
  },
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
        ],
      },
    ]
  },
}

export default nextConfig
```

- [ ] 3. `npm run build -- --no-lint 2>&1 | tail -10` — Esperado: sucesso
- [ ] 4. Commit: `git add next.config.mjs && git commit -m "feat(6.2): add security headers to next.config.mjs as fallback"`

---

### Task 9: Atualizar .vercelignore (adição de resíduos removidos)

**Ficheiros:**
- MODIFY `.vercelignore`

**Passos:**
- [ ] 1. Ler `.vercelignore` atual
- [ ] 2. Adicionar entradas para os diretórios removidos (garantir que não voltam):
  ```
  nextjs-temp/
  next-temp/
  netlify.toml
  .netlify/
  ```
- [ ] 3. Commit: `git add .vercelignore && git commit -m "chore(6.2): update .vercelignore with removed dirs"`

---

## Sub-fase 6.3 — Documentação

### Task 10: Atualizar CLAUDE.md para arquitetura Next.js + Vercel

**Ficheiros:**
- REWRITE `CLAUDE.md`

**Passos:**
- [ ] 1. Ler `CLAUDE.md` atual e `CLAUDE-Next.md`
- [ ] 2. Reescrever `CLAUDE.md` para refletir:
  - **Comandos:** `npm run dev` (next dev), `npm run build` (next build), `npm run start`, `npm run lint`
  - **Framework:** Next.js 16.2.6 App Router (não mais Vite)
  - **Deploy:** Vercel (não mais Netlify)
  - **Estrutura:** `app/`, `components/`, `lib/`, `hooks/`, `styles/`
  - **Backend:** Supabase SSR (não mais cliente direto)
  - **i18n:** `[lang]` route segment (não mais fetch JSON)
  - **Licoes aprendidas:** Manter as 29 genéricas, atualizar referências Vite → Next.js, remover #30 (top-level await em main.js — não aplicável)
- [ ] 3. Commit: `git add CLAUDE.md && git commit -m "docs(6.3): update CLAUDE.md for Next.js + Vercel architecture"`

---

### Task 11: Atualizar CLAUDE-Next.md — marcar Fase 6 completa

**Ficheiros:**
- MODIFY `CLAUDE-Next.md`

**Passos:**
- [ ] 1. Atualizar tabela de fases (linha ~469): Fase 6 → `✅ COMPLETA`
- [ ] 2. Atualizar comandos de dev (remover referências a `dev:next`/`build:next` — agora é `dev`/`build`)
- [ ] 3. Adicionar seção "Vercel Deployment" com instruções:
  - `vercel` para preview, `vercel --prod` para produção
  - Variáveis de ambiente no dashboard Vercel
  - Security headers via `vercel.json`
- [ ] 4. Adicionar lição aprendida #27: "Vercel deteta Next.js automaticamente — não precisa de configuração de build"
- [ ] 5. Commit: `git add CLAUDE-Next.md && git commit -m "docs(6.3): mark Phase 6 complete, add Vercel deployment guide"`

---

## Final Verification

### Task 12: Verificação final completa

**Passos:**
- [ ] 1. `npm run build -- --no-lint 2>&1 | tail -30` — Esperado: sucesso, 39 rotas
- [ ] 2. Verificar que não há referências a Netlify restantes:
  ```bash
  grep -r "netlify" --include="*.js" --include="*.jsx" --include="*.json" --include="*.toml" . --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=.git 2>/dev/null
  ```
  Esperado: apenas memórias/docs
- [ ] 3. Verificar que não há referências a Vite restantes no código:
  ```bash
  grep -r "VITE_\|vite\.\|vite\.config" --include="*.js" --include="*.jsx" --include="*.json" . --exclude-dir=node_modules --exclude-dir=.next --exclude-dir=.git 2>/dev/null
  ```
  Esperado: apenas memórias/docs
- [ ] 4. Verificar estrutura final:
  ```bash
  ls -la *.toml *.config.js .env 2>&1
  # netlify.toml, tailwind.config.js, .env devem dar "No such file"
  ls vercel.json .env.local next.config.mjs 2>&1
  # Todos devem existir
  ```
- [ ] 5. Commit final: `git add -A && git commit -m "chore(6): phase 6 cutover complete — Vite removed, Vercel configured"`
