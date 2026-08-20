import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { SITE_URL } from '@/lib/constants'
import DefinicoesPageClient from './definicoesPageClient'

export const revalidate = 0

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('settings.page_title')} | Conheça Farmácia`,
    description: tFn('settings.page_description'),
    alternates: {
      languages: {
        pt: '/pt/perfil/definicoes',
        en: '/en/profile/settings',
      },
    },
  }
}

export default async function DefinicoesPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  return <DefinicoesPageClient lang={safeLang} />
}
