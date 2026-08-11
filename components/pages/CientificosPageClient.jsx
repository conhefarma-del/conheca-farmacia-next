'use client'

import { useState, useMemo, useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import FilterButtons from '@/components/ui/FilterButtons'
import { ArrowLeft, Search, Eye, Users } from 'lucide-react'

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
}

/**
 * CientificosPageClient — listagem pública dos Artigos Científicos.
 * Hero do mesmo tamanho que /eventos, com pesquisa + filtros por
 * categoria (da BD) e toggle PT/EN dentro do hero (como /artigos).
 */
export default function CientificosPageClient({ articles = [], categories = [], lang = 'pt' }) {
  const { t } = useContext(LangContext)
  const [currentFilter, setCurrentFilter] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')
  const [sortMode, setSortMode] = useState('recent') // 'recent' | 'views'

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

  const filteredArticles = useMemo(() => {
    const filtered = articles.filter((article) => {
      const matchesCategory = currentFilter === 'all' || article.category?.slug === currentFilter
      const matchesSearch =
        !searchTerm ||
        article.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        article.abstract?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (article.keywords || []).some((k) => k.toLowerCase().includes(searchTerm.toLowerCase()))
      return matchesCategory && matchesSearch
    })
    return filtered.sort((a, b) => {
      if (sortMode === 'views') {
        return (b.viewCount || 0) - (a.viewCount || 0)
      }
      // 'recent' — por data de publicação, mais recente primeiro
      return new Date(b.date || 0) - new Date(a.date || 0)
    })
  }, [articles, currentFilter, searchTerm, sortMode])

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
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder={t('cientificos_page.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>

            {/* Filtros por categoria + toggle PT/EN */}
            <div className="sci-filters flex flex-wrap items-center justify-center gap-3 mt-6">
              <FilterButtons
                categories={categoriesObj}
                activeFilter={currentFilter}
                onFilterChange={setCurrentFilter}
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
      <section className="bg-brand-bg-alt">
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
                className={`sci-sort-btn ${sortMode === 'recent' ? 'active' : ''}`}
                onClick={() => setSortMode('recent')}
              >
                {t('cientificos_page.sort_recent')}
              </button>
              <button
                type="button"
                className={`sci-sort-btn ${sortMode === 'views' ? 'active' : ''}`}
                onClick={() => setSortMode('views')}
              >
                <Eye size={13} /> {t('cientificos_page.sort_views')}
              </button>
            </div>
          </div>

          {filteredArticles.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredArticles.map((article) => {
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
        </div>
      </section>
    </>
  )
}
