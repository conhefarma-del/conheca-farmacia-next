# Artigos Científicos — Plano de Implementação (Atualizado 2026-05-23)

> Plano atualizado do original de 2026-05-09. Mudanças principais: Supabase desde início, CRUD admin completo, layout similar a artigo.html, conformidade SECURITY_GUIDELINES.md.

## Contexto

O plano original (9 de maio) propunha armazenamento JSON local e sem admin CMS. Entretanto, o projeto evoluiu significativamente: CMS admin completo para artigos/eventos/lives, API layer com Supabase, SEO centralizado, CSP sem inline scripts, featured sections, etc.

Este plano atualiza a implementação para: **Supabase desde início + CRUD completo no admin**, seguindo os padrões já estabelecidos no projeto.

---

## Decisões Atualizadas vs. Plano Original

| Aspeto | Plano Original (9 Maio) | Plano Atualizado |
|--------|------------------------|-----------------|
| Armazenamento | JSON local → Supabase depois | Supabase desde início |
| Admin CMS | Nenhum | CRUD completo (list/new/edit) |
| Layout detalhe | Layout académico dedicado | Similar ao artigo.html (2/3 + 1/3 sidebar) |
| Categorias | 5 categorias | 5 categorias (inalterado) |
| SEO | Highwire Press meta tags | Highwire Press + seo.js existente |
| CSP | Não considerado | Sem inline scripts (padrão projeto) |

---

## Data Schema

### Tabela Supabase `scientific_articles`

| Coluna | Tipo | Notas |
|--------|------|-------|
| id | UUID | PK, gen_random_uuid() |
| slug | TEXT | UNIQUE, NOT NULL |
| title | TEXT | NOT NULL |
| abstract | TEXT | Resumo académico (150-300 palavras) |
| excerpt | TEXT | Resumo curto para cards |
| keywords | TEXT[] | Palavras-chave |
| category | TEXT | NOT NULL, CHECK |
| category_label | TEXT | NOT NULL |
| lang | TEXT | DEFAULT 'pt', CHECK ('pt', 'en') |
| doi | TEXT | Opcional |
| authors | JSONB | Array de autores com afiliações |
| content | TEXT | Markdown completo |
| references_arr | TEXT[] | Referências bibliográficas |
| image_url | TEXT | |
| status | TEXT | NOT NULL, CHECK ('draft', 'published') |
| featured | BOOLEAN | DEFAULT false |
| read_time | INTEGER | |
| view_count | INTEGER | DEFAULT 0 |
| published_at | TIMESTAMPTZ | |
| created_at | TIMESTAMPTZ | DEFAULT now() |
| updated_at | TIMESTAMPTZ | DEFAULT now() |

### Estrutura JSONB `authors`

```json
[
  {
    "name": "Dr. João Pedro",
    "institution": "universidade-de-luanda",
    "institutionLabel": "Universidade de Luanda",
    "department": "Faculdade de Farmácia",
    "role": "Farmacêutico · Investigador Principal",
    "avatar": "JP",
    "avatarBg": "#006171",
    "corresponding": true
  }
]
```

### Categorias

| Key | Label |
|-----|-------|
| farmacologia-clinica | Farmacologia Clínica |
| saude-publica | Saúde Pública |
| farmacovigilancia | Farmacovigilância |
| educacao-farmaceutica | Educação Farmacêutica |
| fitoterapia | Fitoterapia |

### Category Colors

```js
const categoryColors = {
  "farmacologia-clinica": "#0a844f",
  "saude-publica": "#006171",
  "farmacovigilancia": "#ff6c23",
  "educacao-farmaceutica": "#002a32",
  "fitoterapia": "#6b7280",
};
```

---

## Tarefa 1: Migration SQL — Tabela `scientific_articles`

**Ficheiro:** `src/migrations/017-create-scientific-articles.sql`

