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

// Os pares são guardados de forma canónica (drug_a_id < drug_b_id)
function canonicalPair(a, b) {
  return a < b ? { drug_a_id: a, drug_b_id: b } : { drug_a_id: b, drug_b_id: a }
}

// ============================================================
//  Zod schemas — validação server-side (URLs: https:// ou relativo)
// ============================================================
const URL_SAFE = z.string().refine(
  (u) => !u || /^(https:\/\/|\/)/i.test(u),
  'URL deve começar por https:// ou ser um caminho relativo'
)

const drugSchema = z.object({
  slug: z.string().min(1).regex(/^[a-z0-9-]+$/, 'Slug inválido (apenas letras minúsculas, números e hífens)'),
  name_pt: z.string().min(1, 'Nome (PT) é obrigatório'),
  name_en: z.string().min(1, 'Name (EN) is required'),
  class_pt: z.string().optional().default(''),
  class_en: z.string().optional().default(''),
  aliases: z.array(z.string()).optional().default([]),
  status: z.enum(['draft', 'published']).default('draft'),
  sort_order: z.number().int().optional().default(0),
})

const drugInteractionSchema = z.object({
  drug_a_id: z.string().uuid('Fármaco A inválido'),
  drug_b_id: z.string().uuid('Fármaco B inválido'),
  severity: z.enum(['critical', 'moderate', 'minor', 'none']).default('moderate'),
  summary_pt: z.string().optional().default(''),
  summary_en: z.string().optional().default(''),
  summary_pro_pt: z.string().optional().default(''),
  summary_pro_en: z.string().optional().default(''),
  explanation_pt: z.string().optional().default(''),
  explanation_en: z.string().optional().default(''),
  mechanism_pt: z.string().optional().default(''),
  mechanism_en: z.string().optional().default(''),
  management_pt: z.string().optional().default(''),
  management_en: z.string().optional().default(''),
  monitoring_pt: z.string().optional().default(''),
  monitoring_en: z.string().optional().default(''),
  red_flags_pt: z.string().optional().default(''),
  red_flags_en: z.string().optional().default(''),
  source_pt: z.string().optional().default(''),
  source_en: z.string().optional().default(''),
  source_url: URL_SAFE.optional().default(''),
  status: z.enum(['draft', 'published']).default('draft'),
})

// ============================================================
//  Público
// ============================================================
export async function getPublicDrugs(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('drugs')
    .select('id, slug, name_pt, name_en, class_pt, class_en, aliases, atc_code')
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('name_pt', { ascending: true })
  if (error) return []
  return (data || []).map((d) => ({
    id: d.id,
    slug: d.slug,
    name: pickLang(d, 'name', lang),
    className: pickLang(d, 'class', lang),
    aliases: d.aliases || [],
    atcCode: d.atc_code || '',
  }))
}

// Todos os pares publicados — a página calcula os pares pedidos no client
export async function getPublishedInteractions(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('drug_interactions')
    .select(
      'id, drug_a_id, drug_b_id, severity, summary_pt, summary_en, summary_pro_pt, summary_pro_en, ' +
      'explanation_pt, explanation_en, mechanism_pt, mechanism_en, ' +
      'management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en, source_pt, source_en, source_url'
    )
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('severity', { ascending: true })
  if (error) return []
  return (data || []).map((i) => ({
    id: i.id,
    drugAId: i.drug_a_id,
    drugBId: i.drug_b_id,
    severity: i.severity,
    summary: pickLang(i, 'summary', lang),
    summaryPro: pickLang(i, 'summary_pro', lang),
    explanation: pickLang(i, 'explanation', lang),
    mechanism: pickLang(i, 'mechanism', lang),
    management: pickLang(i, 'management', lang),
    monitoring: pickLang(i, 'monitoring', lang),
    redFlags: pickLang(i, 'red_flags', lang),
    source: pickLang(i, 'source', lang),
    sourceUrl: i.source_url || '',
  }))
}

// ============================================================
//  Público — novas dimensões (Fluxo 2)
//  Fail-safe: se a migração 060 ainda não foi aplicada, a query
//  devolve erro e a função retorna [] (abas vazias, sem quebrar).
// ============================================================

