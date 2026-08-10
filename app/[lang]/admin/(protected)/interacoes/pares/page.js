import { getAllDrugs, getAllDrugInteractions } from '@/lib/actions/interacoes'
import { getCurrentRole } from '@/lib/actions/content'
import ParesAdminPage from '@/components/admin/ParesAdminPage'

export const dynamic = 'force-dynamic'

export default async function ParesAdminRoute({ params }) {
  const { lang } = await params
  const [drugs, interactions, currentUserRole] = await Promise.all([
    getAllDrugs(),
    getAllDrugInteractions(),
    getCurrentRole(),
  ])
  return (
    <ParesAdminPage
      lang={lang}
      initialDrugs={drugs}
      initialInteractions={interactions}
      currentUserRole={currentUserRole}
    />
  )
}
