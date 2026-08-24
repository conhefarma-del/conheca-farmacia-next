# CLAUDE-Next.md

Lições aprendidas do projeto "Conheça Farmácia" — Next.js App Router.

## Data & Supabase — Crítico

### RPC com SECURITY DEFINER para Contagens Públicas

**Problema**: Website público (sem autenticação) precisa mostrar contagem de inscrições em eventos. Usar `supabase.from('inscricoes').select('*', {count: 'exact'})` retorna 0 porque RLS bloqueia leituras anon na tabela `inscricoes`.

**Sintoma**: `spotsLeft = capacity - (inscriptionCount || 0)` → `spotsLeft = capacity` (mostra total, não vagas restantes).

**Solução**: Criar RPC `get_event_inscription_count(slug)` com `SECURITY DEFINER`:

```sql
CREATE FUNCTION get_event_inscription_count(event_slug TEXT)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result BIGINT;
BEGIN
  SELECT COUNT(*)::BIGINT INTO result
  FROM inscricoes
  WHERE evento_slug = event_slug;
  RETURN COALESCE(result, 0);
END;
$$;
```

**Regras**:
1. RPCs que leem tabelas com RLS restritiva → usar `SECURITY DEFINER`
2. `SET search_path = public` sempre (previne attack vector)
3. Chamar via `supabase.rpc()` no client
4. Para listagens, usar RPC que já retorna counts (`get_events_with_inscription_counts`)

**Princípio**: `SECURITY DEFINER` executa como owner da função, bypassando RLS. Seguro porque a função só expõe o count (não dados sensíveis).

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

## i18n Full-Stack (2026-06-15)

### 48. i18n URL Slugs: Directórios Espelhados, Não Segment Swap

A partir de 2026-06-15, o projecto evoluiu de um único directório por secção para directórios físicos separados PT/EN. Isto é necessário porque (a) os slugs das secções estão traduzidos (`artigos` ↔ `articles`), e (b) os slugs dos items também podem ter tradução (`workshop-farmacocinetica` ↔ `pharmacokinetics-workshop`).

**Estrutura actual em `app/[lang]/(public)/`:**
- PT: `artigos/`, `eventos/`, `sobre/`, `pesquisa/`, `inscricao/`
- EN: `articles/`, `events/`, `about/`, `search/`, `register/`
- Partilhados (slug único): `lives/`, `unsubscribe/`

**Helper central em `lib/i18n-routes.js`:**

```js
// Para links de secção estática
const href = getSectionHref('en', 'artigos')  // '/en/articles'
const href = getSectionHref('pt', 'lives')    // '/pt/lives' (partilhado)

// Para pathname dinâmico (LanguageSwitcher)
const next = getLocalizedPath('/pt/artigos/abc-123', 'en')
// → '/en/articles/abc-123'

// Slug dinâmico de item SEM tradução conhecida: manter o slug actual
const next = getLocalizedPath('/pt/artigos/abc-123', 'en')
// → '/en/articles/abc-123' (abc-123 preservado)
```

**Regras:**
1. **NUNCA** `\`\${lang}/artigos\`` hardcoded em componentes — não navega para o mirror EN. Usar `getSectionHref(lang, 'artigos')` em `Header`, `UtilityBar`, `MobileDrawer`, `Footer`, `LanguageSwitcher`
2. **NUNCA** fazer segment swap manual (`pathname.replace('/pt/', '/en/')`) — falha em `artigos` vs `articles`. Usar `getLocalizedPath`
3. Ao adicionar uma nova secção, criar AMBOS os directórios (PT + EN) e adicionar entrada em `PT_TO_EN` em `lib/i18n-routes.js`
4. O EN mirror pode no início ser uma re-export do PT (`export { default } from '../../artigos/page'`) até a tradução estar pronta — não é aceitável omitir o ficheiro, porque o `[lang]` middleware aceita qualquer valor em `segments[2]`

**Diagnóstico de "404 ao trocar para EN":** se a secção é nova, falta criar o mirror EN. Se já existe, falta entrada em `PT_TO_EN`.

### 49. Sticky Header Que Desliza com Utility Bar

