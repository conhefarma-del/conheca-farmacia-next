# Artigos Científicos — Plano de Implementação (2026-08-11, v3)

> Versão final baseada nos modelos de design do utilizador em
> `_temp/design-demos/` (`cientificos.html`, `artigo-cientifico.html`,
> `banner-cientificos.html`) e nas decisões confirmadas em 2026-08-11.
> Substitui a v2 (que estendia a tabela `articles`) — o utilizador quer uma
> **secção totalmente separada dos Artigos**.

## Decisões confirmadas (respostas do utilizador)

| # | Pergunta | Decisão |
|---|----------|---------|
| 1 | Base de dados | **A — tabela própria** `scientific_articles` (+ traduções), independente de `articles`, admin próprio |
| 2 | Conteúdo inicial | **C — artigos reais publicados** (DOI, autores, referências reais via PubMed/DOAJ), não placeholders |
| 3 | Idiomas | **Toggle PT/EN local na página** (não o Utility Bar global) — muda a língua do artigo **só se** existir versão na segunda língua |
| 4 | Rotas/entradas | **Os dois**: item próprio no menu principal **e** banner em `/artigos` |
| 5 | Admin | **Secção própria** `/admin/cientificos` + **formulário novo dedicado** |
| 6 | Categorias | **Geríveis no admin** (tabela própria, para adicionar categorias ao longo do tempo) |
| 7 | Detalhes | TOC gerado **dos `h2`** · listagem **tudo de uma vez** (sem paginação) · **DOI apenas apresentado, sem link** |

## Arquitetura

- **Público:** `/cientificos` (listagem) e `/cientificos/[slug]` (detalhe) — rotas top-level, irmãs de `/artigos` (como no demo: nav "Científicos" + link "← Voltar para Artigos").
- **Admin:** `/admin/cientificos` (lista paginada), `/admin/cientificos/new`, `/admin/cientificos/[id]` (editar) e `/admin/cientificos/categorias` (CRUD de categorias).
- **Dados:** 3 tabelas novas — `scientific_categories`, `scientific_articles`, `scientific_article_translations` — espelhando o padrão `articles`/`article_translations` + categorias geríveis.
- **Idiomas:** modelo de traduções (base PT + traduções EN por artigo), como `articles`. O toggle local mostra EN **só quando** existe tradução; a listagem tem toggle PT/EN que filtra (comportamento do demo).

---

## Migração 142 — Schema + categorias seed

**Ficheiro:** `supabase/migrations/142_artigos_cientificos.sql`

