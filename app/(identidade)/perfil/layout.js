import { createClient } from '@/lib/supabase/server'
import AccountShell from '@/components/account/AccountShell'

export const dynamic = 'force-dynamic'

/**
 * Chassi do perfil de conta (/perfil e /perfil/seguranca).
 *
 * O layout lê a sessão só para a sidebar saber quem está do outro lado; a
 * autoridade continua nas páginas (redirect para /entrar quando não há
 * sessão). O `next` de cada página é o seu próprio caminho.
 */
export default async function PerfilLayout({ children }) {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  const meta = user?.user_metadata || {}

  return (
    <AccountShell
      surface="conta"
      user={{
        name: meta.full_name || meta.display_name || '',
        email: user?.email || '',
        avatarUrl: meta.avatar_url || '',
      }}
    >
      {children}
    </AccountShell>
  )
}
