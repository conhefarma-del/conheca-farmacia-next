'use client'

import { useContext, useRef, useCallback } from 'react'
import { LangContext } from '@/lib/contexts'
import ArticleCard from '@/components/ui/ArticleCard'

export default function RelatedArticles({ articles, lang }) {
  const { t } = useContext(LangContext)
  const scrollRef = useRef(null)

  if (!articles.length) return null

  const useCarousel = articles.length >= 3

  const scrollByCard = useCallback((direction) => {
    if (!scrollRef.current) return
    const card = scrollRef.current.querySelector('.article-card')
    const cardWidth = card ? card.offsetWidth : 300
    const gap = 24
    scrollRef.current.scrollBy({ left: direction * (cardWidth + gap), behavior: 'smooth' })
  }, [])

  if (!useCarousel) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {articles.map((article) => (
          <ArticleCard key={article.slug} article={article} lang={lang} />
        ))}
      </div>
    )
  }

  return (
    <div className="related-carousel-wrapper">
      <div ref={scrollRef} className="related-carousel-container">
        {articles.map((article) => (
          <div key={article.slug} className="related-carousel-item">
            <ArticleCard article={article} lang={lang} />
          </div>
        ))}
      </div>
      <button
        className="carousel-nav-btn carousel-nav-btn--left"
        aria-label="Artigo anterior"
        onClick={() => scrollByCard(-1)}
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M15 18l-6-6 6-6"/></svg>
      </button>
      <button
        className="carousel-nav-btn carousel-nav-btn--right"
        aria-label="Próximo artigo"
        onClick={() => scrollByCard(1)}
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 18l6-6-6-6"/></svg>
      </button>
    </div>
  )
}