// Medicamento ↔ alimento/bebida
export async function getPublishedFoodInteractions(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('drug_food_interactions')
    .select(
      'id, drug_id, entity_slug, entity_pt, entity_en, severity, mechanism_pt, mechanism_en, ' +
      'advice_pt, advice_en, source_pt, source_en, sort_order'
    )
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((i) => ({
    id: i.id,
    drugId: i.drug_id,
    entitySlug: i.entity_slug,
    entity: pickLang(i, 'entity', lang),
    severity: i.severity,
    mechanism: pickLang(i, 'mechanism', lang),
    advice: pickLang(i, 'advice', lang),
    source: pickLang(i, 'source', lang),
  }))
}

// Medicamento ↔ doença/condição
export async function getPublishedDiseaseInteractions(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('drug_disease_interactions')
    .select(
      'id, drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity, ' +
      'reason_pt, reason_en, advice_pt, advice_en, source_pt, source_en, sort_order'
    )
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((i) => ({
    id: i.id,
    drugId: i.drug_id,
    conditionSlug: i.condition_slug,
    condition: pickLang(i, 'condition', lang),
    interactionType: i.interaction_type,
    severity: i.severity,
    reason: pickLang(i, 'reason', lang),
    advice: pickLang(i, 'advice', lang),
    source: pickLang(i, 'source', lang),
  }))
}

// Medicamento ↔ gestação/lactação (1:1 por fármaco)
export async function getPublishedPregnancyInfo(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('drug_pregnancy_info')
    .select(
      'id, drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en, ' +
      'lactation_pt, lactation_en, contraception_pt, contraception_en, source_pt, source_en'
    )
    .eq('status', 'published')
    .eq('is_archived', false)
  if (error) return []
  return (data || []).map((i) => ({
    id: i.id,
    drugId: i.drug_id,
    pregnancyCategory: i.pregnancy_category,
    risk: pickLang(i, 'risk', lang),
    trimester: pickLang(i, 'trimester', lang),
    lactation: pickLang(i, 'lactation', lang),
    contraception: pickLang(i, 'contraception', lang),
    source: pickLang(i, 'source', lang),
  }))
}

// ============================================================
//  Admin — Fármacos
// ============================================================
export async function getAllDrugs() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drugs')
    .select('*, drug_interactions(count), drug_profiles(status, is_archived), drug_pharmacology(status, is_archived)')
    .order('sort_order', { ascending: true })
  if (error) return []
  return (data || []).map((d) => ({
    id: d.id,
    slug: d.slug,
    name_pt: d.name_pt,
    name_en: d.name_en,
    class_pt: d.class_pt,
    class_en: d.class_en,
    aliases: d.aliases || [],
    atc_code: d.atc_code || '',
    status: d.status,
    sort_order: d.sort_order,
    is_archived: d.is_archived,
    interactionCount: d.drug_interactions?.[0]?.count || 0,
    profileStatus: d.drug_profiles
      ? d.drug_profiles.is_archived
        ? 'archived'
        : d.drug_profiles.status
      : null,
    pharmacologyStatus: d.drug_pharmacology
      ? d.drug_pharmacology.is_archived
        ? 'archived'
        : d.drug_pharmacology.status
      : null,
  }))
}

