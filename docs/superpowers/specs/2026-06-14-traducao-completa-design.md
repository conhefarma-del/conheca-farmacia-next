# Tradução Completa do Conteúdo (PT ↔ EN)

**Data:** 2026-06-14
**Estado:** Design aprovado
**Autor:** Brainstorming com user

## Context

O website Conheça Farmácia tem actualmente suporte para duas línguas (PT e EN), mas apenas o "chrome" do site (nav, footer, botões, labels) está traduzido — controlado por ficheiros JSON em `public/i18n/{lang}.json` e `LangContext`.

O **conteúdo original** (artigos, eventos, lives) é guardado na base de dados Supabase com colunas em português e **nunca é traduzido**. Quando um visitante acede a `/en/artigos/[slug]`, vê os títulos e o body em PT dentro de uma UI em inglês — o que é confuso e fraco para SEO internacional.

**Resultado esperado:** o website mostra conteúdo 100% em inglês quando o utilizador muda para `/en/*`, com fallback elegante para PT quando ainda não há tradução. O admin pode criar traduções via auto-tradução assistida (OpenRouter) e revê-las antes de publicar.

**Decisões-chave (do brainstorming):**
- Tudo se traduz: texto corrido, metadados, taxonomia, roles/bios de autores
- **Nomes próprios** (`author_name`, `host_name`) **NÃO se traduzem** — copiados do PT
- Quando falta tradução EN, mostra chrome EN + body PT com aviso
- Modelo de dados: **tabela de traduções** (não colunas paralelas)
- Workflow admin: **auto-tradução com revisão** (OpenRouter)
- Slug EN **auto-gerado** pela IA, editável
- Pesquisa actua **na língua do URL**
- hreflang **completo** para SEO
- **Sem limite** de uso (com rate-limit hard-coded de segurança)
- **Bulk translate** via UI admin
- UX admin: **separador bilingue** (PT | EN) no mesmo form

## Architecture

### 1. Camada de dados — 3 tabelas de tradução

Criar 3 tabelas novas (uma por entidade de conteúdo), todas com a mesma estrutura de PK composta `(entity_id, lang)`.

#### `article_translations`
| Coluna | Tipo | Notas |
|---|---|---|
| `article_id` | `UUID NOT NULL` | FK → `articles.id` ON DELETE CASCADE |
| `lang` | `CHAR(2) NOT NULL` | `'pt'` ou `'en'` |
| `slug` | `TEXT NOT NULL` | UNIQUE dentro de `(slug, lang)` |
| `title` | `TEXT NOT NULL` | |
| `excerpt` | `TEXT` | |
| `content` | `TEXT` | markdown |
| `category` | `TEXT` | slug partilhado PT↔EN |
| `category_label` | `TEXT` | label traduzido |
| `author_name` | `TEXT` | nome próprio (NÃO traduzido, copiado do PT) |
| `author_role` | `TEXT` | traduzido |
| `author_bio` | `TEXT` | traduzido |
| `meta_description` | `TEXT` | para SEO |
| `auto_translated` | `BOOLEAN DEFAULT TRUE` | |
| `translated_at` | `TIMESTAMPTZ` | |
| `created_at` | `TIMESTAMPTZ DEFAULT NOW()` | |
| `updated_at` | `TIMESTAMPTZ DEFAULT NOW()` | |
| **PK** | | `(article_id, lang)` |

#### `event_translations`
Mesma estrutura. Campos específicos: `location`, `description`, `host_name`, `host_role`, `host_bio`, `meta_description`. PK: `(event_id, lang)`.

#### `live_translations`
Mesma estrutura. Campos específicos: `host_name`, `host_role`, `description`, `topic`, `meta_description`. PK: `(live_id, lang)`.

#### `translation_logs` (auditoria)
| Coluna | Tipo |
|---|---|
| `id` | `UUID PRIMARY KEY` |
| `entity_type` | `TEXT` (`'article'`, `'event'`, `'live'`) |
| `entity_id` | `UUID` |
| `lang` | `CHAR(2)` |
| `char_count` | `INTEGER` |
| `model` | `TEXT` (ex: `'anthropic/claude-3.5-sonnet'`) |
| `cost_estimate` | `NUMERIC(10, 6)` |
| `created_at` | `TIMESTAMPTZ DEFAULT NOW()` |

