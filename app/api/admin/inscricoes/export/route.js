import { getAdminSession } from '@/lib/admin-guard'
import { createAdminClient } from '@/lib/supabase/admin'

export const dynamic = 'force-dynamic'

/** Célula CSV segura: aspas duplicadas e neutralização de fórmulas. */
function csvCell(value) {
  const raw = value == null ? '' : String(value)
  const safe = /^[=+\-@]/.test(raw) ? `'${raw}` : raw
  return `"${safe.replace(/"/g, '""')}"`
}

function sanitizeSearch(term) {
  return String(term || '').replace(/[,()."\\%_]/g, ' ').trim().slice(0, 80)
}

export async function GET(request) {
  const session = await getAdminSession()
  if (!session) {
    return new Response('Não autorizado', { status: 401 })
  }

  const { searchParams } = new URL(request.url)
  const eventoId = searchParams.get('evento') || ''
  const term = sanitizeSearch(searchParams.get('q'))

  const admin = createAdminClient()
  let query = admin
    .from('inscricoes')
    .select('id, nome, email, telefone, profissao, created_at, compareceu, status, evento:events(title)')
    .order('created_at', { ascending: false })
    .limit(5000)

  if (eventoId) query = query.eq('evento_id', eventoId)
  if (term) query = query.or(`nome.ilike.%${term}%,email.ilike.%${term}%`)

  const { data, error } = await query
  if (error) {
    return new Response('Erro ao exportar inscrições', { status: 500 })
  }

  const header = [
    'id', 'nome', 'email', 'telefone', 'profissao',
    'evento', 'data_inscricao', 'compareceu', 'estado',
  ]

  const rows = (data || []).map((row) => [
    row.id,
    row.nome,
    row.email,
    row.telefone,
    row.profissao,
    row.evento?.title || '',
    row.created_at,
    row.compareceu ? 'sim' : 'não',
    row.status || 'confirmada',
  ])

  const csv = [header, ...rows]
    .map((line) => line.map(csvCell).join(','))
    .join('\r\n')

  return new Response(`\uFEFF${csv}`, {
    headers: {
      'Content-Type': 'text/csv; charset=utf-8',
      'Content-Disposition': `attachment; filename="inscricoes-${new Date().toISOString().slice(0, 10)}.csv"`,
      'Cache-Control': 'no-store',
    },
  })
}
