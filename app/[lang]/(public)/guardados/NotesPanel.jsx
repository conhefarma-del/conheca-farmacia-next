'use client'

import { useState, useEffect, useContext } from 'react'
import { StickyNote, Pencil, Trash2, Check, X, Loader2 } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

/**
 * NotesPanel — painel de anotação contínua para um item guardado.
 *
 * Props:
 *   savedItemId   — ID do item guardado
 *   note          — objeto da nota { id, content, created_at, updated_at } ou null
 *   onUpsert(content)  → Promise<{ success, note }>
 *   onDelete()    → Promise<{ success }>
 */
export default function NotesPanel({ savedItemId, note, onUpsert, onDelete }) {
  const { t } = useContext(LangContext)
  const [content, setContent] = useState(note?.content || '')
  const [originalContent, setOriginalContent] = useState(note?.content || '')
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const [confirmDelete, setConfirmDelete] = useState(false)

  // Sync with external note changes
  useEffect(() => {
    setContent(note?.content || '')
    setOriginalContent(note?.content || '')
  }, [note?.content])

  const handleContentChange = (e) => {
    setContent(e.target.value)
  }

  const handleSave = async () => {
    if (content.trim() === originalContent) return
    setSaving(true)
    try {
      const result = await onUpsert(content.trim())
      if (result.success) {
        setOriginalContent(content.trim())
        setSaved(true)
        setTimeout(() => setSaved(false), 2000)
      }
    } finally {
      setSaving(false)
    }
  }

  // Auto-save on blur or Ctrl+Enter
  const handleBlur = () => {
    if (content.trim() !== originalContent) {
      handleSave()
    }
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
      handleSave()
    }
  }

  const handleDelete = async () => {
    setDeleting(true)
    try {
      await onDelete()
      setContent('')
      setOriginalContent('')
      setConfirmDelete(false)
    } finally {
      setDeleting(false)
    }
  }

  return (
    <div className="notes-panel notes-panel--single">
      <div className="notes-panel-header">
        <StickyNote size={14} />
        <span>{t('saved.notes_title')}</span>
        {saving && (
          <span className="notes-save-status">
            <Loader2 size={10} className="animate-spin" />
          </span>
        )}
        {saved && (
          <span className="notes-save-status notes-save-status--saved">
            <Check size={10} />
            {t('notes_drawer.saved')}
          </span>
        )}
      </div>

      {/* Single note textarea */}
      <div className="notes-single">
        <textarea
          value={content}
          onChange={handleContentChange}
          onBlur={handleBlur}
          onKeyDown={handleKeyDown}
          placeholder={t('saved.notes_add_placeholder')}
          className="notes-single-input"
          rows={3}
          maxLength={5000}
        />
        <div className="notes-single-footer">
          <span className="notes-char-count">{content.length}/5000</span>
          <div className="notes-single-actions">
            {content.trim() !== originalContent && (
              <button
                type="button"
                onClick={handleSave}
                disabled={saving}
                className="notes-btn notes-btn-save"
              >
                {saving ? (
                  <Loader2 size={12} className="animate-spin" />
                ) : (
                  <Check size={12} />
                )}
                {t('notes_page.save')}
              </button>
            )}
            {content.trim() && !confirmDelete && (
              <button
                type="button"
                onClick={() => setConfirmDelete(true)}
                className="notes-btn notes-btn-delete"
                title={t('notes_page.delete')}
              >
                <Trash2 size={12} />
              </button>
            )}
            {confirmDelete && (
              <div className="notes-confirm-delete">
                <span>{t('notes_page.confirm_delete')}</span>
                <button
                  type="button"
                  onClick={handleDelete}
                  disabled={deleting}
                  className="notes-btn notes-btn-delete--confirm"
                >
                  {deleting ? <Loader2 size={10} className="animate-spin" /> : <Check size={10} />}
                </button>
                <button
                  type="button"
                  onClick={() => setConfirmDelete(false)}
                  className="notes-btn notes-btn-cancel"
                >
                  <X size={10} />
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
