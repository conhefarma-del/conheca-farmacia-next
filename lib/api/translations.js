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
 *
 * `buildTranslatableFields(row, entityType, fields)` projects a normalised
 * input object (camelCase or snake_case) into the field subset expected by
 * the translation tables, returning only the keys that match a known
 * translatable field for the entity type.
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
    'description',
    'location',
    'host_role',
    'host_bio',
    'meta_description',
  ],
  live: [
    'title',
    'description',
    'host_role',
    'topic',
    'meta_description',
  ],
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
  authorName: 'author_name',
  author_name: 'author_name',
  authorRole: 'author_role',
  author_role: 'author_role',
  authorBio: 'author_bio',
  author_bio: 'author_bio',
  hostName: 'host_name',
  host_name: 'host_name',
  hostRole: 'host_role',
  host_role: 'host_role',
  hostBio: 'host_bio',
  host_bio: 'host_bio',
  topic: 'topic',
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
