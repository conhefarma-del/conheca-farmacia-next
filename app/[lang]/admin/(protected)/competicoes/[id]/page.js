import { getCompetitionById, getCompetitionLeaderboardAdmin } from '@/lib/actions/competition'
import { getCurrentRole } from '@/lib/actions/content'
import CompetitionDetailPage from '@/components/admin/CompetitionDetailPage'
import { notFound } from 'next/navigation'

export const dynamic = 'force-dynamic'

export default async function CompetitionDetailRoute({ params }) {
  const { lang, id } = await params
  const [competition, leaderboard, currentUserRole] = await Promise.all([
    getCompetitionById(id),
    getCompetitionLeaderboardAdmin(id),
    getCurrentRole(),
  ])
  if (!competition) notFound()
  return (
    <CompetitionDetailPage
      lang={lang}
      competition={competition}
      initialLeaderboard={leaderboard}
      currentUserRole={currentUserRole}
    />
  )
}
