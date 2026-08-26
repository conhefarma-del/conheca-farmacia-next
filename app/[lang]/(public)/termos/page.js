import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicTermsData } from '@/lib/actions/legalContent'
import TermosPageClient from './termosPageClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('termos_page.hero_title')} | Conheça Farmácia`,
    description: tFn('termos_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/termos', en: '/en/terms' } },
  }
}

export default async function TermosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const sections = await getPublicTermsData()

  return <TermosPageClient lang={safeLang} sections={sections} />
}
