import { createAdminClient } from '@/lib/supabase/admin'

export const dynamic = 'force-dynamic'

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

/**
 * Contagem pública de inscrições confirmadas de um evento.
 *
 * Só devolve um número — nunca PII. O cache curto evita que cada visitante
 * dispare uma Server Action a cada 30 s. O polling do cliente usa esta rota.
 */
export async function GET(_request, { params }) {
  const { id } = await params

  if (!UUID_REGEX.test(id)) {
    return Response.json({ error: 'invalid_event_id' }, { status: 400 })
  }

  const admin = createAdminClient()
  const { count, error } = await admin
    .from('inscricoes')
    .select('id', { count: 'exact', head: true })
    .eq('evento_id', id)
    .eq('status', 'confirmada')

  if (error) {
    return Response.json({ error: 'count_failed' }, { status: 500 })
  }

  return Response.json(
    { count: count || 0 },
    {
      headers: {
        'Cache-Control': 'public, s-maxage=10, stale-while-revalidate=30',
      },
    }
  )
}
