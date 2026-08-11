'use server'

import { createClient } from '@/lib/supabase/server'
import { createAdminClient } from '@/lib/supabase/admin'
import { revalidatePath } from 'next/cache'
import { isValidHexColor } from '@/lib/security'
import { sanitizeHtml } from '@/lib/sanitize'
import { ensureUniqueEnSlug } from '@/lib/api/translations'
import { slugify } from '@/lib/utils/slugify'
import { getOpenAlexCitedBy } from '@/lib/api/openalex'

/**
 * Server Actions — Artigos Científicos.
 *
 * Padrão de `lib/actions/content.js`: requireAdmin em todas as mutações,
 * sanitização server-side (sanitizeHtml), audit_logs, revalidatePath.
 * RLS (142) restringe a escrita a admin; delete a superadmin.
 * A auto-tradução EN segue o padrão de `lib/actions/translation.js`
 * (autoTranslateEntity), sem tocar nas entidades article/event/live:
 * a mesma quota diária atómica + OpenRouter, mas com tabela própria
 * `scientific_article_translations`.
 */

// ============================================================
//  HELPERS
// ============================================================

// Auto-tradução EN (padrão lib/actions/translation.js)
const OPENROUTER_URL = 'https://openrouter.ai/api/v1/chat/completions'
const OPENROUTER_MODEL =
  process.env.OPENROUTER_MODEL || 'google/gemma-4-31b-it:free'
const TRANSLATION_DAILY_CHAR_LIMIT = parseInt(
  process.env.TRANSLATION_DAILY_CHAR_LIMIT || '1000000',
  10
)
const TRANSLATE_TIMEOUT_MS = 30000
const MAX_FIELD_CHARS = 50000
const MAX_TOTAL_CHARS = 200000
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

// HIGH-01: campos renderizados como HTML devem ser sanitizados antes de
// chegar à BD — abstract e content (markdown com potencial HTML).
const SCI_HTML_FIELDS = new Set(['abstract', 'content'])

const SCI_SYSTEM_PROMPT = `You are a technical translator specialised in scholarly pharmacology and pharmaceutical sciences (PT→EN). Your task is to translate the Portuguese fields of a scientific article into natural, professional English suitable for an academic audience.

Rules:
- Keep scientific terminology in English (e.g., "pharmacokinetics", "bioavailability", "drug interaction").
- Copy proper names (author names, journal names, DOIs) VERBATIM without translating.
- keywords: return an array of English keywords (strings).
- For empty or null values, return null.
- Respond ONLY with valid JSON, no markdown fences, no preamble.
- Use the exact field names provided in the user message.
- Preserve markdown formatting in the content field.`

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
/** ORCID no formato 0000-0000-0000-0000/000X (opcional; inválido → null) */
function sanitizeOrcid(orcid) {
  const v = String(orcid || '').trim().toUpperCase()
  if (!v) return null
  return /^\d{4}-\d{4}-\d{4}-\d{3}[\dX]$/.test(v) ? v : null
}

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
      orcid: sanitizeOrcid(a.orcid),
    }))
}

/**
 * Sincroniza o registo scientific_authors + junction scientific_article_authors
 * a partir do JSONB canónico `authors` do artigo (144/145). Mesmas regras da
 * migração 145:
 *   1. nome + instituição iguais (ambas conhecidas) → mesmo autor
 *   2. nome igual e um dos lados sem instituição → funde
 *   3. instituições conhecidas e diferentes → autor novo (slug único)
 * A junction é reconstruída (delete + insert) — idempotente.
 */
async function syncArticleAuthors(supabase, articleId, authors) {
  if (!Array.isArray(authors)) authors = []

  // Limpa ligações existentes (rebuild idempotente)
  await supabase.from('scientific_article_authors').delete().eq('article_id', articleId)
  if (authors.length === 0) return

  const links = []
  for (let i = 0; i < authors.length; i++) {
    const authorId = await upsertAuthor(supabase, authors[i])
    links.push({
      article_id: articleId,
      author_id: authorId,
      position: i + 1,
      corresponding: Boolean(authors[i].corresponding),
    })
  }

  const { error } = await supabase.from('scientific_article_authors').insert(links)
  if (error) throw error
}

