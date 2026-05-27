'use client'

import { useState, useMemo } from 'react'
import HeroSection from '@/components/ui/HeroSection'
import TemporalFilter from '@/components/ui/TemporalFilter'
import FilterButtons from '@/components/ui/FilterButtons'
import LiveCard from '@/components/ui/LiveCard'
import NewsletterSection from '@/components/ui/NewsletterSection'

export default function LivesPageClient({ lives, lang, t, categoryColors, categories }) {
  const [currentStatus, setCurrentStatus] = useState('upcoming')
  const [currentCategory, setCurrentCategory] = useState('all')

  const today = new Date().toISOString().split('T')[0]

  const filteredLives = useMemo(() => {
    return lives
      .map((live) => ({
        ...live,
        status: live.data >= today ? 'upcoming' : 'past',
      }))
      .filter((live) => {
        const matchesStatus = live.status === currentStatus
        const matchesCategory = currentCategory === 'all' || live.categoria === currentCategory
        return matchesStatus && matchesCategory
      })
      .sort((a, b) => {
        if (currentStatus === 'upcoming') return a.data.localeCompare(b.data)
        return b.data.localeCompare(a.data)
      })
  }, [lives, currentStatus, currentCategory, today])

  return (
    <>
      <HeroSection
        title={t('lives_page.hero_title')}
        subtitle={t('lives_page.hero_subtitle')}
      />

      <section className="max-w-7xl mx-auto px-4 py-8">
        <TemporalFilter
          currentStatus={currentStatus}
          onStatusChange={setCurrentStatus}
          t={t}
          upcomingKey="lives_page.upcoming"
          pastKey="lives_page.past"
        />

        <FilterButtons
          categories={categories}
          currentFilter={currentCategory}
          onFilterChange={setCurrentCategory}
          categoryColors={categoryColors}
          t={t}
          i18nPrefix="lives_page.filters"
        />

        {filteredLives.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {filteredLives.map((live) => (
              <LiveCard key={live.slug} live={live} lang={lang} t={t} />
            ))}
          </div>
        ) : (
          <div className="text-center py-16 text-gray-500">
            <p>{t('lives_page.no_results') || 'Nenhuma live encontrada.'}</p>
          </div>
        )}
      </section>

      <NewsletterSection keys="lives_page" />
    </>
  )
}
