'use client'

import { useState, useEffect, useCallback, useContext } from 'react'
import Link from 'next/link'
import {
  Search, Loader2, Frown, ExternalLink, Pencil, Trash2, Check, X,
  Pill, ShieldAlert, ClipboardList, Atom, Newspaper, StickyNote, Plus
} from 'lucide-react'
import { getAllNotes, getNotesCount, updateNote, deleteNoteById, upsertStandaloneNote } from '@/lib/actions/saved'
import NotesDrawer from '@/components/ui/NotesDrawer'
import { LangContext } from '@/lib/contexts'

const TAB_KEYS = {
  all: 'notes_page.tabs_all',
  drug: 'notes_page.tab_drug',
  interaction: 'notes_page.tab_interaction',
  drug_class: 'notes_page.tab_drug_class',
  molecular_target: 'notes_page.tab_molecular_target',
  article: 'notes_page.tab_article',
  standalone: 'notes_page.tab_standalone',
}

const TYPE_ICONS = {
  drug: Pill,
  interaction: ShieldAlert,
  drug_class: ClipboardList,
  molecular_target: Atom,
  article: Newspaper,
  standalone: StickyNote,
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
  standalone: 'Nota solta',
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

  const [notes, setNotes] = useState([])
  const [counts, setCounts] = useState(null)
  const [activeTab, setActiveTab] = useState('all')
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const [totalPages, setTotalPages] = useState(0)
  const [total, setTotal] = useState(0)
  const [loading, setLoading] = useState(true)
  const [loadingMore, setLoadingMore] = useState(false)
  
  // NotesDrawer state
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [drawerNote, setDrawerNote] = useState(null)
  const [drawerIsStandalone, setDrawerIsStandalone] = useState(false)

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
  }

  const handleSearchChange = (e) => {
    setSearch(e.target.value)
  }

  const openDrawer = (note, isStandalone = false) => {
    setDrawerNote(note)
    setDrawerIsStandalone(isStandalone)
    setDrawerOpen(true)
  }

  const handleDrawerClose = () => {
    setDrawerOpen(false)
    setDrawerNote(null)
    setDrawerIsStandalone(false)
    // Reload notes to reflect changes
    loadNotes(1)
  }

  const handleCreateStandalone = async () => {
    const result = await upsertStandaloneNote(null, 'Nova nota...')
    if (result.success && result.note) {
      setDrawerNote(result.note)
      setDrawerIsStandalone(true)
      setDrawerOpen(true)
      loadNotes(1)
    }
  }

  const handleDelete = async (noteId) => {
    const result = await deleteNoteById(noteId)
    if (result.success) {
      setNotes((prev) => prev.filter((n) => n.id !== noteId))
      setTotal((prev) => prev - 1)
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
          <div className="saved-grid">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="saved-card" style={{ ...pulse, opacity: 0.1, minHeight: 120 }} />
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

            {/* Tabs + Botão Criar Nota */}
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
              <button
                type="button"
                onClick={handleCreateStandalone}
                className="saved-tab saved-tab--create"
              >
                <Plus size={14} />
                <span className="saved-tab-label">Criar nota</span>
              </button>
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
              <div className="saved-grid">
                {notes.map((note) => {
                  const item = note.saved_item
                  const isStandalone = note.is_standalone
                  
                  const TypeIcon = isStandalone ? StickyNote : (TYPE_ICONS[item?.item_type] || Pencil)
                  const href = isStandalone ? null : (TYPE_LINKS[item?.item_type]?.(lang, item?.item_slug) || '#')
                  const itemName = isStandalone ? 'Nota solta' : (item?.item_name || 'Nota')

                  return (
                    <div key={note.id} className="saved-card">
                      {href ? (
                        <Link href={href} className="saved-card-link">
                          <div className="saved-card-icon">
                            <TypeIcon size={20} />
                          </div>
                          <div className="saved-card-content">
                            <div className="saved-card-name">{itemName}</div>
                            {item?.item_subtitle && (
                              <div className="saved-card-subtitle">{item.item_subtitle}</div>
                            )}
                            <div className="saved-card-meta">
                              <span className="saved-card-date">
                                {timeAgo(note.updated_at, lang)}
                              </span>
                            </div>
                          </div>
                        </Link>
                      ) : (
                        <div className="saved-card-link">
                          <div className="saved-card-icon">
                            <TypeIcon size={20} />
                          </div>
                          <div className="saved-card-content">
                            <div className="saved-card-name">{itemName}</div>
                            <div className="saved-card-meta">
                              <span className="saved-card-date">
                                {timeAgo(note.updated_at, lang)}
                              </span>
                            </div>
                          </div>
                        </div>
                      )}
                      
                      {/* Note preview + Edit button inline */}
                      <div className="saved-card-note-row">
                        <div className="saved-card-note-preview">
                          {note.content.substring(0, 80)}...
                        </div>
                        <button
                          type="button"
                          onClick={() => openDrawer(note, isStandalone)}
                          className="saved-card-note-edit-btn"
                          title={t('saved.notes_title')}
                        >
                          <Pencil size={12} />
                        </button>
                      </div>
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

      {/* Notes Drawer */}
      {drawerNote && (
        <NotesDrawer
          isOpen={drawerOpen}
          onClose={handleDrawerClose}
          itemId={drawerNote.saved_item?.item_id}
          itemName={drawerNote.is_standalone ? 'Nota solta' : drawerNote.saved_item?.item_name}
          itemSlug={drawerNote.saved_item?.item_slug}
          itemType={drawerNote.is_standalone ? 'standalone' : drawerNote.saved_item?.item_type}
          lang={lang}
          noteId={drawerNote.id}
          isStandalone={drawerNote.is_standalone}
        />
      )}
    </div>
  )
}
