import { getAllDrugs, getAllDrugInteractions } from '@/lib/actions/interacoes'
import { getCurrentRole } from '@/lib/actions/content'
import FarmacosAdminPage from '@/components/admin/FarmacosAdminPage'

export const dynamic = 'force-dynamic'

export default async function FarmacosAdminRoute({ params }) {
  const { lang } = await params
  const [drugs, interactions, currentUserRole] = await Promise.all([
    getAllDrugs(),
    getAllDrugInteractions(),
    getCurrentRole(),
  ])
  return (
    <FarmacosAdminPage
      lang={lang}
      initialDrugs={drugs}
      initialInteractions={interactions}
      currentUserRole={currentUserRole}
    />
  )
}
