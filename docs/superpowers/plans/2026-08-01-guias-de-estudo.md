# Guias de Estudo — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar a secção pública "Guias de Estudo" com disciplinas essenciais, livros recomendados e recursos gratuitos para 4 cursos de saúde (Medicina, Farmácia, Enfermagem, Análises Clínicas), gerida via Supabase + Admin CMS (bilíngue PT/EN).

**Architecture:** Migração Supabase `038` com 4 tabelas (`guide_courses`, `guide_disciplines`, `guide_books`, `guide_resources`) com FK cascata + RLS; Server Actions `lib/actions/guides.js` para leitura pública e CRUD admin; páginas públicas `/[lang]/guias` (índice) + `/[lang]/guias/[slug]` (curso) sob PublicLayout; rota admin `(protected)/guias` com gestão hierárquica curso → disciplinas → livros/recursos. Páginas públicas lêem dados live da DB (publicado + não-arquivado).

**Tech Stack:** Next.js 16 App Router, React 19, Supabase (Postgres + RLS), Server Actions (`'use server'`), Tailwind v4 + CSS variables, `lucide-react`, metadata API (SEO), `Breadcrumb` + JSON-LD existentes.

**Source content:** Catálogo editorial dos Guias (cursos, disciplinas, livros, recursos) — conteúdo referencial no plano antigo `2026-05-23-guias-de-estudo.md`; introduzido como seed de amostra na migração e completado via Admin CMS.

**Nota de portabilidade:** Este plano substitui o `2026-05-23-guias-de-estudo.md` (arquitetura Vite/HTML/Netlify — já não existente no repositório). O schema das 4 tabelas e o conteúdo editorial sobrevivem; toda a camada de UI/API foi reescrita para o padrão Next.js do projeto (espelho da feature FAQ/Privacy).

---

## File Structure

**Migrations:**
- Create: `supabase/migrations/038_guide_tables.sql` — 4 tabelas + RLS + triggers + seed de amostra.

**Server Actions:**
- Create: `lib/actions/guides.js` — `getPublicGuideCourses`, `getPublicGuideCourseBySlug`, CRUD admin (cursos, disciplinas, livros, recursos) com Zod.

**Páginas Públicas:**
- Create: `app/[lang]/(public)/guias/page.js` — Server Component (índice de cursos).
- Create: `app/[lang]/(public)/guias/guiasPageClient.jsx` — Client Component (grid de cards).
- Create: `app/[lang]/(public)/guias/[slug]/page.js` — Server Component (detalhe do curso).
- Create: `app/[lang]/(public)/guias/[slug]/guiasCursoClient.jsx` — Client Component (disciplinas expandíveis + livros + recursos).

**Componentes Públicos:**
- Create: `components/guias/GuideCourseCard.jsx` — Card de curso (índice).
- Create: `components/guias/GuideDisciplinaCard.jsx` — Accordion de disciplina (expand/collapse).
- Create: `components/guias/GuideBookCard.jsx` — Card de livro com links externos.
- Create: `components/guias/GuideResourceLink.jsx` — Link de recurso gratuito.

**Páginas Admin:**
- Create: `app/[lang]/admin/(protected)/guias/page.js` — Server Component.
- Create: `components/admin/GuidesAdminPage.jsx` — Gestão hierárquica completa (cursos → disciplinas → livros/recursos).
- Create: `components/admin/GuideCursoForm.jsx` — Form de curso (BilingualTabs PT/EN).
- Create: `components/admin/GuideDisciplinaForm.jsx` — Form de disciplina com editor inline de livros/recursos.
- Modify: `components/layout/AdminSidebar.jsx` — Adicionar "Guias de Estudo".

**Navegação Pública:**
- Modify: `components/layout/Header.jsx` — Link "Guias de Estudo" na nav desktop.
- Modify: `components/layout/MobileDrawer.jsx` — Link no drawer mobile.
- Modify: `components/layout/Footer.jsx` — Link na coluna "Navegação".

**i18n:**
- Modify: `lib/i18n-routes.js` — Adicionar `guias: 'guides'` ao `PT_TO_EN`.
- Modify: `public/i18n/{pt,en}.json` — Chaves `nav.guias`, `footer.guias`, `guias_page.*`, `guias_curso.*`, `admin.guias.*`.

**Estilos:**
- Modify: `styles/globals.css` — Estilos `.guide-*`.

---

## Task 1: Migração `038_guide_tables.sql`

**Files:**
- Create: `supabase/migrations/038_guide_tables.sql`

- [ ] **Step 1: Escrever a migração (tabelas + RLS + triggers)**

```sql
-- 038: Study guides — courses, disciplines, books, resources
-- Bilíngue (PT/EN), soft-delete via is_archived, gate público via status='published'.

CREATE TABLE IF NOT EXISTS public.guide_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  hero_subtitle_pt TEXT NOT NULL DEFAULT '',
  hero_subtitle_en TEXT NOT NULL DEFAULT '',
  icon_emoji TEXT NOT NULL DEFAULT '📚',
  color TEXT NOT NULL DEFAULT '#0a844f',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.guide_disciplines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  course_id UUID NOT NULL REFERENCES public.guide_courses(id) ON DELETE CASCADE,
  name_pt TEXT NOT NULL,
  name_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  phase_pt TEXT NOT NULL DEFAULT '',
  phase_en TEXT NOT NULL DEFAULT '',
  importance_pt TEXT NOT NULL DEFAULT '',
  importance_en TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.guide_books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discipline_id UUID NOT NULL REFERENCES public.guide_disciplines(id) ON DELETE CASCADE,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  author TEXT NOT NULL DEFAULT '',
  edition TEXT NOT NULL DEFAULT '',
  year INTEGER,
  cover_url TEXT NOT NULL DEFAULT '',
  team_paragraph_pt TEXT NOT NULL DEFAULT '',
  team_paragraph_en TEXT NOT NULL DEFAULT '',
  -- [{label_pt, label_en, url}] — links externos (loja/editora)
  links JSONB NOT NULL DEFAULT '[]',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.guide_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  discipline_id UUID NOT NULL REFERENCES public.guide_disciplines(id) ON DELETE CASCADE,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT NOT NULL DEFAULT '',
  url TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'pdf' CHECK (type IN ('pdf', 'guideline', 'article', 'other')),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.guide_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_disciplines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_books ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guide_resources ENABLE ROW LEVEL SECURITY;

-- Admin can do everything (auth check enforced via Server Actions)
CREATE POLICY "admin_all_guide_courses" ON public.guide_courses
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_guide_disciplines" ON public.guide_disciplines
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_guide_books" ON public.guide_books
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "admin_all_guide_resources" ON public.guide_resources
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon can only read published, non-archived data (public pages)
CREATE POLICY "anon_read_guide_courses" ON public.guide_courses
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_guide_disciplines" ON public.guide_disciplines
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_guide_books" ON public.guide_books
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

CREATE POLICY "anon_read_guide_resources" ON public.guide_resources
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND is_archived = false);

-- Triggers for updated_at (função já existe — migração 034)
CREATE TRIGGER set_guide_courses_updated_at
  BEFORE UPDATE ON public.guide_courses
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_guide_disciplines_updated_at
  BEFORE UPDATE ON public.guide_disciplines
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_guide_books_updated_at
  BEFORE UPDATE ON public.guide_books
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER set_guide_resources_updated_at
  BEFORE UPDATE ON public.guide_resources
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
```

