import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import EntrarClient from './entrarClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('auth.login_title') || 'Entrar'} | Conheça Farmácia`,
    description: tFn('auth.login_description') || 'Entra na tua conta Conheça Farmácia',
    alternates: { languages: { pt: '/pt/entrar', en: '/en/login' } },
    robots: { index: false, follow: true },
  }
}

export default async function EntrarPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <EntrarClient lang={safeLang} />
}