Em 2026-06-15 refactor do `app/[lang]/(public)/layout.js` para dois wrappers fixed:
- `.utility-bar-wrapper` — `position: fixed; top: 0; z-index: 60; transform: translateY(0 | -100%)`
- `.header-wrapper` — `position: fixed; top: 60 | 0; z-index: 50; transition: top 0.4s`
- `<main style={{ paddingTop: 140 | 80 }}>` — compensa o espaço dos elementos fixed

**Erro típico (já aconteceu):** pôr `position: fixed; top: 60px` na classe CSS `.header` (filho). O CSS ganha sobre o `style` inline do wrapper, e o header nunca mexe. **Solução:** a classe CSS do header não deve ter `position`/`top` — o wrapper é dono desses valores.

**Sincronizar com mobile drawer via `body.utility-hidden`:** o `MobileDrawer` tem `top: 60` quando utility visível, `top: 80` quando escondida. A classe é toggleada no `<body>` por um `useEffect` que observa `utilityBarVisible` no `PublicLayout` (ver `mobile-drawer-utility-bar-behavior` em memory).

**Threshold de scroll:** 10px em qualquer direcção para evitar jitter no rasto de scroll. `requestAnimationFrame` throttle para evitar múltiplas render frames por scroll event.

**Cuidado com `position: sticky`:** tentação inicial é `sticky`, mas como o wrapper pai é `<body>` e a stacking é feita por `position: fixed`, `sticky` não funciona correctamente. `fixed` é a escolha certa.

### 50. Server Actions Não Podem Ser Embrulhadas em Arrow Function Prop

Em Next.js 16, Server Actions marcadas com `'use server'` são passáveis **directamente** como props a Client Components. Se forem embrulhadas numa arrow function inline, o RSC lança:

```
Event handlers cannot be passed to Client Component props
```

**Exemplo do bug (já aconteceu no BilingualTabs em 2026-06-15):**

```jsx
// ❌ Errado — arrow function quebra a referência da Server Action
<BilingualTabs onSave={(values) => saveTranslationAction('article', id, values)} />

// ✅ Correto — passa-se a action directamente; o Client Component importa-a
// (no page.js Server Component)
<BilingualTabs entityType="article" entityId={id} translation={t} fields={f} />

// (dentro de BilingualTabs.jsx, Client Component)
import { saveTranslationAction, autoTranslateEntity } from '@/lib/actions/translation'
const result = await saveTranslationAction(entityType, entityId, enValues)
```

**Regra:** se é Server Action, o Client Component deve fazer `import` directo e receber **dados**, não callbacks. Esta restrição também se aplica a `onClick={() => serverAction(...)}` — extrair a chamada para um Client Component.

### 51. Server Action Que Persiste Deve Devolver o Recurso Actualizado

`router.refresh()` (Next.js) só re-executa Server Components — não re-popula `useState` locais em Client Components. Se uma Server Action devolve `{ ok: true, translation: {...} }` mas o Client só faz `router.refresh()`, os inputs (controlados por `useState`) continuam vazios até F5 manual.

**Padrão (BilingualTabs):**

```js
const result = await autoTranslateEntity(entityType, entityId)
if (result?.ok) {
  if (result.translation) {
    setEnValues(result.translation)  // ← popula useState IMEDIATAMENTE
  }
  setSuccess(t('translation.auto_success', '...'))
  router.refresh()  // re-fetch dos dados de servidor (apenas para outras partes)
}
```

**Quando NÃO é necessário:** se o state da UI não precisa de reflectir a mutação (ex: navegação programática, toast que desaparece). **Quando É necessário:** qualquer input controlado, lista local, contador, etc. alimentado por dados que a action acabou de escrever.

**Diagnóstico:** user diz "actualizei a página e aparece" → falta `setState(result.data)`. User diz "grava mas não aparece mesmo com refresh" → Server Action não está a fazer a escrita; investigar via query directa à DB primeiro (ver `investigate-before-fixing-via-direct-db-query` em memory).

### 52. OpenRouter BYOK + Free Tier Quota Switching

Em 2026-06-15, `meta-llama/llama-3.3-70b-instruct:free` começou a retornar 429 mesmo com API key própria do user. Investigação:

**Causa:** O tier `free` no OpenRouter tem rate-limit **por-utilizador** (não global), mas é baixo (ex: 20 req/min para modelos grandes). Adicionar a key pública de demo daria quota partilhada, mas BYOK dá quota individual — esta quota esgota-se depressa com modelos 70B.

