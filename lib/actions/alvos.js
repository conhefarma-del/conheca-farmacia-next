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
//  Pares com auto-interação — pré-computados na view materializada
//  auto_interaction_pairs (migração 190), em vez de cruzar no cliente
// ============================================================

/**
 * Pares de interações fármaco-fármaco com auto-interação, pré-computados
 * em SQL: um par tem auto-interação quando um fármaco é substrato de um
 * alvo e o outro é inibidor/indutor do MESMO alvo (ex.: claritromicina ×
 * simvastatina no CYP3A4). Devolve [{ pairId, drugAId, drugBId,
 * targetSlug, targetName, roleA, roleB }]. Se a view ainda não existir
 * (migração 190 por aplicar), devolve [] e a página degrada sem avisos.
 */
export const getAutoInteractionPairs = unstable_cache(
  async (lang = 'pt') => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('auto_interaction_pairs')
      .select(
        'pair_id, drug_a_id, drug_b_id, target_slug, target_name_pt, target_name_en, role_a, role_b'
      )
    if (error) return []
    return (data || []).map((r) => ({
      pairId: r.pair_id,
      drugAId: r.drug_a_id,
      drugBId: r.drug_b_id,
      targetSlug: r.target_slug,
      targetName: lang === 'en' ? r.target_name_en || r.target_name_pt : r.target_name_pt,
      roleA: r.role_a,
      roleB: r.role_b,
    }))
  },
  ['api', 'alvos', 'auto-interaction-pairs'],
  { revalidate: 3600, tags: ['alvos'] }
)

// ============================================================
//  Contagens de fármacos por papel e alvo — para a listagem /alvos
// ============================================================

/**
 * Nº de fármacos publicados com cada papel (substrato/inibidor/indutor)
 * por alvo molecular — contagens reais de drug_target_roles. Usado nos
 * cards da listagem /alvos (ex.: "12 substratos · 9 inibidores").
 */
export const getTargetDrugCounts = unstable_cache(
  async () => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('drug_target_roles')
      .select('target_id, role')
      .eq('status', 'published')
      .eq('is_archived', false)
    if (error) return {}
    const counts = {}
    ;(data || []).forEach((r) => {
      if (!counts[r.target_id]) counts[r.target_id] = { substrate: 0, inhibitor: 0, inducer: 0 }
      if (r.role && counts[r.target_id][r.role] !== undefined) counts[r.target_id][r.role]++
    })
    return counts
  },
  ['api', 'alvos', 'drug-counts'],
  { revalidate: 3600, tags: ['alvos'] }
)

// ============================================================
//  Papéis fármaco ↔ alvo (drug_target_roles) — queries públicas
// ============================================================

/**
 * Papéis publicados de um fármaco em cada alvo molecular, com o alvo
 * juntado (nome, tipo, slug). Usado pela secção "Metabolismo — alvos
 * moleculares" do perfil /medicamento/[slug].
 */
export const getDrugTargetRoles = unstable_cache(
  async (drugId, lang = 'pt') => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('drug_target_roles')
      .select('id, role, source_pt, target:target_id(id, slug, target_type, name_pt, name_en, what_is_pt, what_is_en)')
      .eq('drug_id', drugId)
      .eq('status', 'published')
      .eq('is_archived', false)
      .order('role', { ascending: true })
    if (error || !data) return []
    return (data || []).map((r) => ({
      id: r.id,
      role: r.role,
      source: r.source_pt || '',
      target: {
        id: r.target?.id,
        slug: r.target?.slug,
        targetType: r.target?.target_type,
        name: pickLang(r.target, 'name', lang),
        whatIs: pickLang(r.target, 'what_is', lang),
      },
    }))
  },
  ['api', 'alvos', 'drug-roles'],
  { revalidate: 3600, tags: ['alvos'] }
)

/**
 * Contagens de papéis por fármaco (para o admin /admin/alvos/drug-links).
 * Devolve por fármaco: total de linhas e contagem por papel.
 */
