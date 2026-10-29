import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import EntrarClient from '@/components/auth/EntrarForm'
import { safeNext } from '@/lib/account-next'
import { SITE_ORIGIN } from '@/lib/account-urls'

export const dynamic = 'force-dynamic'

export const metadata = {
  title: 'Entrar',
  robots: { index: false, follow: false },
}

/**
 * Avisos que chegam por `?motivo=` — sem eles, quem apaga a conta ou cai num
 * link expirado aterrava num formulário de login sem explicação nenhuma.
 */
const MOTIVOS = {
  CONTA_APAGADA: 'A sua conta foi apagada. Obrigado por ter estado connosco.',
  LINK_INVALIDO:
    'A ligação expirou ou já foi usada. Peça um novo e-mail ou entre com a palavra-passe.',
}

/**
 * Entrada da conta — a única do sistema.
 *
 * O site e o Localizador deixaram de ter formulários próprios: apontam para
 * aqui com `?next=<destino>`. `next` é validado por `safeNext()` antes de
 * chegar ao formulário, porque é ele que decide para onde a pessoa vai depois
 * de autenticada.
 */
export default async function EntrarPage({ searchParams }) {
  const params = await searchParams
  const next = safeNext(params?.next, '/perfil')
  const notice = MOTIVOS[params?.motivo] || null

  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (user) redirect(next)

  return (
    <EntrarClient
      lang="pt"
      basePath=""
      nextUrl={next}
      confirmPath="/auth/confirm"
      siteBase={`${SITE_ORIGIN}/pt`}
      notice={notice}
    />
  )
}
