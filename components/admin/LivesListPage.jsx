'use client'

import { useState, useCallback, useMemo } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Pencil, Trash2, Plus } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { deleteLive, toggleLiveStatus } from '@/lib/actions/content'
import AnalyticsCard from '@/components/admin/AnalyticsCard'
import { getTopLives } from '@/lib/actions/lists'

/**
 * LivesListPage — Client Component
 *
 * Filtros: sort, status, tempo (all/upcoming/past).
 * Colunas: Título, Categoria, Data, Plataforma, Status, Ações.
 *
 * Props:
 *   - lives: Array
 *   - stats: { total, published, drafts }
 *   - lang: string
 *   - topLives: Array
 */

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-PT')
}

const ANALYTICS_METRICS = [
  { key: 'views', label: 'Visualizações' },
  { key: 'access', label: 'Acessos' },
  { key: 'downloads', label: 'Downloads' },
]

export default function LivesListPage({ lives = [], stats, lang = 'pt', topLives = [] }) {
  const router = useRouter()
  const [sortField, setSortField] = useState('date-desc')
  const [statusFilter, setStatusFilter] = useState('all')
  const [timeFilter, setTimeFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [actionLoading, setActionLoading] = useState(null)

  const filteredLives = useMemo(() => {
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    let filtered = lives.filter((live) => {
      if (statusFilter !== 'all' && live.status !== statusFilter) return false

      if (timeFilter !== 'all' && live.date) {
        const liveDate = new Date(live.date)
        liveDate.setHours(0, 0, 0, 0)
        if (timeFilter === 'upcoming' && liveDate < today) return false
        if (timeFilter === 'past' && liveDate >= today) return false
      }

      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        const title = (live.title || '').toLowerCase()
        const category = (live.category_label || live.category || '').toLowerCase()
        const platform = (live.platform || '').toLowerCase()
        if (!title.includes(q) && !category.includes(q) && !platform.includes(q)) {
          return false
        }
      }

      return true
    })

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
  }, [lives, sortField, statusFilter, timeFilter, searchQuery])

  const handleToggleStatus = useCallback(async (id, currentStatus) => {
    const newLabel = currentStatus === 'published' ? 'Rascunho' : 'Publicado'
    if (!confirm(`Alterar status para "${newLabel}"?`)) return

    setActionLoading(`status-${id}`)
    try {
      const result = await toggleLiveStatus(id, currentStatus)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao alterar status.')
    } finally {
      setActionLoading(null)
    }
  }, [router])

  const handleDelete = useCallback(async (id, title) => {
    if (!confirm(`Tem certeza que deseja excluir a live "${title}"?`)) return

    setActionLoading(`delete-${id}`)
    try {
      const result = await deleteLive(id)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao excluir live.')
    } finally {
      setActionLoading(null)
    }
  }, [router])

  const handleAnalyticsMetric = useCallback(async (metric) => {
    return await getTopLives(metric, 3)
  }, [])

  const safeStats = stats || { total: 0, published: 0, drafts: 0 }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Gerir Lives</h1>
        <p className="admin-page-subtitle">Criar, editar e gerir lives e webinars</p>
      </div>

      {/* Stats + Analytics */}
      <div className="admin-stats-grid admin-stats-grid-4" style={{ marginBottom: 24 }}>
        <div className="admin-stat-card stat-blue">
          <div>
            <div className="admin-stat-card-value">{safeStats.total}</div>
            <div className="admin-stat-card-label">Total</div>
          </div>
        </div>
        <div className="admin-stat-card stat-green">
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
        <AnalyticsCard
          metrics={ANALYTICS_METRICS}
          onMetricChange={handleAnalyticsMetric}
          initialData={topLives}
          initialMetric="views"
        />
      </div>

      {/* Filters */}
      <div className="admin-list-filters" style={{ marginBottom: 16 }}>
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
          <h3>Lista de Lives</h3>
          <Link href={`/${lang}/admin/lives/new`} className="admin-btn admin-btn-primary" style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <Plus size={16} />
            Adicionar Live
          </Link>
        </div>

        {filteredLives.length === 0 ? (
          <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>Nenhuma live encontrada</p>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Título</th>
                  <th>Categoria</th>
                  <th>Data</th>
                  <th>Plataforma</th>
                  <th>Status</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {filteredLives.map((live) => (
                  <tr key={live.id}>
                    <td>{escapeHtml(live.title)}</td>
                    <td>{escapeHtml(live.category_label || live.category || '-')}</td>
                    <td>{formatDate(live.date)}</td>
                    <td>{escapeHtml(live.platform || '-')}</td>
                    <td>
                      <button
                        className={`admin-status-badge ${live.status === 'published' ? 'admin-status-published' : 'admin-status-draft'}`}
                        style={{ cursor: 'pointer', border: 'none' }}
                        onClick={() => handleToggleStatus(live.id, live.status)}
                        disabled={actionLoading === `status-${live.id}`}
                      >
                        {live.status === 'published' ? 'Publicado' : 'Rascunho'}
                      </button>
                    </td>
                    <td>
                      <div className="admin-actions">
                        <Link href={`/${lang}/admin/lives/${live.id}`} className="admin-btn admin-btn-secondary">
                          <Pencil size={14} /> Editar
                        </Link>
                        <button className="admin-btn admin-btn-danger" onClick={() => handleDelete(live.id, live.title)} disabled={actionLoading === `delete-${live.id}`}>
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
