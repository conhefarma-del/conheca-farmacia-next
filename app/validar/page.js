import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { refToInt, partialName, maskEmail, formatPtDate } from '@/lib/validar'
import ValidarBilhete from '@/components/pages/ValidarBilhete'
import ValidarBloqueado from '@/components/pages/ValidarBloqueado'

export const dynamic = 'force-dynamic'
export const revalidate = 0

// No caching on this route — it returns sensitive admin-only data.
export const headers = () => ({
  'Cache-Control': 'no-store, max-age=0',
  'X-Robots-Tag': 'noindex, nofollow',
})

export const metadata = {
  title: 'Validar inscrição | Conheça Farmácia',
  description:
    'Confirme a autenticidade de uma inscrição num evento da Conheça Farmácia. Acesso reservado a administradores.',
  robots: { index: false, follow: false },
}

export default async function ValidarPage({ searchParams }) {
  // SECURITY (Sentinela A.2): Auth check FIRST, ref parsing LAST.
  // Previous order parsed ?ref and called refToInt before any auth,
  // creating a timing side-channel: valid ref formats triggered
  // extra Supabase work (auth + admin check + inscription query),
  // invalid formats returned immediately. An attacker could enumerate
  // plausible IDs via timing. By doing auth + admin check first,
  // every unauthenticated or non-admin request returns the same
  // ValidarBloqueado render in roughly the same time, regardless of
  // whether the ref is well-formed.
  const supabase = await createClient()

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

  // Admin confirmed — only NOW parse and validate the ref.
  const sp = await searchParams
  const rawRef = typeof sp?.ref === 'string' ? sp.ref : null

  if (!rawRef) {
    // Admin typed /validar manually with no querystring. Return blocked
    // page (not 404) so the route is still useful.
    return <ValidarBloqueado lang="pt" />
  }

  const intRef = refToInt(rawRef)
  if (intRef === null) notFound()

  // Fetch the inscription + nested event. RLS lets the admin see all
  // rows (admins are deliberately privileged). Data is masked in the
  // helpers below before reaching the browser.
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
