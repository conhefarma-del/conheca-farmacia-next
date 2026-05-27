# Artigos Científicos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar uma sub-página "Artigos Científicos" dentro da secção de Artigos, com layout académico próprio, citações exportáveis (ABNT/APA/Vancouver), e suporte bilingue (PT/EN). Gerido via Supabase + Admin CMS completo.

**Architecture:** Sub-página acessível via banner na página `artigos.html` existente. Nova página `cientificos.html` para listagem (cards académicos) e `artigo-cientifico.html` para detalhe (layout similar ao `artigo.html` com sidebar de citações). **Dados armazenados no Supabase** (tabela `scientific_articles` com RLS), com fallback JSON local. CRUD completo no Admin CMS existente. Campo `lang` nos dados suporta artigos PT e EN. Sistema de citações gera formatos ABNT, APA e Vancouver via JavaScript. **SEO académico:** Highwire Press meta tags injetadas no `<head>` via JS para indexação pelo Google Scholar. **Afiliações estruturadas:** campo `authors` como JSONB com `institution`, `department`, `affiliation`, `corresponding`. **CSP compliance:** zero inline scripts, todos os scripts em ficheiros .js externos com `type="module"`.

**Tech Stack:** HTML5, Tailwind CSS v4, Vanilla JS (ES6+), Vite, marked.js, DOMPurify, Supabase (PostgreSQL, RLS, Auth)

---

## Requisitos (Resumo das Decisões)

| Decisão           | Escolha                                                                                                          |
| ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| Conteúdo          | Artigos da equipa + de terceiros                                                                                 |
| Estrutura visual  | Muito diferente dos artigos atuais (abstract, palavras-chave, referências, múltiplos autores, secções numeradas) |
| Navegação         | Sub-página via banner em `artigos.html`                                                                          |
| Página de detalhe | Nova página dedicada (`artigo-cientifico.html`) — layout similar ao `artigo.html`                                |
| Sidebar           | Própria (citação copiável, palavras-chave, autores, TOC)                                                         |
| Listagem          | Cards académicos (sem imagem hero, com autores, palavras-chave, DOI)                                             |
| Intercatividade   | Leitura + citações exportáveis (ABNT/APA/Vancouver)                                                              |
| DOI               | Campo opcional; citações adaptam-se quando vazio (URL como fallback)                                             |
| SEO Académico     | Highwire Press meta tags para Google Scholar + schema.org ScholarlyArticle                                       |
| Afiliações        | JSONB estruturado: `institution` (normalizado) + `department` + `affiliation` + `corresponding`                  |
| PDF download      | Fase posterior                                                                                                   |
| Review por pares  | Não visível por agora                                                                                            |
| Idioma            | Bilingue (PT + EN) — cada artigo tem `lang`                                                                      |
| Armazenamento     | **Supabase desde início** (tabela `scientific_articles` com RLS) + fallback JSON local                            |
| Admin CMS         | **CRUD completo** — listagem, criar, editar, eliminar no painel admin existente                                  |
| Volume esperado   | 10-30 artigos no primeiro ano                                                                                    |
| Autores           | Variável (1-N com afiliações) — campo JSONB `authors`                                                            |
| CSP               | Zero inline scripts — todos os scripts em ficheiros .js externos                                                 |

---

## File Structure

### Ficheiros Novos

| Ficheiro                                       | Responsabilidade                                                             |
| ---------------------------------------------- | ---------------------------------------------------------------------------- |
| `src/migrations/017-create-scientific-articles.sql` | Migration Supabase — criar tabela `scientific_articles` com RLS        |
| `cientificos.html`                             | Página de listagem de artigos científicos (cards académicos, filtros, busca) |
| `artigo-cientifico.html`                       | Página de detalhe de artigo científico (layout similar ao artigo.html)       |
| `src/cientificos-logic.js`                     | Lógica de listagem/filtros/busca para `cientificos.html`                     |
| `src/cientifico-detail.js`                     | Lógica de carregamento/renderização para `artigo-cientifico.html`            |
| `src/lib/citation-formatter.js`                | Geração de citações nos formatos ABNT, APA, Vancouver                        |
| `src/content/scientific-articles-catalog.json` | Catálogo de fallback (JSON local)                                            |
| `src/admin/cientificos/index.html`             | Listagem admin de artigos científicos                                        |
| `src/admin/cientificos/new.html`               | Criar artigo científico no admin                                             |
| `src/admin/cientificos/edit.html`              | Editar artigo científico no admin                                            |

