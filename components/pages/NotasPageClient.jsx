'use client'

import { useState, useEffect, useCallback, useContext } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import {
  Search, Loader2, Frown, ExternalLink, Pencil, Trash2, Check, X
} from 'lucide-react'
import { getAllNotes, getNotesCount, updateNote, deleteNote } from '@/lib/actions/saved'
import { LangContext } from '@/lib/contexts'

const TAB_KEYS = {
  all: 'notes_page.tabs_all',
  drug: 'notes_page.tab_drug',
  interaction: 'notes_page.tab_interaction',
  drug_class: 'notes_page.tab_drug_class',
  molecular_target: 'notes_page.tab_molecular_target',
  article: 'notes_page.tab_article',
}

const TYPE_ICONS = {
  drug: '💊',
  interaction: '🔗',
  drug_class: '📋',
  molecular_target: '🎯',
  article: '📰',
}

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

function timeAgo(date, lang) {
  const now = new Date()
  const d = new Date(date)
  const diffMs = now - d
  const diffMin = Math.floor(diffMs / 60000)
  const diffH = Math.floor(diffMs / 3600000)
  const diffD = Math.floor(diffMs / 86400000)

  if (diffMin < 1) return lang === 'pt' ? 'Agora mesmo' : 'Just now'
  if (diffMin < 60) return lang === 'pt' ? `Há ${diffMin} min` : `${diffMin}m ago`
  if (diffH < 24) return lang === 'pt' ? `Há ${diffH}h` : `${diffH}h ago`
  if (diffD < 7) return lang === 'pt' ? `Há ${diffD} dia(s)` : `${diffD}d ago`
  return d.toLocaleDateString(lang === 'pt' ? 'pt-PT' : 'en-GB', { day: 'numeric', month: 'short' })
}

