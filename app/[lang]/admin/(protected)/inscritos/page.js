import { getAllInscricoesAdmin, getAllEventsForFilter } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/content'
import InscritosListPage from '@/components/admin/InscritosListPage'

export const dynamic = 'force-dynamic'

export default async function InscritosPage({ params }) {
  const { lang } = await params

  const [inscricoes, eventos, currentUserRole] = await Promise.all([
    getAllInscricoesAdmin(),
    getAllEventsForFilter(),
    getCurrentRole(),
  ])

  return (
    <InscritosListPage
      lang={lang}
      inscricoes={inscricoes}
      eventos={eventos}
      currentUserRole={currentUserRole}
    />
  )
}
