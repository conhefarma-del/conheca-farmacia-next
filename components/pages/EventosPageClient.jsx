'use client'

import { useState, useMemo, useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import Link from 'next/link'
import Image from 'next/image'
import { EVENT_CATEGORY_COLORS } from '@/lib/constants'
import NewsletterSection from '@/components/ui/NewsletterSection'

export default function EventosPageClient({ events, lang }) {
  const { t } = useContext(LangContext)
  const [activeStatus, setActiveStatus] = useState('upcoming')
  const [activeCategory, setActiveCategory] = useState('all')

  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const filteredEvents = useMemo(() => {
    let result = events.map(event => {
      const eventDate = new Date(event.date + 'T00:00:00')
      return {
        ...event,
        temporalStatus: eventDate >= today ? 'upcoming' : 'past',
      }
    })

    result = result.filter(e => e.temporalStatus === activeStatus)

    if (activeCategory !== 'all') {
      result = result.filter(e => e.category === activeCategory)
    }

    if (activeStatus === 'upcoming') {
      result.sort((a, b) => new Date(a.date) - new Date(b.date))
    } else {
      result.sort((a, b) => new Date(b.date) - new Date(a.date))
    }

    return result
  }, [events, activeStatus, activeCategory, today])

  const formatDay = (dateStr) => {
    const dateObj = new Date(dateStr + 'T00:00:00')
    return String(dateObj.getDate()).padStart(2, '0')
  }

  const formatMonth = (dateStr) => {
    const dateObj = new Date(dateStr + 'T00:00:00')
    const months = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ']
    return months[dateObj.getMonth()]
  }

  return (
    <>
      {/* Hero Section — matches MPA eventos.html */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('eventos_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('eventos_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Filters Section — matches MPA */}
      <section className="events-filter-section">
        <div className="container-center">
          <div className="max-w-5xl mx-auto">
            {/* Temporal Filter (Toggle) */}
            <div className="temporal-filter mb-12">
              <div className="flex justify-center gap-4 flex-wrap">
                <button
                  className={`temporal-btn ${activeStatus === 'upcoming' ? 'active' : ''}`}
                  data-status="upcoming"
                  onClick={() => setActiveStatus('upcoming')}
                >
                  {t('eventos_page.filter_upcoming')}
                </button>
                <button
                  className={`temporal-btn ${activeStatus === 'past' ? 'active' : ''}`}
                  data-status="past"
                  onClick={() => setActiveStatus('past')}
                >
                  {t('eventos_page.filter_past')}
                </button>
              </div>
            </div>

            {/* Category Filter */}
            <div className="category-filter">
              <div className="flex justify-center gap-3 flex-wrap">
                <button
                  className={`filter-btn ${activeCategory === 'all' ? 'active' : ''}`}
                  data-category="all"
                  onClick={() => setActiveCategory('all')}
                >
                  {t('eventos_page.filter_all')}
                </button>
                {['workshop', 'palestra', 'congresso', 'seminario', 'outro'].map((key) => (
                  <button
                    key={key}
                    className={`filter-btn ${activeCategory === key ? 'active' : ''}`}
                    data-category={key}
                    onClick={() => setActiveCategory(key)}
                  >
                    {t(`eventos_page.filter_${key}`)}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Events Grid — matches MPA */}
      <section className="events-grid-section bg-brand-bg-alt">
        <div className="container-center">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {filteredEvents.map((event) => {
              const color = EVENT_CATEGORY_COLORS[event.category] || '#00493a'
              const spotsLeft = event.capacity - (event.inscriptionCount || 0)
              const isCapacityFull = spotsLeft <= 0
              const isPast = event.temporalStatus === 'past'

              return (
                <article key={event.slug} className="event-card">
                  <div className="event-card-header relative">
                    <div
                      className="event-card-date-box"
                      style={{ backgroundColor: color }}
                    >
                      <div className="day">{formatDay(event.date)}</div>
                      <div className="month">{formatMonth(event.date)}</div>
                    </div>
                    {event.image && (
                      <Image
                        src={event.image}
                        alt={event.title}
                        width={400}
                        height={192}
                        className="event-card-image"
                        loading="lazy"
                      />
                    )}
                  </div>

                  <div className="event-card-content">
                    <div className="flex flex-row flex-wrap items-center gap-2 mb-4">
                      <span
                        className="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider"
                        style={{ backgroundColor: `${color}20`, color: color, border: `1px solid ${color}40` }}
                      >
                        {event.categoryLabel}
                      </span>
                      <span className="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider bg-slate-100 text-slate-600 border border-slate-200">
                        {event.type === 'online' ? 'Online' : 'Presencial'}
                      </span>
                    </div>

                    <h3 className="event-card-title">{event.title}</h3>
                    <p className="event-card-excerpt">{event.excerpt}</p>

                    <div className="event-card-meta">
                      <div className="event-meta-item">
                        <span>{event.time} — {event.endTime}</span>
                      </div>
                      <div className="event-meta-item">
                        <span>{event.location}</span>
                      </div>
                      {spotsLeft > 0 ? (
                        <div className="event-meta-item">
                          <span>{spotsLeft} vagas disponíveis</span>
                        </div>
                      ) : (
                        <div className="event-meta-item" style={{ color: '#dc2626', fontWeight: 600 }}>
                          <span>Evento completo</span>
                        </div>
                      )}
                    </div>

                    <div className="event-card-actions mt-auto">
                      <Link
                        href={`/${lang}/eventos/${event.slug}`}
                        className="btn btn-secondary btn-small"
                        aria-label={`Ver evento: ${event.title}`}
                      >
                        {t('content.saber_mais')}
                      </Link>
                      <Link
                        href={`/${lang}/inscricao?evento=${event.slug}`}
                        className={`btn btn-primary btn-small ${isPast || isCapacityFull ? 'opacity-50 pointer-events-none' : ''}`}
                      >
                        {isCapacityFull
                          ? (t('eventos_page.evento_completo') || 'Completo')
                          : isPast
                            ? (t('eventos_page.ver_gravacao') || 'Ver Gravação')
                            : (t('content.inscrever') || 'Inscrever-me')
                        }
                      </Link>
                    </div>
                  </div>
                </article>
              )
            })}
          </div>

          {/* No Results State */}
          {filteredEvents.length === 0 && (
            <div className="text-center py-20">
              <div className="text-6xl mb-4">&#128269;</div>
              <h3 className="text-xl font-bold text-brand-deep">
                {t('eventos_page.no_results_title') || 'Nenhum evento encontrado'}
              </h3>
              <p className="text-brand-deep/60">
                {t('eventos_page.no_results_text') || 'Tente mudar os filtros ou volte em breve para novos eventos!'}
              </p>
            </div>
          )}
        </div>
      </section>

      <NewsletterSection />
    </>
  )
}
