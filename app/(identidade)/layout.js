import { createClient } from '@/lib/supabase/server'
import { loadTranslations } from '@/lib/i18n'
import { accountLang } from '@/lib/account-i18n'
import LangProvider from '@/components/providers/LangProvider'

/**
 * Área de conta (conta.conhecafarmacia.com).
 *
 * O layout já não desenha chrome: as páginas de autenticação e as páginas
 * de conta têm chassis diferentes. `(auth)` mantém a barra de marca com as
 * duas portas de saída; `/perfil` usa o AccountShell (sidebar + top-bar),
 * o mesmo do Localizador e do perfil de estudante.
 *
 * As rotas vivem na raiz (`/entrar`, `/perfil`), sem `[lang]`: em conta.* não
 * há idioma no URL. O idioma vem daqui — da preferência guardada na conta —
 * e é o que faz o perfil deixar de estar sempre em português depois de a
 * pessoa escolher inglês em Preferências. Sem sessão (ou sem preferência),
 * fica PT.
 */

export const metadata = {
  title: {
    default: 'A minha conta | Conheça Farmácia',
    template: '%s | A minha conta',
  },
  robots: { index: false, follow: false },
}

export default async function AccountGroupLayout({ children }) {
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()

  const lang = accountLang(user)

  return (
    <LangProvider lang={lang} translations={loadTranslations(lang)}>
      {children}
    </LangProvider>
  )
}