**Decisão tomada:** trocar para `google/gemma-4-31b-it:free` (256K ctx, dense 30.7B, Google). Tem quota mais generosa que Llama 3.3 70B e qualidade suficiente para tradução PT→EN de artigos farmacêuticos.

**Env var override pattern** (`lib/actions/translation.js`):

```js
const OPENROUTER_MODEL =
  process.env.OPENROUTER_MODEL || 'google/gemma-4-31b-it:free'
```

E em `.env.local.example`:

```
OPENROUTER_MODEL=google/gemma-4-31b-it:free
```

**Caveat — HMR não pega em constantes no topo de `'use server'` modules.** Mudar o env var no `.env.local` requer **restart do dev server** (`npm run dev` a frio), não apenas F5. O `process.env.OPENROUTER_MODEL` é avaliado uma vez no module-load.

**Próximos candidatos a testar** (se Gemma 4 também rate-limitar):
- `nvidia/nemotron-3-ultra-550b-a55b:free` — mais capaz (MoE 55B/550B)
- `google/gemma-4-26b-a4b-it:free` — irmão MoE mais leve (256K ctx)

**Hard-cap de segurança** (tabela `translation_logs`): `TRANSLATION_DAILY_CHAR_LIMIT=1000000` caracteres PT/dia. Mesmo que a API não rate-limite, evita custos descontrolados se alguém automatizar spam de auto-translates.

### 53. Server Action Falsy Check Pattern: `result?.ok` / `result?.rateLimited`

Actions em `lib/actions/translation.js` devolvem objectos em vez de `throw`. Padrão consistente:

```js
// sucesso
{ ok: true, translation: { title, slug, excerpt, content } }

// falha normal
{ ok: false, error: 'OpenRouter 500: ...' }

// rate-limited (caso especial — UI mostra mensagem diferente)
{ ok: false, rateLimited: true, error: '...' }

// translation disabled (feature flag off)
{ ok: false, disabled: true, error: 'translation disabled' }
```

**Lado do client** (`BilingualTabs.jsx`):

```js
if (result?.ok) {
  if (result.translation) setEnValues(result.translation)
  setSuccess(...)
  router.refresh()
} else if (result?.rateLimited) {
  setError(t('translation.rate_limited', 'Limite diário...'))
} else {
  setError(result?.error || t('translation.auto_error', 'Erro...'))
}
```

**Porquê não throw:** permite ao UI mostrar mensagens contextuais (rate limit vs erro genérico vs feature flag off) sem `try/catch` no callback. Throw seria melhor para erros inesperados (500 interno, DB offline) — mas a action apanha esses e devolve `{ ok: false, error }` em vez de propagar.

### 54. Vercel Analytics + Speed Insights: Subpath Imports, Sem Env Vars

Em 2026-06-15 adicionados:

```bash
npm i @vercel/analytics@^2.0.1 @vercel/speed-insights@^2.0.0
```

```js
// app/layout.js (Client ou Server — funciona em ambos)
import { Analytics } from '@vercel/analytics/next'
import { SpeedInsights } from '@vercel/speed-insights/next'

// Dentro do <body>, depois de {children} (importante — ver docs)
<Analytics />
<SpeedInsights />
```

**Notas:**
- Subpath `/next` para Analytics é o entry que injecta `<Script>` para o script de tracking. Existe também `@vercel/analytics/react` para client-only.
- **NÃO** precisam de env vars — funcionam out-of-the-box via domínio do deploy
- Em dev (localhost), os componentes renderizam mas não enviam (warnings no console sobre não-production)
- Em prod, primeiro deploy pode ter delay de 5-10 min até os dados aparecerem no dashboard Vercel
- Em Vercel Hobby: Analytics incluído; Speed Insights incluído. Em Pro/Enterprise: mais features

**Posição no layout:** depois de `{children}` para garantir que os componentes só mountam após a árvore React estar hidratada (algumas métricas dependem disso).

## Segurança (2026-06-15, Sentinela audit)

### 55. Rate Limit Atómico via RPC: INSERT ... ON CONFLICT

