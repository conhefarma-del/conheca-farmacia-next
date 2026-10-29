import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { safeNext } from '@/lib/account-next'

/**
 * Fecha uma ligação de e-mail (confirmação, reposição, troca de e-mail).
 *
 * O Supabase entrega o código PKCE em `?code=` e a sessão só existe depois de
 * `exchangeCodeForSession` — que tem de correr no servidor, para as cookies
 * ficarem gravadas no mesmo request (o padrão do portal da farmácia, e a lição
 * do «loop após entrar»: sessão só no browser → servidor não a vê).
 *
 * O destino (`next`) vem validado por `safeNext()`: este parâmetro atravessa
 * domínios e sem allow list era um open redirect.
 *
 * @param {Request} request
 * @param {string} fallbackNext  destino quando o link não traz `next`
 */
export async function completeAuthLink(request, fallbackNext) {
  const url = new URL(request.url)
  const code = url.searchParams.get('code')
  const errorDescription = url.searchParams.get('error_description')

  // O OAuth não aceita um `next` com query string no redirectTo; o destino
  // viaja numa cookie curta criada pelo formulário antes do salto.
  let cookieNext = null
  const rawCookie = request.cookies.get('cf-next')?.value
  if (rawCookie) {
    try {
      cookieNext = decodeURIComponent(rawCookie)
    } catch {
      cookieNext = null
    }
  }

  const next = safeNext(url.searchParams.get('next') || cookieNext, fallbackNext)

  if (errorDescription || !code) {
    return NextResponse.redirect(new URL('/entrar?motivo=LINK_INVALIDO', url.origin))
  }

  const supabase = await createClient()
  const { error } = await supabase.auth.exchangeCodeForSession(code)
  if (error) {
    return NextResponse.redirect(new URL('/entrar?motivo=LINK_INVALIDO', url.origin))
  }

  const response = NextResponse.redirect(new URL(next, url.origin))
  response.cookies.delete('cf-next')
  return response
}
