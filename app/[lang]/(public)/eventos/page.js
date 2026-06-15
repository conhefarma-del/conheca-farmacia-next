import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getEvents } from '@/lib/api/events'
import { EVENT_CATEGORY_COLORS, EVENT_CATEGORIES } from '@/lib/constants'
import EventosPageClient from '@/components/pages/EventosPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('eventos_page.hero_title')} | Conheça Farmácia`,
    description: tFn('eventos_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/eventos', en: '/en/eventos' } },
  }
}

export default async function EventosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)

  let events = []
  try {
    events = await getEvents(safeLang)
  } catch (err) {
    console.error('Error fetching events:', err)
  }

  return (
    <EventosPageClient
      events={events}
      lang={safeLang}
      categoryColors={EVENT_CATEGORY_COLORS}
      categories={EVENT_CATEGORIES}
    />
  )
}