- [ ] **Step 2: Seed de amostra (cursos + exemplo completo Farmácia/Farmacologia)**

```sql
-- Seed de amostra: 4 cursos + 1 disciplina completa (Farmácia → Farmacologia)
-- O conteúdo editorial completo é introduzido via Admin CMS.
INSERT INTO public.guide_courses (slug, name_pt, name_en, description_pt, description_en, hero_subtitle_pt, hero_subtitle_en, icon_emoji, color, status, sort_order) VALUES
  ('farmacia', 'Farmácia', 'Pharmacy',
   'Formação centrada na descoberta, desenvolvimento, produção e uso racional de medicamentos.',
   'Training focused on the discovery, development, production and rational use of medicines.',
   'Do laboratório ao balcão — a ciência que protege a saúde.',
   'From the lab to the counter — the science that protects health.',
   '💊', '#0a844f', 'published', 1),
  ('medicina', 'Medicina', 'Medicine',
   'Formação médica generalista com base nas ciências fundamentais e clínicas.',
   'Generalist medical training grounded in the fundamental and clinical sciences.',
   'A arte de curar, sustentada pela ciência.',
   'The art of healing, grounded in science.',
   '🩺', '#0a844f', 'published', 2),
  ('enfermagem', 'Enfermagem', 'Nursing',
   'Formação em cuidados de enfermagem, gestão e educação para a saúde.',
   'Training in nursing care, management and health education.',
   'Cuidar é a nossa ciência.',
   'Caring is our science.',
   '🩹', '#0a844f', 'published', 3),
  ('analises-clinicas', 'Análises Clínicas', 'Clinical Laboratory Science',
   'Formação em diagnóstico laboratorial e controlo de qualidade.',
   'Training in laboratory diagnostics and quality control.',
   'A verdade escondida em cada amostra.',
   'The truth hidden in every sample.',
   '🔬', '#0a844f', 'published', 4);

DO $$
DECLARE
  farmacia_id UUID;
  farmacologia_id UUID;
BEGIN
  SELECT id INTO farmacia_id FROM public.guide_courses WHERE slug = 'farmacia';

  INSERT INTO public.guide_disciplines (slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, status, sort_order)
  VALUES ('farmacologia', farmacia_id,
    'Farmacologia', 'Pharmacology',
    'Estudo dos fármacos, mecanismos de ação, efeitos terapêuticos e adversos.',
    'Study of drugs, mechanisms of action, therapeutic and adverse effects.',
    '2º Ano', '2nd Year',
    'Base fundamental para qualquer profissional que lida com medicamentos. Sem farmacologia, o farmacêutico não consegue compreender interações medicamentosas nem aconselhar doentes.',
    'The fundamental basis for any professional who works with medicines. Without pharmacology, the pharmacist cannot understand drug interactions or counsel patients.',
    'published', 1)
  RETURNING id INTO farmacologia_id;

  INSERT INTO public.guide_books (discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, status, sort_order)
  VALUES (farmacologia_id,
    'Goodman & Gilman''s The Pharmacological Basis of Therapeutics',
    'Goodman & Gilman''s The Pharmacological Basis of Therapeutics',
    'Laurence L. Brunton, Bjorn Knollmann', '14ª Edição', 2023,
    'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1681245397i/63289543.jpg',
    'Considerado a bíblia da farmacologia. Essencial para qualquer estudante de farmácia ou medicina que queira uma compreensão profunda dos mecanismos de ação dos fármacos.',
    'Considered the bible of pharmacology. Essential for any pharmacy or medicine student who wants a deep understanding of drug mechanisms of action.',
    '[{"label_pt":"Comprar na Amazon","label_en":"Buy on Amazon","url":"https://www.amazon.com/dp/1260464164"},{"label_pt":"Ver na Editora","label_en":"View on Publisher","url":"https://www.mhprofessional.com"}]',
    'published', 1);

  INSERT INTO public.guide_resources (discipline_id, title_pt, title_en, description_pt, description_en, url, type, status, sort_order)
  VALUES (farmacologia_id,
    'Lista de Medicamentos Essenciais OMS 2025', 'WHO Model List of Essential Medicines 2025',
    'Lista atualizada de medicamentos essenciais pela Organização Mundial da Saúde.',
    'Updated list of essential medicines by the World Health Organization.',
    'https://www.who.int/publications/i/item/EML2025', 'guideline', 'published', 1);
END $$;
```

- [ ] **Step 3: Commit**

```bash
git add supabase/migrations/038_guide_tables.sql
git commit -m "feat(db): add guide tables (courses, disciplines, books, resources) with RLS"
```

---

## Task 2: Server Actions — `lib/actions/guides.js`

**Files:**
- Create: `lib/actions/guides.js`

- [ ] **Step 1: Escrever as Server Actions (público + admin) com Zod**

