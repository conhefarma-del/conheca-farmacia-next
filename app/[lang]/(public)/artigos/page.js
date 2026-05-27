import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getArticles } from '@/lib/api/articles'
import ArtigosPageClient from '@/components/pages/ArtigosPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('artigos_page.hero_title')} | Conheça Farmácia`,
    description: tFn('artigos_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/artigos', en: '/en/artigos' } },
  }
}

export default async function ArtigosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let articles = []
  try {
    articles = await getArticles()
  } catch (err) {
    console.error('Error fetching articles:', err)
  }

  return (
    <ArtigosPageClient
      articles={articles}
      lang={safeLang}
    />
  )
}
