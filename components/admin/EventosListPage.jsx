'use client'

import { useState, useCallback, useMemo } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Pencil, Trash2, Plus, Search } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { deleteEvent, toggleEventStatus } from '@/lib/actions/content'
import AnalyticsCard from '@/components/admin/AnalyticsCard'
import { getTopEvents } from '@/lib/actions/lists'

/**
 * EventosListPage — Client Component
 *
 * Filtros: sort, status, tempo (all/upcoming/past).
 * Colunas: Título, Categoria, Data, Tipo, Status, Ações.
 *
 * Props:
 *   - events: Array (do server)
 *   - stats: { total, published, drafts }
 *   - lang: string
 *   - topEvents: Array
 */

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-PT')
}

const TYPE_LABELS = {
  online: 'Online',
  presencial: 'Presencial',
  hibrido: 'Híbrido',
}

const ANALYTICS_METRICS = [
  { key: 'views', label: 'Visualizações' },
  { key: 'fill', label: 'Lot.' },
  { key: 'upcoming', label: 'Prox.' },
]

export default function EventosListPage({ events = [], stats, lang = 'pt', topEvents = [] }) {
  const router = useRouter()
  const [sortField, setSortField] = useState('date-desc')
  const [statusFilter, setStatusFilter] = useState('all')
  const [timeFilter, setTimeFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [actionLoading, setActionLoading] = useState(null)

  const filteredEvents = useMemo(() => {
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    let filtered = events.filter((event) => {
      // Status filter
      if (statusFilter !== 'all' && event.status !== statusFilter) return false

      // Time filter
      if (timeFilter !== 'all' && event.date) {
        const eventDate = new Date(event.date)
        eventDate.setHours(0, 0, 0, 0)
        if (timeFilter === 'upcoming' && eventDate < today) return false
        if (timeFilter === 'past' && eventDate >= today) return false
      }

      // Search
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        const title = (event.title || '').toLowerCase()
        const category = (event.category_label || event.category || '').toLowerCase()
        const location = (event.location || '').toLowerCase()
        if (!title.includes(q) && !category.includes(q) && !location.includes(q)) {
          return false
        }
      }

      return true
    })

    // Sort
    filtered.sort((a, b) => {
      switch (sortField) {
        case 'date-asc': return new Date(a.date || 0) - new Date(b.date || 0)
        case 'date-desc': return new Date(b.date || 0) - new Date(a.date || 0)
        case 'title-asc': return (a.title || '').localeCompare(b.title || '', 'pt')
        case 'title-desc': return (b.title || '').localeCompare(a.title || '', 'pt')
        default: return 0
      }
    })

    return filtered
  }, [events, sortField, statusFilter, timeFilter, searchQuery])

  const handleToggleStatus = useCallback(async (id, currentStatus) => {
    const newLabel = currentStatus === 'published' ? 'Rascunho' : 'Publicado'
    if (!confirm(`Alterar status para "${newLabel}"?`)) return

    setActionLoading(`status-${id}`)
    try {
      const result = await toggleEventStatus(id, currentStatus)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao alterar status.')
    } finally {
      setActionLoading(null)
    }
  }, [router])

  const handleDelete = useCallback(async (id, title) => {
    if (!confirm(`Tem certeza que deseja excluir o evento "${title}"?`)) return

    setActionLoading(`delete-${id}`)
    try {
      const result = await deleteEvent(id)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao excluir evento.')
    } finally {
      setActionLoading(null)
    }
  }, [router])

  const handleAnalyticsMetric = useCallback(async (metric) => {
    return await getTopEvents(metric, 3)
  }, [])

  const safeStats = stats || { total: 0, published: 0, drafts: 0 }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Gerir Eventos</h1>
        <p className="admin-page-subtitle">Criar, editar e gerir eventos</p>
      </div>

      {/* Stats + Analytics */}
      <div className={`admin-stats-grid admin-stats-grid-4${searchQuery ? ' admin-search-active' : ''}`} style={{ marginBottom: 24 }}>
        <div className="admin-stats-scroll">
          <div className="admin-stat-card stat-purple">
            <div>
              <div className="admin-stat-card-value">{safeStats.total}</div>
              <div className="admin-stat-card-label">Total</div>
            </div>
          </div>
          <div className="admin-stat-card stat-blue">
            <div>
              <div className="admin-stat-card-value">{safeStats.published}</div>
              <div className="admin-stat-card-label">Publicados</div>
            </div>
          </div>
          <div className="admin-stat-card stat-orange">
            <div>
              <div className="admin-stat-card-value">{safeStats.drafts}</div>
              <div className="admin-stat-card-label">Rascunhos</div>
            </div>
          </div>
        </div>
        <AnalyticsCard
          metrics={ANALYTICS_METRICS}
          onMetricChange={handleAnalyticsMetric}
          initialData={topEvents}
          initialMetric="views"
        />
      </div>

      {/* Filters */}
      <div className="admin-list-filters" style={{ marginBottom: 16 }}>
        <div style={{ position: 'relative', flex: 1, minWidth: 180, maxWidth: 280 }}>
          <Search size={16} style={{ position: 'absolute', left: 10, top: '50%', transform: 'translateY(-50%)', color: 'var(--admin-text-muted)', pointerEvents: 'none' }} />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Pesquisar por título..."
            className="admin-select"
            style={{ width: '100%', paddingLeft: 32 }}
          />
        </div>
        <select className="admin-select" value={sortField} onChange={(e) => setSortField(e.target.value)}>
          <option value="date-desc">Mais recentes</option>
          <option value="date-asc">Mais antigos</option>
          <option value="title-asc">Título A-Z</option>
          <option value="title-desc">Título Z-A</option>
        </select>
        <select className="admin-select" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
          <option value="all">Todos os status</option>
          <option value="published">Publicados</option>
          <option value="draft">Rascunhos</option>
        </select>
        <select className="admin-select" value={timeFilter} onChange={(e) => setTimeFilter(e.target.value)}>
          <option value="all">Todos os tempos</option>
          <option value="upcoming">Próximos</option>
          <option value="past">Passados</option>
        </select>
      </div>

      {/* Table */}
      <div className="admin-dashboard-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
          <h3>Lista de Eventos</h3>
          <Link href={`/${lang}/admin/eventos/new`} className="admin-btn admin-btn-primary" style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <Plus size={16} />
            Adicionar Evento
          </Link>
        </div>

        {filteredEvents.length === 0 ? (
          <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>Nenhum evento encontrado</p>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Título</th>
                  <th>Categoria</th>
                  <th>Data</th>
                  <th>Tipo</th>
                  <th>Status</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {filteredEvents.map((event) => (
                  <tr key={event.id}>
                    <td>{escapeHtml(event.title)}</td>
                    <td>{escapeHtml(event.category_label || event.category || '-')}</td>
                    <td>{formatDate(event.date)}</td>
                    <td>{TYPE_LABELS[event.type] || event.type || '-'}</td>
                    <td>
                      <button
                        className={`admin-status-badge ${event.status === 'published' ? 'admin-status-published' : 'admin-status-draft'}`}
                        style={{ cursor: 'pointer', border: 'none' }}
                        onClick={() => handleToggleStatus(event.id, event.status)}
                        disabled={actionLoading === `status-${event.id}`}
                      >
                        {event.status === 'published' ? 'Publicado' : 'Rascunho'}
                      </button>
                    </td>
                    <td>
                      <div className="admin-actions">
                        <Link href={`/${lang}/admin/eventos/${event.id}`} className="admin-btn admin-btn-secondary">
                          <Pencil size={14} /> Editar
                        </Link>
                        <button className="admin-btn admin-btn-danger" onClick={() => handleDelete(event.id, event.title)} disabled={actionLoading === `delete-${event.id}`}>
                          <Trash2 size={14} /> Excluir
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </>
  )
}