```js
'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'

// ============================================================
//  Helper: requireAdmin (padrão de legalContent.js / content.js)
// ============================================================
async function requireAdmin() {
  const supabase = await createClient()
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return null
    const { data: adminUser, error: adminError } = await supabase
      .from('admin_users')
      .select('user_id, role')
      .eq('user_id', user.id)
      .maybeSingle()
    if (adminError || !adminUser) return null
    return { supabase, user, role: adminUser.role }
  } catch {
    return null
  }
}

// ============================================================
//  Zod schemas — validação server-side (SEC-XSS-03: URLs)
// ============================================================
const URL_SAFE = z.string().refine(
  (u) => !u || /^(https:\/\/|\/)/i.test(u),
  'URL deve começar por https:// ou ser um caminho relativo'
)

const guideCourseSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/),
  name_pt: z.string().min(1, 'Nome (PT) é obrigatório'),
  name_en: z.string().min(1, 'Name (EN) is required'),
  description_pt: z.string().optional().default(''),
  description_en: z.string().optional().default(''),
  hero_subtitle_pt: z.string().optional().default(''),
  hero_subtitle_en: z.string().optional().default(''),
  icon_emoji: z.string().optional().default('📚'),
  color: z.string().optional().default('#0a844f'),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const guideDisciplineSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/),
  name_pt: z.string().min(1),
  name_en: z.string().min(1),
  description_pt: z.string().optional().default(''),
  description_en: z.string().optional().default(''),
  phase_pt: z.string().optional().default(''),
  phase_en: z.string().optional().default(''),
  importance_pt: z.string().optional().default(''),
  importance_en: z.string().optional().default(''),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const guideBookSchema = z.object({
  title_pt: z.string().min(1),
  title_en: z.string().min(1),
  author: z.string().optional().default(''),
  edition: z.string().optional().default(''),
  year: z.number().int().min(1900).max(2100).optional().nullable(),
  cover_url: URL_SAFE.optional().default(''),
  team_paragraph_pt: z.string().optional().default(''),
  team_paragraph_en: z.string().optional().default(''),
  links: z.array(z.object({
    label_pt: z.string().min(1),
    label_en: z.string().min(1),
    url: z.string().url('URL inválida'),
  })).optional().default([]),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const guideResourceSchema = z.object({
  title_pt: z.string().min(1),
  title_en: z.string().min(1),
  description_pt: z.string().optional().default(''),
  description_en: z.string().optional().default(''),
  url: z.string().url('URL inválida'),
  type: z.enum(['pdf', 'guideline', 'article', 'other']).default('pdf'),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

// ============================================================
//  PÚBLICO — leitura (apenas published + is_archived=false)
//  A RLS já filtra; as queries reforçam com colunas explícitas (SEC-API-03)
// ============================================================

const COURSE_COLS = 'id, slug, name_pt, name_en, description_pt, description_en, hero_subtitle_pt, hero_subtitle_en, icon_emoji, color, sort_order'
const DISCIPLINE_COLS = 'id, slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, sort_order'

/** Páginas públicas — seleção por idioma (pt/en) */
function pickLang(row, prefix, lang) {
  const key = lang === 'en' ? 'en' : 'pt'
  return row[`${prefix}_${key}`]
}

export async function getPublicGuideCourses() {
  const supabase = await createClient()
  try {
    const { data, error } = await supabase
      .from('guide_courses')
      .select(COURSE_COLS)
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })
    if (error) return []
    return (data || []).map((c) => ({
      id: c.id, slug: c.slug,
      name: pickLang(c, 'name', 'pt'), description: pickLang(c, 'description', 'pt'),
      heroSubtitle: pickLang(c, 'hero_subtitle', 'pt'),
      iconEmoji: c.icon_emoji, color: c.color, sortOrder: c.sort_order,
    }))
  } catch {
    return []
  }
}

/**
 * Detalhe público de um curso: disciplina + livros + recursos aninhados.
 * Uma só chamada → evita N+1 no client. `lang` controla os campos devolvidos.
 */
export async function getPublicGuideCourseBySlug(slug, lang = 'pt') {
  const supabase = await createClient()
  try {
    const { data: course, error: cErr } = await supabase
      .from('guide_courses')
      .select(COURSE_COLS)
      .eq('slug', slug)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()
    if (cErr || !course) return null

    const { data: disciplines, error: dErr } = await supabase
      .from('guide_disciplines')
      .select(DISCIPLINE_COLS)
      .eq('course_id', course.id)
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })
    if (dErr) return null

    const disciplinesResolved = await Promise.all((disciplines || []).map(async (d) => {
      const [books, resources] = await Promise.all([
        supabase.from('guide_books')
          .select('id, discipline_id, title_pt, title_en, author, edition, year, cover_url, team_paragraph_pt, team_paragraph_en, links, sort_order')
          .eq('discipline_id', d.id)
          .eq('status', 'published')
          .eq('is_archived', false)
          .order('sort_order', { ascending: true }),
        supabase.from('guide_resources')
          .select('id, discipline_id, title_pt, title_en, description_pt, description_en, url, type, sort_order')
          .eq('discipline_id', d.id)
          .eq('status', 'published')
          .eq('is_archived', false)
          .order('sort_order', { ascending: true }),
      ])
      return {
        id: d.id, slug: d.slug, courseId: d.course_id,
        name: pickLang(d, 'name', lang), description: pickLang(d, 'description', lang),
        phase: pickLang(d, 'phase', lang), importance: pickLang(d, 'importance', lang),
        sortOrder: d.sort_order,
        books: (books.data || []).map((b) => ({
          id: b.id,
          title: pickLang(b, 'title', lang),
          author: b.author, edition: b.edition, year: b.year, coverUrl: b.cover_url,
          teamParagraph: pickLang(b, 'team_paragraph', lang),
          links: (b.links || []).map((l) => ({
            label: pickLang(l, 'label', lang),
            url: l.url,
          })),
        })),
        resources: (resources.data || []).map((r) => ({
          id: r.id,
          title: pickLang(r, 'title', lang),
          description: pickLang(r, 'description', lang),
          url: r.url, type: r.type,
        })),
      }
    }))

    return {
      id: course.id, slug: course.slug,
      name: pickLang(course, 'name', lang),
      description: pickLang(course, 'description', lang),
      heroSubtitle: pickLang(course, 'hero_subtitle', lang),
      iconEmoji: course.icon_emoji, color: course.color,
      disciplines: disciplinesResolved,
    }
  } catch {
    return null
  }
}

// ============================================================
//  ADMIN — Cursos CRUD
// ============================================================

export async function getAllGuideCourses() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('guide_courses')
      .select('id, slug, name_pt, name_en, status, sort_order, is_archived, created_at, updated_at, guide_disciplines(count)')
      .order('sort_order', { ascending: true })
    if (error) return []
    return (data || []).map((c) => ({
      ...c,
      disciplineCount: c.guide_disciplines?.[0]?.count || 0,
    }))
  } catch {
    return []
  }
}

export async function getGuideCourseDetail(id) {
  const ctx = await requireAdmin()
  if (!ctx) return null
  const { supabase } = ctx
  try {
    const { data: course, error: cErr } = await supabase
      .from('guide_courses')
      .select('*')
      .eq('id', id)
      .maybeSingle()
    if (cErr || !course) return null

    const { data: disciplines, error: dErr } = await supabase
      .from('guide_disciplines')
      .select('*, guide_books(*), guide_resources(*)')
      .eq('course_id', id)
      .order('sort_order', { ascending: true })
    if (dErr) return null

    return { ...course, disciplines: disciplines || [] }
  } catch {
    return null
  }
}

export async function createGuideCourse(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideCourseSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase.from('guide_courses').insert(parsed.data).select().single()
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true, data: row }
  } catch {
    return { success: false, error: 'Erro ao criar curso' }
  }
}

export async function updateGuideCourse(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideCourseSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_courses').update(parsed.data).eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar curso' }
  }
}

export async function archiveGuideCourse(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { supabase, user } = ctx
  try {
    const { error } = await supabase.from('guide_courses')
      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
      .eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao arquivar curso' }
  }
}

export async function restoreGuideCourse(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Não autorizado' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_courses')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao restaurar curso' }
  }
}

export async function deleteGuideCourse(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_courses').delete().eq('id', id) // CASCADE remove disciplinas
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao eliminar curso' }
  }
}

// ============================================================
//  ADMIN — Disciplinas CRUD
// ============================================================

export async function createGuideDiscipline(courseId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideDisciplineSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_disciplines')
      .insert({ ...parsed.data, course_id: courseId })
      .select().single()
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true, data: row }
  } catch {
    return { success: false, error: 'Erro ao criar disciplina' }
  }
}

export async function updateGuideDiscipline(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideDisciplineSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_disciplines').update(parsed.data).eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar disciplina' }
  }
}

export async function deleteGuideDiscipline(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_disciplines').delete().eq('id', id) // CASCADE remove livros+recursos
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao eliminar disciplina' }
  }
}

// ============================================================
//  ADMIN — Livros CRUD
// ============================================================

export async function createGuideBook(disciplineId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideBookSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_books')
      .insert({ ...parsed.data, discipline_id: disciplineId })
      .select().single()
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true, data: row }
  } catch {
    return { success: false, error: 'Erro ao criar livro' }
  }
}

export async function updateGuideBook(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideBookSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_books').update(parsed.data).eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar livro' }
  }
}

export async function deleteGuideBook(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_books').delete().eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao eliminar livro' }
  }
}

// ============================================================
//  ADMIN — Recursos CRUD
// ============================================================

export async function createGuideResource(disciplineId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideResourceSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_resources')
      .insert({ ...parsed.data, discipline_id: disciplineId })
      .select().single()
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true, data: row }
  } catch {
    return { success: false, error: 'Erro ao criar recurso' }
  }
}

export async function updateGuideResource(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = guideResourceSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_resources').update(parsed.data).eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar recurso' }
  }
}

export async function deleteGuideResource(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_resources').delete().eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao eliminar recurso' }
  }
}
```

