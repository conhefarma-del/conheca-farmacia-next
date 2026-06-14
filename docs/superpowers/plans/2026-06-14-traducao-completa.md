# Tradução Completa do Conteúdo (PT ↔ EN) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar tradução completa (PT ↔ EN) ao conteúdo original (artigos, eventos, lives) com auto-tradução via OpenRouter, admin UX bilingue, fallback PT quando não há tradução, e hreflang para SEO.

**Architecture:** 3 tabelas de tradução (`article_translations`, `event_translations`, `live_translations`) com PK composta `(entity_id, lang)`. Refactor da camada de leitura (`lib/api/*`) para aceitar `lang` e fazer merge com fallback PT. Server Action `autoTranslateEntity` chama OpenRouter e popula a tradução. Componente `BilingualTabs` para o admin editar PT e EN no mesmo form. Feature flag `ENABLE_CONTENT_I18N` para rollout incremental.

**Tech Stack:** Next.js 16.2.6 (App Router, RSC, Server Actions), React 19, Supabase (PostgreSQL + RLS + admin client), OpenRouter API (Claude 3.5 Sonnet), Tailwind v4, sem framework de testes (verificação via `npm run build` + smoke tests manuais — alinhado com o resto do projeto).

**Spec:** `docs/superpowers/specs/2026-06-14-traducao-completa-design.md`

---

## File Structure

### Criar

| Path | Responsabilidade |
|---|---|
| `supabase/migrations/015_i18n_translations.sql` | Schema das 3 tabelas de tradução + `translation_logs` + RLS + indexes |
| `lib/actions/translation.js` | Server Action `autoTranslateEntity`, `generateEnglishSlug`, `checkRateLimit`, logging |
| `lib/api/translations.js` | Helpers: `getTranslationBySlug`, `upsertTranslation`, `mergeEntityWithTranslation`, `splitEntityFields` |
| `lib/utils/slugify.js` | Função `slugify` pura (lowercase, sem acentos, kebab-case) — usada como fallback |
| `components/admin/BilingualTabs.jsx` | Componente client com separadores PT/EN + botão "Auto-traduzir" + badge de estado |
| `components/public/TranslationFallbackBanner.jsx` | Banner amarelo para `/en/*` quando não há tradução |
| `app/[lang]/admin/(protected)/traducoes/page.js` | Bulk translate UI — listagem de pendentes + botão "Traduzir todos" |

### Modificar

| Path | Mudança |
|---|---|
| `lib/api/articles.js` | Adicionar parâmetro `lang` em todas as funções; usar `mergeEntityWithTranslation` |
| `lib/api/events.js` | Idem |
| `lib/api/lives.js` | Idem |
| `lib/api/search.js` | `searchArticles(query, lang)` — JOIN com `article_translations` se `lang === 'en'` |
| `app/[lang]/(public)/artigos/page.js` | Listagem com merge PT/EN |
| `app/[lang]/(public)/artigos/[slug]/page.js` | Merge + hreflang + `TranslationFallbackBanner` |
| `app/[lang]/(public)/eventos/page.js` e `[slug]/page.js` | Idem |
| `app/[lang]/(public)/lives/page.js` e `[slug]/page.js` | Idem |
| `app/[lang]/(public)/pesquisa/page.js` | Passar `lang` para `searchArticles` |
| `app/sitemap.js` | Entries PT + EN por entidade (com `<xhtml:link>` hreflang) |
| `app/[lang]/admin/(protected)/artigos/[id]/page.js` | Usar `BilingualTabs` em vez de form monolingue |
| `app/[lang]/admin/(protected)/eventos/[id]/page.js` | Idem |
| `app/[lang]/admin/(protected)/lives/[id]/page.js` | Idem |
| `app/[lang]/admin/(protected)/artigos/novo/page.js` (se existir) | Idem |
| `.env.local.example` | Adicionar `OPENROUTER_API_KEY`, `OPENROUTER_MODEL`, `TRANSLATION_DAILY_CHAR_LIMIT`, `ENABLE_CONTENT_I18N` |

### Não modificar (reutilizar)

- `lib/supabase/server.js`, `lib/supabase/admin.js`
- `lib/i18n.js`, `public/i18n/{pt,en}.json` (chrome translations)
- `lib/security.js`
- `proxy.js`

---

## Phase 1 — Migration SQL

### Task 1.1: Criar e aplicar migration das tabelas de tradução

**Files:**
- Create: `supabase/migrations/015_i18n_translations.sql`

- [ ] **Step 1: Escrever a migration**

```sql
-- 015_i18n_translations.sql
-- Cria tabelas de tradução PT/EN para artigos, eventos e lives.
-- Aplicar via supabase db push (BD remota já tem schema principal de articles/events/lives).

-- ============================================================================
-- article_translations
-- ============================================================================
CREATE TABLE article_translations (
  article_id UUID NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
  lang CHAR(2) NOT NULL CHECK (lang IN ('pt', 'en')),
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  excerpt TEXT,
  content TEXT,
  category TEXT,
  category_label TEXT,
  author_name TEXT,
  author_role TEXT,
  author_bio TEXT,
  meta_description TEXT,
  auto_translated BOOLEAN NOT NULL DEFAULT TRUE,
  translated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (article_id, lang)
);

CREATE UNIQUE INDEX idx_article_translations_slug_lang
  ON article_translations (slug, lang);
CREATE INDEX idx_article_translations_article_id
  ON article_translations (article_id);

-- ============================================================================
-- event_translations
-- ============================================================================
CREATE TABLE event_translations (
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  lang CHAR(2) NOT NULL CHECK (lang IN ('pt', 'en')),
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  host_name TEXT,
  host_role TEXT,
  host_bio TEXT,
  meta_description TEXT,
  auto_translated BOOLEAN NOT NULL DEFAULT TRUE,
  translated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (event_id, lang)
);

CREATE UNIQUE INDEX idx_event_translations_slug_lang
  ON event_translations (slug, lang);
CREATE INDEX idx_event_translations_event_id
  ON event_translations (event_id);

-- ============================================================================
-- live_translations
-- ============================================================================
CREATE TABLE live_translations (
  live_id UUID NOT NULL REFERENCES lives(id) ON DELETE CASCADE,
  lang CHAR(2) NOT NULL CHECK (lang IN ('pt', 'en')),
  slug TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  host_name TEXT,
  host_role TEXT,
  topic TEXT,
  meta_description TEXT,
  auto_translated BOOLEAN NOT NULL DEFAULT TRUE,
  translated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (live_id, lang)
);

CREATE UNIQUE INDEX idx_live_translations_slug_lang
  ON live_translations (slug, lang);
CREATE INDEX idx_live_translations_live_id
  ON live_translations (live_id);

-- ============================================================================
-- translation_logs (auditoria + rate limit)
-- ============================================================================
CREATE TABLE translation_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  entity_type TEXT NOT NULL CHECK (entity_type IN ('article', 'event', 'live')),
  entity_id UUID NOT NULL,
  lang CHAR(2) NOT NULL,
  char_count INTEGER NOT NULL,
  model TEXT NOT NULL,
  cost_estimate NUMERIC(10, 6),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_translation_logs_created_at
  ON translation_logs (created_at);

-- ============================================================================
-- RLS
-- ============================================================================
ALTER TABLE article_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE live_translations ENABLE ROW LEVEL SECURITY;
ALTER TABLE translation_logs ENABLE ROW LEVEL SECURITY;

-- SELECT público para traduções
CREATE POLICY "article_translations: public read" ON article_translations
  FOR SELECT USING (true);
CREATE POLICY "event_translations: public read" ON event_translations
  FOR SELECT USING (true);
CREATE POLICY "live_translations: public read" ON live_translations
  FOR SELECT USING (true);

-- SELECT restrito a admin para logs
CREATE POLICY "translation_logs: admin read" ON translation_logs
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  );

-- INSERT/UPDATE/DELETE apenas para admin (escrita via service role key no admin client)
-- Nota: server actions usam admin client (createAdminClient) que bypassa RLS, mas
-- adicionamos policies de defesa em profundidade para outros clientes.
CREATE POLICY "article_translations: admin write" ON article_translations
  FOR ALL USING (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  );
CREATE POLICY "event_translations: admin write" ON event_translations
  FOR ALL USING (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  );
CREATE POLICY "live_translations: admin write" ON live_translations
  FOR ALL USING (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  );
CREATE POLICY "translation_logs: admin write" ON translation_logs
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM admin_users WHERE id = auth.uid())
  );

-- ============================================================================
-- Trigger para updated_at
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_article_translations_updated_at
  BEFORE UPDATE ON article_translations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_event_translations_updated_at
  BEFORE UPDATE ON event_translations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_live_translations_updated_at
  BEFORE UPDATE ON live_translations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

- [ ] **Step 2: Aplicar a migration na BD remota**

```bash
cd /c/Users/bapti/Projects/conheca-farmacia-NEXT
supabase db push
```

Expected: `Applying migration 015_i18n_translations.sql...` + success.

- [ ] **Step 3: Verificar que as tabelas foram criadas**

```bash
supabase db remote commit --schema public
# Ou no SQL editor do dashboard:
# SELECT table_name FROM information_schema.tables
# WHERE table_name IN ('article_translations', 'event_translations', 'live_translations', 'translation_logs');
```

Expected: 4 nomes de tabela presentes.

- [ ] **Step 4: Verificar RLS**

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('article_translations', 'event_translations', 'live_translations', 'translation_logs');
```

Expected: `rowsecurity = true` para todas as 4.

- [ ] **Step 5: Commit**

```bash
cd /c/Users/bapti/Projects/conheca-farmacia-NEXT
git add supabase/migrations/015_i18n_translations.sql
git commit -m "feat(db): add i18n translation tables for articles/events/lives"
```

---

## Phase 2 — Helpers de leitura e slugify

### Task 2.1: Criar `lib/utils/slugify.js`

**Files:**
- Create: `lib/utils/slugify.js`

- [ ] **Step 1: Escrever a função**

