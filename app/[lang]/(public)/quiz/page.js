import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getQuizPools } from '@/lib/api/quiz'
import QuizModesClient from '@/components/pages/QuizModesClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('quiz_page.hero_title')} | Conheça Farmácia`,
    description: tFn('quiz_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/quiz', en: '/en/quiz' } },
  }
}

export default async function QuizPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let pools = null
  try {
    pools = await getQuizPools()
  } catch (err) {
    console.error('Error loading /quiz data:', err)
  }

  // Decks resumidos (sem os cartões — só para o seletor)
  const decks = (pools?.decks || []).map(({ slug, name, color, cards }) => ({
    slug,
    name,
    color: color || '#0a844f',
    cardCount: (cards || []).length,
  }))

  const counts = pools?.counts || {}
  const typeCounts = {
    flashcard: counts.cards || 0,
    pharmacology: counts.drugs || 0,
    interaction: (counts.interactions || 0) + (counts.food || 0) + (counts.disease || 0),
    protocol: counts.protocols || 0,
  }

  return <QuizModesClient lang={safeLang} decks={decks} typeCounts={typeCounts} />
}
