import { getTermsSections } from '@/lib/actions/legalContent'
import { getCurrentRole } from '@/lib/actions/content'
import TermosAdminPage from '@/components/admin/TermosAdminPage'

export const dynamic = 'force-dynamic'

export default async function AdminTermosPage({ params }) {
  const { lang } = await params
  const [sections, currentUserRole] = await Promise.all([
    getTermsSections(),
    getCurrentRole(),
  ])

  return (
    <TermosAdminPage
      lang={lang}
      initialSections={sections}
      currentUserRole={currentUserRole}
    />
  )
}