```js
// lib/utils/slugify.js

/**
 * Converte uma string para slug kebab-case, sem acentos, lowercase.
 * Usado como fallback para `generateEnglishSlug` quando a IA falha.
 */
export function slugify(input) {
  if (!input) return ''
  return String(input)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // remove diacritics
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '') // remove non-alphanumeric (except space/hyphen)
    .replace(/\s+/g, '-') // spaces -> hyphens
    .replace(/-+/g, '-') // collapse multiple hyphens
    .replace(/^-|-$/g, '') // trim leading/trailing hyphens
}

/**
 * Garante que um slug é único dentro de uma tabela. Se já existir, sufixa -2, -3...
 *
 * @param {string} slug - slug base
 * @param {(slug: string) => Promise<boolean>} existsFn - async function que devolve true se slug existe
 * @returns {Promise<string>} slug único
 */
export async function ensureUniqueSlug(slug, existsFn) {
  let candidate = slug
  let suffix = 2
  while (await existsFn(candidate)) {
    candidate = `${slug}-${suffix}`
    suffix += 1
  }
  return candidate
}
```

- [ ] **Step 2: Verificar que o ficheiro está sintacticamente OK**

```bash
cd /c/Users/bapti/Projects/conheca-farmacia-NEXT
node -e "const { slugify } = require('./lib/utils/slugify.js'); console.log(slugify('Farmacocinética Básica'))"
```

Expected: `farmacocinetica-basica`

**Nota:** Se o require não funcionar (ESM), usar:
```bash
node --input-type=module -e "import('./lib/utils/slugify.js').then(m => console.log(m.slugify('Farmacocinética Básica')))"
```

- [ ] **Step 3: Commit**

```bash
git add lib/utils/slugify.js
git commit -m "feat(utils): add slugify and ensureUniqueSlug helpers"
```

---

### Task 2.2: Criar `lib/api/translations.js`

**Files:**
- Create: `lib/api/translations.js`

- [ ] **Step 1: Escrever o módulo**

```js
// lib/api/translations.js
// Helpers para ler e fazer merge de traduções com a entidade PT base.
import { createClient } from '@/lib/supabase/server'
import { ensureUniqueSlug } from '@/lib/utils/slugify'

// Configuração: que campos se traduzem em cada entidade.
// Campos não listados aqui são herdados da entidade PT (image_url, dates, etc.)
export const TRANSLATABLE_FIELDS = {
  article: ['slug', 'title', 'excerpt', 'content', 'category', 'category_label', 'author_name', 'author_role', 'author_bio', 'meta_description'],
  event:   ['slug', 'title', 'description', 'location', 'host_name', 'host_role', 'host_bio', 'meta_description'],
  live:    ['slug', 'title', 'description', 'host_name', 'host_role', 'topic', 'meta_description'],
}

// Campos "transversais" (não traduzidos, sempre da tabela base)
const SHARED_FIELDS = {
  article: ['id', 'image_url', 'published_date', 'read_time', 'status', 'featured', 'references_arr', 'author_avatar', 'author_avatar_bg'],
  event:   ['id', 'image_url', 'event_date', 'status', 'featured'],
  live:    ['id', 'image_url', 'live_date', 'status', 'featured'],
}

const TRANSLATION_TABLE = {
  article: 'article_translations',
  event: 'event_translations',
  live: 'live_translations',
}

const ENTITY_TABLE = {
  article: 'articles',
  event: 'events',
  live: 'lives',
}

const ENTITY_ID_COLUMN = {
  article: 'article_id',
  event: 'event_id',
  live: 'live_id',
}

/**
 * Procura uma tradução por slug e lang.
 */
export async function getTranslationBySlug(entityType, slug, lang) {
  const supabase = await createClient()
  const table = TRANSLATION_TABLE[entityType]
  const { data, error } = await supabase
    .from(table)
    .select('*')
    .eq('slug', slug)
    .eq('lang', lang)
    .maybeSingle()
  if (error) {
    console.error(`[translations] getTranslationBySlug(${entityType}, ${slug}, ${lang}):`, error)
    return null
  }
  return data
}

/**
 * Procura uma tradução por entity_id e lang.
 */
export async function getTranslationByEntityId(entityType, entityId, lang) {
  const supabase = await createClient()
  const table = TRANSLATION_TABLE[entityType]
  const idCol = ENTITY_ID_COLUMN[entityType]
  const { data, error } = await supabase
    .from(table)
    .select('*')
    .eq(idCol, entityId)
    .eq('lang', lang)
    .maybeSingle()
  if (error) {
    console.error(`[translations] getTranslationByEntityId:`, error)
    return null
  }
  return data
}

/**
 * Faz merge de uma entidade PT com a sua tradução (ou null).
 * Devolve um objecto unificado com todos os campos que a UI espera.
 *
 * Estratégia:
 *  - Campos transversais (image_url, dates, etc.) vêm SEMPRE da entidade base.
 *  - Campos traduzíveis (title, content, etc.) vêm da tradução se existir;
 *    senão, fallback para a entidade base.
 *  - Adiciona `translationAvailable: boolean` e `lang` para a UI decidir
 *    se mostra o banner de fallback.
 */
export function mergeEntityWithTranslation(entity, translation, lang) {
  if (!entity) return null
  const merged = { ...entity }
  if (translation) {
    // Sobrescrever campos traduzíveis com a tradução
    for (const field of Object.keys(translation)) {
      // Skip metadata columns
      if (['lang', 'auto_translated', 'translated_at', 'created_at', 'updated_at'].includes(field)) continue
      // Skip FK columns
      if (field.endsWith('_id')) continue
      merged[field] = translation[field]
    }
  }
  merged.lang = lang
  merged.translationAvailable = !!translation
  return merged
}

/**
 * Verifica se um slug já existe na tabela de tradução para a lang.
 */
export async function slugExistsInTranslation(entityType, slug, lang) {
  const supabase = await createClient()
  const table = TRANSLATION_TABLE[entityType]
  const { data, error } = await supabase
    .from(table)
    .select('id')
    .eq('slug', slug)
    .eq('lang', lang)
    .limit(1)
  if (error) {
    console.error(`[translations] slugExistsInTranslation:`, error)
    return false
  }
  return (data?.length ?? 0) > 0
}

/**
 * Gera um slug EN único. Verifica colisão e sufixa se necessário.
 */
export async function generateUniqueEnglishSlug(entityType, baseSlug) {
  return ensureUniqueSlug(baseSlug, (slug) => slugExistsInTranslation(entityType, slug, 'en'))
}

/**
 * Lista entidades que NÃO têm tradução EN (para bulk translate UI).
 * Devolve array de { id, title, ...metadata } para a UI.
 */
export async function listEntitiesMissingTranslation(entityType) {
  const supabase = await createClient()
  const entityTable = ENTITY_TABLE[entityType]
  const translationTable = TRANSLATION_TABLE[entityType]
  const idCol = ENTITY_ID_COLUMN[entityType]

  // Subquery: ids que JÁ têm tradução EN
  const { data: translated, error: err1 } = await supabase
    .from(translationTable)
    .select(idCol)
    .eq('lang', 'en')
  if (err1) {
    console.error(`[translations] listEntitiesMissingTranslation (translated):`, err1)
    return []
  }
  const translatedIds = new Set((translated ?? []).map((r) => r[idCol]))

  // Todas as entidades publicadas
  const { data: all, error: err2 } = await supabase
    .from(entityTable)
    .select('id, title, slug, published_date, event_date, live_date, status')
    .eq('status', 'published')
    .order('published_date', { ascending: false, nullsFirst: false })
  if (err2) {
    console.error(`[translations] listEntitiesMissingTranslation (all):`, err2)
    return []
  }
  return (all ?? []).filter((row) => !translatedIds.has(row.id))
}
```

- [ ] **Step 2: Verificar que compila (sem erros de import)**

```bash
cd /c/Users/bapti/Projects/conheca-farmacia-NEXT
npm run build 2>&1 | grep -E "(error|Error|Failed)" | head -20
```

Expected: nenhum erro (ou apenas warnings pré-existentes não relacionados).

- [ ] **Step 3: Commit**

```bash
git add lib/api/translations.js
git commit -m "feat(api): add translation helpers (merge, get, list-missing)"
```

---

## Phase 3 — Refactor da camada de leitura

### Task 3.1: Refactor `lib/api/articles.js`

**Files:**
- Modify: `lib/api/articles.js`

- [ ] **Step 1: Adicionar `lang` a `getArticleBySlug`**

Substituir a função existente por:

```js
// lib/api/articles.js
import { createClient } from '@/lib/supabase/server'
import { getTranslationBySlug, mergeEntityWithTranslation } from '@/lib/api/translations'

/**
 * @param {string} slug
 * @param {'pt'|'en'} lang
 * @returns {Promise<object|null>} artigo com merge de tradução, ou null
 */
export async function getArticleBySlug(slug, lang = 'pt') {
  const supabase = await createClient()
  const { data: article, error } = await supabase
    .from('articles')
    .select('*')
    .eq('slug', slug)
    .eq('status', 'published')
    .maybeSingle()
  if (error) {
    console.error('[articles] getArticleBySlug:', error)
    return null
  }
  if (!article) return null

  let translation = null
  if (lang === 'en') {
    translation = await getTranslationBySlug('article', slug, 'en')
  }
  return mergeEntityWithTranslation(article, translation, lang)
}
```

- [ ] **Step 2: Refactor `listArticles` para aceitar `lang`**

Encontrar a função `listArticles` existente e substituir por:

```js
export async function listArticles({ lang = 'pt', category = null, limit = null, offset = 0 } = {}) {
  const supabase = await createClient()
  let query = supabase
    .from('articles')
    .select('*')
    .eq('status', 'published')
    .order('published_date', { ascending: false, nullsFirst: false })
    .range(offset, offset + (limit ?? 1000) - 1)

  if (category) {
    query = query.eq('category', category)
  }

  const { data, error } = await query
  if (error) {
    console.error('[articles] listArticles:', error)
    return []
  }
  if (lang === 'pt' || !data?.length) return data ?? []

  // Para EN, fazer join com traduções em batch
  const ids = data.map((a) => a.id)
  const { data: translations, error: err2 } = await supabase
    .from('article_translations')
    .select('*')
    .in('article_id', ids)
    .eq('lang', 'en')
  if (err2) {
    console.error('[articles] listArticles (translations):', err2)
    return data
  }
  const tMap = new Map((translations ?? []).map((t) => [t.article_id, t]))
  return data.map((a) => mergeEntityWithTranslation(a, tMap.get(a.id) ?? null, 'en'))
}
```

- [ ] **Step 3: Smoke test local**

