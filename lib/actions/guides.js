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
//  Zod schemas — validação server-side (URLs: https:// ou relativo)
// ============================================================
const URL_SAFE = z.string().refine(
  (u) => !u || /^(https:\/\/|\/)/i.test(u),
  'URL deve começar por https:// ou ser um caminho relativo'
)

const guideCourseSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
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
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
  name_pt: z.string().min(1, 'Nome (PT) é obrigatório'),
  name_en: z.string().min(1, 'Name (EN) is required'),
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
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  author: z.string().optional().default(''),
  edition: z.string().optional().default(''),
  year: z.number().int().min(1900).max(2100).optional().nullable(),
  cover_url: URL_SAFE.optional().default(''),
  team_paragraph_pt: z.string().optional().default(''),
  team_paragraph_en: z.string().optional().default(''),
  links: z.array(z.object({
    label_pt: z.string().min(1, 'Label PT do link é obrigatório'),
    label_en: z.string().min(1, 'Label EN do link é obrigatório'),
    url: z.string().url('URL inválida'),
  })).optional().default([]),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const guideResourceSchema = z.object({
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  description_pt: z.string().optional().default(''),
  description_en: z.string().optional().default(''),
  url: z.string().url('URL inválida'),
  type: z.enum(['pdf', 'guideline', 'article', 'other']).default('pdf'),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

// Universidades: nomes próprios (sem colunas bilingues) — o nome/links são
// os mesmos em PT/EN (ex. "Universidade Agostinho Neto").
const guideUniversitySchema = z.object({
  name: z.string().min(1, 'Nome da universidade é obrigatório'),
  city: z.string().optional().default(''),
  is_public: z.boolean().optional().default(true),
  website_url: URL_SAFE.optional().default(''),
  course_url: URL_SAFE.optional().default(''),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

// ============================================================
//  PÚBLICO — leitura (apenas published + is_archived=false)
//  A RLS já filtra; as queries reforçam com colunas explícitas.
// ============================================================

const COURSE_COLS = 'id, slug, name_pt, name_en, description_pt, description_en, hero_subtitle_pt, hero_subtitle_en, icon_emoji, color, sort_order'
const DISCIPLINE_COLS = 'id, slug, course_id, name_pt, name_en, description_pt, description_en, phase_pt, phase_en, importance_pt, importance_en, sort_order'
const UNIVERSITY_COLS = 'id, course_id, name, city, is_public, website_url, course_url, sort_order'

/** Seleção de campo por idioma (pt/en) para colunas *_pt / *_en. */
function pickLang(row, prefix, lang) {
  const key = lang === 'en' ? 'en' : 'pt'
  return row[`${prefix}_${key}`]
}

/**
 * Páginas públicas — índice de cursos.
 * `lang` controla os campos devolvidos (name/description/heroSubtitle).
 */
export async function getPublicGuideCourses(lang = 'pt') {
  const supabase = await createClient()
  try {
    // Nº de disciplinas publicado por curso: uma query agregada + contagem em JS
    // (evita N+1 e mantém-se atualizado automaticamente com o conteúdo).
    const [{ data, error }, { data: discRows, error: discError }] = await Promise.all([
      supabase.from('guide_courses')
        .select(COURSE_COLS)
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('sort_order', { ascending: true }),
      supabase.from('guide_disciplines')
        .select('course_id')
        .eq('status', 'published')
        .eq('is_archived', false),
    ])
    if (error || discError) return []

    const countByCourse = (discRows || []).reduce((acc, d) => {
      acc[d.course_id] = (acc[d.course_id] || 0) + 1
      return acc
    }, {})

    return (data || []).map((c) => ({
      id: c.id,
      slug: c.slug,
      name: pickLang(c, 'name', lang),
      description: pickLang(c, 'description', lang),
      heroSubtitle: pickLang(c, 'hero_subtitle', lang),
      iconEmoji: c.icon_emoji,
      color: c.color,
      sortOrder: c.sort_order,
      disciplineCount: countByCourse[c.id] || 0,
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

    const { data: universities, error: uErr } = await supabase
      .from('guide_universities')
      .select(UNIVERSITY_COLS)
      .eq('course_id', course.id)
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })
    if (uErr) return null

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
        id: d.id,
        slug: d.slug,
        courseId: d.course_id,
        name: pickLang(d, 'name', lang),
        description: pickLang(d, 'description', lang),
        phase: pickLang(d, 'phase', lang),
        importance: pickLang(d, 'importance', lang),
        sortOrder: d.sort_order,
        books: (books.data || []).map((b) => ({
          id: b.id,
          title: pickLang(b, 'title', lang),
          author: b.author,
          edition: b.edition,
          year: b.year,
          coverUrl: b.cover_url,
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
          url: r.url,
          type: r.type,
        })),
      }
    }))

    return {
      id: course.id,
      slug: course.slug,
      name: pickLang(course, 'name', lang),
      description: pickLang(course, 'description', lang),
      heroSubtitle: pickLang(course, 'hero_subtitle', lang),
      iconEmoji: course.icon_emoji,
      color: course.color,
      disciplines: disciplinesResolved,
      universities: (universities || []).map((u) => ({
        id: u.id,
        name: u.name,
        city: u.city,
        isPublic: u.is_public,
        websiteUrl: u.website_url,
        courseUrl: u.course_url,
        sortOrder: u.sort_order,
      })),
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

/** Detalhe admin de um curso: disciplinas + livros + recursos aninhados. */
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

    const { data: universities, error: uErr } = await supabase
      .from('guide_universities')
      .select('*')
      .eq('course_id', id)
      .order('sort_order', { ascending: true })
    if (uErr) return null

    return { ...course, disciplines: disciplines || [], universities: universities || [] }
  } catch {
    return null
  }
}

export async function createGuideCourse(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const parsed = guideCourseSchema.safeParse(data)
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_courses')
      .insert(parsed.data)
      .select()
      .single()
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
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('guide_courses')
      .update(parsed.data)
      .eq('id', id)
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
    const { error } = await supabase
      .from('guide_courses')
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
    const { error } = await supabase
      .from('guide_courses')
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
    // ON DELETE CASCADE remove disciplinas + livros + recursos
    const { error } = await supabase.from('guide_courses').delete().eq('id', id)
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
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_disciplines')
      .insert({ ...parsed.data, course_id: courseId })
      .select()
      .single()
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
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('guide_disciplines')
      .update(parsed.data)
      .eq('id', id)
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
    // ON DELETE CASCADE remove livros + recursos da disciplina
    const { error } = await supabase.from('guide_disciplines').delete().eq('id', id)
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
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_books')
      .insert({ ...parsed.data, discipline_id: disciplineId })
      .select()
      .single()
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
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('guide_books')
      .update(parsed.data)
      .eq('id', id)
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
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_resources')
      .insert({ ...parsed.data, discipline_id: disciplineId })
      .select()
      .single()
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
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('guide_resources')
      .update(parsed.data)
      .eq('id', id)
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

// ============================================================
//  ADMIN — Universidades CRUD
// ============================================================

export async function createGuideUniversity(courseId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const parsed = guideUniversitySchema.safeParse(data)
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { data: row, error } = await supabase
      .from('guide_universities')
      .insert({ ...parsed.data, course_id: courseId })
      .select()
      .single()
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true, data: row }
  } catch {
    return { success: false, error: 'Erro ao criar universidade' }
  }
}

export async function updateGuideUniversity(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const parsed = guideUniversitySchema.partial().safeParse(data)
  if (!parsed.success) {
    return { success: false, error: parsed.error.errors[0]?.message || 'Dados inválidos' }
  }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('guide_universities')
      .update(parsed.data)
      .eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar universidade' }
  }
}

export async function deleteGuideUniversity(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase.from('guide_universities').delete().eq('id', id)
    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/guias')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao eliminar universidade' }
  }
}
