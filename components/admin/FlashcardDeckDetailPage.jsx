'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Plus, Pencil, Trash2, Archive, ArchiveRestore } from 'lucide-react'
import FlashcardDeckForm from '@/components/admin/FlashcardDeckForm'
import { archiveFlashcard, deleteFlashcard } from '@/lib/actions/flashcards'
import ConfirmModal from '@/components/admin/ConfirmModal'

const TYPE_LABELS = {
  mecanismo: 'Mecanismo',
  classe: 'Classe',
  perfil: 'Perfil',
  interacao: 'Interação',
  manual: 'Manual',
}

/**
 * FlashcardDeckDetailPage — form do deck + tabela dos cartões do deck,
 * com adicionar/editar/arquivar/eliminar por cartão.
 */
export default function FlashcardDeckDetailPage({ deck, cards = [], decks = [] }) {
  const router = useRouter()
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [confirmDelete, setConfirmDelete] = useState(null)

  const handleArchive = async (id) => {
    setBusy(true)
    setError('')
    try {
      const res = await archiveFlashcard(id)
      if (!res.ok) setError(res.error)
      router.refresh()
    } catch {
      setError('Erro ao arquivar cartão.')
    } finally {
      setBusy(false)
    }
  }

  const handleDelete = async () => {
    if (!confirmDelete) return
    setBusy(true)
    setError('')
    try {
      const res = await deleteFlashcard(confirmDelete.id)
      if (!res.ok) setError(res.error)
      setConfirmDelete(null)
      router.refresh()
    } catch {
      setError('Erro ao eliminar cartão.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div>
      <FlashcardDeckForm mode="edit" initialData={deck} />

      <div className="admin-section-divider" />

      <div className="admin-page-header">
        <h2 className="admin-page-title" style={{ fontSize: 18 }}>Cartões do deck</h2>
        <p className="admin-page-subtitle">
          {cards.filter((c) => c.status === 'published' && !c.is_archived).length} publicados ·{' '}
          {cards.length} total
        </p>
      </div>

      <div className="admin-toolbar">
        <Link
          href={`/pt/admin/flashcards/cards/new?deck=${deck.id}`}
          className="admin-btn admin-btn-primary"
        >
          <Plus size={16} /> Adicionar Cartão
        </Link>
      </div>

      {error && <div className="admin-form-error">{error}</div>}

      {cards.length === 0 ? (
        <div className="admin-empty-state">
          Sem cartões neste deck ainda. Usa "Adicionar Cartão" e o botão de geração a partir de um
          fármaco.
        </div>
      ) : (
        <div className="admin-table-wrap">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Tipo</th>
                <th>Frente</th>
                <th>Estado</th>
                <th className="admin-table-actions">Ações</th>
              </tr>
            </thead>
            <tbody>
              {cards.map((card) => (
                <tr key={card.id} className={card.is_archived ? 'is-archived' : ''}>
                  <td>
                    <span className="admin-badge admin-badge-muted">{TYPE_LABELS[card.card_type] || card.card_type}</span>
                  </td>
                  <td>
                    <Link href={`/pt/admin/flashcards/cards/${card.id}`} className="admin-table-link">
                      {card.front_pt.slice(0, 80)}
                      {card.front_pt.length > 80 ? '…' : ''}
                    </Link>
                  </td>
                  <td>
                    <span className={`admin-badge ${card.status === 'published' ? 'admin-badge-success' : 'admin-badge-warning'}`}>
                      {card.status === 'published' ? 'Publicado' : 'Rascunho'}
                    </span>
                    {card.is_archived && <span className="admin-badge admin-badge-danger">Arquivado</span>}
                  </td>
                  <td className="admin-table-actions">
                    <div className="admin-row-actions">
                      <Link
                        href={`/pt/admin/flashcards/cards/${card.id}`}
                        className="admin-icon-btn"
                        title="Editar"
                      >
                        <Pencil size={15} />
                      </Link>
                      <button
                        className="admin-icon-btn"
                        title={card.is_archived ? 'Restaurar' : 'Arquivar'}
                        disabled={busy}
                        onClick={() => handleArchive(card.id)}
                      >
                        {card.is_archived ? <ArchiveRestore size={15} /> : <Archive size={15} />}
                      </button>
                      <button
                        className="admin-icon-btn admin-icon-danger"
                        title="Eliminar"
                        disabled={busy}
                        onClick={() => setConfirmDelete(card)}
                      >
                        <Trash2 size={15} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <ConfirmModal
        open={!!confirmDelete}
        title="Eliminar cartão"
        message="Eliminar este cartão? Esta ação não pode ser revertida (os progressos associados são apagados)."
        confirmLabel="Eliminar"
        danger
        onConfirm={handleDelete}
        onClose={() => setConfirmDelete(null)}
      />
    </div>
  )
}