Quando o rate limit é um contador "X chars por dia", NUNCA fazer `SELECT count; if < limit; INSERT;` em Node — há uma janela TOCTOU entre o check e o insert. Dois requests paralelos ambos leem `< limit`, ambos inserem, e o total real excede o limite.

Solução canónica (Postgres): uma tabela com PK = dia, e uma função `SECURITY DEFINER` que faz tudo num statement:

```sql
INSERT INTO translation_quota (usage_date, chars_used)
VALUES (v_today, p_chars)
ON CONFLICT (usage_date) DO UPDATE
  SET chars_used = translation_quota.chars_used + EXCLUDED.chars_used
RETURNING chars_used INTO v_new_total;

IF v_new_total > p_limit THEN
  UPDATE translation_quota SET chars_used = chars_used - p_chars ...;
  RETURN FALSE;
END IF;
RETURN TRUE;
```

**Porquê `SECURITY DEFINER` + `SET search_path = public`:** o RPC é o único writer, e a tabela fica acessível só a admins via RLS. Sem `search_path` fixo, a função pode ser "shadowed" por uma tabela com o mesmo nome no schema de um utilizador malicioso — CVE conhecido do Postgres.

Implementação: `supabase/migrations/019_atomic_translation_rate_limit.sql` + `checkAndReserveQuota()` em `lib/actions/translation.js`. **Fail-closed**: se o RPC der erro, **recusar** o request (não "fail open" — um migration em falta não pode silenciosamente levantar o cap diário).

### 56. validateUrl Regex Estrito: /^https?:\/\//i

`url.startsWith('http')` aceita `httpfoo://evil`, `https.evil.example/`, `http://` (sem path), e muitos outros. A regex `^https?:\/\//i` força o delimiter `://` correcto, que é o que distingue uma URL web de qualquer outro esquema.

```js
const SAFE_URL_REGEX = /^https?:\/\//i
export function validateUrl(url) {
  if (!url || typeof url !== 'string' || !SAFE_URL_REGEX.test(url)) return '#'
  return url
}
```

**Porquê isto importa:** `validateUrl` é a última barreira antes de renderizar `<a href={...}>`. Se aceitar `javascript:alert(1)`, o click executa o script. `data:` schemes também devem ser bloqueados se o destino for um link (DOMPurify já os trata em `sanitizeHtml`).

### 57. Page View Tracker: pathname Only, Nunca Querystring

`components/content/PageViewTracker.jsx` envia `page_path` para o backend de analytics. **Nunca** inclua `window.location.search` — a querystring pode conter emails (newsletter prefill), tokens de unsubscribe, tokens de partilha, etc.

```js
// ERRADO: pathname + searchParams
const url = pathname + (searchParams.toString() ? `?${searchParams}` : '')
// CERTO: pathname only
const url = pathname
```

**Porquê:** analytics é um sink de dados menos protegido que o resto do sistema. Se uma URL de admin vazada (com um token one-off na querystring) for visitada, a querystring acaba na DB de analytics — uma exposição lateral que normalmente ninguém lembra de auditar. `pathname` é suficiente para tráfego-por-rota.

### 58. CSP Sem unsafe-eval em Next.js 16

Next.js 16 (App Router + Fluid Compute) **não** precisa de `eval()` no runtime. O CSP herdado muitas vezes tem `'unsafe-eval'` por defeito (ex.: para alguns polyfills legados), mas o `next start` e o `next build` de hoje rodam sem ele.

**Pode manter `'unsafe-inline'`** se houver um script anti-FOUC (no nosso caso, `app/layout.js:46-50` define `<html class="dark">` antes da hidratação para evitar flash de tema). Mover esse script para `useEffect` reintroduz o flash. `'unsafe-eval'` é o que pode sair sem regressão.

CSP activo em `vercel.json:35`:
```
script-src 'self' 'unsafe-inline' https://vercel.live
```

### 59. Proxy try/catch no getUser: Degradação Graciosa

O proxy (anteriormente middleware) chama `supabase.auth.getUser()` em cada request para refrescar a sessão. **Se o Supabase auth estiver offline** (5xx, timeout DNS, etc.) o proxy não pode crashar — caso contrário, **todo o site** cai junto.

```js
try {
  await supabase.auth.getUser()
} catch (proxyErr) {
  console.error('[proxy] getUser failed, continuing without session refresh', { lang, path: pathname })
}
```

