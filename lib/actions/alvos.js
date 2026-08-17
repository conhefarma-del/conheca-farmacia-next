'use server'

import { createClient } from '@/lib/supabase/server'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { unstable_cache, revalidatePath, revalidateTag } from 'next/cache'
import { z } from 'zod'

// ============================================================
//  Helper: requireAdmin (padrão de interacoes.js)
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

const targetSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
  target_type: z.enum(['cyp450', 'cox', 'transporter', 'mao', 'enzyme', 'receptor', 'other']),
  name_pt: z.string().min(1, 'Nome (PT) é obrigatório'),
  name_en: z.string().min(1, 'Name (EN) is required'),
  full_name_pt: z.string().optional().default(''),
  full_name_en: z.string().optional().default(''),
  aliases: z.array(z.string()).optional().default([]),
  what_is_pt: z.string().optional().default(''),
  what_is_en: z.string().optional().default(''),
  role_pt: z.string().optional().default(''),
  role_en: z.string().optional().default(''),
  substrates_pt: z.string().optional().default(''),
  substrates_en: z.string().optional().default(''),
  inhibitors_pt: z.string().optional().default(''),
  inhibitors_en: z.string().optional().default(''),
  inducers_pt: z.string().optional().default(''),
  inducers_en: z.string().optional().default(''),
  clinical_notes_pt: z.string().optional().default(''),
  clinical_notes_en: z.string().optional().default(''),
  source_pt: z.string().optional().default(''),
  source_en: z.string().optional().default(''),
  sort_order: z.number().int().optional().default(0),
  status: z.enum(['draft', 'published']).default('draft'),
})

// ============================================================
//  Helpers
// ============================================================
function pickLang(row, prefix, lang) {
  return row[`${prefix}_${lang}`] ?? row[`${prefix}_pt`] ?? ''
}

function mapTarget(row, lang) {
  return {
    id: row.id,
    slug: row.slug,
    targetType: row.target_type,
    name: pickLang(row, 'name', lang),
    fullName: pickLang(row, 'full_name', lang),
    aliases: row.aliases || [],
    whatIs: pickLang(row, 'what_is', lang),
    role: pickLang(row, 'role', lang),
    substrates: pickLang(row, 'substrates', lang),
    inhibitors: pickLang(row, 'inhibitors', lang),
    inducers: pickLang(row, 'inducers', lang),
    clinicalNotes: pickLang(row, 'clinical_notes', lang),
    source: pickLang(row, 'source', lang),
    sortOrder: row.sort_order || 0,
  }
}

// ============================================================
//  Queries públicas (ISR 3600s, tag 'alvos')
// ============================================================
export const getPublicTargets = unstable_cache(
  async (lang = 'pt') => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('molecular_targets')
      .select('*')
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })
    if (error) return []
    return (data || []).map((d) => mapTarget(d, lang))
  },
  ['api', 'alvos', 'list'],
  { revalidate: 3600, tags: ['alvos'] }
)

export const getPublicTargetBySlug = unstable_cache(
  async (slug, lang = 'pt') => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('molecular_targets')
      .select('*')
      .eq('slug', slug)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()
    if (error || !data) return null
    return mapTarget(data, lang)
  },
  ['api', 'alvos', 'slug'],
  { revalidate: 3600, tags: ['alvos'] }
)

// ============================================================
//  Admin — CRUD de alvos moleculares
// ============================================================
export async function getAllTargetsAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('molecular_targets')
    .select('*')
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((d) => ({
    id: d.id,
    slug: d.slug,
    target_type: d.target_type,
    name_pt: d.name_pt,
    name_en: d.name_en,
    full_name_pt: d.full_name_pt,
    full_name_en: d.full_name_en,
    aliases: d.aliases || [],
    what_is_pt: d.what_is_pt,
    what_is_en: d.what_is_en,
    role_pt: d.role_pt,
    role_en: d.role_en,
    substrates_pt: d.substrates_pt,
    substrates_en: d.substrates_en,
    inhibitors_pt: d.inhibitors_pt,
    inhibitors_en: d.inhibitors_en,
    inducers_pt: d.inducers_pt,
    inducers_en: d.inducers_en,
    clinical_notes_pt: d.clinical_notes_pt,
    clinical_notes_en: d.clinical_notes_en,
    source_pt: d.source_pt,
    source_en: d.source_en,
    sort_order: d.sort_order,
    status: d.status,
    is_archived: d.is_archived,
  }))
}

export async function createTarget(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = targetSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('molecular_targets').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

export async function updateTarget(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = targetSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('molecular_targets').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

export async function archiveTarget(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('molecular_targets')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

export async function restoreTarget(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('molecular_targets')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

export async function deleteTarget(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('molecular_targets').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}
