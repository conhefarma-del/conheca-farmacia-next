# Guias de Estudo — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar secção de Guias de Estudo com disciplinas essenciais, livros recomendados e recursos gratuitos para 4 cursos de saúde (Medicina, Farmácia, Enfermagem, Análises Clínicas), geridos via Supabase + Admin CMS.

**Architecture:** 4 tabelas Supabase (courses, disciplines, books, resources) com FK cascata. Página índice `guias.html` + 4 páginas de curso. Admin CRUD completo. Fallback JSON. CSP compliance.

**Tech Stack:** HTML5, Tailwind CSS v4, Vanilla JS (ES6+), Vite, Supabase (PostgreSQL, RLS, Auth)

---

## Verificação de Segurança (SECURITY_GUIDELINES.md)

| Guideline | Aplicação | Task |
|-----------|-----------|------|
| SEC-XSS-01 | `escapeHtml()` em TODAS as interpolações innerHTML — title, name, description, excerpt, phase, importance, team_paragraph, edition, author, resource.title, resource.description | 5, 6, 8-11 |
| SEC-XSS-02 | `escapeAttr()` em `value=""`, `alt=""`, `title=""`, `data-*` nos formulários admin | 9, 10, 11 |
| SEC-XSS-03 | `validateUrl()` em links de resources (url) e book links (url) | 6 |
| SEC-XSS-04 | `encodeURIComponent()` em slugs em URLs (course slug → link, discipline slug) | 5, 6 |
| SEC-XSS-05 | Imagens de capa `cover_url` de books: validar que URL começa com `https://` ou caminho relativo | 6 |
| SEC-API-01 | `normalizeGuideCourse/Discipline/Book/Resource()` — snake_case → camelCase | 2 |
| SEC-API-02 | `deleteGuide*()` — verificar sessão antes de eliminar | 2 |
| SEC-API-03 | SELECT público com colunas explícitas em `getGuideCourses()`, `getGuideDisciplinesByCourse()` | 2 |
| SEC-API-04 | `supabaseClient` via `config.js` — nunca duplicado | 2, 8-11 |
| SEC-ATH-02 | Admin pages importam `checkAuth` de `../lib/auth.js` — nunca check local | 8-11 |
| SEC-ATH-03 | `initIdleTimeout()` em todas as páginas admin | 8-11 |
| SEC-HRD-02 | Sem scripts CDN necessários (guias usam só módulos ES6) | N/A |
| SEC-FRM-01 | Sem formulários públicos (tudo é admin) | N/A |
| SEC-FRM-03 | Links `target="_blank"` com `rel="noopener noreferrer"` (book links, resource links) | 6 |
| SEC-AUD-01 | Colunas `created_at`, `updated_at` nas 4 tabelas | 1 |
| SEC-AUD-02 | Usar `logger` em vez de `console.log` | 5, 6 |
| SEC-AUD-03 | Sem `window.*` com chaves ou credenciais | 5, 6, 8-11 |
| SEC-UPL-01 | Imagens de capa via URL — sem upload direto (admin preenche URL) | 9, 11 |
| SEC-SQL-01 | RLS: público só lê `status='published'` nas 4 tabelas | 1 |
| SEC-SQL-03 | CHECK constraints em `status`, `type`; NOT NULL em campos obrigatórios; FK CASCADE em discipline_id, course_id | 1 |
| SEC-CSS-01 | Sem injeção de `<style>` via innerHTML | 5, 6 |
| SEC-CSS-02 | Variáveis CSS do tema para cores (`--color-brand-*`) | 4 |

---

## SEO (src/lib/seo.js)

### Página índice (`guias.html`)
- `setDocumentTitle('Guias de Estudo | Conheça Farmácia')`
- `setMetaDescription('Disciplinas, livros e recursos essenciais para cursos de saúde — Medicina, Farmácia, Enfermagem, Análises Clínicas.')`
- `setCanonicalUrl('https://conhecafarmacia.netlify.app/guias.html')`
- `setOpenGraphTags({ title, description, url })`
- `setTwitterCardTags({ title, description })`

### Páginas de curso (`farmacia.html`, etc.)
- `setDocumentTitle('{Curso} — Guias de Estudo | Conheça Farmácia')`
- `setMetaDescription('{heroSubtitle do curso}')`
- `setCanonicalUrl('https://conhecafarmacia.netlify.app/{slug}.html')`
- `setOpenGraphTags({ title, description, url })`
- `setTwitterCardTags({ title, description })`
- `buildBreadcrumbSchema([{name: 'Guias de Estudo', url: 'guias.html'}, {name: '{Curso}'}])` + `injectJsonLd()`

---

## Schema Supabase

### `guide_courses`