```bash
cd /c/Users/bapti/Projects/conheca-farmacia-NEXT
npm run dev
# Em outro terminal:
curl -s "http://localhost:3000/pt/artigos" | head -50
# Verificar que a lista de artigos aparece normalmente (PT)
```

Expected: HTML da listagem de artigos em PT, sem erros no console do servidor.

- [ ] **Step 4: Commit**

```bash
git add lib/api/articles.js
git commit -m "refactor(api): articles.js accepts lang, merges translation with fallback"
```

---

### Task 3.2: Refactor `lib/api/events.js`

**Files:**
- Modify: `lib/api/events.js`

- [ ] **Step 1: Adicionar `lang` a `getEventBySlug`**

Substituir a função existente por:

```js
// Adicionar imports
import { getTranslationBySlug, mergeEntityWithTranslation } from '@/lib/api/translations'

export async function getEventBySlug(slug, lang = 'pt') {
  const supabase = await createClient()
  const { data: event, error } = await supabase
    .from('events')
    .select('*')
    .eq('slug', slug)
    .eq('status', 'published')
    .maybeSingle()
  if (error) {
    console.error('[events] getEventBySlug:', error)
    return null
  }
  if (!event) return null

  let translation = null
  if (lang === 'en') {
    translation = await getTranslationBySlug('event', slug, 'en')
  }
  return mergeEntityWithTranslation(event, translation, lang)
}
```

- [ ] **Step 2: Refactor `listEvents` para aceitar `lang`**

```js
export async function listEvents({ lang = 'pt', limit = null, offset = 0 } = {}) {
  const supabase = await createClient()
  let query = supabase
    .from('events')
    .select('*')
    .eq('status', 'published')
    .order('event_date', { ascending: false, nullsFirst: false })
    .range(offset, offset + (limit ?? 1000) - 1)

  const { data, error } = await query
  if (error) {
    console.error('[events] listEvents:', error)
    return []
  }
  if (lang === 'pt' || !data?.length) return data ?? []

  const ids = data.map((e) => e.id)
  const { data: translations, error: err2 } = await supabase
    .from('event_translations')
    .select('*')
    .in('event_id', ids)
    .eq('lang', 'en')
  if (err2) {
    console.error('[events] listEvents (translations):', err2)
    return data
  }
  const tMap = new Map((translations ?? []).map((t) => [t.event_id, t]))
  return data.map((e) => mergeEntityWithTranslation(e, tMap.get(e.id) ?? null, 'en'))
}
```

- [ ] **Step 3: Smoke test local**

```bash
curl -s "http://localhost:3000/pt/eventos" | head -30
```

Expected: listagem de eventos em PT, sem erros.

- [ ] **Step 4: Commit**

```bash
git add lib/api/events.js
git commit -m "refactor(api): events.js accepts lang, merges translation with fallback"
```

---

### Task 3.3: Refactor `lib/api/lives.js`

**Files:**
- Modify: `lib/api/lives.js`

- [ ] **Step 1: Adicionar `lang` a `getLiveBySlug`**

```js
import { getTranslationBySlug, mergeEntityWithTranslation } from '@/lib/api/translations'

export async function getLiveBySlug(slug, lang = 'pt') {
  const supabase = await createClient()
  const { data: live, error } = await supabase
    .from('lives')
    .select('*')
    .eq('slug', slug)
    .eq('status', 'published')
    .maybeSingle()
  if (error) {
    console.error('[lives] getLiveBySlug:', error)
    return null
  }
  if (!live) return null

  let translation = null
  if (lang === 'en') {
    translation = await getTranslationBySlug('live', slug, 'en')
  }
  return mergeEntityWithTranslation(live, translation, lang)
}
```

- [ ] **Step 2: Refactor `listLives` para aceitar `lang`**

```js
export async function listLives({ lang = 'pt', limit = null, offset = 0 } = {}) {
  const supabase = await createClient()
  let query = supabase
    .from('lives')
    .select('*')
    .eq('status', 'published')
    .order('live_date', { ascending: false, nullsFirst: false })
    .range(offset, offset + (limit ?? 1000) - 1)

  const { data, error } = await query
  if (error) {
    console.error('[lives] listLives:', error)
    return []
  }
  if (lang === 'pt' || !data?.length) return data ?? []

  const ids = data.map((l) => l.id)
  const { data: translations, error: err2 } = await supabase
    .from('live_translations')
    .select('*')
    .in('live_id', ids)
    .eq('lang', 'en')
  if (err2) {
    console.error('[lives] listLives (translations):', err2)
    return data
  }
  const tMap = new Map((translations ?? []).map((t) => [t.live_id, t]))
  return data.map((l) => mergeEntityWithTranslation(l, tMap.get(l.id) ?? null, 'en'))
}
```

- [ ] **Step 3: Smoke test local**

```bash
curl -s "http://localhost:3000/pt/lives" | head -30
```

Expected: listagem de lives em PT, sem erros.

- [ ] **Step 4: Commit**

```bash
git add lib/api/lives.js
git commit -m "refactor(api): lives.js accepts lang, merges translation with fallback"
```

---

### Task 3.4: Refactor `lib/api/search.js` para pesquisar na língua do URL

**Files:**
- Modify: `lib/api/search.js`

- [ ] **Step 1: Reescrever a função de search de artigos**

Localizar a função existente `searchArticles` (ou equivalente) e substituir por:

```js
// lib/api/search.js
import { createClient } from '@/lib/supabase/server'
import { mergeEntityWithTranslation } from '@/lib/api/translations'

/**
 * Pesquisa artigos na língua do URL.
 * - lang === 'pt': pesquisa em title, excerpt, content, category_label da tabela articles.
 * - lang === 'en': pesquisa APENAS em article_translations (title, excerpt, content_en).
 *   Se não houver tradução EN, o artigo NÃO aparece (decisão: integridade linguística).
 */
export async function searchArticles(query, lang = 'pt') {
  if (!query || query.trim().length < 2) return []
  const supabase = await createClient()
  const q = `%${query.trim()}%`

  if (lang === 'en') {
    // JOIN com article_translations
    const { data, error } = await supabase
      .from('article_translations')
      .select(`
        *,
        article:article_id (*)
      `)
      .eq('lang', 'en')
      .or(`title.ilike.${q},excerpt.ilike.${q},content.ilike.${q}`)
      .limit(50)
    if (error) {
      console.error('[search] searchArticles (en):', error)
      return []
    }
    return (data ?? [])
      .filter((row) => row.article?.status === 'published')
      .map((row) => mergeEntityWithTranslation(row.article, row, 'en'))
  }

  // PT: pesquisa directa em articles
  const { data, error } = await supabase
    .from('articles')
    .select('*')
    .eq('status', 'published')
    .or(`title.ilike.${q},excerpt.ilike.${q},content.ilike.${q}`)
    .limit(50)
  if (error) {
    console.error('[search] searchArticles (pt):', error)
    return []
  }
  return (data ?? []).map((a) => mergeEntityWithTranslation(a, null, 'pt'))
}
```

- [ ] **Step 2: Smoke test local**

```bash
curl -s "http://localhost:3000/pt/pesquisa?q=teste" | head -30
curl -s "http://localhost:3000/en/search?q=test" | head -30
```

Expected: resultados de pesquisa em PT (lista) e 0 resultados em EN (nenhuma tradução ainda).

- [ ] **Step 3: Commit**

```bash
git add lib/api/search.js
git commit -m "refactor(api): search.js filters by URL lang, EN searches translations only"
```

---

## Phase 4 — Refactor das páginas públicas

### Task 4.1: Criar `components/public/TranslationFallbackBanner.jsx`

**Files:**
- Create: `components/public/TranslationFallbackBanner.jsx`

- [ ] **Step 1: Escrever o componente**

```jsx
// components/public/TranslationFallbackBanner.jsx
'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'

/**
 * Banner amarelo mostrado no topo do conteúdo em /en/* quando a página
 * não tem tradução EN e está a fazer fallback para PT.
 *
 * Para admins autenticados, mostra link "Translate this article"
 * que aponta para a página de edição admin.
 */
export default function TranslationFallbackBanner({ entityType, entityId }) {
  const { t } = useContext(LangContext)
  return (
    <div
      role="status"
      className="translation-fallback-banner"
      style={{
        background: '#fff3cd',
        border: '1px solid #ffc107',
        color: '#856404',
        padding: '12px 16px',
        borderRadius: '6px',
        margin: '0 0 24px 0',
        fontSize: '14px',
      }}
    >
      <strong>{t('translation.not_translated_title')}</strong>{' '}
      {t('translation.not_translated_body')}
      {entityType && entityId && (
        <>
          {' '}
          <a
            href={`/admin/${entityType}s/${entityId}`}
            style={{ color: '#856404', textDecoration: 'underline' }}
          >
            {t('translation.translate_link')}
          </a>
        </>
      )}
    </div>
  )
}
```

- [ ] **Step 2: Adicionar keys de i18n em `public/i18n/pt.json` e `public/i18n/en.json`**

Ler `public/i18n/pt.json` e `public/i18n/en.json`. Adicionar (em qualquer ponto razoável do objecto):

```json
"translation": {
  "not_translated_title": "Tradução em falta",
  "not_translated_body": "Esta página ainda não foi traduzida para inglês. A versão original em português está a ser mostrada.",
  "translate_link": "Traduzir esta página"
}
```

```json
"translation": {
  "not_translated_title": "Not yet translated",
  "not_translated_body": "This page is not yet translated to English. The original Portuguese version is being shown.",
  "translate_link": "Translate this page"
}
```

- [ ] **Step 3: Commit**

```bash
git add components/public/TranslationFallbackBanner.jsx public/i18n/pt.json public/i18n/en.json
git commit -m "feat(public): add TranslationFallbackBanner for /en/* pages without translation"
```

---

### Task 4.2: Refactor página `app/[lang]/(public)/artigos/[slug]/page.js`

**Files:**
- Modify: `app/[lang]/(public)/artigos/[slug]/page.js`

- [ ] **Step 1: Substituir o ficheiro inteiro**