### Ficheiros Modificados

| Ficheiro                  | Alteração                                                                  |
| ------------------------- | -------------------------------------------------------------------------- |
| `artigos.html`            | Adicionar banner "Artigos Científicos" antes do grid                       |
| `src/input.css`           | Estilos para cards académicos, layout artigo científico, sidebar, citações |
| `src/lib/api.js`          | Adicionar `getScientificArticles()`, `getScientificArticleBySlug()`, `deleteScientificArticle()`, `normalizeScientificArticle()` |
| `src/lib/seo.js`          | Adicionar `injectScholarMetaTags()` para Google Scholar                    |
| `src/lib/fallback-data.js`| Adicionar `getFallbackScientificArticles()`, `getFallbackScientificArticleBySlug()` |
| `vite.config.js`          | Adicionar entries para páginas científicas e admin                         |
| `src/admin/dashboard.html`| Adicionar card de contagem de artigos científicos                          |

---

## Supabase Schema

### Tabela `scientific_articles`

```sql
CREATE TABLE scientific_articles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  abstract TEXT,
  keywords TEXT[],
  category TEXT NOT NULL,
  category_label TEXT NOT NULL,
  lang TEXT DEFAULT 'pt' CHECK (lang IN ('pt', 'en')),
  content TEXT,
  doi TEXT DEFAULT '',
  image_url TEXT,
  published_date DATE,
  read_time INTEGER,
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  featured BOOLEAN DEFAULT false,
  authors JSONB DEFAULT '[]',
  references_arr TEXT[],
  meta_description TEXT,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE scientific_articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read published scientific articles"
ON scientific_articles FOR SELECT
USING (status = 'published');

CREATE POLICY "Admin full access to scientific articles"
ON scientific_articles FOR ALL
USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));

CREATE TRIGGER update_scientific_articles_updated_at
BEFORE UPDATE ON scientific_articles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Campo JSONB `authors` (formato)

```json
[
  {
    "name": "Dr. João Pedro",
    "institution": "universidade-de-luanda",
    "institutionLabel": "Universidade de Luanda",
    "department": "Faculdade de Farmácia",
    "affiliation": "Universidade de Luanda, Faculdade de Farmácia",
    "role": "Farmacêutico · Investigador Principal",
    "avatar": "JP",
    "avatarBg": "#006171",
    "corresponding": true
  }
]
```

### Categorias

| Key                    | Label                   |
| ---------------------- | ----------------------- |
| `farmacologia-clinica` | Farmacologia Clínica    |
| `saude-publica`        | Saúde Pública           |
| `farmacovigilancia`    | Farmacovigilância       |
| `educacao-farmaceutica`| Educação Farmacêutica   |
| `fitoterapia`          | Fitoterapia             |

---

## Módulos Existentes Reutilizados

| Módulo                         | Funções reutilizáveis |
| ------------------------------ | ---------------------- |
| `src/lib/api.js`               | Padrão de normalização, fallback JSON, `deleteArticle()` |
| `src/lib/seo.js`               | `setDocumentTitle`, `setMetaDescription`, `setCanonicalUrl`, `setOpenGraphTags`, `setTwitterCardTags`, `injectJsonLd`, `buildArticleSchema`, `buildBreadcrumbSchema` |
| `src/lib/security.js`          | `escapeHtml()`, `escapeAttr()` |
| `src/lib/error-handler.js`     | `errorHandler` |
| `src/breadcrumb.js`            | `renderBreadcrumb()` |
| `src/lib/fallback-data.js`     | Padrão de fallback JSON |
| `src/admin/lib/auth.js`        | `checkAuth()`, `initIdleTimeout()` |
| `src/admin/lib/audit-logger.js`| `logAction()` |
| `src/admin/lib/preview.js`     | Preview de Markdown |
| `src/admin/lib/image-compressor.js` | Compressão de imagens |

---

## Task 1: Migration Supabase — Criar tabela `scientific_articles`

**Files:**

- Create: `src/migrations/017-create-scientific-articles.sql`

- [ ] **Step 1: Criar ficheiro de migration**
      Criar `src/migrations/017-create-scientific-articles.sql` com o schema completo definido acima (CREATE TABLE, RLS policies, trigger).

- [ ] **Step 2: Aplicar migration no Supabase via MCP**
      Usar `apply_migration` para criar a tabela. Verificar com `list_tables`.

- [ ] **Step 3: Inserir artigos de exemplo**
      Inserir 2 artigos de exemplo via `execute_sql`:
      - Artigo 1 (PT): "Farmacovigilância em Angola" — categoria `farmacologia-clinica`, 2 autores com afiliações estruturadas
      - Artigo 2 (EN): "Antibiotic Resistance in Angola" — categoria `saude-publica`, 3 autores com afiliações estruturadas

- [ ] **Step 4: Commit**

```bash
git add src/migrations/017-create-scientific-articles.sql
git commit -m "feat: add scientific_articles table with RLS and sample data"
```

---

## Task 2: API Layer — Adicionar funções para artigos científicos

**Files:**

- Modify: `src/lib/api.js`
- Modify: `src/lib/fallback-data.js`
- Create: `src/content/scientific-articles-catalog.json` (fallback)

- [ ] **Step 1: Criar JSON de fallback**
      Criar `src/content/scientific-articles-catalog.json` com os mesmos 2 artigos de exemplo (formato camelCase, como `articles-catalog.json`). Seguir o schema do plano original.

- [ ] **Step 2: Adicionar fallback functions**
      Em `src/lib/fallback-data.js`, adicionar:
      ```js
      import scientificArticlesData from '../content/scientific-articles-catalog.json';

      export function getFallbackScientificArticles() {
        return scientificArticlesData.scientificArticles || [];
      }

      export function getFallbackScientificArticleBySlug(slug) {
        return (scientificArticlesData.scientificArticles || []).find(a => a.slug === slug) || null;
      }
      ```

- [ ] **Step 3: Adicionar normalização e API functions**
      Em `src/lib/api.js`, adicionar após as funções existentes:
      - `normalizeScientificArticle(row)` — converter snake_case Supabase → camelCase frontend
      - `getScientificArticles()` — SELECT * FROM scientific_articles WHERE status = 'published' ORDER BY published_date DESC
      - `getScientificArticleBySlug(slug)` — SELECT * WHERE slug = slug AND status = 'published'
      - `deleteScientificArticle(id)` — DELETE com auth check (padrão `deleteArticle()`)

      Todas as funções devem ter fallback para JSON local em caso de erro (padrão `getArticles()`).

- [ ] **Step 4: Validar sintaxe**
      Run: `node --check src/lib/api.js && node --check src/lib/fallback-data.js`

- [ ] **Step 5: Commit**

```bash
git add src/lib/api.js src/lib/fallback-data.js src/content/scientific-articles-catalog.json
git commit -m "feat: add scientific articles API functions with fallback"
```

---

## Task 3: Criar utilitário de formatação de citações

**Files:**

- Create: `src/lib/citation-formatter.js`

- [ ] **Step 1: Implementar o módulo de citações**
      Criar `src/lib/citation-formatter.js` com:
      - `formatCitation(article, style)` — recebe artigo científico e estilo (`"abnt"`, `"apa"`, `"vancouver"`). **Quando DOI está vazio**, usa URL como fallback (ABNT: "Disponível em: <URL>", APA: URL, Vancouver: "Available from: URL"). Quando DOI existe, usa-o como referência permanente. Inclui "Conheça Farmácia" como publicador.
      - `copyToClipboard(text)` — copia texto com fallback para browsers sem clipboard API.

      **Importante:** Não usar inline onclick — apenas event listeners via `addEventListener` (CSP compliance).

- [ ] **Step 2: Validar sintaxe**
      Run: `node --check src/lib/citation-formatter.js`

- [ ] **Step 3: Commit**

```bash
git add src/lib/citation-formatter.js
git commit -m "feat: add citation formatter (ABNT, APA, Vancouver)"
```

---

## Task 4: SEO Académico — Adicionar Highwire Press meta tags

**Files:**

- Modify: `src/lib/seo.js`

- [ ] **Step 1: Adicionar `injectScholarMetaTags(article)`**
      Em `src/lib/seo.js`, adicionar no final:
      - `injectScholarMetaTags(article)` — injeta meta tags `citation_title`, `citation_author` (um por autor), `citation_publication_date`, `citation_journal_title` ("Conheça Farmácia"), `citation_language`, `citation_keywords` (uma por keyword), `citation_doi` (apenas se DOI existe). Remove tags anteriores antes de injetar.
      - `buildScholarlyArticleSchema(article)` — gera schema.org `ScholarlyArticle` (extensão de `buildArticleSchema` existente) com múltiplos autores.

- [ ] **Step 2: Validar sintaxe**
      Run: `node --check src/lib/seo.js`

- [ ] **Step 3: Commit**

```bash
git add src/lib/seo.js
git commit -m "feat: add academic SEO - Highwire Press meta tags + ScholarlyArticle schema"
```

---

## Task 5: Adicionar banner "Artigos Científicos" em artigos.html

**Files:**

- Modify: `artigos.html`

- [ ] **Step 1: Adicionar o banner**
      Em `artigos.html`, inserir após o fecho da secção `articles-filter-section` e antes da secção `section-padding bg-brand-bg-alt` (grid de artigos):

      Banner com: ícone de livro (SVG), título "Artigos Científicos", descrição "Publicações académicas com revisão, referências e citações exportáveis", seta para a direita. Link para `cientificos.html`. Estilo: borda dashed verde, hover com shadow.

      **Importante:** Sem inline onclick — apenas link `<a>`.

- [ ] **Step 2: Verificar visualmente no browser**
      Run: `npm run dev`
      Navegar para `http://localhost:5173/artigos.html` e confirmar que o banner aparece entre os filtros e o grid.

