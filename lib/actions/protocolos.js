'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'

// ============================================================
//  Helper: requireAdmin (padrão de legalContent.js / guides.js)
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
//  Helpers
// ============================================================
function pickLang(row, prefix, lang) {
  return row[`${prefix}_${lang}`] ?? row[`${prefix}_pt`] ?? ''
}

// ============================================================
//  Zod schemas — validação server-side (URLs: https:// ou relativo)
// ============================================================
const URL_SAFE = z.string().refine(
  (u) => !u || /^(https:\/\/|\/)/i.test(u),
  'URL deve começar por https:// ou ser um caminho relativo'
)

const protocolCategorySchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
  name_pt: z.string().min(1, 'Nome (PT) é obrigatório'),
  name_en: z.string().min(1, 'Name (EN) is required'),
  color: z.string().optional().default('#0a844f'),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const drugSchema = z.object({
  label_pt: z.string().min(1, 'Rótulo do fármaco (PT) é obrigatório'),
  label_en: z.string().min(1, 'Drug label (EN) is required'),
  dose: z.string().optional().default(''),
})

const protocolStepSchema = z.object({
  label_pt: z.string().optional().default(''),
  label_en: z.string().optional().default(''),
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  body_pt: z.string().optional().default(''),
  body_en: z.string().optional().default(''),
  recommendation: z.enum(['strong', 'conditional']).nullable().optional(),
  evidence: z.enum(['high', 'moderate', 'low']).nullable().optional(),
  drugs: z.array(drugSchema).optional().default([]),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const protocolReferenceSchema = z.object({
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  url: URL_SAFE,
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const protocolQuizSchema = z.object({
  question_pt: z.string().min(1, 'Pergunta (PT) é obrigatória'),
  question_en: z.string().min(1, 'Question (EN) is required'),
  option_a_pt: z.string().optional().default(''),
  option_a_en: z.string().optional().default(''),
  option_b_pt: z.string().optional().default(''),
  option_b_en: z.string().optional().default(''),
  option_c_pt: z.string().optional().default(''),
  option_c_en: z.string().optional().default(''),
  option_d_pt: z.string().optional().default(''),
  option_d_en: z.string().optional().default(''),
  correct_index: z.number().int().min(0).max(3).default(0),
  explanation_pt: z.string().optional().default(''),
  explanation_en: z.string().optional().default(''),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const protocolSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
  category_id: z.string().uuid('Categoria inválida'),
  title_pt: z.string().min(1, 'Título (PT) é obrigatório'),
  title_en: z.string().min(1, 'Title (EN) is required'),
  description_pt: z.string().optional().default(''),
  description_en: z.string().optional().default(''),
  summary_pt: z.string().optional().default(''),
  summary_en: z.string().optional().default(''),
  safety_notes_pt: z.string().optional().default(''),
  safety_notes_en: z.string().optional().default(''),
  red_flags_pt: z.string().optional().default(''),
  red_flags_en: z.string().optional().default(''),
  source_pt: z.string().optional().default(''),
  source_en: z.string().optional().default(''),
  source_url: URL_SAFE.nullable().optional(),
  difficulty: z.enum(['iniciante', 'intermedio', 'avancado']).nullable().optional(),
  pdf_url: URL_SAFE.nullable().optional(),
  is_updated: z.boolean().optional().default(false),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

// ============================================================
//  Público
// ============================================================
export async function getPublicProtocolCategories(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('clinical_protocol_categories')
    .select('id, slug, name_pt, name_en, color, sort_order')
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((c) => ({
    id: c.id,
    slug: c.slug,
    name: pickLang(c, 'name', lang),
    color: c.color,
  }))
}

export async function getPublicProtocols(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('clinical_protocols')
    .select(
      'id, slug, title_pt, title_en, description_pt, description_en, difficulty, is_updated, updated_at, sort_order, ' +
      'clinical_protocol_categories(slug, name_pt, name_en, color), clinical_protocol_steps(count)'
    )
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('sort_order', { ascending: true })
  if (error) return []
  // RLS esconde categorias draft/arquivadas — filtrar protocolos sem categoria visível
  return (data || [])
    .filter((p) => p.clinical_protocol_categories)
    .map((p) => ({
      id: p.id,
      slug: p.slug,
      title: pickLang(p, 'title', lang),
      description: pickLang(p, 'description', lang),
      difficulty: p.difficulty,
      isUpdated: p.is_updated,
      updatedAt: p.updated_at,
      stepCount: p.clinical_protocol_steps?.[0]?.count || 0,
      categorySlug: p.clinical_protocol_categories.slug,
      categoryName: pickLang(p.clinical_protocol_categories, 'name', lang),
      categoryColor: p.clinical_protocol_categories.color,
    }))
}

export async function getPublicProtocolBySlug(slug, lang = 'pt') {
  const supabase = await createClient()
  const { data: row, error } = await supabase
    .from('clinical_protocols')
    .select('*, clinical_protocol_categories(slug, name_pt, name_en, color)')
    .eq('slug', slug)
    .eq('status', 'published')
    .eq('is_archived', false)
    .maybeSingle()
  if (error || !row || !row.clinical_protocol_categories) return null

  const [stepsRes, refsRes, quizzesRes] = await Promise.all([
    supabase.from('clinical_protocol_steps')
      .select('*').eq('protocol_id', row.id).eq('status', 'published').eq('is_archived', false)
      .order('sort_order', { ascending: true }),
    supabase.from('clinical_protocol_references')
      .select('*').eq('protocol_id', row.id).eq('status', 'published').eq('is_archived', false)
      .order('sort_order', { ascending: true }),
    supabase.from('clinical_protocol_quizzes')
      .select('*').eq('protocol_id', row.id).eq('status', 'published').eq('is_archived', false)
      .order('sort_order', { ascending: true }),
  ])

  return {
    id: row.id,
    slug: row.slug,
    title: pickLang(row, 'title', lang),
    description: pickLang(row, 'description', lang),
    summary: pickLang(row, 'summary', lang),
    safetyNotes: pickLang(row, 'safety_notes', lang),
    redFlags: pickLang(row, 'red_flags', lang),
    source: pickLang(row, 'source', lang),
    sourceUrl: row.source_url || null,
    pdfUrl: row.pdf_url || null,
    difficulty: row.difficulty,
    isUpdated: row.is_updated,
    updatedAt: row.updated_at,
    category: {
      slug: row.clinical_protocol_categories.slug,
      name: pickLang(row.clinical_protocol_categories, 'name', lang),
      color: row.clinical_protocol_categories.color,
    },
    steps: (stepsRes.data || []).map((s) => ({
      id: s.id,
      label: pickLang(s, 'label', lang),
      title: pickLang(s, 'title', lang),
      body: pickLang(s, 'body', lang),
      recommendation: s.recommendation,
      evidence: s.evidence,
      drugs: (s.drugs || []).map((d) => ({ label: pickLang(d, 'label', lang), dose: d.dose || '' })),
    })),
    references: (refsRes.data || []).map((r) => ({ id: r.id, title: pickLang(r, 'title', lang), url: r.url })),
    quizzes: (quizzesRes.data || []).map((q) => ({
      id: q.id,
      question: pickLang(q, 'question', lang),
      options: [
        pickLang(q, 'option_a', lang),
        pickLang(q, 'option_b', lang),
        pickLang(q, 'option_c', lang),
        pickLang(q, 'option_d', lang),
      ],
      correctIndex: q.correct_index,
      explanation: pickLang(q, 'explanation', lang),
    })),
  }
}

// ============================================================
//  Admin — Categorias
// ============================================================
export async function getAllProtocolCategories() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('clinical_protocol_categories')
    .select('*, clinical_protocols(count)')
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((c) => ({
    id: c.id,
    slug: c.slug,
    name_pt: c.name_pt,
    name_en: c.name_en,
    color: c.color,
    status: c.status,
    sort_order: c.sort_order,
    is_archived: c.is_archived,
    protocolCount: c.clinical_protocols?.[0]?.count || 0,
  }))
}

export async function createProtocolCategory(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolCategorySchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_categories').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolCategory(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolCategorySchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_categories').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function archiveProtocolCategory(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('clinical_protocol_categories')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function restoreProtocolCategory(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('clinical_protocol_categories')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolCategory(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('clinical_protocol_categories').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Protocolos
// ============================================================
export async function getAllClinicalProtocols() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('clinical_protocols')
    .select(
      'id, slug, title_pt, title_en, category_id, difficulty, is_updated, status, sort_order, is_archived, updated_at, ' +
      'clinical_protocol_categories(name_pt, name_en, color), clinical_protocol_steps(count)'
    )
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((p) => ({
    id: p.id,
    slug: p.slug,
    title_pt: p.title_pt,
    title_en: p.title_en,
    category_id: p.category_id,
    categoryName: p.clinical_protocol_categories?.name_pt || '—',
    categoryColor: p.clinical_protocol_categories?.color || '#0a844f',
    difficulty: p.difficulty,
    is_updated: p.is_updated,
    status: p.status,
    sort_order: p.sort_order,
    is_archived: p.is_archived,
    stepCount: p.clinical_protocol_steps?.[0]?.count || 0,
  }))
}

export async function getProtocolDetail(id) {
  const ctx = await requireAdmin()
  if (!ctx) return null
  const { data, error } = await ctx.supabase
    .from('clinical_protocols')
    .select('*, clinical_protocol_steps(*), clinical_protocol_references(*), clinical_protocol_quizzes(*)')
    .eq('id', id)
    .order('sort_order', { ascending: true, referencedTable: 'clinical_protocol_steps' })
    .order('sort_order', { ascending: true, referencedTable: 'clinical_protocol_references' })
    .order('sort_order', { ascending: true, referencedTable: 'clinical_protocol_quizzes' })
    .maybeSingle()
  if (error || !data) return null
  return data
}

export async function createProtocol(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocols').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocol(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocols').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function archiveProtocol(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('clinical_protocols')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function restoreProtocol(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('clinical_protocols')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocol(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('clinical_protocols').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Passos
// ============================================================
export async function createProtocolStep(protocolId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolStepSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_steps').insert({ ...parsed.data, protocol_id: protocolId })
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolStep(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolStepSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_steps').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolStep(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase.from('clinical_protocol_steps').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Referências
// ============================================================
export async function createProtocolReference(protocolId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolReferenceSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_references').insert({ ...parsed.data, protocol_id: protocolId })
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolReference(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolReferenceSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_references').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolReference(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase.from('clinical_protocol_references').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

// ============================================================
//  Admin — Quiz
// ============================================================
export async function createProtocolQuiz(protocolId, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolQuizSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_quizzes').insert({ ...parsed.data, protocol_id: protocolId })
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function updateProtocolQuiz(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = protocolQuizSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('clinical_protocol_quizzes').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}

export async function deleteProtocolQuiz(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase.from('clinical_protocol_quizzes').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/protocolos')
  return { success: true }
}