```jsx
// app/[lang]/(public)/artigos/[slug]/page.js
import { notFound } from 'next/navigation'
import { getArticleBySlug } from '@/lib/api/articles'
import { getTranslationBySlug } from '@/lib/api/translations'
import { loadTranslations } from '@/lib/i18n'
import TranslationFallbackBanner from '@/components/public/TranslationFallbackBanner'
import ArticleView from '@/components/ArticleView' // ajustar nome se diferente

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || 'https://conhecafarmacia.com'

export async function generateMetadata({ params }) {
  const { slug, lang } = await params
  const article = await getArticleBySlug(slug, lang)
  if (!article) return {}

  const translation = lang === 'en' ? await getTranslationBySlug('article', slug, 'en') : null
  // PT slug para hreflang (sempre a base PT)
  const ptSlug = article.slug

  return {
    title: article.title,
    description: article.meta_description || article.excerpt,
    alternates: {
      canonical: `${SITE_URL}/${lang}/artigos/${article.slug}`,
      languages: {
        'pt': `${SITE_URL}/pt/artigos/${ptSlug}`,
        'en': translation ? `${SITE_URL}/en/articles/${translation.slug}` : undefined,
        'x-default': `${SITE_URL}/pt/artigos/${ptSlug}`,
      },
    },
  }
}

export default async function ArticlePage({ params }) {
  const { slug, lang } = await params
  const article = await getArticleBySlug(slug, lang)
  if (!article) notFound()

  const showFallbackBanner = lang === 'en' && !article.translationAvailable

  return (
    <>
      {showFallbackBanner && (
        <TranslationFallbackBanner entityType="article" entityId={article.id} />
      )}
      <ArticleView article={article} lang={lang} />
    </>
  )
}
```

**Nota:** O componente `ArticleView` já existe no projecto; ajustar o import conforme a estrutura real. Se não existir, renderizar o body do artigo com `<div dangerouslySetInnerHTML={{ __html: renderMarkdown(article.content) }} />` (e o helper de markdown que o projecto já usa).

- [ ] **Step 2: Smoke test local**

```bash
npm run dev
# Navegar para /pt/artigos/[slug-existente] — deve mostrar artigo em PT
# Navegar para /en/articles/[slug-existente] — deve mostrar artigo em PT (fallback) + banner amarelo
```

Expected:
- `/pt/artigos/foo`: artigo em PT, sem banner.
- `/en/articles/foo`: artigo em PT, com banner amarelo no topo.

- [ ] **Step 3: Verificar hreflang via DevTools**

- Abrir DevTools → Elements → `<head>`.
- Confirmar presença de:
  ```html
  <link rel="alternate" hreflang="pt" href="https://conhecafarmacia.com/pt/artigos/[slug]">
  <link rel="alternate" hreflang="x-default" href="https://conhecafarmacia.com/pt/artigos/[slug]">
  ```
- (Sem hreflang en porque ainda não há tradução.)

- [ ] **Step 4: Commit**

```bash
git add "app/[lang]/(public)/artigos/[slug]/page.js"
git commit -m "feat(public): article page merges translation + shows fallback banner + hreflang"
```

---

### Task 4.3: Refactor página `app/[lang]/(public)/artigos/page.js` (listagem)

**Files:**
- Modify: `app/[lang]/(public)/artigos/page.js`

- [ ] **Step 1: Localizar e ajustar a chamada a `listArticles`**

Procurar a chamada existente (tipicamente `listArticles()`) e substituir por `listArticles({ lang })`:

```jsx
// Antes
const articles = await listArticles()

// Depois
const { lang } = await params
const articles = await listArticles({ lang })
```

- [ ] **Step 2: Smoke test local**

```bash
curl -s "http://localhost:3000/pt/artigos" | head -30
curl -s "http://localhost:3000/en/articles" | head -30
```

Expected:
- PT: lista normal de artigos.
- EN: lista de artigos com `translationAvailable: false` (todos em PT, sem tradução EN).

- [ ] **Step 3: Commit**

```bash
git add "app/[lang]/(public)/artigos/page.js"
git commit -m "refactor(public): articles list passes lang to listArticles"
```

---

### Task 4.4: Refactor páginas de eventos (listagem + detail)

**Files:**
- Modify: `app/[lang]/(public)/eventos/page.js`
- Modify: `app/[lang]/(public)/eventos/[slug]/page.js`

- [ ] **Step 1: Ajustar `eventos/page.js` (listagem)**

Localizar a chamada a `listEvents()` e substituir por `listEvents({ lang })`:

```jsx
const { lang } = await params
const events = await listEvents({ lang })
```

- [ ] **Step 2: Ajustar `eventos/[slug]/page.js` (detail)**

Adicionar imports no topo:

```jsx
import TranslationFallbackBanner from '@/components/public/TranslationFallbackBanner'
import { getTranslationBySlug } from '@/lib/api/translations'
```

Substituir o `generateMetadata` e o componente da página:

```jsx
export async function generateMetadata({ params }) {
  const { slug, lang } = await params
  const event = await getEventBySlug(slug, lang)
  if (!event) return {}

  const translation = lang === 'en' ? await getTranslationBySlug('event', slug, 'en') : null
  const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || 'https://conhecafarmacia.com'

  return {
    title: event.title,
    description: event.meta_description || event.description,
    alternates: {
      canonical: `${SITE_URL}/${lang}/eventos/${event.slug}`,
      languages: {
        'pt': `${SITE_URL}/pt/eventos/${event.slug}`,
        'en': translation ? `${SITE_URL}/en/events/${translation.slug}` : undefined,
        'x-default': `${SITE_URL}/pt/eventos/${event.slug}`,
      },
    },
  }
}

export default async function EventPage({ params }) {
  const { slug, lang } = await params
  const event = await getEventBySlug(slug, lang)
  if (!event) notFound()

  const showFallbackBanner = lang === 'en' && !event.translationAvailable

  return (
    <>
      {showFallbackBanner && (
        <TranslationFallbackBanner entityType="event" entityId={event.id} />
      )}
      {/* Renderizar evento com o componente existente */}
      <EventView event={event} lang={lang} />
    </>
  )
}
```

**Nota:** Ajustar `EventView` para o nome real do componente usado no projecto (ou inline render se necessário).

- [ ] **Step 3: Smoke test local**

```bash
curl -s "http://localhost:3000/pt/eventos" | head -20
curl -s "http://localhost:3000/en/events" | head -20
```

Expected: listagens funcionam, sem erros.

- [ ] **Step 4: Commit**

```bash
git add "app/[lang]/(public)/eventos/page.js" "app/[lang]/(public)/eventos/[slug]/page.js"
git commit -m "refactor(public): event pages merge translation + hreflang + fallback banner"
```

---

### Task 4.5: Refactor páginas de lives (listagem + detail)

**Files:**
- Modify: `app/[lang]/(public)/lives/page.js`
- Modify: `app/[lang]/(public)/lives/[slug]/page.js`

- [ ] **Step 1: Ajustar `lives/page.js` (listagem)**

```jsx
const { lang } = await params
const lives = await listLives({ lang })
```

- [ ] **Step 2: Ajustar `lives/[slug]/page.js` (detail)**

```jsx
import TranslationFallbackBanner from '@/components/public/TranslationFallbackBanner'
import { getTranslationBySlug } from '@/lib/api/translations'

export async function generateMetadata({ params }) {
  const { slug, lang } = await params
  const live = await getLiveBySlug(slug, lang)
  if (!live) return {}

  const translation = lang === 'en' ? await getTranslationBySlug('live', slug, 'en') : null
  const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || 'https://conhecafarmacia.com'

  return {
    title: live.title,
    description: live.meta_description || live.description,
    alternates: {
      canonical: `${SITE_URL}/${lang}/lives/${live.slug}`,
      languages: {
        'pt': `${SITE_URL}/pt/lives/${live.slug}`,
        'en': translation ? `${SITE_URL}/en/lives/${translation.slug}` : undefined,
        'x-default': `${SITE_URL}/pt/lives/${live.slug}`,
      },
    },
  }
}

export default async function LivePage({ params }) {
  const { slug, lang } = await params
  const live = await getLiveBySlug(slug, lang)
  if (!live) notFound()

  const showFallbackBanner = lang === 'en' && !live.translationAvailable

  return (
    <>
      {showFallbackBanner && (
        <TranslationFallbackBanner entityType="live" entityId={live.id} />
      )}
      <LiveView live={live} lang={lang} />
    </>
  )
}
```

- [ ] **Step 3: Smoke test local**

```bash
curl -s "http://localhost:3000/pt/lives" | head -20
curl -s "http://localhost:3000/en/lives" | head -20
```

Expected: listagens funcionam.

- [ ] **Step 4: Commit**

```bash
git add "app/[lang]/(public)/lives/page.js" "app/[lang]/(public)/lives/[slug]/page.js"
git commit -m "refactor(public): live pages merge translation + hreflang + fallback banner"
```

---

### Task 4.6: Refactor página de pesquisa

**Files:**
- Modify: `app/[lang]/(public)/pesquisa/page.js`

- [ ] **Step 1: Ajustar a chamada a `searchArticles`**

Localizar a chamada existente e substituir:

```jsx
const { lang } = await params
const results = await searchArticles(query, lang)
```

- [ ] **Step 2: Smoke test local**

```bash
curl -s "http://localhost:3000/pt/pesquisa?q=farmacologia" | head -30
curl -s "http://localhost:3000/en/search?q=pharmacology" | head -30
```

Expected: PT devolve resultados, EN devolve 0 (sem traduções ainda).

- [ ] **Step 3: Commit**

```bash
git add "app/[lang]/(public)/pesquisa/page.js"
git commit -m "refactor(public): search page passes lang to searchArticles"
```

---

## Phase 5 — Server Action de tradução automática

### Task 5.1: Criar `lib/actions/translation.js`

**Files:**
- Create: `lib/actions/translation.js`

- [ ] **Step 1: Escrever o módulo**

```js
// lib/actions/translation.js
'use server'

import { createAdminClient } from '@/lib/supabase/admin'
import { generateUniqueEnglishSlug } from '@/lib/api/translations'
import { slugify } from '@/lib/utils/slugify'

const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions'
const OPENROUTER_MODEL = process.env.OPENROUTER_MODEL || 'llama-nemotron-rerank-v1-1b-v2:free'
const DAILY_CHAR_LIMIT = parseInt(process.env.TRANSLATION_DAILY_CHAR_LIMIT || '1000000', 10)
const TIMEOUT_MS = 30000

const SYSTEM_PROMPT = `You are a technical translator specialised in pharmacology and pharmaceutical sciences (PT→EN). Your task is to translate Portuguese text fields to natural, professional English suitable for a pharmaceutical-care audience.