- [ ] **Step 3: Commit**

```bash
git add artigos.html
git commit -m "feat: add scientific articles banner on artigos.html"
```

---

## Task 6: Adicionar estilos CSS para componentes científicos

**Files:**

- Modify: `src/input.css`

- [ ] **Step 1: Estilos do banner (artigos.html)**
      No final de `src/input.css`, adicionar estilos para o banner:
      `.scientific-articles-banner`, `.sci-banner-link`, `.sci-banner-content`, `.sci-banner-icon`, `.sci-banner-text`, `.sci-banner-title`, `.sci-banner-desc`, `.sci-banner-arrow`

- [ ] **Step 2: Estilos para cards académicos (cientificos.html)**
      Adicionar: `.sci-card`, `.sci-card-category`, `.sci-card-title`, `.sci-card-abstract`, `.sci-card-authors`, `.sci-card-author`, `.sci-card-keywords`, `.sci-card-keyword`, `.sci-card-meta`, `.sci-card-lang`

- [ ] **Step 3: Estilos para página de detalhe (artigo-cientifico.html)**
      Adicionar: `.sci-abstract-box`, `.sci-abstract-title`, `.sci-abstract-text`, `.sci-keywords-section`, `.sci-keyword-tag`, `.sci-authors-grid`, `.sci-author-card`, `.sci-author-avatar`, `.sci-author-info`, `.sci-author-name`, `.sci-author-affiliation`, `.sci-author-corresponding`, `.sci-citation-widget`, `.sci-citation-title`, `.sci-citation-tabs`, `.sci-citation-tab`, `.sci-citation-text`, `.sci-citation-copy-btn`, `.sci-article-body` (e variantes h2/h3/p/ul/ol/table), `.sci-references-list`, `.sci-reference-item`

