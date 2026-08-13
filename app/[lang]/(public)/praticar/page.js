import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getQuizPools } from '@/lib/api/quiz'
import { getFlashcardDecks } from '@/lib/api/flashcards'
import PraticarPageClient from '@/components/pages/PraticarPageClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('praticar_page.hero_title')} | Conheça Farmácia`,
    description: tFn('praticar_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/praticar', en: '/en/praticar' } },
  }
}

export default async function PraticarPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let pools = null
  let flashDecks = []
  try {
    ;[pools, flashDecks] = await Promise.all([getQuizPools(), getFlashcardDecks()])
  } catch (err) {
    console.error('Error loading /praticar data:', err)
  }

  const counts = pools?.counts || {}
  const questionTotal =
    (counts.cards || 0) +
    (counts.drugs || 0) +
    (counts.interactions || 0) +
    (counts.food || 0) +
    (counts.disease || 0) +
    (counts.protocols || 0)

  return (
    <PraticarPageClient
      lang={safeLang}
      counts={{
        questionTotal,
        decks: counts.decks || 0,
        cards: counts.cards || 0,
        drugs: counts.drugs || 0,
        interactions: (counts.interactions || 0) + (counts.food || 0) + (counts.disease || 0),
        protocols: counts.protocols || 0,
      }}
      flashcards={{ decks: flashDecks.length, cards: (counts.cards || 0) }}
    />
  )
}
