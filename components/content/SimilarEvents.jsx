import EventCard from '@/components/ui/EventCard'

export default function SimilarEvents({ events, lang, title }) {
  if (!events || events.length === 0) return null

  return (
    <section className="event-related-section">
      <div className="container-center">
        <h2 className="section-title">{title || 'Eventos Relacionados'}</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {events.map((event) => (
            <EventCard key={event.slug} event={event} lang={lang} />
          ))}
        </div>
      </div>
    </section>
  )
}
