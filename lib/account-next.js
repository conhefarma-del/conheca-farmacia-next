/**
 * Validação do `next` da área de conta.
 *
 * O parâmetro atravessa domínios (`conta.*` → `localizador.*`), o que faz dele
 * um open redirect se for usado tal e qual: `/entrar?next=https://site-malicioso`
 * devolveria a pessoa, já autenticada, a um site de terceiros. Só passam
 * caminhos relativos e hosts da própria Conheça Farmácia.
 *
 * Não é `'use server'`: é código puro, chamado por Server Components (páginas
 * de entrar/registar) e por Route Handlers (/auth/confirm), e testável sem
 * servidor.
 */

const DEFAULT_NEXT = '/perfil'

/** Hosts aceites, além de `*.conhecafarmacia.com`. */
const EXTRA_HOSTS = new Set(['localhost', '127.0.0.1'])

function isAllowedHost(hostname) {
  const host = String(hostname || '').toLowerCase()
  if (!host) return false
  if (EXTRA_HOSTS.has(host)) return true
  return host === 'conhecafarmacia.com' || host.endsWith('.conhecafarmacia.com')
}

/**
 * Devolve um destino seguro para depois de entrar/criar conta.
 *
 * @param {string|null|undefined} raw   valor recebido em `?next=`
 * @param {string} fallback             usado quando não há `next` ou é inválido
 * @returns {string} caminho relativo (`/perfil`) ou URL absoluta do domínio CF
 */
export function safeNext(raw, fallback = DEFAULT_NEXT) {
  if (raw === null || raw === undefined) return fallback
  const value = String(raw).trim()
  if (!value) return fallback

  // Caminho relativo: aceita, mas recusa `//host` (protocol-relative) e
  // qualquer tentativa de escapar com barras invertidas.
  if (value.startsWith('/')) {
    if (value.startsWith('//') || value.startsWith('/\\')) return fallback
    return value
  }

  try {
    const url = new URL(value)
    const local = url.hostname === 'localhost' || url.hostname === '127.0.0.1'
    if (url.protocol !== 'https:' && !(local && url.protocol === 'http:')) return fallback
    if (!isAllowedHost(url.hostname)) return fallback
    return url.toString()
  } catch {
    return fallback
  }
}
