import { getAllDrugs, getAllDrugInteractions } from '@/lib/actions/interacoes'
import { getCurrentRole } from '@/lib/actions/content'
import InteracoesAdminPage from '@/components/admin/InteracoesAdminPage'

export const dynamic = 'force-dynamic'

export default async function InteracoesAdminRoute({ params }) {
  const { lang } = await params
  const [drugs, interactions, currentUserRole] = await Promise.all([
    getAllDrugs(),
    getAllDrugInteractions(),
    getCurrentRole(),
  ])
  return (
    <InteracoesAdminPage
      lang={lang}
      initialDrugs={drugs}
      initialInteractions={interactions}
      currentUserRole={currentUserRole}
    />
  )
}