Padrão geral: **um erro de um sub-sistema (auth, DB) só pode derrubar a feature que dele depende** (rotas admin), não a plataforma inteira. Rotas públicas continuam a servir mesmo com Supabase offline.

### 60. SECURITY.md + Política 2FA

O projecto não tinha `SECURITY.md` antes do audit de 2026-06-15. Criado em `SECURITY.md` na raiz, com:

- Email de disclosure (`security@conhecafarmacia.com`) + SLA
- Threat model e modelo de autenticação (público + admin)
- **Política de 2FA: enforced on first admin login** (decisão confirmada pelo user)
  - Novo admin tem de ter factor TOTP verificado antes de conseguir login
  - Admin existente (com password válida) é guiado para enrollment no próximo login
  - SMS não é aceite como segundo factor (NIST 800-63B §5.1.2)
- Inventário completo dos headers activos (incluindo o admin-only `Cache-Control: no-store` e `X-Robots-Tag: noindex, nofollow`)
- Classificação de env vars por risco (🟢 público vs 🔴 server-only)
- Histórico de advisories em `docs/security/audits/`
- **Advisories em defer:** postcss transitivo (GHSA-qx2v-qp2m-jg93) — fix do `npm audit fix --force` requer Next 9, que seria breaking. Monitor release notes do Next para bump.

A **política de 2FA é enforced** porque o `try/catch` que estava em `lib/actions/auth.js:91-93` engole silenciosamente o `getAuthenticatorAssuranceLevel` — qualquer falha (network, factor não enrolled, AAL abaixo de 2) resultava em `success: true`. Isto permitia login com password sem TOTP, independentemente da configuração do utilizador. A refactorização (commit 3.2 do PR security) fecha o bypass: se a chamada falhar, `signOut()` + erro genérico; se AAL < 2 sem factor, `signOut()` + `requiresTwoFactorEnrollment: true`.

### 61. Server Action throwCode + i18n Error Mapping Pattern (2026-06-17)

**Problema**: Server Actions que lidam com input do utilizador (formulários públicos) mostravam sempre a mesma mensagem genérica no client ("Não foi possível validar/submeter a inscrição. Tenta novamente.") independentemente da causa real — email duplicado, evento cheio, rate limit, etc. O WhatsApp CTA escondia o motivo real.

**Causa raiz**: a Server Action fazia `throw new Error('Não foi possível validar a inscrição. Tenta novamente.')` em **todos** os caminhos de erro da Edge Function, perdendo o `error: "..."` descritivo que a Edge Function devolvia. Resultado: 8+ cenários de erro colapsavam no mesmo texto genérico no client.

**Solução em 3 commits** (não 1):

1. **Telemetria**: `logInscriptionError(code, ctx)` no topo da Server Action. Cada throw regista `[inscription.submit]` com `code` + `emailHash` (não PII) + `eventoId/slug` + `ts` em Vercel logs. Helper `hashEmail()` é djb2 truncated 8-char hex. **Sem mudança de UX** — só diagnóstico.

2. **i18n mapping no client**: adicionar `${feature}_error.codes` em `public/i18n/{pt,en}.json` com chaves correspondentes aos códigos. Refactor do `catch` no Client Component para `JSON.parse(err.message)` e `t('${feature}_error.codes.${code}')` com fallback.

3. **Server Action emite JSON estruturado**: `throwCode(code, detail)` helper que faz `throw new Error(JSON.stringify({ code, detail: detail || null }))`. Migrar **todos** os throws excepto legacy `'duplicate'` string (preservar para backward-compat com clients que ainda não parseiam).

**Porquê 3 commits, não 1**: Commit 1 (telemetria) confirma em prod quais categorias realmente ocorrem antes de assumir o mapping i18n. Commit 2 detecta "dead code" no client parse (`t('...codes.${code}')` nunca alcançado porque Server Action emitia strings genéricas) → Commit 3 fecha o gap. **Sempre** verificar com verification subagent que a cadeia completa está ligada — caso contrário o i18n mapping fica como código morto.

**Cadeia verificada** (2x PASS do verification subagent):
```
Server Action → throwCode(code, detail) → Error(JSON.stringify({code,detail}))
  → err.message → client JSON.parse → code
  → t('inscricao_error.codes.${code}') → string PT/EN
```

