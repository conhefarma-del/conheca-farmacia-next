import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getFlashcardDecks } from '@/lib/api/flashcards'
import FlashcardsPageClient from '@/components/pages/FlashcardsPageClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('flashcards_page.hero_title')} | Conheça Farmácia`,
    description: tFn('flashcards_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/flashcards', en: '/en/flashcards' } },
  }
}

export default async function FlashcardsPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let decks = []
  try {
    decks = await getFlashcardDecks()
  } catch (err) {
    console.error('Error fetching flashcard decks:', err)
  }

  return <FlashcardsPageClient decks={decks} lang={safeLang} />
}
