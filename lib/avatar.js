/**
 * Avatar utilities — foto carregada na conta ou foto do Google OAuth.
 *
 * Prioridade:
 * 1. user_metadata.avatar_url_upload (upload na conta — o Google não toca)
 * 2. user_metadata.avatar_url (foto devolvida pelo Google)
 *
 * Sem nenhuma das duas devolve `null`: a interface desenha as iniciais. O
 * identicon do Gravatar saiu — parecia uma imagem que falhou a carregar.
 */

/**
 * Returns the avatar URL for a user.
 * @param {Object} user - Supabase auth user object
 * @param {number} [size=80] - Gravatar image size
 * @returns {string|null} Avatar URL or null
 */
export function getAvatarUrl(user, size = 80) {
  if (!user) return null

  // 1. Upload feito na conta (o login Google não reescreve esta chave)
  const uploaded = user.user_metadata?.avatar_url_upload
  if (uploaded) return uploaded

  // 2. Foto do Google OAuth
  return user.user_metadata?.avatar_url || null
}

/**
 * Client-side version (no crypto module — uses Web Crypto API).
 * For use in React components.
 */
export function getAvatarUrlClient(explicitUrl) {
  // Sem foto, devolve `null` e quem desenha usa as iniciais.
  return explicitUrl || null
}
