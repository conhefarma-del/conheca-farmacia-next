'use client'

import { useState, useCallback, useMemo } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Pencil, Trash2, Plus, Search, Archive, ArchiveRestore } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { deleteArticle, toggleArticleStatus, archiveArticle, restoreArticle } from '@/lib/actions/content'
import AnalyticsCard from '@/components/admin/AnalyticsCard'
import { getTopArticles } from '@/lib/actions/lists'
import ConfirmModal from '@/components/admin/ConfirmModal'

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

export default function ArtigosListPage({ articles = [], stats, lang = 'pt', topArticles = [], currentUserRole }) {
  const router = useRouter()
  const [sortField, setSortField] = useState('date-desc')
  const [statusFilter, setStatusFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [confirmAction, setConfirmAction] = useState(null) // { type: 'archive' | 'delete', id, title }
  const [actionLoading, setActionLoading] = useState(null)

  // Filtrar e ordenar artigos
  const filteredArticles = useMemo(() => {
    let filtered = articles.filter((article) => {
      // Status filter
      if (statusFilter === 'archived') {
        if (!article.is_archived) return false
      } else if (statusFilter !== 'all' && article.status !== statusFilter) {
        return false
      } else if (statusFilter === 'all' && article.is_archived) {
        return false  // default 'all' esconde arquivados (parity com público)
      }

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
  const handleDelete = useCallback(async (id) => {
    setActionLoading(`delete-${id}`)
    try {
      const result = await deleteArticle(id)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao excluir artigo.')
    } finally {
      setActionLoading(null)
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
      <div className={`admin-stats-grid admin-stats-grid-4${searchQuery ? ' admin-search-active' : ''}`} style={{ marginBottom: 24 }}>
        <div className="admin-stats-scroll">
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
          {safeStats.archived > 0 && (
            <div className="admin-stat-card stat-purple">
              <div>
                <div className="admin-stat-card-value">{safeStats.archived}</div>
                <div className="admin-stat-card-label">Arquivados</div>
              </div>
            </div>
          )}
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
          <option value="archived">Arquivados</option>
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
                      {article.is_archived && (
                        <span
                          className="admin-badge admin-badge-archived"
                          title={`Arquivado em ${new Date(article.archived_at).toLocaleDateString('pt-PT')}${article.archived_by ? ' por ' + article.archived_by : ''}`}
                        >
                          <Archive size={12} /> Arquivado
                        </span>
                      )}
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
                        {!article.is_archived ? (
                          <button
                            type="button"
                            onClick={() => setConfirmAction({ type: 'archive', id: article.id, title: article.title })}
                            className="admin-btn admin-btn-warning"
                            disabled={actionLoading === `archive-${article.id}`}
                          >
                            <Archive size={14} /> Arquivar
                          </button>
                        ) : (
                          currentUserRole === 'superadmin' && (
                            <button
                              type="button"
                              onClick={async () => {
                                setActionLoading(`restore-${article.id}`)
                                try {
                                  const result = await restoreArticle(article.id)
                                  if (!result.success) alert(result.error)
                                  else router.refresh()
                                } catch {
                                  alert('Erro ao restaurar artigo.')
                                } finally {
                                  setActionLoading(null)
                                }
                              }}
                              className="admin-btn admin-btn-secondary"
                              disabled={actionLoading === `restore-${article.id}`}
                            >
                              <ArchiveRestore size={14} /> Restaurar
                            </button>
                          )
                        )}
                        {currentUserRole === 'superadmin' && (
                          <button
                            type="button"
                            onClick={() => setConfirmAction({ type: 'delete', id: article.id, title: article.title })}
                            className="admin-btn admin-btn-danger"
                            disabled={actionLoading === `delete-${article.id}`}
                          >
                            <Trash2 size={14} /> Eliminar
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <ConfirmModal
        isOpen={!!confirmAction}
        onClose={() => setConfirmAction(null)}
        onConfirm={async () => {
          if (!confirmAction) return
          setActionLoading(`${confirmAction.type}-${confirmAction.id}`)
          try {
            const result = confirmAction.type === 'archive'
              ? await archiveArticle(confirmAction.id)
              : await deleteArticle(confirmAction.id)
            if (!result.success) alert(result.error)
            else router.refresh()
          } catch {
            alert(confirmAction.type === 'archive' ? 'Erro ao arquivar artigo.' : 'Erro ao excluir artigo.')
          } finally {
            setActionLoading(null)
            setConfirmAction(null)
          }
        }}
        title={confirmAction?.type === 'delete' ? 'Eliminar definitivamente?' : 'Arquivar?'}
        message={
          confirmAction?.type === 'delete'
            ? `"${confirmAction?.title}" será removido permanentemente. Esta ação não pode ser revertida.`
            : `"${confirmAction?.title}" ficará oculto do público mas pode ser restaurado depois.`
        }
        confirmLabel={confirmAction?.type === 'delete' ? 'Eliminar' : 'Arquivar'}
        variant={confirmAction?.type === 'delete' ? 'danger' : 'warning'}
        loading={!!actionLoading && actionLoading.startsWith(confirmAction?.type ?? '')}
      />
    </>
  )
}
