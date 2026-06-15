import { createClient } from '@/lib/supabase/server'
import { normalizeArticle } from '@/lib/api/normalize'
import { findTranslationBySlug, mergeEntity } from '@/lib/api/translations'

const ARTICLE_COLUMNS = 'id, slug, title, excerpt, image_url, category, category_label, author_name, author_role, author_bio, author_avatar, author_avatar_bg, published_date, read_time, status, featured, references_arr, meta_description, content'

/**
 * Fetch all published articles, merged with translations for `lang`.
 * Always returns the base PT row even when no translation exists (so the
 * PT site keeps working unchanged). When `lang === 'pt'`, behaviour is
 * identical to the pre-i18n implementation.
 *
 * @param {string} lang - 'pt' | 'en'
 * @returns {Promise<Array<object>>} merged article records
 */
export async function getArticles(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('articles')
    .select(ARTICLE_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('published_date', { ascending: false })

  if (error) throw error
  const bases = (data || []).map(normalizeArticle)

  if (lang === 'pt' || bases.length === 0) {
    return bases
  }

  // Bulk-fetch translations for the lang
  const ids = bases.map((a) => a.id)
  const { data: translations, error: trErr } = await supabase
    .from('article_translations')
    .select('*')
    .eq('lang', lang)
    .in('article_id', ids)

  if (trErr) {
    console.error('getArticles translations fetch error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.article_id, t]))
  return bases
    .map((base) => mergeEntity(base, byId.get(base.id) || null, lang))
    .filter((merged) => {
      // On EN, only show articles that have a translation. If no EN version
      // exists, the section stays empty — do NOT fall back to PT articles.
      if (lang === 'en') return merged.has_translation === true
      return true
    })
}

/**
 * Fetch a single article by slug, in the requested language.
 *
 * Resolution order:
 *  1. If `lang === 'en'`, look up `article_translations` by (slug, lang);
 *     if found, load the base article by `article_id` and merge.
 *  2. Otherwise, look up the base `articles` row by `slug` directly.
 *
 * @param {string} slug
 * @param {string} lang - 'pt' | 'en'
 * @returns {Promise<object|null>}
 */
export async function getArticleBySlug(slug, lang = 'pt') {
  const supabase = await createClient()

  if (lang !== 'pt') {
    const translation = await findTranslationBySlug(supabase, 'article', slug, lang)
    if (translation) {
      const { data, error } = await supabase
        .from('articles')
        .select(ARTICLE_COLUMNS)
        .eq('id', translation.article_id)
        .eq('status', 'published')
        .eq('is_archived', false)
        .single()
      if (!error && data) {
        return mergeEntity(normalizeArticle(data), translation, lang)
      }
    }
    // Translation not found → fall through to base lookup as PT fallback
  }

  const { data, error } = await supabase
    .from('articles')
    .select(ARTICLE_COLUMNS)
    .eq('slug', slug)
    .eq('status', 'published')
    .eq('is_archived', false)
    .single()

  if (error) return null
  return data ? normalizeArticle(data) : null
}

export async function getFeaturedArticles(limit = 3) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('articles')
    .select(ARTICLE_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .eq('featured', true)
    .order('published_date', { ascending: false })
    .limit(limit)

  if (error) throw error
  return (data || []).map(normalizeArticle)
}

export async function getPublishedArticlesCount() {
  const supabase = await createClient()
  const { count, error } = await supabase
    .from('articles')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'published')
    .eq('is_archived', false)

  if (error) return 0
  return count || 0
}
