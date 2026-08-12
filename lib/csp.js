/**
 * CSP — script anti-FOUC partilhado entre o proxy (que emite o
 * Content-Security-Policy) e o root layout (que o renderiza inline no <head>).
 *
 * O proxy calcula o hash SHA-256 do conteúdo EXATO deste script e usa
 * 'sha256-…' em script-src em vez de um nonce por pedido. Como o script é
 * estático, o hash é estável e compatível com renderização estática/ISR
 * (um nonce por pedido obrigava a render dinâmica — ver P1/performance).
 *
 * ⚠️ Se editares este script, o hash muda — o proxy recalcula-o
 * automaticamente (Web Crypto), por isso o layout e a CSP mantêm-se sempre
 * em sincronia. Não dupliques a string noutro sítio.
 */

// Anti-FOUC (dark mode) + fix do <html lang>. O layout é estático
// (lang="pt" por defeito no HTML servido); este script acerta o atributo
// `lang` a partir do pathname antes da primeira pintura.
export const ANTI_FOUC_SCRIPT =
  "(function(){try{var p=location.pathname.split('/')[1];if(p==='en'||p==='pt')document.documentElement.lang=p;var t=localStorage.getItem('theme');var d=t==='dark'||(!t&&matchMedia('(prefers-color-scheme:dark)').matches);if(d)document.documentElement.classList.add('dark')}catch(e){}})()"

// Cache do hash — a CSP é emitida por pedido, mas o hash nunca muda.
let _antiFouCHash = null

/**
 * @returns {Promise<string>} SHA-256 do script anti-FOUC em base64 (CSP hash).
 * Usa Web Crypto (crypto.subtle) — disponível no runtime Edge do middleware
 * e no runtime Node do layout.
 */
export async function getAntiFouCSha256() {
  if (_antiFouCHash) return _antiFouCHash
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(ANTI_FOUC_SCRIPT)
  )
  const bytes = new Uint8Array(digest)
  let bin = ''
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i])
  _antiFouCHash = btoa(bin)
  return _antiFouCHash
}