- [ ] **Step 2: Validar sintaxe**

```bash
node --check lib/actions/guides.js
```

- [ ] **Step 3: Commit**

```bash
git add lib/actions/guides.js
git commit -m "feat(actions): add guide server actions (public reads + admin CRUD)"
```

---

## Task 3: i18n — Rotas + JSON

**Files:**
- Modify: `lib/i18n-routes.js`
- Modify: `public/i18n/pt.json`
- Modify: `public/i18n/en.json`

- [ ] **Step 1: Adicionar rota `guias` ao `lib/i18n-routes.js`**

No objecto `PT_TO_EN`:
```js
const PT_TO_EN = {
  artigos: 'articles',
  eventos: 'events',
  sobre: 'about',
  pesquisa: 'search',
  inscricao: 'register',
  faq: 'faq',
  'politica-privacidade': 'privacy-policy',
  guias: 'guides',   // ← novo
}
```

- [ ] **Step 2: Adicionar chaves ao `public/i18n/pt.json`**

```json
{
  "nav": {
    "guias": "Guias de Estudo"
  },
  "footer": {
    "guias": "Guias de Estudo"
  },
  "guias_page": {
    "hero_title": "Guias de Estudo",
    "hero_subtitle": "Disciplinas, livros e recursos essenciais para cursos de saúde — Medicina, Farmácia, Enfermagem e Análises Clínicas.",
    "no_courses": "Em breve — guias de estudo em preparação.",
    "ver_disciplinas": "Ver disciplinas →"
  },
  "guias_curso": {
    "breadcrumb_guias": "Guias de Estudo",
    "porque_essencial": "Porquê é essencial",
    "livros_essenciais": "Livros Essenciais",
    "recursos_gratuitos": "Recursos Gratuitos",
    "outros_cursos": "Outros Cursos",
    "disciplinas_preparacao": "Disciplinas em preparação.",
    "erro_carregar": "Erro ao carregar guia."
  }
}
```

- [ ] **Step 3: Adicionar chaves ao `public/i18n/en.json`** (equivalente EN)

```json
{
  "nav": {
    "guias": "Study Guides"
  },
  "footer": {
    "guias": "Study Guides"
  },
  "guias_page": {
    "hero_title": "Study Guides",
    "hero_subtitle": "Essential disciplines, books and resources for health courses — Medicine, Pharmacy, Nursing and Clinical Laboratory Science.",
    "no_courses": "Coming soon — study guides in preparation.",
    "ver_disciplinas": "View disciplines →"
  },
  "guias_curso": {
    "breadcrumb_guias": "Study Guides",
    "porque_essencial": "Why it matters",
    "livros_essenciais": "Essential Books",
    "recursos_gratuitos": "Free Resources",
    "outros_cursos": "Other Courses",
    "disciplinas_preparacao": "Disciplines in preparation.",
    "erro_carregar": "Error loading guide."
  }
}
```