export default function NotasPageClient({ lang }) {
  const { t } = useContext(LangContext)
  const router = useRouter()

  const [notes, setNotes] = useState([])
  const [counts, setCounts] = useState(null)
  const [activeTab, setActiveTab] = useState('all')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [totalPages, setTotalPages] = useState(0)
  const [total, setTotal] = useState(0)
  const [loading, setLoading] = useState(true)
  const [loadingMore, setLoadingMore] = useState(false)
  const [expandedId, setExpandedId] = useState(null)
  const [editingId, setEditingId] = useState(null)
  const [editContent, setEditContent] = useState('')
  const [deletingId, setDeletingId] = useState(null)

  // Load counts
  useEffect(() => {
    async function load() {
      const c = await getNotesCount()
      setCounts(c)
      setLoading(false)
    }
    load()
  }, [])

  // Load notes
  const loadNotes = useCallback(async (pageNum = 1, append = false) => {
    if (append) setLoadingMore(true)
    else setLoading(true)

    try {
      const result = await getAllNotes({
        type: activeTab === 'all' ? undefined : activeTab,
        search: search || undefined,
        page: pageNum,
        limit: 20,
      })
      if (append) {
        setNotes((prev) => [...prev, ...result.notes])
      } else {
        setNotes(result.notes)
      }
      setTotalPages(result.pages)
      setTotal(result.total)
    } catch {
      setNotes([])
    } finally {
      setLoading(false)
      setLoadingMore(false)
    }
  }, [activeTab, search])

  useEffect(() => {
    loadNotes(1)
  }, [loadNotes])

  // Reset page when tab or search changes
  useEffect(() => {
    setPage(1)
  }, [activeTab, search])

  const handleTabChange = (key) => {
    setActiveTab(key)
    setExpandedId(null)
    setEditingId(null)
  }

  const handleSearchChange = (e) => {
    setSearch(e.target.value)
  }

  const toggleExpand = (noteId) => {
    setExpandedId(expandedId === noteId ? null : noteId)
    setEditingId(null)
    setEditContent('')
  }

  const startEdit = (note) => {
    setEditingId(note.id)
    setEditContent(note.content)
  }

  const saveEdit = async (noteId) => {
    if (!editContent.trim()) return
    const result = await updateNote(noteId, editContent.trim())
    if (result.success) {
      setNotes((prev) =>
        prev.map((n) => (n.id === noteId ? { ...n, content: editContent.trim() } : n))
      )
      setEditingId(null)
      setEditContent('')
    }
  }

  const handleDelete = async (noteId) => {
    setDeletingId(noteId)
    try {
      const result = await deleteNote(noteId)
      if (result.success) {
        setNotes((prev) => prev.filter((n) => n.id !== noteId))
        setTotal((prev) => prev - 1)
      }
    } finally {
      setDeletingId(null)
    }
  }

  const loadMore = () => {
    const nextPage = page + 1
    setPage(nextPage)
    loadNotes(nextPage, true)
  }

  if (loading) {
    const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }
    return (
      <>
        <section className="events-hero">
          <div className="container-center">
            <div className="text-center py-12 md:py-16">
              <div className="h-12 w-48 mx-auto rounded-2xl mb-3" style={{ ...pulse, opacity: 0.5 }} />
              <div className="h-5 w-64 mx-auto rounded-lg" style={{ ...pulse, opacity: 0.3 }} />
            </div>
          </div>
        </section>
        <section className="max-w-7xl mx-auto px-4 py-8">
          <div className="max-w-md mx-auto mb-6">
            <div className="h-12 w-full rounded-lg" style={{ ...pulse, opacity: 0.2 }} />
          </div>
          <div className="flex gap-2 justify-center flex-wrap">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="h-9 rounded-lg" style={{ ...pulse, opacity: 0.2, width: 70 + i * 12 }} />
            ))}
          </div>
        </section>
        <section className="max-w-7xl mx-auto px-4 pb-16">
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="p-4 rounded-xl" style={{ border: '1px solid var(--color-brand-divider)' }}>
                <div className="h-4 w-36 rounded mb-2" style={{ ...pulse, opacity: 0.4 }} />
                <div className="h-3 w-full rounded mb-1.5" style={{ ...pulse, opacity: 0.2 }} />
                <div className="h-3 w-2/3 rounded" style={{ ...pulse, opacity: 0.15 }} />
              </div>
            ))}
          </div>
        </section>
      </>
    )
  }

  return (
    <div className="saved-page">
      {/* Hero — estilo /cientificos */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('notes_page.title')}
            </h1>
            <p className="hero-subtitle text-center">
              {total > 0
                ? t('notes_page.subtitle', { n: total })
                : t('notes_page.empty_hint')}
            </p>

            {/* Pesquisa */}
            <div className="max-w-3xl mx-auto mt-10 relative">
              <Search
                size={18}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-brand-deep/40"
                aria-hidden="true"
              />
              <input
                type="search"
                value={search}
                onChange={handleSearchChange}
                placeholder={t('notes_page.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>

            {/* Tabs */}
            <div className="flex flex-wrap items-center justify-center gap-3 mt-6">
              {Object.entries(TAB_KEYS).map(([key, labelKey]) => {
                const count = key === 'all' ? counts?.total : counts?.[key] || 0
                return (
                  <button
                    key={key}
                    type="button"
                    onClick={() => handleTabChange(key)}
                    className={`saved-tab ${activeTab === key ? 'saved-tab--active' : ''}`}
                  >
                    <span className="saved-tab-label">{t(labelKey)}</span>
                    {count > 0 && (
                      <span className="saved-tab-badge">{count}</span>
                    )}
                  </button>
                )
              })}
            </div>
          </div>
        </div>
      </section>

      {/* Lista de notas */}
      <section className="saved-content">
        <div className="container-center">
          {notes.length === 0 ? (
            <div className="saved-empty">
              <Frown size={48} className="mx-auto mb-4 opacity-30" />
              <p className="text-lg font-medium mb-2">
                {search ? t('notes_page.no_results') : t('notes_page.empty')}
              </p>
              <p className="text-sm opacity-60">
                {search
                  ? `${t('notes_page.no_results_hint')} "${search}"`
                  : t('notes_page.empty_hint')}
              </p>
            </div>
          ) : (
            <>
              <div className="space-y-3">
                {notes.map((note) => {
                  const item = note.saved_item
                  if (!item) return null

                  const isExpanded = expandedId === note.id
                  const isEditing = editingId === note.id
                  const TypeIcon = TYPE_ICONS[item.item_type] || '📝'
                  const href = TYPE_LINKS[item.item_type]?.(lang, item.item_slug) || '#'

                  return (
                    <div
                      key={note.id}
                      className={`nota-inline ${isExpanded ? 'nota-inline--expanded' : ''}`}
                    >
                      {/* Header */}
                      <div className="flex items-center gap-3 cursor-pointer" onClick={() => toggleExpand(note.id)}>
                        <span className="text-lg">{TypeIcon}</span>
                        <div className="flex-1 min-w-0">
                          <div className="font-semibold text-sm" style={{ color: 'var(--color-brand-deep)' }}>
                            {item.item_name}
                          </div>
                          {!isExpanded && (
                            <div className="text-xs truncate" style={{ color: 'var(--color-brand-deep)', opacity: 0.5 }}>
                              {note.content.substring(0, 80)}...
                            </div>
                          )}
                        </div>
                        <div className="flex items-center gap-2 flex-shrink-0">
                          <span className="text-xs" style={{ color: 'var(--color-brand-deep)', opacity: 0.4 }}>
                            {timeAgo(note.updated_at, lang)}
                          </span>
                          <Pencil
                            size={14}
                            className="opacity-40 hover:opacity-100 cursor-pointer"
                            onClick={(e) => { e.stopPropagation(); startEdit(note) }}
                          />
                          <Trash2
                            size={14}
                            className="opacity-40 hover:opacity-100 cursor-pointer hover:text-red-500"
                            onClick={(e) => { e.stopPropagation(); handleDelete(note.id) }}
                          />
                        </div>
                      </div>

                      {/* Expanded content */}
                      {isExpanded && (
                        <div className="mt-3 pt-3" style={{ borderTop: '1px solid var(--color-brand-divider)' }}>
                          {isEditing ? (
                            <div>
                              <textarea
                                value={editContent}
                                onChange={(e) => setEditContent(e.target.value)}
                                className="w-full p-3 rounded-lg text-sm resize-none focus:outline-none focus:ring-2 focus:ring-[var(--color-brand-accent)]"
                                style={{
                                  background: 'var(--color-brand-bg)',
                                  color: 'var(--color-brand-deep)',
                                  border: '1px solid var(--color-brand-divider)',
                                }}
                                rows={4}
                                maxLength={5000}
                                autoFocus
                              />
                              <div className="flex items-center justify-between mt-2">
                                <span className="text-xs" style={{ opacity: 0.4 }}>{editContent.length}/5000</span>
                                <div className="flex gap-2">
                                  <button
                                    type="button"
                                    onClick={() => saveEdit(note.id)}
                                    className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium"
                                    style={{
                                      background: 'var(--color-brand-accent)',
                                      color: 'white',
                                    }}
                                  >
                                    <Check size={12} /> {t('notes_page.save')}
                                  </button>
                                  <button
                                    type="button"
                                    onClick={() => { setEditingId(null); setEditContent('') }}
                                    className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-medium"
                                    style={{
                                      background: 'var(--color-brand-card)',
                                      border: '1px solid var(--color-brand-divider)',
                                      color: 'var(--color-brand-deep)',
                                    }}
                                  >
                                    <X size={12} /> {t('notes_page.cancel')}
                                  </button>
                                </div>
                              </div>
                            </div>
                          ) : (
                            <div className="nota-inline-content">
                              {note.content}
                            </div>
                          )}

                          {/* Link para o item */}
                          <div className="mt-3 pt-3" style={{ borderTop: '1px solid var(--color-brand-divider)' }}>
                            <Link
                              href={href}
                              className="inline-flex items-center gap-2 text-xs font-medium"
                              style={{ color: 'var(--color-brand-accent)' }}
                            >
                              <ExternalLink size={12} />
                              {t('notes_page.view_item', { page: TYPE_LABELS[item.item_type] })}
                            </Link>
                          </div>
                        </div>
                      )}
                    </div>
                  )
                })}
              </div>

              {/* Load more */}
              {page < totalPages && (
                <div className="text-center mt-8">
                  <button
                    type="button"
                    onClick={loadMore}
                    disabled={loadingMore}
                    className="px-6 py-3 rounded-xl text-sm font-medium transition-all"
                    style={{
                      background: 'var(--color-brand-card)',
                      border: '1px solid var(--color-brand-divider)',
                      color: 'var(--color-brand-deep)',
                    }}
                  >
                    {loadingMore ? (
                      <Loader2 size={16} className="animate-spin mx-auto" />
                    ) : (
                      t('notes_page.load_more')
                    )}
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
