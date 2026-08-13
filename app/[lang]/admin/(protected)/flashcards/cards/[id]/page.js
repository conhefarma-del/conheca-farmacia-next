import FlashcardForm from '@/components/admin/FlashcardForm'
import { getAllFlashcardDecksAdmin, getFlashcardCardByIdAdmin } from '@/lib/actions/lists'

export default async function EditFlashcardPage({ params }) {
  const { id } = await params
  const [decks, card] = await Promise.all([
    getAllFlashcardDecksAdmin(),
    getFlashcardCardByIdAdmin(id),
  ])

  if (!card) {
    return (
      <div className="admin-empty-state">
        Cartão não encontrado. <a href="/pt/admin/flashcards">Voltar para os decks</a>
      </div>
    )
  }

  return <FlashcardForm mode="edit" decks={decks} initialData={card} />
}
