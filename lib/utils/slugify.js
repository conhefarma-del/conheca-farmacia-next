/**
 * Slugify a string into URL-safe kebab-case.
 * - Lowercase
 * - Strips diacritics (NFD + remove combining marks)
 * - Replaces any non-alphanumeric run with a single dash
 * - Trims leading/trailing dashes
 *
 * @param {string} input
 * @returns {string}
 */
export function slugify(input) {
  if (!input || typeof input !== 'string') return ''
  return input
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // remove diacritics
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 200) // hard cap to keep URLs sane
}
