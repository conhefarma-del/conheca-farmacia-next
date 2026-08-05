import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import {
  getPublicDrugs,
  getPublishedInteractions,
  getPublishedFoodInteractions,
  getPublishedDiseaseInteractions,
  getPublishedPregnancyInfo,
} from '@/lib/actions/interacoes'
import InteracoesPageClient from './interacoesPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('interacoes_page.hero_title')} | Conheça Farmácia`,
    description: tFn('interacoes_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/interacoes', en: '/en/interactions' } },
  }
}

export default async function InteracoesPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const [drugs, interactions, foodInteractions, diseaseInteractions, pregnancyInfo] =
    await Promise.all([
      getPublicDrugs(safeLang),
      getPublishedInteractions(safeLang),
      getPublishedFoodInteractions(safeLang),
      getPublishedDiseaseInteractions(safeLang),
      getPublishedPregnancyInfo(safeLang),
    ])
  return (
    <InteracoesPageClient
      lang={safeLang}
      drugs={drugs}
      interactions={interactions}
      foodInteractions={foodInteractions}
      diseaseInteractions={diseaseInteractions}
      pregnancyInfo={pregnancyInfo}
    />
  )
}