```sql
CREATE TABLE IF NOT EXISTS scientific_articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  abstract TEXT,
  excerpt TEXT,
  keywords TEXT[],
  category TEXT NOT NULL,
  category_label TEXT NOT NULL,
  lang TEXT NOT NULL DEFAULT 'pt' CHECK (lang IN ('pt', 'en')),
  doi TEXT,
  authors JSONB NOT NULL DEFAULT '[]',
  content TEXT,
  references_arr TEXT[],
  image_url TEXT,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  featured BOOLEAN DEFAULT false,
  read_time INTEGER,
  view_count INTEGER DEFAULT 0,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE scientific_articles ENABLE ROW LEVEL SECURITY;

-- Público lê publicados
CREATE POLICY "Public read published scientific articles"
  ON scientific_articles FOR SELECT
  USING (status = 'published');

-- Admins fazem tudo
CREATE POLICY "Admins full access scientific articles"
  ON scientific_articles FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- Index para performance
CREATE INDEX idx_scientific_articles_status ON scientific_articles(status);
CREATE INDEX idx_scientific_articles_category ON scientific_articles(category);
CREATE INDEX idx_scientific_articles_lang ON scientific_articles(lang);
CREATE INDEX idx_scientific_articles_featured ON scientific_articles(featured) WHERE featured = true;
```

Aplicar via MCP `apply_migration`.

---

## Verificação de Segurança (SECURITY_GUIDELINES.md)

| Guideline | Aplicação |
|-----------|-----------|
| SEC-XSS-01 | Todas as interpolações innerHTML usam `escapeHtml()` (Tarefas 7, 9) |
| SEC-XSS-02 | Atributos HTML usam `escapeAttr()` (Tarefas 7, 9, 11) |
| SEC-XSS-03 | URLs validadas com `validateUrl()` (Tarefa 9) |
| SEC-XSS-04 | Slugs codificados com `encodeURIComponent()` (Tarefas 7, 9) |
| SEC-XSS-05 | DOMPurify com hook `afterSanitizeAttributes` (Tarefa 9) |
| SEC-API-01 | Normalização camelCase (Tarefa 2) |
| SEC-API-02 | `deleteScientificArticle()` com verificação de sessão (Tarefa 2) |
| SEC-API-03 | SELECT público com colunas explícitas (Tarefa 2) |
| SEC-API-04 | Cliente Supabase via `config.js` (Tarefa 2) |
| SEC-ATH-02 | Admin pages usam `checkAuth()` de `auth.js` (Tarefa 11) |
| SEC-ATH-03 | `initIdleTimeout()` em todas as páginas admin (Tarefa 11) |
| SEC-HRD-02 | Scripts CDN com `integrity` + `crossorigin` (Tarefa 8) |
| SEC-FRM-03 | Links `target="_blank"` com `rel="noopener noreferrer"` (Tarefas 6, 8) |
| SEC-AUD-01 | Colunas audit na tabela (Tarefa 1) |
| SEC-AUD-02 | Usar `logger` em vez de `console.log` (Tarefas 7, 9) |
| SEC-AUD-03 | Sem `window.*` com chaves (Tarefas 7, 9) |
| SEC-SQL-01 | RLS: público só lê `status='published'` (Tarefa 1) |
| SEC-SQL-03 | CHECK + NOT NULL constraints (Tarefa 1) |
| SEC-CSS-01 | Sem injeção de `<style>` via innerHTML (Tarefa 5) |
| SEC-CSS-02 | Variáveis CSS do tema (Tarefa 5) |

---

## Tarefa 2: API Functions em `src/lib/api.js`

Adicionar funções seguindo o padrão existente:

```js
// --- Scientific Articles ---

function normalizeScientificArticle(row) {
  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    abstract: row.abstract,
    excerpt: row.excerpt,
    keywords: row.keywords || [],
    category: row.category,
    categoryLabel: row.category_label,
    lang: row.lang || 'pt',
    doi: row.doi || '',
    authors: row.authors || [],
    content: row.content,
    references: row.references_arr || [],
    image: row.image_url,
    status: row.status,
    featured: row.featured || false,
    readTime: row.read_time,
    viewCount: row.view_count || 0,
    publishedAt: row.published_at,
    date: row.published_at ? row.published_at.split('T')[0] : null,
  };
}

export async function getScientificArticles() {
  // SEC-API-03: SELECT explícito, não SELECT *
  const SELECT_COLS = 'id, slug, title, abstract, excerpt, keywords, category, category_label, lang, doi, authors, image_url, status, featured, read_time, view_count, published_at';
  // SELECT ... FROM scientific_articles WHERE status='published' ORDER BY published_at DESC
}
export async function getScientificArticleBySlug(slug) {
  // SELECT com todas as colunas incluindo content, references_arr
  // WHERE slug=... AND status='published' .single()
}
export async function getFeaturedScientificArticles(limit = 3) {
  // SELECT_COLS + WHERE featured=true AND status='published' LIMIT limit
}
export async function getAllScientificArticles() {
  // Admin: SELECT * ORDER BY created_at DESC (sem filtro status)
}
export async function deleteScientificArticle(id) {
  // SEC-API-02: Verificar sessão antes de eliminar
  // const { data: { session } } = await supabaseClient.auth.getSession();
  // if (!session) throw new Error('Unauthorized: login required');
  // supabaseClient.from('scientific_articles').delete().eq('id', id)
}
```

