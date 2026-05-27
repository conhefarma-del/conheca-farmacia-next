# Spec: Fase 5 — Performance, SEO & Analytics

**Data:** 2026-05-27
**Estado:** Aprovado para implementação
**Fases anteriores:** 0-4 completas (Next.js 16.2.6, React 19, Supabase SSR)

---

## 1. Visão Geral

A Fase 5 foca-se em três pilares que transformam o site Next.js funcional (Fases 0-4) numa aplicação de produção otimizada:

| Sub-fase | Prioridade | Foco |
|----------|-----------|------|
| 5.1 Analytics & Integridade de Dados | Máxima | Eliminar RPCs diretas, deduplicação, tracking global |
| 5.2 Performance & UX Estrutural | Alta | Loading skeletons, error boundaries, Image optimization |
| 5.3 SEO Dinâmico e Autoridade | Alta | Sitemap, robots, metadata, schemas, hreflang |

---

## 2. Sub-fase 5.1 — Analytics & Integridade de Dados

### 2.1 Problemas Atuais

1. **3 camadas de tracking duplicadas**: ViewCountTracker/EventViewTracker/LiveViewTracker chamam RPC diretamente; hooks useAnalytics usam lib/api/analytics.js mas não são usados; LiveAccessButton/MaterialLink chamam RPC inline.
2. **Zero deduplicação**: Cada refresh incrementa a contagem.
3. **page_views não migrado**: O tracking global do Vite não tem equivalente Next.js.

### 2.2 Centralização — lib/api/analytics.js como Server Action

**Ficheiro:** `lib/api/analytics.js`

Converter de `'use client'` para `'use server'`. Todas as funções usam `createClient()` do servidor.

**Funções existentes (manter):**
- `incrementViewCount(articleSlug)`
- `incrementShareCount(articleId)`
- `addReadingTime(articleId, seconds)`
- `incrementEventViewCount(eventSlug)`
- `incrementLiveViewCount(liveSlug)`
- `incrementLiveAccessCount(liveSlug)`
- `incrementLiveDownloadCount(liveSlug)`

**Função nova:**
- `trackPageView(path, referrer, sessionId)` — insere na tabela `page_views`

### 2.3 Deduplicação — Duas Estratégias

| Componente | Mecanismo | Chave | TTL | Justificação |
|-----------|-----------|-------|-----|--------------|
| PageViewTracker (global) | sessionStorage | `_pv_{pathname}` | Sessão de aba | F5 não deve contar como nova view |
| ViewCountTracker | localStorage | `cf_view_article_{slug}` | 24h | Unique Daily Users |
| EventViewTracker | localStorage | `cf_view_event_{slug}` | 24h | Unique Daily Users |
| LiveViewTracker | localStorage | `cf_view_live_{slug}` | 24h | Unique Daily Users |

**Função helper — `lib/analytics-dedup.js` (Client Module):**

NOTA: `localStorage` é API do browser — não pode estar em ficheiro `'use server'`. Os helpers de dedup ficam num módulo client-side separado que os trackers importam.

```js
// lib/analytics-dedup.js
'use client'

export function hasTracked(key) {
  try {
    const raw = localStorage.getItem(key)
    if (!raw) return false
    const { ts } = JSON.parse(raw)
    return Date.now() - ts < 86_400_000
  } catch { return false }
}

export function markTracked(key) {
  try {
    localStorage.setItem(key, JSON.stringify({ ts: Date.now() }))
  } catch {}
}
```

### 2.4 PageViewTracker — Componente Novo

**Ficheiro:** `components/content/PageViewTracker.jsx`

- Client Component com `usePathname()` e `useSearchParams()`
- Fire-and-forget para `trackPageView()` Server Action
- Envolvido em `<Suspense fallback={null}>` no Root Layout
- **NÃO inclui `document.title`** — Next.js atualiza metadados assincronamente; título pode ser da página anterior

**Integração em `app/layout.js`:**
```jsx
import { Suspense } from 'react'
import PageViewTracker from '@/components/content/PageViewTracker'

<body>
  <ThemeProvider>
    <Suspense fallback={null}>
      <PageViewTracker />
    </Suspense>
    {children}
  </ThemeProvider>
</body>
```