/** Upsert de um autor no registo — devolve o id (novo ou existente). */
async function upsertAuthor(supabase, a) {
  const name = String(a.name || '').trim()
  const institution = String(a.institution || '').trim() || null
  const fields = {
    name,
    institution: institution || null,
    department: a.department || null,
    role: a.role || null,
    avatar: a.avatar || null,
    avatar_bg: a.avatarBg || '#0a844f',
    orcid: a.orcid || null,
  }

  // Regra 1: nome + instituição iguais
  if (institution) {
    const { data: exact } = await supabase
      .from('scientific_authors')
      .select('id')
      .eq('name', name)
      .eq('institution', institution)
      .maybeSingle()
    if (exact) {
      await supabase
        .from('scientific_authors')
        .update({ ...fields, updated_at: new Date().toISOString() })
        .eq('id', exact.id)
      return exact.id
    }
  }

  // Regra 2: nome igual e um dos lados sem instituição → funde (só se único)
  const { data: sameName } = await supabase
    .from('scientific_authors')
    .select('id, institution')
    .eq('name', name)
    .limit(2)
  if (sameName && sameName.length === 1 && (!sameName[0].institution || !institution)) {
    await supabase
      .from('scientific_authors')
      .update({ ...fields, updated_at: new Date().toISOString() })
      .eq('id', sameName[0].id)
    return sameName[0].id
  }

  // Regra 3: cria novo com slug único (desambiguado)
  const baseSlug = slugify(name) || 'autor'
  let slug = baseSlug
  let n = 2
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const { data: clash } = await supabase
      .from('scientific_authors')
      .select('id')
      .eq('slug', slug)
      .maybeSingle()
    if (!clash) break
    slug = `${baseSlug}-${n}`
    n += 1
  }

  const { data: created, error } = await supabase
    .from('scientific_authors')
    .insert({ ...fields, slug })
    .select('id')
    .single()
  if (error) throw error
  return created.id
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

// ---- Auto-tradução EN (helpers, padrão lib/actions/translation.js) ----

/**
 * Reserva atómica de quota diária (CRIT-01). Fail-closed: se o RPC falhar
 * ou devolver FALSE, o caller deve abortar — nunca excede o orçamento.
 */
async function checkAndReserveQuota(charCount) {
  const supabase = createAdminClient()
  const { data, error } = await supabase.rpc('check_and_increment_translation_quota', {
    p_chars: charCount,
    p_limit: TRANSLATION_DAILY_CHAR_LIMIT,
  })
  if (error) {
    console.error('[scientific] translation quota rpc failed:', error)
    return { allowed: false, error: 'QUOTA_CHECK_FAILED' }
  }
  return { allowed: data === true }
}

/** Chama OpenRouter para traduzir um objecto de campos PT → EN. */
async function callOpenRouter(sourceFields) {
  const apiKey = process.env.OPENROUTER_API_KEY
  if (!apiKey) {
    throw new Error('OPENROUTER_API_KEY not configured')
  }

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), TRANSLATE_TIMEOUT_MS)

  try {
    const response = await fetch(OPENROUTER_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://conhecafarmacia.com',
        'X-Title': 'Conheça Farmácia Scientific Translator',
      },
      body: JSON.stringify({
        model: OPENROUTER_MODEL,
        messages: [
          { role: 'system', content: SCI_SYSTEM_PROMPT },
          { role: 'user', content: JSON.stringify(sourceFields) },
        ],
        response_format: { type: 'json_object' },
        temperature: 0.2,
      }),
      signal: controller.signal,
    })

    if (!response.ok) {
      const errText = await response.text()
      throw new Error(`OpenRouter ${response.status}: ${errText.slice(0, 500)}`)
    }

    const result = await response.json()
    const content = result?.choices?.[0]?.message?.content
    if (!content) {
      throw new Error('OpenRouter returned empty content')
    }
    return JSON.parse(content)
  } finally {
    clearTimeout(timeout)
  }
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
    // Fonte original / licença (caixa 'Sobre este artigo')
    journal: clampStr(formData.journal, 300),
    volume: clampStr(formData.volume, 50),
    issue: clampStr(formData.issue, 50),
    pages: clampStr(formData.pages, 50),
    license: clampStr(formData.license, 100),
    license_url: clampStr(formData.license_url, 300),
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