---

## Tarefa 3: Fallback data em `src/lib/fallback-data.js`

- **Ficheiro:** `src/content/scientific-articles-catalog.json` — 2 artigos de exemplo (1 PT, 1 EN)
- **Ficheiro:** `src/lib/fallback-data.js` — adicionar `getFallbackScientificArticles()` e `getFallbackScientificArticleBySlug()`

---

## Tarefa 4: Banner em `artigos.html`

Inserir banner "Artigos Científicos" entre a secção de filtros e o grid (após `</section>` do filtro, ~linha 275).

HTML do banner (sem inline styles/scripts, CSP-safe):
```html
<section class="scientific-articles-banner">
  <div class="container-center">
    <a href="cientificos.html" class="sci-banner-link">
      <div class="sci-banner-content">
        <div class="sci-banner-icon"><!-- SVG livro --></div>
        <div class="sci-banner-text">
          <h2 class="sci-banner-title">Artigos Científicos</h2>
          <p class="sci-banner-desc">Publicações académicas com revisão, referências e citações exportáveis</p>
        </div>
        <div class="sci-banner-arrow"><!-- SVG seta --></div>
      </div>
    </a>
  </div>
</section>
```

---

## Tarefa 5: CSS — Estilos científicos em `src/input.css`

Adicionar no final:

1. **Banner** (`.scientific-articles-banner`, `.sci-banner-*`)
2. **Cards académicos** (`.sci-card`, `.sci-card-category`, `.sci-card-title`, etc.)
3. **Detalhe** (`.sci-abstract-box`, `.sci-keywords-*`, `.sci-authors-grid`, `.sci-author-card`, etc.)
4. **Citações** (`.sci-citation-widget`, `.sci-citation-tab`, `.sci-citation-text`, `.sci-citation-copy-btn`)
5. **Referências** (`.sci-references-list`, `.sci-reference-item`)
6. **Corpo do artigo** (`.sci-article-body h2`, etc.)
7. **Botões de idioma** (`.sci-lang-btn`)
8. **Dark mode** — usar `html.dark` (padrão do projeto)

Reutilizar variáveis CSS: `--color-brand-accent`, `--color-brand-deep`, `--color-brand-bg-alt`, `--color-brand-divider`, `--shadow-soft`.

---

## Tarefa 6: Página de listagem `cientificos.html`

**Ficheiro novo:** `cientificos.html`

Copiar estrutura de `artigos.html` (header, drawer, footer, scripts) com conteúdo próprio:
- Hero: "Artigos Científicos" com breadcrumb ← Artigos
- Search + filtros de categoria + filtros de idioma (PT/EN)
- Grid de cards académicos (sem imagem hero, com autores, keywords, DOI)
- CTA "Voltar para Artigos"
- **SEC-FRM-03:** Links `target="_blank"` com `rel="noopener noreferrer"`

**Scripts:** `<script type="module" src="/src/scientific-articles-logic.js"></script>` (CSP-safe)

**Vite config:** `cientificos: resolve(__dirname, "cientificos.html")`

---

## Tarefa 7: Lógica de listagem `src/scientific-articles-logic.js`

**Ficheiro novo**

- Import `getScientificArticles` de `api.js`
- Import `escapeHtml` de `security.js` — SEC-XSS-01
- SEC-XSS-04: Slugs com `encodeURIComponent()`
- Filtros por categoria (5), idioma (PT/EN), search
- Cards académicos com autores, keywords, DOI

---

## Tarefa 8: Página de detalhe `artigo-cientifico.html`

**Ficheiro novo**