**Path filtering:** Ignorar caminhos que comecem por `/admin` ou `/_next` ou `/api`.

### 2.5 Refatoração de Trackers

| Componente | Antes | Depois |
|-----------|-------|--------|
| ViewCountTracker | RPC direto, sem dedup | `lib/api/analytics.js` + localStorage 24h |
| EventViewTracker | RPC direto, sem dedup | `lib/api/analytics.js` + localStorage 24h |
| LiveViewTracker | RPC direto, sem dedup | `lib/api/analytics.js` + localStorage 24h |
| ReadingTimeTracker | RPC direto | `lib/api/analytics.js` |
| LiveAccessButton | Import dinâmico createClient | `lib/api/analytics.js` |
| MaterialLink | Import dinâmico createClient | `lib/api/analytics.js` |

### 2.6 Eliminação de Código Morto

| Ficheiro | Razão |
|----------|-------|
| `components/content/ArticleAnalytics.jsx` | Nunca importado em nenhuma página |
| `components/content/EventAnalytics.jsx` | Nunca importado |
| `components/content/LiveAnalytics.jsx` | Nunca importado |
| `hooks/useAnalytics.js` | Hooks nunca usados (lógica movida para trackers) |

---

## 3. Sub-fase 5.2 — Performance & UX Estrutural

### 3.1 Loading States (Skeletons)

**Princípio:** Os skeletons devem replicar a estrutura exata das páginas reais (mesma largura de container, mesma tipografia, mesma grid) para mitigar CLS visual.

| Ficheiro | Estrutura do Skeleton |
|----------|----------------------|
| `app/[lang]/(public)/loading.jsx` | Hero + grid 3 cols (articles) + grid 2 cols (events/lives) |
| `app/[lang]/(public)/artigos/loading.jsx` | Hero + filtros + grid 3 cols article cards |
| `app/[lang]/(public)/artigos/[slug]/loading.jsx` | Hero image + parágrafos + sidebar |
| `app/[lang]/(public)/eventos/loading.jsx` | Hero + filtros + grid 2 cols event cards |
| `app/[lang]/(public)/eventos/[slug]/loading.jsx` | Hero image + detalhes evento + speakers |
| `app/[lang]/(public)/lives/loading.jsx` | Hero + filtros + grid 2 cols live cards |
| `app/[lang]/(public)/lives/[slug]/loading.jsx` | Hero image + quick access + materials |

**Padrão de skeleton (article card):**
```jsx
<div className="article-card animate-pulse">
  <div className="bg-gray-200 dark:bg-gray-700 h-48 rounded-t-lg" />
  <div className="article-card-content space-y-3">
    <div className="bg-gray-200 dark:bg-gray-700 h-5 w-20 rounded" />
    <div className="bg-gray-200 dark:bg-gray-700 h-6 w-3/4 rounded" />
    <div className="bg-gray-200 dark:bg-gray-700 h-4 w-full rounded" />
    <div className="bg-gray-200 dark:bg-gray-700 h-4 w-2/3 rounded" />
  </div>
</div>
```

**Padrão de skeleton (detail page):**
```jsx
<div className="max-w-4xl mx-auto animate-pulse">
  <div className="bg-gray-200 dark:bg-gray-700 h-64 w-full rounded-lg mb-8" />
  <div className="space-y-4">
    <div className="bg-gray-200 dark:bg-gray-700 h-8 w-3/4 rounded" />
    <div className="bg-gray-200 dark:bg-gray-700 h-4 w-full rounded" />
    <div className="bg-gray-200 dark:bg-gray-700 h-4 w-5/6 rounded" />
  </div>
</div>
```

### 3.2 Error Boundaries

| Ficheiro | Comportamento |
|----------|---------------|
| `app/[lang]/(public)/error.jsx` | Error boundary global público — Client Component com botão `reset()` |
| `app/[lang]/(public)/artigos/error.jsx` | Error boundary artigos |
| `app/[lang]/(public)/eventos/error.jsx` | Error boundary eventos |
| `app/[lang]/(public)/lives/error.jsx` | Error boundary lives |