#### RLS
- **SELECT** público em todas as 3 tabelas de tradução (qualquer pessoa lê traduções).
- **INSERT/UPDATE/DELETE** apenas para `admin_users` (mesma policy que `articles`/`events`/`lives`).

#### Indexes
- `article_translations(slug, lang)` UNIQUE
- `article_translations(article_id)`
- Idem para `event_translations` e `live_translations`.
- `translation_logs(created_at)` para queries de rate limit.

### 2. Camada de leitura (refactor)

#### `lib/api/articles.js`
**API nova (refactor):**
```js
// Antes
getArticleBySlug(slug) → article | null

// Depois
getArticleBySlug(slug, lang) → { article, translation } | null
```
- `article` = linha de `articles` (PT base).
- `translation` = linha de `article_translations` (ou `null`).
- Helper `mergeArticleWithTranslation(article, translation, lang)` devolve um objecto unificado para a UI.

**Listagem:**
- `listArticles(lang)` faz LEFT JOIN com `article_translations` filtrado por `lang`.
- Helper escolhe o título (e demais campos textuais) de `translation` se existir, senão de `article`.

**Search:** `searchArticles(query, lang)` — pesquisa nas colunas da língua do URL apenas (PT ou EN, não ambos).

#### `lib/api/events.js` e `lib/api/lives.js`
Mesmo padrão que `articles.js`.

#### Páginas públicas
Cada `[slug]/page.js` recebe `(params)` com `slug` e `lang`. Resolve a entidade, faz merge com tradução, fallback em PT quando não há tradução.

**`generateMetadata`** emite:
- `<title>` na língua do URL.
- `<link rel="alternate" hreflang="pt" href=".../pt/artigos/[slug-pt]">`
- `<link rel="alternate" hreflang="en" href=".../en/articles/[slug-en]">` (apenas se tradução EN existe)
- `<link rel="alternate" hreflang="x-default" href=".../pt/artigos/[slug-pt]">`

**Banner de fallback (apenas em `/en/*`):**
- Se `lang === 'en'` e `translation` é `null`, mostra banner amarelo discreto no topo do conteúdo:
  > "This article is not yet translated to English. Showing the original Portuguese version."
- Para admins autenticados, link adicional: "Translate this article" → abre a página de edição admin.

### 3. Camada de admin (auto-tradução + UX)

#### Componente reutilizável: `components/admin/BilingualTabs.jsx`
- Props: `record` (linha PT), `translation` (linha EN ou null), `fields` (config de campos), `onSave(translation)`, `onAutoTranslate()`.
- Renderiza tabs "Português (PT)" | "English (EN)".
- Separador PT: editável (form actual, sem mudanças).
- Separador EN:
  - Pré-preenchido se `translation` existe.
  - Vazio + botão grande "✨ Auto-traduzir do PT" se `translation === null`.
  - Badge no canto: `✓ Traduzido` / `⚠ Por traduzir` / `🤖 Auto-traduzido`.
- Cada separador tem botão "Guardar" próprio (não obriga gravar os dois).

Aplicar o componente em:
- `app/[lang]/admin/(protected)/artigos/[id]/page.js` (form de artigo)
- Idem para eventos e lives.

#### Server Action: `lib/actions/translation.js`
**Função principal:** `autoTranslateEntity(entityType, entityId, sourceLang, targetLang)`
- Verifica permissão admin.
- Lê registo PT da entidade (`articles`/`events`/`lives`).
- Monta prompt OpenRouter:
  ```
  System: "Tradutor técnico de farmacologia PT→EN. Mantém terminologia científica em inglês. Copia nomes próprios sem traduzir. Responde em JSON com os campos fornecidos."
  User: JSON com { field1: "valor PT", field2: "valor PT", ... }
  ```