Layout similar a `artigo.html` (2/3 + 1/3 sidebar):
- Hero: category badge, lang badge, título, autores inline, data, readtime
- Abstract box (borda à esquerda)
- Keywords como tags
- Autores grid (avatar, nome, afiliação, departamento, correspondente)
- Corpo Markdown com DOMPurify
- Sidebar: widget citação (ABNT/APA/Vancouver), TOC, keywords
- Referências bibliográficas
- Breadcrumb + SEO (seo.js + Highwire Press)
- Share buttons
- Sem carrossel de artigos relacionados

**Scripts CDN:** marked.js + DOMPurify com SRI hashes de `artigo.html` (SEC-HRD-02)

**Vite config:** `artigoCientifico: resolve(__dirname, "artigo-cientifico.html")`

---

## Tarefa 9: Lógica de detalhe `src/scientific-article-detail.js`

**Ficheiro novo**

- Imports: `getScientificArticleBySlug`, `formatCitation`, `copyToClipboard`, `seo.js`, `escapeHtml`, `renderBreadcrumb`
- Carregar artigo por `?id=slug`
- SEC-XSS-01: `escapeHtml()` em TODAS as interpolações
- SEC-XSS-02: `escapeAttr()` em atributos
- SEC-XSS-04: `encodeURIComponent()` em slugs
- SEC-XSS-05: DOMPurify hook (copiar de `article-detail.js`)
- SEC-AUD-02: `logger` em vez de `console.log`
- Highwire Press meta tags injetadas via JS
- Track page view via `increment_view_count`

---

## Tarefa 10: Utilitário de citações `src/lib/citation-formatter.js`

**Ficheiro novo**

```js
export function formatCitation(article, style) { /* "abnt" | "apa" | "vancouver" */ }
export async function copyToClipboard(text) { /* fallback textarea + clipboard API */ }
```

- ABNT: `SOBRENOME, N. Título. Conheça Farmácia, Ano. DOI ou Disponível em: URL`
- APA: `Last, F. M. (Year). Title. Conheça Farmácia. DOI ou URL`
- Vancouver: `Last FM. Title. Conheça Farmácia. Year. doi:X ou Available from: URL`
- DOI vazio → URL como fallback

---

## Tarefa 11: Admin CMS — CRUD Artigos Científicos

### 11a: Listagem `src/admin/cientificos/index.html`
- SEC-ATH-02: `checkAuth` de `../lib/auth.js`
- SEC-ATH-03: `initIdleTimeout()`
- SEC-API-04: `supabaseClient` de `../../config.js`
- Tabela, filtros, pesquisa, botões editar/eliminar

### 11b: Criar `src/admin/cientificos/new.html`
- Formulário: título, slug, categoria, idioma, status, featured, abstract, excerpt, meta_description, autores (dinâmico), keywords, conteúdo Markdown, DOI, referências, imagem, preview

### 11c: Editar `src/admin/cientificos/edit.html`
- Mesmo formulário com dados pré-carregados

### 11d: CSS admin
- `.sci-author-entry` — styling autores no formulário

### 11e: Vite config
```
adminCientificosIndex, adminCientificosNew, adminCientificosEdit
```

---

## Tarefa 12: SEO Académico — Highwire Press Meta Tags

Integrado na Tarefa 9 (`src/scientific-article-detail.js`):

```js
function injectScholarMetaTags(article) {
  document.querySelectorAll('meta[name^="citation_"]').forEach(m => m.remove());
  const tags = [
    { name: 'citation_title', content: article.title },
    { name: 'citation_publication_date', content: article.date?.replace(/-/g, '/') },
    { name: 'citation_journal_title', content: 'Conheça Farmácia' },
    { name: 'citation_language', content: article.lang },
    { name: 'citation_publisher', content: 'Conheça Farmácia' },
  ];
  article.authors.forEach(a => tags.push({ name: 'citation_author', content: a.name }));
  if (article.doi) tags.push({ name: 'citation_doi', content: article.doi });
  article.keywords.forEach(kw => tags.push({ name: 'citation_keywords', content: kw }));
  tags.forEach(({ name, content }) => {
    const meta = document.createElement('meta');
    meta.name = name;
    meta.content = content;
    document.head.appendChild(meta);
  });
}
```

---

## Ficheiros Novos