**Regras:**
- Renderiza dentro do container de conteúdo (não captura Header/Footer)
- Mensagem amigável: "De momento não foi possível carregar a informação"
- Botão "Tentar novamente" que chama `reset()` do Next.js
- Deve ser `'use client'`

### 3.3 Otimização de Imagens

**Estado atual:** Cards (ArticleCard, EventCard, LiveCard) já usam `next/image`. Detail pages usam `Image` mas sem `priority` nas imagens hero.

**Alterações:**

| Ficheiro | Alteração |
|----------|-----------|
| `app/[lang]/(public)/artigos/[slug]/page.js` | Adicionar `priority={true}` ao hero `<Image>` |
| `app/[lang]/(public)/eventos/[slug]/page.js` | Adicionar `priority={true}` ao hero `<Image>` |
| `app/[lang]/(public)/lives/[slug]/page.js` | Adicionar `priority={true}` ao hero `<Image>` |
| `next.config.mjs` | Restringir `remotePatterns` com `pathname: '/storage/v1/object/public/**'` |
| `components/content/ArticleContent.jsx` | Injetar `loading="lazy"` em `<img>` do markdown via DOMPurify hook |

**next.config.mjs atualizado:**
```js
images: {
  remotePatterns: [
    {
      protocol: 'https',
      hostname: '*.supabase.co',
      pathname: '/storage/v1/object/public/**',
    },
  ],
},
```

---

## 4. Sub-fase 5.3 — SEO Dinâmico e Autoridade

### 4.1 metadataBase no Root Layout

**Ficheiro:** `app/layout.js`

```js
export const metadata = {
  metadataBase: new URL('https://conhecafarmacia.netlify.app'),
  title: 'Conheça Farmácia',
  description: 'Portal de saúde e farmácia',
}
```

### 4.2 Sitemap Dinâmico com i18n

**Ficheiro:** `app/sitemap.js`

**Regras de negócio:**
- `export const revalidate = 43200` (12 horas) — ISR para evitar queries repetitivas ao Supabase
- Cada caminho multiplicado por idioma (`/pt/...`, `/en/...`)
- `alternates.languages` por entrada para paridade hreflang
- Artigos, eventos e lives do Supabase com `lastmod` de `updated_at`
- Páginas `inscricao` e `unsubscribe` excluídas (têm `robots: noindex`)

```js
import { getArticles } from '@/lib/api/articles'
import { getEvents } from '@/lib/api/events'
import { getLives } from '@/lib/api/lives'

export const revalidate = 43200 // 12 horas

const SITE_URL = 'https://conhecafarmacia.netlify.app'
const LOCALES = ['pt', 'en']

export default async function sitemap() {
  // Páginas estáticas × idiomas
  const staticPaths = ['', '/artigos', '/eventos', '/lives', '/sobre', '/pesquisa']
  const staticEntries = staticPaths.flatMap(path =>
    LOCALES.map(lang => ({
      url: `${SITE_URL}/${lang}${path}`,
      changeFrequency: path === '' ? 'daily' : 'weekly',
      priority: path === '' ? 1.0 : 0.8,
      alternates: {
        languages: Object.fromEntries(LOCALES.map(l => [l, `${SITE_URL}/${l}${path}`])),
      },
    }))
  )

  // Conteúdo dinâmico × idiomas
  let articles = [], events = [], lives = []
  try { articles = await getArticles() } catch {}
  try { events = await getEvents() } catch {}
  try { lives = await getLives() } catch {}

  const articleEntries = articles.flatMap(article =>
    LOCALES.map(lang => ({
      url: `${SITE_URL}/${lang}/artigos/${article.slug}`,
      lastModified: article.updated_at || article.published_date,
      changeFrequency: 'monthly',
      priority: 0.6,
      alternates: { languages: Object.fromEntries(LOCALES.map(l => [l, `${SITE_URL}/${l}/artigos/${article.slug}`])) },
    }))
  )

  const eventEntries = events.flatMap(event =>
    LOCALES.map(lang => ({
      url: `${SITE_URL}/${lang}/eventos/${event.slug}`,
      lastModified: event.updated_at || event.date,
      changeFrequency: 'weekly',
      priority: 0.6,
      alternates: { languages: Object.fromEntries(LOCALES.map(l => [l, `${SITE_URL}/${l}/eventos/${event.slug}`])) },
    }))
  )

  const liveEntries = lives.flatMap(live =>
    LOCALES.map(lang => ({
      url: `${SITE_URL}/${lang}/lives/${live.slug}`,
      lastModified: live.updated_at || live.data || live.date,
      changeFrequency: 'monthly',
      priority: 0.5,
      alternates: { languages: Object.fromEntries(LOCALES.map(l => [l, `${SITE_URL}/${l}/lives/${live.slug}`])) },
    }))
  )

  return [...staticEntries, ...articleEntries, ...eventEntries, ...liveEntries]
}
```