- [ ] **Step 4: Estilos dark mode**
      Dentro do bloco `html.dark` existente, adicionar variantes para todos os componentes `.sci-*`.

- [ ] **Step 5: Estilos filtro de idioma**
      `.sci-lang-btn`, `.sci-lang-btn.active`

- [ ] **Step 6: Verificar build**
      Run: `npm run build`
      Expected: Build conclui sem erros CSS.

- [ ] **Step 7: Commit**

```bash
git add src/input.css
git commit -m "feat: add CSS styles for scientific articles (banner, cards, detail, citations)"
```

---

## Task 7: Criar página de listagem cientificos.html

**Files:**

- Create: `cientificos.html`

- [ ] **Step 1: Criar a página HTML completa**
      Criar `cientificos.html` seguindo o mesmo padrão de `artigos.html` (header, drawer, footer) mas com conteúdo próprio:
      - Hero: breadcrumb "← Artigos | Publicações Académicas", título "Artigos Científicos", subtítulo
      - Search bar + filtros de categoria (botões dinâmicos via JS) + filtro de idioma (Todos/PT/EN)
      - Grid de cards (`#sci-articles-grid`) — vazio, renderizado via JS
      - Secção "Nenhum artigo encontrado" (hidden por defeito)
      - CTA "← Voltar para Artigos"

      **Importante:** Sem inline onclick em nenhum elemento — usar `addEventListener` no JS.

