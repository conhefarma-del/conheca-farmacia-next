import EventosListPage from '@/components/admin/EventosListPage'
import { getAllEventsAdmin, getEventStats, getTopEvents } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/content'

/**
 * Eventos List Page — Server Component (puro)
 * Phase 4 (2026-06-15): passa currentUserRole para condicionar visibilidade de botões.
 */

export default async function EventosPage() {
  const [events, stats, topEvents, currentUserRole] = await Promise.all([
    getAllEventsAdmin(),
    getEventStats(),
    getTopEvents('views', 3),
    getCurrentRole(),
  ])

  return (
    <EventosListPage
      events={events}
      stats={stats}
      topEvents={topEvents}
      currentUserRole={currentUserRole}
    />
  )
}
