import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import PesquisaPageClient from '@/components/pages/PesquisaPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('search.hero_title')} | Conheça Farmácia`,
    description: tFn('search.hero_subtitle'),
    alternates: { languages: { pt: '/pt/pesquisa', en: '/en/pesquisa' } },
  }
}

export default async function PesquisaPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  return <PesquisaPageClient lang={safeLang} />
}
