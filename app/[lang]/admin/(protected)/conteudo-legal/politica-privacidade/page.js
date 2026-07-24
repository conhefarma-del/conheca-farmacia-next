import { getPrivacySections } from '@/lib/actions/legalContent'
import { getCurrentRole } from '@/lib/actions/content'
import PrivacyAdminPage from '@/components/admin/PrivacyAdminPage'

export const dynamic = 'force-dynamic'

export default async function AdminPrivacyPage({ params }) {
  const { lang } = await params
  const [sections, currentUserRole] = await Promise.all([
    getPrivacySections(),
    getCurrentRole(),
  ])

  return (
    <PrivacyAdminPage
      lang={lang}
      initialSections={sections}
      currentUserRole={currentUserRole}
    />
  )
}
