# Fase 5 — Performance, SEO & Analytics: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminar inconsistências de analytics, melhorar UX de carregamento e consolidar SEO no site Next.js.

**Architecture:** 3 sub-fases sequenciais: Analytics (Server Actions + dedup), Performance (loading/error + Image optimization), SEO (sitemap/robots dinâmicos + schemas).

**Tech Stack:** Next.js App Router, React 19, Supabase SSR, Tailwind v4

---

## Sub-fase 5.1: Analytics & Integridade de Dados

### Task 1: Converter lib/api/analytics.js para Server Actions

**Files:**
- Modify: `lib/api/analytics.js`

- [ ] **Step 1: Substituir 'use client' por 'use server' e import do servidor**

Substituir o conteúdo do ficheiro por:

```js
'use server'

import { createClient } from '@/lib/supabase/server'

export async function incrementViewCount(articleSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_view_count', { article_slug: articleSlug })
}

export async function incrementShareCount(articleId) {
  const supabase = await createClient()
  await supabase.rpc('increment_share_count', { row_id: articleId })
}

export async function addReadingTime(articleId, seconds) {
  const supabase = await createClient()
  await supabase.rpc('add_reading_time', { row_id: articleId, seconds })
}

export async function incrementEventViewCount(eventSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_event_view_count', { event_slug: eventSlug })
}

export async function incrementLiveViewCount(liveSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_live_view_count', { live_slug: liveSlug })
}

export async function incrementLiveAccessCount(liveSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_live_access_count', { live_slug: liveSlug })
}

export async function incrementLiveDownloadCount(liveSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_live_download_count', { live_slug: liveSlug })
}

export async function trackPageView(path, referrer, sessionId) {
  const supabase = await createClient()
  await supabase.from('page_views').insert({
    page_path: path,
    referrer: referrer || null,
    session_id: sessionId,
  })
}
```

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

Esperado: sucesso.

- [ ] **Step 3: Commit**

```bash
git add lib/api/analytics.js
git commit -m "feat(5.1): convert analytics API to server actions + add trackPageView"
```

---

### Task 2: Criar lib/analytics-dedup.js

**Files:**
- Create: `lib/analytics-dedup.js`

- [ ] **Step 1: Criar ficheiro com helpers de deduplicação**

```js
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

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add lib/analytics-dedup.js
git commit -m "feat(5.1): add analytics dedup helpers (localStorage TTL 24h)"
```

---

### Task 3: Criar PageViewTracker component

**Files:**
- Create: `components/content/PageViewTracker.jsx`

- [ ] **Step 1: Criar componente com Suspense wrapper**

```jsx
'use client'

import { useEffect, Suspense } from 'react'
import { usePathname, useSearchParams } from 'next/navigation'
import { trackPageView } from '@/lib/api/analytics'

function getSessionId() {
  try {
    let sid = sessionStorage.getItem('_pv_session_id')
    if (!sid) {
      sid = crypto.randomUUID()
      sessionStorage.setItem('_pv_session_id', sid)
    }
    return sid
  } catch { return crypto.randomUUID() }
}

function PageViewTrackerInner() {
  const pathname = usePathname()
  const searchParams = useSearchParams()

  useEffect(() => {
    if (pathname.startsWith('/admin') || pathname.startsWith('/_next') || pathname.startsWith('/api')) return

    const key = `_pv_${pathname}`
    if (sessionStorage.getItem(key)) return
    sessionStorage.setItem(key, '1')

    const url = pathname + (searchParams.toString() ? `?${searchParams}` : '')
    trackPageView(url, null, document.referrer).catch(() => {})
  }, [pathname, searchParams])

  return null
}

export default function PageViewTracker() {
  return (
    <Suspense fallback={null}>
      <PageViewTrackerInner />
    </Suspense>
  )
}
```

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add components/content/PageViewTracker.jsx
git commit -m "feat(5.1): create PageViewTracker with Suspense + sessionStorage dedup"
```

---

### Task 4: Integrar PageViewTracker no layout + metadataBase

**Files:**
- Modify: `app/layout.js`

- [ ] **Step 1: Ler o ficheiro atual**

Ler `app/layout.js` para ver a estrutura existente.

- [ ] **Step 2: Adicionar imports, metadataBase e PageViewTracker**

Adicionar import:
```js
import { Suspense } from 'react'
import PageViewTracker from '@/components/content/PageViewTracker'
```

Adicionar `metadataBase` ao objeto `metadata` existente:
```js
metadataBase: new URL('https://conhecafarmacia.netlify.app'),
```

Adicionar dentro do `<body>`, antes de `{children}`:
```jsx
<Suspense fallback={null}>
  <PageViewTracker />