**Nota:** As chaves `admin.guias.*` (labels do CMS) seguem o padrão das outras secções admin — podem ser strings diretas no componente (como FAQ/Privacy admin) ou chaves i18n. Para consistência com o resto do admin, usar strings diretas em PT.

- [ ] **Step 4: Validar JSON**

```bash
node -e "JSON.parse(require('fs').readFileSync('public/i18n/pt.json'))"
node -e "JSON.parse(require('fs').readFileSync('public/i18n/en.json'))"
```

- [ ] **Step 5: Commit**

```bash
git add lib/i18n-routes.js public/i18n/pt.json public/i18n/en.json
git commit -m "feat(i18n): add guias routes and translations"
```

---

## Task 4: Componentes Públicos — Cards + Accordion + Livros + Recursos

**Files:**
- Create: `components/guias/GuideCourseCard.jsx`
- Create: `components/guias/GuideDisciplinaCard.jsx`
- Create: `components/guias/GuideBookCard.jsx`
- Create: `components/guias/GuideResourceLink.jsx`

- [ ] **Step 1: `GuideCourseCard.jsx`**

```jsx
import Link from 'next/link'

/**
 * Card de curso no índice /[lang]/guias.
 * O slug é partilhado PT/EN (ex: 'farmacia') → href direto.
 */
export default function GuideCourseCard({ course, lang }) {
  return (
    <Link
      href={`/${lang}/guias/${course.slug}`}
      className="guide-course-card"
    >
      <div className="guide-course-emoji">{course.iconEmoji || '📚'}</div>
      <h2 className="guide-course-name">{course.name}</h2>
      <p className="guide-course-desc">{course.description}</p>
      <span className="guide-course-count">Ver disciplinas →</span>
    </Link>
  )
}
```

- [ ] **Step 2: `GuideDisciplinaCard.jsx`** (accordion, `details`/`summary` — padrão FAQ)

```jsx
'use client'

import { useState } from 'react'
import { ChevronDown } from 'lucide-react'
import GuideBookCard from './GuideBookCard'
import GuideResourceLink from './GuideResourceLink'

export default function GuideDisciplinaCard({ disciplina, t }) {
  const [open, setOpen] = useState(false)

  return (
    <div className="guide-discipline-card">
      <button
        className="guide-discipline-header"
        aria-expanded={open}
        onClick={() => setOpen(!open)}
      >
        <div className="guide-discipline-text">
          <h3 className="guide-discipline-name">{disciplina.name}</h3>
          {disciplina.description && (
            <p className="guide-discipline-desc">{disciplina.description}</p>
          )}
        </div>
        <div className="guide-discipline-meta">
          {disciplina.phase && (
            <span className="guide-discipline-phase">{disciplina.phase}</span>
          )}
          <ChevronDown size={20} className={`guide-discipline-toggle ${open ? 'expanded' : ''}`} />
        </div>
      </button>

      {open && (
        <div className="guide-discipline-content">
          {disciplina.importance && (
            <div className="guide-importance-box">
              <div className="guide-importance-label">{t('guias_curso.porque_essencial')}</div>
              <p>{disciplina.importance}</p>
            </div>
          )}

          {disciplina.books?.length > 0 && (
            <div className="guide-section-block">
              <div className="guide-section-label">{t('guias_curso.livros_essenciais')}</div>
              <div className="space-y-4">
                {disciplina.books.map((book) => (
                  <GuideBookCard key={book.id} book={book} />
                ))}
              </div>
            </div>
          )}

          {disciplina.resources?.length > 0 && (
            <div className="guide-section-block">
              <div className="guide-section-label">{t('guias_curso.recursos_gratuitos')}</div>
              <div className="space-y-2">
                {disciplina.resources.map((resource) => (
                  <GuideResourceLink key={resource.id} resource={resource} />
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
```

- [ ] **Step 3: `GuideBookCard.jsx`** (links externos com `rel="noopener noreferrer"` — SEC-FRM-03)

```jsx
/**
 * Card de livro. `coverUrl` é validado server-side (https:// ou relativo).
 * Links externos abrem em nova aba com rel de segurança.
 */
export default function GuideBookCard({ book }) {
  return (
    <div className="guide-book-card">
      {book.coverUrl && (
        <img
          src={book.coverUrl}
          alt={book.title}
          className="guide-book-cover"
          loading="lazy"
        />
      )}
      <div className="guide-book-info">
        <h4 className="guide-book-title">{book.title}</h4>
        <p className="guide-book-meta">
          {book.author}{book.edition ? ` · ${book.edition}` : ''}{book.year ? ` · ${book.year}` : ''}
        </p>
        {book.teamParagraph && <p className="guide-book-paragraph">{book.teamParagraph}</p>}
        {book.links?.length > 0 && (
          <div className="guide-book-links">
            {book.links.map((link, i) => (
              <a
                key={i}
                href={link.url}
                target="_blank"
                rel="noopener noreferrer"
                className="guide-book-link"
              >
                {link.label}
              </a>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
```

- [ ] **Step 4: `GuideResourceLink.jsx`**

```jsx
const ICON_MAP = { pdf: '📄', guideline: '📋', article: '📰', other: '🔗' }

export default function GuideResourceLink({ resource }) {
  return (
    <a
      href={resource.url}
      target="_blank"
      rel="noopener noreferrer"
      className="guide-resource-link"
    >
      <div className="guide-resource-icon">{ICON_MAP[resource.type] || '🔗'}</div>
      <div>
        <div className="guide-resource-title">{resource.title}</div>
        {resource.description && <div className="guide-resource-desc">{resource.description}</div>}
      </div>
    </a>
  )
}
```

- [ ] **Step 5: Commit**

```bash
git add components/guias/
git commit -m "feat(components): add study guides public components"
```

---

## Task 5: Páginas Públicas — `/[lang]/guias` + `/[lang]/guias/[slug]`

**Files:**
- Create: `app/[lang]/(public)/guias/page.js`
- Create: `app/[lang]/(public)/guias/guiasPageClient.jsx`
- Create: `app/[lang]/(public)/guias/[slug]/page.js`
- Create: `app/[lang]/(public)/guias/[slug]/guiasCursoClient.jsx`

