'use client'

import { useState } from 'react'
import { StickyNote, Plus, Pencil, Trash2, Check, X, Loader2 } from 'lucide-react'

/**
 * NotesPanel — expandable list of annotations for a saved item.
 *
 * Props:
 *   savedItemId — ID of the saved item
 *   notes       — array of { id, content, created_at, updated_at }
 *   onAdd(content)        → Promise<{ success }>
 *   onUpdate(noteId, content) → Promise<{ success }>
 *   onDelete(noteId)      → Promise<{ success }>
 */
export default function NotesPanel({ savedItemId, notes, onAdd, onUpdate, onDelete }) {
  const [newContent, setNewContent] = useState('')
  const [adding, setAdding] = useState(false)
  const [editingId, setEditingId] = useState(null)
  const [editContent, setEditContent] = useState('')
  const [deletingId, setDeletingId] = useState(null)

  const handleAdd = async () => {
    if (!newContent.trim() || adding) return
    setAdding(true)
    try {
      const result = await onAdd(newContent.trim())
      if (result.success) setNewContent('')
    } finally {
      setAdding(false)
    }
  }

  const handleEdit = (note) => {
    setEditingId(note.id)
    setEditContent(note.content)
  }

  const handleSaveEdit = async (noteId) => {
    if (!editContent.trim()) return
    const result = await onUpdate(noteId, editContent.trim())
    if (result.success) {
      setEditingId(null)
      setEditContent('')
    }
  }

  const handleDelete = async (noteId) => {
    setDeletingId(noteId)
    try {
      await onDelete(noteId)
    } finally {
      setDeletingId(null)
    }
  }

  return (
    <div className="notes-panel">
      <div className="notes-panel-header">
        <StickyNote size={14} />
        <span>Anotações</span>
        <span className="notes-count">{notes.length}</span>
      </div>

      {/* Notes list */}
      {notes.length > 0 && (
        <div className="notes-list">
          {notes.map((note) => (
            <div key={note.id} className="notes-item">
              {editingId === note.id ? (
                <div className="notes-edit-row">
                  <textarea
                    value={editContent}
                    onChange={(e) => setEditContent(e.target.value)}
                    className="notes-edit-input"
                    rows={2}
                    maxLength={2000}
                    autoFocus
                  />
                  <div className="notes-edit-actions">
                    <button
                      type="button"
                      onClick={() => handleSaveEdit(note.id)}
                      className="notes-btn notes-btn-save"
                    >
                      <Check size={12} />
                    </button>
                    <button
                      type="button"
                      onClick={() => { setEditingId(null); setEditContent('') }}
                      className="notes-btn notes-btn-cancel"
                    >
                      <X size={12} />
                    </button>
                    <span className="notes-char-count">{editContent.length}/2000</span>
                  </div>
                </div>
              ) : (
                <>
                  <p className="notes-content">{note.content}</p>
                  <div className="notes-item-footer">
                    <span className="notes-date">
                      {new Date(note.created_at).toLocaleDateString('pt-PT', {
                        day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
                      })}
                    </span>
                    <div className="notes-item-actions">
                      <button
                        type="button"
                        onClick={() => handleEdit(note)}
                        className="notes-btn notes-btn-edit"
                        title="Editar"
                      >
                        <Pencil size={12} />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDelete(note.id)}
                        disabled={deletingId === note.id}
                        className="notes-btn notes-btn-delete"
                        title="Eliminar"
                      >
                        {deletingId === note.id ? (
                          <Loader2 size={12} className="animate-spin" />
                        ) : (
                          <Trash2 size={12} />
                        )}
                      </button>
                    </div>
                  </div>
                </>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Add note */}
      <div className="notes-add">
        <textarea
          value={newContent}
          onChange={(e) => setNewContent(e.target.value)}
          placeholder="Nova anotação..."
          className="notes-add-input"
          rows={2}
          maxLength={2000}
          onKeyDown={(e) => {
            if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) handleAdd()
          }}
        />
        <div className="notes-add-footer">
          <span className="notes-char-count">{newContent.length}/2000</span>
          <button
            type="button"
            onClick={handleAdd}
            disabled={!newContent.trim() || adding}
            className="notes-btn notes-btn-add"
          >
            {adding ? (
              <Loader2 size={12} className="animate-spin" />
            ) : (
              <><Plus size={12} /> Adicionar</>
            )}
          </button>
        </div>
      </div>
    </div>
  )
}
