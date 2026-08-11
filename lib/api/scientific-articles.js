import { createClient } from '@/lib/supabase/server'

/**
 * API layer — Artigos Científicos (tabela própria `scientific_articles`).
 *
 * Espelha o padrão de `lib/api/articles.js`: SELECT com colunas explícitas,
 * merge de traduções (`scientific_article_translations`), e comportamento
 * por língua idêntico ao dos artigos:
 *   - `pt` devolve sempre a base (o conteúdo canónico vive na base PT);
 *   - `en` só devolve artigos que têm tradução (sem fallback para PT na
 *     listagem); no detalhe, o fallback PT aplica-se quando o slug não
 *     resolve numa tradução (padrão `getArticleBySlug`).
 *
 * Categorias vêm da BD (`scientific_categories` — geríveis no admin),
 * não de constantes.
 */

const SCIENTIFIC_ARTICLE_COLUMNS =
  'id, slug, title, abstract, keywords, category_id, doi, authors, content, references_arr, read_time, status, featured, published_at, created_at, is_archived, scientific_categories(slug, name_pt, name_en, color)'

const SCIENTIFIC_TRANSLATION_COLUMNS =
  'id, article_id, lang, slug, title, abstract, keywords, content, references_arr, updated_at'

function pickCategory(cat, lang = 'pt') {
  if (!cat) return null
  const name = lang === 'en' && cat.name_en ? cat.name_en : cat.name_pt
  return { slug: cat.slug, name, color: cat.color }
}

/**
 * Normalize a scientific article row (snake_case, flat + embedded category)
 * to the frontend shape (camelCase, nested category, arrays).
 *
 * @param {object} row
 * @param {'pt'|'en'} lang
 * @returns {object}
 */
export function normalizeScientificArticle(row, lang = 'pt') {
  return {
    id: row.id,
    slug: row.slug,
    title: row.title,
    abstract: row.abstract,
    keywords: row.keywords || [],
    category: pickCategory(row.scientific_categories, lang),
    categoryId: row.category_id,
    doi: row.doi || '',
    authors: Array.isArray(row.authors) ? row.authors : [],
    content: row.content,
    references: row.references_arr || [],
    readTime: row.read_time,
    status: row.status,
    featured: row.featured || false,
    isArchived: row.is_archived || false,
    publishedAt: row.published_at,
    date: row.published_at ? row.published_at.split('T')[0] : null,
  }
}

/**
 * Merge a base PT row with an optional translation row (per-language fields).
 * Non-translatable fields (doi, authors, category, dates) stay on the base.
 *
 * @param {object} base - already normalized
 * @param {object|null} translation
 * @param {'pt'|'en'} lang
 * @returns {object}
 */
export function mergeScientificTranslation(base, translation, lang) {
  if (!translation) {
    return { ...base, lang, has_translation: false }
  }
  const merged = { ...base }
  for (const field of ['title', 'abstract', 'keywords', 'content', 'references']) {
    const col = field === 'references' ? 'references_arr' : field
    const translated = translation[col]
    if (translated !== null && translated !== undefined) merged[field] = translated
  }
  merged.lang = lang
  merged.has_translation = true
  return merged
}

/**
 * All scientific categories, ordered by sort_order, with the name in `lang`.
 * Used by the public listing (filters) and the admin form (dropdown).
 *
 * @param {'pt'|'en'} lang
 * @returns {Promise<Array<{id: string, slug: string, name: string, color: string, sortOrder: number}>>}
 */
export async function getScientificCategories(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('scientific_categories')
    .select('id, slug, name_pt, name_en, color, sort_order')
    .order('sort_order', { ascending: true })

  if (error) throw error
  return (data || []).map((c) => ({
    id: c.id,
    slug: c.slug,
    name: lang === 'en' && c.name_en ? c.name_en : c.name_pt,
    color: c.color,
    sortOrder: c.sort_order,
  }))
}

