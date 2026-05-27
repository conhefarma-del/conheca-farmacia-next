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
 * Validate URL — only allow http/https, fallback to '#'
 */
export function validateUrl(url) {
  if (!url || !url.startsWith('http')) return '#'
  return url
}
