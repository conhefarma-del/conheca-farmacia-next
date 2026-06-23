import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { refToInt, partialName, maskEmail, formatPtDate } from '@/lib/validar'
import ValidarBilhete from '@/components/pages/ValidarBilhete'

export const dynamic = 'force-dynamic'
export const revalidate = 0

// PT-only metadata (page itself lives outside [lang] segment because the
// QR code points to /validar/<ref> without a language prefix).
export const metadata = {
  title: 'Validar inscrição | Conheça Farmácia',
  description:
    'Confirme a autenticidade de uma inscrição num evento da Conheça Farmácia.',
  robots: { index: false, follow: false },
}

export default async function ValidarPage({ params }) {
  const { ref } = await params

  const intRef = refToInt(ref)
  if (intRef === null) notFound()

  const supabase = await createClient()

  // Fetch inscription + nested event. We deliberately use anon client
  // (no service role) and RLS allows SELECT on inscricoes by anyone —
  // the returned data is already masked in the helpers below before
  // reaching the browser.
  const { data: inscription, error } = await supabase
    .from('inscricoes')
    .select(
      `
        id,
        nome,
        email,
        created_at,
        events:evento_id ( id, slug, title, date, time, location, type )
      `
    )
    .eq('id', intRef)
    .single()

  if (error || !inscription) notFound()

  const safe = {
    ref: String(inscription.id).padStart(6, '0'),
    attendeePartial: partialName(inscription.nome),
    attendeeEmailMasked: maskEmail(inscription.email),
    issuedAt: formatPtDate(inscription.created_at),
    event: inscription.events
      ? {
          title: inscription.events.title,
          date: inscription.events.date,
          time: inscription.events.time,
          location: inscription.events.location,
        }
      : null,
  }

  return <ValidarBilhete data={safe} />
}