- Chama `https://openrouter.ai/api/v1/chat/completions`:
  - `model: 'anthropic/claude-3.5-sonnet'` (default, configurável via env).
  - `response_format: { type: 'json_object' }`.
  - Timeout: 30s.
- Parse JSON → insere em `article_translations` (ou events/lives) com `auto_translated = TRUE`, `translated_at = NOW()`.
- Slug EN é auto-gerado por chamada separada: `generateEnglishSlug(portugueseSlug)` via OpenRouter; fallback para `slugify()` (lowercase, sem acentos, kebab-case).
- Garante `slug_en` único — se colidir, sufixa `-2`, `-3`.
- Grava entrada em `translation_logs` (char_count, model, cost_estimate).
- Verifica rate limit hard-coded (1M chars/dia global) antes de chamar API.

**Configuração de campos por entidade** (constante no mesmo ficheiro):
```js
const ENTITY_FIELDS = {
  article: ['title', 'excerpt', 'content', 'category_label', 'author_role', 'author_bio', 'meta_description'],
  event:   ['title', 'description', 'location', 'host_name', 'host_role', 'host_bio', 'meta_description'],
  live:    ['title', 'description', 'host_name', 'host_role', 'topic', 'meta_description'],
}
```

#### Bulk translate UI
**Nova página:** `app/[lang]/admin/(protected)/traducoes/page.js`
- Lista todas as entidades agrupadas (Artigos / Eventos / Lives).
- Para cada uma: título PT + estado da tradução (`✓ EN` / `⚠ Por traduzir`) + botão "Traduzir agora" / "Re-traduzir".
- Botão global "Traduzir todos os pendentes" (com confirmação).
- Barra de progresso + gestão de erros (retry por item, não aborta batch todo).
- Concorrência: 5 em paralelo (configurável).

### 4. SEO

#### `app/sitemap.js`
- Para cada entidade, emite 2 entries (PT + EN) se tradução EN existe, 1 entry (PT) se não.
- `<xhtml:link rel="alternate" hreflang="..."/>` em cada entry.

#### `app/robots.js`
- Mantém-se inalterado.

### 5. Variáveis de ambiente (Vercel + Supabase)

```
OPENROUTER_API_KEY=<chave>           # Server Action
OPENROUTER_MODEL=anthropic/claude-3.5-sonnet  # configurável
TRANSLATION_DAILY_CHAR_LIMIT=1000000  # rate limit hard-coded
ENABLE_CONTENT_I18N=true             # feature flag
```

## Data Flow

### Criação de artigo com tradução
1. Admin cria artigo em PT no `/admin/artigos/novo` → grava em `articles`.
2. Admin edita artigo → separador EN → clica "Auto-traduzir do PT".
3. Server Action lê artigo PT, chama OpenRouter, parse JSON, gera slug EN, insere em `article_translations` com `auto_translated = TRUE`.
4. Admin revisa e edita campos EN → clica "Guardar EN" → actualiza `article_translations`.
5. Visita anónima em `/en/articles/[slug-en]` → página lê `article_translations` WHERE `slug = ?` AND `lang = 'en'` → renderiza versão EN.

### Visitante em artigo sem tradução EN
1. Visita anónima em `/en/articles/[slug-en]` → query devolve `null` em `article_translations`.
2. Helper `mergeArticleWithTranslation(article, null, 'en')` devolve campos PT.
3. Página renderiza com PT + banner amarelo "Not yet translated".

### Search
1. Utilizador em `/en/pesquisa?q=diabetes` → `searchArticles('diabetes', 'en')`.
2. Query SQL: `SELECT ... FROM articles a LEFT JOIN article_translations t ON t.article_id = a.id AND t.lang = 'en' WHERE t.title ILIKE '%diabetes%' OR t.excerpt ILIKE '%diabetes%'`.
3. Sem fallback para PT — só artigos com versão EN aparecem em `/en/search`.

## Critical Files

### A criar
- `supabase/migrations/015_i18n_translations.sql` — schema + RLS + indexes
- `lib/actions/translation.js` — `autoTranslateEntity`, `generateEnglishSlug`, rate limit
- `components/admin/BilingualTabs.jsx` — componente reutilizável
- `app/[lang]/admin/(protected)/traducoes/page.js` — bulk translate UI

