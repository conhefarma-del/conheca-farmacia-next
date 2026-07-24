import { getFAQTabs } from '@/lib/actions/legalContent'
import { getCurrentRole } from '@/lib/actions/content'
import FAQAdminPage from '@/components/admin/FAQAdminPage'

export const dynamic = 'force-dynamic'

export default async function AdminFAQPage({ params }) {
  const { lang } = await params
  const [tabs, currentUserRole] = await Promise.all([
    getFAQTabs(),
    getCurrentRole(),
  ])

  return (
    <FAQAdminPage
      lang={lang}
      initialTabs={tabs}
      currentUserRole={currentUserRole}
    />
  )
}
