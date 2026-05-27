'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import Link from 'next/link'
import Image from 'next/image'
import { EVENT_CATEGORY_COLORS } from '@/lib/constants'

export default function EventCard({ event, lang = 'pt', variant = 'list' }) {
  const { t } = useContext(LangContext)
  const color = EVENT_CATEGORY_COLORS[event.category] || '#666'
  const dateObj = new Date(event.date + 'T00:00:00')
  const day = dateObj.getDate()
  const month = dateObj.toLocaleString(lang === 'en' ? 'en' : 'pt-PT', { month: 'short' }).toUpperCase()
  const fullDate = dateObj.toLocaleDateString(lang === 'en' ? 'en' : 'pt-PT', {
    day: 'numeric', month: 'long', year: 'numeric',
  })
  const saberMais = t('content.saber_mais')

  if (variant === 'home') {
    return (
      <article className="event-card home-card">
        <div className="event-card-header">
          <div
            className="event-card-date-box"
            style={{ backgroundColor: color }}
          >
            <span className="day">{day}</span>
            <span className="month">{month}</span>
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
        <div className="event-card-content home-card-content">
          <div className="event-date">{fullDate}</div>
          <h3 className="event-card-title">{event.title}</h3>
          <p className="event-card-desc">{event.excerpt}</p>
          <div className="home-card-footer">
            <Link
              href={`/${lang}/eventos/${event.slug}`}
              className="btn btn-primary btn-small w-full"
            >
              {saberMais}
            </Link>
          </div>
        </div>
      </article>
    )
  }

  return (
    <article className="event-card">
      <div className="event-card-header">
        {event.image && (
          <Image
            src={event.image}
            alt={event.title}
            width={400}
            height={192}
            className="event-card-img"
            loading="lazy"
          />
        )}
        <div
          className="event-card-date-box"
          style={{ backgroundColor: color }}
        >
          <span className="event-card-day">{day}</span>
          <span className="event-card-month">{month}</span>
        </div>
        <span
          className="event-badge"
          style={{ backgroundColor: `${color}20`, color: color }}
        >
          {event.categoryLabel}
        </span>
        {event.type && (
          <span className="event-type-badge">
            {event.type === 'Online' ? '💻 Online' : '📍 Presencial'}
          </span>
        )}
      </div>
      <div className="event-card-content">
        <h3 className="event-card-title">{event.title}</h3>
        <p className="event-card-excerpt">{event.excerpt}</p>
        <div className="event-card-meta">
          {event.time && (
            <span className="event-meta-item">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
              {event.time}{event.endTime ? ` - ${event.endTime}` : ''}
            </span>
          )}
          {event.location && (
            <span className="event-meta-item">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/></svg>
              {event.location}
            </span>
          )}
        </div>
        <Link
          href={`/${lang}/eventos/${event.slug}`}
          className="event-card-cta"
        >
          {saberMais}
        </Link>
      </div>
    </article>
  )
}
