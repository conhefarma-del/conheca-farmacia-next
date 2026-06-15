import LivesListPage from '@/components/admin/LivesListPage'
import { getAllLivesAdmin, getLiveStats, getTopLives } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/content'

/**
 * Lives List Page — Server Component (puro)
 * Phase 4 (2026-06-15): passa currentUserRole para condicionar visibilidade de botões.
 */

export default async function LivesPage() {
  const [lives, stats, topLives, currentUserRole] = await Promise.all([
    getAllLivesAdmin(),
    getLiveStats(),
    getTopLives('views', 3),
    getCurrentRole(),
  ])

  return (
    <LivesListPage
      lives={lives}
      stats={stats}
      topLives={topLives}
      currentUserRole={currentUserRole}
    />
  )
}