### A modificar
- `lib/api/articles.js` — adicionar parâmetro `lang` em todas as funções
- `lib/api/events.js` — idem
- `lib/api/lives.js` — idem
- `lib/api/search.js` — filtrar por lingua do URL
- `app/[lang]/(public)/artigos/page.js` — listagem com merge
- `app/[lang]/(public)/artigos/[slug]/page.js` — merge + hreflang + banner
- `app/[lang]/(public)/eventos/page.js` e `[slug]/page.js` — idem
- `app/[lang]/(public)/lives/page.js` e `[slug]/page.js` — idem
- `app/[lang]/(public)/pesquisa/page.js` — passa `lang` para search
- `app/sitemap.js` — entries PT + EN por entidade
- `app/[lang]/admin/(protected)/artigos/[id]/page.js` — usar `BilingualTabs`
- Idem para `eventos/[id]` e `lives/[id]`

### A reutilizar (não modificar)
- `lib/supabase/server.js`, `lib/supabase/admin.js` — clientes existentes
- `lib/i18n.js` — chrome translations (não muda)
- `lib/security.js` — escape helpers
- `proxy.js` — não muda

## Verification

### Local (npm run dev)
1. **Smoke test PT:** `/pt/artigos/[slug]` mostra exactamente como antes (sem regressão).
2. **Tradução nova:** cria artigo PT → auto-traduzir → edita EN → grava. Verificar `/en/articles/[slug-en]` mostra EN.
3. **Banner fallback:** artigo sem tradução EN → `/en/articles/[slug-en]` mostra PT + banner.
4. **Search EN:** `/en/pesquisa?q=termo` só mostra artigos com versão EN.
5. **Search PT:** `/pt/pesquisa?q=termo` mostra todos os artigos (com ou sem EN).
6. **Bulk translate:** `/admin/traducoes` → "Traduzir pendentes" → progresso → 0 erros.
7. **Slug collision:** criar 2 artigos PT com slug igual, traduzir ambos → verificar sufixos `-2`.
8. **Rate limit:** simular (ou forçar) 1M+ chars/dia → ver erro.

### Build
- `npm run build` passa sem erros.
- Lint passa.

### SEO
- `curl /pt/artigos/[slug-pt]` → ver `<link rel="alternate" hreflang="en" href=".../en/articles/[slug-en]">` no head.
- `curl /sitemap.xml` → ver 2 entries por artigo traduzido.

### Deploy (Vercel)
- Env vars configuradas: `OPENROUTER_API_KEY`, `OPENROUTER_MODEL`, `TRANSLATION_DAILY_CHAR_LIMIT`, `ENABLE_CONTENT_I18N`.
- Feature flag `ENABLE_CONTENT_I18N=false` no primeiro deploy; liga-se após smoke test.

## Rollout Sequence

1. **Migration SQL** — corre na BD via `supabase db push`. **Sem mudança de comportamento** (tabelas novas, vazias).
2. **Refactor camada de leitura** — `lib/api/*` + páginas públicas. **Feature flag `ENABLE_CONTENT_I18N=false`** no início → site PT funciona como antes. Activar flag → EN lê fallback PT (sem tradução real ainda).
3. **Server Action + BilingualTabs** — admin pode criar traduções (só admin autenticado usa).
4. **Bulk translate UI** — admin faz backfill de artigos existentes.
5. **SEO (hreflang, sitemap)** — activa para Google começar a indexar EN.
6. **Testes e2e** — fluxo completo.

## YAGNI (Não inclui nesta versão)

- Tradução de imagens (alt text) — adicionar depois
- Tradução automática de comentários / user-generated content
- 3ª língua (espanhol, francês) — schema suporta, UI não
- Glossário editável via UI (hard-coded no system prompt)
- Preview lado-a-lado PT/EN no admin
- Cache de traduções
- CDN separado para EN
- Export/import de traduções em massa (CSV)
- Versionamento de traduções (histórico de alterações)
- Webhooks OpenRouter para tradução assíncrona