### 4.3 Robots.txt Dinâmico

**Ficheiro:** `app/robots.js`

```js
export default function robots() {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/admin/', '/api/'],
      },
    ],
    sitemap: 'https://conhecafarmacia.netlify.app/sitemap.xml',
  }
}
```

### 4.4 Paridade de Schemas JSON-LD

**Funções novas em `lib/seo.js`:**
- `buildOrganizationSchema()` — Organization schema para homepage
- `buildWebSiteSchema()` — WebSite schema com SearchAction para homepage

**Alterações por página:**

| Página | Alteração |
|--------|-----------|
| Homepage (`page.js`) | Adicionar Organization + WebSite JSON-LD |
| Lives detail (`lives/[slug]/page.js`) | Adicionar BreadcrumbList JSON-LD (falta vs artigos/eventos) |
| Lives detail | Adicionar `alternates.canonical` (falta) |
| Lives detail | Adicionar `alternates.languages` hreflang (falta) |
| Lives detail | Adicionar `openGraph.url` (falta) |
| Lives detail | Adicionar Twitter card metadata (falta) |
| Eventos detail (`eventos/[slug]/page.js`) | Corrigir `openGraph.type` de `'website'` para `'event'` |
| Eventos detail | Adicionar Twitter card metadata (falta) |
| Eventos detail | Adicionar `alternates.languages` hreflang (falta) |
| Artigos detail (`artigos/[slug]/page.js`) | Adicionar `alternates.languages` hreflang (falta) |

---

## 5. Inventário de Ficheiros

### Ficheiros a CRIAR (15)

| # | Ficheiro | Sub-fase |
|---|----------|----------|
| 1 | `lib/analytics-dedup.js` | 5.1 |
| 2 | `components/content/PageViewTracker.jsx` | 5.1 |
| 3 | `app/[lang]/(public)/loading.jsx` | 5.2 |
| 4 | `app/[lang]/(public)/error.jsx` | 5.2 |
| 5 | `app/[lang]/(public)/artigos/loading.jsx` | 5.2 |
| 6 | `app/[lang]/(public)/artigos/[slug]/loading.jsx` | 5.2 |
| 7 | `app/[lang]/(public)/artigos/error.jsx` | 5.2 |
| 8 | `app/[lang]/(public)/eventos/loading.jsx` | 5.2 |
| 9 | `app/[lang]/(public)/eventos/[slug]/loading.jsx` | 5.2 |
| 10 | `app/[lang]/(public)/eventos/error.jsx` | 5.2 |
| 11 | `app/[lang]/(public)/lives/loading.jsx` | 5.2 |
| 12 | `app/[lang]/(public)/lives/[slug]/loading.jsx` | 5.2 |
| 13 | `app/[lang]/(public)/lives/error.jsx` | 5.2 |
| 14 | `app/sitemap.js` | 5.3 |
| 15 | `app/robots.js` | 5.3 |

### Ficheiros a MODIFICAR (15)

