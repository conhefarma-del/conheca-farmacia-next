import InterviewsListPage from '@/components/admin/InterviewsListPage'
import { getAllInterviewsAdmin, getInterviewStats } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/content'

export default async function InterviewsAdminPage() {
  const [interviews, stats, currentUserRole] = await Promise.all([
    getAllInterviewsAdmin(),
    getInterviewStats(),
    getCurrentRole(),
  ])

  return (
    <InterviewsListPage
      interviews={interviews}
      stats={stats}
      currentUserRole={currentUserRole}
    />
  )
}
