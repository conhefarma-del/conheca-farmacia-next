# CLAUDE-Next.md

Lições aprendidas do projeto "Conheça Farmácia" — Next.js App Router.

## General Lessons

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

Em proxy e Server Components, `cookies()` é async. Sempre `const cookieStore = await cookies()`.

### 13. Next.js — Server vs Client Components

- `'use server'` no topo = Server Action (pode aceder a Supabase, não pode usar hooks)
- `'use client'` no topo = Client Component (pode usar hooks, não pode aceder diretamente a Supabase server)
- Server Components são o padrão — só adicionar `'use client'` quando necessário

### 14. Next.js — Security Headers

Security headers estão em `vercel.json` (Vercel) e `next.config.mjs` (fallback para outros hosts). Não duplicar no proxy.

### 15. Next.js — Build Verification

Após qualquer alteração, verificar build:
```bash
npm run build 2>&1 | tail -20
```
O build Next.js valida syntax, imports, e routes automaticamente.

## Next.js Specific Lessons

### 16. Server vs Client Components

- Server Components são o padrão — só adicionar `'use client'` quando necessário
- Usar `"use client"` apenas para hooks, event listeners, browser APIs
- Server Components podem importar e renderizar Client Components como filhos
- **NUNCA passar funções como props de Server para Client Components** — usar `LangContext` nos Client Components

### 17. Tailwind v4 @apply com tokens

Em Tailwind v4, `@apply` com tokens não definidos no `@theme` descarta o CSS silenciosamente. Garantir que todos os tokens estão definidos.

### 18. CSS specificity layers

Selectors fora de `@layer` sobrescrevem regras dentro de `@layer`. Usar `@layer` para organizar, mas ter cuidado com a especificidade.

### 19. Supabase client pattern

Usar `createServerClient()` para Server Components, `createBrowserClient()` para Client Components. Nunca misturar.

### 20. Drawer state: Callback Lifting

Quando dois componentes irmãos precisam de estado partilhado (Header + MobileDrawer), o estado vive no componente pai (PublicLayout) e é passado via props/callbacks.

### 21. CSS Isolation com Route Groups

`styles/admin/admin.css` é importado APENAS no layout `(admin)/layout.js`. Os seletores usam prefixos `.admin-*`. Nunca importar admin CSS no layout público.

### 22. i18n Server-Side (não fetch)

O Next.js não precisa de `fetch('/i18n/pt.json')`. Usar `fs.readFileSync` diretamente em Server Components. O cache em memória evita re-leitura.

### 23. Nunca Top-Level Await em main.js

Regra herdada do Vite: `main.js` NUNCA pode conter `await`. Usar `i18nReady` non-blocking pattern.

### 24. Turbopack Bug com Caracteres Acentuados no Path (Windows)

Turbopack não suporta caracteres acentuados (ç, ã, é) no path do diretório do projeto. Erro: `couldn't find build manifest`. Solução: garantir que o path do projeto não tem caracteres acentuados. O projeto foi renomeado de "Criação de WebSites" para "criacao-de-websites" para resolver este problema. Turbopack funciona nativamente sem `--webpack`.

### 25. Funções Não Atravessam a Fronteira Server→Client

Server Components NÃO podem passar funções (como `t`) como props para Client Components. O Next.js serializa props com `JSON.stringify` — funções não são serializáveis. Solução: Client Components obtêm `t` de `useContext(LangContext)`.

### 26. onClick Não Funciona em Server Components

Event handlers (`onClick`, `onSubmit`, etc.) requerem interatividade e só funcionam em Client Components. Nunca usar `onClick` com async function inline num Server Component. Extrair para um Client Component.

### 27. Breadcrumb recebe items

O componente `Breadcrumb` recebe um array de items como prop. Nunca hardcodar os links dentro do componente.

### 28. Search client-side com Supabase ilike

A pesquisa usa `supabase.from('table').select().ilike('column', `%${query}%`)`. É client-side porque precisa de acesso direto ao Supabase.

### 29. Inscription form: Edge Function + honeypot

O formulário de inscrição usa:
- Edge Function para enviar email de confirmação
- Honeypot field para prevenir spam
- Rate limiting via Edge Function

### 30. NewsletterSection i18n keys

