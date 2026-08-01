import { getAllProtocolCategories, getAllClinicalProtocols } from '@/lib/actions/protocolos'
import { getCurrentRole } from '@/lib/actions/content'
import ProtocolsAdminPage from '@/components/admin/ProtocolsAdminPage'

export const dynamic = 'force-dynamic'

export default async function ProtocolsAdminRoute({ params }) {
  const { lang } = await params
  const [categories, protocols, currentUserRole] = await Promise.all([
    getAllProtocolCategories(),
    getAllClinicalProtocols(),
    getCurrentRole(),
  ])
  return (
    <ProtocolsAdminPage
      lang={lang}
      initialCategories={categories}
      initialProtocols={protocols}
      currentUserRole={currentUserRole}
    />
  )
}