```sql
-- Categorias geríveis (CRUD admin)
CREATE TABLE IF NOT EXISTS public.scientific_categories (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug        TEXT NOT NULL UNIQUE,
  name_pt     TEXT NOT NULL,
  name_en     TEXT,
  color       TEXT NOT NULL DEFAULT '#0a844f',
  sort_order  INTEGER NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.scientific_articles (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug          TEXT NOT NULL UNIQUE,
  title         TEXT NOT NULL,
  abstract      TEXT,
  keywords      TEXT[] DEFAULT '{}',
  category_id   UUID REFERENCES public.scientific_categories(id),
  doi           TEXT,
  authors       JSONB NOT NULL DEFAULT '[]',
  content       TEXT,
  references_arr TEXT[],
  read_time     INTEGER,
  status        TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  featured      BOOLEAN NOT NULL DEFAULT false,
  published_at  TIMESTAMPTZ,
  is_archived   BOOLEAN NOT NULL DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.scientific_article_translations (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  article_id    UUID NOT NULL REFERENCES public.scientific_articles(id) ON DELETE CASCADE,
  lang          TEXT NOT NULL CHECK (lang IN ('pt','en')),
  slug          TEXT NOT NULL,
  title         TEXT NOT NULL,
  abstract      TEXT,
  keywords      TEXT[] DEFAULT '{}',
  content       TEXT,
  references_arr TEXT[],
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE (article_id, lang)
);

-- RLS (padrão do projeto, ver migração 141)
ALTER TABLE public.scientific_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scientific_articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scientific_article_translations ENABLE ROW LEVEL SECURITY;

-- Público: categorias sempre legíveis
CREATE POLICY "anon_read_scientific_categories" ON public.scientific_categories
  FOR SELECT TO anon USING (true);
-- Público: só artigos publicados e não arquivados
CREATE POLICY "anon_read_scientific_articles" ON public.scientific_articles
  FOR SELECT TO anon USING (status = 'published' AND is_archived = false);
CREATE POLICY "anon_read_scientific_translations" ON public.scientific_article_translations
  FOR SELECT TO anon USING (EXISTS (
    SELECT 1 FROM public.scientific_articles a
    WHERE a.id = article_id AND a.status = 'published' AND a.is_archived = false));
-- Admin: tudo (padrão is_current_user_admin)
CREATE POLICY "admin_all_scientific_categories" ON public.scientific_categories
  FOR ALL TO authenticated USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());
CREATE POLICY "admin_all_scientific_articles" ON public.scientific_articles
  FOR ALL TO authenticated USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());
CREATE POLICY "admin_all_scientific_translations" ON public.scientific_article_translations
  FOR ALL TO authenticated USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());

-- Indexes
CREATE INDEX idx_sci_articles_status ON public.scientific_articles(status, is_archived);
CREATE INDEX idx_sci_articles_category ON public.scientific_articles(category_id);
CREATE INDEX idx_sci_articles_featured ON public.scientific_articles(featured) WHERE featured = true;

-- Seed das 5 categorias do demo
INSERT INTO public.scientific_categories (slug, name_pt, name_en, color, sort_order) VALUES
  ('farmacologia-clinica',    'Farmacologia Clínica',   'Clinical Pharmacology', '#0a844f', 1),
  ('saude-publica',           'Saúde Pública',          'Public Health',         '#006171', 2),
  ('farmacovigilancia',       'Farmacovigilância',      'Pharmacovigilance',     '#e85d18', 3),
  ('educacao-farmaceutica',   'Educação Farmacêutica',  'Pharmaceutical Education', '#002a32', 4),
  ('fitoterapia',             'Fitoterapia',            'Phytotherapy',          '#6b7280', 5)
ON CONFLICT (slug) DO NOTHING;
```

- `doi` é global (não vai para traduções) — o DOI identifica o artigo, não a tradução.
- `authors` é global (nomes/afiliações não se traduzem).
- Sem coluna de imagem — o design do demo não tem imagem nos cards nem no detalhe.

## Migração 143 — Seed de 5 artigos reais (1 por categoria)

- **Método:** pesquisa PubMed/DOAJ por artigos reais publicados (de acesso livre sempre que possível), um por categoria: farmacologia clínica, saúde pública, farmacovigilância, educação farmacêutica, fitoterapia.
- **Conteúdo:** título, abstract (resumo real), keywords, DOI real, autores reais, conteúdo (resumo estruturado em markdown + ligação à fonte), `references_arr` reais, `read_time`, `status='published'`.
- **Validação editorial:** a escolha dos 5 artigos é **confirmada com o utilizador antes de escrever a migração** (é conteúdo editorial do site, com DOI e autores reais).
- Tradução EN: os artigos escolhidos entram em PT; a tradução EN fica opcional (seed só PT; o toggle só aparece quando existir tradução).

---

## Tarefas

### T1 — Migração 142 (schema + categorias)
SQL acima. Aplicar no Supabase.

### T2 — Migração 143 (seed real)
Após validação editorial dos 5 artigos com o utilizador.

### T3 — Camada de dados: `lib/api/scientific-articles.js` (novo)
Espelhar o padrão de `lib/api/articles.js` + `normalize.js`:
- `SCIENTIFIC_ARTICLE_COLUMNS` (SELECT explícito)
- `normalizeScientificArticle(row, categoryMap)` → `{ id, slug, title, abstract, keywords, category: {slug, name, color}, doi, authors, content, references, readTime, status, featured, publishedAt, date }`
- `getScientificArticles(lang)` — publicados + não arquivados, merge de traduções (padrão `getArticles`: EN só mostra com tradução)
- `getScientificArticleBySlug(slug, lang)`
- `getScientificCategories()` — ordenadas por `sort_order`
- Admin: `getAllScientificArticlesAdmin()` (sem filtro status) + contagem

