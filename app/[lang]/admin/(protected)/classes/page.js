import ClassesAdminPage from '@/components/admin/ClassesAdminPage'
import { getAllClassesAdmin } from '@/lib/actions/classes'
import { getCurrentRole } from '@/lib/actions/content'

export const dynamic = 'force-dynamic'

export default async function ClassesAdminRoute({ params }) {
  const { lang } = await params
  const [classes, currentUserRole] = await Promise.all([
    getAllClassesAdmin(),
    getCurrentRole(),
  ])
  return (
    <ClassesAdminPage
      lang={lang}
      initialClasses={classes}
      currentUserRole={currentUserRole}
    />
  )
}
