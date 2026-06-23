// Helpers used by /validar/[ref] page to sanitise inscription data
// before exposing it publicly. Never expose raw PII (email, phone) or
// the full attendee name to unauthenticated visitors.

/**
 * Strip leading zeros from a zero-padded reference (e.g. "000090" → "90").
 * Returns the int8-friendly numeric string.
 */
export function refToInt(ref) {
  if (!ref || !/^\d{1,6}$/.test(ref)) return null
  // parse to Number to strip leading zeros; re-stringify for safety
  const n = parseInt(ref, 10)
  if (!Number.isFinite(n) || n <= 0) return null
  return String(n)
}

/**
 * "João Silva Santos" → "João S."
 * Falls back to the first word if there is no last name.
 */
export function partialName(fullName) {
  if (!fullName || typeof fullName !== 'string') return ''
  const parts = fullName.trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return ''
  if (parts.length === 1) return parts[0]
  const last = parts[parts.length - 1]
  return `${parts[0]} ${last.charAt(0).toUpperCase()}.`
}

/**
 * "joao@example.com" → "j***@example.com"
 * Preserves domain for verifiability without leaking the local-part.
 */
export function maskEmail(email) {
  if (!email || typeof email !== 'string') return ''
  const at = email.indexOf('@')
  if (at < 1) return ''
  const local = email.slice(0, at)
  const domain = email.slice(at + 1)
  if (!domain) return ''
  return `${local.charAt(0).toLowerCase()}***@${domain}`
}

/**
 * Format a date in pt-PT long form (e.g. "21 de junho de 2026").
 */
export function formatPtDate(iso) {
  if (!iso) return ''
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return ''
  return new Intl.DateTimeFormat('pt-PT', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  }).format(d)
}
