# Módulo de Entrevistas — Plano de Implementação (Atualizado 2026-05-23)

> Plano atualizado do original de 2026-05-10. Mudanças: Supabase + fallback JSON, Admin CRUD completo, partilha reutilizada de article-detail.js, CSP compliance.

## Contexto

O plano original (10 de maio) propunha JSON local e sem admin CMS. Entretanto, o projeto evoluiu: CMS admin completo, API layer com Supabase + fallback JSON, SEO centralizado, CSP sem inline scripts, share buttons com Web Share API, etc.

Este plano atualiza a implementação para: **Supabase + fallback JSON + CRUD completo no admin**, seguindo os padrões estabelecidos (artigos, eventos, lives).

---

## Decisões Atualizadas vs. Plano Original

| Aspeto | Plano Original (10 Maio) | Plano Atualizado |
|--------|------------------------|-----------------|
| Armazenamento | JSON local | Supabase + fallback JSON |
| Admin CMS | Nenhum | CRUD completo (list/new/edit) |
| Layout detalhe | 2/3 + 1/3 sidebar | Igual (artigo.html) |
| Partilha | `share-utils.js` separado | Reutilizar padrão de `article-detail.js` |
| Vídeo | YouTube lazy load | YouTube lazy load (inalterado) |
| Categorias | 4 categorias | 4 categorias (inalterado) |
| CSP | Não considerado | Sem inline scripts |

---

## Supabase Schema — Tabela `interviews`

```sql
CREATE TABLE IF NOT EXISTS interviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  excerpt TEXT,
  category TEXT NOT NULL,
  category_label TEXT NOT NULL,
  interviewee JSONB NOT NULL DEFAULT '{}',
  interviewer JSONB DEFAULT '{}',
  date DATE,
  read_time INTEGER,
  video_duration TEXT,
  thumbnail_url TEXT,
  video_id TEXT,
  audio_url TEXT,
  executive_summary TEXT,
  pull_quotes TEXT[],
  qa JSONB DEFAULT '[]',
  content TEXT,
  references_arr TEXT[],
  related TEXT[],
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  featured BOOLEAN DEFAULT false,
  meta_description TEXT,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE interviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read published interviews"
  ON interviews FOR SELECT
  USING (status = 'published');

CREATE POLICY "Admins full access interviews"
  ON interviews FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));

-- Indexes
CREATE INDEX idx_interviews_status ON interviews(status);
CREATE INDEX idx_interviews_category ON interviews(category);
CREATE INDEX idx_interviews_featured ON interviews(featured) WHERE featured = true;
```

### Estrutura JSONB `interviewee`

```json
{
  "name": "Dra. Ana Silva",
  "role": "Farmacêutica Clínica · Hospital Nacional",
  "bio": "15 anos de experiência em farmácia hospitalar.",
  "avatar": "AS",
  "avatarBg": "#00493a"
}
```

### Estrutura JSONB `interviewer`

```json
{
  "name": "João Santos",
  "role": "Editor",
  "avatar": "JS",
  "avatarBg": "#0a844f"
}
```

### Estrutura JSONB `qa`

```json
[
  {
    "question": "Qual é o maior desafio da farmácia em Angola?",
    "answer": "A falta de recursos e a necessidade de formação contínua."
  }
]
```

### Categorias

| Key | Label |
|-----|-------|
| `profissionais` | Profissionais |
| `lideres` | Líderes |
| `educadores` | Educadores |
| `investigadores` | Investigadores |

### Category Colors

```js
const categoryColors = {
  profissionais: "#ff6c23",
  lideres: "#0a844f",
  educadores: "#002a32",
  investigadores: "#006171",
};
```

---

## Módulos Existentes Reutilizados