/**
 * Published, non-archived scientific articles, merged for `lang`.
 * On EN, only articles with a translation are returned (no PT fallback),
 * mirroring `getArticles()`.
 *
 * @param {'pt'|'en'} lang
 * @returns {Promise<Array<object>>}
 */
export async function getScientificArticles(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('scientific_articles')
    .select(SCIENTIFIC_ARTICLE_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('published_at', { ascending: false })

  if (error) throw error
  const bases = (data || []).map((row) => normalizeScientificArticle(row, lang))

  if (lang === 'pt' || bases.length === 0) return bases

  const ids = bases.map((a) => a.id)
  const { data: translations, error: trErr } = await supabase
    .from('scientific_article_translations')
    .select(SCIENTIFIC_TRANSLATION_COLUMNS)
    .eq('lang', lang)
    .in('article_id', ids)

  if (trErr) {
    console.error('getScientificArticles translations fetch error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.article_id, t]))
  return bases
    .map((base) => mergeScientificTranslation(base, byId.get(base.id) || null, lang))
    .filter((merged) => (lang === 'en' ? merged.has_translation === true : true))
}

/**
 * Single published scientific article by slug, in `lang`.
 *
 * Resolution (mirrors `getArticleBySlug`):
 *   1. If `lang !== 'pt'`, look up `scientific_article_translations` by
 *      (slug, lang); if found, load the base by article_id and merge.
 *   2. Otherwise look up the base `scientific_articles` row by slug
 *      (PT fallback — the canonical row is PT).
 *
 * Attaches `langSlugs: { pt, en }` so the local PT/EN toggle can navigate
 * between the two slugs (en is null when no translation exists).
 *
 * @param {string} slug
 * @param {'pt'|'en'} lang
 * @returns {Promise<object|null>}
 */
export async function getScientificArticleBySlug(slug, lang = 'pt') {
  const supabase = await createClient()

  let translation = null
  if (lang !== 'pt') {
    const { data, error } = await supabase
      .from('scientific_article_translations')
      .select(SCIENTIFIC_TRANSLATION_COLUMNS)
      .eq('slug', slug)
      .eq('lang', lang)
      .maybeSingle()
    if (!error && data) translation = data
  }

  let base = null
  if (translation) {
    const { data, error } = await supabase
      .from('scientific_articles')
      .select(SCIENTIFIC_ARTICLE_COLUMNS)
      .eq('id', translation.article_id)
      .eq('status', 'published')
      .eq('is_archived', false)
      .single()
    if (!error && data) base = data
  } else {
    const { data, error } = await supabase
      .from('scientific_articles')
      .select(SCIENTIFIC_ARTICLE_COLUMNS)
      .eq('slug', slug)
      .eq('status', 'published')
      .eq('is_archived', false)
      .maybeSingle()
    if (!error && data) base = data
  }

  if (!base) return null

  const normalized = mergeScientificTranslation(
    normalizeScientificArticle(base, lang),
    translation,
    lang
  )

  // Slugs para o toggle PT/EN local (o EN só existe se houver tradução).
  const langSlugs = { pt: base.slug, en: null }
  if (translation) {
    langSlugs.en = translation.slug
  } else {
    const { data: enTr } = await supabase
      .from('scientific_article_translations')
      .select('slug')
      .eq('article_id', base.id)
      .eq('lang', 'en')
      .maybeSingle()
    if (enTr) langSlugs.en = enTr.slug
  }
  normalized.langSlugs = langSlugs

  return normalized
}

/**
 * All scientific articles regardless of status/archive — admin only
 * (RLS restringe a admin; o caller deve garantir a sessão).
 *
 * @returns {Promise<Array<object>>}
 */
export async function getAllScientificArticlesAdmin() {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('scientific_articles')
    .select(SCIENTIFIC_ARTICLE_COLUMNS)
    .order('created_at', { ascending: false })

  if (error) throw error
  return (data || []).map((row) => normalizeScientificArticle(row))
}
