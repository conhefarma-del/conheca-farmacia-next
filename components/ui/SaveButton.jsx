'use client'

import { useState, useEffect, useContext } from 'react'
import { useRouter } from 'next/navigation'
import { Bookmark, BookmarkCheck, Pencil, Loader2 } from 'lucide-react'
import { toggleSaveItem, isItemSaved, hasNoteForItem } from '@/lib/actions/saved'
import { LangContext } from '@/lib/contexts'

/**
 * SaveButton — bookmark toggle + notes button for any saveable content.
 *
 * Props:
 *   itemType       — 'drug' | 'interaction' | 'drug_class' | 'molecular_target' | 'article'
 *   itemId         — UUID of the item
 *   itemSlug       — slug for quick link
 *   itemName       — display name (denormalized)
 *   itemSubtitle   — optional subtitle
 *   itemImageUrl   — optional thumbnail
 *   lang           — current language
 *   size           — 'sm' (16px) | 'md' (20px) | 'lg' (24px)
 *   className      — extra classes
 *   onNotesClick   — () => void (abre o NotesDrawer)
 *   showNotesBtn   — boolean (mostrar botão de notas)
 */
export default function SaveButton({
  itemType,
  itemId,
  itemSlug,
  itemName,
  itemSubtitle,
  itemImageUrl,
  lang = 'pt',
  size = 'md',
  className = '',
  onNotesClick,
  showNotesBtn = false,
}) {
  const { t } = useContext(LangContext)
  const [saved, setSaved] = useState(false)
  const [hasNote, setHasNote] = useState(false)
  const [loading, setLoading] = useState(true)
  const [toggling, setToggling] = useState(false)
  const router = useRouter()

  const sizeMap = { sm: 16, md: 20, lg: 24 }
  const iconSize = sizeMap[size] || 20

  // Check initial state
  useEffect(() => {
    let cancelled = false
    async function check() {
      try {
        const [isSaved, noteExists] = await Promise.all([
          isItemSaved(itemType, itemId),
          showNotesBtn ? hasNoteForItem(itemId) : Promise.resolve(false),
        ])
        if (!cancelled) {
          setSaved(isSaved)
          setHasNote(noteExists)
        }
      } catch {
        // silently fail — default to unsaved
      } finally {
        if (!cancelled) setLoading(false)
      }
    }
    check()
    return () => { cancelled = true }
  }, [itemType, itemId, showNotesBtn])

  const handleSaveClick = async (e) => {
    e.preventDefault()
    e.stopPropagation()

    if (toggling) return

    setToggling(true)
    try {
      const result = await toggleSaveItem({
        itemType,
        itemId,
        itemSlug,
        itemName,
        itemSubtitle,
        itemImageUrl,
      })

      if (result.error === 'auth_required') {
        router.push(`/${lang}/entrar`)
        return
      }

      if (result.success) {
        setSaved(result.saved)
        // Se guardou, verificar se tem nota
        if (result.saved) {
          const noteExists = await hasNoteForItem(itemId)
          setHasNote(noteExists)
        }
      }
    } catch {
      // silently fail
    } finally {
      setToggling(false)
    }
  }

  const handleNotesClick = (e) => {
    e.preventDefault()
    e.stopPropagation()
    if (!saved) {
      // Show warning that item needs to be saved first
      alert(t('saved.login_required') || 'Guarda o item primeiro para adicionar notas')
      return
    }
    if (onNotesClick) onNotesClick()
  }

  if (loading) {
    return (
      <span
        className={`inline-flex items-center justify-center ${className}`}
        style={{ width: iconSize + 8, height: iconSize + 8 }}
      >
        <Loader2 size={iconSize - 4} className="animate-spin opacity-30" />
      </span>
    )
  }

  return (
    <div className={`save-button-group ${className}`}>
      {/* Botão Guardar */}
      <button
        type="button"
        onClick={handleSaveClick}
        disabled={toggling}
        className={`save-button ${saved ? 'save-button--saved' : ''}`}
        title={saved ? (t('saved.unsave') || 'Remover dos guardados') : (t('saved.save') || 'Guardar')}
        aria-label={saved ? (t('saved.unsave') || 'Remover dos guardados') : (t('saved.save') || 'Guardar')}
        aria-pressed={saved}
      >
        {toggling ? (
          <Loader2 size={iconSize} className="animate-spin" />
        ) : saved ? (
          <BookmarkCheck size={iconSize} />
        ) : (
          <Bookmark size={iconSize} />
        )}
      </button>

      {/* Botão Notas */}
      {showNotesBtn && (
        <button
          type="button"
          onClick={handleNotesClick}
          className={`save-notes-button ${hasNote ? 'save-notes-button--has-note' : ''} ${!saved ? 'save-notes-button--disabled' : ''}`}
          title={saved ? t('notes_drawer.title', { name: itemName }) : (t('notes_drawer.save_first') || 'Guarda primeiro para adicionar notas')}
          aria-label={saved ? t('notes_drawer.title', { name: itemName }) : (t('notes_drawer.save_first') || 'Guarda primeiro para adicionar notas')}
        >
          <Pencil size={iconSize - 2} />
        </button>
      )}
    </div>
  )
}
