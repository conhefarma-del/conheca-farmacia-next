import { getAllFoodDimensions, getAllDiseaseDimensions, getAllPregnancyDimensions } from '@/lib/actions/interacoes'
import { getCurrentRole } from '@/lib/actions/content'
import DimensoesAdminPage from '@/components/admin/DimensoesAdminPage'

export const dynamic = 'force-dynamic'

export default async function DimensoesAdminRoute({ params }) {
  const { lang } = await params
  const [food, disease, pregnancy, currentUserRole] = await Promise.all([
    getAllFoodDimensions(),
    getAllDiseaseDimensions(),
    getAllPregnancyDimensions(),
    getCurrentRole(),
  ])
  return (
    <DimensoesAdminPage
      lang={lang}
      initialFood={food}
      initialDisease={disease}
      initialPregnancy={pregnancy}
      currentUserRole={currentUserRole}
    />
  )
}