- [ ] **Step 1: Índice — Server Component `page.js`**

```jsx
// app/[lang]/(public)/guias/page.js
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicGuideCourses } from '@/lib/actions/guides'
import GuiasPageClient from './guiasPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('guias_page.hero_title')} | Conheça Farmácia`,
    description: tFn('guias_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/guias', en: '/en/guides' } },
  }
}

export default async function GuiasPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const courses = await getPublicGuideCourses()

  return <GuiasPageClient lang={safeLang} courses={courses} />
}
```

- [ ] **Step 2: Índice — Client Component `guiasPageClient.jsx`**

```jsx
'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import GuideCourseCard from '@/components/guias/GuideCourseCard'
import Breadcrumb from '@/components/ui/Breadcrumb'

export default function GuiasPageClient({ lang, courses }) {
  const { t } = useContext(LangContext)

  const breadcrumbItems = [
    { label: t('nav.inicio'), href: `/${lang}` },
    { label: t('guias_page.hero_title') },
  ]

  return (
    <>
      {/* Hero */}
      <section className="hero hero--short">
        <div className="container-center">
          <Breadcrumb items={breadcrumbItems} />
          <div className="text-center py-8 md:py-12">
            <h1 className="text-4xl md:text-5xl font-bold text-brand-deep dark:text-white mb-4">
              {t('guias_page.hero_title')}
            </h1>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              {t('guias_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Grid de Cursos */}
      <section className="section-padding bg-brand-bg dark:bg-gray-900">
        <div className="container-center">
          {courses.length === 0 ? (
            <p className="text-center text-muted-foreground">{t('guias_page.no_courses')}</p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              {courses.map((course) => (
                <GuideCourseCard key={course.id} course={course} lang={lang} />
              ))}
            </div>
          )}
        </div>
      </section>
    </>
  )
}
```

- [ ] **Step 3: Detalhe do curso — Server Component `[slug]/page.js`**

```jsx
// app/[lang]/(public)/guias/[slug]/page.js
import { notFound } from 'next/navigation'
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicGuideCourseBySlug } from '@/lib/actions/guides'
import GuiasCursoClient from './guiasCursoClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const course = await getPublicGuideCourseBySlug(slug, safeLang)
  if (!course) return { title: 'Guias de Estudo | Conheça Farmácia' }

  return {
    title: `${course.name} — Guias de Estudo | Conheça Farmácia`,
    description: course.description || course.heroSubtitle,
    alternates: { languages: { pt: `/pt/guias/${slug}`, en: `/en/guides/${slug}` } },
  }
}

export default async function GuiaCursoPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const course = await getPublicGuideCourseBySlug(slug, safeLang)
  if (!course) notFound()

  return <GuiasCursoClient lang={safeLang} course={course} />
}
```

- [ ] **Step 4: Detalhe do curso — Client Component `guiasCursoClient.jsx`**

```jsx
'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import GuideDisciplinaCard from '@/components/guias/GuideDisciplinaCard'
import Breadcrumb from '@/components/ui/Breadcrumb'
import { getSectionHref } from '@/lib/i18n-routes'

export default function GuiasCursoClient({ lang, course }) {
  const { t } = useContext(LangContext)

  const breadcrumbItems = [
    { label: t('nav.inicio'), href: `/${lang}` },
    { label: t('guias_curso.breadcrumb_guias'), href: getSectionHref(lang, 'guias') },
    { label: course.name },
  ]

  return (
    <>
      {/* Breadcrumb + Hero */}
      <section className="hero hero--short">
        <div className="container-center">
          <Breadcrumb items={breadcrumbItems} />
          <div className="flex items-center gap-4 mb-4">
            <span className="text-5xl">{course.iconEmoji || '📚'}</span>
            <h1 className="article-hero-title">{course.name}</h1>
          </div>
          <p className="hero-subtitle">{course.heroSubtitle}</p>
        </div>
      </section>

      {/* Disciplines */}
      <section className="section-padding">
        <div className="container-center max-w-4xl mx-auto">
          {course.disciplines.length === 0 ? (
            <p className="text-center text-muted-foreground">
              {t('guias_curso.disciplinas_preparacao')}
            </p>
          ) : (
            <div className="space-y-6">
              {course.disciplines.map((disc) => (
                <GuideDisciplinaCard key={disc.id} disciplina={disc} t={t} />
              ))}
            </div>
          )}
        </div>
      </section>
    </>
  )
}
```

- [ ] **Step 5: Commit**

```bash
git add 'app/[lang]/(public)/guias/'
git commit -m "feat(pages): add public study guides pages (index + course detail)"
```

---

## Task 6: CSS — Estilos `.guide-*`

**Files:**
- Modify: `styles/globals.css`

- [ ] **Step 1: Adicionar estilos (usar CSS variables do tema — SEC-CSS-02)**

Adicionar ao final de `styles/globals.css` (resumo — ajustar ao design system atual):

```css
/* ========================================
   Study Guides
   ======================================== */

/* Index — course cards */
.guide-course-card {
  display: block;
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  background: var(--color-card-bg, var(--color-background));
  padding: 1.5rem;
  transition: transform .3s ease, box-shadow .3s ease, border-color .3s ease;
}
.guide-course-card:hover {
  transform: translateY(-4px);
  border-color: var(--color-primary);
}
.guide-course-emoji { font-size: 2.5rem; margin-bottom: 1rem; }
.guide-course-name { font-size: 1.4rem; font-weight: 700; color: var(--color-foreground); margin-bottom: .5rem; }
.guide-course-desc { font-size: .9rem; color: var(--color-muted-foreground); margin-bottom: .75rem; }
.guide-course-count { font-size: .8rem; font-weight: 600; color: var(--color-primary); }

