'use server'

import { createClient } from '@/lib/supabase/server'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { unstable_cache } from 'next/cache'
import { revalidatePath, revalidateTag } from 'next/cache'
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
export const getPublicDrugs = unstable_cache(
  async (lang = 'pt') => {
  const supabase = await createAnonClient()
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
  },
  ['api', 'interacoes', 'drugs'],
  { revalidate: 3600, tags: ['interacoes'] }
)// Todos os pares publicados — payload ENXUTO (P2): só o que a lista precisa
// (ids, severidade, resumo público + flag hasDetails). O detalhe completo
// (explanation/mechanism/management/monitoring/red_flags/source/summary_pro)
// é buscado sob demanda via getInteractionDetail quando o utilizador
// expande um cartão — corta ~1 MB de campos longos do payload inicial.
export const getPublishedInteractions = unstable_cache(
  async (lang = 'pt') => {
    const supabase = await createAnonClient()
    // hasDetails: quais pares têm QUALQUER campo de detalhe não vazio
    // (mesma semântica do antigo `inter.explanation || inter.summaryPro || …`).
    const [pairsRes, detailsRes] = await Promise.all([
      supabase
        .from('drug_interactions')
        .select('id, drug_a_id, drug_b_id, severity, summary_pt, summary_en')
        .eq('status', 'published')
        .eq('is_archived', false)
        .order('severity', { ascending: true }),
      supabase
        .from('drug_interactions')
        .select('id')
        .or(
          'explanation_pt.not.eq.,explanation_en.not.eq.,mechanism_pt.not.eq.,mechanism_en.not.eq.,' +
          'management_pt.not.eq.,management_en.not.eq.,monitoring_pt.not.eq.,monitoring_en.not.eq.,' +
          'red_flags_pt.not.eq.,red_flags_en.not.eq.,source_pt.not.eq.,source_en.not.eq.,' +
          'summary_pro_pt.not.eq.,summary_pro_en.not.eq.'
        )
        .eq('status', 'published')
        .eq('is_archived', false),
    ])
    if (pairsRes.error) return []
    const withDetails = new Set((detailsRes.data || []).map((d) => d.id))
    return (pairsRes.data || []).map((i) => ({
      id: i.id,
      drugAId: i.drug_a_id,
      drugBId: i.drug_b_id,
      severity: i.severity,
      summary: pickLang(i, 'summary', lang),
      hasDetails: withDetails.has(i.id),
    }))
  },
  ['api', 'interacoes', 'pairs'],
  { revalidate: 3600, tags: ['interacoes'] }
)

// Detalhe completo de UMA interação (P2 — sob demanda, ao expandir o cartão).
// Padrão documentado do Next: unstable_cache chamado DENTRO da action exportada
// (o export direto de `unstable_cache(...)` é rejeitado pelo compilador de
// server actions — "only export async functions").
const getInteractionDetailCached = unstable_cache(
  async (id, lang = 'pt') => {
    const supabase = await createAnonClient()
    const { data, error } = await supabase
      .from('drug_interactions')
      .select(
        'id, summary_pt, summary_en, summary_pro_pt, summary_pro_en, ' +
        'explanation_pt, explanation_en, mechanism_pt, mechanism_en, ' +
        'management_pt, management_en, monitoring_pt, monitoring_en, ' +
        'red_flags_pt, red_flags_en, source_pt, source_en, source_url'
      )
      .eq('id', id)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()
    if (error || !data) return null
    return {
      id: data.id,
      summary: pickLang(data, 'summary', lang),
      summaryPro: pickLang(data, 'summary_pro', lang),
      explanation: pickLang(data, 'explanation', lang),
      mechanism: pickLang(data, 'mechanism', lang),
      management: pickLang(data, 'management', lang),
      monitoring: pickLang(data, 'monitoring', lang),
      redFlags: pickLang(data, 'red_flags', lang),
      source: pickLang(data, 'source', lang),
      sourceUrl: data.source_url || '',
    }
  },
  ['api', 'interacoes', 'detail'],
  { revalidate: 3600, tags: ['interacoes'] }
)

export async function getInteractionDetail(id, lang = 'pt') {
  return getInteractionDetailCached(id, lang)
}

// ============================================================
//  Público — novas dimensões (Fluxo 2)
//  Fail-safe: se a migração 060 ainda não foi aplicada, a query
//  devolve erro e a função retorna [] (abas vazias, sem quebrar).
// ============================================================

// Medicamento ↔ alimento/bebida
export const getPublishedFoodInteractions = unstable_cache(
  async (lang = 'pt') => {
  const supabase = await createAnonClient()
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
  },
  ['api', 'interacoes', 'food'],
  { revalidate: 3600, tags: ['interacoes'] }
)

// Medicamento ↔ doença/condição
export const getPublishedDiseaseInteractions = unstable_cache(
  async (lang = 'pt') => {
  const supabase = await createAnonClient()
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
  },
  ['api', 'interacoes', 'disease'],
  { revalidate: 3600, tags: ['interacoes'] }
)

// Medicamento ↔ gestação/lactação (1:1 por fármaco)
export const getPublishedPregnancyInfo = unstable_cache(
  async (lang = 'pt') => {
  const supabase = await createAnonClient()
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
  },
  ['api', 'interacoes', 'pregnancy'],
  { revalidate: 3600, tags: ['interacoes'] }
)

