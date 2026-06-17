import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getEventBySlug, getEventInscriptionCount } from '@/lib/api/events'
import { createClient } from '@/lib/supabase/server'
import InscricaoPageClient from '@/components/pages/InscricaoPageClient'

export const dynamic = 'force-dynamic'

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('inscricao.title')} | Conheça Farmácia`,
    description: tFn('inscricao.subtitle'),
    robots: { index: false, follow: true },
    alternates: { languages: { pt: '/pt/inscricao', en: '/en/register' } },
  }
}

export default async function RegisterPage({ params, searchParams }) {
  const { lang } = await params
  const { eventoId, evento } = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let event = null

  // Preferencial: ?eventoId=<UUID> (estável PT/EN, link canónico)
  if (eventoId && typeof eventoId === 'string' && UUID_REGEX.test(eventoId)) {
    try {
      const supabase = await createClient()
      const { data } = await supabase
        .from('events')
        .select('id, slug, title, capacity, is_archived, status')
        .eq('id', eventoId)
        .eq('status', 'published')
        .eq('is_archived', false)
        .single()
      event = data
    } catch {}
  }

  // Fallback legacy: ?evento=<slug> (PT canónico, retro-compat com bookmarks antigos)
  if (!event && evento) {
    try {
      event = await getEventBySlug(evento, 'pt')
    } catch {}
  }

  let initialCount = 0
  if (event) {
    try {
      initialCount = await getEventInscriptionCount(event.id)
    } catch {}
  }

  return (
    <InscricaoPageClient
      lang={safeLang}
      eventoId={event?.id || null}
      eventoSlug={event?.slug || null}
      eventTitle={event?.title || null}
      capacity={event?.capacity || null}
      initialInscriptionCount={initialCount}
    />
  )
}
