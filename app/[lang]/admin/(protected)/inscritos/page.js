import { getInscricoesAdmin, getAllEventsForFilter } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/content'
import InscritosListPage from '@/components/admin/InscritosListPage'

export const dynamic = 'force-dynamic'

const PAGE_SIZE = 25

export default async function InscritosPage({ params, searchParams }) {
  const { lang } = await params
  const sp = (await searchParams) || {}

  const page = Math.max(1, Number.parseInt(sp.page || '1', 10) || 1)
  const q = typeof sp.q === 'string' ? sp.q : ''
  const eventoId = typeof sp.evento === 'string' ? sp.evento : ''

  const [{ rows, total }, eventos, currentUserRole] = await Promise.all([
    getInscricoesAdmin({ page, pageSize: PAGE_SIZE, q, eventoId }),
    getAllEventsForFilter(),
    getCurrentRole(),
  ])

  return (
    <InscritosListPage
      lang={lang}
      inscricoes={rows}
      total={total}
      page={page}
      pageSize={PAGE_SIZE}
      busca={q}
      filtroEvento={eventoId}
      eventos={eventos}
      currentUserRole={currentUserRole}
    />
  )
}