| Módulo | Funções reutilizáveis |
|--------|----------------------|
| `src/lib/api.js` | Padrão de normalização, fallback, delete com auth |
| `src/lib/seo.js` | `setDocumentTitle`, `setMetaDescription`, `setCanonicalUrl`, `setOpenGraphTags`, `setTwitterCardTags`, `injectJsonLd`, `buildArticleSchema`, `buildBreadcrumbSchema` |
| `src/lib/security.js` | `escapeHtml()`, `escapeAttr()`, `validateUrl()` |
| `src/lib/error-handler.js` | `errorHandler` |
| `src/breadcrumb.js` | `renderBreadcrumb()` |
| `src/lib/fallback-data.js` | Padrão de fallback JSON |
| `src/admin/lib/auth.js` | `checkAuth()`, `initIdleTimeout()` |
| `src/admin/lib/audit-logger.js` | `logAction()` |
| `src/admin/lib/preview.js` | Preview de Markdown |
| `src/article-detail.js` | `renderShareSection()` — padrão de partilha com Web Share API |
| `src/lib/logger.js` | `logger` |

---

## Task 1: Migration Supabase

**Ficheiro:** `src/migrations/018-create-interviews.sql`

Aplicar via MCP `apply_migration`. Schema completo acima.

---

## Task 2: API Layer

**Ficheiro:** `src/lib/api.js`

Adicionar:
- `normalizeInterview(row)` — snake_case → camelCase
- `getInterviews()` — SELECT_COLS WHERE status='published' ORDER BY date DESC
- `getInterviewBySlug(slug)` — SELECT * WHERE slug=... .single()
- `getAllInterviews()` — Admin, sem filtro status
- `deleteInterview(id)` — com verificação de sessão (SEC-API-02)

**Ficheiro:** `src/lib/fallback-data.js` — adicionar `getFallbackInterviews()` e `getFallbackInterviewBySlug()`

**Ficheiro:** `src/content/interviews-catalog.json` — 2 entrevistas de exemplo

---

## Task 3: Módulo de Vídeo

**Ficheiro novo:** `src/interview-video.js`

```js
export function loadYouTubePlayer(containerId, videoId, onReady) {
  // 1. Mostra thumbnail com botão play (onclick via addEventListener)
  // 2. Ao clicar, carrega YouTube IFrame API
  // 3. Inicializa player com autoplay=1
}
```

- Thumbnail: `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`
- Sem inline scripts — event listener via `addEventListener`
- YouTube API script carregado dinamicamente

---

## Task 4: CSS

**Ficheiro:** `src/input.css`

Adicionar no final:
1. `.interview-card` — cards com thumbnail
2. `.video-wrapper` — aspect-ratio 16/9
3. `.youtube-thumbnail`, `.play-button` — overlay de play
4. `.interview-summary-box` — sumário executivo
5. `.pull-quote` — com aspas decorativas
6. `.qa-section`, `.qa-item`, `.qa-question`, `.qa-answer` — timeline vertical
7. `.transcript-toggle`, `.transcript-content` — expansível
8. `.interviewee-card` — sidebar
9. Dark mode (`html.dark`) — variantes para todos

---

## Task 5: Listagem — `entrevistas.html` + `src/interviews-logic.js`

**Ficheiro novo:** `entrevistas.html`
- Hero, search, filtros de categoria (4), grid de cards
- Vite config: `entrevistas: resolve(__dirname, "entrevistas.html")`

**Ficheiro novo:** `src/interviews-logic.js`
- `getInterviews()` de `api.js`, `escapeHtml()` de `security.js`
- Filtros client-side: categoria, search
- Cards: thumbnail (play overlay se vídeo), badge, título, excerpt, entrevistado, duração
- Links: `entrevista.html?id={encodeURIComponent(slug)}`

---

## Task 6: Detalhe — `entrevista.html` + `src/interview-detail.js`

**Ficheiro novo:** `entrevista.html`
- Layout 2/3 + 1/3 sidebar (como `artigo.html`)
- Hero, vídeo (condicional), sumário, pull quotes, Markdown, Q&A, transcrição, referências
- Sidebar: entrevistado, entrevistador, share buttons, relacionados
- CDN: marked.js + DOMPurify com SRI (copiar de `artigo.html`)
- Vite config: `entrevista: resolve(__dirname, "entrevista.html")`

