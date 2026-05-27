'use client'

import { useState, useMemo, useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { LIVE_CATEGORY_COLORS } from '@/lib/constants'
import LiveCard from '@/components/ui/LiveCard'
import NewsletterSection from '@/components/ui/NewsletterSection'

export default function LivesPageClient({ lives, lang }) {
  const { t } = useContext(LangContext)
  const [activeStatus, setActiveStatus] = useState('upcoming')
  const [activeCategory, setActiveCategory] = useState('all')

  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const filteredLives = useMemo(() => {
    let result = lives.map(live => {
      const liveDate = new Date((live.data || live.date) + 'T00:00:00')
      return {
        ...live,
        temporalStatus: liveDate >= today ? 'upcoming' : 'past',
      }
    })

    result = result.filter(l => l.temporalStatus === activeStatus)

    if (activeCategory !== 'all') {
      result = result.filter(l => (l.categoria || l.category) === activeCategory)
    }

    if (activeStatus === 'upcoming') {
      result.sort((a, b) => new Date(a.data || a.date) - new Date(b.data || b.date))
    } else {
      result.sort((a, b) => new Date(b.data || b.date) - new Date(a.data || a.date))
    }

    return result
  }, [lives, activeStatus, activeCategory, today])

  return (
    <>
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('lives_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('lives_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Filter Section */}
      <section className="events-filter-section">
        <div className="container-center">
          <div className="max-w-5xl mx-auto">
            {/* Temporal Filter */}
            <div className="temporal-filter mb-12">
              <div className="flex justify-center gap-4 flex-wrap">
                <button
                  className={`temporal-btn${activeStatus === 'upcoming' ? ' active' : ''}`}
                  data-status="upcoming"
                  onClick={() => setActiveStatus('upcoming')}
                >
                  {t('lives_page.filter_upcoming')}
                </button>
                <button
                  className={`temporal-btn${activeStatus === 'past' ? ' active' : ''}`}
                  data-status="past"
                  onClick={() => setActiveStatus('past')}
                >
                  {t('lives_page.filter_past')}
                </button>
              </div>
            </div>

            {/* Category Filter */}
            <div className="category-filter">
              <div className="flex justify-center gap-3 flex-wrap">
                <button
                  className={`filter-btn${activeCategory === 'all' ? ' active' : ''}`}
                  data-category="all"
                  onClick={() => setActiveCategory('all')}
                >
                  {t('lives_page.filter_all')}
                </button>
                <button
                  className={`filter-btn${activeCategory === 'live' ? ' active' : ''}`}
                  data-category="live"
                  onClick={() => setActiveCategory('live')}
                >
                  {t('lives_page.filter_live')}
                </button>
                <button
                  className={`filter-btn${activeCategory === 'webinar' ? ' active' : ''}`}
                  data-category="webinar"
                  onClick={() => setActiveCategory('webinar')}
                >
                  {t('lives_page.filter_webinar')}
                </button>
                <button
                  className={`filter-btn${activeCategory === 'entrevista' ? ' active' : ''}`}
                  data-category="entrevista"
                  onClick={() => setActiveCategory('entrevista')}
                >
                  {t('lives_page.filter_entrevista')}
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Lives Grid */}
      <section className="events-grid-section bg-brand-bg-alt">
        <div className="container-center">
          {filteredLives.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {filteredLives.map(live => (
                <LiveCard key={live.slug} live={live} lang={lang} />
              ))}
            </div>
          ) : (
            <div className="text-center py-20">
              <div className="text-6xl mb-4">🔍</div>
              <h3 className="text-xl font-bold text-brand-deep mb-2">
                {t('lives_page.no_results_title')}
              </h3>
              <p className="text-brand-deep/60">
                {t('lives_page.no_results_text')}
              </p>
            </div>
          )}
        </div>
      </section>

      {/* Newsletter */}
      <NewsletterSection />
    </>
  )
}
