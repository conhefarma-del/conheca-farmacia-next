# Spec: Guias de Estudo — Disciplinas, Livros e Recursos Essenciais para Cursos de Saúde

## Contexto

O projeto Conheça Farmácia precisa de uma secção dedicada a guias de estudo para cursos de saúde (Medicina, Farmácia, Enfermagem, Análises Clínicas). O foco principal são as **disciplinas essenciais** de cada formação, com descrição, fase do curso e importância. Dentro de cada disciplina, apresentar **livros essenciais** (com capa, autor, edição, ano, parágrafo da equipa e links externos customizados) e **recursos gratuitos** (PDFs, diretrizes).

O conteúdo é gerido via Supabase + Admin CMS completo.

---

## Páginas

### Páginas Públicas (5)

| Página | URL | Descrição |
|--------|-----|-----------|
| Índice de Guias | `guias.html` | Cards dos 4 cursos — cada card leva à página do curso |
| Medicina | `medicina.html` | Disciplinas, livros e recursos do curso de Medicina |
| Farmácia | `farmacia.html` | Disciplinas, livros e recursos do curso de Farmácia |
| Enfermagem | `enfermagem.html` | Disciplinas, livros e recursos do curso de Enfermagem |
| Análises Clínicas | `analises-clinicas.html` | Disciplinas, livros e recursos do curso de Análises Clínicas |

### Páginas Admin (6)

| Página | URL | Descrição |
|--------|-----|-----------|
| Listagem cursos | `src/admin/guias/index.html` | Tabela de cursos com contagem de disciplinas |
| Criar curso | `src/admin/guias/new.html` | Formulário novo curso |
| Editar curso | `src/admin/guias/edit.html` | Editar curso existente |
| Listagem disciplinas | `src/admin/guias/disciplinas.html` | Disciplinas de um curso (filtrado) |
| Criar disciplina | `src/admin/guias/disciplina-new.html` | Formulário nova disciplina (com livros e recursos inline) |
| Editar disciplina | `src/admin/guias/disciplina-edit.html` | Editar disciplina + livros + recursos |

### Página JS (3)

| Ficheiro | Responsabilidade |
|----------|-----------------|
| `src/guia-logic.js` | Lógica para `guias.html` (carregar cursos) |
| `src/guia-curso-logic.js` | Lógica para páginas de curso (carregar disciplinas + livros + recursos) |
| `src/admin/guias/admin-guias.js` | Lógica admin (CRUD cursos, disciplinas, livros, recursos) |

---

## Navegação

### Header (todas as páginas)

Adicionar "Guias de Estudo" ao nav links (desktop) e drawer links (mobile):
```html
<li><a href="guias.html">Guias de Estudo</a></li>
```

Posicionamento: após "Lives" e antes de "Sobre Nós".

### Breadcrumb (páginas de curso)

```
← Guias de Estudo | Farmácia
```

### Links entre cursos (final da página)

Secção "Outros Cursos" com links rápidos para os outros 3 cursos.

---

## Layout: Página Índice (`guias.html`)

```
┌──────────────────────────────────────────────┐
│ Hero: "Guias de Estudo"                       │
│ Subtítulo: "Disciplinas, livros e recursos    │
│ essenciais para cursos de saúde"              │
├──────────────────────────────────────────────┤
│                                               │
│  [💊 Medicina]  [💉 Farmácia]                │
│  [🩺 Enfermagem]  [🔬 Análises Clínicas]    │
│                                               │
│  Cada card: emoji, nome do curso,             │
│  breve descrição, contagem de disciplinas     │
└──────────────────────────────────────────────┘
```

---

## Layout: Página do Curso (ex: `farmacia.html`)

```
┌──────────────────────────────────────────────────┐
│ ← Guias de Estudo | Farmácia                      │
│                                                    │
│ 💊 Farmácia                                       │
│ Formação essencial para a saúde pública...         │
├──────────────────────────────────────────────────┤
│                                                    │
│ ╔═══════════════════════════════════════════╗      │
│ ║ ▶ Farmacologia                   1º Ano   ║      │
│ ║   A ciência dos fármacos e a sua ação...  ║      │
│ ╚═══════════════════════════════════════════╝      │
│                                                    │
│ ╔═══════════════════════════════════════════╗      │
│ ║ ▼ Química Farmacêutica           1º Ano   ║      │
│ ║   A base química dos medicamentos...      ║      │
│ ║                                           ║      │
│ ║   Porquê é essencial:                     ║      │
│ ║   "Sem química farmacêutica, o futuro..." ║      │
│ ║                                           ║      │
│ ║   ── Livros Essenciais ──                 ║      │
│ ║   ┌──────┐ Título do Livro                ║      │
│ ║   │ CAPA │ Autor · 5ª Edição · 2023       ║      │
│ ║   │      │ Parágrafo da equipa...         ║      │
│ ║   └──────│ [Amazon] [Editora] [Wook]      ║      │
│ ║                                           ║      │
│ ║   ── Recursos Gratuitos ──                ║      │
│ ║   📄 Diretrizes OMS 2025                  ║      │
│ ║   📄 Protocolo Nacional de Química        ║      │
│ ╚═══════════════════════════════════════════╝      │
│                                                    │
│ ── Outros Cursos ──                                │
│ [Medicina] [Enfermagem] [Análises Clínicas]       │
└──────────────────────────────────────────────────┘
```