As chaves i18n do `NewsletterSection` devem corresponder exatamente ao que está no JSON de traduções. Verificar sempre as chaves disponíveis.

### 31. font-display no Tailwind v4 @theme

Em Tailwind v4, usar `@theme` em `globals.css` para definir fontes customizadas:
```css
@theme {
  --font-display: 'Fraunces', serif;
  --font-body: 'DM Sans', sans-serif;
}
```

### 32. Unsubscribe: token via searchParams

O unsubscribe usa um token único passado via `searchParams`. Nunca expor o email do utilizador na URL.

### 33. About page: Server Component com HeroSection

A página About é um Server Component que renderiza `HeroSection` como Client Component. O conteúdo estático fica no Server Component.

### 34. Admin route group architecture

O admin usa route group `(admin)` com layout próprio que importa `admin.css`. O `AuthGuard` envolve todas as rotas protected.

### 35. Server Actions com requireAdmin() pattern

Todas as Server Actions de mutação (INSERT/UPDATE/DELETE) usam um helper `requireAdmin()` que faz dupla verificação:
1. `supabase.auth.getUser()` — verifica sessão ativa
2. `supabase.from('admin_users').select('user_id').eq('user_id', user.id)` — verifica na tabela admin_users

Este helper vive em cada ficheiro de actions (não importado de módulo partilhado) para evitar dependências circulares. Retorna `{ supabase, user }` ou `null`.

### 36. Admin CSS Variable System

`styles/admin/admin.css` define todas as variáveis em `:root` e sobrescreve em `html.dark`:
- `--admin-bg`, `--admin-card-bg`, `--admin-input-bg`, `--admin-text`, `--admin-text-muted`, `--admin-border`, `--admin-divider`
- Stat card colors: `--stat-green`, `--stat-blue`, etc. (gradientes)
- Dark mode: `--admin-success-bg`, `--admin-danger-bg`, `--admin-warning-bg`

O CSS é importado APENAS no `(protected)/layout.js`. O toggle dark mode vive no `AdminSidebar` footer.

### 37. Stats Grid Mobile Scroll Pattern

Para grids de stats que precisam de scroll horizontal em mobile:
- Wrapper `.admin-stats-scroll` com `display: contents` no desktop
- Em `@media (max-width: 768px)`: `display: flex`, `overflow-x: auto`, `scroll-snap-type: x mandatory`
- Cards com `flex: 0 0 calc(50% - 6px)` e `scroll-snap-align: start`

### 38. MarkdownEditor com DOMPurify (SEC-XSS-05)

O `MarkdownEditor` é um Client Component com:
- Textarea base + botões "Expandir" e "Pré-visualizar"
- Editor fullscreen overlay (controla `document.body.style.overflow`)
- Preview usa `marked.parse()` + `DOMPurify.sanitize()` com `ALLOWED_TAGS`, `ALLOWED_ATTR`, `ALLOWED_URI_REGEXP`
- `dangerouslySetInnerHTML` recebe APENAS HTML sanitizado

### 39. Idle Timeout em AuthGuard (SEC-ATH-03)

O `useIdleTimeout()` é chamado DENTRO do `AuthGuard`, que envolve TODAS as páginas protected. Timeout de 30 minutos. Eventos: click, keydown, mousemove, scroll, touchstart. Auto-logout: `signOut()` + redirect.

### 40. ImageUpload com Compressão Client-Side (SEC-UPL-01)

`ImageUpload` valida MIME type (`image/jpeg`, `image/png`, `image/webp`, `image/gif`) e tamanho (5MB) antes de fazer upload. Usa canvas para comprimir (max 1200px width, quality 0.85). Upload para Supabase Storage com nome sanitizado (`replace(/[^a-zA-Z0-9._-]/g, '_')`).

### 41. proxy.js: Admin Protection (Next.js 16)

O proxy (anteriormente middleware) faz tripla proteção para rotas admin:
1. Rota `/admin` (login): se autenticado + admin_users → redirect para dashboard
2. Rotas `/admin/*`: verifica `getUser()` + `admin_users`. Se falha, faz `signOut()` + redirect para login
3. Todas as rotas: injeta header `x-lang` para o root layout

