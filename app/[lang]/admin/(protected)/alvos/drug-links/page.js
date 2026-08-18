import { getAllDrugTargetRolesAdmin, getTargetRoleCounts } from '@/lib/actions/alvos'
import { getCurrentRole } from '@/lib/actions/content'
import DrugTargetRolesAdminPage from '@/components/admin/DrugTargetRolesAdminPage'

export const dynamic = 'force-dynamic'

export default async function DrugTargetRolesAdminRoute({ params }) {
  const { lang } = await params
  const [roles, currentUserRole, counts] = await Promise.all([
    getAllDrugTargetRolesAdmin(),
    getCurrentRole(),
    getTargetRoleCounts(),
  ])

  return (
    <DrugTargetRolesAdminPage
      lang={lang}
      initialRoles={roles}
      initialDrugs={[]}
      currentUserRole={currentUserRole}
      initialCounts={counts}
    />
  )
}