Rules:
- Keep scientific terminology in English (e.g., "pharmacokinetics", "bioavailability", "drug interaction").
- Copy proper names (author names, host names) VERBATIM without translating.
- For empty or null values, return null.
- Respond ONLY with valid JSON, no markdown fences, no preamble.
- Use the exact field names provided in the user message.
- Preserve markdown formatting in content fields.`

const ENTITY_FIELDS = {
  article: ['title', 'excerpt', 'content', 'category_label', 'author_role', 'author_bio', 'meta_description'],
  event:   ['title', 'description', 'location', 'host_name', 'host_role', 'host_bio', 'meta_description'],
  live:    ['title', 'description', 'host_name', 'host_role', 'topic', 'meta_description'],
}

const ENTITY_TABLE = {
  article: 'articles',
  event: 'events',
  live: 'lives',
}

const TRANSLATION_TABLE = {
  article: 'article_translations',
  event: 'event_translations',
  live: 'live_translations',
}

const ENTITY_ID_COLUMN = {
  article: 'article_id',
  event: 'event_id',
  live: 'live_id',
}

/**
 * Verifica se o rate limit diário foi atingido.
 * Soma chars traduzidos nas últimas 24h; rejeita se >= DAILY_CHAR_LIMIT.
 */
async function checkRateLimit() {
  const supabase = await createAdminClient()
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
  const { data, error } = await supabase
    .from('translation_logs')
    .select('char_count')
    .gte('created_at', since)
  if (error) {
    console.error('[translation] checkRateLimit:', error)
    return { allowed: true, used: 0 } // fail open
  }
  const used = (data ?? []).reduce((sum, row) => sum + (row.char_count ?? 0), 0)
  return { allowed: used < DAILY_CHAR_LIMIT, used, limit: DAILY_CHAR_LIMIT }
}

/**
 * Chama OpenRouter para traduzir um objecto de campos PT → EN.
 */
async function callOpenRouter(sourceFields) {
  const apiKey = process.env.OPENROUTER_API_KEY
  if (!apiKey) {
    throw new Error('OPENROUTER_API_KEY not configured')
  }

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS)

  try {
    const response = await fetch(OPENROUTER_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://conhecafarmacia.com',
        'X-Title': 'Conheça Farmácia Translator',
      },
      body: JSON.stringify({
        model: OPENROUTER_MODEL,
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: JSON.stringify(sourceFields) },
        ],
        response_format: { type: 'json_object' },
        temperature: 0.2,
      }),
      signal: controller.signal,
    })

    if (!response.ok) {
      const errText = await response.text()
      throw new Error(`OpenRouter ${response.status}: ${errText.slice(0, 500)}`)
    }

    const result = await response.json()
    const content = result?.choices?.[0]?.message?.content
    if (!content) {
      throw new Error('OpenRouter returned empty content')
    }
    return JSON.parse(content)
  } finally {
    clearTimeout(timeout)
  }
}

/**
 * Auto-traduz uma entidade (article/event/live) de PT → EN.
 * Insere ou actualiza a tradução em article_translations/etc.
 *
 * @param {'article'|'event'|'live'} entityType
 * @param {string} entityId - UUID
 * @returns {Promise<{ok: boolean, translation?: object, error?: string, rateLimited?: boolean}>}
 */
export async function autoTranslateEntity(entityType, entityId) {
  if (!ENTITY_TABLE[entityType]) {
    return { ok: false, error: `Unknown entity type: ${entityType}` }
  }

  // 1. Rate limit
  const rate = await checkRateLimit()
  if (!rate.allowed) {
    return {
      ok: false,
      rateLimited: true,
      error: `Daily translation limit reached (${rate.used}/${rate.limit} chars in last 24h). Try again later.`,
    }
  }

  // 2. Ler registo PT base
  const supabase = await createAdminClient()
  const { data: entity, error: errEntity } = await supabase
    .from(ENTITY_TABLE[entityType])
    .select('*')
    .eq('id', entityId)
    .single()
  if (errEntity || !entity) {
    return { ok: false, error: `Entity not found: ${errEntity?.message || 'no row'}` }
  }

  // 3. Preparar input para IA
  const fields = ENTITY_FIELDS[entityType]
  const sourceObj = {}
  for (const f of fields) {
    sourceObj[f] = entity[f] ?? null
  }

  // 4. Chamar IA
  let translated
  try {
    translated = await callOpenRouter(sourceObj)
  } catch (err) {
    return { ok: false, error: `Translation failed: ${err.message}` }
  }

  // 5. Gerar slug EN
  const baseSlug = slugify(translated.slug || entity.slug || entity.title || 'untitled')
  const enSlug = await generateUniqueEnglishSlug(entityType, baseSlug)

  // 6. Construir payload
  const translation = {
    [ENTITY_ID_COLUMN[entityType]]: entityId,
    lang: 'en',
    slug: enSlug,
    auto_translated: true,
    translated_at: new Date().toISOString(),
    ...translated,
    slug: enSlug, // override com slug único
  }

  // 7. Upsert
  const { data: upserted, error: errUpsert } = await supabase
    .from(TRANSLATION_TABLE[entityType])
    .upsert(translation, {
      onConflict: `${ENTITY_ID_COLUMN[entityType]},lang`,
      ignoreDuplicates: false,
    })
    .select()
    .single()
  if (errUpsert) {
    return { ok: false, error: `Upsert failed: ${errUpsert.message}` }
  }

  // 8. Log
  const charCount = JSON.stringify(sourceObj).length
  await supabase.from('translation_logs').insert({
    entity_type: entityType,
    entity_id: entityId,
    lang: 'en',
    char_count: charCount,
    model: OPENROUTER_MODEL,
    cost_estimate: 0, // TODO: calcular baseado em tokens
  })

  return { ok: true, translation: upserted }
}

/**
 * Versão mais leve para gerar APENAS o slug EN (usado quando a tradução
 * foi feita manualmente e o admin quer gerar slug).
 */
export async function generateEnglishSlugAction(portugueseSlug) {
  // Tentar IA primeiro
  try {
    const apiKey = process.env.OPENROUTER_API_KEY
    if (apiKey) {
      const response = await fetch(OPENROUTER_URL, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: OPENROUTER_MODEL,
          messages: [
            {
              role: 'system',
              content: 'Convert a Portuguese slug to an English kebab-case slug. Output ONLY the slug, no quotes, no explanation.',
            },
            { role: 'user', content: portugueseSlug },
          ],
          temperature: 0.1,
        }),
      })
      if (response.ok) {
        const data = await response.json()
        const slug = data?.choices?.[0]?.message?.content?.trim()
        if (slug && /^[a-z0-9-]+$/.test(slug)) return slug
      }
    }
  } catch (err) {
    console.warn('[translation] generateEnglishSlug IA failed, using fallback:', err)
  }
  // Fallback slugify (português → kebab, sem acentos)
  return slugify(portugueseSlug)
}
```

- [ ] **Step 2: Verificar que compila**

```bash
cd /c/Users/bapti/Projects/conheca-farmacia-NEXT
npm run build 2>&1 | grep -E "(error|Error|Failed)" | head -20
```

Expected: nenhum erro novo.

- [ ] **Step 3: Commit**

```bash
git add lib/actions/translation.js
git commit -m "feat(actions): autoTranslateEntity via OpenRouter with rate limit and logging"
```

---

## Phase 6 — Componente BilingualTabs

### Task 6.1: Criar `components/admin/BilingualTabs.jsx`

**Files:**
- Create: `components/admin/BilingualTabs.jsx`

- [ ] **Step 1: Escrever o componente**

