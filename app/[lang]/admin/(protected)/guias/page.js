import { getAllGuideCourses } from '@/lib/actions/guides'
import { getCurrentRole } from '@/lib/actions/content'
import GuidesAdminPage from '@/components/admin/GuidesAdminPage'

export const dynamic = 'force-dynamic'

export default async function AdminGuiasPage({ params }) {
  const { lang } = await params
  const [courses, currentUserRole] = await Promise.all([
    getAllGuideCourses(),
    getCurrentRole(),
  ])

  return (
    <GuidesAdminPage
      lang={lang}
      initialCourses={courses}
      currentUserRole={currentUserRole}
    />
  )
}
