'use client'

import { useState, useMemo } from 'react'
import HeroSection from '@/components/ui/HeroSection'
import TemporalFilter from '@/components/ui/TemporalFilter'
import FilterButtons from '@/components/ui/FilterButtons'
import EventCard from '@/components/ui/EventCard'
import NewsletterSection from '@/components/ui/NewsletterSection'

export default function EventosPageClient({ events, lang, t, categoryColors, categories }) {
  const [currentStatus, setCurrentStatus] = useState('upcoming')
  const [currentCategory, setCurrentCategory] = useState('all')

  const today = new Date().toISOString().split('T')[0]

  const filteredEvents = useMemo(() => {
    return events
      .map((event) => ({
        ...event,
        status: event.date >= today ? 'upcoming' : 'past',
      }))
      .filter((event) => {
        const matchesStatus = event.status === currentStatus
        const matchesCategory = currentCategory === 'all' || event.category === currentCategory
        return matchesStatus && matchesCategory
      })
      .sort((a, b) => {
        if (currentStatus === 'upcoming') return a.date.localeCompare(b.date)
        return b.date.localeCompare(a.date)
      })
  }, [events, currentStatus, currentCategory, today])

  return (
    <>
      <HeroSection
        title={t('eventos_page.hero_title')}
        subtitle={t('eventos_page.hero_subtitle')}
      />

      <section className="max-w-7xl mx-auto px-4 py-8">
        <TemporalFilter
          currentStatus={currentStatus}
          onStatusChange={setCurrentStatus}
          t={t}
          upcomingKey="eventos_page.upcoming"
          pastKey="eventos_page.past"
        />

        <FilterButtons
          categories={categories}
          currentFilter={currentCategory}
          onFilterChange={setCurrentCategory}
          categoryColors={categoryColors}
          t={t}
          i18nPrefix="eventos_page.filters"
        />

        {filteredEvents.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {filteredEvents.map((event) => (
              <EventCard key={event.slug} event={event} lang={lang} t={t} />
            ))}
          </div>
        ) : (
          <div className="text-center py-16 text-gray-500">
            <p>{t('eventos_page.no_results') || 'Nenhum evento encontrado.'}</p>
          </div>
        )}
      </section>

      <NewsletterSection keys="eventos_page" />
    </>
  )
}