| # | Ficheiro | Sub-fase |
|---|----------|----------|
| 1 | `lib/api/analytics.js` | 5.1 |
| 2 | `app/layout.js` | 5.1 + 5.3 |
| 3 | `components/content/ViewCountTracker.jsx` | 5.1 |
| 4 | `components/content/EventViewTracker.jsx` | 5.1 |
| 5 | `components/content/LiveViewTracker.jsx` | 5.1 |
| 6 | `components/content/ReadingTimeTracker.jsx` | 5.1 |
| 7 | `components/content/LiveAccessButton.jsx` | 5.1 |
| 8 | `components/content/MaterialLink.jsx` | 5.1 |
| 9 | `app/[lang]/(public)/artigos/[slug]/page.js` | 5.2 + 5.3 |
| 10 | `app/[lang]/(public)/eventos/[slug]/page.js` | 5.2 + 5.3 |
| 11 | `app/[lang]/(public)/lives/[slug]/page.js` | 5.2 + 5.3 |
| 12 | `next.config.mjs` | 5.2 |
| 13 | `components/content/ArticleContent.jsx` | 5.2 |
| 14 | `app/[lang]/(public)/page.js` | 5.3 |
| 15 | `lib/seo.js` | 5.3 |

### Ficheiros a ELIMINAR (4)

| # | Ficheiro | Sub-fase |
|---|----------|----------|
| 1 | `components/content/ArticleAnalytics.jsx` | 5.1 |
| 2 | `components/content/EventAnalytics.jsx` | 5.1 |
| 3 | `components/content/LiveAnalytics.jsx` | 5.1 |
| 4 | `hooks/useAnalytics.js` | 5.1 |

**Total: 34 operações** (15 criar, 15 modificar, 4 eliminar)

---

## 6. Critérios de Aceitação

### 5.1 Analytics
- [ ] `lib/api/analytics.js` tem `'use server'` e usa `createClient()` do servidor
- [ ] `lib/analytics-dedup.js` existe com `'use client'`, `hasTracked()` e `markTracked()`
- [ ] Todas as 8 funções existem (7 existentes + `trackPageView`)
- [ ] `PageViewTracker` existe, usa `usePathname()` + `useSearchParams()`, envolto em `<Suspense>`
- [ ] ViewCountTracker, EventViewTracker, LiveViewTracker usam `lib/api/analytics.js` com localStorage 24h
- [ ] LiveAccessButton e MaterialLink usam `lib/api/analytics.js`
- [ ] ReadingTimeTracker usa `lib/api/analytics.js`
- [ ] 4 ficheiros mortos eliminados
- [ ] Refresh não incrementa contagem (localStorage)
- [ ] `npm run build:next` completa sem erros

### 5.2 Performance
- [ ] 7 `loading.jsx` criados com skeletons que replicam estrutura real
- [ ] 3 `error.jsx` criados com botão `reset()` funcional
- [ ] Hero `<Image>` tem `priority={true}` nas 3 detail pages
- [ ] `next.config.mjs` tem `pathname` restriction
- [ ] `ArticleContent.jsx` injeta `loading="lazy"` em `<img>` do markdown
- [ ] `npm run build:next` completa sem erros

### 5.3 SEO
- [ ] `metadataBase` definido no root layout
- [ ] `app/sitemap.js` dinâmico com i18n (pt/en), `alternates.languages`, `revalidate = 43200`
- [ ] `app/robots.js` existe e bloqueia `/admin/`
- [ ] Lives detail tem canonical + hreflang + BreadcrumbList JSON-LD
- [ ] Eventos detail tem OG type `'event'` + Twitter card + hreflang
- [ ] Artigos detail tem hreflang
- [ ] Homepage tem Organization + WebSite JSON-LD
- [ ] `npm run build:next` completa sem erros

---

## 7. Ordem de Execução

1. **5.1 Analytics** — Centralizar RPC, deduplicação, PageViewTracker, limpeza
2. **5.2 Performance** — Loading states, error boundaries, Image optimization
3. **5.3 SEO** — metadataBase, sitemap, robots, schemas, hreflang