```sql
CREATE TABLE guide_courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  hero_subtitle TEXT,
  icon_emoji TEXT,
  color TEXT DEFAULT '#0a844f',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE guide_courses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read published" ON guide_courses FOR SELECT USING (status = 'published');
CREATE POLICY "Admin full access" ON guide_courses FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
CREATE TRIGGER update_guide_courses_updated_at BEFORE UPDATE ON guide_courses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### `guide_disciplines`

```sql
CREATE TABLE guide_disciplines (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  course_id UUID NOT NULL REFERENCES guide_courses(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  phase TEXT,
  importance TEXT,
  sort_order INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE guide_disciplines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read published" ON guide_disciplines FOR SELECT USING (status = 'published');
CREATE POLICY "Admin full access" ON guide_disciplines FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
CREATE INDEX idx_guide_disciplines_course ON guide_disciplines(course_id);
```

### `guide_books`

```sql
CREATE TABLE guide_books (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discipline_id UUID NOT NULL REFERENCES guide_disciplines(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  author TEXT,
  edition TEXT,
  year INTEGER,
  cover_url TEXT,
  team_paragraph TEXT,
  links JSONB DEFAULT '[]',
  sort_order INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE guide_books ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read published" ON guide_books FOR SELECT USING (status = 'published');
CREATE POLICY "Admin full access" ON guide_books FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
CREATE INDEX idx_guide_books_discipline ON guide_books(discipline_id);
```

`links` JSONB formato: `[{"label": "Comprar na Amazon", "url": "https://..."}, {"label": "Ver na Editora", "url": "https://..."}]`

### `guide_resources`

```sql
CREATE TABLE guide_resources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  discipline_id UUID NOT NULL REFERENCES guide_disciplines(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  url TEXT NOT NULL,
  type TEXT DEFAULT 'pdf' CHECK (type IN ('pdf', 'guideline', 'article', 'other')),
  sort_order INTEGER DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE guide_resources ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read published" ON guide_resources FOR SELECT USING (status = 'published');
CREATE POLICY "Admin full access" ON guide_resources FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
CREATE INDEX idx_guide_resources_discipline ON guide_resources(discipline_id);
```

---

## Módulos Reutilizados

| Módulo | Funções |
|--------|---------|
| `src/lib/api.js` | Padrão de normalização, fallback, delete com auth |
| `src/lib/seo.js` | `setDocumentTitle`, `setMetaDescription`, `setCanonicalUrl`, `setOpenGraphTags`, `setTwitterCardTags`, `injectJsonLd`, `buildBreadcrumbSchema` |
| `src/lib/security.js` | `escapeHtml()`, `escapeAttr()` |
| `src/lib/error-handler.js` | `errorHandler` |
| `src/breadcrumb.js` | `renderBreadcrumb()` |
| `src/admin/lib/auth.js` | `checkAuth()`, `initIdleTimeout()` |
| `src/admin/lib/audit-logger.js` | `logAction()` |

---

## Task 1: Migration SQL

**Ficheiro:** `src/migrations/019-create-guide-tables.sql`

- [ ] **Step 1: Criar ficheiro de migration**
      Criar `src/migrations/019-create-guide-tables.sql` com os 4 CREATE TABLE, RLS policies, indexes e triggers definidos no schema acima.

- [ ] **Step 2: Aplicar migration no Supabase via MCP**
      Usar `apply_migration` com project_id `tbqsazriorqzexjwhekw`. Verificar com `list_tables`.

- [ ] **Step 3: Commit**

```bash
git add src/migrations/019-create-guide-tables.sql
git commit -m "feat: add guide tables (courses, disciplines, books, resources) with RLS"
```

---

## Task 2: API Functions em `src/lib/api.js`

**Ficheiro:** `src/lib/api.js`

- [ ] **Step 1: Adicionar normalização**
      Após as funções existentes, adicionar:
```js
// --- Guides ---

function normalizeGuideCourse(row) {
  return {
    id: row.id,
    slug: row.slug,
    name: row.name,
    description: row.description,
    heroSubtitle: row.hero_subtitle,
    iconEmoji: row.icon_emoji,
    color: row.color || '#0a844f',
    status: row.status,
    sortOrder: row.sort_order,
  };
}

function normalizeGuideDiscipline(row) {
  return {
    id: row.id,
    slug: row.slug,
    courseId: row.course_id,
    name: row.name,
    description: row.description,
    phase: row.phase,
    importance: row.importance,
    sortOrder: row.sort_order,
    status: row.status,
  };
}

function normalizeGuideBook(row) {
  return {
    id: row.id,
    disciplineId: row.discipline_id,
    title: row.title,
    author: row.author,
    edition: row.edition,
    year: row.year,
    coverUrl: row.cover_url,
    teamParagraph: row.team_paragraph,
    links: row.links || [],
    sortOrder: row.sort_order,
    status: row.status,
  };
}

function normalizeGuideResource(row) {
  return {
    id: row.id,
    disciplineId: row.discipline_id,
    title: row.title,
    description: row.description,
    url: row.url,
    type: row.type || 'pdf',
    sortOrder: row.sort_order,
    status: row.status,
  };
}
```

- [ ] **Step 2: Adicionar funções de busca**

**Segurança:** SEC-API-02 (delete com verificação de sessão), SEC-API-03 (SELECT com colunas explícitas), SEC-API-04 (supabaseClient via config.js).

```js
const COURSE_COLS = 'id, slug, name, description, hero_subtitle, icon_emoji, color, status, sort_order';
const DISCIPLINE_COLS = 'id, slug, course_id, name, description, phase, importance, sort_order, status';

export async function getGuideCourses() {
  try {
    const { data, error } = await supabaseClient
      .from('guide_courses')
      .select(COURSE_COLS)  // SEC-API-03: colunas explícitas
      .eq('status', 'published')
      .order('sort_order', { ascending: true });
    if (error) throw error;
    return (data || []).map(normalizeGuideCourse);
  } catch (err) {
    logger.warn('getGuideCourses fallback:', err.message);
    const { getFallbackGuideCourses } = await import('./fallback-data.js');
    return getFallbackGuideCourses();
  }
}

export async function getGuideCourseBySlug(slug) {
  try {
    const { data, error } = await supabaseClient
      .from('guide_courses')
      .select('*')
      .eq('slug', slug)
      .eq('status', 'published')
      .single();
    if (error) throw error;
    return data ? normalizeGuideCourse(data) : null;
  } catch (err) {
    logger.warn('getGuideCourseBySlug fallback:', err.message);
    const { getFallbackGuideCourseBySlug } = await import('./fallback-data.js');
    return getFallbackGuideCourseBySlug(slug);
  }
}

export async function getGuideDisciplinesByCourse(courseId) {
  try {
    const { data, error } = await supabaseClient
      .from('guide_disciplines')
      .select('id, slug, course_id, name, description, phase, importance, sort_order, status')
      .eq('course_id', courseId)
      .eq('status', 'published')
      .order('sort_order', { ascending: true });
    if (error) throw error;
    return (data || []).map(normalizeGuideDiscipline);
  } catch (err) {
    logger.warn('getGuideDisciplinesByCourse fallback:', err.message);
    const { getFallbackGuideDisciplinesByCourse } = await import('./fallback-data.js');
    return getFallbackGuideDisciplinesByCourse(courseId);
  }
}

export async function getGuideBooksByDiscipline(disciplineId) {
  try {
    const { data, error } = await supabaseClient
      .from('guide_books')
      .select('*')
      .eq('discipline_id', disciplineId)
      .eq('status', 'published')
      .order('sort_order', { ascending: true });
    if (error) throw error;
    return (data || []).map(normalizeGuideBook);
  } catch (err) {
    logger.warn('getGuideBooksByDiscipline fallback:', err.message);
    return [];
  }
}

export async function getGuideResourcesByDiscipline(disciplineId) {
  try {
    const { data, error } = await supabaseClient
      .from('guide_resources')
      .select('*')
      .eq('discipline_id', disciplineId)
      .eq('status', 'published')
      .order('sort_order', { ascending: true });
    if (error) throw error;
    return (data || []).map(normalizeGuideResource);
  } catch (err) {
    logger.warn('getGuideResourcesByDiscipline fallback:', err.message);
    return [];
  }
}

export async function getAllGuideCourses() {
  try {
    const { data, error } = await supabaseClient
      .from('guide_courses')
      .select('*')
      .order('sort_order', { ascending: true });
    if (error) throw error;
    return (data || []).map(normalizeGuideCourse);
  } catch (err) {
    logger.error('getAllGuideCourses:', err.message);
    return [];
  }
}

export async function getAllGuideDisciplines(courseId) {
  try {
    let query = supabaseClient
      .from('guide_disciplines')
      .select('*')
      .order('sort_order', { ascending: true });
    if (courseId) query = query.eq('course_id', courseId);
    const { data, error } = await query;
    if (error) throw error;
    return (data || []).map(normalizeGuideDiscipline);
  } catch (err) {
    logger.error('getAllGuideDisciplines:', err.message);
    return [];
  }
}

export async function deleteGuideCourse(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized');
  return supabaseClient.from('guide_courses').delete().eq('id', id);
}

export async function deleteGuideDiscipline(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized');
  return supabaseClient.from('guide_disciplines').delete().eq('id', id);
}

export async function deleteGuideBook(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized');
  return supabaseClient.from('guide_books').delete().eq('id', id);
}

export async function deleteGuideResource(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized');
  return supabaseClient.from('guide_resources').delete().eq('id', id);
}
```

- [ ] **Step 3: Validar sintaxe**
      Run: `node --check src/lib/api.js`

- [ ] **Step 4: Commit**

```bash
git add src/lib/api.js
git commit -m "feat: add guide API functions (courses, disciplines, books, resources)"
```

---

## Task 3: Fallback Data

**Ficheiros:**
- Create: `src/content/guides-catalog.json`
- Modify: `src/lib/fallback-data.js`

- [ ] **Step 1: Criar catálogo JSON de fallback**
      Criar `src/content/guides-catalog.json` com os 4 cursos e disciplinas de exemplo. Farmácia e Medicina com dados reais (5 disciplinas cada, 2 livros por disciplina). Enfermagem e Análises Clínicas com placeholders (3 disciplinas cada, 1 livro por disciplina).

      Estrutura:
```json
{
  "courses": [
    {
      "id": "farmacia-001",
      "slug": "farmacia",
      "name": "Farmácia",
      "description": "Formação centrada na descoberta, desenvolvimento, produção e uso racional de medicamentos.",
      "heroSubtitle": "Do laboratório ao balcão — a ciência que protege a saúde.",
      "iconEmoji": "💊",
      "color": "#0a844f",
      "status": "published",
      "sortOrder": 1,
      "disciplines": [
        {
          "id": "farm-farmacologia",
          "slug": "farmacologia",
          "courseId": "farmacia-001",
          "name": "Farmacologia",
          "description": "Estudo dos fármacos, mecanismos de ação, efeitos terapêuticos e adversos.",
          "phase": "2º Ano",
          "importance": "Base fundamental para qualquer profissional que lida com medicamentos. Sem farmacologia, o farmacêutico não consegue compreender interações medicamentosas nem aconselhar doentes.",
          "sortOrder": 1,
          "status": "published",
          "books": [
            {
              "id": "b001",
              "title": "Goodman & Gilman's The Pharmacological Basis of Therapeutics",
              "author": "Laurence L. Brunton, Bjorn Knollmann",
              "edition": "14ª Edição",
              "year": 2023,
              "coverUrl": "https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1681245397i/63289543.jpg",
              "teamParagraph": "Considerado a bíblia da farmacologia. Este livro é essencial para qualquer estudante de farmácia ou medicina que queira uma compreensão profunda dos mecanismos de ação dos fármacos.",
              "links": [
                {"label": "Comprar na Amazon", "url": "https://www.amazon.com/dp/1260464164"},
                {"label": "Ver na Editora", "url": "https://www.mhprofessional.com"}
              ],
              "sortOrder": 1,
              "status": "published"
            }
          ],
          "resources": [
            {
              "id": "r001",
              "title": "Lista de Medicamentos Essenciais OMS 2025",
              "description": "Lista atualizada de medicamentos essenciais pela Organização Mundial da Saúde.",
              "url": "https://www.who.int/publications/i/item/EML2025",
              "type": "guideline",
              "sortOrder": 1,
              "status": "published"
            }
          ]
        }
      ]
    }
  ]
}
```

      Continuar com o mesmo padrão para: Farmácia (Farmacologia, Química Farmacêutica, Farmácia Clínica, Botânica Farmacêutica, Microbiologia), Medicina (Anatomia, Fisiologia, Bioquímica, Patologia, Farmacologia), Enfermagem (3 disciplinas placeholder), Análises Clínicas (3 disciplinas placeholder).

- [ ] **Step 2: Adicionar funções de fallback**
      Em `src/lib/fallback-data.js`, adicionar:
```js
import guidesData from '../content/guides-catalog.json';

export function getFallbackGuideCourses() {
  return (guidesData.courses || []).map(c => ({
    id: c.id, slug: c.slug, name: c.name, description: c.description,
    heroSubtitle: c.heroSubtitle, iconEmoji: c.iconEmoji, color: c.color,
    status: c.status, sortOrder: c.sortOrder,
  }));
}

export function getFallbackGuideCourseBySlug(slug) {
  const course = (guidesData.courses || []).find(c => c.slug === slug);
  if (!course) return null;
  return {
    id: course.id, slug: course.slug, name: course.name,
    description: course.description, heroSubtitle: course.heroSubtitle,
    iconEmoji: course.iconEmoji, color: course.color,
    status: course.status, sortOrder: course.sortOrder,
  };
}

export function getFallbackGuideDisciplinesByCourse(courseId) {
  const course = (guidesData.courses || []).find(c => c.id === courseId);
  if (!course) return [];
  return (course.disciplines || []).map(d => ({
    id: d.id, slug: d.slug, courseId: d.courseId, name: d.name,
    description: d.description, phase: d.phase, importance: d.importance,
    sortOrder: d.sortOrder, status: d.status,
  }));
}
```

- [ ] **Step 3: Validar sintaxe**
      Run: `node --check src/lib/fallback-data.js`

- [ ] **Step 4: Commit**

```bash
git add src/content/guides-catalog.json src/lib/fallback-data.js
git commit -m "feat: add guides fallback data with sample courses and disciplines"
```

---

## Task 4: CSS — Estilos para Guias

**Ficheiro:** `src/input.css`

- [ ] **Step 1: Estilos da página índice**
      Adicionar no final de `src/input.css`:
```css
/* =============================================
   GUIDE STYLES
   ============================================= */

/* Index page — course cards */
.guide-course-card {
  @apply rounded-2xl border border-brand-divider/10 bg-white
    p-6 md:p-8 hover:shadow-soft transition-all duration-300
    cursor-pointer;
}

.guide-course-card:hover {
  @apply -translate-y-1;
}

.guide-course-emoji {
  @apply text-4xl mb-4;
}

.guide-course-name {
  @apply text-xl md:text-2xl font-bold text-brand-deep mb-2;
}

.guide-course-desc {
  @apply text-sm text-brand-deep/60 mb-3;
}

.guide-course-count {
  @apply text-xs font-semibold text-brand-accent;
}

/* Course page — discipline cards */
.guide-discipline-card {
  @apply rounded-2xl border border-brand-divider/10 bg-white
    overflow-hidden transition-all duration-300;
}

.guide-discipline-header {
  @apply flex items-center justify-between p-6 cursor-pointer
    hover:bg-brand-bg-alt/50 transition-colors;
}

.guide-discipline-header:hover {
  @apply bg-brand-bg-alt;
}

.guide-discipline-name {
  @apply text-lg font-bold text-brand-deep;
}

.guide-discipline-phase {
  @apply text-xs font-semibold px-2 py-1 rounded-full
    bg-brand-accent/10 text-brand-accent;
}

.guide-discipline-toggle {
  @apply w-5 h-5 text-brand-deep/40 transition-transform duration-300;
}

.guide-discipline-toggle.expanded {
  @apply rotate-180;
}

.guide-discipline-content {
  @apply px-6 pb-6 space-y-6;
}

.guide-discipline-desc {
  @apply text-brand-deep/70 text-sm;
}

.guide-importance-box {
  @apply bg-brand-accent/5 border-l-4 border-brand-accent rounded-r-xl
    p-4 text-sm text-brand-deep/80;
}

.guide-importance-label {
  @apply text-xs font-bold uppercase tracking-wider text-brand-accent mb-2;
}

/* Book cards */
.guide-book-card {
  @apply flex gap-4 p-4 rounded-xl bg-brand-bg-alt/50;
}

.guide-book-cover {
  @apply flex-shrink-0 w-24 h-36 object-cover rounded-lg shadow-sm;
}

.guide-book-info {
  @apply flex-1;
}

.guide-book-title {
  @apply font-bold text-brand-deep mb-1;
}

.guide-book-meta {
  @apply text-xs text-brand-deep/50 mb-2;
}

.guide-book-paragraph {
  @apply text-sm text-brand-deep/70 mb-3;
}

.guide-book-links {
  @apply flex flex-wrap gap-2;
}

.guide-book-link {
  @apply text-xs font-semibold px-3 py-1.5 rounded-lg
    border border-brand-accent/30 text-brand-accent
    hover:bg-brand-accent hover:text-white hover:border-brand-accent
    transition-all;
}

/* Section labels */
.guide-section-label {
  @apply text-xs font-bold uppercase tracking-wider text-brand-deep/40
    mb-3 flex items-center gap-2;
}

.guide-section-label::after {
  content: "";
  @apply flex-1 h-px bg-brand-divider/20;
}

/* Resources */
.guide-resource-link {
  @apply flex items-center gap-3 p-3 rounded-lg
    hover:bg-brand-bg-alt transition-colors text-sm;
}

.guide-resource-icon {
  @apply flex-shrink-0 w-8 h-8 rounded-lg bg-brand-accent/10
    flex items-center justify-center text-brand-accent text-xs;
}

.guide-resource-title {
  @apply font-medium text-brand-deep;
}

.guide-resource-desc {
  @apply text-xs text-brand-deep/50;
}

/* Other courses links */
.guide-other-courses {
  @apply flex flex-wrap gap-3 mt-8;
}

.guide-other-link {
  @apply inline-flex items-center gap-2 px-4 py-2 rounded-xl
    border border-brand-divider/20 text-sm font-medium text-brand-deep/70
    hover:border-brand-accent hover:text-brand-accent transition-all;
}

/* Dark mode */
html.dark .guide-course-card,
html.dark .guide-discipline-card {
  @apply bg-brand-deep border-brand-divider/20;
}

html.dark .guide-course-name,
html.dark .guide-discipline-name,
html.dark .guide-book-title {
  @apply text-white;
}

html.dark .guide-course-desc,
html.dark .guide-discipline-desc,
html.dark .guide-book-paragraph {
  @apply text-white/60;
}

html.dark .guide-discipline-header:hover {
  @apply bg-white/5;
}

html.dark .guide-book-card {
  @apply bg-white/5;
}

html.dark .guide-resource-link:hover {
  @apply bg-white/5;
}

html.dark .guide-importance-box {
  @apply bg-brand-accent/10;
}

html.dark .guide-other-link {
  @apply text-white/60 border-white/10;
}

html.dark .guide-book-link {
  @apply border-brand-accent/40;
}
```

- [ ] **Step 2: Verificar build**
      Run: `npm run build`

- [ ] **Step 3: Commit**

```bash
git add src/input.css
git commit -m "feat: add CSS styles for study guides (courses, disciplines, books, resources)"
```

---

## Task 5: Página Índice — `guias.html` + `src/guia-logic.js`

**Ficheiros:**
- Create: `guias.html`
- Create: `src/guia-logic.js`
- Modify: `vite.config.js`

- [ ] **Step 1: Criar `guias.html`**
      Seguir padrão de `artigos.html` (header, drawer, footer). Conteúdo:
```html
<!-- Hero -->
<section class="articles-hero">
  <div class="container-center">
    <div class="text-center py-20 md:py-32">
      <h1 class="text-5xl md:text-7xl font-bold text-brand-deep mb-6">Guias de Estudo</h1>
      <p class="hero-subtitle">Disciplinas, livros e recursos essenciais para cursos de saúde.</p>
    </div>
  </div>
</section>

<!-- Grid de Cursos -->
<section class="section-padding bg-brand-bg-alt">
  <div class="container-center">
    <div id="guides-grid" class="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
      <!-- Cards rendered by JS -->
    </div>
  </div>
</section>
```

      Scripts: `<script type="module" src="/main.js"></script>` + `<script type="module" src="/src/guia-logic.js"></script>`

- [ ] **Step 2: Criar `src/guia-logic.js`**
```js
import { getGuideCourses } from './lib/api.js';
import { escapeHtml } from './lib/security.js';
import { logger } from './lib/logger.js';
import {
  setDocumentTitle,
  setMetaDescription,
  setCanonicalUrl,
  setOpenGraphTags,
  setTwitterCardTags,
} from './lib/seo.js';

// SEO — SEC-XSS-01: escapeHtml em innerHTML, SEC-AUD-02: logger em vez de console.log
setDocumentTitle('Guias de Estudo | Conheça Farmácia');
setMetaDescription('Disciplinas, livros e recursos essenciais para cursos de saúde — Medicina, Farmácia, Enfermagem, Análises Clínicas.');
setCanonicalUrl('https://conhecafarmacia.netlify.app/guias.html');
setOpenGraphTags({
  title: 'Guias de Estudo | Conheça Farmácia',
  description: 'Disciplinas, livros e recursos essenciais para cursos de saúde.',
  url: 'https://conhecafarmacia.netlify.app/guias.html',
});
setTwitterCardTags({
  title: 'Guias de Estudo | Conheça Farmácia',
  description: 'Disciplinas, livros e recursos essenciais para cursos de saúde.',
});

const coursePages = {
  'medicina': 'medicina.html',
  'farmacia': 'farmacia.html',
  'enfermagem': 'enfermagem.html',
  'analises-clinicas': 'analises-clinicas.html',
};

document.addEventListener('DOMContentLoaded', async () => {
  const grid = document.getElementById('guides-grid');
  if (!grid) return;

  try {
    const courses = await getGuideCourses();
    grid.innerHTML = '';

    if (courses.length === 0) {
      grid.innerHTML = '<p class="text-center text-brand-deep/50 col-span-2">Em breve — guias de estudo em preparação.</p>';
      return;
    }

    courses.forEach(course => {
      const card = document.createElement('a');
      const page = coursePages[course.slug] || `${course.slug}.html`;
      card.href = page;
      card.className = 'guide-course-card';

      card.innerHTML = `
        <div class="guide-course-emoji">${escapeHtml(course.iconEmoji || '📚')}</div>
        <h2 class="guide-course-name">${escapeHtml(course.name)}</h2>
        <p class="guide-course-desc">${escapeHtml(course.description || '')}</p>
        <span class="guide-course-count">Ver disciplinas →</span>
      `;
      grid.appendChild(card);
    });
  } catch (err) {
    logger.error('Error loading guide courses:', err);
    grid.innerHTML = '<p class="text-center text-red-500">Erro ao carregar guias.</p>';
  }
});
```

- [ ] **Step 3: Adicionar entry no Vite config**
      Em `vite.config.js`, adicionar ao `rollupOptions.input`:
```js
guias: resolve(__dirname, "guias.html"),
```

- [ ] **Step 4: Validar sintaxe**
      Run: `node --check src/guia-logic.js`

- [ ] **Step 5: Commit**

```bash
git add guias.html src/guia-logic.js vite.config.js
git commit -m "feat: add study guides index page (guias.html)"
```

---

## Task 6: Lógica de Curso — `src/guia-curso-logic.js`

**Ficheiro:** Create: `src/guia-curso-logic.js`

- [ ] **Step 1: Implementar a lógica completa**

**Segurança:** SEC-XSS-01 (`escapeHtml` em todas as interpolações), SEC-XSS-03 (`validateUrl` em links externos de books e resources), SEC-XSS-04 (`encodeURIComponent` em slugs), SEC-FRM-03 (`rel="noopener noreferrer"` em `target="_blank"`), SEC-AUD-02 (`logger` em vez de `console.log`).

```js
import { getGuideCourseBySlug, getGuideDisciplinesByCourse, getGuideBooksByDiscipline, getGuideResourcesByDiscipline } from './lib/api.js';
import { escapeHtml, validateUrl } from './lib/security.js';
import { renderBreadcrumb } from './breadcrumb.js';
import { errorHandler } from './lib/error-handler.js';
import { logger } from './lib/logger.js';
import {
  setDocumentTitle,
  setMetaDescription,
  setCanonicalUrl,
  setOpenGraphTags,
  setTwitterCardTags,
  injectJsonLd,
  buildBreadcrumbSchema,
} from './lib/seo.js';

const otherCourses = [
  { slug: 'medicina', name: 'Medicina', emoji: '🩺' },
  { slug: 'farmacia', name: 'Farmácia', emoji: '💊' },
  { slug: 'enfermagem', name: 'Enfermagem', emoji: '🩹' },
  { slug: 'analises-clinicas', name: 'Análises Clínicas', emoji: '🔬' },
];

function renderDiscipline(discipline, books, resources) {
  const section = document.createElement('div');
  section.className = 'guide-discipline-card';

  const headerId = `disc-header-${discipline.id}`;
  const contentId = `disc-content-${discipline.id}`;

  section.innerHTML = `
    <div class="guide-discipline-header" id="${headerId}" aria-expanded="false" aria-controls="${contentId}" role="button" tabindex="0">
      <div>
        <h3 class="guide-discipline-name">${escapeHtml(discipline.name)}</h3>
        <p class="text-xs text-brand-deep/50 mt-1">${escapeHtml(discipline.description || '')}</p>
      </div>
      <div class="flex items-center gap-3">
        <span class="guide-discipline-phase">${escapeHtml(discipline.phase || '')}</span>
        <svg class="guide-discipline-toggle" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M6 9l6 6 6-6"/>
        </svg>
      </div>
    </div>
    <div class="guide-discipline-content" id="${contentId}" style="display: none;">
      ${discipline.importance ? `
        <div class="guide-importance-box">
          <div class="guide-importance-label">Porquê é essencial</div>
          <p>${escapeHtml(discipline.importance)}</p>
        </div>
      ` : ''}

      ${books.length > 0 ? `
        <div class="guide-section-label">Livros Essenciais</div>
        <div class="space-y-4">
          ${books.map(book => renderBook(book)).join('')}
        </div>
      ` : ''}

      ${resources.length > 0 ? `
        <div class="guide-section-label">Recursos Gratuitos</div>
        <div class="space-y-2">
          ${resources.map(resource => renderResource(resource)).join('')}
        </div>
      ` : ''}
    </div>
  `;

  // Toggle expand/collapse
  const header = section.querySelector('.guide-discipline-header');
  const content = section.querySelector('.guide-discipline-content');
  const toggle = section.querySelector('.guide-discipline-toggle');

  header.addEventListener('click', () => {
    const isExpanded = content.style.display !== 'none';
    content.style.display = isExpanded ? 'none' : 'block';
    header.setAttribute('aria-expanded', !isExpanded);
    toggle.classList.toggle('expanded', !isExpanded);
  });

  header.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      header.click();
    }
  });

  return section;
}

function renderBook(book) {
  const linksHtml = (book.links || []).map(link =>
    `<a href="${validateUrl(link.url)}" target="_blank" rel="noopener noreferrer" class="guide-book-link">${escapeHtml(link.label)}</a>`
  ).join('');

  return `
    <div class="guide-book-card">
      ${book.coverUrl ? `<img src="${escapeHtml(book.coverUrl)}" alt="${escapeHtml(book.title)}" class="guide-book-cover" loading="lazy" />` : ''}
      <div class="guide-book-info">
        <h4 class="guide-book-title">${escapeHtml(book.title)}</h4>
        <p class="guide-book-meta">${escapeHtml(book.author || '')}${book.edition ? ` · ${escapeHtml(book.edition)}` : ''}${book.year ? ` · ${book.year}` : ''}</p>
        ${book.teamParagraph ? `<p class="guide-book-paragraph">${escapeHtml(book.teamParagraph)}</p>` : ''}
        ${linksHtml ? `<div class="guide-book-links">${linksHtml}</div>` : ''}
      </div>
    </div>
  `;
}

function renderResource(resource) {
  const iconMap = { pdf: '📄', guideline: '📋', article: '📰', other: '🔗' };
  const icon = iconMap[resource.type] || '🔗';

  return `
    <a href="${validateUrl(resource.url)}" target="_blank" rel="noopener noreferrer" class="guide-resource-link">
      <div class="guide-resource-icon">${icon}</div>
      <div>
        <div class="guide-resource-title">${escapeHtml(resource.title)}</div>
        ${resource.description ? `<div class="guide-resource-desc">${escapeHtml(resource.description)}</div>` : ''}
      </div>
    </a>
  `;
}

function renderOtherCourses(currentSlug) {
  const container = document.getElementById('other-courses');
  if (!container) return;

  otherCourses
    .filter(c => c.slug !== currentSlug)
    .forEach(course => {
      const link = document.createElement('a');
      link.href = `${course.slug}.html`;
      link.className = 'guide-other-link';
      link.innerHTML = `${course.emoji} ${escapeHtml(course.name)}`;
      container.appendChild(link);
    });
}

async function loadCourse() {
  const slug = document.body.dataset.courseSlug;
  if (!slug) {
    errorHandler.handle(new Error('Course slug not found'), 'PAGE', 'Curso não encontrado');
    return;
  }

  try {
    const course = await getGuideCourseBySlug(slug);
    if (!course) {
      errorHandler.handle(new Error(`Course ${slug} not found`), 'PAGE', 'Curso não encontrado');
      return;
    }

    // SEO
    setDocumentTitle(`${course.name} — Guias de Estudo | Conheça Farmácia`);
    setMetaDescription(course.description || `Disciplinas, livros e recursos essenciais para o curso de ${course.name}.`);
    setCanonicalUrl(`https://conhecafarmacia.netlify.app/${slug}.html`);
    setOpenGraphTags({
      title: `${course.name} — Guias de Estudo`,
      description: course.description,
      url: `https://conhecafarmacia.netlify.app/${slug}.html`,
    });
    setTwitterCardTags({
      title: `${course.name} — Guias de Estudo`,
      description: course.description,
    });

    // Breadcrumb
    renderBreadcrumb([
      { label: 'Guias de Estudo', href: 'guias.html' },
      { label: course.name },
    ]);

    // Hero
    const emojiEl = document.getElementById('course-emoji');
    const nameEl = document.getElementById('course-name');
    const subtitleEl = document.getElementById('course-subtitle');
    if (emojiEl) emojiEl.textContent = course.iconEmoji || '📚';
    if (nameEl) nameEl.textContent = course.name;
    if (subtitleEl) subtitleEl.textContent = course.heroSubtitle || '';

    // Disciplines
    const disciplines = await getGuideDisciplinesByCourse(course.id);
    const container = document.getElementById('disciplines-container');
    if (!container) return;

    container.innerHTML = '';

    for (const disc of disciplines) {
      const [books, resources] = await Promise.all([
        getGuideBooksByDiscipline(disc.id),
        getGuideResourcesByDiscipline(disc.id),
      ]);
      const card = renderDiscipline(disc, books, resources);
      container.appendChild(card);
    }

    if (disciplines.length === 0) {
      container.innerHTML = '<p class="text-center text-brand-deep/50">Disciplinas em preparação.</p>';
    }

    // Other courses
    renderOtherCourses(slug);

  } catch (err) {
    logger.error('Error loading course:', err);
    errorHandler.handle(err, 'PAGE', 'Erro ao carregar curso');
  }
}

document.addEventListener('DOMContentLoaded', loadCourse);
```

- [ ] **Step 2: Validar sintaxe**
      Run: `node --check src/guia-curso-logic.js`

- [ ] **Step 3: Commit**

```bash
git add src/guia-curso-logic.js
git commit -m "feat: add course page logic with expandable disciplines, books and resources"
```

---

## Task 7: Páginas de Curso — `farmacia.html`, `medicina.html`, `enfermagem.html`, `analises-clinicas.html`

**Ficheiros:**
- Create: `farmacia.html`
- Create: `medicina.html`
- Create: `enfermagem.html`
- Create: `analises-clinicas.html`
- Modify: `vite.config.js`

- [ ] **Step 1: Criar template de página de curso**
      Todas as 4 páginas seguem o mesmo template (header, drawer, footer de `artigos.html`). A única diferença é `data-course-slug` no `<body>` e o título. SEO dinâmico via `guia-curso-logic.js` (Task 6).

      Template (exemplo Farmácia — repetir para Medicina, Enfermagem, Análises Clínicas):
```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Farmácia — Guias de Estudo | Conheça Farmácia</title>
  <meta name="description" content="">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="">
  <meta property="og:type" content="website">
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet" />
</head>
<body class="antialiased text-brand-deep bg-brand-bg" data-course-slug="farmacia">
  <!-- Header (copiar de artigos.html) -->
  <!-- Drawer (copiar de artigos.html) -->

  <main>
    <!-- Breadcrumb -->
    <section class="article-hero">
      <div class="container-center" id="breadcrumb-container"></div>
    </section>

    <!-- Hero -->
    <section class="article-hero">
      <div class="container-center">
        <div class="flex items-center gap-4 mb-4">
          <span id="course-emoji" class="text-5xl"></span>
          <h1 id="course-name" class="article-hero-title"></h1>
        </div>
        <p id="course-subtitle" class="hero-subtitle"></p>
      </div>
    </section>

    <!-- Disciplines -->
    <section class="section-padding">
      <div class="container-center max-w-4xl mx-auto">
        <div id="disciplines-container" class="space-y-6">
          <!-- Disciplines rendered by JS -->
        </div>
      </div>
    </section>

    <!-- Other Courses -->
    <section class="section-padding bg-brand-bg-alt">
      <div class="container-center">
        <h2 class="text-lg font-bold text-brand-deep mb-4">Outros Cursos</h2>
        <div id="other-courses" class="guide-other-courses"></div>
      </div>
    </section>
  </main>

  <!-- Footer (copiar de artigos.html) -->

  <script type="module" src="/main.js"></script>
  <script type="module" src="/src/guia-curso-logic.js"></script>
</body>
</html>
```

      Copiar 4 vezes, alterando: `data-course-slug`, `<title>`, e meta description.

- [ ] **Step 2: Adicionar entries no Vite config**
      Em `vite.config.js`:
```js
farmacia: resolve(__dirname, "farmacia.html"),
medicina: resolve(__dirname, "medicina.html"),
enfermagem: resolve(__dirname, "enfermagem.html"),
analisesClinicas: resolve(__dirname, "analises-clinicas.html"),
```

- [ ] **Step 3: Commit**

```bash
git add farmacia.html medicina.html enfermagem.html analises-clinicas.html vite.config.js
git commit -m "feat: add course pages for Farmácia, Medicina, Enfermagem, Análises Clínicas"
```

---

## Task 8: Admin — Listagem de Cursos (`src/admin/guias/index.html`)

**Ficheiro:** Create: `src/admin/guias/index.html`

- [ ] **Step 1: Criar página de listagem**
      Seguir padrão de `src/admin/artigos/index.html`. Sidebar com link "Guias de Estudo".
      **Segurança:** SEC-ATH-02: importar `checkAuth`, `logout`, `initIdleTimeout` de `../lib/auth.js`. SEC-ATH-03: chamar `initIdleTimeout()`. SEC-API-04: `supabaseClient` de `../../config.js`. SEC-AUD-02: `logger` de `../../lib/logger.js`.
      Tabela com colunas: Nome, Slug, Status, Disciplinas (contagem), Ações (Editar, Eliminar). Botão "Novo Curso". Importar: `checkAuth` de `../lib/auth.js`, `supabaseClient` de `../../config.js`, `escapeHtml` de `../../lib/security.js`, `logAction` de `../lib/audit-logger.js`.

- [ ] **Step 2: Adicionar entry no Vite config**
```js
adminGuiasIndex: resolve(__dirname, "src/admin/guias/index.html"),
```

- [ ] **Step 3: Commit**

```bash
git add src/admin/guias/index.html vite.config.js
git commit -m "feat: add admin listing for study guides"
```

---

## Task 9: Admin — Criar/Editar Curso

**Ficheiros:**
- Create: `src/admin/guias/new.html`
- Create: `src/admin/guias/edit.html`
- Modify: `vite.config.js`

- [ ] **Step 1: Criar `new.html`**
      **Segurança:** SEC-ATH-02: `checkAuth`, `initIdleTimeout` de `../lib/auth.js`. SEC-ATH-03: `initIdleTimeout()`. SEC-API-04: `supabaseClient` de `../../config.js`. SEC-XSS-02: `escapeAttr()` em `value=""` dos inputs. SEC-AUD-02: `logger`. Sem inline onclick (CSP).
      Formulário: Nome, Slug (auto-gerado), Descrição, Subtítulo Hero, Emoji, Cor (color picker ou text), Status, Ordem. Botão Guardar → `supabaseClient.from('guide_courses').insert(data)`.

- [ ] **Step 2: Criar `edit.html`**
      Mesmo formulário com dados pré-carregados. Botão Eliminar com confirm modal. Botão "Gerir Disciplinas" → link para `disciplinas.html?course={id}`.

- [ ] **Step 3: Adicionar entries no Vite config**
```js
adminGuiasNew: resolve(__dirname, "src/admin/guias/new.html"),
adminGuiasEdit: resolve(__dirname, "src/admin/guias/edit.html"),
```

- [ ] **Step 4: Commit**

```bash
git add src/admin/guias/new.html src/admin/guias/edit.html vite.config.js
git commit -m "feat: add admin create/edit forms for guide courses"
```

---

## Task 10: Admin — Listagem de Disciplinas

**Ficheiro:** Create: `src/admin/guias/disciplinas.html`

- [ ] **Step 1: Criar página de listagem**
      Receber `course_id` via URL param. Tabela com: Nome, Fase, Status, Ordem, Ações (Editar, Eliminar). Botão "Nova Disciplina". Link "← Voltar ao Curso" para `edit.html?id={course_id}`.

- [ ] **Step 2: Adicionar entry no Vite config**
```js
adminGuiasDisciplinas: resolve(__dirname, "src/admin/guias/disciplinas.html"),
```

- [ ] **Step 3: Commit**

```bash
git add src/admin/guias/disciplinas.html vite.config.js
git commit -m "feat: add admin listing for guide disciplines"
```

---

## Task 11: Admin — Criar/Editar Disciplina (com livros e recursos inline)

**Ficheiros:**
- Create: `src/admin/guias/disciplina-new.html`
- Create: `src/admin/guias/disciplina-edit.html`
- Modify: `vite.config.js`

- [ ] **Step 1: Criar `disciplina-new.html`**
      **Segurança:** SEC-ATH-02: `checkAuth`, `initIdleTimeout` de `../lib/auth.js`. SEC-ATH-03: `initIdleTimeout()`. SEC-API-04: `supabaseClient` de `../../config.js`. SEC-XSS-02: `escapeAttr()` em `value=""` dos inputs. SEC-AUD-02: `logger`. Sem inline onclick (CSP). Todas as adições/remoções de livros e recursos via `addEventListener`.
      Formulário: Nome, Slug, Descrição, Fase (ex: "1º Ano"), Importância, Status, Ordem. Curso pré-selecionado via URL param `course_id`.

      Secção **Livros** (dinâmica):
      - Botão "Adicionar Livro"
      - Campos por livro: Título, Autor, Edição, Ano, URL da Capa, Parágrafo da Equipa
      - Links externos: array dinâmico de {Label, URL} — botão "Adicionar Link"
      - Botão "Remover" por livro

      Secção **Recursos Gratuitos** (dinâmica):
      - Botão "Adicionar Recurso"
      - Campos: Título, Descrição, URL, Tipo (select: PDF, Diretriz, Artigo, Outro)
      - Botão "Remover" por recurso

      Guardar: inserir disciplina → guardar livros com `discipline_id` → guardar recursos com `discipline_id`.

- [ ] **Step 2: Criar `disciplina-edit.html`**
      Mesmo formulário com dados pré-carregados. Eliminar com confirm modal (CASCADE elimina livros e recursos).

- [ ] **Step 3: Adicionar entries no Vite config**
```js
adminGuiasDisciplinaNew: resolve(__dirname, "src/admin/guias/disciplina-new.html"),
adminGuiasDisciplinaEdit: resolve(__dirname, "src/admin/guias/disciplina-edit.html"),
```

- [ ] **Step 4: Commit**

```bash
git add src/admin/guias/disciplina-new.html src/admin/guias/disciplina-edit.html vite.config.js
git commit -m "feat: add admin create/edit forms for guide disciplines with books and resources"
```

---

## Task 12: Navegação — Adicionar "Guias de Estudo" em todas as páginas

**Ficheiros:** Todos os HTML com nav/drawer/footer (~12 ficheiros)

- [ ] **Step 1: Adicionar link no header desktop**
      Em `.nav-links` (em todos os HTML), após o link "Lives" e antes de "Sobre Nós":
```html
<li><a href="guias.html">Guias de Estudo</a></li>
```

- [ ] **Step 2: Adicionar link no drawer mobile**
      Em `.drawer-links` (em todos os HTML), após "Lives" e antes de "Sobre Nós":
```html
<li><a href="guias.html">Guias de Estudo</a></li>
```

- [ ] **Step 3: Adicionar link no footer**
      Em `.footer-links` Navegação (em todos os HTML), após "Lives" e antes de "Sobre Nós":
```html
<li><a href="guias.html">Guias de Estudo</a></li>
```

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add 'Guias de Estudo' navigation link across all pages"
```

---

## Task 13: Verificação Final

- [ ] **Step 1: Validar sintaxe de todos os JS**
```bash
node --check src/lib/api.js
node --check src/lib/fallback-data.js
node --check src/guia-logic.js
node --check src/guia-curso-logic.js
```

- [ ] **Step 2: Build de produção**
      Run: `npm run build`
      Expected: Build conclui sem erros.

- [ ] **Step 3: Verificar páginas no preview**
      Run: `npm run preview`
      - `guias.html` — 4 cards de cursos
      - `farmacia.html` — disciplinas com livros e recursos
      - `medicina.html` — disciplinas com livros e recursos
      - `enfermagem.html` — placeholder disciplines
      - `analises-clinicas.html` — placeholder disciplines
      - Admin: criar curso → aparece no índice
      - Admin: criar disciplina com livros → aparece na página do curso
      - Admin: eliminar disciplina → remove cascade livros e recursos

- [ ] **Step 4: Verificar responsividade**
      Mobile (320-480px): cards 1 coluna, book cards empilhados
      Tablet (768px): 2 colunas
      Desktop (1024px+): layout completo

- [ ] **Step 5: Verificar dark mode**
      Alternar dark mode em cada página. Todos os `.guide-*` devem adaptar.

- [ ] **Step 6: Verificar CSP**
      Nenhum inline script ou onclick handler.

---

## Ordem de Execução

1. **Task 1** — Migration SQL (Supabase)
2. **Task 3** — Fallback JSON + fallback-data.js
3. **Task 2** — API functions (api.js)
4. **Task 4** — CSS (input.css)
5. **Task 5** — Página índice (guias.html + guia-logic.js)
6. **Task 6** — Lógica de curso (guia-curso-logic.js)
7. **Task 7** — 4 páginas de curso
8. **Task 8** — Admin listagem cursos
9. **Task 9** — Admin criar/editar curso
10. **Task 10** — Admin listagem disciplinas
11. **Task 11** — Admin criar/editar disciplina (com livros e recursos)
12. **Task 12** — Navegação (nav/drawer/footer)
13. **Task 13** — Verificação final

---

## Ficheiros Novos (15)

| Ficheiro | Responsabilidade |
|----------|-----------------|
| `src/migrations/019-create-guide-tables.sql` | Migration Supabase (4 tabelas + RLS) |
| `src/content/guides-catalog.json` | Fallback JSON |
| `guias.html` | Página índice |
| `farmacia.html` | Curso de Farmácia |
| `medicina.html` | Curso de Medicina |
| `enfermagem.html` | Curso de Enfermagem |
| `analises-clinicas.html` | Curso de Análises Clínicas |
| `src/guia-logic.js` | Lógica página índice |
| `src/guia-curso-logic.js` | Lógica páginas de curso |
| `src/admin/guias/index.html` | Admin listagem cursos |
| `src/admin/guias/new.html` | Admin criar curso |
| `src/admin/guias/edit.html` | Admin editar curso |
| `src/admin/guias/disciplinas.html` | Admin listagem disciplinas |
| `src/admin/guias/disciplina-new.html` | Admin criar disciplina |
| `src/admin/guias/disciplina-edit.html` | Admin editar disciplina |

## Ficheiros Modificados (~16)

| Ficheiro | Alteração |
|----------|----------|
| `src/lib/api.js` | +11 funções guides |
| `src/lib/fallback-data.js` | +3 funções fallback |
| `src/input.css` | Estilos `.guide-*` |
| `vite.config.js` | +11 entries |
| `src/admin/styles/admin.css` | Estilos formulários guides |
| ~12 HTML files | Link "Guias de Estudo" na nav |