Cada disciplina é um card expansível/colapsável. Os livros aparecem dentro como cards horizontais. Os recursos são links simples.

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
```

`links` formato:
```json
[
  {"label": "Comprar na Amazon", "url": "https://..."},
  {"label": "Ver na Editora", "url": "https://..."}
]
```

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
```

### RLS Policies (todas as tabelas)

```sql
-- Público lê publicados
CREATE POLICY "Public read" ON guide_courses FOR SELECT USING (status = 'published');
CREATE POLICY "Public read" ON guide_disciplines FOR SELECT USING (status = 'published');
CREATE POLICY "Public read" ON guide_books FOR SELECT USING (status = 'published');
CREATE POLICY "Public read" ON guide_resources FOR SELECT USING (status = 'published');

-- Admins fazem tudo
CREATE POLICY "Admin all" ON guide_courses FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE user_id = auth.uid()));
-- ... (mesmo padrão para as outras 3 tabelas)
```

---

## API Layer (`src/lib/api.js`)

Funções adicionadas:

```js
// --- Guides ---
export async function getGuideCourses() { /* WHERE status='published' ORDER BY sort_order */ }
export async function getGuideCourseBySlug(slug) { /* WHERE slug=... */ }
export async function getGuideDisciplinesByCourse(courseId) { /* WHERE course_id=... AND status='published' ORDER BY sort_order */ }
export async function getGuideDisciplineBySlug(slug) { /* com livros e recursos via join ou queries separadas */ }
export async function getGuideBooksByDiscipline(disciplineId) { /* WHERE discipline_id=... ORDER BY sort_order */ }
export async function getGuideResourcesByDiscipline(disciplineId) { /* WHERE discipline_id=... ORDER BY sort_order */ }
export async function getAllGuideCourses() { /* Admin: sem filtro status */ }
export async function deleteGuideCourse(id) { /* com auth check */ }
export async function deleteGuideDiscipline(id) { /* com auth check */ }
export async function deleteGuideBook(id) { /* com auth check */ }
export async function deleteGuideResource(id) { /* com auth check */ }
```

---

## Ficheiros Novos

| Ficheiro | Responsabilidade |
|----------|-----------------|
| `src/migrations/019-create-guide-tables.sql` | Migration Supabase (4 tabelas + RLS) |
| `guias.html` | Página índice dos cursos |
| `medicina.html` | Página do curso de Medicina |
| `farmacia.html` | Página do curso de Farmácia |
| `enfermagem.html` | Página do curso de Enfermagem |
| `analises-clinicas.html` | Página do curso de Análises Clínicas |
| `src/guia-logic.js` | Lógica da página índice |
| `src/guia-curso-logic.js` | Lógica das páginas de curso |
| `src/admin/guias/index.html` | Admin listagem cursos |
| `src/admin/guias/new.html` | Admin criar curso |
| `src/admin/guias/edit.html` | Admin editar curso |
| `src/admin/guias/disciplinas.html` | Admin listagem disciplinas |
| `src/admin/guias/disciplina-new.html` | Admin criar disciplina (com livros e recursos inline) |
| `src/admin/guias/disciplina-edit.html` | Admin editar disciplina |
| `src/content/guides-catalog.json` | Fallback JSON |

## Ficheiros Modificados

| Ficheiro | Alteração |
|----------|----------|
| `src/lib/api.js` | +11 funções guides |
| `src/lib/fallback-data.js` | +funções fallback guides |
| `src/input.css` | Estilos guides (discipline cards, book cards, resources) |
| `vite.config.js` | +11 entries |
| `src/admin/styles/admin.css` | Estilos formulários guides |
| ~12 HTML files | Link "Guias de Estudo" na nav |

---

## Cursos Iniciais (Dados)

| Curso | Dados | Disciplinas exemplo |
|-------|-------|---------------------|
| Farmácia | Reais | Farmacologia, Química Farmacêutica, Farmácia Clínica, Botânica, Microbiologia |
| Medicina | Reais | Anatomia, Fisiologia, Bioquímica, Patologia, Farmacologia |
| Enfermagem | Placeholder | Enfermagem Geral, Enfermagem Médico-Cirúrgica, Saúde Comunitária |
| Análises Clínicas | Placeholder | Bioquímica Clínica, Hematologia, Microbiologia Clínica, Imunologia |

---

## Reutilização de Módulos

| Módulo | Funções |
|--------|---------|
| `src/lib/api.js` | Padrão de normalização, fallback, delete |
| `src/lib/seo.js` | Meta tags, OG, JSON-LD |
| `src/lib/security.js` | `escapeHtml()`, `escapeAttr()` |
| `src/lib/error-handler.js` | `errorHandler` |
| `src/breadcrumb.js` | `renderBreadcrumb()` |
| `src/admin/lib/auth.js` | `checkAuth()`, `initIdleTimeout()` |
| `src/admin/lib/audit-logger.js` | `logAction()` |