**Nota:** Next.js 16 renomeou `middleware.js` para `proxy.js` e a função `middleware` para `proxy`. O Proxy usa Node.js runtime por defeito (não Edge), o que melhora a compatibilidade com `@supabase/ssr`.

### 42. Vercel — Deploy Automático

Vercel deteta Next.js automaticamente. Não precisa de configuração de build:
- **Framework**: auto-detectado como Next.js
- **Build command**: `next build` (automático)
- **Output**: `.next` (automático)
- **Security headers**: `vercel.json` (HSTS, CSP, X-Frame-Options, etc.)
- **Env vars**: Configurar no dashboard Vercel (NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY)
- **Deploy**: `npx vercel` (preview) ou `npx vercel --prod` (produção)
- **Branch previews**: Automático — cada push gera preview URL
- **`.vercelignore`**: Usar `/supabase/` (com `/` inicial) para ignorar apenas a pasta raiz, não `lib/supabase/`

### 43. .vercelignore: Cuidado com Patterns Genéricos

O `.vercelignore` usa patterns como `.gitignore`. O pattern `supabase/` ignora **todas** as pastas chamadas `supabase` em qualquer nível — incluindo `lib/supabase/`. Isto causou 23 erros "Module not found" no Vercel porque os ficheiros `lib/supabase/client.js` e `lib/supabase/server.js` eram removidos antes do build.

**Solução:** Usar `/supabase/` (com `/` inicial) para ignorar apenas a pasta `supabase/` na raiz do projeto.

```bash
# ❌ Errado — ignora em todos os diretórios
supabase/

# ✅ Correto — ignora apenas na raiz
/supabase/
```

### 44. Netlify → Vercel Migration Completa

Migração de Netlify para Vercel concluída (2026-05-28):
- `.vercelignore` configurado (corrigido pattern `/supabase/`)
- `vercel.json` com security headers
- Env vars configuradas no dashboard Vercel
- Deploy automático via push para GitHub
- Turbopack funciona nativamente (path ASCII)
- `proxy.js` substitui `middleware.js` (Next.js 16)

### 45. force-dynamic: cookies() Impede Static Generation

Páginas que usam `cookies()` (via `createClient()` do Supabase) não podem ser pré-renderizadas estaticamente. O Next.js lança o erro `DYNAMIC_SERVER_USAGE` durante o build/prerendering, que resulta num 500 em produção.

**Causa:** O `try/catch` capturava o erro de framework `DYNAMIC_SERVER_USAGE` e chamava `notFound()`, mas isso não resolvia — o Next.js precisava de saber ANTES que a página é dinâmica.

**Solução:** Adicionar `export const dynamic = 'force-dynamic'` em todas as páginas que usam `createClient()`:
- `app/[lang]/(public)/artigos/[slug]/page.js`
- `app/[lang]/(public)/eventos/[slug]/page.js`
- `app/[lang]/(public)/lives/[slug]/page.js`

**Diagnóstico:** `npx vercel logs --level=error --expand` mostra a mensagem completa do erro.

### 46. OpenGraph: Tipos Válidos

O Next.js não aceita `type: 'event'` no metadata OpenGraph. Os tipos válidos são: `website`, `article`, `profile`, `book`, `music.song`, `music.album`, `music.playlist`, `music.radio_station`, `video.movie`, `video.episode`, `video.tv_show`, `video.other`.

**Erro:** `Error: Invalid OpenGraph type: event` → crasha a página com 500.

**Solução:** Usar `type: 'website'` para eventos ou outros tipos de conteúdo não listados.

```js
// ❌ Errado
openGraph: { type: 'event' }

// ✅ Correto
openGraph: { type: 'website' }
```

### 47. Slugs: Sem Caracteres Acentuados

Slugs com caracteres acentuados (ex: `farmacocinética`) causam 404 no Next.js. O routing não encontra a página porque o slug no URL é codificado/decodificado de forma inconsistente.

**Exemplo:** O evento `workshop-farmacocinética` aparece na listagem (card com imagem), mas a página de detalhe retorna 404.

**Solução:** Slugs devem usar apenas `a-z`, `0-9` e `-`. Remover acentos antes de guardar no CMS.

```bash
# ❌ Errado — acentos no slug
workshop-farmacocinética

# ✅ Correto — slug sem acentos
workshop-farmacocinetica
```
