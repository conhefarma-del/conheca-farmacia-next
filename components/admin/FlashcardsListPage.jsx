'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { Plus, Pencil, Trash2, Archive, ArchiveRestore, Layers } from 'lucide-react'
import {
  deleteFlashcardDeck,
  archiveFlashcardDeck,
} from '@/lib/actions/flashcards'
import ConfirmModal from '@/components/admin/ConfirmModal'

/**
 * FlashcardsListPage — listagem admin dos decks de flashcards.
 * Tabela com nome, prefixo ATC, cartões (publicados/total), estado e ações.
 */
export default function FlashcardsListPage({ decks = [], stats, currentUserRole }) {
  const router = useRouter()
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [confirmDelete, setConfirmDelete] = useState(null)

  const isSuper = currentUserRole === 'superadmin'

  const handleArchive = async (id, archived) => {
    setBusy(true)
    setError('')
    try {
      const res = await archiveFlashcardDeck(id)
      if (!res.ok) setError(res.error)
      router.refresh()
    } catch {
      setError('Erro ao arquivar deck.')
    } finally {
      setBusy(false)
    }
  }

  const handleDelete = async () => {
    if (!confirmDelete) return
    setBusy(true)
    setError('')
    try {
      const res = await deleteFlashcardDeck(confirmDelete.id)
      if (!res.ok) setError(res.error)
      setConfirmDelete(null)
      router.refresh()
    } catch {
      setError('Erro ao eliminar deck.')
    } finally {
      setBusy(false)
    }
  }

  return (
    <div>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Flashcards</h1>
        <p className="admin-page-subtitle">Decks de repetição espaçada ligados ao banco de Medicamentos</p>
      </div>

      {/* Stats */}
      <div className="admin-stats-grid">
        <div className="admin-stat-card">
          <div className="admin-stat-value">{stats?.decks ?? 0}</div>
          <div className="admin-stat-label">Decks</div>
        </div>
        <div className="admin-stat-card">
          <div className="admin-stat-value">{stats?.publishedDecks ?? 0}</div>
          <div className="admin-stat-label">Publicados</div>
        </div>
        <div className="admin-stat-card">
          <div className="admin-stat-value">{stats?.cards ?? 0}</div>
          <div className="admin-stat-label">Cartões</div>
        </div>
        <div className="admin-stat-card">
          <div className="admin-stat-value">{stats?.publishedCards ?? 0}</div>
          <div className="admin-stat-label">Cartões publicados</div>
        </div>
      </div>

      {error && <div className="admin-form-error">{error}</div>}

      <div className="admin-toolbar">
        <Link href="/pt/admin/flashcards/decks/new" className="admin-btn admin-btn-primary">
          <Plus size={16} /> Novo Deck
        </Link>
      </div>

      {decks.length === 0 ? (
        <div className="admin-empty-state">Sem decks ainda. Cria o primeiro deck de flashcards.</div>
      ) : (
        <div className="admin-table-wrap">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Deck</th>
                <th>ATC</th>
                <th>Cartões</th>
                <th>Estado</th>
                <th className="admin-table-actions">Ações</th>
              </tr>
            </thead>
            <tbody>
              {decks.map((deck) => (
                <tr key={deck.id} className={deck.is_archived ? 'is-archived' : ''}>
                  <td>
                    <Link href={`/pt/admin/flashcards/decks/${deck.id}`} className="admin-table-link">
                      <span className="deck-color-dot" style={{ background: deck.color }} />
                      {deck.name_pt}
                    </Link>
                    {deck.atc_prefix && <span className="admin-badge admin-badge-muted">{deck.atc_prefix}</span>}
                  </td>
                  <td>{deck.atc_prefix || '—'}</td>
                  <td>
                    {deck.publishedCount}/{deck.cardCount}
                  </td>
                  <td>
                    <span className={`admin-badge ${deck.status === 'published' ? 'admin-badge-success' : 'admin-badge-warning'}`}>
                      {deck.status === 'published' ? 'Publicado' : 'Rascunho'}
                    </span>
                    {deck.is_archived && <span className="admin-badge admin-badge-danger">Arquivado</span>}
                  </td>
                  <td className="admin-table-actions">
                    <div className="admin-row-actions">
                      <Link
                        href={`/pt/admin/flashcards/decks/${deck.id}`}
                        className="admin-icon-btn"
                        title="Editar"
                      >
                        <Pencil size={15} />
                      </Link>
                      <button
                        className="admin-icon-btn"
                        title={deck.is_archived ? 'Restaurar' : 'Arquivar'}
                        disabled={busy}
                        onClick={() => handleArchive(deck.id, deck.is_archived)}
                      >
                        {deck.is_archived ? <ArchiveRestore size={15} /> : <Archive size={15} />}
                      </button>
                      {isSuper && (
                        <button
                          className="admin-icon-btn admin-icon-danger"
                          title="Eliminar"
                          disabled={busy}
                          onClick={() => setConfirmDelete(deck)}
                        >
                          <Trash2 size={15} />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {!isSuper && (
        <p className="admin-note" style={{ marginTop: 14, fontSize: 12, opacity: 0.6 }}>
          <Layers size={13} /> Eliminar decks é exclusivo de superadmin — usa arquivar.
        </p>
      )}

      <ConfirmModal
        open={!!confirmDelete}
        title="Eliminar deck"
        message={`Eliminar o deck "${confirmDelete?.name_pt}"? Esta ação não pode ser revertida.`}
        confirmLabel="Eliminar"
        danger
        onConfirm={handleDelete}
        onClose={() => setConfirmDelete(null)}
      />
    </div>
  )
}