/**
 * Contador de leituras — action pública (sem requireAdmin de propósito):
 * qualquer visitante pode incrementar a view de um artigo publicado via o
 * RPC `increment_scientific_view` (SECURITY DEFINER, só incrementa um
 * contador de artigos publicados — não expõe nem altera mais nada).
 * Best-effort: nunca lança erro (o contador não deve partir a página).
 */
export async function incrementScientificArticleView(articleId) {
  try {
    if (!articleId || typeof articleId !== 'string' || !UUID_REGEX.test(articleId)) return
    const supabase = await createClient()
    await supabase.rpc('increment_scientific_view', { p_article_id: articleId })
  } catch (err) {
    console.error('incrementScientificArticleView error:', err)
  }
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
    // Registo de autores (144/145) — não-fatal: o JSONB canónico já ficou gravado
    try {
      await syncArticleAuthors(supabase, data.id, articleData.authors)
    } catch (err) {
      console.error('syncArticleAuthors (create) error:', err)
    }
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
    // Registo de autores (144/145) — não-fatal: o JSONB canónico já ficou gravado
    try {
      await syncArticleAuthors(supabase, id, articleData.authors)
    } catch (err) {
      console.error('syncArticleAuthors (update) error:', err)
    }
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

/**
 * Auto-traduz um artigo científico PT → EN via IA (OpenRouter).
 *
 * Inspirada em `autoTranslateEntity` (lib/actions/translation.js), mas sem
 * tocar nas entidades article/event/live: lê a base de `scientific_articles`,
 * traduz com a MESMA quota diária atómica (check_and_increment_translation_quota)
 * e faz upsert em `scientific_article_translations`.
 *
 * Referências NÃO são traduzidas — são citações (nomes, DOIs, revistas),
 * copiadas verbatim da base PT. Keywords vão como array para o modelo.
 *
 * @param {string} articleId - UUID do artigo científico (base PT)
 * @returns {Promise<{success: boolean, translation?: object, error?: string, rateLimited?: boolean}>}
 */
export async function autoTranslateScientificArticle(articleId) {
  // SEC-UMN-01: auth ANTES de qualquer leitura/escrita/IA.
  const ctx = await requireAdmin()
  if (!ctx) {
    return { success: false, error: 'Sessão expirada. Faça login novamente.' }
  }

  if (typeof articleId !== 'string' || !UUID_REGEX.test(articleId)) {
    return { success: false, error: 'ID do artigo inválido.' }
  }

  // 1. Ler registo PT base. Usamos o client admin (service role) porque a RLS
  //    anónima só expõe artigos published — um rascunho tem de ser legível
  //    para ser traduzido antes de publicar.
  const admin = createAdminClient()
  const { data: article, error: errArticle } = await admin
    .from('scientific_articles')
    .select('id, slug, title, abstract, keywords, content, references_arr')
    .eq('id', articleId)
    .single()
  if (errArticle || !article) {
    return { success: false, error: `Artigo científico não encontrado: ${errArticle?.message || 'no row'}` }
  }

  // 2. Reserva atómica de quota (fail-closed — nunca excede o orçamento).
  const estimatedChars = JSON.stringify(article).length
  const rate = await checkAndReserveQuota(estimatedChars)
  if (!rate.allowed) {
    return {
      success: false,
      rateLimited: true,
      error: 'Limite diário de tradução atingido. Tente novamente amanhã.',
    }
  }

  // 3. Preparar input para a IA — referências ficam fora (verbatim).
  const sourceObj = {
    title: article.title ?? null,
    abstract: article.abstract ?? null,
    keywords: Array.isArray(article.keywords) ? article.keywords : [],
    content: article.content ?? null,
  }
  let totalChars = 0
  for (const [f, value] of Object.entries(sourceObj)) {
    const str = Array.isArray(value) ? value.join(', ') : value
    if (typeof str === 'string' && str.length > MAX_FIELD_CHARS) {
      return {
        success: false,
        error: `Campo "${f}" excede o tamanho máximo (${MAX_FIELD_CHARS} caracteres). Reduz o conteúdo antes de traduzir.`,
      }
    }
    if (typeof str === 'string') totalChars += str.length
  }
  if (totalChars > MAX_TOTAL_CHARS) {
    return {
      success: false,
      error: `Conteúdo total (${totalChars} caracteres) excede o limite de ${MAX_TOTAL_CHARS}.`,
    }
  }

  // 4. Chamar IA
  let translated
  try {
    translated = await callOpenRouter(sourceObj)
  } catch (err) {
    return { success: false, error: `Falha na tradução: ${err.message}` }
  }
  if (!translated || typeof translated !== 'object') {
    return { success: false, error: 'Resposta da IA inválida (JSON esperado).' }
  }

  // 5. Gerar slug EN único a partir do título traduzido
  const baseSlug = slugify(translated.slug || translated.title || article.title || article.slug || 'untitled')
  const existsFn = async (candidate) => {
    const { data, error } = await admin
      .from('scientific_article_translations')
      .select('slug')
      .eq('slug', candidate)
      .eq('lang', 'en')
      .maybeSingle()
    if (error) {
      console.error('[scientific] existsFn:', error)
      return false // fail open
    }
    return !!data
  }
  const enSlug = await ensureUniqueEnSlug(baseSlug, existsFn)

  // 6. Construir payload (HIGH-01: sanitizar campos HTML devolvidos pelo modelo)
  const { slug: _ignored, ...translatedFields } = translated
  for (const [key, value] of Object.entries(translatedFields)) {
    if (SCI_HTML_FIELDS.has(key) && typeof value === 'string') {
      translatedFields[key] = sanitizeHtml(value)
    }
  }
  const payload = {
    article_id: articleId,
    lang: 'en',
    slug: enSlug,
    title: clampStr(translatedFields.title, 300) || clampStr(article.title, 300),
    abstract: translatedFields.abstract ? sanitizeHtml(String(translatedFields.abstract)) : null,
    keywords: sanitizeKeywords(translatedFields.keywords),
    content: translatedFields.content ? sanitizeHtml(String(translatedFields.content)) : null,
    references_arr: article.references_arr || [],
    updated_at: new Date().toISOString(),
  }

  // 7. Upsert (article_id, lang)
  const { data: upserted, error: errUpsert } = await admin
    .from('scientific_article_translations')
    .upsert(payload, { onConflict: 'article_id,lang', ignoreDuplicates: false })
    .select('id, article_id, lang, slug, title, abstract, keywords, content, references_arr, updated_at')
    .single()
  if (errUpsert) {
    return { success: false, error: `Erro ao guardar tradução: ${errUpsert.message}` }
  }

  // 8. Log de auditoria (padrão do ficheiro — translation_logs tem CHECK
  //    restrito a article/event/live, por isso usamos audit_logs).
  await logAudit(ctx.supabase, ctx.user, 'AUTO_TRANSLATE', 'scientific_article_translations', articleId, {
    lang: 'en',
    title: payload.title,
  })

  revalidateScientific()
  return { success: true, translation: upserted }
}

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

/**
 * getCitedByCount — contagem 'Citado por' via OpenAlex (por DOI).
 * Pública (leitura); valida o DOI antes de tocar na API externa.
 *
 * @param {string} doi
 * @returns {Promise<{count: number, workId: string|null}|null>}
 */
export async function getCitedByCount(doi) {
  if (typeof doi !== 'string' || !doi.trim()) return null
  try {
    return await getOpenAlexCitedBy(doi)
  } catch {
    return null
  }
}
