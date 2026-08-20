import { getAllCompetitionsAdmin } from '@/lib/actions/competition'
import { getCurrentRole } from '@/lib/actions/content'
import CompetitionsAdminPage from '@/components/admin/CompetitionsAdminPage'

export const dynamic = 'force-dynamic'

export default async function CompetitionsAdminRoute({ params }) {
  const { lang } = await params
  const [competitions, currentUserRole] = await Promise.all([
    getAllCompetitionsAdmin(),
    getCurrentRole(),
  ])
  return (
    <CompetitionsAdminPage
      lang={lang}
      initialCompetitions={competitions}
      currentUserRole={currentUserRole}
    />
  )
}