// ============================================================
//  Admin — Fármacos
// ============================================================
export async function getAllDrugs() {
  const ctx = await requireAdmin()
  if (!ctx) return []
  const { data, error } = await ctx.supabase
    .from('drugs')
    // drug_interactions tem 2 FKs para drugs (drug_a_id e drug_b_id) — o hint
    // !drug_a_id desambígua o embedding, senão o PostgREST falha com
    // "more than one relationship found" e devolve [] (0 fármacos no admin).
    .select('*, drug_interactions!drug_a_id(count), drug_profiles(status, is_archived), drug_pharmacology(status, is_archived)')
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
  revalidateTag('interacoes')
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
  revalidateTag('interacoes')
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
  revalidateTag('interacoes')
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
  revalidateTag('interacoes')
  return { success: true }
}

export async function deleteDrug(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('drugs').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  revalidateTag('interacoes')
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
      'drugA:drugs!drug_a_id(name_pt, name_en), ' +
      'drugB:drugs!drug_b_id(name_pt, name_en)'
    )
    .order('severity', { ascending: true })
  if (error) return []
  return (data || []).map((i) => ({
    id: i.id,
    drugAId: i.drug_a_id,
    drugBId: i.drug_b_id,
    drugAName: i.drugA?.name_pt || '—',
    drugBName: i.drugB?.name_pt || '—',
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
  revalidateTag('interacoes')
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
  revalidateTag('interacoes')
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
  revalidateTag('interacoes')
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
  revalidateTag('interacoes')
  return { success: true }
}

export async function deleteDrugInteraction(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Apenas superadmin' }
  const { error } = await ctx.supabase.from('drug_interactions').delete().eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/interacoes')
  revalidateTag('interacoes')
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

// ============================================================
//  Zod schemas — dimensões
// ============================================================

const foodDimensionSchema = z.object({
  drug_id: z.string().uuid('Fármaco inválido'),
  entity_slug: z.string().min(1, 'Slug da entidade obrigatório'),
  entity_pt: z.string().min(1, 'Nome (PT) obrigatório'),
  entity_en: z.string().min(1, 'Name (EN) required'),
  severity: z.enum(['critical', 'moderate', 'minor', 'none']).default('moderate'),
  mechanism_pt: z.string().optional().default(''),
  mechanism_en: z.string().optional().default(''),
  advice_pt: z.string().optional().default(''),
  advice_en: z.string().optional().default(''),
  source_pt: z.string().optional().default(''),
  source_en: z.string().optional().default(''),
  sort_order: z.number().int().optional().default(0),
  status: z.enum(['draft', 'published']).default('draft'),
})

const diseaseDimensionSchema = z.object({
  drug_id: z.string().uuid('Fármaco inválido'),
  condition_slug: z.string().min(1, 'Slug da condição obrigatório'),
  condition_pt: z.string().min(1, 'Nome (PT) obrigatório'),
  condition_en: z.string().min(1, 'Name (EN) required'),
  interaction_type: z.enum(['contraindication', 'precaution']).default('precaution'),
  severity: z.enum(['critical', 'moderate', 'minor', 'none']).default('moderate'),
  reason_pt: z.string().optional().default(''),
  reason_en: z.string().optional().default(''),
  advice_pt: z.string().optional().default(''),
  advice_en: z.string().optional().default(''),
  source_pt: z.string().optional().default(''),
  source_en: z.string().optional().default(''),
  sort_order: z.number().int().optional().default(0),
  status: z.enum(['draft', 'published']).default('draft'),
})

const pregnancyDimensionSchema = z.object({
  drug_id: z.string().uuid('Fármaco inválido'),
  pregnancy_category: z.enum(['contraindicated', 'caution', 'compatible', 'no_data']).default('caution'),
  risk_pt: z.string().optional().default(''),
  risk_en: z.string().optional().default(''),
  trimester_pt: z.string().optional().default(''),
  trimester_en: z.string().optional().default(''),
  lactation_pt: z.string().optional().default(''),
  lactation_en: z.string().optional().default(''),
  contraception_pt: z.string().optional().default(''),
  contraception_en: z.string().optional().default(''),
  source_pt: z.string().optional().default(''),
  source_en: z.string().optional().default(''),
  status: z.enum(['draft', 'published']).default('draft'),
})

function getDimSchema(table) {
  if (table === 'drug_food_interactions') return foodDimensionSchema
  if (table === 'drug_disease_interactions') return diseaseDimensionSchema
  return pregnancyDimensionSchema
}

export async function createDrugDimension(table, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const schema = getDimSchema(table)
  const parsed = schema.safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from(table).insert(parsed.data)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/admin/interacoes/dimensoes')
  return { success: true }
}

export async function updateDrugDimension(table, id, data) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }
  const schema = getDimSchema(table)
  const parsed = schema.partial().safeParse(data)
  if (!parsed.success) return { success: false, error: parsed.error.issues[0]?.message || 'Dados inválidos' }
  const { error } = await ctx.supabase.from(table).update(parsed.data).eq('id', id)
  if (error) return { success: false, error: error.message }
  revalidatePath('/[lang]/admin/interacoes/dimensoes')
  return { success: true }
}