/* Course page — discipline cards */
.guide-discipline-card {
  border: 1px solid var(--color-border);
  border-radius: 1rem;
  background: var(--color-card-bg, var(--color-background));
  overflow: hidden;
}
.guide-discipline-header {
  display: flex; align-items: center; justify-content: space-between; gap: 1rem;
  width: 100%; padding: 1.5rem; cursor: pointer; text-align: left;
  background: none; border: none; color: inherit;
}
.guide-discipline-header:hover { background: var(--color-accent-bg, rgba(0,0,0,.03)); }
.guide-discipline-name { font-size: 1.1rem; font-weight: 700; color: var(--color-foreground); }
.guide-discipline-desc { font-size: .85rem; color: var(--color-muted-foreground); margin-top: .25rem; }
.guide-discipline-meta { display: flex; align-items: center; gap: .75rem; flex-shrink: 0; }
.guide-discipline-phase {
  font-size: .75rem; font-weight: 600; padding: .25rem .75rem; border-radius: 999px;
  background: var(--color-accent-bg, rgba(0,0,0,.05)); color: var(--color-primary);
}
.guide-discipline-toggle { color: var(--color-muted-foreground); transition: transform .3s ease; }
.guide-discipline-toggle.expanded { transform: rotate(180deg); }
.guide-discipline-content { padding: 0 1.5rem 1.5rem; }
.guide-section-block { margin-top: 1.5rem; }
.guide-section-label {
  display: flex; align-items: center; gap: .5rem;
  font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: .05em;
  color: var(--color-muted-foreground); margin-bottom: .75rem;
}
.guide-section-label::after { content: ""; flex: 1; height: 1px; background: var(--color-border); }

/* Importance box */
.guide-importance-box {
  margin-top: 1rem;
  background: var(--color-accent-bg, rgba(0,0,0,.03));
  border-left: 4px solid var(--color-primary);
  border-radius: 0 .75rem .75rem 0;
  padding: 1rem; font-size: .9rem; color: var(--color-muted-foreground);
}
.guide-importance-label {
  font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: .05em;
  color: var(--color-primary); margin-bottom: .5rem;
}

/* Book cards */
.guide-book-card {
  display: flex; gap: 1rem; padding: 1rem; border-radius: .75rem;
  background: var(--color-accent-bg, rgba(0,0,0,.03));
}
.guide-book-cover {
  flex-shrink: 0; width: 96px; height: 144px; object-fit: cover;
  border-radius: .5rem;
}
.guide-book-info { flex: 1; min-width: 0; }
.guide-book-title { font-weight: 700; color: var(--color-foreground); margin-bottom: .25rem; }
.guide-book-meta { font-size: .8rem; color: var(--color-muted-foreground); margin-bottom: .5rem; }
.guide-book-paragraph { font-size: .9rem; color: var(--color-muted-foreground); margin-bottom: .75rem; }
.guide-book-links { display: flex; flex-wrap: wrap; gap: .5rem; }
.guide-book-link {
  font-size: .8rem; font-weight: 600; padding: .375rem .75rem; border-radius: .5rem;
  border: 1px solid var(--color-border); color: var(--color-primary);
  transition: background .2s ease, color .2s ease;
}
.guide-book-link:hover { background: var(--color-primary); color: var(--color-background); }

/* Resources */
.guide-resource-link {
  display: flex; align-items: center; gap: .75rem; padding: .75rem;
  border-radius: .5rem; font-size: .9rem; color: var(--color-foreground);
  transition: background .2s ease;
}
.guide-resource-link:hover { background: var(--color-accent-bg, rgba(0,0,0,.03)); }
.guide-resource-icon {
  flex-shrink: 0; width: 2rem; height: 2rem; border-radius: .5rem;
  display: flex; align-items: center; justify-content: center;
  background: var(--color-accent-bg, rgba(0,0,0,.05)); font-size: .85rem;
}
.guide-resource-title { font-weight: 500; color: var(--color-foreground); }
.guide-resource-desc { font-size: .8rem; color: var(--color-muted-foreground); }

/* Dark mode */
.dark .guide-course-card:hover,
.dark .guide-discipline-header:hover,
.dark .guide-resource-link:hover { background: rgba(255,255,255,.05); }
.dark .guide-book-card { background: rgba(255,255,255,.05); }

/* Responsivo */
@media (max-width: 640px) {
  .guide-book-card { flex-direction: column; }
  .guide-book-cover { width: 100%; height: auto; max-height: 220px; }
}
```

- [ ] **Step 2: Commit**

```bash
git add styles/globals.css
git commit -m "style: add study guides CSS"
```

---

## Task 7: Admin — Gestão de Guias

**Files:**
- Create: `app/[lang]/admin/(protected)/guias/page.js` — Server Component
- Create: `components/admin/GuidesAdminPage.jsx` — Client Component
- Create: `components/admin/GuideCursoForm.jsx`
- Create: `components/admin/GuideDisciplinaForm.jsx`
- Modify: `components/layout/AdminSidebar.jsx`

- [ ] **Step 1: Server Component admin**

```jsx
// app/[lang]/admin/(protected)/guias/page.js
import { getAllGuideCourses } from '@/lib/actions/guides'
import { getCurrentRole } from '@/lib/actions/auth'
import GuidesAdminPage from '@/components/admin/GuidesAdminPage'

export const dynamic = 'force-dynamic'

