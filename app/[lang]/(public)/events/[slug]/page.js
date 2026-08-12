import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getSectionHref } from '@/lib/i18n-routes'
import { getEventBySlug, getEvents, getEventInscriptionCount } from '@/lib/api/events'
import { buildEventSchema, buildBreadcrumbSchema } from '@/lib/seo'
import { EVENT_CATEGORY_COLORS, SITE_URL } from '@/lib/constants'
import { BLUR_PLACEHOLDER } from '@/lib/images'
import { createClient } from '@/lib/supabase/server'
import { findTranslationByEntityId } from '@/lib/api/translations'
import { formatEventType } from '@/lib/utils/event-type'
import Breadcrumb from '@/components/ui/Breadcrumb'
import CapacityBar from '@/components/content/CapacityBar'
import RegistrationButton from '@/components/content/RegistrationButton'
import SpeakersList from '@/components/content/SpeakersList'
import SimilarEvents from '@/components/content/SimilarEvents'
import EventViewTracker from '@/components/content/EventViewTracker'
import TranslationFallbackBanner from '@/components/i18n/TranslationFallbackBanner'
import Image from 'next/image'
import Link from 'next/link'
import { notFound } from 'next/navigation'

export const revalidate = 3600

export async function generateStaticParams() {
  try {
    const events = await getEvents()
    return events.map((event) => ({ slug: event.slug }))
  } catch {
    return []
  }
}

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  let event
  try {
    event = await getEventBySlug(slug, safeLang)
  } catch {
    return { title: 'Evento — Conheça Farmácia' }
  }

  if (!event) {
    return { title: 'Evento não encontrado — Conheça Farmácia' }
  }

  // Build hreflang with the correct slug for each language
  // Both /pt/eventos and /en/events are valid URL paths for the same content.
  const langs = { 'pt': `/pt/eventos/${event.slug}` }
  if (safeLang === 'en' && event.hasOwnProperty('event_id')) {
    // We came in via EN translation; the base row is the PT row above,
    // so event.slug IS the PT slug and we just need the EN slug.
    const enSlug = slug
    langs['en'] = `/en/events/${enSlug}`
  } else {
    // We came in via PT (or PT fallback). Look up the EN slug.
    try {
      const supabase = await createClient()
      const enTr = await findTranslationByEntityId(supabase, 'event', event.id, 'en')
      if (enTr) langs['en'] = `/en/events/${enTr.slug}`
    } catch { /* leave out */ }
  }

  const eventUrl = `${SITE_URL}/${safeLang}/events/${event.slug}`

  return {
    title: `${event.title} — Conheça Farmácia`,
    description: event.description || event.excerpt || event.title,
    alternates: {
      canonical: eventUrl,
      languages: langs,
    },
    openGraph: {
      title: event.title,
      description: event.description || event.excerpt,
      url: eventUrl,
      type: 'website',
      images: event.image ? [{ url: event.image }] : [],
    },
    twitter: {
      card: 'summary_large_image',
      title: event.title,
      description: event.description || event.excerpt,
      images: event.image ? [event.image] : [],
    },
  }
}

function calculateDuration(startTime, endTime) {
  if (!startTime || !endTime) return null
  const [sh, sm] = startTime.split(':').map(Number)
  const [eh, em] = endTime.split(':').map(Number)
  const totalMin = (eh * 60 + em) - (sh * 60 + sm)
  if (totalMin <= 0) return null
  const hours = Math.floor(totalMin / 60)
  const mins = totalMin % 60
  if (hours > 0 && mins > 0) return `${hours}h${mins}min`
  if (hours > 0) return `${hours}h`
  return `${mins}min`
}

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const date = new Date(dateStr + 'T00:00:00')
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  return date.toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
}

