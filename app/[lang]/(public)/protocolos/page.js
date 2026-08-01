import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicProtocolCategories, getPublicProtocols } from '@/lib/actions/protocolos'
import ProtocolosPageClient from './protocolosPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('protocolos_page.hero_title')} | Conheça Farmácia`,
    description: tFn('protocolos_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/protocolos', en: '/en/protocols' } },
  }
}

export default async function ProtocolosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const [categories, protocols] = await Promise.all([
    getPublicProtocolCategories(safeLang),
    getPublicProtocols(safeLang),
  ])
  return <ProtocolosPageClient lang={safeLang} categories={categories} protocols={protocols} />
}