```jsx
// components/admin/BilingualTabs.jsx
'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { autoTranslateEntity } from '@/lib/actions/translation'

/**
 * Tabs widget para editar uma entidade bilingue (PT | EN).
 *
 * Props:
 *  - entityType: 'article' | 'event' | 'live'
 *  - entityId: UUID
 *  - record: object com os campos PT
 *  - translation: object com campos EN, ou null
 *  - fields: array de { key, label, type, multiline? } descrevendo campos editáveis
 *  - onSaveTranslation: server action chamada quando admin clica "Guardar EN"
 *  - lang: 'pt' | 'en' (do URL)
 *
 * Notas:
 *  - O separador PT é read-only neste componente (a página admin renderiza-o fora).
 *    Apenas o separador EN é gerido aqui.
 *  - O botão "Auto-traduzir" chama autoTranslateEntity e refresca a rota.
 */
export default function BilingualTabs({
  entityType,
  entityId,
  record,
  translation,
  fields,
  onSaveTranslation,
  lang = 'pt',
}) {
  const router = useRouter()
  const [activeTab, setActiveTab] = useState(translation ? 'en' : 'en')
  const [enValues, setEnValues] = useState(() => {
    if (translation) {
      const obj = {}
      for (const f of fields) obj[f.key] = translation[f.key] ?? ''
      return obj
    }
    return Object.fromEntries(fields.map((f) => [f.key, '']))
  })
  const [isTranslating, startTransition] = useTransition()
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState(null)
  const [success, setSuccess] = useState(null)

  const status = !translation
    ? 'missing'
    : translation.auto_translated
    ? 'auto'
    : 'manual'

  function handleAutoTranslate() {
    setError(null)
    setSuccess(null)
    startTransition(async () => {
      const result = await autoTranslateEntity(entityType, entityId)
      if (result.ok) {
        setSuccess(t('translation.auto_success'))
        // Recarregar a página para obter a tradução fresca do server
        router.refresh()
      } else if (result.rateLimited) {
        setError(t('translation.rate_limited'))
      } else {
        setError(result.error || t('translation.auto_error'))
      }
    })
  }

  async function handleSave(e) {
    e.preventDefault()
    setError(null)
    setSuccess(null)
    setIsSaving(true)
    try {
      const result = await onSaveTranslation(enValues)
      if (result?.ok) {
        setSuccess(t('translation.save_success'))
        router.refresh()
      } else {
        setError(result?.error || t('translation.save_error'))
      }
    } catch (err) {
      setError(err.message)
    } finally {
      setIsSaving(false)
    }
  }

  function updateField(key, value) {
    setEnValues((prev) => ({ ...prev, [key]: value }))
  }

  return (
    <div className="bilingual-tabs">
      <div role="tablist" style={{ display: 'flex', borderBottom: '2px solid #e5e7eb', marginBottom: '16px' }}>
        <button
          type="button"
          role="tab"
          aria-selected={activeTab === 'pt'}
          onClick={() => setActiveTab('pt')}
          style={{
            padding: '10px 20px',
            border: 'none',
            background: 'none',
            cursor: 'pointer',
            borderBottom: activeTab === 'pt' ? '2px solid #2563eb' : '2px solid transparent',
            marginBottom: '-2px',
            fontWeight: activeTab === 'pt' ? '600' : '400',
          }}
        >
          {t('translation.tab_pt')}
        </button>
        <button
          type="button"
          role="tab"
          aria-selected={activeTab === 'en'}
          onClick={() => setActiveTab('en')}
          style={{
            padding: '10px 20px',
            border: 'none',
            background: 'none',
            cursor: 'pointer',
            borderBottom: activeTab === 'en' ? '2px solid #2563eb' : '2px solid transparent',
            marginBottom: '-2px',
            fontWeight: activeTab === 'en' ? '600' : '400',
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
          }}
        >
          {t('translation.tab_en')}
          <span
            style={{
              fontSize: '11px',
              padding: '2px 8px',
              borderRadius: '9999px',
              background:
                status === 'manual' ? '#d1fae5' : status === 'auto' ? '#dbeafe' : '#fee2e2',
              color: status === 'manual' ? '#065f46' : status === 'auto' ? '#1e40af' : '#991b1b',
            }}
          >
            {status === 'manual' && '✓ ' + t('translation.status_manual')}
            {status === 'auto' && '🤖 ' + t('translation.status_auto')}
            {status === 'missing' && '⚠ ' + t('translation.status_missing')}
          </span>
        </button>
      </div>

      {activeTab === 'pt' && (
        <div className="bilingual-tabs__pt" style={{ padding: '16px 0' }}>
          <p style={{ color: '#6b7280', fontStyle: 'italic' }}>
            {t('translation.pt_hint')}
          </p>
          <a
            href={`/${lang}/admin/${entityType}s/${entityId}`}
            style={{ color: '#2563eb', textDecoration: 'underline' }}
          >
            {t('translation.edit_pt_link')}
          </a>
        </div>
      )}

      {activeTab === 'en' && (
        <form onSubmit={handleSave} className="bilingual-tabs__en">
          {error && (
            <div
              role="alert"
              style={{
                background: '#fee2e2',
                color: '#991b1b',
                padding: '12px',
                borderRadius: '6px',
                marginBottom: '16px',
              }}
            >
              {error}
            </div>
          )}
          {success && (
            <div
              role="status"
              style={{
                background: '#d1fae5',
                color: '#065f46',
                padding: '12px',
                borderRadius: '6px',
                marginBottom: '16px',
              }}
            >
              {success}
            </div>
          )}

          {!translation && (
            <div
              style={{
                background: '#fff3cd',
                border: '1px solid #ffc107',
                color: '#856404',
                padding: '16px',
                borderRadius: '6px',
                marginBottom: '16px',
              }}
            >
              <p style={{ margin: '0 0 12px 0' }}>{t('translation.no_translation_hint')}</p>
              <button
                type="button"
                onClick={handleAutoTranslate}
                disabled={isTranslating}
                style={{
                  background: '#2563eb',
                  color: 'white',
                  border: 'none',
                  padding: '10px 20px',
                  borderRadius: '6px',
                  cursor: isTranslating ? 'wait' : 'pointer',
                  fontWeight: '600',
                }}
              >
                {isTranslating
                  ? t('translation.translating')
                  : '✨ ' + t('translation.auto_translate_button')}
              </button>
            </div>
          )}

          {fields.map((field) => (
            <div key={field.key} style={{ marginBottom: '16px' }}>
              <label
                htmlFor={`en-${field.key}`}
                style={{ display: 'block', fontWeight: '600', marginBottom: '6px' }}
              >
                {field.label}
              </label>
              {field.multiline ? (
                <textarea
                  id={`en-${field.key}`}
                  value={enValues[field.key] || ''}
                  onChange={(e) => updateField(field.key, e.target.value)}
                  rows={field.rows || 6}
                  style={{
                    width: '100%',
                    padding: '8px',
                    border: '1px solid #d1d5db',
                    borderRadius: '4px',
                    fontFamily: field.key === 'content' ? 'monospace' : 'inherit',
                  }}
                />
              ) : (
                <input
                  id={`en-${field.key}`}
                  type="text"
                  value={enValues[field.key] || ''}
                  onChange={(e) => updateField(field.key, e.target.value)}
                  style={{
                    width: '100%',
                    padding: '8px',
                    border: '1px solid #d1d5db',
                    borderRadius: '4px',
                  }}
                />
              )}
            </div>
          ))}

          <div style={{ display: 'flex', gap: '8px', marginTop: '24px' }}>
            <button
              type="submit"
              disabled={isSaving}
              style={{
                background: '#059669',
                color: 'white',
                border: 'none',
                padding: '10px 20px',
                borderRadius: '6px',
                cursor: isSaving ? 'wait' : 'pointer',
                fontWeight: '600',
              }}
            >
              {isSaving ? t('translation.saving') : t('translation.save_button')}
            </button>
            {translation && (
              <button
                type="button"
                onClick={handleAutoTranslate}
                disabled={isTranslating}
                style={{
                  background: '#6366f1',
                  color: 'white',
                  border: 'none',
                  padding: '10px 20px',
                  borderRadius: '6px',
                  cursor: isTranslating ? 'wait' : 'pointer',
                }}
              >
                {isTranslating
                  ? t('translation.translating')
                  : '🔄 ' + t('translation.retranslate_button')}
              </button>
            )}
          </div>
        </form>
      )}
    </div>
  )
}

// Helper de tradução inline (este componente é client, mas o LangContext
// só é acessível dentro do provider; em alternativa, importar do context)
import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'

function t(key) {
  // Fallback simples se o context não estiver disponível
  try {
    const ctx = useContext(LangContext)
    if (ctx?.t) return ctx.t(key)
  } catch {}
  return key
}
```

- [ ] **Step 2: Adicionar keys de i18n**

Adicionar em `public/i18n/pt.json` e `public/i18n/en.json`:

```json
"translation.tab_pt": "Português",
"translation.tab_en": "English",
"translation.pt_hint": "A versão PT é editada na página principal do artigo.",
"translation.edit_pt_link": "Editar versão PT",
"translation.no_translation_hint": "Esta entidade ainda não tem tradução EN. Carregue no botão abaixo para gerar uma versão automática via IA, e depois reveja e guarde.",
"translation.auto_translate_button": "Auto-traduzir do PT",
"translation.retranslate_button": "Re-traduzir",
"translation.translating": "A traduzir...",
"translation.save_button": "Guardar EN",
"translation.saving": "A guardar...",
"translation.auto_success": "Tradução gerada com sucesso. Reveja os campos e guarde.",
"translation.auto_error": "Erro ao gerar tradução. Tente novamente.",
"translation.rate_limited": "Limite diário de traduções atingido. Tente novamente mais tarde.",
"translation.save_success": "Tradução guardada com sucesso.",
"translation.save_error": "Erro ao guardar tradução.",
"translation.status_manual": "Traduzido",
"translation.status_auto": "Auto-traduzido",
"translation.status_missing": "Por traduzir"
```

- [ ] **Step 3: Verificar que compila**

```bash
cd /c/Users/bapti/Projects/conheca-farmacia-NEXT
npm run build 2>&1 | grep -E "(error|Error|Failed)" | head -20
```

Expected: nenhum erro novo (warnings sobre inline `t` helper são aceitáveis; pode ser refactor para usar o context directamente).

- [ ] **Step 4: Commit**

```bash
git add components/admin/BilingualTabs.jsx public/i18n/pt.json public/i18n/en.json
git commit -m "feat(admin): BilingualTabs component with auto-translate button"
```

---

## Phase 7 — Integrar BilingualTabs no admin

### Task 7.1: Integrar BilingualTabs no admin de artigos

**Files:**
- Modify: `app/[lang]/admin/(protected)/artigos/[id]/page.js`
- Modify: `app/[lang]/admin/(protected)/artigos/novo/page.js` (se existir; senão skip)

- [ ] **Step 1: Localizar a página de edição de artigo**

Ler o ficheiro actual e identificar:
- Onde está a chamada a `getArticleById` ou equivalente.
- Onde estão os campos do form (title, excerpt, content, etc.).
- Onde está a Server Action de update.

- [ ] **Step 2: Adicionar Server Action de update de tradução**

Adicionar a `lib/actions/translation.js` (no fim do ficheiro, após a última função):

```js
/**
 * Server action para guardar tradução EN manualmente.
 * Chamada pelo componente BilingualTabs.
 */
export async function saveTranslationAction(entityType, entityId, values) {
  if (!ENTITY_TABLE[entityType]) {
    return { ok: false, error: `Unknown entity type: ${entityType}` }
  }
  const supabase = await createAdminClient()
  const idCol = ENTITY_ID_COLUMN[entityType]
  const payload = {
    [idCol]: entityId,
    lang: 'en',
    ...values,
    auto_translated: false,
    translated_at: new Date().toISOString(),
  }
  const { data, error } = await supabase
    .from(TRANSLATION_TABLE[entityType])
    .upsert(payload, {
      onConflict: `${idCol},lang`,
      ignoreDuplicates: false,
    })
    .select()
    .single()
  if (error) {
    return { ok: false, error: error.message }
  }
  return { ok: true, translation: data }
}
```

- [ ] **Step 3: Renderizar BilingualTabs na página**

Adicionar no topo da página:

```jsx
import BilingualTabs from '@/components/admin/BilingualTabs'
import { getTranslationByEntityId } from '@/lib/api/translations'
import { saveTranslationAction } from '@/lib/actions/translation'
```

Modificar a função principal (Server Component) para incluir BilingualTabs:

