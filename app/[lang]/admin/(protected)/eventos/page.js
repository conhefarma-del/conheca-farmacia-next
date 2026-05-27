import EventosListPage from '@/components/admin/EventosListPage'
import { getAllEventsAdmin, getEventStats, getTopEvents } from '@/lib/actions/lists'

/**
 * Eventos List Page — Server Component (puro)
 */

export default async function EventosPage() {
  const [events, stats, topEvents] = await Promise.all([
    getAllEventsAdmin(),
    getEventStats(),
    getTopEvents('views', 3),
  ])

  return (
    <EventosListPage
      events={events}
      stats={stats}
      topEvents={topEvents}
    />
  )
}
