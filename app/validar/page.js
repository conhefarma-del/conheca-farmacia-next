import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { refToInt, partialName, maskEmail, formatPtDate } from '@/lib/validar'
import ValidarBilhete from '@/components/pages/ValidarBilhete'
import ValidarBloqueado from '@/components/pages/ValidarBloqueado'

export const dynamic = 'force-dynamic'
export const revalidate = 0

export const metadata = {
  title: 'Validar inscrição | Conheça Farmácia',
  description:
    'Confirme a autenticidade de uma inscrição num evento da Conheça Farmácia. Acesso reservado a administradores.',
  robots: { index: false, follow: false },
}

export default async function ValidarPage({ searchParams }) {
  const sp = await searchParams
  const rawRef = typeof sp?.ref === 'string' ? sp.ref : null

  // No ref provided — show the friendly blocked page so the URL itself
  // (e.g. /validar with no querystring) does not 404 for an admin who
  // typed it manually.
  if (!rawRef) {
    return <ValidarBloqueado lang="pt" />
  }

  const intRef = refToInt(rawRef)
  if (intRef === null) {
    // Invalid format — same response as missing ref, to avoid leaking
    // whether a given id exists.
    return <ValidarBloqueado lang="pt" />
  }

  const supabase = await createClient()

  // HIGH-08 / RLS-aware: check the session FIRST. We never query the
  // inscription unless the visitor is an authenticated admin — this is
  // the privacy boundary. Non-admins see the blocked page regardless of
  // whether the ref is valid.
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    return <ValidarBloqueado lang="pt" />
  }

  const { data: adminRow } = await supabase
    .from('admin_users')
    .select('role')
    .eq('user_id', user.id)
    .single()

  if (!adminRow || !['admin', 'superadmin'].includes(adminRow.role)) {
    return <ValidarBloqueado lang="pt" />
  }

  // Admin confirmed — fetch the inscription + nested event.
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