### T4 — Ações server: `lib/actions/scientific.js` (novo)
Padrão de `lib/actions/content.js`:
- `createScientificArticle` / `updateScientificArticle` — `requireAdmin`, `sanitizeHtml` no `content` e `abstract`, validação (slug único, title ≤300, keywords array ≤10 strings ≤50 chars, authors array ≤12 objetos com campos ≤200 — o seed 143 inclui um artigo com 10 autores, doi formato `10.xxxx/...`, references ≤100 strings), `published_at` quando `status='published'`
- `archiveScientificArticle` / `deleteScientificArticle` (hard delete, só superadmin — padrão 020)
- CRUD de categorias: `createScientificCategory` / `updateScientificCategory` / `deleteScientificCategory` (delete com verificação de artigos associados — ou mover para "outros")
- Traduções: `saveScientificTranslation(articleId, lang, fields)`

### T5 — Admin: `app/[lang]/admin/(protected)/cientificos/`
- `page.js` — lista paginada (padrão `DrugAdminTable`/`AdminPagination`): colunas título, categoria, idiomas, status, data; ações editar/arquivar/eliminar
- `new/page.js` + `[id]/page.js` — `components/admin/ScientificArticleForm.jsx` (novo)
- `categorias/page.js` — CRUD de categorias (nome PT/EN, slug, cor, ordem)
- Sidebar: item "Científicos" (pode entrar como submenu de Artigos → Traduções EN já é submenu; adicionar Científicos como item do grupo Artigos)

### T6 — `components/admin/ScientificArticleForm.jsx` (novo)
Formulário dedicado: título, slug, categoria (dropdown da BD), status, featured, abstract (textarea), keywords (input vírgulas → tags), autores dinâmicos (nome, instituição, departamento, cargo, iniciais, cor, correspondente), DOI, conteúdo markdown, referências (textarea linha-a-linha), read_time (auto ou manual), secção de tradução EN (título/abstract/keywords/conteúdo/referências quando existirem).

### T7 — Listagem pública `/cientificos`
`app/[lang]/(public)/cientificos/page.js` + `components/pages/CientificosPageClient.jsx`:
- Hero (eyebrow "Publicações académicas" + título + subtítulo) — do demo
- "← Voltar para Artigos" no topo
- Filtros: categorias da BD (com as cores) + toggle PT/EN + pesquisa
- Grid de cards `.sci-card`: badge categoria + badge língua, título, abstract (3 linhas clamp), keywords, meta (data · tempo · avatares de autores empilhados)
- Tudo de uma vez (sem paginação)
- Estado vazio com ícone (padrão do projeto)

### T8 — Detalhe `/cientificos/[slug]`
`app/[lang]/(public)/cientificos/[slug]/page.js`:
- Layout 2/3 + 1/3 (demo)
- Hero: badges (categoria + língua), título serif, chips de autores, meta (data · tempo · DOI **sem link**)
- `AbstractBox` — borda esquerda, label "Resumo", texto serif
- Keywords tags
- Grid de autores (avatar, nome, afiliação, ponto de correspondente)
- Corpo em serif (markdown + sanitize) — `ScientificArticleContent` (wrapper do markdown com classes `.sci-article-body`)
- `CitationWidget` (ABNT/APA/Vancouver + copiar) — `components/content/CitationWidget.jsx`
- Referências
- **Toggle PT/EN local** — `components/content/ArticleLangToggle.jsx`: botões PT/EN; muda para a tradução se existir, senão permanece na versão atual (sem aviso de fallback — o toggle só aparece quando há 2 línguas? **Decisão:** o toggle só é renderizado quando existe tradução)
- Sidebar sticky: DOI (sem link), TOC gerado dos `h2` do corpo (parsing markdown no cliente ou ids de âncoras), partilhar (ShareSection existente), relacionados (mesma categoria)

### T9 — SEO: `lib/seo.js` + `generateMetadata`
- `buildScholarlyArticleSchema(article, lang)` — schema.org `ScholarlyArticle` (authors array, `sameAs` DOI como string, `citation`)
- Highwire meta tags via `other: {}` em `generateMetadata`: `citation_title`, `citation_author*`, `citation_publication_date`, `citation_journal_title: 'Conheça Farmácia'`, `citation_language`, `citation_doi`, `citation_keywords*`, `citation_pdf_url` (se houver)