**Ficheiro novo:** `src/interview-detail.js`
- `getInterviewBySlug()`, `loadYouTubePlayer()`, `escapeHtml()`, `errorHandler`, `renderBreadcrumb()`, `seo.js`
- Secções condicionais: vídeo, sumário, pull quotes, Q&A, transcrição, referências, relacionados
- `renderShareSection()` — reutilizar padrão de `article-detail.js`
- DOMPurify hook img src
- SEO: meta tags + JSON-LD

---

## Task 7: Admin CMS

### 7a: Listagem `src/admin/entrevistas/index.html`
- `checkAuth()`, `initIdleTimeout()`, `supabaseClient`
- Tabela: título, entrevistado, categoria, status, data, ações
- Filtros, pesquisa, botões editar/eliminar

### 7b: Criar `src/admin/entrevistas/new.html`
- Campos: título, slug, categoria, status, featured
- Entrevistado: nome, role, bio, avatar, cor
- Entrevistador: nome, role, avatar, cor
- Vídeo ID, duração, thumbnail URL
- Sumário executivo, pull quotes (dinâmico), Q&A (dinâmico)
- Conteúdo Markdown (com preview)
- Referências (textarea, uma por linha)

### 7c: Editar `src/admin/entrevistas/edit.html`
- Mesmo formulário com dados pré-carregados

### 7d: Vite config
```
adminEntrevistasIndex, adminEntrevistasNew, adminEntrevistasEdit
```

---

## Task 8: Navegação

Adicionar link "Entrevistas" em:
- `.nav-links` (header desktop) — todos os HTML
- `.drawer-links` (mobile drawer) — todos os HTML
- `.footer-links` (footer) — todos os HTML

---

## Ficheiros Novos

| Ficheiro | Responsabilidade |
|----------|-----------------|
| `src/migrations/018-create-interviews.sql` | Migration Supabase |
| `src/content/interviews-catalog.json` | Catálogo fallback |
| `entrevistas.html` | Página de listagem |
| `entrevista.html` | Página de detalhe |
| `src/interviews-logic.js` | Lógica de listagem |
| `src/interview-detail.js` | Lógica de detalhe |
| `src/interview-video.js` | Módulo YouTube lazy load |
| `src/admin/entrevistas/index.html` | Admin listagem |
| `src/admin/entrevistas/new.html` | Admin criar |
| `src/admin/entrevistas/edit.html` | Admin editar |

## Ficheiros Modificados

| Ficheiro | Alteração |
|----------|----------|
| `src/lib/api.js` | normalizeInterview + 4 funções |
| `src/lib/fallback-data.js` | getFallbackInterviews/BySlug |
| `src/input.css` | Estilos entrevistas |
| `vite.config.js` | 5 entries |
| `src/admin/styles/admin.css` | Estilos formulário |
| ~12 HTML files | Link "Entrevistas" na nav |

---

## Ordem de Execução

1. Migration SQL (Supabase)
2. Catálogo JSON fallback + fallback-data.js
3. API functions (api.js)
4. Video module (interview-video.js)
5. CSS (input.css)
6. Listagem (entrevistas.html + interviews-logic.js)
7. Detalhe (entrevista.html + interview-detail.js)
8. Admin CMS (list/new/edit + vite config)
9. Navegação (header/drawer/footer)

---

## Verificação

### Funcional
1. `node --check` em todos JS
2. `npm run build` — sem erros
3. Cards com filtros categoria/search
4. Vídeo lazy load funciona
5. Sumário/pull quotes/Q&A condicionais
6. Transcrição expande/recolhe
7. Share buttons funcionam
8. Dark mode correto
9. Admin CRUD completo
10. Navegação "Entrevistas" em todas as páginas

### Segurança
11. `escapeHtml()` em innerHTML (SEC-XSS-01)
12. `encodeURIComponent()` em slugs (SEC-XSS-04)
13. DOMPurify hook (SEC-XSS-05)
14. Scripts CDN com SRI (SEC-HRD-02)
15. `rel="noopener noreferrer"` (SEC-FRM-03)
16. Admin `checkAuth()` + `initIdleTimeout()` (SEC-ATH-02/03)
17. Sem inline scripts (CSP)
18. RLS correto (SEC-SQL-01)
19. SELECT com colunas explícitas (SEC-API-03)
20. Delete com verificação de sessão (SEC-API-02)