- [ ] **Step 2: Adicionar entry no Vite config**
      Em `vite.config.js`, adicionar:
      ```js
      cientificos: resolve(__dirname, "cientificos.html"),
      ```

- [ ] **Step 3: Commit**

```bash
git add cientificos.html vite.config.js
git commit -m "feat: add scientific articles listing page (cientificos.html)"
```

---

## Task 8: Criar lógica de listagem cientificos-logic.js

**Files:**

- Create: `src/cientificos-logic.js`

- [ ] **Step 1: Implementar a lógica completa**
      Criar `src/cientificos-logic.js`:
      - Importar `getScientificArticles` de `./lib/api.js`
      - Importar `escapeHtml` de `./lib/security.js`
      - Importar `logger` de `./lib/logger.js`
      - Filtros client-side: categoria, idioma (PT/EN/Todos), pesquisa (título, abstract, autores, keywords)
      - Renderizar cards académicos: category badge (cor), lang badge, título, abstract (3 linhas), autores, keywords (max 4), meta (data, tempo leitura, refs), link "Ler artigo"
      - Links: `artigo-cientifico.html?id={slug}`
      - Filtro de idioma: `data-lang` attribute com event listeners

      **Padrão:** Seguir o padrão de `src/articles-logic.js` mas sem imagem hero nos cards.

- [ ] **Step 2: Verificar que a página carrega**
      Run: `npm run dev`
      Navegar para `http://localhost:5173/cientificos.html` e confirmar que os artigos de exemplo aparecem.

- [ ] **Step 3: Validar sintaxe**
      Run: `node --check src/cientificos-logic.js`

- [ ] **Step 4: Commit**

```bash
git add src/cientificos-logic.js
git commit -m "feat: add scientific articles listing logic with filters and search"
```

---

## Task 9: Criar página de detalhe artigo-cientifico.html

**Files:**

- Create: `artigo-cientifico.html`

- [ ] **Step 1: Criar a página HTML completa**
      Criar `artigo-cientifico.html` com layout similar ao `artigo.html`:
      - Hero: breadcrumb "← Artigos Científicos", category badge, lang badge, título, autores inline, data, tempo de leitura
      - Abstract box (`#sci-abstract`) — destacado com border-left verde
      - Keywords (`#sci-keywords`) — tags clicáveis
      - Autores grid (`#sci-authors-grid`) — cards com avatar, nome, afiliação, role, correspondente
      - **Layout 2/3 + 1/3** (padrão `article-grid`):
        - **Conteúdo** (`#sci-body`) — Markdown renderizado
        - **Sidebar** — Widget de citação (tabs ABNT/APA/Vancouver + copiar), Table of Contents (`#sci-toc`)
      - Referências (`#sci-references`) — lista numerada
      - CTA "← Voltar para Artigos Científicos"

      **Scripts externos:** `marked.min.js`, `dompurify.min.js` (CDN com SRI)
      **Módulos:** `main.js`, `src/cientifico-detail.js`

- [ ] **Step 2: Adicionar entry no Vite config**
      Em `vite.config.js`, adicionar:
      ```js
      artigoCientifico: resolve(__dirname, "artigo-cientifico.html"),
      ```

- [ ] **Step 3: Commit**

