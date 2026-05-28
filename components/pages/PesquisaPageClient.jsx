'use client'

import { useState, useEffect, useContext, useCallback } from 'react'
import { useSearchParams, useRouter, usePathname } from 'next/navigation'
import Link from 'next/link'
import Image from 'next/image'
import { LangContext } from '@/lib/contexts'
import { searchAllContent } from '@/lib/api/search'
import { escapeHtml } from '@/lib/security'
import Breadcrumb from '@/components/ui/Breadcrumb'

const PER_PAGE = 15

const MONTHS_PT = [
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
]

function formatDate(dateStr) {
  if (!dateStr) return ''
  try {
    const d = new Date(dateStr + 'T00:00:00')
    return `${d.getDate()} ${MONTHS_PT[d.getMonth()]} ${d.getFullYear()}`
  } catch {
    return dateStr
  }
}

function highlightTerms(text, query) {
  if (!query || !text) return text
  const safe = escapeHtml(text)
  const escaped = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const regex = new RegExp(`(${escaped})`, 'gi')
  return safe.replace(regex, '<mark class="search-highlight">$1</mark>')
}

function renderSkeletons(count = 6) {
  return Array.from({ length: count }, (_, i) => (
    <div key={i} className="search-skeleton">
      <div className="skeleton-image" />
      <div className="skeleton-body">
        <div className="skeleton-line" style={{ width: 60 }} />
        <div className="skeleton-line skeleton-line-long" />
        <div className="skeleton-line skeleton-line-long" />
        <div className="skeleton-line skeleton-line-short" />
      </div>
    </div>
  ))
}

