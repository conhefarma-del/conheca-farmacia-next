'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { isValidHexColor } from '@/lib/security'
import { sanitizeHtml } from '@/lib/sanitize'

/**
 * Server Actions — Artigos Científicos.
 *
 * Padrão de `lib/actions/content.js`: requireAdmin em todas as mutações,
 * sanitização server-side (sanitizeHtml), audit_logs, revalidatePath.
 * RLS (142) restringe a escrita a admin; delete a superadmin.
 */

// ============================================================
//  HELPERS
// ============================================================

async function requireAdmin() {
  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) return null

  const { data: adminUser, error: adminError } = await supabase
    .from('admin_users')
    .select('user_id, role')
    .eq('user_id', user.id)
    .single()

  if (adminError || !adminUser) return null
  return { supabase, user, role: adminUser.role || 'admin' }
}

async function requireSuperAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return null
  if (ctx.role !== 'superadmin') return null
  return ctx
}

async function logAudit(supabase, user, action, tableName, recordId, newValues = null) {
  try {
    await supabase.from('audit_logs').insert({
      action,
      table_name: tableName,
      record_id: String(recordId),
      user_email: user.email,
      new_values: newValues ? JSON.stringify(newValues) : null,
      created_at: new Date().toISOString(),
    })
  } catch {
    // SEC-AUD-02: não bloquear operação por falha de log
  }
}

function clampStr(v, max) {
  if (v === null || v === undefined) return ''
  return String(v).trim().slice(0, max)
}

/** keywords: string "a, b" ou array → array ≤10 de strings ≤50 (sem HTML). */
function sanitizeKeywords(input) {
  let arr = Array.isArray(input) ? input : String(input || '').split(',')
  return arr
    .map((k) => String(k).trim().replace(/<[^>]*>/g, '').slice(0, 50))
    .filter(Boolean)
    .slice(0, 10)
}

/** authors: array ≤12 de objetos {name, institution, department, role, avatar, avatarBg, corresponding}. */
function sanitizeAuthors(input) {
  if (!Array.isArray(input)) return []
  return input
    .filter((a) => a && typeof a === 'object' && (a.name || a.institution))
    .slice(0, 12)
    .map((a) => ({
      name: clampStr(a.name, 200),
      institution: clampStr(a.institution, 200),
      department: clampStr(a.department, 200),
      role: clampStr(a.role, 200),
      avatar: clampStr(a.avatar, 10),
      avatarBg: isValidHexColor(a.avatarBg) ? a.avatarBg : '#0a844f',
      corresponding: Boolean(a.corresponding),
    }))
}

/** doi opcional no formato 10.xxxx/... */
function validateDoi(doi) {
  if (!doi) return { ok: true, value: null }
  const v = String(doi).trim()
  if (v.length > 255) return { ok: false }
  if (!/^10\.\d{4,9}\/[-._;()/:A-Z0-9]+$/i.test(v)) return { ok: false }
  return { ok: true, value: v }
}

function sanitizeReferences(input) {
  let arr = Array.isArray(input) ? input : []
  return arr
    .map((r) => String(r).trim().replace(/<[^>]*>/g, '').slice(0, 1000))
    .filter(Boolean)
    .slice(0, 100)
}

function revalidateScientific() {
  revalidatePath(`/[lang]/admin/cientificos`, 'page')
  revalidatePath(`/[lang]/admin/cientificos/categorias`, 'page')
  revalidatePath(`/[lang]/cientificos`, 'page')
  revalidatePath(`/[lang]/cientificos/[slug]`, 'page')
}

// ============================================================
//  ARTIGOS CIENTÍFICOS — CRUD
// ============================================================

function buildArticleData(formData) {
  const title = clampStr(formData.title, 300)
  const slug = clampStr(formData.slug, 200)
  const doiCheck = validateDoi(formData.doi)

  const data = {
    slug,
    title,
    // SEC-UMN-06: sanitização server-side (padrão do content.js)
    abstract: formData.abstract ? sanitizeHtml(String(formData.abstract)) : null,
    keywords: sanitizeKeywords(formData.keywords),
    category_id: formData.category_id || null,
    doi: doiCheck.ok ? doiCheck.value : null,
    authors: sanitizeAuthors(formData.authors),
    content: formData.content ? sanitizeHtml(String(formData.content)) : null,
    references_arr: sanitizeReferences(formData.references),
    read_time: formData.read_time ? Math.min(Math.max(parseInt(formData.read_time, 10) || 1, 1), 600) : null,
    status: formData.status === 'published' ? 'published' : 'draft',
    featured: Boolean(formData.featured),
    published_at: formData.published_at || null,
  }

  // Publicar agora se não houver data definida
  if (data.status === 'published' && !data.published_at) {
    data.published_at = new Date().toISOString()
  }
  return { data, doiError: !doiCheck.ok }
}