```bash
git add artigo-cientifico.html vite.config.js
git commit -m "feat: add scientific article detail page (artigo-cientifico.html)"
```

---

## Task 10: Criar lógica de detalhe cientifico-detail.js

**Files:**

- Create: `src/cientifico-detail.js`

- [ ] **Step 1: Implementar a lógica completa**
      Criar `src/cientifico-detail.js` seguindo o padrão de `src/article-detail.js`:
      - Importar: `getScientificArticleBySlug` de `./lib/api.js`, `formatCitation`/`copyToClipboard` de `./lib/citation-formatter.js`, `escapeHtml` de `./lib/security.js`, `errorHandler` de `./lib/error-handler.js`, `renderBreadcrumb` de `./breadcrumb.js`, funções SEO de `./lib/seo.js`
      - `loadArticle()` — buscar artigo por slug (URL param `?id=`), renderizar ou mostrar erro
      - `renderArticle(article)` — preencher: category/lang badges, título, autores meta, data, abstract, keywords, autores grid, corpo (Markdown → DOMPurify → innerHTML), TOC (h2 headings), referências
      - `initCitationTabs(article)` — tabs ABNT/APA/Vancouver com event listeners
      - `injectScholarMetaTags(article)` — Highwire Press meta tags
      - SEO: `setDocumentTitle`, `setMetaDescription`, `setCanonicalUrl`, `setOpenGraphTags`, `setTwitterCardTags`, `injectJsonLd`, `buildArticleSchema`, `buildBreadcrumbSchema`
      - Loading skeleton (padrão `article-detail.js`)
      - DOMPurify hook para restringir `img src` a domínios permitidos (padrão existente)

      **Importante:** Sem inline scripts — tudo via `addEventListener`.

- [ ] **Step 2: Verificar que a página de detalhe funciona**
      Run: `npm run dev`
      Navegar para `http://localhost:5173/artigo-cientifico.html?id=sc001-farmacovigilancia-angola` e confirmar:
      - Título, abstract, autores com afiliações
      - Keywords como tags
      - Conteúdo Markdown renderizado com DOMPurify
      - Widget de citação com tabs ABNT/APA/Vancouver
      - Citações sem DOI mostram URL como fallback
      - Botão copiar funciona
      - TOC no sidebar
      - Referências no final
      - Meta tags Google Scholar no `<head>` (DevTools)

- [ ] **Step 3: Validar sintaxe**
      Run: `node --check src/cientifico-detail.js`

- [ ] **Step 4: Commit**

```bash
git add src/cientifico-detail.js
git commit -m "feat: add scientific article detail logic with citations, TOC and Scholar SEO"
```

---

## Task 11: Admin CMS — Listagem de artigos científicos

**Files:**

- Create: `src/admin/cientificos/index.html`

- [ ] **Step 1: Criar página de listagem admin**
      Criar `src/admin/cientificos/index.html` seguindo o padrão de `src/admin/artigos/index.html`:
      - Sidebar + top bar (mesmo template)
      - Tabela com: título, categoria, idioma (PT/EN badge), status (badge), data, views, ações (editar/eliminar)
      - Filtros: status, categoria, idioma
      - Botão "Novo Artigo Científico" → `new.html`
      - Pesquisa client-side
      - Importar: `checkAuth` de `../lib/auth.js`, `supabaseClient` de `../../config.js`, `escapeHtml` de `../../lib/security.js`, `logAction` de `../lib/audit-logger.js`
      - Confirm modal para eliminação (padrão existente — HTML/CSS, não `confirm()` nativo)

- [ ] **Step 2: Adicionar entry no Vite config**
      Em `vite.config.js`, adicionar:
      ```js
      adminCientificosIndex: resolve(__dirname, "src/admin/cientificos/index.html"),
      ```

- [ ] **Step 3: Commit**

```bash
git add src/admin/cientificos/index.html vite.config.js
git commit -m "feat: add admin listing for scientific articles"
```

---

## Task 12: Admin CMS — Criar artigo científico

**Files:**

- Create: `src/admin/cientificos/new.html`

