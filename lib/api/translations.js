import { createClient } from '@/lib/supabase/server'
import { slugify } from '@/lib/utils/slugify'

/**
 * Translation merge helpers for i18n content (articles, events, lives).
 *
 * Pattern:
 *   - The base tables (articles, events, lives) hold PT content.
 *   - Translations live in (article|event|live)_translations keyed by
 *     (entity_id, lang).
 *   - `mergeEntity(base, translation, lang)` returns a single object the
 *     UI can consume: when `translation` is present, translated fields
 *     win; otherwise we fall back to base.
 *   - `findTranslationBySlug(supabase, table, slug, lang)` is a tiny
 *     helper used by public pages to fetch the EN row by EN slug.
 *   - `ensureUniqueSlug(supabase, table, baseSlug, lang)` is used after
 *     auto-translating a slug to disambiguate collisions (-2, -3…).
 */

const TRANSLATION_TABLES = {
  article: 'article_translations',
  event:   'event_translations',
  live:    'live_translations',
}

/** Returns a list of fields that come from the translation row (per entity). */
export const TRANSLATABLE_FIELDS = {
  article: ['title', 'excerpt', 'content', 'category', 'category_label', 'author_role', 'author_bio', 'meta_description'],
  event:   ['title', 'description', 'location', 'host_name', 'host_role', 'host_bio', 'meta_description'],
  live:    ['title', 'description', 'host_name', 'host_role', 'topic', 'meta_description'],
}

/**
 * Merge base entity (PT row) with an optional translation row.
 * Translated fields win when present; base values stay for everything else.
 *
 * @param {object} base         - PT row from articles/events/lives
 * @param {object|null} translation - Row from the matching translations table
 * @param {string} lang         - 'pt' | 'en' — what the caller asked for
 * @returns {object} unified record (translationStatus included)
 */
export function mergeEntity(base, translation, lang) {
  if (!base) return null
  const merged = { ...base }

  if (translation) {
    for (const field of Object.keys(translation)) {
      // Skip meta columns from the translation row
      if (['article_id', 'event_id', 'live_id', 'lang', 'auto_translated', 'translated_at', 'created_at', 'updated_at'].includes(field)) {
        continue
      }
      // Non-null translation values win
      if (translation[field] !== null && translation[field] !== undefined) {
        merged[field] = translation[field]
      }
    }
    merged.translationStatus = 'translated'
  } else {
    merged.translationStatus = lang === 'en' ? 'fallback-pt' : 'native'
  }

  return merged
}

/**
 * Fetch a translation row by EN slug, or null if not found.
 * @param {object} supabase  - Supabase client
 * @param {'article'|'event'|'live'} entityType
 * @param {string} slug
 * @param {string} lang
 * @returns {Promise<object|null>}
 */
export async function findTranslationBySlug(supabase, entityType, slug, lang) {
  const table = TRANSLATION_TABLES[entityType]
  if (!table) throw new Error(`Unknown entity type: ${entityType}`)

  const { data, error } = await supabase
    .from(table)
    .select('*')
    .eq('slug', slug)
    .eq('lang', lang)
    .maybeSingle()

  if (error) {
    console.error(`findTranslationBySlug(${entityType}, ${slug}, ${lang}) error:`, error)
    return null
  }
  return data
}

/**
 * Given a desired base slug, return a slug that doesn't yet exist in the
 * translations table for the given lang. Tries base, base-2, base-3, ...
 *
 * @param {object} supabase
 * @param {'article'|'event'|'live'} entityType
 * @param {string} baseSlug
 * @param {string} lang
 * @returns {Promise<string>}
 */
export async function ensureUniqueSlug(supabase, entityType, baseSlug, lang) {
  const table = TRANSLATION_TABLES[entityType]
  const root = slugify(baseSlug) || 'item'

  let candidate = root
  let n = 1
  // Hard ceiling to avoid pathological loops
  while (n < 100) {
    const { data, error } = await supabase
      .from(table)
      .select('slug')
      .eq('slug', candidate)
      .eq('lang', lang)
      .maybeSingle()
    if (error) {
      console.error(`ensureUniqueSlug lookup error:`, error)
      // On error, return the candidate anyway; insert will fail with a
      // constraint violation that's surfaced to the caller.
      return candidate
    }
    if (!data) return candidate
    n += 1
    candidate = `${root}-${n}`
  }
  throw new Error(`Could not find a unique slug for "${root}" in ${lang}`)
}
