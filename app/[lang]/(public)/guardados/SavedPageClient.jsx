'use client'

import { useState, useEffect, useCallback, useContext } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import {
  Bookmark, Search, Pill, ShieldAlert, ClipboardList, Atom, Newspaper,
  ChevronLeft, ChevronRight, Loader2, Frown, StickyNote
} from 'lucide-react'
import { getSavedItems, getSavedCounts, deleteNote, addNote, updateNote, getNotes } from '@/lib/actions/saved'
import NotesPanel from './NotesPanel'
import { LangContext } from '@/lib/contexts'

const ITEM_TYPES = [
  { key: 'all', icon: Bookmark, labelKey: 'all' },
  { key: 'drug', icon: Pill, labelKey: 'drug' },
  { key: 'interaction', icon: ShieldAlert, labelKey: 'interaction' },
  { key: 'drug_class', icon: ClipboardList, labelKey: 'drug_class' },
  { key: 'molecular_target', icon: Atom, labelKey: 'molecular_target' },
  { key: 'article', icon: Newspaper, labelKey: 'article' },
]

const TAB_KEYS = {
  all: 'saved.tabs_all',
  drug: 'saved.tab_drug',
  interaction: 'saved.tab_interaction',
  drug_class: 'saved.tab_drug_class',
  molecular_target: 'saved.tab_molecular_target',
  article: 'saved.tab_article',
}

const TYPE_LINKS = {
  drug: (slug) => `/medicamentos/${slug}`,
  interaction: (slug) => `/interacoes`,
  drug_class: (slug) => `/classes/${slug}`,
  molecular_target: (slug) => `/alvos/${slug}`,
  article: (slug) => `/artigos/${slug}`,
}

const TYPE_ICONS = {
  drug: Pill,
  interaction: ShieldAlert,
  drug_class: ClipboardList,
  molecular_target: Atom,
  article: Newspaper,
}