- [ ] **Step 1: Criar formulário de criação**
      Criar `src/admin/cientificos/new.html` seguindo o padrão de `src/admin/artigos/new.html`:
      - Sidebar + top bar
      - Formulário com campos:
        - Título, Slug (auto-gerado a partir do título)
        - Categoria (select com as 5 opções)
        - Idioma (select: PT/EN)
        - Status (select: Rascunho/Publicado)
        - Checkbox "Destacar na página principal"
        - Abstract (textarea)
        - Keywords (input — separar por vírgulas, converter para array)
        - Meta Descrição (SEO)
        - Conteúdo Markdown (textarea com botão expandir/preview)
        - DOI (opcional)
        - Imagem URL
        - Tempo de leitura (número)
        - **Autores** (array dinâmico):
          - Campos por autor: Nome, Institution (slug), InstitutionLabel, Department, Role, Avatar (2 letras), AvatarBg (cor), Correspondente (checkbox)
          - Botões "Adicionar Autor" / "Remover"
        - **Referências** (array dinâmico):
          - Campo de texto por referência
          - Botões "Adicionar Referência" / "Remover"
      - Botão Guardar → `supabaseClient.from('scientific_articles').insert(data)`
      - Audit log: `logAction('CREATE', 'scientific_articles', ...)`

      **Importante:** Sem inline onclick — todos os event listeners via `addEventListener` no `<script type="module">`.

- [ ] **Step 2: Adicionar entry no Vite config**
      Em `vite.config.js`, adicionar:
      ```js
      adminCientificosNew: resolve(__dirname, "src/admin/cientificos/new.html"),
      ```

- [ ] **Step 3: Commit**

```bash
git add src/admin/cientificos/new.html vite.config.js
git commit -m "feat: add admin create form for scientific articles"
```

---

## Task 13: Admin CMS — Editar artigo científico

**Files:**

- Create: `src/admin/cientificos/edit.html`

- [ ] **Step 1: Criar formulário de edição**
      Criar `src/admin/cientificos/edit.html` seguindo o padrão de `src/admin/artigos/edit.html`:
      - Todos os campos do `new.html`
      - Carregar artigo existente por ID (URL param `?id=`)
      - Pré-preencher todos os campos incluindo autores e referências (JSONB)
      - Botão Guardar → `supabaseClient.from('scientific_articles').update(data).eq('id', id)`
      - Botão Eliminar → confirmação modal + `deleteScientificArticle(id)`
      - Botão Pré-visualizar
      - Audit log: `logAction('UPDATE', 'scientific_articles', ...)`

- [ ] **Step 2: Adicionar entry no Vite config**
      Em `vite.config.js`, adicionar:
      ```js
      adminCientificosEdit: resolve(__dirname, "src/admin/cientificos/edit.html"),
      ```

- [ ] **Step 3: Commit**

```bash
git add src/admin/cientificos/edit.html vite.config.js
git commit -m "feat: add admin edit form for scientific articles"
```

---

## Task 14: Dashboard — Card de artigos científicos

**Files:**

- Modify: `src/admin/dashboard.html`

- [ ] **Step 1: Adicionar card de contagem**
      No dashboard, adicionar card com contagem de artigos científicos publicados. Seguir o padrão dos cards existentes (artigos, eventos, lives).

- [ ] **Step 2: Commit**

```bash
git add src/admin/dashboard.html
git commit -m "feat: add scientific articles count card to admin dashboard"
```

---

## Task 15: Verificação final — Build, responsividade, dark mode

**Files:**

- Nenhum ficheiro novo (validação)

- [ ] **Step 1: Validar sintaxe de todos os JS**
      Run:
      ```bash
      node --check src/lib/api.js
      node --check src/lib/fallback-data.js
      node --check src/lib/citation-formatter.js
      node --check src/lib/seo.js
      node --check src/cientificos-logic.js
      node --check src/cientifico-detail.js
      ```

- [ ] **Step 2: Build de produção**
      Run: `npm run build`
      Expected: Build conclui sem erros.

- [ ] **Step 3: Verificar páginas no preview**
      Run: `npm run preview`
      Verificar:
      - `artigos.html` — banner aparece
      - `cientificos.html` — cards, filtros, busca, idioma
      - `artigo-cientifico.html?id=sc001-farmacovigilancia-angola` — layout completo
      - `artigo-cientifico.html?id=SC002-antibiotic-resistance-angola` — artigo EN
      - Admin: criar, editar, eliminar artigo científico