export async function createDrug(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = drugSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('drugs').insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

export async function updateDrug(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = drugSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from('drugs').update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

export async function archiveDrug(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('drugs')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

export async function restoreDrug(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('drugs')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

export async function deleteDrug(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('drugs').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

// ============================================================
//  Admin — Interações
// ============================================================
export async function getAllDrugInteractions() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drug_interactions')
    .select(
      'id, drug_a_id, drug_b_id, severity, status, is_archived, ' +
      'drugs!drug_interactions_drug_a_id_fkey(name_pt, name_en), ' +
      'drugs!drug_interactions_drug_b_id_fkey(name_pt, name_en)'
    )
    .order('severity', { ascending: true })
  if (error) return []
  return (data || []).map((i) => ({
    id: i.id,
    drugAId: i.drug_a_id,
    drugBId: i.drug_b_id,
    drugAName: i.drugs?.['drug_interactions_drug_a_id_fkey']?.name_pt || '—',
    drugBName: i.drugs?.['drug_interactions_drug_b_id_fkey']?.name_pt || '—',
    severity: i.severity,
    status: i.status,
    is_archived: i.is_archived,
  }))
}

export async function createDrugInteraction(data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = drugInteractionSchema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const pair = canonicalPair(parsed.data.drug_a_id, parsed.data.drug_b_id)
  const { error } = await ctx.supabase.from('drug_interactions').insert({ ...parsed.data, ...pair })
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

// Detalhe completo de um par — usado no painel de edição (espelha getProtocolDetail)
export async function getDrugInteractionDetail(id) {
  const ctx = await requireAdmin()
  if (!ctx) return null
  const { data, error } = await ctx.supabase
    .from('drug_interactions')
    .select('*')
    .eq('id', id)
    .maybeSingle()
  if (error || !data) return null
  return data
}

export async function updateDrugInteraction(id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const parsed = drugInteractionSchema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const payload = { ...parsed.data }
  if (payload.drug_a_id && payload.drug_b_id) {
    Object.assign(payload, canonicalPair(payload.drug_a_id, payload.drug_b_id))
  }
  const { error } = await ctx.supabase.from('drug_interactions').update(payload).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

export async function archiveDrugInteraction(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await ctx.supabase
    .from('drug_interactions')
    .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: ctx.user.id })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

export async function restoreDrugInteraction(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase
    .from('drug_interactions')
    .update({ is_archived: false, archived_at: null, archived_by: null })
    .eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

export async function deleteDrugInteraction(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('drug_interactions').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  return { success: true }
}

// ============================================================
//  Admin — Dimensões (alimento, doença, gestação)
// ============================================================

async function getDrugNames() {
  const ctx = await requireAdmin()
  if (!ctx) return new Map()
  const { data } = await ctx.supabase.from('drugs').select('id, slug, name_pt')
  const map = new Map()
  for (const d of data || []) map.set(d.id, d)
  return map
}

export async function getAllFoodDimensions() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drug_food_interactions')
    .select('id, drug_id, entity_slug, entity_pt, severity, status, is_archived, sort_order, created_at')
    .order('sort_order', { ascending: true })
  if (error) return []
  const drugNames = await getDrugNames()
  return (data || []).map((i) => ({
    id: i.id,
    drugId: i.drug_id,
    drugSlug: drugNames.get(i.drug_id)?.slug || null,
    drugName: drugNames.get(i.drug_id)?.name_pt || '—',
    entity: i.entity_pt || i.entity_slug,
    severity: i.severity,
    status: i.status,
    isArchived: i.is_archived,
    sortOrder: i.sort_order,
    createdAt: i.created_at,
  }))
}

export async function getAllDiseaseDimensions() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drug_disease_interactions')
    .select('id, drug_id, condition_slug, condition_pt, interaction_type, severity, status, is_archived, sort_order, created_at')
    .order('sort_order', { ascending: true })
  if (error) return []
  const drugNames = await getDrugNames()
  return (data || []).map((i) => ({
    id: i.id,
    drugId: i.drug_id,
    drugSlug: drugNames.get(i.drug_id)?.slug || null,
    drugName: drugNames.get(i.drug_id)?.name_pt || '—',
    condition: i.condition_pt || i.condition_slug,
    interactionType: i.interaction_type,
    severity: i.severity,
    status: i.status,
    isArchived: i.is_archived,
    sortOrder: i.sort_order,
    createdAt: i.created_at,
  }))
}

export async function getAllPregnancyDimensions() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drug_pregnancy_info')
    .select('id, drug_id, pregnancy_category, risk_pt, status, is_archived, created_at')
    .order('drug_id', { ascending: true })
  if (error) return []
  const drugNames = await getDrugNames()
  return (data || []).map((i) => ({
    id: i.id,
    drugId: i.drug_id,
    drugSlug: drugNames.get(i.drug_id)?.slug || null,
    drugName: drugNames.get(i.drug_id)?.name_pt || '—',
    pregnancyCategory: i.pregnancy_category,
    risk: (i.risk_pt || '').slice(0, 80),
    status: i.status,
    isArchived: i.is_archived,
    createdAt: i.created_at,
  }))
}

async function dimAction(table, id, fn) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const { error } = await fn(ctx.supabase, id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/admin/interacoes/dimensoes')
  return { success: true }
}

export async function archiveDrugDimension(table, id) {
  return dimAction(table, id, (supabase, i) =>
    supabase.from(table).update({ is_archived: true, archived_at: new Date().toISOString() }).eq('id', i)
  )
}

export async function restoreDrugDimension(table, id) {
  return dimAction(table, id, (supabase, i) =>
    supabase.from(table).update({ is_archived: false, archived_at: null, archived_by: null }).eq('id', i)
  )
}

export async function deleteDrugDimension(table, id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from(table).delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/admin/interacoes/dimensoes')
  return { success: true }
}
