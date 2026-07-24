import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicFAQData } from '@/lib/actions/legalContent'
import FAQPageClient from './faqPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('faq_page.hero_title')} | Conheça Farmácia`,
    description: tFn('faq_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/faq', en: '/en/faq' } },
  }
}

export default async function FAQPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const tabs = await getPublicFAQData()

  return <FAQPageClient lang={safeLang} tabs={tabs} />
}
