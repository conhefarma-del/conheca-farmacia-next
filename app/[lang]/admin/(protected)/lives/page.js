import LivesListPage from '@/components/admin/LivesListPage'
import { getAllLivesAdmin, getLiveStats, getTopLives } from '@/lib/actions/lists'

/**
 * Lives List Page — Server Component (puro)
 */

export default async function LivesPage() {
  const [lives, stats, topLives] = await Promise.all([
    getAllLivesAdmin(),
    getLiveStats(),
    getTopLives('views', 3),
  ])

  return (
    <LivesListPage
      lives={lives}
      stats={stats}
      topLives={topLives}
    />
  )
}
