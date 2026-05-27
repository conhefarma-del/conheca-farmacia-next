'use client'

import { useState, useMemo, useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import HeroSection from '@/components/ui/HeroSection'
import FilterButtons from '@/components/ui/FilterButtons'
import ArticleCard from '@/components/ui/ArticleCard'
import NewsletterSection from '@/components/ui/NewsletterSection'

export default function ArticlesPageClient({ articles, lang, categoryColors, categories }) {
  const { t } = useContext(LangContext)
  const [currentFilter, setCurrentFilter] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')

  const filteredArticles = useMemo(() => {
    return articles.filter((article) => {
      const matchesCategory = currentFilter === 'all' || article.category === currentFilter
      const matchesSearch =
        !searchTerm ||
        article.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        article.excerpt?.toLowerCase().includes(searchTerm.toLowerCase())
      return matchesCategory && matchesSearch
    })
  }, [articles, currentFilter, searchTerm])

  return (
    <>
      <HeroSection
        title={t('artigos_page.hero_title')}
        subtitle={t('artigos_page.hero_subtitle')}
      />

      <section className="max-w-7xl mx-auto px-4 py-8">
        {/* Search */}
        <div className="max-w-md mx-auto mb-8">
          <input
            type="text"
            id="search-input"
            placeholder={t('artigos_page.search_placeholder')}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-700 dark:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-[var(--accent)]"
          />
        </div>

        {/* Category filters */}
        <FilterButtons
          categories={categories}
          currentFilter={currentFilter}
          onFilterChange={setCurrentFilter}
          categoryColors={categoryColors}
          t={t}
          i18nPrefix="artigos_page.filters"
        />

        {/* Articles grid */}
        {filteredArticles.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredArticles.map((article) => (
              <ArticleCard key={article.slug} article={article} lang={lang} />
            ))}
          </div>
        ) : (
          <div id="no-results" className="text-center py-16 text-gray-500">
            <p>{t('artigos_page.no_results') || 'Nenhum artigo encontrado.'}</p>
          </div>
        )}
      </section>

      <NewsletterSection keys="artigos_page" />
    </>
  )
}
