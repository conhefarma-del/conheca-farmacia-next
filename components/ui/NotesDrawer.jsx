'use client'

import { useState, useEffect, useCallback, useRef, useContext } from 'react'
import { useRouter } from 'next/navigation'
import {
  ChevronUp, ChevronDown, X, ExternalLink, Loader2, Check
} from 'lucide-react'
import { getNoteForItem, upsertNote } from '@/lib/actions/saved'
import { LangContext } from '@/lib/contexts'

const AUTO_SAVE_DELAY = 1500 // 1.5s debounce

const TYPE_LINKS = {
  drug: (lang, slug) => `/${lang}/medicamentos/${slug}`,
  interaction: (lang, slug) => `/${lang}/interacoes`,
  drug_class: (lang, slug) => `/${lang}/classes/${slug}`,
  molecular_target: (lang, slug) => `/${lang}/alvos/${slug}`,
  article: (lang, slug) => `/${lang}/artigos/${slug}`,
}

const TYPE_LABELS = {
  drug: 'Medicamento',
  interaction: 'Interação',
  drug_class: 'Classe',
  molecular_target: 'Alvo',
  article: 'Artigo',
}

/**
 * NotesDrawer — bottom sheet (mobile) + sidebar (desktop) para notas contínuas.
 *
 * Props:
 *   isOpen      — boolean
 *   onClose     — () => void
 *   savedItemId — UUID do item guardado
 *   itemName    — nome do item
 *   itemSlug    — slug do item
 *   itemType    — tipo do item
 *   lang        — idioma atual
 */
