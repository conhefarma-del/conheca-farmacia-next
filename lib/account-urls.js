/**
 * Origens dos hosts que partilham a mesma conta.
 *
 * A área de conta vive em `conta.conhecafarmacia.com`, servida por este
 * projecto (alias de domínio, não um deploy novo). Os links para o conteúdo
 * de cada produto têm de ser absolutos, porque atravessam hosts — um `Link`
 * relativo a `/pt/guardados` a partir do conta.* cairia no proxy que devolve
 * o visitante ao site, mas com um salto a mais.
 *
 * Tudo configurável por ambiente para os previews da Vercel não apontarem
 * sempre para produção.
 */

/** Remove barras finais para as concatenações não gerarem `//`. */
const origin = (value, fallback) =>
  String(value || '')
    .trim()
    .replace(/\/+$/, '') || fallback

export const SITE_ORIGIN = origin(
  process.env.NEXT_PUBLIC_SITE_URL,
  'https://www.conhecafarmacia.com',
)

export const ACCOUNT_ORIGIN = origin(
  process.env.NEXT_PUBLIC_ACCOUNT_ORIGIN,
  'https://conta.conhecafarmacia.com',
)

export const LOCATOR_ORIGIN = origin(
  process.env.NEXT_PUBLIC_LOCATOR_ORIGIN,
  'https://localizador.conhecafarmacia.com',
)
