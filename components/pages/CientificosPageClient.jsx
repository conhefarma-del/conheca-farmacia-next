'use client'

import { useState, useMemo, useEffect, useContext } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { LangContext } from '@/lib/contexts'
import FilterButtons from '@/components/ui/FilterButtons'
import CitedByBadge from '@/components/content/CitedByBadge'
import { ArrowLeft, Search, Eye, Users, ChevronLeft, ChevronRight } from 'lucide-react'

const PER_PAGE = 15

/**
 * Lista de páginas para a navegação, com reticências quando há muitas:
 * ex. total 12, atual 6 → [1, '…', 4, 5, 6, 7, 8, '…', 12]
 */
function pageList(current, total) {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1)
  const pages = new Set([1, total, current - 1, current, current + 1])
  const sorted = [...pages].filter((p) => p >= 1 && p <= total).sort((a, b) => a - b)
  const out = []
  let prev = 0
  for (const p of sorted) {
    if (p - prev > 1) out.push('ellipsis')
    out.push(p)
    prev = p
  }
  return out
}

/**
 * Constrói a URL da listagem a partir do estado de filtros (server-side).
 * Parâmetros omitidos = predefinição; página 1 não gera `?page=1`.
 */
function buildUrl(lang, { categoria = '', q = '', ordenar = 'recent', page = 1 } = {}) {
  const params = new URLSearchParams()
  if (categoria) params.set('categoria', categoria)
  if (q.trim()) params.set('q', q.trim())
  if (ordenar && ordenar !== 'recent') params.set('ordenar', ordenar)
  if (page > 1) params.set('page', String(page))
  const qs = params.toString()
  return `/${lang}/cientificos${qs ? `?${qs}` : ''}`
}

/**
 * CientificosPageClient — listagem pública dos Artigos Científicos.
 * Server-side: a página server filtra/ordena/pagina (15 por página) e passa
 * a fatia atual + total + estado ativo; este componente só navega (router).
 * A pesquisa tem debounce; filtros, ordenação e páginas são URLs indexáveis.
 */
