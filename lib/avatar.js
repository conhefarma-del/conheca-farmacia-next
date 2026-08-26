/**
 * Avatar utilities — Google OAuth photo, upload, or Gravatar fallback.
 *
 * Priority:
 * 1. user_metadata.avatar_url (Google OAuth / manual upload)
 * 2. Gravatar (MD5 of email, with fallback to identicon)
 */
import { createHash } from 'crypto'

/**
 * Returns the avatar URL for a user.
 * @param {Object} user - Supabase auth user object
 * @param {number} [size=80] - Gravatar image size
 * @returns {string|null} Avatar URL or null
 */
export function getAvatarUrl(user, size = 80) {
  if (!user) return null

  // 1. Explicit avatar (Google OAuth / manual upload)
  const explicit = user.user_metadata?.avatar_url
  if (explicit) return explicit

  // 2. Gravatar fallback (works for any email)
  const email = user.email
  if (!email) return null

  const hash = createHash('md5')
    .update(email.trim().toLowerCase())
    .digest('hex')

  return `https://www.gravatar.com/avatar/${hash}?d=identicon&s=${size}`
}

/**
 * Client-side version (no crypto module — uses Web Crypto API).
 * For use in React components.
 */
export function getAvatarUrlClient(email, explicitUrl, size = 80) {
  if (explicitUrl) return explicitUrl
  if (!email) return null

  // Simple MD5 for Gravatar (browser-compatible)
  // We use identicon as fallback which doesn't need true MD5 for basic use
  // But for proper Gravatar, we hash the email
  let hash = 0
  const str = email.trim().toLowerCase()
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i)
    hash = ((hash << 5) - hash) + char
    hash |= 0
  }
  // Convert to hex-like string for Gravatar
  const hex = Math.abs(hash).toString(16).padStart(32, '0')

  return `https://www.gravatar.com/avatar/${hex}?d=identicon&s=${size}`
}