export default function NotesDrawer({
  isOpen,
  onClose,
  savedItemId,
  itemName,
  itemSlug,
  itemType,
  lang = 'pt',
}) {
  const { t } = useContext(LangContext)
  const router = useRouter()

  const [collapsed, setCollapsed] = useState(true)
  const [content, setContent] = useState('')
  const [originalContent, setOriginalContent] = useState('')
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)
  const [loading, setLoading] = useState(true)
  const [isMobile, setIsMobile] = useState(false)

  const textareaRef = useRef(null)
  const drawerRef = useRef(null)
  const saveTimerRef = useRef(null)
  const dragStartY = useRef(0)
  const dragCurrentY = useRef(0)
  const scrollYRef = useRef(0)

  // Detectar mobile
  useEffect(() => {
    const check = () => setIsMobile(window.innerWidth < 768)
    check()
    window.addEventListener('resize', check)
    return () => window.removeEventListener('resize', check)
  }, [])

  // Block scroll when drawer is open
  useEffect(() => {
    if (isOpen && !collapsed) {
      scrollYRef.current = window.scrollY
      document.body.style.position = 'fixed'
      document.body.style.top = `-${scrollYRef.current}px`
      document.body.style.width = '100%'
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.position = ''
      document.body.style.top = ''
      document.body.style.width = ''
      document.body.style.overflow = ''
      if (scrollYRef.current > 0) {
        window.scrollTo(0, scrollYRef.current)
      }
    }
    return () => {
      document.body.style.position = ''
      document.body.style.top = ''
      document.body.style.width = ''
      document.body.style.overflow = ''
    }
  }, [isOpen, collapsed])

  // Carregar nota existente
  useEffect(() => {
    if (!isOpen || !savedItemId) return
    let cancelled = false
    async function load() {
      setLoading(true)
      try {
        const note = await getNoteForItem(savedItemId)
        if (!cancelled) {
          setContent(note?.content || '')
          setOriginalContent(note?.content || '')
        }
      } catch {
        // silently fail
      } finally {
        if (!cancelled) setLoading(false)
      }
    }
    load()
    return () => { cancelled = true }
  }, [isOpen, savedItemId])

  // Auto-save com debounce
  const scheduleSave = useCallback((newContent) => {
    if (saveTimerRef.current) clearTimeout(saveTimerRef.current)
    setSaved(false)
    saveTimerRef.current = setTimeout(async () => {
      setSaving(true)
      try {
        await upsertNote(savedItemId, newContent)
        setOriginalContent(newContent)
        setSaved(true)
        setTimeout(() => setSaved(false), 2000)
      } catch {
        // silently fail
      } finally {
        setSaving(false)
      }
    }, AUTO_SAVE_DELAY)
  }, [savedItemId])

  // Cleanup timer
  useEffect(() => {
    return () => {
      if (saveTimerRef.current) clearTimeout(saveTimerRef.current)
    }
  }, [])

  // Handle content change
  const handleContentChange = (e) => {
    const newContent = e.target.value
    setContent(newContent)
    scheduleSave(newContent)
  }

  // Toggle collapsed
  const toggleCollapsed = () => {
    setCollapsed((prev) => !prev)
  }

  // Drag handlers (mobile)
  const handleDragStart = (e) => {
    dragStartY.current = e.touches ? e.touches[0].clientY : e.clientY
    dragCurrentY.current = dragStartY.current
  }

  const handleDragMove = (e) => {
    if (!isMobile) return
    dragCurrentY.current = e.touches ? e.touches[0].clientY : e.clientY
  }

  const handleDragEnd = () => {
    if (!isMobile) return
    const delta = dragStartY.current - dragCurrentY.current
    if (delta > 50) {
      setCollapsed(false) // Arrastou para cima → expandir
    } else if (delta < -50) {
      setCollapsed(true) // Arrastou para baixo → colapsar
    }
    dragStartY.current = 0
    dragCurrentY.current = 0
  }

  // Navegar para a página do item
  const goToItem = () => {
    const href = TYPE_LINKS[itemType]?.(lang, itemSlug)
    if (href) {
      // Fechar drawer antes de navegar
      document.body.style.position = ''
      document.body.style.top = ''
      document.body.style.width = ''
      document.body.style.overflow = ''
      router.push(href)
      onClose()
    }
  }

  // Fechar e guardar se pendente
  const handleClose = () => {
    if (content !== originalContent && content.trim()) {
      upsertNote(savedItemId, content)
    }
    setCollapsed(true)
    onClose()
  }

  if (!isOpen) return null

  const href = TYPE_LINKS[itemType]?.(lang, itemSlug) || '#'
  const typeLabel = TYPE_LABELS[itemType] || ''

  return (
    <>
      {/* Backdrop */}
      <div
        className={`notes-drawer-backdrop ${!collapsed ? 'is-open' : ''}`}
        onClick={handleClose}
      />

      {/* Drawer */}
      <div
        ref={drawerRef}
        className={`notes-drawer ${isMobile ? 'notes-drawer-mobile' : 'notes-drawer-desktop'} ${collapsed ? 'is-collapsed' : 'is-expanded'} ${isOpen ? 'is-open' : ''}`}
        onTouchStart={handleDragStart}
        onTouchMove={handleDragMove}
        onTouchEnd={handleDragEnd}
      >
        {/* Handle (mobile) */}
        {isMobile && (
          <div
            className="notes-drawer-handle"
            onMouseDown={handleDragStart}
            onMouseMove={handleDragMove}
            onMouseUp={handleDragEnd}
          />
        )}

        {/* Header */}
        <div className="notes-drawer-header">
          <button
            type="button"
            onClick={toggleCollapsed}
            className="notes-drawer-toggle"
          >
            {collapsed ? (
              <ChevronUp size={18} />
            ) : (
              <ChevronDown size={18} />
            )}
            <span className="notes-drawer-title">
              {t('notes_drawer.title', { name: itemName })}
            </span>
          </button>

          <div className="notes-drawer-header-meta">
            {saving && (
              <span className="notes-drawer-status">
                <Loader2 size={12} className="animate-spin" />
                {t('notes_drawer.saving')}
              </span>
            )}
            {saved && (
              <span className="notes-drawer-status notes-drawer-status--saved">
                <Check size={12} />
                {t('notes_drawer.saved')}
              </span>
            )}
            {!collapsed && (
              <span className="notes-drawer-chars">
                {content.length}
              </span>
            )}
            <button
              type="button"
              onClick={handleClose}
              className="notes-drawer-close"
              title={t('notes_drawer.close')}
            >
              <X size={16} />
            </button>
          </div>
        </div>

        {/* Content */}
        {!collapsed && (
          <div className="notes-drawer-body">
            {loading ? (
              <div className="notes-drawer-loading">
                <Loader2 size={24} className="animate-spin opacity-30" />
              </div>
            ) : (
              <textarea
                ref={textareaRef}
                value={content}
                onChange={handleContentChange}
                placeholder={t('notes_drawer.empty')}
                className="notes-drawer-textarea"
                maxLength={5000}
              />
            )}

            {/* Footer */}
            <div className="notes-drawer-footer">
              <button
                type="button"
                onClick={goToItem}
                className="notes-drawer-link"
              >
                <ExternalLink size={14} />
                {t('notes_drawer.view_item', { page: typeLabel })}
              </button>
            </div>
          </div>
        )}
      </div>
    </>
  )
}