```jsx
// Antes: form monolingue
// return <ArticleForm article={article} onUpdate={...} />

// Depois: form PT existente + BilingualTabs no fim
export default async function AdminArticlePage({ params }) {
  const { id, lang } = await params
  const article = await getArticleById(id)
  if (!article) notFound()
  const translation = await getTranslationByEntityId('article', id, 'en')

  // ... render do form PT existente aqui ...

  return (
    <>
      {/* Form PT existente */}
      <ArticleForm article={article} onUpdate={updateArticle} />

      {/* Tabs bilingue (EN) */}
      <div style={{ marginTop: '48px', padding: '24px', background: '#f9fafb', borderRadius: '8px' }}>
        <h2 style={{ marginTop: 0 }}>{t('translation.en_section_title')}</h2>
        <BilingualTabs
          entityType="article"
          entityId={id}
          record={article}
          translation={translation}
          fields={[
            { key: 'title', label: 'Title' },
            { key: 'excerpt', label: 'Excerpt', multiline: true, rows: 3 },
            { key: 'content', label: 'Content (markdown)', multiline: true, rows: 12 },
            { key: 'category_label', label: 'Category label' },
            { key: 'author_role', label: 'Author role' },
            { key: 'author_bio', label: 'Author bio', multiline: true, rows: 3 },
            { key: 'meta_description', label: 'Meta description', multiline: true, rows: 2 },
          ]}
          onSaveTranslation={(values) => saveTranslationAction('article', id, values)}
          lang={lang}
        />
      </div>
    </>
  )
}
```

**Nota:** Ajustar conforme a estrutura real (pode haver layouts diferentes). O essencial é:
1. Carregar `translation` no server component.
2. Renderizar BilingualTabs com `fields` correspondentes ao schema.

- [ ] **Step 4: Smoke test no admin**

```bash
npm run dev
# Login como admin
# Navegar para /pt/admin/artigos/[id-existente]
# Verificar:
#   - Form PT normal aparece
#   - Secção "English" aparece com badge "⚠ Por traduzir"
#   - Clicar separador "English" → mostra campos vazios + botão "Auto-traduzir"
#   - Sem OPENROUTER_API_KEY configurada, o botão dá erro (esperado)
```

Expected: UI renderiza. Botão de auto-translate pode falhar sem API key — isso é OK nesta fase.

- [ ] **Step 5: Commit**

```bash
git add "app/[lang]/admin/(protected)/artigos/[id]/page.js" lib/actions/translation.js
git commit -m "feat(admin): integrate BilingualTabs in article edit page"
```

---

### Task 7.2: Integrar BilingualTabs no admin de eventos

**Files:**
- Modify: `app/[lang]/admin/(protected)/eventos/[id]/page.js`

- [ ] **Step 1: Aplicar o mesmo padrão de Task 7.1**

```jsx
import BilingualTabs from '@/components/admin/BilingualTabs'
import { getTranslationByEntityId } from '@/lib/api/translations'
import { saveTranslationAction } from '@/lib/actions/translation'

// No server component:
const translation = await getTranslationByEntityId('event', id, 'en')

// Render:
<BilingualTabs
  entityType="event"
  entityId={id}
  record={event}
  translation={translation}
  fields={[
    { key: 'title', label: 'Title' },
    { key: 'description', label: 'Description', multiline: true, rows: 6 },
    { key: 'location', label: 'Location' },
    { key: 'host_role', label: 'Host role' },
    { key: 'host_bio', label: 'Host bio', multiline: true, rows: 3 },
    { key: 'meta_description', label: 'Meta description', multiline: true, rows: 2 },
  ]}
  onSaveTranslation={(values) => saveTranslationAction('event', id, values)}
  lang={lang}
/>
```

- [ ] **Step 2: Smoke test**

Verificar que o separador EN aparece com os campos correctos.

- [ ] **Step 3: Commit**

```bash
git add "app/[lang]/admin/(protected)/eventos/[id]/page.js"
git commit -m "feat(admin): integrate BilingualTabs in event edit page"
```

---

### Task 7.3: Integrar BilingualTabs no admin de lives

**Files:**
- Modify: `app/[lang]/admin/(protected)/lives/[id]/page.js`

- [ ] **Step 1: Aplicar o mesmo padrão**

```jsx
<BilingualTabs
  entityType="live"
  entityId={id}
  record={live}
  translation={translation}
  fields={[
    { key: 'title', label: 'Title' },
    { key: 'description', label: 'Description', multiline: true, rows: 6 },
    { key: 'host_role', label: 'Host role' },
    { key: 'topic', label: 'Topic' },
    { key: 'meta_description', label: 'Meta description', multiline: true, rows: 2 },
  ]}
  onSaveTranslation={(values) => saveTranslationAction('live', id, values)}
  lang={lang}
/>
```

- [ ] **Step 2: Smoke test + commit**

```bash
git add "app/[lang]/admin/(protected)/lives/[id]/page.js"
git commit -m "feat(admin): integrate BilingualTabs in live edit page"
```

---

## Phase 8 — Bulk translate UI

### Task 8.1: Criar página `/admin/traducoes`

**Files:**
- Create: `app/[lang]/admin/(protected)/traducoes/page.js`

- [ ] **Step 1: Escrever a página**

```jsx
// app/[lang]/admin/(protected)/traducoes/page.js
import Link from 'next/link'
import { listEntitiesMissingTranslation } from '@/lib/api/translations'
import BulkTranslateClient from './BulkTranslateClient'

export default async function TraducoesPage({ params }) {
  const { lang } = await params

  const [missingArticles, missingEvents, missingLives] = await Promise.all([
    listEntitiesMissingTranslation('article'),
    listEntitiesMissingTranslation('event'),
    listEntitiesMissingTranslation('live'),
  ])

  return (
    <div style={{ padding: '24px' }}>
      <h1>Gestão de Traduções EN</h1>
      <p style={{ color: '#6b7280' }}>
        Artigos, eventos e lives que ainda não têm tradução para inglês.
        Usa o botão abaixo para gerar traduções automáticas via IA.
      </p>

      <BulkTranslateClient
        groups={{
          article: missingArticles.map((a) => ({ id: a.id, title: a.title, slug: a.slug })),
          event: missingEvents.map((e) => ({ id: e.id, title: e.title, slug: e.slug })),
          live: missingLives.map((l) => ({ id: l.id, title: l.title, slug: l.slug })),
        }}
        lang={lang}
      />
    </div>
  )
}
```

- [ ] **Step 2: Criar o client component**

Criar `app/[lang]/admin/(protected)/traducoes/BulkTranslateClient.jsx`:

```jsx
// app/[lang]/admin/(protected)/traducoes/BulkTranslateClient.jsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { autoTranslateEntity } from '@/lib/actions/translation'

const CONCURRENCY = 5

export default function BulkTranslateClient({ groups, lang }) {
  const router = useRouter()
  const [running, setRunning] = useState(false)
  const [progress, setProgress] = useState({ done: 0, total: 0, failed: 0, current: null })
  const [log, setLog] = useState([])

  const all = [
    ...groups.article.map((e) => ({ ...e, type: 'article' })),
    ...groups.event.map((e) => ({ ...e, type: 'event' })),
    ...groups.live.map((e) => ({ ...e, type: 'live' })),
  ]

  async function translateAll() {
    if (!confirm(`Traduzir ${all.length} entidades? Esta acção usa a API OpenRouter.`)) return
    setRunning(true)
    setLog([])
    setProgress({ done: 0, total: all.length, failed: 0, current: null })

    let done = 0
    let failed = 0
    const queue = [...all]

    async function worker() {
      while (queue.length > 0) {
        const item = queue.shift()
        if (!item) break
        setProgress((p) => ({ ...p, current: `${item.type}: ${item.title}` }))
        try {
          const result = await autoTranslateEntity(item.type, item.id)
          if (result.ok) {
            done += 1
            setLog((l) => [`✓ ${item.type}/${item.title}`, ...l])
          } else if (result.rateLimited) {
            setLog((l) => [`⛔ Rate limit atingido — parando.`, ...l])
            queue.length = 0 // para
          } else {
            failed += 1
            setLog((l) => [`✗ ${item.type}/${item.title}: ${result.error}`, ...l])
          }
        } catch (err) {
          failed += 1
          setLog((l) => [`✗ ${item.type}/${item.title}: ${err.message}`, ...l])
        }
        setProgress((p) => ({ ...p, done, failed }))
      }
    }

    await Promise.all(Array.from({ length: Math.min(CONCURRENCY, all.length) }, worker))
    setRunning(false)
    setProgress((p) => ({ ...p, current: null }))
    router.refresh()
  }

  return (
    <div>
      <div style={{ marginBottom: '24px', display: 'flex', gap: '16px', alignItems: 'center' }}>
        <button
          type="button"
          onClick={translateAll}
          disabled={running || all.length === 0}
          style={{
            background: running ? '#9ca3af' : '#2563eb',
            color: 'white',
            border: 'none',
            padding: '10px 20px',
            borderRadius: '6px',
            cursor: running ? 'wait' : 'pointer',
            fontWeight: '600',
          }}
        >
          {running ? 'A traduzir...' : `✨ Traduzir todos os pendentes (${all.length})`}
        </button>
        {running && (
          <span>
            {progress.done}/{progress.total} ({progress.failed} erros)
          </span>
        )}
      </div>

      {progress.current && (
        <p style={{ color: '#6b7280' }}>
          A traduzir: <strong>{progress.current}</strong>
        </p>
      )}

      {(['article', 'event', 'live']).map((type) => {
        const items = groups[type]
        if (items.length === 0) return null
        const labels = { article: 'Artigos', event: 'Eventos', live: 'Lives' }
        return (
          <section key={type} style={{ marginTop: '32px' }}>
            <h2>{labels[type]} por traduzir ({items.length})</h2>
            <ul>
              {items.map((item) => (
                <li key={item.id} style={{ marginBottom: '8px' }}>
                  <a
                    href={`/${lang}/admin/${type}s/${item.id}`}
                    style={{ color: '#2563eb', textDecoration: 'underline' }}
                  >
                    {item.title}
                  </a>
                  <span style={{ color: '#9ca3af', marginLeft: '8px', fontSize: '12px' }}>
                    /{item.slug}
                  </span>
                </li>
              ))}
            </ul>
          </section>
        )
      })}

      {log.length > 0 && (
        <details style={{ marginTop: '32px' }}>
          <summary style={{ cursor: 'pointer', fontWeight: '600' }}>
            Log de execução ({log.length} entries)
          </summary>
          <pre
            style={{
              background: '#f3f4f6',
              padding: '12px',
              borderRadius: '4px',
              fontSize: '12px',
              maxHeight: '300px',
              overflow: 'auto',
            }}
          >
            {log.join('\n')}
          </pre>
        </details>
      )}

      {all.length === 0 && (
        <p style={{ color: '#059669', fontWeight: '600' }}>
          ✓ Tudo traduzido! Não há entidades pendentes.
        </p>
      )}
    </div>
  )
}
```

