import FlashcardDeckDetailPage from '@/components/admin/FlashcardDeckDetailPage'
import {
  getAllFlashcardDecksAdmin,
  getFlashcardsByDeckAdmin,
} from '@/lib/actions/lists'

export default async function FlashcardDeckDetail({ params }) {
  const { id } = await params
  const [decks, cards] = await Promise.all([
    getAllFlashcardDecksAdmin(),
    getFlashcardsByDeckAdmin(id),
  ])
  const deck = decks.find((d) => d.id === id) || null

  if (!deck) {
    return (
      <div className="admin-empty-state">
        Deck não encontrado. <a href="/pt/admin/flashcards">Voltar para os decks</a>
      </div>
    )
  }

  return <FlashcardDeckDetailPage deck={deck} cards={cards} decks={decks} />
}