export async function createScientificArticle(formData) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx
    if (!formData.title || !formData.slug) {
      return { success: false, error: 'Título e slug são obrigatórios.' }
    }

    const { data: articleData, doiError } = buildArticleData(formData)
    if (doiError) return { success: false, error: 'DOI inválido. Use o formato 10.xxxx/...' }

    const { data, error } = await supabase
      .from('scientific_articles')
      .insert(articleData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar artigo científico: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'scientific_articles', data.id, { title: articleData.title })
    revalidateScientific()
    return { success: true, id: data.id }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function updateScientificArticle(id, formData) {
  try {
    if (!id) return { success: false, error: 'ID do artigo é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx
    if (!formData.title || !formData.slug) {
      return { success: false, error: 'Título e slug são obrigatórios.' }
    }

    const { data: articleData, doiError } = buildArticleData(formData)
    if (doiError) return { success: false, error: 'DOI inválido. Use o formato 10.xxxx/...' }

    const { error } = await supabase
      .from('scientific_articles')
      .update(articleData)
      .eq('id', id)

    if (error) return { success: false, error: `Erro ao atualizar artigo científico: ${error.message}` }

    await logAudit(supabase, user, 'UPDATE', 'scientific_articles', id, { title: articleData.title })
    revalidateScientific()
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function toggleScientificArticleStatus(id, currentStatus) {
  try {
    if (!id || !currentStatus) {
      return { success: false, error: 'ID e status são obrigatórios.' }
    }

    const newStatus = currentStatus === 'published' ? 'draft' : 'published'

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const update = { status: newStatus }
    if (newStatus === 'published') {
      const { data: existing } = await supabase
        .from('scientific_articles')
        .select('published_at')
        .eq('id', id)
        .single()
      if (!existing?.published_at) update.published_at = new Date().toISOString()
    }

    const { error } = await supabase.from('scientific_articles').update(update).eq('id', id)
    if (error) return { success: false, error: 'Erro ao alterar status.' }

    await logAudit(
      supabase,
      user,
      newStatus === 'published' ? 'PUBLISH' : 'UNPUBLISH',
      'scientific_articles',
      id,
      { status: newStatus }
    )

    revalidateScientific()
    return { success: true, newStatus }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function archiveScientificArticle(id) {
  try {
    if (!id) return { success: false, error: 'ID do artigo é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const { data: article } = await supabase
      .from('scientific_articles')
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!article) return { success: false, error: 'Artigo científico não encontrado.' }
    if (article.is_archived) return { success: true } // idempotente

    const { error } = await supabase
      .from('scientific_articles')
      .update({ is_archived: true })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao arquivar artigo.' }

    await logAudit(supabase, user, 'ARCHIVE', 'scientific_articles', id, { title: article.title })
    revalidateScientific()
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function restoreScientificArticle(id) {
  try {
    if (!id) return { success: false, error: 'ID do artigo é obrigatório.' }

    const ctx = await requireSuperAdmin()
    if (!ctx) return { success: false, error: 'Operação restrita a superadmin.' }

    const { supabase, user } = ctx

    const { data: article } = await supabase
      .from('scientific_articles')
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!article) return { success: false, error: 'Artigo científico não encontrado.' }
    if (!article.is_archived) return { success: true }

    const { error } = await supabase
      .from('scientific_articles')
      .update({ is_archived: false })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao restaurar artigo.' }

    await logAudit(supabase, user, 'RESTORE', 'scientific_articles', id, { title: article.title })
    revalidateScientific()
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function deleteScientificArticle(id) {
  try {
    if (!id) return { success: false, error: 'ID do artigo é obrigatório.' }

    const ctx = await requireSuperAdmin()
    if (!ctx) return { success: false, error: 'Operação restrita a superadmin.' }

    const { supabase, user } = ctx

    const { data: article } = await supabase
      .from('scientific_articles')
      .select('title')
      .eq('id', id)
      .single()

    // ON DELETE CASCADE remove as traduções associadas
    const { error } = await supabase.from('scientific_articles').delete().eq('id', id)
    if (error) return { success: false, error: 'Erro ao eliminar artigo.' }

    await logAudit(supabase, user, 'DELETE', 'scientific_articles', id, { title: article?.title })
    revalidateScientific()
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  CATEGORIAS — CRUD
// ============================================================

export async function createScientificCategory(formData) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const namePt = clampStr(formData.name_pt, 120)
    const slug = clampStr(formData.slug, 120).toLowerCase().replace(/[^a-z0-9-]/g, '-').replace(/^-+|-+$/g, '')
    if (!namePt || !slug) {
      return { success: false, error: 'Nome (PT) e slug são obrigatórios.' }
    }
    if (!isValidHexColor(formData.color)) {
      return { success: false, error: 'Cor inválida. Use formato hex (#RRGGBB).' }
    }

    const { data, error } = await supabase
      .from('scientific_categories')
      .insert({
        slug,
        name_pt: namePt,
        name_en: clampStr(formData.name_en, 120) || null,
        color: formData.color,
        sort_order: parseInt(formData.sort_order, 10) || 0,
      })
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar categoria: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'scientific_categories', data.id, { name_pt: namePt })
    revalidateScientific()
    return { success: true, id: data.id }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function updateScientificCategory(id, formData) {
  try {
    if (!id) return { success: false, error: 'ID da categoria é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const namePt = clampStr(formData.name_pt, 120)
    if (!namePt) return { success: false, error: 'Nome (PT) é obrigatório.' }
    if (!isValidHexColor(formData.color)) {
      return { success: false, error: 'Cor inválida. Use formato hex (#RRGGBB).' }
    }

    const { error } = await supabase
      .from('scientific_categories')
      .update({
        name_pt: namePt,
        name_en: clampStr(formData.name_en, 120) || null,
        color: formData.color,
        sort_order: parseInt(formData.sort_order, 10) || 0,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)

    if (error) return { success: false, error: `Erro ao atualizar categoria: ${error.message}` }

    await logAudit(supabase, user, 'UPDATE', 'scientific_categories', id, { name_pt: namePt })
    revalidateScientific()
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function deleteScientificCategory(id) {
  try {
    if (!id) return { success: false, error: 'ID da categoria é obrigatório.' }

    const ctx = await requireSuperAdmin()
    if (!ctx) return { success: false, error: 'Operação restrita a superadmin.' }

    const { supabase, user } = ctx

    // Não permitir eliminar categorias com artigos associados
    const { count } = await supabase
      .from('scientific_articles')
      .select('id', { count: 'exact', head: true })
      .eq('category_id', id)
      .eq('is_archived', false)
    if (count > 0) {
      return { success: false, error: `Categoria em uso por ${count} artigo(s). Reatribua ou arquive os artigos primeiro.` }
    }

    const { data: cat } = await supabase
      .from('scientific_categories')
      .select('name_pt')
      .eq('id', id)
      .single()

    const { error } = await supabase.from('scientific_categories').delete().eq('id', id)
    if (error) return { success: false, error: `Erro ao eliminar categoria: ${error.message}` }

    await logAudit(supabase, user, 'DELETE', 'scientific_categories', id, { name_pt: cat?.name_pt })
    revalidateScientific()
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  TRADUÇÃO EN
// ============================================================

export async function saveScientificTranslation(articleId, fields) {
  try {
    if (!articleId) return { success: false, error: 'ID do artigo é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const title = clampStr(fields.title, 300)
    const slug = clampStr(fields.slug, 200)
    if (!title || !slug) {
      return { success: false, error: 'Título e slug (EN) são obrigatórios.' }
    }

    // Evitar conflito de slug EN entre artigos diferentes
    const { data: clash, error: clashErr } = await supabase
      .from('scientific_article_translations')
      .select('article_id')
      .eq('slug', slug)
      .eq('lang', 'en')
      .neq('article_id', articleId)
      .maybeSingle()
    if (!clashErr && clash) {
      return { success: false, error: `O slug EN "${slug}" já está usado por outro artigo.` }
    }

    const payload = {
      article_id: articleId,
      lang: 'en',
      slug,
      title,
      abstract: fields.abstract ? sanitizeHtml(String(fields.abstract)) : null,
      keywords: sanitizeKeywords(fields.keywords),
      content: fields.content ? sanitizeHtml(String(fields.content)) : null,
      references_arr: sanitizeReferences(fields.references),
      updated_at: new Date().toISOString(),
    }

    // Upsert por (article_id, lang)
    const { error } = await supabase
      .from('scientific_article_translations')
      .upsert(payload, { onConflict: 'article_id,lang' })

    if (error) return { success: false, error: `Erro ao guardar tradução: ${error.message}` }

    await logAudit(supabase, user, 'UPSERT', 'scientific_article_translations', articleId, { lang: 'en', title })
    revalidateScientific()
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}