export default function SavedPageClient({ lang }) {
  const { t } = useContext(LangContext)
  const [items, setItems] = useState([])
  const [counts, setCounts] = useState(null)
  const [activeTab, setActiveTab] = useState('all')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [totalPages, setTotalPages] = useState(0)
  const [total, setTotal] = useState(0)
  const [loading, setLoading] = useState(true)
  const [loadingItems, setLoadingItems] = useState(false)
  const [expandedNotes, setExpandedNotes] = useState(null) // savedItemId
  const [notesCache, setNotesCache] = useState({})
  const router = useRouter()

  // Load counts
  useEffect(() => {
    async function load() {
      const c = await getSavedCounts()
      setCounts(c)
      setLoading(false)
    }
    load()
  }, [])

  // Load items when tab/search/page changes
  const loadItems = useCallback(async () => {
    setLoadingItems(true)
    try {
      const result = await getSavedItems({
        itemType: activeTab === 'all' ? undefined : activeTab,
        search: search || undefined,
        page,
        limit: 12,
      })
      setItems(result.items)
      setTotalPages(result.pages)
      setTotal(result.total)
    } catch {
      setItems([])
    } finally {
      setLoadingItems(false)
    }
  }, [activeTab, search, page])

  useEffect(() => {
    loadItems()
  }, [loadItems])

  // Reset page when tab or search changes
  useEffect(() => {
    setPage(1)
  }, [activeTab, search])

  const handleTabChange = (key) => {
    setActiveTab(key)
    setExpandedNotes(null)
  }

  const handleSearchChange = (e) => {
    setSearch(e.target.value)
  }

  const toggleNotes = async (savedItemId) => {
    if (expandedNotes === savedItemId) {
      setExpandedNotes(null)
      return
    }
    setExpandedNotes(savedItemId)
    if (!notesCache[savedItemId]) {
      const notes = await getNotes(savedItemId)
      setNotesCache((prev) => ({ ...prev, [savedItemId]: notes }))
    }
  }

  const handleAddNote = async (savedItemId, content) => {
    const result = await addNote(savedItemId, content)
    if (result.success) {
      setNotesCache((prev) => ({
        ...prev,
        [savedItemId]: [result.note, ...(prev[savedItemId] || [])],
      }))
    }
    return result
  }

  const handleUpdateNote = async (savedItemId, noteId, content) => {
    const result = await updateNote(noteId, content)
    if (result.success) {
      setNotesCache((prev) => ({
        ...prev,
        [savedItemId]: (prev[savedItemId] || []).map((n) =>
          n.id === noteId ? result.note : n
        ),
      }))
    }
    return result
  }

  const handleDeleteNote = async (savedItemId, noteId) => {
    const result = await deleteNote(noteId)
    if (result.success) {
      setNotesCache((prev) => ({
        ...prev,
        [savedItemId]: (prev[savedItemId] || []).filter((n) => n.id !== noteId),
      }))
    }
    return result
  }

  if (loading) {
    return (
      <section className="py-20 text-center">
        <Loader2 size={40} className="mx-auto mb-4 text-brand-accent animate-spin" />
      </section>
    )
  }

  return (
    <div className="saved-page">
      {/* Hero */}
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <div className="w-14 h-14 rounded-2xl bg-brand-accent/10 flex items-center justify-center mx-auto mb-4">
              <Bookmark size={28} className="text-brand-accent" />
            </div>
            <h1 className="text-4xl md:text-5xl font-bold text-brand-deep mb-3">
              {t('saved.title')}
            </h1>
            <p className="text-brand-deep/60 max-w-md mx-auto">
              {total > 0
                ? t('saved.count', { n: total })
                : t('saved.empty_hint')}
            </p>
          </div>
        </div>
      </section>

      {/* Tabs + Search */}
      <section className="saved-toolbar">
        <div className="container-center">
          <div className="saved-toolbar-inner">
            {/* Tabs */}
            <div className="saved-tabs">
              {ITEM_TYPES.map(({ key, icon: Icon }) => {
                const count = key === 'all' ? counts?.total : counts?.[key] || 0
                return (
                  <button
                    key={key}
                    type="button"
                    onClick={() => handleTabChange(key)}
                    className={`saved-tab ${activeTab === key ? 'saved-tab--active' : ''}`}
                  >
                    <Icon size={14} />
                    <span className="saved-tab-label">{t(TAB_KEYS[key])}</span>
                    {count > 0 && (
                      <span className="saved-tab-badge">{count}</span>
                    )}
                  </button>
                )
              })}
            </div>

            {/* Search */}
            <div className="saved-search">
              <Search size={16} className="saved-search-icon" />
              <input
                type="text"
                value={search}
                onChange={handleSearchChange}
                placeholder={t('saved.search_placeholder')}
                className="saved-search-input"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Items List */}
      <section className="saved-content">
        <div className="container-center">
          {loadingItems ? (
            <div className="text-center py-16">
              <Loader2 size={32} className="mx-auto mb-3 text-brand-accent animate-spin" />
            </div>
          ) : items.length === 0 ? (
            <div className="saved-empty">
              <Frown size={48} className="mx-auto mb-4 opacity-30" />
              <p className="text-lg font-medium mb-2">
                {search ? t('saved.no_results') : t('saved.empty')}
              </p>
              <p className="text-sm opacity-60">
                {search
                  ? `${t('saved.no_results_hint')} "${search}"`
                  : t('saved.empty_hint')}
              </p>
            </div>
          ) : (
            <>
              <div className="saved-list">
                {items.map((item) => {
                  const TypeIcon = TYPE_ICONS[item.item_type] || Bookmark
                  const href = TYPE_LINKS[item.item_type]?.(item.item_slug) || '#'

                  return (
                    <div key={item.id} className="saved-item">
                      <div className="saved-item-main">
                        <div className="saved-item-icon">
                          <TypeIcon size={18} />
                        </div>
                        <Link href={href} className="saved-item-info">
                          <div className="saved-item-name">{item.item_name}</div>
                          {item.item_subtitle && (
                            <div className="saved-item-subtitle">{item.item_subtitle}</div>
                          )}
                        </Link>
                        <div className="saved-item-meta">
                          {item.notesCount > 0 && (
                            <button
                              type="button"
                              onClick={() => toggleNotes(item.id)}
                              className="saved-item-notes-badge"
                            >
                              <StickyNote size={12} />
                              {item.notesCount}
                            </button>
                          )}
                          <span className="saved-item-date">
                            {new Date(item.created_at).toLocaleDateString('pt-PT', { day: 'numeric', month: 'short' })}
                          </span>
                        </div>
                      </div>

                      {/* Notes Panel */}
                      {expandedNotes === item.id && (
                        <NotesPanel
                          savedItemId={item.id}
                          notes={notesCache[item.id] || []}
                          onAdd={(content) => handleAddNote(item.id, content)}
                          onUpdate={(noteId, content) => handleUpdateNote(item.id, noteId, content)}
                          onDelete={(noteId) => handleDeleteNote(item.id, noteId)}
                        />
                      )}
                    </div>
                  )
                })}
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="saved-pagination">
                  <button
                    type="button"
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    disabled={page <= 1}
                    className="saved-page-btn"
                  >
                    <ChevronLeft size={16} />
                  </button>                    <span className="saved-page-info">
                  <button
                    type="button"
                    onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                    disabled={page >= totalPages}
                    className="saved-page-btn"
                  >
                    <ChevronRight size={16} />
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </section>
    </div>
  )
}
