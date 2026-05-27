import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getEvents, getInscriptionCount } from '@/lib/api/events'
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

  let events = []
  try {
    events = await getEvents()
  } catch (err) {
    console.error('Error fetching events:', err)
  }

  const eventsWithCounts = await Promise.all(
    events.map(async (event) => {
      try {
        const count = await getInscriptionCount(event.slug)
        return { ...event, inscriptionCount: count }
      } catch {
        return { ...event, inscriptionCount: 0 }
      }
    })
  )

  return (
    <EventosPageClient
      events={eventsWithCounts}
      lang={safeLang}
    />
  )
}
