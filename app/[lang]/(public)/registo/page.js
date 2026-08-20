import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import RegistoClient from './registoClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('auth.register_title') || 'Criar Conta'} | Conheça Farmácia`,
    description: tFn('auth.register_description') || 'Cria uma conta Conheça Farmácia',
    alternates: { languages: { pt: '/pt/registo', en: '/en/register' } },
    robots: { index: false, follow: true },
  }
}

export default async function RegistoPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <RegistoClient lang={safeLang} />
}
