import Image from 'next/image'
import { loadTranslations } from '@/lib/i18n'
import LangProvider from '@/components/providers/LangProvider'
import { LOCATOR_ORIGIN, SITE_ORIGIN } from '@/lib/account-urls'

/**
 * Chrome da área de conta (conta.conhecafarmacia.com).
 *
 * Não é o cabeçalho de nenhum dos dois produtos: sem menu do site, sem
 * utility bar, sem barra do Localizador, sem rodapé de newsletter. A conta é
 * o lugar onde os dois se encontram, por isso a barra é só a marca em ponto
 * pequeno e as duas portas de saída — «Site» e «Localizador» — para ninguém
 * ficar preso aqui depois de entrar.
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

const DESTINATIONS = [
  { href: SITE_ORIGIN, label: 'Site' },
  { href: LOCATOR_ORIGIN, label: 'Localizador' },
]

export default function AccountLayout({ children }) {
  const translations = loadTranslations('pt')

  return (
    <LangProvider lang="pt" translations={translations}>
      <div className="min-h-dvh flex flex-col bg-brand-bg-alt">
        <div className="border-b border-brand-divider/60">
          <div className="container-center flex items-center justify-between gap-3 py-3">
            <Image
              src="/logo/logo-principal-verde.png"
              alt="Conheça Farmácia"
              width={120}
              height={41}
              priority
              style={{ height: 22, width: 'auto' }}
            />

            <nav aria-label="Ir para" className="flex items-center gap-1.5">
              {DESTINATIONS.map(({ href, label }) => (
                <a
                  key={href}
                  href={href}
                  className="rounded-full border border-brand-divider px-3 py-1.5 text-xs font-medium text-brand-deep/70 transition-colors hover:border-brand-accent/40 hover:text-brand-deep"
                >
                  {label}
                </a>
              ))}
            </nav>
          </div>
        </div>

        <main className="flex-1">{children}</main>

        <footer className="py-6">
          <div className="container-center text-center text-xs text-brand-deep/40">
            Uma conta para o site e para o Localizador.
          </div>
        </footer>
      </div>
    </LangProvider>
  )
}