**Aplicar quando**: criar nova Server Action pública (newsletter, contacto, wizard) com PII ou input validado. 11 códigos no caso da inscrição: `event_not_found, event_full, duplicate, rate_limited, validation_failed, validation_unreachable, db_insert_error, db_insert_no_id, invalid_event_id, invalid_event_slug, misconfigured`.

**Exemplo canónico**: `lib/actions/inscription.js:53-72` (helpers) + `:123-265` (apiSubmitInscription instrumentada) + `components/pages/InscricaoPageClient.jsx:111-145` (catch refactorizado) + `public/i18n/{pt,en}.json` (bloco `inscricao_error.codes`).

**PII safety**: `hashEmail()` retorna 8-char hex djb2 truncated. **Nunca** passar `form.nome` ou `form.email` raw para logs — só `emailHash`. Mesmo com hashes, considerar se o slug do evento + emailHash é correlacionável (pode revelar inscrição de pessoa específica num evento raro) — manter logs agregados quando possível.

**Status 409 com semântica dupla**: a Edge Function `validate-inscription` devolve 409 para **dois** cenários distintos — `event_full` (vagas esgotadas) e `duplicate` (email já registado). Distinguir no Server Action por inspecção da string `validation.error` (procura "já está registado" / "already"). Não confiar no status code sozinho.

### 62. RLS: UPDATE de Sessão de Outrem é Silenciosamente Filtrado (competition_sessions)

**Problema (bug real, 2026-08-24)**: no fluxo `/competicao/amigos`, apenas o criador entrava no jogo — o **convidado ficava preso no lobby** para sempre. O criador iniciava o quiz, a competição ia para `active`, mas o convidado nunca lia as perguntas.

**Causa raiz**: `startFriendQuiz()` (server action, corre no **contexto auth do criador**) grava `questions` + `started_at` na linha `competition_sessions` de **todos** os jogadores e depois muda a competição para `active`. As únicas policies de UPDATE em `competition_sessions` eram:
- `own_session_update` (`user_id = auth.uid()`) — migração 234
- `anon_session_update` (anon) — migração 234
- `admin_all_sessions` (admin) — migração 234

O criador **não é** o `user_id` da linha do convidado, logo o UPDATE na sessão do convidado era **silenciosamente filtrado pelo RLS** (0 linhas afetadas, sem erro lançado). Resultado:
- sessão do criador: `questions` preenchidos → criador entra no quiz
- sessão do convidado: `questions` continua `'[]'` → o polling do lobby do convidado nunca encontra `session.questions` → fica preso no lobby

**Lição 1 — RLS filtra silenciosamente**: um `UPDATE` (ou `DELETE`) bloqueado por RLS **não dá erro** no supabase-js — devolve 0 linhas afetadas. O código que não verifica `error` nem o número de linhas afetadas assume falsamente sucesso. Sempre verificar `error` **e** o resultado em operações de escrita por outro user.

**Lição 2 — Server action que atualiza dados de outro user precisa de policy própria**: se uma ação roda no contexto do user A mas escreve na linha pertencente ao user B, há de existir uma policy que o autoriza (ex.: o criador da competição). Fix (migração `246_fix_friend_session_update_by_creator.sql`):

```sql
CREATE POLICY friend_update_sessions_by_creator ON public.competition_sessions
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.competitions comp
      WHERE comp.id = competition_sessions.competition_id
        AND comp.is_friend_challenge = true
        AND comp.created_by_user_id = auth.uid()
    )
  )
  WITH CHECK ( /* idêntico ao USING */ );
```

**Lição 3 — evitar recursão RLS**: policies de `competition_sessions` que consultam `competitions`, e policies de `competitions` que consultam `competition_sessions`, saturam (recursão infinita, migração 242). A policy acima consulta `competitions` de forma unilateral (sem loop) — sem problema. Manter a dependência num só sentido.

**Pré-existente (não alterado)**: a policy `anon_read_sessions` (234) tem `USING (true)` para `authenticated`, o que na prática permite a qualquer user autenticado ler todas as sessões (lobby/leaderboard da mesma competição funcionam). Não foi o bloqueio do fluxo, mas é uma leitura ampla que num futuro hardening deve ser restringida.
