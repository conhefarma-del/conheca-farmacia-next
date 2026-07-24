/**
 * Valida cor hex (#RGB ou #RRGGBB). Usado em template de certificado (events.certificado_cor).
 * Evita injeção de CSS arbitrário no estilo do certificado.
 */
export function isValidHexColor(value) {
  if (typeof value !== 'string') return false
  return /^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/.test(value.trim())
}

/**
 * Escape HTML special characters to prevent XSS
 */
export function escapeHtml(unsafe) {
  if (!unsafe) return ''
  return String(unsafe)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
}

/**
 * Escape HTML attribute values
 */
export function escapeAttr(unsafe) {
  if (!unsafe) return ''
  return String(unsafe)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

/**
 * Validate URL — only allow http/https, fallback to '#'.
 *
 * MED-09: the previous startsWith('http') check let through schemes like
 * 'httpfoo://' and 'https-evil.example/'. A strict regex anchored at the
 * start of the string forces http:// or https:// to actually be the
 * scheme delimiter.
 */
const SAFE_URL_REGEX = /^https?:\/\//i
export function validateUrl(url) {
  if (!url || typeof url !== 'string' || !SAFE_URL_REGEX.test(url)) return '#'
  return url
}
