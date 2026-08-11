'use client'

import { useState, useMemo, useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import { ArrowLeft, Search, BookOpen, UserRound, FileText } from 'lucide-react'

/**
 * CientificosAutoresPageClient — índice de autores dos Artigos Científicos.
 * Pesquisa por nome/afiliação, filtro "autor correspondente", ordenação
 * A–Z ou por nº de artigos publicados.
 */
export default function CientificosAutoresPageClient({ authors = [], lang = 'pt' }) {
  const { t } = useContext(LangContext)
  const [searchTerm, setSearchTerm] = useState('')
  const [sortMode, setSortMode] = useState('az') // 'az' | 'articles'
  const [filterMode, setFilterMode] = useState('all') // 'all' | 'corresponding'

  const filteredAuthors = useMemo(() => {
    const term = searchTerm.trim().toLowerCase()
    const filtered = authors.filter((a) => {
      if (filterMode === 'corresponding' && !a.isCorresponding) return false
      if (!term) return true
      return (
        a.name?.toLowerCase().includes(term) ||
        a.institution?.toLowerCase().includes(term) ||
        a.department?.toLowerCase().includes(term) ||
        a.role?.toLowerCase().includes(term)
      )
    })
    return filtered.sort((a, b) => {
      if (sortMode === 'articles') return (b.articleCount || 0) - (a.articleCount || 0)
      return a.name?.localeCompare(b.name, lang === 'en' ? 'en' : 'pt')
    })
  }, [authors, searchTerm, sortMode, filterMode, lang])

  const countLabel = (n) =>
    n === 1 ? t('cientifico_autores.articles_count_one') : t('cientifico_autores.articles_count_other', { count: n })

  return (
    <>
      {/* ← Voltar para Artigos Científicos */}
      <div className="max-w-[1100px] mx-auto px-6 md:px-12 pt-6">
        <Link
          href={`/${lang}/cientificos`}
          className="inline-flex items-center gap-2 text-sm font-semibold text-[var(--color-brand-accent)] hover:underline"
        >
          <ArrowLeft size={16} /> {t('cientifico_author.back_to_cientificos')}
        </Link>
      </div>

      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('cientifico_autores.title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('cientifico_autores.subtitle')}
            </p>

            {/* Pesquisa por nome / afiliação */}
            <div className="max-w-2xl mx-auto mt-10 relative">
              <Search
                size={18}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-brand-deep/40"
                aria-hidden="true"
              />
              <input
                type="search"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder={t('cientifico_autores.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Lista de autores */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1100px] mx-auto px-6 md:px-12 py-12">
          {/* Barra: filtros + ordenação */}
          <div className="flex flex-wrap items-center justify-between gap-3 mb-8">
            <div className="inline-flex rounded-full border border-brand-divider overflow-hidden" role="group" aria-label="Filtrar autores">
              <button
                type="button"
                className={`sci-sort-btn ${filterMode === 'all' ? 'active' : ''}`}
                onClick={() => setFilterMode('all')}
              >
                {t('cientifico_autores.filter_all')}
              </button>
              <button
                type="button"
                className={`sci-sort-btn ${filterMode === 'corresponding' ? 'active' : ''}`}
                onClick={() => setFilterMode('corresponding')}
              >
                {t('cientifico_autores.filter_corresponding')}
              </button>
            </div>
            <div className="inline-flex rounded-full border border-brand-divider overflow-hidden" role="group" aria-label="Ordenar autores">
              <button
                type="button"
                className={`sci-sort-btn ${sortMode === 'az' ? 'active' : ''}`}
                onClick={() => setSortMode('az')}
              >
                {t('cientifico_autores.sort_az')}
              </button>
              <button
                type="button"
                className={`sci-sort-btn ${sortMode === 'articles' ? 'active' : ''}`}
                onClick={() => setSortMode('articles')}
              >
                <FileText size={13} /> {t('cientifico_autores.sort_most_articles')}
              </button>
            </div>
          </div>

          {filteredAuthors.length > 0 ? (
            <div className="sci-authors-index-grid">
              {filteredAuthors.map((author) => (
                <div key={author.id} className="sci-author-index-card">
                  <Link
                    href={`/${lang}/cientificos/autores/${author.slug}`}
                    className="sci-author-index-main"
                  >
                    <span className="sci-avatar" style={{ background: author.avatarBg || '#0a844f' }}>
                      {(author.avatar || (author.name || '?')[0]).toUpperCase()}
                    </span>
                    <span className="sci-author-index-info">
                      <span className="sci-author-index-name">{author.name}</span>
                      {(author.institution || author.department || author.role) && (
                        <span className="sci-author-index-affil">
                          {[author.role, author.institution, author.department].filter(Boolean).join(' · ')}
                        </span>
                      )}
                    </span>
                  </Link>
                  <div className="sci-author-index-actions">
                    <span className="sci-author-count">{countLabel(author.articleCount)}</span>
                    <div className="sci-author-index-links">
                      <Link href={`/${lang}/cientificos/autores/${author.slug}`}>
                        <BookOpen size={13} /> {t('cientifico_author.view_articles')}
                      </Link>
                      <Link href={`/${lang}/cientificos/autores/${author.slug}/perfil`}>
                        <UserRound size={13} /> {t('cientifico_author.view_profile')}
                      </Link>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-16 text-gray-500">
              <p>{t('cientifico_autores.no_results')}</p>
            </div>
          )}
        </div>
      </section>
    </>
  )
}
