import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getEventBySlug, getEvents, getInscriptionCount } from '@/lib/api/events'
import { buildEventSchema, buildBreadcrumbSchema } from '@/lib/seo'
import { EVENT_CATEGORY_COLORS, SITE_URL } from '@/lib/constants'
import Breadcrumb from '@/components/ui/Breadcrumb'
import CapacityBar from '@/components/content/CapacityBar'
import SpeakersList from '@/components/content/SpeakersList'
import SimilarEvents from '@/components/content/SimilarEvents'
import EventViewTracker from '@/components/content/EventViewTracker'
import Image from 'next/image'
import Link from 'next/link'
import { notFound } from 'next/navigation'

export const dynamic = 'force-dynamic'

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
    event = await getEventBySlug(slug)
  } catch {
    return { title: 'Evento — Conheça Farmácia' }
  }

  if (!event) {
    return { title: 'Evento não encontrado — Conheça Farmácia' }
  }

  const eventUrl = `${SITE_URL}/${safeLang}/eventos/${event.slug}`

  return {
    title: `${event.title} — Conheça Farmácia`,
    description: event.excerpt || event.title,
    alternates: {
      canonical: eventUrl,
      languages: { 'pt': `/pt/eventos/${event.slug}`, 'en': `/en/eventos/${event.slug}` },
    },
    openGraph: {
      title: event.title,
      description: event.excerpt,
      url: eventUrl,
      type: 'website',
      images: event.image ? [{ url: event.image }] : [],
    },
    twitter: {
      card: 'summary_large_image',
      title: event.title,
      description: event.excerpt,
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
    event = await getEventBySlug(slug)
  } catch (err) {
    console.error('Error fetching event:', err)
    notFound()
  }
  if (!event) notFound()

  const color = EVENT_CATEGORY_COLORS[event.category] || '#00493a'
  const eventUrl = `${SITE_URL}/${safeLang}/eventos/${event.slug}`
  const isPast = event.date < new Date().toISOString().split('T')[0]
  const duration = calculateDuration(event.time, event.endTime)

  // Inscription count
  let inscriptionCount = 0
  try {
    inscriptionCount = await getInscriptionCount(event.slug)
  } catch {}

  const isFull = event.capacity && inscriptionCount >= event.capacity

  // Similar events
  let similarEvents = []
  try {
    const allEvents = await getEvents()
    similarEvents = allEvents
      .filter((e) => e.category === event.category && e.slug !== event.slug)
      .slice(0, 3)
  } catch {}

  const breadcrumbLevels = [
    { label: 'Início', href: `/${safeLang}`, i18nKey: 'nav.inicio' },
    { label: 'Eventos', href: `/${safeLang}/eventos`, i18nKey: 'nav.eventos' },
    { label: event.title },
  ]

  const eventSchema = buildEventSchema(event, safeLang)
  const breadcrumbSchema = buildBreadcrumbSchema(
    breadcrumbLevels.map((l) => ({
      ...l,
      href: l.href ? `${SITE_URL}${l.href}` : undefined,
    }))
  )

  // Registration button content
  let registrationBtn
  if (isPast) {
    registrationBtn = (
      <button
        className="btn btn-lg btn-inscrever btn-secondary"
        disabled
        data-i18n="evento_detail.recording_btn"
      >
        {tFn('evento_detail.recording_btn') || 'Evento passado'}
      </button>
    )
  } else if (isFull) {
    registrationBtn = (
      <button
        className="btn btn-primary btn-lg btn-inscrever btn-disabled"
        disabled
        data-i18n="evento_detail.full_btn"
      >
        {tFn('evento_detail.full_btn') || 'Evento Completo'}
      </button>
    )
  } else {
    registrationBtn = (
      <Link
        href={`/${safeLang}/inscricao?evento=${event.slug}`}
        className="btn btn-primary btn-lg btn-inscrever"
        data-i18n="evento_detail.register_btn"
      >
        {tFn('evento_detail.register_btn') || 'Inscrever-me'}
      </Link>
    )
  }

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
                    {event.type === 'online' ? 'Online' : 'Presencial'}
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
                  {event.excerpt && <p>{event.excerpt}</p>}
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
                        {event.type === 'online' ? 'Online' : 'Presencial'}
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
                      {tFn('evento_detail.available_spots') || 'Vagas Disponíveis'}
                    </h3>
                    <CapacityBar
                      eventSlug={event.slug}
                      capacity={event.capacity}
                      initialCount={inscriptionCount}
                    />
                  </div>
                )}

                {/* Registration CTA */}
                <div className="mt-12">
                  {registrationBtn}
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
