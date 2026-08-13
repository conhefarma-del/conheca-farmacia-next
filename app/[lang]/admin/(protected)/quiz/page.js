import QuizStatsPage from '@/components/admin/QuizStatsPage'
import { getQuizStats } from '@/lib/actions/quiz'

export const dynamic = 'force-dynamic'

export default async function QuizAdminPage() {
  const stats = await getQuizStats()
  return <QuizStatsPage stats={stats} />
}