export default function CientificosPageClient({
  articles = [],
  categories = [],
  lang = 'pt',
  total = 0,
  page = 1,
  totalPages = 1,
  categoria = '',
  q = '',
  ordenar = 'recent',
}) {
  const { t } = useContext(LangContext)
  const router = useRouter()
  const [searchInput, setSearchInput] = useState(q)

  // Sincroniza o input quando a URL muda (navegação/voltar)
  useEffect(() => {
    setSearchInput(q)
  }, [q])

  // Pesquisa com debounce → router.push (scroll: false; página volta a 1)
  useEffect(() => {
    if (searchInput.trim() === q) return
    const timer = setTimeout(() => {
      router.push(buildUrl(lang, { categoria, q: searchInput, ordenar }), { scroll: false })
    }, 350)
    return () => clearTimeout(timer)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchInput])

  const categoriesObj = useMemo(() => {
    const o = {}
    categories.forEach((c) => { o[c.slug] = c.name })
    return o
  }, [categories])

  const catBySlug = useMemo(() => {
    const m = new Map()
    categories.forEach((c) => m.set(c.slug, c))
    return m
  }, [categories])

  const handleFilterChange = (slug) => {
    router.push(buildUrl(lang, { categoria: slug === 'all' ? '' : slug }), { scroll: false })
  }

  const handleSortChange = (mode) => {
    if (mode === ordenar) return
    router.push(buildUrl(lang, { categoria, q, ordenar: mode }), { scroll: false })
  }

  const pageFrom = total ? (page - 1) * PER_PAGE + 1 : 0
  const pageTo = total ? Math.min(page * PER_PAGE, total) : 0

  return (
    <>
      {/* ← Voltar para Artigos */}
      <div className="max-w-[1400px] mx-auto px-6 md:px-12 pt-6">
        <Link
          href={`/${lang}/artigos`}
          className="inline-flex items-center gap-2 text-sm font-semibold text-[var(--color-brand-accent)] hover:underline"
        >
          <ArrowLeft size={16} /> {t('cientificos_page.back_to_articles')}
        </Link>
      </div>

      {/* Hero — mesmo tamanho que /eventos, com pesquisa + filtros dentro (como /artigos) */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('cientificos_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('cientificos_page.hero_subtitle')}
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
                value={searchInput}
                onChange={(e) => setSearchInput(e.target.value)}
                placeholder={t('cientificos_page.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>

            {/* Filtros por categoria + toggle PT/EN */}
            <div className="sci-filters flex flex-wrap items-center justify-center gap-3 mt-6">
              <FilterButtons
                categories={categoriesObj}
                activeFilter={categoria || 'all'}
                onFilterChange={handleFilterChange}
                dataAttr="sci-filter"
              />
              <div
                className="inline-flex rounded-full border border-brand-divider overflow-hidden"
                role="group"
                aria-label="Idioma"
              >
                {(['pt', 'en']).map((l) => (
                  <Link
                    key={l}
                    href={`/${l}/cientificos`}
                    className={`px-3 py-1.5 text-xs font-semibold transition-colors ${
                      lang === l
                        ? 'bg-brand-accent text-white'
                        : 'bg-brand-bg text-brand-deep opacity-60 hover:opacity-100'
                    }`}
                    aria-current={lang === l ? 'page' : undefined}
                  >
                    {l === 'pt' ? t('cientificos_page.lang_pt') : t('cientificos_page.lang_en')}
                  </Link>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Grid de cards académicos */}
      <section className="bg-brand-bg-alt sci-pagination-scroll">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {/* Barra acima dos cards: link para autores + ordenação (fora do hero) */}
          <div className="flex flex-wrap items-center justify-between gap-3 mb-8">
            <Link
              href={`/${lang}/cientificos/autores`}
              className="inline-flex items-center gap-2 text-sm font-semibold text-[var(--color-brand-accent)] hover:underline"
            >
              <Users size={16} /> {t('cientificos_page.view_all_authors')}
            </Link>
            <div
              className="inline-flex rounded-full border border-brand-divider overflow-hidden"
              role="group"
              aria-label="Ordenar artigos"
            >
              <button
                type="button"
                className={`sci-sort-btn ${ordenar === 'recent' ? 'active' : ''}`}
                onClick={() => handleSortChange('recent')}
              >
                {t('cientificos_page.sort_recent')}
              </button>
              <button
                type="button"
                className={`sci-sort-btn ${ordenar === 'views' ? 'active' : ''}`}
                onClick={() => handleSortChange('views')}
              >
                <Eye size={13} /> {t('cientificos_page.sort_views')}
              </button>
            </div>
          </div>

          {articles.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {articles.map((article) => {
                const cat = article.category?.slug ? catBySlug.get(article.category.slug) : null
                const color = cat?.color || '#0a844f'
                const authors = article.authors || []
                return (
                  <Link
                    key={article.slug}
                    href={`/${lang}/cientificos/${article.slug}`}
                    className="sci-card"
                  >
                    <div className="sci-card-top">
                      {cat ? (
                        <span className="sci-category-badge" style={{ background: `${color}1a`, color }}>
                          {cat.name}
                        </span>
                      ) : (
                        <span
                          className="sci-category-badge"
                          style={{ background: 'var(--color-brand-bg-alt)', color: 'var(--color-brand-deep)' }}
                        >
                          {t('cientificos_page.filter_all')}
                        </span>
                      )}
                      <span className="lang-badge">{(article.lang || lang).toUpperCase()}</span>
                    </div>
                    <h2 className="sci-title">{article.title}</h2>
                    {article.abstract && <p className="sci-abstract">{article.abstract}</p>}
                    {article.keywords && article.keywords.length > 0 && (
                      <div className="sci-keywords">
                        {article.keywords.slice(0, 4).map((kw, i) => (
                          <span key={i} className="sci-keyword">{kw}</span>
                        ))}
                      </div>
                    )}
                    <div className="sci-meta">
                      <time>{formatDate(article.date, lang)}</time>
                      {article.readTime && (
                        <>
                          <span>·</span>
                          <span>{article.readTime} {t('cientificos_page.min_read')}</span>
                        </>
                      )}
                      <span className="sci-views" title={t('cientificos_page.sort_views')}>
                        <Eye size={12} /> {(article.viewCount || 0)}
                      </span>
                      <CitedByBadge doi={article.doi} />
                      {authors.length > 0 && (
                        <div className="sci-authors-preview">
                          {authors.slice(0, 3).map((a, i) => (
                            <div
                              key={i}
                              className="avatar"
                              style={{ background: a.avatarBg || color }}
                              title={a.name}
                            >
                              {(a.avatar || (a.name || '?')[0]).toUpperCase()}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </Link>
                )
              })}
            </div>
          ) : (
            <div className="text-center py-16 text-gray-500">
              <p>{t('cientificos_page.no_results')}</p>
            </div>
          )}

          {/* Paginação — 15 artigos por página, links indexáveis */}
          {totalPages > 1 && (
            <div className="mt-10">
              <p className="text-center text-xs text-brand-deep/50 mb-4">
                {t('cientificos_page.showing_range', {
                  from: pageFrom,
                  to: pageTo,
                  total,
                })}
              </p>
              <nav className="sci-pagination" aria-label={t('cientificos_page.pagination_label')}>
                {page > 1 && (
                  <Link
                    href={buildUrl(lang, { categoria, q, ordenar, page: page - 1 })}
                    className="sci-page-btn"
                    aria-label={t('cientificos_page.pagination_prev')}
                  >
                    <ChevronLeft size={16} />
                  </Link>
                )}
                {pageList(page, totalPages).map((p, i) =>
                  p === 'ellipsis' ? (
                    <span key={`e${i}`} className="sci-page-ellipsis" aria-hidden="true">…</span>
                  ) : (
                    <Link
                      key={p}
                      href={buildUrl(lang, { categoria, q, ordenar, page: p })}
                      className={`sci-page-btn${p === page ? ' active' : ''}`}
                      aria-current={p === page ? 'page' : undefined}
                    >
                      {p}
                    </Link>
                  )
                )}
                {page < totalPages && (
                  <Link
                    href={buildUrl(lang, { categoria, q, ordenar, page: page + 1 })}
                    className="sci-page-btn"
                    aria-label={t('cientificos_page.pagination_next')}
                  >
                    <ChevronRight size={16} />
                  </Link>
                )}
              </nav>
            </div>
          )}
        </div>
      </section>
    </>
  )
}

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
}