export default function PesquisaPageClient({ lang }) {
  const { t } = useContext(LangContext)
  const searchParams = useSearchParams()
  const router = useRouter()
  const pathname = usePathname()

  const [query, setQuery] = useState(searchParams.get('q') || '')
  const [tipo, setTipo] = useState(searchParams.get('tipo') || 'todos')
  const [ordem, setOrdem] = useState(searchParams.get('ordem') || 'recente')
  const [page, setPage] = useState(parseInt(searchParams.get('p'), 10) || 1)
  const [loading, setLoading] = useState(false)
  const [allResults, setAllResults] = useState(null)

  const breadcrumbItems = [
    { label: t('common.voltar_ao_site'), href: `/${lang}` },
    { label: t('search.pesquisa') },
  ]

  // Merged & sorted items from allResults
  const mergedItems = allResults ? (() => {
    const items = []
    allResults.articles.forEach(item => items.push({ ...item, type: 'articles' }))
    allResults.events.forEach(item => items.push({ ...item, type: 'events' }))
    allResults.lives.forEach(item => items.push({ ...item, type: 'lives' }))

    items.sort((a, b) => {
      const da = a.published_date || a.date || ''
      const db = b.published_date || b.date || ''
      return ordem === 'antigo' ? da.localeCompare(db) : db.localeCompare(da)
    })
    return items
  })() : []

  const totalPages = Math.ceil(mergedItems.length / PER_PAGE)
  const pagedItems = mergedItems.slice((page - 1) * PER_PAGE, page * PER_PAGE)

  // Update URL params
  const updateUrl = useCallback((q, tVal, o, pVal) => {
    const sp = new URLSearchParams()
    if (q) sp.set('q', q)
    if (tVal !== 'todos') sp.set('tipo', tVal)
    if (o !== 'recente') sp.set('ordem', o)
    if (pVal > 1) sp.set('p', String(pVal))
    const qs = sp.toString()
    router.replace(`${pathname}${qs ? `?${qs}` : ''}`, { scroll: false })
  }, [router, pathname])

  // Execute search
  const doSearch = useCallback(async (q, tVal, o) => {
    if (!q.trim()) return
    setLoading(true)
    setPage(1)
    try {
      const results = await searchAllContent(q, tVal || tipo, o || ordem)
      setAllResults(results)
      updateUrl(q, tVal || tipo, o || ordem, 1)
    } catch (err) {
      console.error('Search error:', err)
      setAllResults({ articles: [], events: [], lives: [], total: 0 })
    } finally {
      setLoading(false)
    }
  }, [tipo, ordem, updateUrl])

  // Search on Enter
  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      e.preventDefault()
      doSearch(query)
    }
  }

  // Filter change: re-execute search
  const handleTipoChange = (newTipo) => {
    setTipo(newTipo)
    if (query.trim()) {
      doSearch(query, newTipo, ordem)
    }
  }

  // Sort change: re-execute search
  const handleOrdemChange = (newOrdem) => {
    setOrdem(newOrdem)
    if (query.trim()) {
      doSearch(query, tipo, newOrdem)
    }
  }

  // Page change
  const goToPage = (p) => {
    setPage(p)
    updateUrl(query, tipo, ordem, p)
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  // Initial search if URL has q param
  useEffect(() => {
    const q = searchParams.get('q')
    if (q && !allResults) {
      setQuery(q)
      doSearch(q)
    }
  }, []) // eslint-disable-line react-hooks/exhaustive-deps

  // Get link for a result item
  const getItemLink = (item) => {
    if (item.type === 'articles') return `/${lang}/artigos/${item.slug}`
    if (item.type === 'events') return `/${lang}/eventos/${item.slug}`
    if (item.type === 'lives') return `/${lang}/lives/${item.slug}`
    return '#'
  }

  // Build page buttons (like MPA)
  const renderPageButtons = () => {
    const buttons = []
    for (let i = 1; i <= totalPages; i++) {
      buttons.push(
        <button
          key={i}
          className={`page-btn ${page === i ? 'active' : ''}`}
          onClick={() => goToPage(i)}
        >
          {i}
        </button>
      )
    }
    return buttons
  }

  return (
    <>
      {/* Breadcrumb — right after header, like MPA */}
      <nav id="breadcrumb" aria-label="Breadcrumb">
        <div className="max-w-7xl mx-auto px-4">
          <Breadcrumb items={breadcrumbItems} />
        </div>
      </nav>

      {/* Hero — centered text, no subtitle alignment override */}
      <section className="articles-hero">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 text-center">
          <h1 className="hero-title">{t('search.hero_title')}</h1>
          <p className="hero-subtitle text-center">{t('search.hero_subtitle')}</p>
        </div>
      </section>

      <section className="search-page" style={{ marginTop: '-2rem' }}>
        <div className="search-container">
          {/* Search Bar — no duplicate title, just the input */}
          <div className="search-hero">
            <div className="search-input-wrapper">
              <input
                type="text"
                className="search-input"
                id="search-input"
                placeholder={t('search.placeholder')}
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                onKeyDown={handleKeyDown}
                style={{ paddingLeft: '1rem' }}
              />
              <button
                className="search-btn"
                id="search-btn"
                onClick={() => doSearch(query)}
                disabled={loading}
                aria-label={t('search.button')}
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="11" cy="11" r="8" />
                  <path d="m21 21-4.3-4.3" />
                </svg>
              </button>
            </div>
          </div>

          {/* Result count */}
          <div className="search-count" id="search-count">
            {!loading && allResults && allResults.total > 0 && (
              <>{mergedItems.length} {mergedItems.length === 1 ? t('search.resultado') : t('search.resultados')}</>
            )}
          </div>

          {/* Filters & Sort */}
          <div className="search-filters">
            <div className="search-type-filters">
              {['todos', 'artigos', 'eventos', 'lives'].map((key) => (
                <button
                  key={key}
                  className={`filter-btn ${tipo === key ? 'active' : ''}`}
                  data-filter={key}
                  aria-pressed={tipo === key}
                  onClick={() => handleTipoChange(key)}
                >
                  {t(`search.${key}`)}
                </button>
              ))}
            </div>

            <div className="search-sort">
              <select
                className="search-sort-select"
                id="search-sort"
                value={ordem}
                onChange={(e) => handleOrdemChange(e.target.value)}
              >
                <option value="recente">{t('search.mais_recente')}</option>
                <option value="antigo">{t('search.mais_antigo')}</option>
              </select>
            </div>
          </div>

          {/* Loading skeleton */}
          {loading && (
            <div className="search-results">
              {renderSkeletons(6)}
            </div>
          )}

          {/* Empty state */}
          {!loading && allResults && allResults.total === 0 && (
            <div className="search-empty" id="search-empty">
              <div className="search-empty-icon">🔍</div>
              <p className="search-empty-text">{t('search.nenhum_resultado')}</p>
              <p className="text-sm opacity-50 mt-1">&ldquo;{query}&rdquo;</p>
            </div>
          )}

          {/* Empty query state */}
          {!loading && !allResults && (
            <div className="search-empty" id="search-empty">
              <p className="search-empty-text">Escreva o que pretende pesquisar.</p>
            </div>
          )}

          {/* Results */}
          {!loading && allResults && allResults.total > 0 && (
            <>
              <div className="search-results" id="search-results">
                {pagedItems.map((item) => (
                  <Link
                    key={`${item.type}-${item.id}`}
                    href={getItemLink(item)}
                    className="search-result-card"
                  >
                    {item.image_url && (
                      <div className="search-result-image">
                        <Image
                          src={item.image_url}
                          alt={item.title}
                          width={200}
                          height={140}
                          className="object-cover w-full h-full"
                        />
                      </div>
                    )}
                    <div className="search-result-body">
                      <span className="search-result-type">
                        {item.type === 'articles' ? '📄 Artigo' : item.type === 'events' ? '📅 Evento' : '🎬 Live'}
                      </span>
                      <h3
                        className="search-result-title"
                        dangerouslySetInnerHTML={{ __html: highlightTerms(item.title, query) }}
                      />
                      {item.excerpt && (
                        <p
                          className="search-result-excerpt"
                          dangerouslySetInnerHTML={{ __html: highlightTerms(item.excerpt, query) }}
                        />
                      )}
                      <span className="search-result-date">
                        {formatDate(item.published_date || item.date)}
                      </span>
                    </div>
                  </Link>
                ))}
              </div>

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="search-pagination" id="search-pagination">
                  {page > 1 && (
                    <button className="page-btn" onClick={() => goToPage(page - 1)}>
                      &larr;
                    </button>
                  )}
                  {renderPageButtons()}
                  {page < totalPages && (
                    <button className="page-btn" onClick={() => goToPage(page + 1)}>
                      &rarr;
                    </button>
                  )}
                </div>
              )}
            </>
          )}
        </div>
      </section>
    </>
  )
}
