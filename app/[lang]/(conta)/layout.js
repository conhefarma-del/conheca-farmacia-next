import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import AccountShell from '@/components/account/AccountShell'
import { SITE_ORIGIN } from '@/lib/account-urls'

export const dynamic = 'force-dynamic'

/**
 * Chassi das páginas de perfil do site (/[lang]/perfil e /definicoes).
 *
 * Sai do route group `(public)` de propósito: o perfil é uma área de conta,
 * não uma página editorial, e por isso não leva o cabeçalho do site nem o
 * rodapé de newsletter. A sessão é validada aqui (a mesma cookie de
 * conta.*) para as páginas não terem de repetir a leitura.
 */
export default async function ContaSiteLayout({ children, params }) {
  const { lang } = await params
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  // O `next` leva a pessoa de volta ao perfil, não à visão geral da conta:
  // sem ele, quem vinha do «Perfil de estudante» aterrava em `conta.*/perfil`.
  if (!user) {
    const next = encodeURIComponent(`${SITE_ORIGIN}/${lang}/perfil`)
    redirect(`/${lang}/entrar?next=${next}`)
  }

  const meta = user.user_metadata || {}

  return (
    <AccountShell
      surface="site"
      lang={lang}
      user={{
        name: meta.full_name || meta.display_name || '',
        email: user.email || '',
        avatarUrl: meta.avatar_url_upload || meta.avatar_url || '',
      }}
    >
      {children}
    </AccountShell>
  )
}
