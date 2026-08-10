import { getAllDrugs, getAllFoodDimensions, getAllDiseaseDimensions, getAllPregnancyDimensions } from '@/lib/actions/interacoes'
import { getCurrentRole } from '@/lib/actions/content'
import DimensoesAdminPage from '@/components/admin/DimensoesAdminPage'

export const dynamic = 'force-dynamic'

export default async function DimensoesAdminRoute({ params }) {
  const { lang } = await params
  const [drugs, food, disease, pregnancy, currentUserRole] = await Promise.all([
    getAllDrugs(),
    getAllFoodDimensions(),
    getAllDiseaseDimensions(),
    getAllPregnancyDimensions(),
    getCurrentRole(),
  ])
  return (
    <DimensoesAdminPage
      lang={lang}
      initialDrugs={drugs}
      initialFood={food}
      initialDisease={disease}
      initialPregnancy={pregnancy}
      currentUserRole={currentUserRole}
    />
  )
}