</Suspense>
```

- [ ] **Step 3: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 4: Commit**

```bash
git add app/layout.js
git commit -m "feat(5.1+5.3): integrate PageViewTracker + add metadataBase to root layout"
```

---

### Task 5: Reescrever ViewCountTracker com dedup

**Files:**
- Modify: `components/content/ViewCountTracker.jsx`

- [ ] **Step 1: Substituir conteúdo**

```jsx
'use client'

import { useEffect } from 'react'
import { incrementViewCount } from '@/lib/api/analytics'
import { hasTracked, markTracked } from '@/lib/analytics-dedup'

export default function ViewCountTracker({ articleSlug }) {
  useEffect(() => {
    if (!articleSlug) return
    const key = `cf_view_article_${articleSlug}`
    if (hasTracked(key)) return
    incrementViewCount(articleSlug).then(() => markTracked(key)).catch(() => {})
  }, [articleSlug])

  return null
}
```

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add components/content/ViewCountTracker.jsx
git commit -m "feat(5.1): rewrite ViewCountTracker with centralized API + 24h dedup"
```

---

### Task 6: Reescrever EventViewTracker com dedup

**Files:**
- Modify: `components/content/EventViewTracker.jsx`

- [ ] **Step 1: Substituir conteúdo**

```jsx
'use client'

import { useEffect } from 'react'
import { incrementEventViewCount } from '@/lib/api/analytics'
import { hasTracked, markTracked } from '@/lib/analytics-dedup'

export default function EventViewTracker({ eventSlug }) {
  useEffect(() => {
    if (!eventSlug) return
    const key = `cf_view_event_${eventSlug}`
    if (hasTracked(key)) return
    incrementEventViewCount(eventSlug).then(() => markTracked(key)).catch(() => {})
  }, [eventSlug])

  return null
}
```

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add components/content/EventViewTracker.jsx
git commit -m "feat(5.1): rewrite EventViewTracker with centralized API + 24h dedup"
```

---

### Task 7: Reescrever LiveViewTracker com dedup

**Files:**
- Modify: `components/content/LiveViewTracker.jsx`

- [ ] **Step 1: Substituir conteúdo**

```jsx
'use client'

import { useEffect } from 'react'
import { incrementLiveViewCount } from '@/lib/api/analytics'
import { hasTracked, markTracked } from '@/lib/analytics-dedup'

export default function LiveViewTracker({ liveSlug }) {
  useEffect(() => {
    if (!liveSlug) return
    const key = `cf_view_live_${liveSlug}`
    if (hasTracked(key)) return
    incrementLiveViewCount(liveSlug).then(() => markTracked(key)).catch(() => {})
  }, [liveSlug])

  return null
}
```

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add components/content/LiveViewTracker.jsx
git commit -m "feat(5.1): rewrite LiveViewTracker with centralized API + 24h dedup"
```

---

### Task 8: Centralizar ReadingTimeTracker, LiveAccessButton, MaterialLink

**Files:**
- Modify: `components/content/ReadingTimeTracker.jsx`
- Modify: `components/content/LiveAccessButton.jsx`
- Modify: `components/content/MaterialLink.jsx`

