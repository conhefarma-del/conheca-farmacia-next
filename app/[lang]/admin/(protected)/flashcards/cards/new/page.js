import FlashcardForm from '@/components/admin/FlashcardForm'
import { getAllFlashcardDecksAdmin } from '@/lib/actions/lists'

export default async function NewFlashcardPage() {
  const decks = await getAllFlashcardDecksAdmin()
  return <FlashcardForm mode="create" decks={decks} />
}
