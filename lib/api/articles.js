import { unstable_cache } from 'next/cache'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { normalizeArticle } from '@/lib/api/normalize'
import { findTranslationBySlug, mergeEntity } from '@/lib/api/translations'

const ARTICLE_COLUMNS = 'id, slug, title, excerpt, image_url, category, category_label, author_name, author_role, author_bio, author_avatar, author_avatar_bg, published_date, read_time, status, featured_langs, references_arr, meta_description, content'

/**
 * Fetch all published articles, merged with translations for `lang`.
 * Always returns the base PT row even when no translation exists (so the
 * PT site keeps working unchanged). When `lang === 'pt'`, behaviour is
 * identical to the pre-i18n implementation.
 *
 * @param {string} lang - 'pt' | 'en'
 * @returns {Promise<Array<object>>} merged article records
 */
export const getArticles = unstable_cache(
  async (lang = 'pt') => {
  const supabase = await createAnonClient()
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
  },
  ['api', 'articles', 'list'],
  { revalidate: 3600, tags: ['articles'] }
)

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
export const getArticleBySlug = unstable_cache(
  async (slug, lang = 'pt') => {
  const supabase = await createAnonClient()

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
  },
  ['api', 'articles', 'by-slug'],
  { revalidate: 3600, tags: ['articles'] }
)

export const getFeaturedArticles = unstable_cache(
  async (limit = 3, lang = 'pt') => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase
    .from('articles')
    .select(ARTICLE_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .contains('featured_langs', [lang])
    .order('published_date', { ascending: false })
    .limit(limit)

  if (error) throw error
  const bases = (data || []).map(normalizeArticle)

  if (lang === 'pt' || bases.length === 0) {
    return bases
  }

  // EN: merge with translation table so the EN homepage renders
  // English title/excerpt. Mirrors the pattern in `getArticles()`.
  const ids = bases.map((a) => a.id)
  const { data: translations, error: trErr } = await supabase
    .from('article_translations')
    .select('*')
    .eq('lang', lang)
    .in('article_id', ids)

  if (trErr) {
    console.error('getFeaturedArticles translations fetch error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.article_id, t]))
  return bases
    .map((base) => mergeEntity(base, byId.get(base.id) || null, lang))
    .filter((merged) => {
      // On EN, hide featured items without a translation. The homepage
      // section is hidden entirely when the result is empty (see
      // FeaturedArticles.jsx:3) — no PT fallback. This matches the
      // locked-in behaviour for `getArticles()`.
      if (lang === 'en') return merged.has_translation === true
      return true
    })
  },
  ['api', 'articles', 'featured'],
  { revalidate: 3600, tags: ['articles'] }
)

export const getPublishedArticlesCount = unstable_cache(
  async () => {
  const supabase = await createAnonClient()
  const { count, error } = await supabase
    .from('articles')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'published')
    .eq('is_archived', false)

  if (error) return 0
  return count || 0
  },
  ['api', 'articles', 'count'],
  { revalidate: 3600, tags: ['articles'] }
)