- [ ] **Step 1: ReadingTimeTracker — substituir import**

Ler o ficheiro e substituir:
- `import { createClient } from '@/lib/supabase/client'` → `import { addReadingTime } from '@/lib/api/analytics'`
- Remover `const supabase = createClient()` e `supabase.rpc('add_reading_time', ...)` → `addReadingTime(articleId, 30).catch(() => {})`

- [ ] **Step 2: LiveAccessButton — substituir import**

Ler o ficheiro e substituir o import dinâmico de `createClient` por import estático de `incrementLiveAccessCount` de `lib/api/analytics`.

- [ ] **Step 3: MaterialLink — substituir import**

Ler o ficheiro e substituir o import dinâmico de `createClient` por import estático de `incrementLiveDownloadCount` de `lib/api/analytics`.

- [ ] **Step 4: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 5: Commit**

```bash
git add components/content/ReadingTimeTracker.jsx components/content/LiveAccessButton.jsx components/content/MaterialLink.jsx
git commit -m "feat(5.1): centralize ReadingTimeTracker, LiveAccessButton, MaterialLink to analytics API"
```

---

### Task 9: Eliminar código morto

**Files:**
- Delete: `components/content/ArticleAnalytics.jsx`
- Delete: `components/content/EventAnalytics.jsx`
- Delete: `components/content/LiveAnalytics.jsx`
- Delete: `hooks/useAnalytics.js`

- [ ] **Step 1: Verificar que não há imports ativos**

```bash
grep -r "ArticleAnalytics\|EventAnalytics\|LiveAnalytics\|useAnalytics" --include="*.js" --include="*.jsx" app/ components/ lib/ hooks/
```

Esperado: apenas os próprios ficheiros ou nenhum resultado.

- [ ] **Step 2: Eliminar ficheiros**

```bash
rm components/content/ArticleAnalytics.jsx components/content/EventAnalytics.jsx components/content/LiveAnalytics.jsx hooks/useAnalytics.js
```

- [ ] **Step 3: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 4: Commit**

```bash
git add -u
git commit -m "chore(5.1): remove unused analytics components and hooks"
```

---

## Sub-fase 5.2: Performance & UX Estrutural

### Task 10: Criar loading.jsx para artigos (listagem)

**Files:**
- Create: `app/[lang]/(public)/artigos/loading.jsx`

- [ ] **Step 1: Criar skeleton**

```jsx
export default function Loading() {
  return (
    <div className="min-h-screen">
      <section className="bg-brand-deep text-white py-16">
        <div className="container-center max-w-7xl mx-auto px-4 text-center">
          <div className="h-10 w-64 mx-auto bg-white/20 rounded animate-pulse mb-4" />
          <div className="h-5 w-96 mx-auto bg-white/10 rounded animate-pulse" />
        </div>
      </section>
      <section className="container-center max-w-7xl mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="article-card animate-pulse">
              <div className="bg-gray-200 dark:bg-gray-700 h-48 rounded-t-lg" />
              <div className="p-4 space-y-3">
                <div className="h-4 w-20 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-5 w-3/4 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded" />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
```

- [ ] **Step 2: Commit**

```bash
git add app/[lang]/\(public\)/artigos/loading.jsx
git commit -m "feat(5.2): add loading skeleton for artigos list page"
```

---

### Task 11: Criar loading.jsx para artigos (detail)

**Files:**
- Create: `app/[lang]/(public)/artigos/[slug]/loading.jsx`

- [ ] **Step 1: Criar skeleton**

