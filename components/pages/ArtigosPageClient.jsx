'use client'

import { useState, useMemo, useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import Link from 'next/link'
import Image from 'next/image'
import { ARTICLE_CATEGORY_COLORS, ARTICLE_CATEGORIES } from '@/lib/constants'
import NewsletterSection from '@/components/ui/NewsletterSection'

export default function ArtigosPageClient({ articles, lang }) {
  const { t } = useContext(LangContext)
  const [activeFilter, setActiveFilter] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')

  const filteredArticles = useMemo(() => {
    let result = articles

    if (activeFilter !== 'all') {
      result = result.filter(a => a.category === activeFilter)
    }

    if (searchTerm.trim()) {
      const term = searchTerm.toLowerCase()
      result = result.filter(a =>
        a.title?.toLowerCase().includes(term) ||
        a.excerpt?.toLowerCase().includes(term)
      )
    }

    return result
  }, [articles, activeFilter, searchTerm])

  const lerMais = t('content.ler_mais')

  return (
    <>
      {/* Hero Section */}
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-20 md:py-32">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('artigos_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('artigos_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Search & Filters Section */}
      <section className="articles-filter-section">
        <div className="container-center">
          <div className="max-w-4xl mx-auto">
            {/* Search Bar */}
            <div className="relative mb-8">
              <span className="absolute inset-y-0 left-0 flex items-center pl-4 text-brand-deep/40">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </span>
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder={t('artigos_page.search_placeholder')}
                className="w-full pl-12 pr-4 py-4 rounded-2xl border border-brand-divider shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
              />
            </div>

            {/* Category Filters */}
            <div className="flex flex-wrap justify-center gap-3 pb-8">
              <button
                className={`filter-btn ${activeFilter === 'all' ? 'active' : ''}`}
                data-filter="all"
                onClick={() => setActiveFilter('all')}
              >
                {t('artigos_page.filter_all')}
              </button>
              {ARTICLE_CATEGORIES.map((key) => (
                <button
                  key={key}
                  className={`filter-btn ${activeFilter === key ? 'active' : ''}`}
                  data-filter={key}
                  onClick={() => setActiveFilter(key)}
                >
                  {t(`artigos_page.filter_${key.replace(/-/g, '_')}`)}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Articles Grid */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredArticles.map((article) => {
              const color = ARTICLE_CATEGORY_COLORS[article.category] || '#666'
              return (
                <article key={article.slug} className="article-card border border-brand-divider/10">
                  <Link href={`/${lang}/artigos/${article.slug}`} className="block">
                    {article.image && (
                      <Image
                        src={article.image}
                        alt={article.title}
                        width={400}
                        height={192}
                        className="article-card-img"
                        loading="lazy"
                      />
                    )}
                  </Link>
                  <div className="article-card-content">
                    <span
                      className="article-tag"
                      style={{
                        backgroundColor: `${color}20`,
                        color: color,
                        border: `1px solid ${color}40`,
                      }}
                    >
                      {article.categoryLabel}
                    </span>
                    <Link href={`/${lang}/artigos/${article.slug}`}>
                      <h3 className="article-card-title">{article.title}</h3>
                    </Link>
                    <p className="article-card-excerpt">{article.excerpt}</p>
                    <Link
                      href={`/${lang}/artigos/${article.slug}`}
                      className="article-card-link"
                      aria-label={`Ler artigo: ${article.title}`}
                    >
                      {lerMais} <span>&rarr;</span>
                    </Link>
                  </div>
                </article>
              )
            })}
          </div>

          {/* No Results State */}
          {filteredArticles.length === 0 && (
            <div className="text-center py-20">
              <div className="text-6xl mb-4">&#128269;</div>
              <h3 className="text-xl font-bold text-brand-deep">
                {t('artigos_page.no_results_title') || 'Nenhum artigo encontrado'}
              </h3>
              <p className="text-brand-deep/60">
                {t('artigos_page.no_results_text') || 'Tente termos diferentes ou remova os filtros.'}
              </p>
            </div>
          )}
        </div>
      </section>

      {/* Newsletter Section */}
      <NewsletterSection />
    </>
  )
}
