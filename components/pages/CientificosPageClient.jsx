'use client'

import { useState, useMemo, useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import FilterButtons from '@/components/ui/FilterButtons'
import HeroSection from '@/components/ui/HeroSection'
import { ArrowLeft, Search } from 'lucide-react'

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
}

/**
 * CientificosPageClient — listagem pública dos Artigos Científicos.
 * Hero próprio, filtros por categoria (da BD), toggle PT/EN (link que
 * filtra a listagem pela língua), pesquisa e grid de cards académicos.
 */
export default function CientificosPageClient({ articles = [], categories = [], lang = 'pt' }) {
  const { t } = useContext(LangContext)
  const [currentFilter, setCurrentFilter] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')

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
    return articles.filter((article) => {
      const matchesCategory = currentFilter === 'all' || article.category?.slug === currentFilter
      const matchesSearch =
        !searchTerm ||
        article.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        article.abstract?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (article.keywords || []).some((k) => k.toLowerCase().includes(searchTerm.toLowerCase()))
      return matchesCategory && matchesSearch
    })
  }, [articles, currentFilter, searchTerm])

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

      {/* Hero */}
      <HeroSection
        title={t('cientificos_page.hero_title')}
        subtitle={t('cientificos_page.hero_subtitle')}
      />

      {/* Filtros + toggle PT/EN + pesquisa */}
      <section className="max-w-[1400px] mx-auto px-6 md:px-12 pb-10">
        <div className="flex flex-col md:flex-row md:items-center gap-4">
          <FilterButtons
            categories={categoriesObj}
            activeFilter={currentFilter}
            onFilterChange={setCurrentFilter}
            dataAttr="sci-filter"
          />
          <div className="flex items-center gap-3 md:ml-auto">
            {/* Toggle PT/EN (filtra a listagem) */}
            <div className="inline-flex rounded-full border border-[var(--color-brand-divider)] overflow-hidden" role="group" aria-label="Idioma">
              {(['pt', 'en']).map((l) => (
                <Link
                  key={l}
                  href={`/${l}/cientificos`}
                  className={`px-3 py-1.5 text-xs font-semibold transition-colors ${
                    lang === l
                      ? 'bg-[var(--color-brand-accent)] text-white'
                      : 'bg-white text-[var(--color-brand-deep)] opacity-60 hover:opacity-100'
                  }`}
                  aria-current={lang === l ? 'page' : undefined}
                >
                  {l === 'pt' ? t('cientificos_page.lang_pt') : t('cientificos_page.lang_en')}
                </Link>
              ))}
            </div>
            <div className="relative">
              <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
              <input
                type="search"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder={t('cientificos_page.search_placeholder')}
                className="w-52 md:w-64 pl-9 pr-3 py-2 rounded-lg border border-gray-300 dark:border-gray-700 dark:bg-gray-800 text-sm focus:outline-none focus:ring-2 focus:ring-[var(--color-brand-accent)]"
              />
            </div>
          </div>
        </div>

        {/* Grid de cards académicos */}
        {filteredArticles.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-10">
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
                      <span className="sci-category-badge" style={{ background: '#f3f4f1', color: '#6b7280' }}>
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
      </section>
    </>
  )
}