| Ficheiro | Responsabilidade |
|----------|-----------------|
| `src/migrations/017-create-scientific-articles.sql` | Migration Supabase |
| `src/content/scientific-articles-catalog.json` | Catálogo fallback (2 artigos exemplo) |
| `cientificos.html` | Página de listagem |
| `artigo-cientifico.html` | Página de detalhe |
| `src/scientific-articles-logic.js` | Lógica de listagem |
| `src/scientific-article-detail.js` | Lógica de detalhe |
| `src/lib/citation-formatter.js` | Formatação de citações |
| `src/admin/cientificos/index.html` | Admin listagem |
| `src/admin/cientificos/new.html` | Admin criar |
| `src/admin/cientificos/edit.html` | Admin editar |

## Ficheiros Modificados

| Ficheiro | Alteração |
|----------|----------|
| `src/lib/api.js` | normalizeScientificArticle + 5 funções |
| `src/lib/fallback-data.js` | getFallbackScientificArticles/BySlug |
| `artigos.html` | Banner "Artigos Científicos" |
| `src/input.css` | Estilos científicos |
| `src/admin/styles/admin.css` | Estilos formulário autores |
| `vite.config.js` | 5 entries ao rollupOptions.input |

## Utilitários Reutilizados

| Utilitário | Ficheiro | Uso |
|-----------|---------|-----|
| `escapeHtml` | `src/lib/security.js` | Sanitização innerHTML |
| `escapeAttr` | `src/lib/security.js` | Sanitização atributos |
| `setDocumentTitle`, `setMetaDescription`, etc. | `src/lib/seo.js` | SEO padrão |
| `buildArticleSchema`, `buildBreadcrumbSchema` | `src/lib/seo.js` | JSON-LD |
| `injectJsonLd` | `src/lib/seo.js` | Injetar JSON-LD |
| `renderBreadcrumb` | `src/breadcrumb.js` | Breadcrumbs |
| `errorHandler` | `src/lib/error-handler.js` | Error handling |
| `logger` | `src/lib/logger.js` | Logging |
| `supabaseClient` | `src/config.js` | Cliente Supabase |

---

## Ordem de Execução

1. **Tarefa 1** — Migration SQL (Supabase via MCP)
2. **Tarefa 3** — Catálogo JSON fallback + fallback-data.js
3. **Tarefa 2** — API functions (api.js)
4. **Tarefa 10** — Citation formatter (lib/citation-formatter.js)
5. **Tarefa 5** — CSS estilos (input.css)
6. **Tarefa 4** — Banner em artigos.html
7. **Tarefa 6 + 7** — cientificos.html + lógica de listagem
8. **Tarefa 8 + 9** — artigo-cientifico.html + lógica de detalhe + Highwire Press
9. **Tarefa 11** — Admin CMS (list/new/edit + vite config)

---

## Verificação

### Funcional
1. `node --check` em todos JS novos/modificados
2. `npm run build` — sem erros
3. Banner "Artigos Científicos" visível em artigos.html
4. cientificos.html mostra cards com filtros categoria/idioma/search
5. artigo-cientifico.html?id=... mostra layout completo
6. Citações ABNT/APA/Vancouver + botão copiar
7. Dark mode correto em todos `.sci-*`
8. Admin: criar → aparece na listagem pública
9. Admin: editar → reflete na página de detalhe
10. Admin: eliminar → desaparece
11. Highwire Press meta tags no `<head>`
12. Responsividade: mobile/tablet/desktop

### Segurança
13. `escapeHtml()` em innerHTML (SEC-XSS-01)
14. `escapeAttr()` em atributos (SEC-XSS-02)
15. `validateUrl()` onde aplicável (SEC-XSS-03)
16. `encodeURIComponent()` em slugs (SEC-XSS-04)
17. DOMPurify hook img src (SEC-XSS-05)
18. Scripts CDN com SRI (SEC-HRD-02)
19. `rel="noopener noreferrer"` em target="_blank" (SEC-FRM-03)
20. Admin `checkAuth()` de auth.js (SEC-ATH-02)
21. Admin `initIdleTimeout()` (SEC-ATH-03)
22. Sem `console.log` sensíveis (SEC-AUD-02)
23. Sem `window.*` com chaves (SEC-AUD-03)
24. RLS correto (SEC-SQL-01)
25. SELECT com colunas explícitas (SEC-API-03)