- [ ] **Step 4: Verificar responsividade**
      Mobile (320-480px): sidebar empilha, cards 1 coluna
      Tablet (768px): 2 colunas
      Desktop (1024px+): layout completo com sidebar

- [ ] **Step 5: Verificar dark mode**
      Alternar dark mode em cada página e confirmar que todos os `.sci-*` aplicam.

- [ ] **Step 6: Verificar CSP**
      Verificar que não existem inline scripts ou onclick handlers em nenhum ficheiro novo.

- [ ] **Step 7: Commit final (se houver correcções)**

```bash
git add -A
git commit -m "fix: responsive and dark mode adjustments for scientific articles"
```

---

## Tarefas Futuras (fora do escopo deste plano)

1. **DOI** — campo `doi` já existe no schema, fica vazio. As citações já usam URL como fallback quando DOI não existe. Adicionar validação e link quando houver registo DOI. A meta tag `citation_doi` só é injetada quando o DOI existe.
2. **PDF Download** — futuro: upload manual de PDFs para Supabase Storage + botão de download.
3. **Busca textual avançada** — Full Text Search no Supabase quando o volume justificar.
4. **Filtro por instituição** — o campo `institution` (ID normalizado) já existe no schema JSONB. Futuramente, permitir filtrar artigos por instituição dos autores.
5. **Featured na homepage** — integrar artigos científicos na secção de destaques da homepage (padrão já implementado para artigos normais).

---

## Ordem de Execução

1. **Task 1** — Migration SQL (Supabase)
2. **Task 2** — API functions + fallback JSON
3. **Task 3** — Citation formatter
4. **Task 4** — SEO académico
5. **Task 5** — Banner em artigos.html
6. **Task 6** — CSS
7. **Task 7** — Página de listagem (HTML)
8. **Task 8** — Lógica de listagem (JS)
9. **Task 9** — Página de detalhe (HTML)
10. **Task 10** — Lógica de detalhe (JS)
11. **Task 11** — Admin listagem
12. **Task 12** — Admin criar
13. **Task 13** — Admin editar
14. **Task 14** — Dashboard card
15. **Task 15** — Verificação final

---

## Self-Review Checklist

**1. Spec coverage:**

- [x] Sub-página dentro de Artigos (banner em artigos.html) → Task 5
- [x] Listagem com cards académicos → Tasks 7-8
- [x] Página de detalhe dedicada → Tasks 9-10
- [x] Sidebar própria (citações, keywords, TOC) → Tasks 9-10
- [x] Citações ABNT/APA/Vancouver com fallback URL quando DOI vazio → Task 3
- [x] Suporte bilingue PT/EN → Task 8 (filtro) + Task 10 (badge)
- [x] Múltiplos autores com afiliações estruturadas (JSONB) → Task 1 (schema) + Task 10 (render)
- [x] Supabase desde início com RLS → Task 1
- [x] Admin CMS CRUD completo → Tasks 11-13
- [x] Abstract, keywords, referências → Tasks 9-10
- [x] SEO Académico: Highwire Press meta tags → Task 4
- [x] Afiliações estruturadas: institution + department + affiliation → Task 1 (schema)
- [x] Citações com DOI fallback para URL → Task 3
- [x] Dark mode → Task 6
- [x] Responsividade → Task 15
- [x] CSP compliance (zero inline scripts) → Tasks 7-13
- [x] Reutilização de módulos existentes → Mapeada na tabela

**2. Placeholder scan:** Nenhum TBD/TODO encontrado. Todos os passos têm código completo ou referência a padrões existentes.

**3. Type consistency:**

- `article.slug` usado consistentemente como identificador público (links, URL params)
- `article.authors` é sempre JSONB array com `{name, institution, institutionLabel, department, affiliation, role, avatar, avatarBg, corresponding}`
- `normalizeScientificArticle(row)` segue o padrão de `normalizeArticle(row)` existente
- `categoryColors` — mesmas chaves em todos os ficheiros JS científicos
- `injectScholarMetaTags(article)` — usa campos definidos no schema Supabase
