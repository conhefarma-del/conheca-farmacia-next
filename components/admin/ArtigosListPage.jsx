'use client'

import { useState, useCallback, useMemo } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Pencil, Trash2, Plus } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { deleteArticle, toggleArticleStatus } from '@/lib/actions/content'
import AnalyticsCard from '@/components/admin/AnalyticsCard'
import { getTopArticles } from '@/lib/actions/lists'

/**
 * ArtigosListPage — Client Component
 *
 * Gerencia filtros, ordenação, pesquisa, tabela e ações.
 * Dados recebidos via props do Server Component pai.
 *
 * Props:
 *   - articles: Array (do server)
 *   - stats: { total, published, drafts }
 *   - lang: string
 *   - topArticles: Array (initial analytics)
 */

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-PT')
}

function formatReadingTime(seconds) {
  if (!seconds) return '0s'
  if (seconds >= 3600) return `${Math.floor(seconds / 3600)}h ${Math.floor((seconds % 3600) / 60)}m`
  if (seconds >= 60) return `${Math.floor(seconds / 60)}m ${seconds % 60}s`
  return `${seconds}s`
}

const ANALYTICS_METRICS = [
  { key: 'views', label: 'Visualizações' },
  { key: 'shares', label: 'Partilhas' },
  { key: 'reading', label: 'Leitura' },
]

export default function ArtigosListPage({ articles = [], stats, lang = 'pt', topArticles = [] }) {
  const router = useRouter()
  const [sortField, setSortField] = useState('date-desc')
  const [statusFilter, setStatusFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [deleteConfirm, setDeleteConfirm] = useState(null)
  const [actionLoading, setActionLoading] = useState(null)

  // Filtrar e ordenar artigos
  const filteredArticles = useMemo(() => {
    let filtered = articles.filter((article) => {
      // Status filter
      if (statusFilter !== 'all' && article.status !== statusFilter) return false

      // Search filter
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        const title = (article.title || '').toLowerCase()
        const excerpt = (article.excerpt || '').toLowerCase()
        const category = (article.category_label || article.category || '').toLowerCase()
        const author = (article.author_name || '').toLowerCase()
        if (!title.includes(q) && !excerpt.includes(q) && !category.includes(q) && !author.includes(q)) {
          return false
        }
      }

      return true
    })

    // Sort
    filtered.sort((a, b) => {
      switch (sortField) {
        case 'date-asc': return new Date(a.published_date || 0) - new Date(b.published_date || 0)
        case 'date-desc': return new Date(b.published_date || 0) - new Date(a.published_date || 0)
        case 'title-asc': return (a.title || '').localeCompare(b.title || '', 'pt')
        case 'title-desc': return (b.title || '').localeCompare(a.title || '', 'pt')
        default: return 0
      }
    })

    return filtered
  }, [articles, sortField, statusFilter, searchQuery])

  // Toggle status
  const handleToggleStatus = useCallback(async (id, currentStatus) => {
    const newLabel = currentStatus === 'published' ? 'Rascunho' : 'Publicado'
    if (!confirm(`Alterar status para "${newLabel}"?`)) return

    setActionLoading(`status-${id}`)
    try {
      const result = await toggleArticleStatus(id, currentStatus)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao alterar status.')
    } finally {
      setActionLoading(null)
    }
  }, [router])

  // Delete
  const handleDelete = useCallback(async (id, title) => {
    if (!confirm(`Tem certeza que deseja excluir o artigo "${title}"?`)) return

    setActionLoading(`delete-${id}`)
    try {
      const result = await deleteArticle(id)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao excluir artigo.')
    } finally {
      setActionLoading(null)
      setDeleteConfirm(null)
    }
  }, [router])

  // Analytics callback
  const handleAnalyticsMetric = useCallback(async (metric) => {
    return await getTopArticles(metric, 3)
  }, [])

  const safeStats = stats || { total: 0, published: 0, drafts: 0 }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Gerir Artigos</h1>
        <p className="admin-page-subtitle">Criar, editar e gerir artigos do blog</p>
      </div>

      {/* Stats + Analytics */}
      <div className="admin-stats-grid admin-stats-grid-4" style={{ marginBottom: 24 }}>
        <div className="admin-stat-card stat-green">
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
        <AnalyticsCard
          metrics={ANALYTICS_METRICS}
          onMetricChange={handleAnalyticsMetric}
          initialData={topArticles}
          initialMetric="views"
          valueFormatter={(value, metric) => {
            if (metric === 'reading') return formatReadingTime(value)
            return String(value || 0)
          }}
        />
      </div>

      {/* Filters */}
      <div className="admin-list-filters" style={{ marginBottom: 16 }}>
        <select
          className="admin-select"
          value={sortField}
          onChange={(e) => setSortField(e.target.value)}
        >
          <option value="date-desc">Mais recentes</option>
          <option value="date-asc">Mais antigos</option>
          <option value="title-asc">Título A-Z</option>
          <option value="title-desc">Título Z-A</option>
        </select>
        <select
          className="admin-select"
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
        >
          <option value="all">Todos os status</option>
          <option value="published">Publicados</option>
          <option value="draft">Rascunhos</option>
        </select>
      </div>

      {/* Table */}
      <div className="admin-dashboard-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
          <h3>Lista de Artigos</h3>
          <Link
            href={`/${lang}/admin/artigos/new`}
            className="admin-btn admin-btn-primary"
            style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}
          >
            <Plus size={16} />
            Adicionar Artigo
          </Link>
        </div>

        {filteredArticles.length === 0 ? (
          <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>
            Nenhum artigo encontrado
          </p>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Título</th>
                  <th>Categoria</th>
                  <th>Status</th>
                  <th>Data</th>
                  <th>Autor</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {filteredArticles.map((article) => (
                  <tr key={article.id}>
                    <td>{escapeHtml(article.title)}</td>
                    <td>{escapeHtml(article.category_label || article.category || '-')}</td>
                    <td>
                      <button
                        className={`admin-status-badge ${article.status === 'published' ? 'admin-status-published' : 'admin-status-draft'}`}
                        style={{ cursor: 'pointer', border: 'none' }}
                        onClick={() => handleToggleStatus(article.id, article.status)}
                        disabled={actionLoading === `status-${article.id}`}
                      >
                        {article.status === 'published' ? 'Publicado' : 'Rascunho'}
                      </button>
                    </td>
                    <td>{formatDate(article.published_date)}</td>
                    <td>{escapeHtml(article.author_name || '-')}</td>
                    <td>
                      <div className="admin-actions">
                        <Link
                          href={`/${lang}/admin/artigos/${article.id}`}
                          className="admin-btn admin-btn-secondary"
                        >
                          <Pencil size={14} />
                          Editar
                        </Link>
                        <button
                          className="admin-btn admin-btn-danger"
                          onClick={() => handleDelete(article.id, article.title)}
                          disabled={actionLoading === `delete-${article.id}`}
                        >
                          <Trash2 size={14} />
                          Excluir
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