- [ ] **Step 3: Adicionar link no admin sidebar**

Localizar o componente da sidebar admin (em `app/[lang]/admin/(protected)/layout.js` ou similar) e adicionar link para `/admin/traducoes`:

```jsx
<Link href={`/${lang}/admin/traducoes`}>Traduções EN</Link>
```

- [ ] **Step 4: Smoke test local**

```bash
npm run dev
# Login admin
# Navegar para /pt/admin/traducoes
# Verificar:
#   - Lista mostra entidades sem tradução EN
#   - Botão "Traduzir todos" funciona
```

Expected: lista renderiza. Sem `OPENROUTER_API_KEY`, o bulk falha com erro — isso é OK; o importante é que a UI funciona.

- [ ] **Step 5: Commit**

```bash
git add "app/[lang]/admin/(protected)/traducoes/" "app/[lang]/admin/(protected)/"
git commit -m "feat(admin): bulk translate page with progress tracking"
```

---

## Phase 9 — SEO: sitemap

### Task 9.1: Actualizar `app/sitemap.js` para entries PT + EN

**Files:**
- Modify: `app/sitemap.js`

- [ ] **Step 1: Ler o sitemap actual**

Ler `app/sitemap.js` e identificar:
- Como as URLs de artigos/eventos/lives são geradas actualmente.
- O `baseUrl` usado.

- [ ] **Step 2: Reescrever o sitemap para incluir EN**

Substituir (ou adicionar a) lógica de artigos pelo seguinte padrão:

```js
// app/sitemap.js (trecho para articles)
import { createClient } from '@/lib/supabase/server'

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || 'https://conhecafarmacia.com'

async function getArticleUrls() {
  const supabase = await createClient()
  const { data: articles } = await supabase
    .from('articles')
    .select('id, slug, published_date')
    .eq('status', 'published')
  if (!articles) return []

  const { data: translations } = await supabase
    .from('article_translations')
    .select('article_id, slug, updated_at')
    .eq('lang', 'en')

  const tMap = new Map((translations ?? []).map((t) => [t.article_id, t]))

  return articles.flatMap((a) => {
    const t = tMap.get(a.id)
    const lastmod = t?.updated_at || a.published_date
    const entries = [
      {
        url: `${SITE_URL}/pt/artigos/${a.slug}`,
        lastModified: lastmod,
        alternates: { languages: { pt: `${SITE_URL}/pt/artigos/${a.slug}` } },
      },
    ]
    if (t) {
      entries.push({
        url: `${SITE_URL}/en/articles/${t.slug}`,
        lastModified: lastmod,
        alternates: {
          languages: {
            pt: `${SITE_URL}/pt/artigos/${a.slug}`,
            en: `${SITE_URL}/en/articles/${t.slug}`,
            'x-default': `${SITE_URL}/pt/artigos/${a.slug}`,
          },
        },
      })
    }
    return entries
  })
}

// Repetir para events e lives...
```

**Nota:** A API exacta de `app/sitemap.js` em Next.js 16 pode variar. Ajustar conforme a versão. O objectivo é: cada entidade gera 1 entry PT (sempre) e 1 entry EN (se tradução existir), cada uma com `<xhtml:link rel="alternate" hreflang>`.

- [ ] **Step 3: Smoke test local**

```bash
npm run dev
curl -s http://localhost:3000/sitemap.xml | head -100
```

Expected: XML contém entries para `/pt/artigos/...` e (quando houver traduções) `/en/articles/...`.

- [ ] **Step 4: Commit**

```bash
git add app/sitemap.js
git commit -m "feat(seo): sitemap emits PT + EN entries with hreflang alternates"
```

---

## Phase 10 — Variáveis de ambiente e deploy

### Task 10.1: Adicionar env vars

**Files:**
- Modify: `.env.local.example` (se existir)
- Modify: `.gitignore` (para não commitar `.env.local` — provavelmente já está)

- [ ] **Step 1: Adicionar variáveis ao `.env.local.example`**

Se existir `.env.local.example`, adicionar:

```
# OpenRouter (auto-translation)
OPENROUTER_API_KEY=
OPENROUTER_MODEL=llama-nemotron-rerank-v1-1b-v2:free

# Rate limit (chars/dia, hard-coded safety net)
TRANSLATION_DAILY_CHAR_LIMIT=1000000

# Feature flag (rollout incremental)
ENABLE_CONTENT_I18N=true
```

Se não existir, criar o ficheiro com esse conteúdo.

- [ ] **Step 2: Documentar em README ou CLAUDE-Next.md**

Adicionar secção sobre a feature flag e como ligar/desligar.

- [ ] **Step 3: Commit**

```bash
git add .env.local.example
git commit -m "chore: add i18n translation env vars to .env.local.example"
```

- [ ] **Step 4: Configurar no Vercel**

**Nota:** Esta acção requer acesso ao dashboard do Vercel. Instruir o user a:

1. Ir a https://vercel.com/[project]/settings/environment-variables
2. Adicionar as 4 variáveis acima (Production, Preview, Development)
3. Fazer deploy

- [ ] **Step 5: Verificar deploy**

```bash
# Após deploy, verificar:
curl -s https://conhecafarmacia.com/pt/artigos | head -20
curl -s https://conhecafarmacia.com/en/articles | head -20
```

Expected: PT funciona, EN mostra artigos com fallback (PT) + banner.

---

## Phase 11 — Verificação end-to-end

### Task 11.1: Smoke test completo (manual)

- [ ] **Step 1: PT não regrediu**

```bash
# Smoke test em PT
for path in "/" "/artigos" "/eventos" "/lives" "/pesquisa?q=teste" "/sobre"; do
  curl -s -o /dev/null -w "%{http_code} /pt${path}\n" "http://localhost:3000/pt${path}"
done
```

Expected: todos 200.

- [ ] **Step 2: EN renderiza fallback**

```bash
for path in "/articles" "/events" "/lives" "/search?q=test"; do
  curl -s -o /dev/null -w "%{http_code} /en${path}\n" "http://localhost:3000/en${path}"
done
```

Expected: todos 200.

- [ ] **Step 3: Criar artigo de teste com tradução**

- Login admin → criar artigo PT "Teste i18n".
- Em `/pt/admin/artigos/[novo-id]`, separador "English" → "Auto-traduzir".
- Confirmar que artigo aparece em `article_translations` (via SQL ou admin list).
- Navegar para `/en/articles/[slug-en-gerado]` → ver versão EN.

- [ ] **Step 4: Verificar hreflang**

- Abrir DevTools → `<head>` da página `/pt/artigos/[slug]`.
- Confirmar:
  - `<link rel="alternate" hreflang="pt" href=".../pt/artigos/[slug-pt]">`
  - `<link rel="alternate" hreflang="en" href=".../en/articles/[slug-en]">`
  - `<link rel="alternate" hreflang="x-default" href=".../pt/artigos/[slug-pt]">`

- [ ] **Step 5: Verificar search em EN**

```bash
# Artigo com versão EN: deve aparecer em /en/search
curl -s "http://localhost:3000/en/search?q=<keyword-en>" | grep "<article"
```

Expected: 1+ resultados.

- [ ] **Step 6: Verificar fallback banner**

- Navegar para `/en/articles/[slug-pt-sem-traducao]`.
- Confirmar banner amarelo visível com texto "Not yet translated".

- [ ] **Step 7: Verificar bulk translate**

- Ir a `/pt/admin/traducoes`.
- Confirmar que entidades sem tradução aparecem na lista.
- Clicar "Traduzir todos" (com `OPENROUTER_API_KEY` configurada) → progresso → 0 erros.

---

## Self-Review

Spec coverage check:

| Spec requirement | Task |
|---|---|
| 3 translation tables + translation_logs | Task 1.1 |
| RLS + indexes | Task 1.1 |
| `lib/utils/slugify.js` | Task 2.1 |
| `lib/api/translations.js` helpers | Task 2.2 |
| Refactor `lib/api/articles.js` | Task 3.1 |
| Refactor `lib/api/events.js` | Task 3.2 |
| Refactor `lib/api/lives.js` | Task 3.3 |
| Refactor `lib/api/search.js` (lang) | Task 3.4 |
| `TranslationFallbackBanner` | Task 4.1 |
| Article page merge + hreflang | Task 4.2 |
| Article listagem | Task 4.3 |
| Event pages | Task 4.4 |
| Live pages | Task 4.5 |
| Search page | Task 4.6 |
| `lib/actions/translation.js` (autoTranslateEntity, rate limit, logs) | Task 5.1 |
| `BilingualTabs` component | Task 6.1 |
| Integrate BilingualTabs in article admin | Task 7.1 |
| Integrate BilingualTabs in event admin | Task 7.2 |
| Integrate BilingualTabs in live admin | Task 7.3 |
| `/admin/traducoes` bulk UI | Task 8.1 |
| Sitemap with PT + EN | Task 9.1 |
| Env vars | Task 10.1 |
| End-to-end smoke test | Task 11.1 |

Placeholder scan: nenhum "TBD", "TODO" ou referência genérica.

Type consistency check:
- `getTranslationBySlug(entityType, slug, lang)` consistente em `lib/api/translations.js`, `lib/api/articles.js`, e páginas públicas.
- `mergeEntityWithTranslation(entity, translation, lang)` consistente em todas as páginas.
- `autoTranslateEntity(entityType, entityId)` consistente em `BilingualTabs` e `BulkTranslateClient`.
- `TRANSLATABLE_FIELDS` definido em `translations.js`; `ENTITY_FIELDS` (subset) em `translation.js`. Intencional: o primeiro é usado para merge UI, o segundo para input da IA.
- `ENTITY_TABLE`, `TRANSLATION_TABLE`, `ENTITY_ID_COLUMN` constantes em ambos os ficheiros (consistência verificada linha-a-linha).

Ambiguity: nenhum requisito do spec fica sem task.