export async function getTargetRoleCounts() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drug_target_roles')
    .select('drug_id, role, status, is_archived')
  if (error) return []
  const counts = {}
  ;(data || []).forEach((r) => {
    if (!counts[r.drug_id]) counts[r.drug_id] = { total: 0, substrate: 0, inhibitor: 0, inducer: 0, archived: 0 }
    counts[r.drug_id].total++
    if (r.is_archived) counts[r.drug_id].archived++
    else if (r.role) counts[r.drug_id][r.role] = (counts[r.drug_id][r.role] || 0) + 1
  })
  return counts
}

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

// ============================================================
//  Admin — drug_target_roles (secção Metabolismo do fármaco)
// ============================================================

/**
 * Lista todas as linhas fármaco ↔ alvo para o admin, com fármaco e alvo
 * juntados. Usada por /admin/alvos/drug-links.
 */
export async function getAllDrugTargetRolesAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drug_target_roles')
    .select('id, role, source_pt, source_en, status, is_archived, archived_at, drug:drug_id(id, slug, name_pt), target:target_id(id, slug, name_pt, target_type)')
    .order('created_at', { ascending: false })
  if (error) return []
  return (data || []).map((r) => ({
    id: r.id,
    role: r.role,
    source_pt: r.source_pt || '',
    source_en: r.source_en || '',
    status: r.status,
    is_archived: r.is_archived,
    archived_at: r.archived_at,
    drug: r.drug ? { id: r.drug.id, slug: r.drug.slug, name: r.drug.name_pt } : null,
    target: r.target
      ? { id: r.target.id, slug: r.target.slug, name: r.target.name_pt, targetType: r.target.target_type }
      : null,
  }))
}

const drugTargetRolePatchSchema = z.object({
  source_pt: z.string().optional(),
  source_en: z.string().optional(),
  status: z.enum(['draft', 'published']).optional(),
})

/** Atualiza fonte/estado de uma linha (toggle aceitar/remover sem apagar). */
export async function updateDrugTargetRole(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = drugTargetRolePatchSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('drug_target_roles').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

export async function archiveDrugTargetRole(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('drug_target_roles')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

export async function restoreDrugTargetRole(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('drug_target_roles')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

export async function deleteDrugTargetRole(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('drug_target_roles').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidateTag('alvos')
  revalidatePath('/[lang]/alvos')
  return { success: true }
}

/**
 * Re-deriva os papéis fármaco ↔ alvo a partir dos textos atuais dos alvos
 * (lib/targets/derive.js). NÃO grava automaticamente: devolve candidatos
 * novos (que ainda não existem na BD) para o admin rever.
 */
export async function rederiveDrugTargetRoles() {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  try {
    const { deriveAllRoles } = await import('@/lib/targets/derive')
    const [targetsRes, drugsRes, existingRes] = await Promise.all([
      ctx.supabase
        .from('molecular_targets')
        .select('id, slug, substrates_pt, inhibitors_pt, inducers_pt, source_pt')
        .eq('status', 'published')
        .eq('is_archived', false),
      ctx.supabase
        .from('drugs')
        .select('id, slug, name_pt, aliases')
        .eq('status', 'published')
        .not('is_archived', 'is', true),
      ctx.supabase
        .from('drug_target_roles')
        .select('drug_id, target_id, role'),
    ])
    const targets = targetsRes.data || []
    const drugs = drugsRes.data || []
    const existing = new Set(
      (existingRes.data || []).map((r) => `${r.drug_id}|${r.target_id}|${r.role}`)
    )
    const derived = deriveAllRoles(targets, drugs)
    const fresh = derived.filter((r) => !existing.has(`${r.drugId}|${r.targetId}|${r.role}`))
    const drugById = new Map(drugs.map((d) => [d.id, d]))
    const targetById = new Map(targets.map((t) => [t.id, t]))
    return {
      success: true,
      total: derived.length,
      novos: fresh.map((r) => ({
        drug: drugById.get(r.drugId)?.name_pt || r.drugSlug,
        target: targetById.get(r.targetId)?.slug || r.targetSlug,
        role: r.role,
        source: r.source,
      })),
    }
  } catch (e) {
    return { success: false, error: e.message || 'Erro ao re-derivar' }
  }
}
