import { createClient } from '@/lib/supabase/server'
import { slugify } from '@/lib/utils/slugify'

/**
 * Translation merge helpers for content entities (article, event, live).
 *
 * Data model:
 *  - `articles` / `events` / `lives` hold the canonical PT row.
 *  - `article_translations` / `event_translations` / `live_translations` hold
 *    per-language rows with composite PK (entity_id, lang).
 *
 * Convention: a "translation" row contains ALL translatable fields (any may be
 * null) plus `slug`, `title` (required), `lang`, and `auto_translated`.
 *
 * `mergeEntity(baseRow, translation, lang)` returns the base row with
 * translatable fields overridden by the translation when present. When
 * `translation` is null, the PT row is returned unchanged.
 */

export const ENTITY_TRANSLATABLE_FIELDS = {
  article: [
    'title',
    'excerpt',
    'content',
    'category',
    'category_label',
    'author_role',
    'author_bio',
    'meta_description',
  ],
  event: [
    'title',
    'excerpt',
    'type',
    'location',
    'hosts',
    'category_label',
    'meta_description',
  ],
  live: [
    'title',
    'description',
    'hosts',
    'topic',
    'meta_description',
  ],
}
const ENTITY_TRANSLATION_TABLES = {
  article: 'article_translations',
  event:   'event_translations',
  live:    'live_translations',
}

const AUTHOR_HOST_FIELDS = new Set(['author_name', 'host_name'])

/**
 * Map camelCase field name → snake_case column name in translation table.
 */
const FIELD_TO_COLUMN = {
  title: 'title',
  excerpt: 'excerpt',
  content: 'content',
  category: 'category',
  categoryLabel: 'category_label',
  category_label: 'category_label',
  description: 'description',
  location: 'location',
  type: 'type',
  hosts: 'hosts',
  authorName: 'author_name',
  author_name: 'author_name',
  authorRole: 'author_role',
  author_role: 'author_role',
  authorBio: 'author_bio',
  author_bio: 'author_bio',
  topic: 'topic',
  hostRole: 'host_role',
  host_role: 'host_role',
  metaDescription: 'meta_description',
  meta_description: 'meta_description',
  slug: 'slug',
}

/**
 * Merge a base PT row with an optional translation row.
 *
 * Returns a new object that mirrors the base row's shape (camelCase + snake_case
 * duplicates via `normalize*` helpers in the API layer) but with translatable
 * fields overridden by the translation. Non-translatable fields (image_url,
 * date, author_avatar, etc.) are always taken from the base row.
 *
 * @param {object} baseRow
 * @param {object|null} translationRow
 * @param {string} lang
 * @returns {object}
 */
export function mergeEntity(baseRow, translationRow, lang) {
  if (!baseRow) return null
  if (!translationRow) return baseRow

  const merged = { ...baseRow }

  for (const camelKey of Object.keys(FIELD_TO_COLUMN)) {
    const col = FIELD_TO_COLUMN[camelKey]
    if (!(col in translationRow)) continue
    const translated = translationRow[col]
    if (translated === null || translated === undefined) continue
    merged[camelKey] = translated
  }

  merged.lang = lang
  merged.has_translation = true
  merged.auto_translated = translationRow.auto_translated ?? false
  merged.translated_at = translationRow.translated_at ?? null

  // Reconstruct nested author object so that camelCase merges
  // (authorRole, authorBio) are reflected in the nested object
  // used by the frontend components. Hosts are now an array
  // (events.hosts) and are not reconstructed here — they are
  // merged wholesale by the loop above.
  if (merged.author) {
    merged.author = { ...merged.author }
    if (merged.authorRole !== undefined) merged.author.role = merged.authorRole
    if (merged.authorBio !== undefined) merged.author.bio = merged.authorBio
  }

  return merged
}

/**
 * Project a normalised input object (camelCase keys, as submitted by admin
 * forms) into the subset of fields that should be stored on the translation
 * row. Returns an object with snake_case keys matching the column names.
 *
 * `author_name` and `host_name` are explicit NOT translated — they are
 * filtered out here. The admin form passes through whatever is in the PT
 * row at insertion time.
 *
 * @param {object} input  — normalised admin form payload (camelCase)
 * @param {'article'|'event'|'live'} entityType
 * @param {object} [opts]
 * @param {string} [opts.slug]  — required: the EN slug
 * @returns {object}
 */
export function projectTranslatableInput(input, entityType, opts = {}) {
  if (!input) throw new Error('projectTranslatableInput: input is required')
  if (!entityType) throw new Error('projectTranslatableInput: entityType is required')

  const allowed = new Set(ENTITY_TRANSLATABLE_FIELDS[entityType] || [])
  const out = {}

  for (const [camelKey, col] of Object.entries(FIELD_TO_COLUMN)) {
    if (col === 'slug') continue
    if (AUTHOR_HOST_FIELDS.has(col)) continue
    if (!allowed.has(col)) continue
    if (!(camelKey in input)) continue
    const v = input[camelKey]
    if (v === undefined) continue
    out[col] = v === '' ? null : v
  }

  if (opts.slug) out.slug = opts.slug

  return out
}

