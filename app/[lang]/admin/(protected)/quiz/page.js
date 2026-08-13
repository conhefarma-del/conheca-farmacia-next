import QuizStatsPage from '@/components/admin/QuizStatsPage'
import { getQuizStats, getQuizPoolCountsAdmin } from '@/lib/actions/quiz'

export const dynamic = 'force-dynamic'

export default async function QuizAdminPage() {
  const [stats, poolCounts] = await Promise.all([getQuizStats(), getQuizPoolCountsAdmin()])
  return <QuizStatsPage stats={stats} poolCounts={poolCounts} />
}
