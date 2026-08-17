import { getAllTargetsAdmin } from '@/lib/actions/alvos'
import { getCurrentRole } from '@/lib/actions/content'
import AlvosAdminPage from '@/components/admin/AlvosAdminPage'

export const dynamic = 'force-dynamic'

export default async function AlvosAdminRoute({ params }) {
  const { lang } = await params
  const [targets, currentUserRole] = await Promise.all([
    getAllTargetsAdmin(),
    getCurrentRole(),
  ])
  return (
    <AlvosAdminPage
      lang={lang}
      initialTargets={targets}
      currentUserRole={currentUserRole}
    />
  )
}