```jsx
export default function Loading() {
  return (
    <div className="min-h-screen">
      <div className="max-w-4xl mx-auto px-4 py-12 animate-pulse">
        <div className="h-4 w-32 bg-gray-200 dark:bg-gray-700 rounded mb-6" />
        <div className="h-8 w-3/4 bg-gray-200 dark:bg-gray-700 rounded mb-4" />
        <div className="h-4 w-48 bg-gray-200 dark:bg-gray-700 rounded mb-8" />
        <div className="h-64 w-full bg-gray-200 dark:bg-gray-700 rounded-lg mb-8" />
        <div className="space-y-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="h-4 bg-gray-200 dark:bg-gray-700 rounded" style={{ width: `${85 - i * 5}%` }} />
          ))}
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: Commit**

```bash
git add "app/[lang]/(public)/artigos/[slug]/loading.jsx"
git commit -m "feat(5.2): add loading skeleton for artigo detail page"
```

---

### Task 12: Criar loading.jsx para eventos (listagem + detail)

**Files:**
- Create: `app/[lang]/(public)/eventos/loading.jsx`
- Create: `app/[lang]/(public)/eventos/[slug]/loading.jsx`

- [ ] **Step 1: Criar skeleton listagem (2 colunas)**

```jsx
export default function Loading() {
  return (
    <div className="min-h-screen">
      <section className="bg-brand-deep text-white py-16">
        <div className="container-center max-w-7xl mx-auto px-4 text-center">
          <div className="h-10 w-64 mx-auto bg-white/20 rounded animate-pulse mb-4" />
          <div className="h-5 w-96 mx-auto bg-white/10 rounded animate-pulse" />
        </div>
      </section>
      <section className="container-center max-w-7xl mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="event-card animate-pulse">
              <div className="bg-gray-200 dark:bg-gray-700 h-48 rounded-t-lg" />
              <div className="p-4 space-y-3">
                <div className="h-4 w-24 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-5 w-3/4 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded" />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
```

- [ ] **Step 2: Criar skeleton detail**

```jsx
export default function Loading() {
  return (
    <div className="min-h-screen animate-pulse">
      <div className="h-64 w-full bg-gray-200 dark:bg-gray-700" />
      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="h-4 w-32 bg-gray-200 dark:bg-gray-700 rounded mb-6" />
        <div className="h-8 w-3/4 bg-gray-200 dark:bg-gray-700 rounded mb-4" />
        <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded mb-2" />
        <div className="h-4 w-5/6 bg-gray-200 dark:bg-gray-700 rounded mb-8" />
        <div className="h-10 w-48 bg-gray-200 dark:bg-gray-700 rounded" />
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Commit**

```bash
git add app/[lang]/\(public\)/eventos/loading.jsx "app/[lang]/(public)/eventos/[slug]/loading.jsx"
git commit -m "feat(5.2): add loading skeletons for eventos list + detail"
```

---

### Task 13: Criar loading.jsx para lives (listagem + detail)

**Files:**
- Create: `app/[lang]/(public)/lives/loading.jsx`
- Create: `app/[lang]/(public)/lives/[slug]/loading.jsx`

- [ ] **Step 1: Criar skeleton listagem**

```jsx
export default function Loading() {
  return (
    <div className="min-h-screen">
      <section className="bg-brand-deep text-white py-16">
        <div className="container-center max-w-7xl mx-auto px-4 text-center">
          <div className="h-10 w-64 mx-auto bg-white/20 rounded animate-pulse mb-4" />
          <div className="h-5 w-96 mx-auto bg-white/10 rounded animate-pulse" />
        </div>
      </section>
      <section className="container-center max-w-7xl mx-auto px-4 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="event-card animate-pulse">
              <div className="bg-gray-200 dark:bg-gray-700 h-48 rounded-t-lg" />
              <div className="p-4 space-y-3">
                <div className="h-4 w-24 bg-gray-200 dark:bg-gray-700 rounded" />
                <div className="h-5 w-3/4 bg-gray-200 dark:bg-gray-700 rounded" />
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
```

- [ ] **Step 2: Criar skeleton detail**

```jsx
export default function Loading() {
  return (
    <div className="min-h-screen animate-pulse">
      <div className="h-64 w-full bg-gray-200 dark:bg-gray-700" />
      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="h-4 w-32 bg-gray-200 dark:bg-gray-700 rounded mb-6" />
        <div className="h-8 w-3/4 bg-gray-200 dark:bg-gray-700 rounded mb-4" />
        <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded mb-2" />
        <div className="h-4 w-5/6 bg-gray-200 dark:bg-gray-700 rounded mb-8" />
        <div className="h-12 w-full bg-gray-200 dark:bg-gray-700 rounded-lg" />
      </div>
    </div>
  )
}
```

- [ ] **Step 3: Commit**

```bash
git add app/[lang]/\(public\)/lives/loading.jsx "app/[lang]/(public)/lives/[slug]/loading.jsx"
git commit -m "feat(5.2): add loading skeletons for lives list + detail"
```

---

### Task 14: Criar error.jsx para secções públicas

**Files:**
- Create: `app/[lang]/(public)/error.jsx`
- Create: `app/[lang]/(public)/artigos/error.jsx`
- Create: `app/[lang]/(public)/eventos/error.jsx`
- Create: `app/[lang]/(public)/lives/error.jsx`

- [ ] **Step 1: Criar error.jsx público (reutilizado)**

```jsx
'use client'

export default function Error({ error, reset }) {
  return (
    <div className="min-h-[60vh] flex items-center justify-center px-4">
      <div className="text-center max-w-md">
        <h2 className="font-display text-2xl font-bold text-brand-deep mb-4">
          Algo correu mal
        </h2>
        <p className="text-gray-500 dark:text-gray-400 mb-8">
          De momento não foi possível carregar esta página. Tente novamente.
        </p>
        <button onClick={reset} className="btn btn-primary">
          Tentar novamente
        </button>
      </div>
    </div>
  )
}
```

Repetir o mesmo conteúdo para os 3 error.jsx de secção (artigos, eventos, lives).

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add app/[lang]/\(public\)/error.jsx app/[lang]/\(public\)/artigos/error.jsx app/[lang]/\(public\)/eventos/error.jsx app/[lang]/\(public\)/lives/error.jsx
git commit -m "feat(5.2): add error boundaries for all public route sections"
```

---

### Task 15: Adicionar priority={true} nas hero images

**Files:**
- Modify: `app/[lang]/(public)/artigos/[slug]/page.js`
- Modify: `app/[lang]/(public)/eventos/[slug]/page.js`
- Modify: `app/[lang]/(public)/lives/[slug]/page.js`

- [ ] **Step 1: Artigo detail — adicionar priority**

Ler o ficheiro, encontrar o `<Image>` do hero e adicionar `priority={true}`.

- [ ] **Step 2: Evento detail — adicionar priority**

Ler o ficheiro, encontrar o `<Image>` do hero e adicionar `priority={true}`.

- [ ] **Step 3: Live detail — adicionar priority**

Ler o ficheiro, encontrar o `<Image>` do hero e adicionar `priority={true}`.

- [ ] **Step 4: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 5: Commit**

```bash
git add app/[lang]/\(public\)/artigos/\[slug\]/page.js app/[lang]/\(public\)/eventos/\[slug\]/page.js app/[lang]/\(public\)/lives/\[slug\]/page.js
git commit -m "feat(5.2): add priority loading to hero images for LCP optimization"
```

---

### Task 16: Restringir remotePatterns em next.config.mjs

**Files:**
- Modify: `next.config.mjs`

- [ ] **Step 1: Ler e atualizar**

Ler o ficheiro atual. Substituir o bloco `images` por:

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

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add next.config.mjs
git commit -m "feat(5.2): restrict image remotePatterns to Supabase Storage"
```

---

### Task 17: Injetar lazy loading em imagens de markdown

**Files:**
- Modify: `components/content/ArticleContent.jsx`

- [ ] **Step 1: Ler e adicionar hook DOMPurify**

Ler o ficheiro. No hook `afterSanitizeAttributes` existente (ou adicionar um), garantir que todas as `<img>` recebem `loading="lazy"`:

```js
DOMPurify.addHook('afterSanitizeAttributes', (node) => {
  if (node.tagName === 'IMG') {
    node.setAttribute('loading', 'lazy')
  }
  // ... restrições existentes de src
})
```

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add components/content/ArticleContent.jsx
git commit -m "feat(5.2): inject lazy loading on markdown images via DOMPurify hook"
```

---

## Sub-fase 5.3: SEO Dinâmico e Autoridade

### Task 18: Criar app/sitemap.js dinâmico

**Files:**
- Create: `app/sitemap.js`

- [ ] **Step 1: Criar ficheiro**

```js
import { getArticles } from '@/lib/api/articles'
import { getEvents } from '@/lib/api/events'
import { getLives } from '@/lib/api/lives'

export const revalidate = 43200

const SITE_URL = 'https://conhecafarmacia.netlify.app'
const LOCALES = ['pt', 'en']

export default async function sitemap() {
  const staticPaths = ['', '/artigos', '/eventos', '/lives', '/sobre', '/pesquisa']
  const staticEntries = staticPaths.flatMap(path =>
    LOCALES.map(lang => ({
      url: `${SITE_URL}/${lang}${path}`,
      changeFrequency: path === '' ? 'daily' : 'weekly',
      priority: path === '' ? 1.0 : 0.8,
      alternates: { languages: Object.fromEntries(LOCALES.map(l => [l, `${SITE_URL}/${l}${path}`])) },
    }))
  )

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

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add app/sitemap.js
git commit -m "feat(5.3): create dynamic sitemap with i18n + ISR 12h cache"
```

---

### Task 19: Criar app/robots.js dinâmico

**Files:**
- Create: `app/robots.js`

- [ ] **Step 1: Criar ficheiro**

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

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add app/robots.js
git commit -m "feat(5.3): create dynamic robots.txt disallowing admin routes"
```

---

### Task 20: Adicionar hreflang a todos os detail pages

**Files:**
- Modify: `app/[lang]/(public)/artigos/[slug]/page.js`
- Modify: `app/[lang]/(public)/eventos/[slug]/page.js`
- Modify: `app/[lang]/(public)/lives/[slug]/page.js`

- [ ] **Step 1: Artigos — adicionar alternates.languages**

No `generateMetadata`, adicionar ao objeto retornado:
```js
alternates: {
  canonical: `${SITE_URL}/${safeLang}/artigos/${article.slug}`,
  languages: { 'pt': `/pt/artigos/${article.slug}`, 'en': `/en/artigos/${article.slug}` },
},
```

- [ ] **Step 2: Eventos — adicionar alternates.languages + corrigir OG type + Twitter**

No `generateMetadata`:
```js
alternates: {
  canonical: `${SITE_URL}/${safeLang}/eventos/${event.slug}`,
  languages: { 'pt': `/pt/eventos/${event.slug}`, 'en': `/en/eventos/${event.slug}` },
},
openGraph: {
  ...existing,
  type: 'event', // corrigir de 'website'
},
twitter: {
  card: 'summary_large_image',
  title: event.title,
  description: event.excerpt,
  images: event.image ? [event.image] : [],
},
```

- [ ] **Step 3: Lives — adicionar canonical + hreflang + OG url + Twitter**

No `generateMetadata`:
```js
alternates: {
  canonical: `${SITE_URL}/${safeLang}/lives/${live.slug}`,
  languages: { 'pt': `/pt/lives/${live.slug}`, 'en': `/en/lives/${live.slug}` },
},
openGraph: {
  ...existing,
  url: `${SITE_URL}/${safeLang}/lives/${live.slug}`,
},
twitter: {
  card: 'summary_large_image',
  title: live.titulo,
  description: live.resumo,
  images: live.imagem ? [live.imagem] : [],
},
```

- [ ] **Step 4: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 5: Commit**

```bash
git add app/[lang]/\(public\)/artigos/\[slug\]/page.js app/[lang]/\(public\)/eventos/\[slug\]/page.js app/[lang]/\(public\)/lives/\[slug\]/page.js
git commit -m "feat(5.3): add hreflang + fix OG/Twitter metadata on all detail pages"
```

---

### Task 21: Adicionar BreadcrumbList JSON-LD ao lives detail

**Files:**
- Modify: `app/[lang]/(public)/lives/[slug]/page.js`

- [ ] **Step 1: Adicionar import e JSON-LD**

Adicionar import de `buildBreadcrumbSchema` (já existe no artigo/evento detail):
```js
import { buildBreadcrumbSchema, buildLiveSchema } from '@/lib/seo'
```

Adicionar o script JSON-LD após o existente do `buildLiveSchema`:
```jsx
<script
  type="application/ld+json"
  dangerouslySetInnerHTML={{
    __html: JSON.stringify(buildBreadcrumbSchema([
      { name: t('nav.home'), item: `/${lang}` },
      { name: t('nav.lives'), item: `/${lang}/lives` },
      { name: live.titulo },
    ], `${SITE_URL}/${safeLang}/lives/${live.slug}`))
  }}
/>
```

- [ ] **Step 2: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 3: Commit**

```bash
git add app/[lang]/\(public\)/lives/\[slug\]/page.js
git commit -m "feat(5.3): add BreadcrumbList JSON-LD to lives detail page"
```

---

### Task 22: Adicionar WebSite/Organization schema à homepage

**Files:**
- Modify: `lib/seo.js`
- Modify: `app/[lang]/(public)/page.js`

- [ ] **Step 1: Adicionar funções a lib/seo.js**

Ler o ficheiro e adicionar no final:

```js
export function buildOrganizationSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'Conheça Farmácia',
    url: 'https://conhecafarmacia.netlify.app',
    logo: 'https://conhecafarmacia.netlify.app/logo/3.png',
  }
}

export function buildWebSiteSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: 'Conheça Farmácia',
    url: 'https://conhecafarmacia.netlify.app',
    potentialAction: {
      '@type': 'SearchAction',
      target: 'https://conhecafarmacia.netlify.app/pt/pesquisa?q={search_term_string}',
      'query-input': 'required name=search_term_string',
    },
  }
}
```

- [ ] **Step 2: Adicionar JSON-LD à homepage**

Ler `app/[lang]/(public)/page.js` e adicionar import:
```js
import { buildOrganizationSchema, buildWebSiteSchema } from '@/lib/seo'
```

Adicionar antes do return:
```jsx
const orgSchema = buildOrganizationSchema()
const siteSchema = buildWebSiteSchema()
```

Adicionar dentro do JSX (antes do conteúdo):
```jsx
<script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(orgSchema) }} />
<script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(siteSchema) }} />
```

- [ ] **Step 3: Verificar build**

```bash
npm run build:next 2>&1 | tail -20
```

- [ ] **Step 4: Commit**

```bash
git add lib/seo.js app/[lang]/\(public\)/page.js
git commit -m "feat(5.3): add Organization + WebSite JSON-LD schema to homepage"
```

---

## Final Verification

### Task 23: Build final + verificação

- [ ] **Step 1: Build completa**

```bash
npm run build:next
```

Esperado: sucesso, todas as rotas geradas.

- [ ] **Step 2: Verificar que não há imports quebrados**

```bash
grep -r "ArticleAnalytics\|EventAnalytics\|LiveAnalytics\|useAnalytics" --include="*.js" --include="*.jsx" app/ components/ lib/ hooks/
```

Esperado: nenhum resultado.

- [ ] **Step 3: Verificar que sitemap.js e robots.js existem**

```bash
ls app/sitemap.js app/robots.js
```

- [ ] **Step 4: Commit final se necessário**

```bash
git add -A && git commit -m "chore(5): final verification and cleanup"
```
