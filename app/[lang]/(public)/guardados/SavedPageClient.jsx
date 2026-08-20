'use client'

import { useState, useEffect, useCallback, useContext } from 'react'
import Link from 'next/link'
import {
  Bookmark, Search, Pill, ShieldAlert, ClipboardList, Atom, Newspaper,
  ChevronLeft, ChevronRight, Loader2, Frown, StickyNote, Pencil
} from 'lucide-react'
import { getSavedItems, getSavedCounts, getNoteForItem } from '@/lib/actions/saved'
import NotesDrawer from '@/components/ui/NotesDrawer'
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
  drug: (lang, slug) => `/${lang}/medicamentos/${slug}`,
  interaction: (lang, slug) => {
    if (slug && slug.includes('+')) {
      const [a, b] = slug.split('+')
      return `/${lang}/interacoes?farmaco=${a}&par=${b}`
    }
    return `/${lang}/interacoes`
  },
  drug_class: (lang, slug) => `/${lang}/classes/${slug}`,
  molecular_target: (lang, slug) => `/${lang}/alvos/${slug}`,
  article: (lang, slug) => `/${lang}/artigos/${slug}`,
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
  const [notesCache, setNotesCache] = useState({})
  
  // NotesDrawer state
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [drawerItem, setDrawerItem] = useState(null)

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
        limit: 20,
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
  }

  const handleSearchChange = (e) => {
    setSearch(e.target.value)
  }

  const openDrawer = async (item) => {
    setDrawerItem(item)
    setDrawerOpen(true)
    
    // Load note if not cached
    if (notesCache[item.id] === undefined) {
      const note = await getNoteForItem(item.item_type, item.item_id)
      setNotesCache((prev) => ({ ...prev, [item.id]: note }))
    }
  }

  const handleDrawerClose = () => {
    setDrawerOpen(false)
    setDrawerItem(null)
  }

  if (loading) {
    const pulse = { background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite' }
    return (
      <>
        <section className="articles-hero">
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
      {/* Hero */}
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-4xl md:text-5xl font-bold text-brand-deep mb-3">
              {t('saved.title')}
            </h1>
            <p className="hero-subtitle text-center">
              {total > 0
                ? t('saved.count', { n: total })
                : t('saved.empty_hint')}
            </p>
          </div>
        </div>
      </section>

      {/* Search + Tabs centered */}
      <section className="max-w-7xl mx-auto px-4 py-8">
        {/* Search */}
        <div className="max-w-md mx-auto mb-6">
          <div className="relative">
            <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
            <input
              type="text"
              value={search}
              onChange={handleSearchChange}
              placeholder={t('saved.search_placeholder')}
              className="w-full pl-10 pr-4 py-3 rounded-lg border focus:outline-none focus:ring-2 focus:ring-[var(--accent)]"
              style={{
                borderColor: 'var(--color-brand-divider)',
                background: 'var(--color-brand-bg)',
                color: 'var(--color-brand-deep)',
              }}
            />
          </div>
        </div>

        {/* Tabs */}
        <div className="saved-tabs-center">
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
      </section>

      {/* Items Grid */}
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
              <div className="saved-grid">
                {items.map((item) => {
                  const TypeIcon = TYPE_ICONS[item.item_type] || Bookmark
                  const href = TYPE_LINKS[item.item_type]?.(lang, item.item_slug) || '#'
                  const note = notesCache[item.id]
                  const hasNote = note?.content?.trim().length > 0

                  return (
                    <div key={item.id} className="saved-card">
                      <Link href={href} className="saved-card-link">
                        <div className="saved-card-icon">
                          <TypeIcon size={20} />
                        </div>
                        <div className="saved-card-content">
                          <div className="saved-card-name">{item.item_name}</div>
                          {item.item_subtitle && (
                            <div className="saved-card-subtitle">{item.item_subtitle}</div>
                          )}
                          <div className="saved-card-meta">
                            <span className="saved-card-date">
                              {new Date(item.created_at).toLocaleDateString('pt-PT', { day: 'numeric', month: 'short' })}
                            </span>
                          </div>
                        </div>
                      </Link>
                      
                      {/* Note preview */}
                      {hasNote && (
                        <div className="saved-card-note-preview">
                          <StickyNote size={12} className="inline mr-1 opacity-50" />
                          {note.content.substring(0, 80)}...
                        </div>
                      )}
                      
                      {/* Notes button */}
                      <button
                        type="button"
                        onClick={() => openDrawer(item)}
                        className={`saved-card-notes-btn ${hasNote ? 'saved-card-notes-btn--has-note' : ''}`}
                        title={t('saved.notes_title')}
                      >
                        <Pencil size={14} />
                      </button>
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
                  </button>
                  <span className="saved-page-info">
                    {page} / {totalPages}
                  </span>
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

      {/* Notes Drawer */}
      {drawerItem && (
        <NotesDrawer
          isOpen={drawerOpen}
          onClose={handleDrawerClose}
          itemId={drawerItem.item_id}
          itemName={drawerItem.item_name}
          itemSlug={drawerItem.item_slug}
          itemType={drawerItem.item_type}
          lang={lang}
        />
      )}
    </div>
  )
}