/**
 * Generate a unique EN slug given the desired slug and an async function that
 * checks whether a candidate slug is already taken in `article_translations`
 * (or the equivalent table for the entity).
 *
 * If `desired` collides, appends `-2`, `-3`, ... until a free slug is found.
 * Always returns a slugify()'d string.
 *
 * @param {string} desired
 * @param {(candidate: string) => Promise<boolean>} existsFn
 * @returns {Promise<string>}
 */
export async function ensureUniqueEnSlug(desired, existsFn) {
  const base = slugify(desired) || 'translation'
  if (!(await existsFn(base))) return base
  for (let i = 2; i < 1000; i++) {
    const candidate = `${base}-${i}`
    if (!(await existsFn(candidate))) return candidate
  }
  throw new Error('ensureUniqueEnSlug: too many collisions')
}

/**
 * Build the PT fallback row (the base row, no translation) for a given lang.
 * Used by public pages so that `/en/articles/[slug]` always renders something
 * even when no EN translation exists.
 */
export function ptFallback(baseRow, lang) {
  if (!baseRow) return null
  return { ...baseRow, lang, has_translation: false }
}

/**
 * Given a base entity id and the URL lang, return the translation row for
 * the OTHER supported lang (used to build `alternates.languages` hreflang
 * for SEO).
 *
 * @param {object} supabase
 * @param {'article'|'event'|'live'} entityType
 * @param {string} entityId
 * @param {string} otherLang  - 'pt' or 'en' (the lang NOT being rendered)
 * @returns {Promise<object|null>}
 */
export async function findTranslationByEntityId(supabase, entityType, entityId, otherLang) {
  const table = ENTITY_TRANSLATION_TABLES[entityType]
  if (!table) throw new Error(`Unknown entity type: ${entityType}`)
  if (otherLang === 'pt') return null // PT row is the base, not a translation

  const { data, error } = await supabase
    .from(table)
    .select('*')
    .eq(`${entityType}_id`, entityId)
    .eq('lang', otherLang)
    .maybeSingle()

  if (error) {
    console.error(`findTranslationByEntityId(${entityType}, ${entityId}, ${otherLang}) error:`, error)
    return null
  }
  return data
}

/**
 * Find a translation row by its translated slug (e.g. EN slug) and the
 * language code. Used by `getArticleBySlug` / `getEventBySlug` /
 * `getLiveBySlug` when the user visits `/en/...` and we need to resolve
 * the EN slug back to its base PT entity before merging.
 *
 * @param {object} supabase
 * @param {'article'|'event'|'live'} entityType
 * @param {string} slug       - the slug as it appears in the URL
 * @param {string} lang       - 'pt' or 'en' (the lang the slug is in)
 * @returns {Promise<object|null>}
 */
export async function findTranslationBySlug(supabase, entityType, slug, lang) {
  if (lang === 'pt') return null
  const table = ENTITY_TRANSLATION_TABLES[entityType]
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
 * Convenience wrapper around `findTranslationByEntityId` that creates its own
 * server-side Supabase client. Used by the admin pages (articles, events,
 * lives) which previously called this under the 3-arg signature.
 *
 * @param {'article'|'event'|'live'} entityType
 * @param {string} entityId
 * @param {'pt'|'en'} lang
 * @returns {Promise<object|null>}
 */
export async function getTranslationByEntityId(entityType, entityId, lang) {
  const supabase = await createClient()
  return findTranslationByEntityId(supabase, entityType, entityId, lang)
}

/**
 * List published entities (articles, events, or lives) that DO NOT have an
 * English translation yet. Used by the bulk-translate admin page to show
 * pending entries.
 *
 * Returned rows include ids + display title + slug + dates so the admin UI
 * can render the list without further lookups.
 *
 * @param {'article'|'event'|'live'} entityType
 * @returns {Promise<Array<{id: string, title: string, slug: string, published_date?: string, event_date?: string, live_date?: string, status: string}>>}
 */
export async function listEntitiesMissingTranslation(entityType) {
  const supabase = await createClient()
  const baseTable = { article: 'articles', event: 'events', live: 'lives' }[entityType]
  const translationTable = ENTITY_TRANSLATION_TABLES[entityType]
  const idCol = `${entityType}_id`
  const dateCol =
    entityType === 'article'
      ? 'published_date'
      : entityType === 'event'
      ? 'event_date'
      : 'live_date'

  // 1. Collect ids that already have an EN translation.
  const { data: translated, error: errT } = await supabase
    .from(translationTable)
    .select(idCol)
    .eq('lang', 'en')
  if (errT) {
    console.error(`listEntitiesMissingTranslation(${entityType}) translated:`, errT)
    return []
  }
  const translatedIds = new Set((translated ?? []).map((r) => r[idCol]))

  // 2. Fetch all published, non-archived entities.
  const { data: all, error: errA } = await supabase
    .from(baseTable)
    .select(`id, title, slug, ${dateCol}, status`)
    .eq('status', 'published')
    .eq('is_archived', false)
    .order(dateCol, { ascending: false, nullsFirst: false })
  if (errA) {
    console.error(`listEntitiesMissingTranslation(${entityType}) all:`, errA)
    return []
  }

  return (all ?? []).filter((row) => !translatedIds.has(row.id))
}
