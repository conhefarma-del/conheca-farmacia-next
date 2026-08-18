import { notFound } from 'next/navigation'
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getFlashcardDeckBySlug, getFlashcardDrugMap } from '@/lib/api/flashcards'
import FlashcardReviewClient from '@/components/pages/FlashcardReviewClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  const deck = await getFlashcardDeckBySlug(slug)
  const name = deck?.name || tFn('flashcards_page.hero_title')

  return {
    title: `${name} — Revisão | Conheça Farmácia`,
    description: deck?.description || tFn('flashcards_page.hero_subtitle'),
    alternates: { languages: { pt: `/pt/flashcards/${slug}`, en: `/en/flashcards/${slug}` } },
  }
}

export default async function FlashcardDeckPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let deck = null
  try {
    deck = await getFlashcardDeckBySlug(slug)
  } catch (err) {
    console.error('Error fetching flashcard deck:', err)
  }

  if (!deck) notFound()

  // Mapa fármaco → { slug, name } para os links "Ver perfil"
  const drugIds = [...new Set(deck.cards.map((c) => c.drugId).filter(Boolean))]
  let drugMap = {}
  try {
    drugMap = await getFlashcardDrugMap(drugIds)
  } catch {
    drugMap = {}
  }

  return (
    <FlashcardReviewClient
      deck={deck}
      drugMap={drugMap}
      lang={safeLang}
    />
  )
}
