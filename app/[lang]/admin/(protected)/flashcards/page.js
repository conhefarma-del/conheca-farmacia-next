import FlashcardsListPage from '@/components/admin/FlashcardsListPage'
import { getAllFlashcardDecksAdmin, getFlashcardStats } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/content'

export default async function FlashcardsAdminPage() {
  const [decks, stats, currentUserRole] = await Promise.all([
    getAllFlashcardDecksAdmin(),
    getFlashcardStats(),
    getCurrentRole(),
  ])

  return <FlashcardsListPage decks={decks} stats={stats} currentUserRole={currentUserRole} />
}
