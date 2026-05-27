import EventCard from '@/components/ui/EventCard'

export default function FeaturedEvents({ events, lang, title = 'Eventos em Destaque' }) {
  if (!events || events.length === 0) return null

  return (
    <section id="eventos" className="section-padding bg-brand-bg">
      <div className="container-center">
        <h2 className="section-title">
          {title}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {events.map((event) => (
            <EventCard key={event.slug} event={event} lang={lang} variant="home" />
          ))}
        </div>
      </div>
    </section>
  )
}
