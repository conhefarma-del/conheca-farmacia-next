import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicPrivacyData } from '@/lib/actions/legalContent'
import PrivacyPageClient from './privacyPageClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('privacy_page.hero_title')} | Conheça Farmácia`,
    description: tFn('privacy_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/politica-privacidade', en: '/en/privacy-policy' } },
  }
}

export default async function PrivacyPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const sections = await getPublicPrivacyData()

  return <PrivacyPageClient lang={safeLang} sections={sections} />
}
