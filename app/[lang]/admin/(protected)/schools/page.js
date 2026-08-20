import { getAllSchoolsAdmin } from '@/lib/actions/competition'
import { getCurrentRole } from '@/lib/actions/content'
import SchoolsAdminPage from '@/components/admin/SchoolsAdminPage'

export const dynamic = 'force-dynamic'

export default async function SchoolsAdminRoute({ params }) {
  const { lang } = await params
  const [schools, currentUserRole] = await Promise.all([
    getAllSchoolsAdmin(),
    getCurrentRole(),
  ])
  return (
    <SchoolsAdminPage
      lang={lang}
      initialSchools={schools}
      currentUserRole={currentUserRole}
    />
  )
}