### T10 — Entradas de navegação
- Item "Científicos" no menu principal (nav) — demo mostra como item de topo
- Banner em `/artigos` — **variante A (light)** do `banner-cientificos.html`, colocado após a secção de filtros, componente `components/ui/ScientificBanner.jsx`

### T11 — i18n: `lib/i18n.js`
Chaves `cientificos_page.*` (hero, filtros, search, empty) e `cientifico_detail.*` (resumo, autores, tópicos, citações, referências, copiar, relacionados, voltar) em pt/en.

### T12 — CSS
Classes `.sci-*` do demo adaptadas ao Tailwind/CSS do projeto (`.sci-card`, `.sci-category-badge` com cores dinâmicas das categorias, `.sci-abstract-box`, `.sci-authors-grid`, `.sci-citation-widget`, `.sci-article-body` serif) + variantes dark mode + `.sci-banner` (variante A).

---

## Ficheiros

| Ficheiro | Ação |
|---|---|
| `supabase/migrations/142_artigos_cientificos.sql` | Novo |
| `supabase/migrations/143_seed_artigos_cientificos.sql` | Novo (após validação editorial) |
| `lib/api/scientific-articles.js` | Novo |
| `lib/actions/scientific.js` | Novo |
| `lib/citation.js` | Novo (funções puras ABNT/APA/Vancouver) |
| `lib/seo.js` | Modificar (`buildScholarlyArticleSchema`) |
| `lib/i18n.js` | Modificar (chaves novas) |
| `components/admin/ScientificArticleForm.jsx` | Novo |
| `components/admin/ScientificAdminTable.jsx` | Novo (lista paginada) |
| `components/content/CitationWidget.jsx` | Novo |
| `components/content/ArticleLangToggle.jsx` | Novo |
| `components/content/ScientificArticleContent.jsx` | Novo (markdown serif) |
| `components/pages/CientificosPageClient.jsx` | Novo |
| `components/ui/ScientificBanner.jsx` | Novo |
| `app/[lang]/(public)/cientificos/page.js` | Novo |
| `app/[lang]/(public)/cientificos/[slug]/page.js` | Novo |
| `app/[lang]/admin/(protected)/cientificos/{page,new,[id],categorias}` | Novos |
| `components/layout/AdminSidebar.jsx` | Modificar (item Científicos) |
| `app/[lang]/(public)/artigos/ArticlesPageClient.jsx` | Modificar (banner) |
| Navegação principal (header) | Modificar (item Científicos) |
| CSS do projeto | Modificar (classes `.sci-*` + banner) |

## Fora de âmbito (consciente)

- Sem imagem hero/cards (design do demo não tem)
- Sem PDF download/print (pode ser follow-up com `citation_pdf_url`)
- Sem Highwire por JS — server-side via `generateMetadata`
- Sem paginação na listagem pública (decisão do utilizador)
- DOI apresentado sem link (decisão do utilizador)

---

## Ordem de Execução

1. **T1** — Migração 142 (aplicar) + **T3** — camada de dados
2. **T2** — Validação editorial dos 5 artigos com o utilizador → migração 143
3. **T4 + T5 + T6** — Admin (ações, lista, form, categorias)
4. **T11 + T12** — i18n + CSS base
5. **T7 + T8** — Páginas públicas (listagem + detalhe + toggle + citation widget)
6. **T9** — SEO (ScholarlyArticle + Highwire)
7. **T10** — Nav + banner em `/artigos`

## Verificação

- Sintaxe ESM/JSX nos ficheiros novos + `npm run build` sem erros
- Admin: criar artigo científico → aparece em `/cientificos` com o filtro correto; editar reflete; arquivar/eliminar remove
- Categorias: criar/editar cor e ordem no admin → reflete na listagem e nos cards
- Detalhe: abstract box, keywords, autores grid, TOC dos h2, citation widget (3 estilos + copiar), referências, DOI sem link
- Toggle PT/EN: artigo com tradução muda a língua; sem tradução não mostra o toggle
- EN: artigos com tradução aparecem; sem tradução não aparecem na listagem EN
- Highwire meta tags + ScholarlyArticle no `<head>`
- Banner em `/artigos` + item no nav levam a `/cientificos`
- Dark mode correto em `.sci-*`
