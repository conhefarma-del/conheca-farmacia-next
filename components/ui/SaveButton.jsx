'use client'

import { useState, useEffect, useContext } from 'react'
import { useRouter } from 'next/navigation'
import { Bookmark, BookmarkCheck, Loader2 } from 'lucide-react'
import { toggleSaveItem, isItemSaved } from '@/lib/actions/saved'
import { LangContext } from '@/lib/contexts'

/**
 * SaveButton — bookmark toggle for any saveable content.
 *
 * Props:
 *   itemType     — 'drug' | 'interaction' | 'drug_class' | 'molecular_target' | 'article'
 *   itemId       — UUID of the item
 *   itemSlug     — slug for quick link
 *   itemName     — display name (denormalized)
 *   itemSubtitle — optional subtitle
 *   itemImageUrl — optional thumbnail
 *   lang         — current language
 *   size         — 'sm' (16px) | 'md' (20px) | 'lg' (24px)
 *   className    — extra classes
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
}) {
  const { t } = useContext(LangContext)
  const [saved, setSaved] = useState(false)
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
        const result = await isItemSaved(itemType, itemId)
        if (!cancelled) setSaved(result)
      } catch {
        // silently fail — default to unsaved
      } finally {
        if (!cancelled) setLoading(false)
      }
    }
    check()
    return () => { cancelled = true }
  }, [itemType, itemId])

  const handleClick = async (e) => {
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
      }
    } catch {
      // silently fail
    } finally {
      setToggling(false)
    }
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
    <button
      type="button"
      onClick={handleClick}
      disabled={toggling}
      className={`save-button ${saved ? 'save-button--saved' : ''} ${className}`}
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
  )
}
