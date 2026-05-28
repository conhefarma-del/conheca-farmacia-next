import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getEventBySlug, getInscriptionCount } from '@/lib/api/events'
import InscricaoPageClient from '@/components/pages/InscricaoPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params, searchParams }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('inscricao.title')} | Conheça Farmácia`,
    description: tFn('inscricao.subtitle'),
    robots: { index: false, follow: true },
    alternates: { languages: { pt: '/pt/inscricao', en: '/en/inscricao' } },
  }
}

export default async function InscricaoPage({ params, searchParams }) {
  const { lang } = await params
  const { evento } = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let eventTitle = null
  let capacity = null
  let initialCount = 0
  if (evento) {
    try {
      const event = await getEventBySlug(evento)
      if (event) {
        eventTitle = event.title
        capacity = event.capacity || null
        initialCount = await getInscriptionCount(event.slug)
      }
    } catch {}
  }

  return (
    <InscricaoPageClient
      lang={safeLang}
      eventoSlug={evento || null}
      eventTitle={eventTitle}
      capacity={capacity}
      initialInscriptionCount={initialCount}
    />
  )
}