export default async function AdminGuiasPage({ params }) {
  const { lang } = await params
  const [courses, currentUserRole] = await Promise.all([
    getAllGuideCourses(),
    getCurrentRole(),
  ])

  return <GuidesAdminPage lang={lang} courses={courses} currentUserRole={currentUserRole} />
}
```

- [ ] **Step 2: `GuidesAdminPage.jsx` — gestão hierárquica**

Padrão `PrivacyAdminPage` (slide-in edit panel — commit 2826073) + `BilingualTabs` para PT/EN. Estrutura:

1. **Cursos** — tabela (Nome PT/EN, Slug, Status, Disciplinas, Ações: Editar / Publicar-Draft / Arquivar / Eliminar) + botão "Novo Curso".
2. **Painel deslizante** `GuideCursoForm` — campos: slug, `name_pt/en`, `description_pt/en`, `hero_subtitle_pt/en`, emoji, cor, status, ordem (BilingualTabs).
3. **Disciplinas do curso selecionado** — lista por curso com botão "Nova Disciplina"; editar abre `GuideDisciplinaForm`.
4. **`GuideDisciplinaForm`** — campos da disciplina (BilingualTabs) + secções dinâmicas:
   - **Livros**: array de cards (título PT/EN, autor, edição, ano, `cover_url`, parágrafo PT/EN, links `[{label_pt, label_en, url}]` dinâmicos, remover) — botão "Adicionar Livro".
   - **Recursos**: array (título PT/EN, descrição PT/EN, URL, tipo select pdf/guideline/article/other, remover) — botão "Adicionar Recurso".

**Segurança:** todas as gravações passam pelas Server Actions com Zod (Task 2). Estados de erro exibidos inline. Confirmação antes de eliminar (reutilizar `ConfirmModal`). `supabaseClient` nunca acedido diretamente no client.

- [ ] **Step 3: `AdminSidebar.jsx` — link**

```jsx
import { BookOpen } from 'lucide-react'
// ...
{ href: `/${lang}/admin/guias`, label: 'Guias de Estudo', icon: BookOpen },
// entre "Lives" e "Traduções EN" (após artigos/eventos/lives, antes de traduções)
```

- [ ] **Step 4: Commit**

```bash
git add 'app/[lang]/admin/(protected)/guias/' components/admin/GuidesAdminPage.jsx components/admin/GuideCursoForm.jsx components/admin/GuideDisciplinaForm.jsx components/layout/AdminSidebar.jsx
git commit -m "feat(admin): add study guides management (courses, disciplines, books, resources)"
```

---

## Task 8: Navegação Pública

**Files:**
- Modify: `components/layout/Header.jsx`
- Modify: `components/layout/MobileDrawer.jsx`
- Modify: `components/layout/Footer.jsx`

- [ ] **Step 1: Header (nav desktop)**

Em `navLinks` (após "Lives" e antes de "Sobre"):
```jsx
{ href: getSectionHref(lang, 'guias'), label: t('nav.guias'), path: 'guias' },
```

- [ ] **Step 2: MobileDrawer** — mesmo link no drawer (padrão do Header).

- [ ] **Step 3: Footer** — na coluna "Navegação" (após "Sobre"):
```jsx
<li><Link href={getSectionHref(lang, 'guias')}>{t('footer.guias')}</Link></li>
```

- [ ] **Step 4: Commit**

```bash
git add components/layout/Header.jsx components/layout/MobileDrawer.jsx components/layout/Footer.jsx
git commit -m "feat(nav): add 'Guias de Estudo' links to header, drawer and footer"
```

---

## Task 9: Verificação Final

- [ ] **Step 1: Validar sintaxe e JSON**

```bash
node --check lib/actions/guides.js
node -e "JSON.parse(require('fs').readFileSync('public/i18n/pt.json'))"
node -e "JSON.parse(require('fs').readFileSync('public/i18n/en.json'))"
```

- [ ] **Step 2: Build de produção**

```bash
npm run build 2>&1 | tail -30
```

Expected: build succeed, sem erros de import/sintaxe. Rotas novas no route map: `/[lang]/guias`, `/[lang]/guias/[slug]`, `/[lang]/admin/(protected)/guias`.

- [ ] **Step 3: Verificar páginas no dev**

```bash
npm run dev
```

Abrir no browser:
- `/pt/guias` — 4 cards de cursos (seed)
- `/pt/guias/farmacia` — disciplina Farmacologia com livro + recurso
- `/en/guides` e `/en/guides/farmacia` — versão EN
- `/pt/guias/medicina` — disciplina placeholder (sem livros/recursos ainda)
- `/pt/admin/guias` — criar curso → aparece no índice; criar disciplina com livro → aparece na página do curso; eliminar disciplina → remove cascade livros+recursos
- `/pt/guias/farmacologia-invalido` (slug inexistente) → 404 (notFound)

- [ ] **Step 4: Verificar responsividade e dark mode**
  - Mobile (320-480px): cards 1 coluna; book cards empilhados
  - Tablet (768px): grid 2 colunas
  - Desktop (1024px+): layout completo
  - Alternar dark mode em cada página — todos os `.guide-*` adaptam

- [ ] **Step 5: Verificar SEO/JSON-LD**
  - Metadata no `<head>` (title, description, canonical)
  - Breadcrumb renderizado com JSON-LD nas páginas de curso

---

## Self-Review (Spec → Plano)

- [x] Spec 1: 4 tabelas (courses, disciplines, books, resources) com FK CASCADE → Task 1 ✓
- [x] Spec 2: RLS — admin full + anon read published/non-archived → Task 1 ✓
- [x] Spec 3: Bilíngue PT/EN (colunas `_pt`/`_en`, links com `label_pt`/`label_en`) → Task 1 ✓
- [x] Spec 4: Leitura pública via Server Actions com colunas explícitas → Task 2 ✓
- [x] Spec 5: CRUD admin com Zod (URLs validadas — SEC-XSS-03) → Task 2 ✓
- [x] Spec 6: `revalidatePath` em todos os writes → Task 2 ✓
- [x] Spec 7: Índice público com grid de cards → Tasks 4, 5 ✓
- [x] Spec 8: Detalhe do curso com disciplinas expandíveis, livros e recursos → Tasks 4, 5 ✓
- [x] Spec 9: Links externos `target="_blank" rel="noopener noreferrer"` → Task 4 ✓
- [x] Spec 10: i18n (rotas `guias`/`guides`, chaves pt/en) → Task 3 ✓
- [x] Spec 11: Admin hierárquico (curso → disciplinas → livros/recursos) → Task 7 ✓
- [x] Spec 12: Navegação (header, drawer, footer, sidebar admin) → Tasks 7, 8 ✓
- [x] Spec 13: SEO via metadata API + Breadcrumb JSON-LD → Task 5 ✓
- [x] Spec 14: CSS responsivo + dark mode → Task 6 ✓

**Open questions resolved:**
- Fallback JSON do plano antigo: eliminado — o catálogo vira seed na migração e o resto entra via CMS (padrão FAQ/Privacy).
- `escapeHtml()`/`escapeAttr()` (XSS vanilla): não aplicável — React escapa por omissão; validação moved para Zod server-side.
- `status` vs `pending`: usa-se `status ('draft'|'published')` + `is_archived` (padrão eventos), em vez do `pending` boolean da FAQ.
- 4 páginas HTML estáticas → 1 rota dinâmica `/[lang]/guias/[slug]`.
- Número de migração: `038` (o `019` já está usado).
- Admin com `deleteGuideCourse`/`deleteGuideDiscipline` (CASCADE) + archive/restore para cursos; disciplinas/livros/recursos com delete + confirmation modal.
