import { loadTranslations } from '@/lib/i18n'
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
 * há idioma no URL. O LangProvider entra na mesma porque os formulários
 * reutilizados do site leem `LangContext` para as traduções.
 */

export const metadata = {
  title: {
    default: 'A minha conta | Conheça Farmácia',
    template: '%s | A minha conta',
  },
  robots: { index: false, follow: false },
}

export default function AccountGroupLayout({ children }) {
  const translations = loadTranslations('pt')

  return (
    <LangProvider lang="pt" translations={translations}>
      {children}
    </LangProvider>
  )
}
