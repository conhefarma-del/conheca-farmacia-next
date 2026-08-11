import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getScientificArticles, getScientificCategories } from '@/lib/api/scientific-articles'
import CientificosPageClient from '@/components/pages/CientificosPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('cientificos_page.hero_title')} | Conheça Farmácia`,
    description: tFn('cientificos_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/cientificos', en: '/en/cientificos' } },
  }
}

export default async function CientificosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let articles = []
  let categories = []
  try {
    ;[articles, categories] = await Promise.all([
      getScientificArticles(safeLang),
      getScientificCategories(safeLang),
    ])
  } catch (err) {
    console.error('Error fetching scientific articles:', err)
  }

  return (
    <CientificosPageClient
      articles={articles}
      categories={categories}
      lang={safeLang}
    />
  )
}