export default async function EventDetailPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath) => t(translations, keyPath)

  let event
  try {
    event = await getEventBySlug(slug, safeLang)
  } catch (err) {
    console.error('Error fetching event:', err)
    notFound()
  }
  if (!event) notFound()

  const color = EVENT_CATEGORY_COLORS[event.category] || '#00493a'
  const eventUrl = `${SITE_URL}/${safeLang}/events/${event.slug}`
  const isPast = event.date < new Date().toISOString().split('T')[0]
  const duration = calculateDuration(event.time, event.endTime)

  // Inscription count
  let inscriptionCount = 0
  try {
    inscriptionCount = await getEventInscriptionCount(event.id)
  } catch {}

  const isFull = event.capacity && inscriptionCount >= event.capacity

  // Similar events
  let similarEvents = []
  try {
    const allEvents = await getEvents(safeLang)
    similarEvents = allEvents
      .filter((e) => e.category === event.category && e.slug !== event.slug)
      .slice(0, 3)
  } catch {}

  // Breadcrumb levels — use /events for EN, /eventos for PT
  const eventsListHref = safeLang === 'en' ? `/${safeLang}/events` : `/${safeLang}/eventos`
  const breadcrumbLevels = [
    { label: tFn('nav.inicio'), href: `/${safeLang}` },
    { label: tFn('nav.eventos'), href: eventsListHref },
    { label: event.title },
  ]

  const eventSchema = buildEventSchema(event, safeLang)
  const breadcrumbSchema = buildBreadcrumbSchema(
    breadcrumbLevels.map((l) => ({
      ...l,
      href: l.href ? `${SITE_URL}${l.href}` : undefined,
    }))
  )

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(eventSchema) }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
      />

      <EventViewTracker eventSlug={event.slug} />

      {/* Translation fallback banner (EN visitors on PT-fallback content) */}
      {safeLang === 'en' && !event.has_translation && (
        <div className="container-center">
          <TranslationFallbackBanner
            entityType="event"
            ptSlug={event.slug}
            entityId={event.id}
            lang={safeLang}
          />
        </div>
      )}

      <nav id="breadcrumb" aria-label="Breadcrumb">
        <Breadcrumb items={breadcrumbLevels} />
      </nav>

      <main>
        {/* Event Hero Section */}
        <section className="event-hero">
          <div className="container-center">
            <div className="event-hero-content">
              {/* Category Badge */}
              <span
                className="event-category-badge"
                style={{ backgroundColor: `${color}20`, color }}
              >
                {event.categoryLabel}
              </span>

              {/* Event Title */}
              <h1 className="event-hero-title">{event.title}</h1>

              {/* Featured Image */}
              <div className="event-hero-image-wrapper">
                {event.image ? (
                  <Image
                    src={event.image}
                    alt={event.title}
                    width={1200}
                    height={600}
                    className="event-featured-image"
                    unoptimized
                    placeholder="blur"
                    blurDataURL={BLUR_PLACEHOLDER}
                    priority
                  />
                ) : (
                  <img src="" alt="" className="event-featured-image" />
                )}
              </div>

              {/* Event Meta Bar */}
              <div className="event-meta-bar">
                <div className="event-meta-group">
                  <span
                    className="event-meta-badge"
                    style={{ backgroundColor: `${color}20`, color }}
                  >
                    {(() => {
                      const { icon: TypeIcon, label } = formatEventType(event.type, tFn)
                      return (
                        <span className="inline-flex items-center gap-1">
                          {TypeIcon && <TypeIcon size={12} aria-hidden="true" />} {label}
                        </span>
                      )
                    })()}
                  </span>
                  <span className="text-sm font-semibold text-brand-deep/70">
                    {formatDate(event.date, safeLang)}
                  </span>
                </div>
                <div className="event-meta-group">
                  <span className="text-sm text-brand-deep/70">
                    {event.location}
                  </span>
                </div>
                <div className="event-meta-group">
                  <span className="text-sm text-brand-deep/70">
                    {event.time}{event.endTime ? ` — ${event.endTime}` : ''}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Event Content Section */}
        <section className="event-content-section">
          <div className="container-center">
            <div className="event-body-full">
              {/* Main Content Column */}
              <div className="event-body-wrapper">
                {/* Event Description/Excerpt */}
                <div className="event-body mb-12">
                  {(event.description || event.excerpt) && <p>{event.description || event.excerpt}</p>}
                </div>

                {/* Event Details */}
                <div className="event-details-card">
                  <h2 className="text-2xl font-bold text-brand-deep mb-6">
                    {tFn('evento_detail.event_details_title') || 'Detalhes do Evento'}
                  </h2>

                  <div className="event-details-grid">
                    <div className="event-detail-item">
                      <h3 className="text-sm font-bold uppercase tracking-wider text-brand-deep/60 mb-2">
                        {tFn('evento_detail.event_type') || 'Tipo de Evento'}
                      </h3>
                      <p className="text-base text-brand-deep font-medium">
                        {(() => {
                      const { icon: TypeIcon, label } = formatEventType(event.type, tFn)
                      return (
                        <>
                          {TypeIcon && <TypeIcon size={15} aria-hidden="true" />} {label}
                        </>
                      )
                    })()}
                      </p>
                    </div>

                    <div className="event-detail-item">
                      <h3 className="text-sm font-bold uppercase tracking-wider text-brand-deep/60 mb-2">
                        {tFn('evento_detail.event_date') || 'Data'}
                      </h3>
                      <p className="text-base text-brand-deep font-medium">
                        {formatDate(event.date, safeLang)}
                      </p>
                    </div>

                    <div className="event-detail-item">
                      <h3 className="text-sm font-bold uppercase tracking-wider text-brand-deep/60 mb-2">
                        {tFn('evento_detail.event_time') || 'Horário'}
                      </h3>
                      <p className="text-base text-brand-deep font-medium">
                        {event.time}{event.endTime ? ` — ${event.endTime}` : ''}
                        {duration && ` (${duration})`}
                      </p>
                    </div>

                    <div className="event-detail-item">
                      <h3 className="text-sm font-bold uppercase tracking-wider text-brand-deep/60 mb-2">
                        {tFn('evento_detail.event_location') || 'Localização'}
                      </h3>
                      <p className="text-base text-brand-deep font-medium">
                        {event.location}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Capacity Information */}
                {event.capacity && (
                  <div className="event-capacity-section mt-12">
                    <h3 className="text-lg font-bold text-brand-deep mb-4">
                      {tFn('evento_detail.available_spots')}
                    </h3>
                    <CapacityBar
                      eventId={event.id}
                      capacity={event.capacity}
                      initialCount={inscriptionCount}
                      isPast={isPast}
                    />
                  </div>
                )}

                {/* Registration CTA */}
                <div className="mt-12">
                  <RegistrationButton
                    eventId={event.id}
                    capacity={event.capacity}
                    initialCount={inscriptionCount}
                    isPast={isPast}
                    lang={safeLang}
                  />
                </div>
              </div>

              {/* Speakers Section */}
              <SpeakersList hosts={event.hosts} categoryColor={color} />
            </div>
          </div>
        </section>

        {/* Similar Events Section */}
        {similarEvents.length >= 2 && (
          <SimilarEvents events={similarEvents} lang={safeLang} title={tFn('evento_detail.related_events')} />
        )}
      </main>
    </>
  )
}
