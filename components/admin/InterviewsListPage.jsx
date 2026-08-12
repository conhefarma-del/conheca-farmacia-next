'use client'

import { useState, useCallback, useMemo } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Pencil, Trash2, Plus, Search, Archive, ArchiveRestore, Eye } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { deleteInterview, toggleInterviewStatus, archiveInterview, restoreInterview } from '@/lib/actions/content'
import ConfirmModal from '@/components/admin/ConfirmModal'

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-PT')
}

export default function InterviewsListPage({ interviews = [], stats, lang = 'pt', currentUserRole }) {
  const router = useRouter()
  const [sortField, setSortField] = useState('date-desc')
  const [statusFilter, setStatusFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [confirmAction, setConfirmAction] = useState(null)
  const [actionLoading, setActionLoading] = useState(null)

  const filtered = useMemo(() => {
    let list = interviews.filter((i) => {
      if (statusFilter === 'archived') {
        if (!i.is_archived) return false
      } else if (statusFilter !== 'all' && i.status !== statusFilter) {
        return false
      } else if (statusFilter === 'all' && i.is_archived) {
        return false
      }

      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        const title = (i.title || '').toLowerCase()
        const cat = (i.category_label || i.category || '').toLowerCase()
        const people = (Array.isArray(i.interviewees) ? i.interviewees : [i.interviewee]).filter(Boolean)
        const person = people.map((p) => (p?.name || '')).join(' ').toLowerCase()
        if (!title.includes(q) && !cat.includes(q) && !person.includes(q)) return false
      }

      return true
    })

    list.sort((a, b) => {
      switch (sortField) {
        case 'date-asc': return new Date(a.date || 0) - new Date(b.date || 0)
        case 'date-desc': return new Date(b.date || 0) - new Date(a.date || 0)
        case 'title-asc': return (a.title || '').localeCompare(b.title || '', 'pt')
        case 'title-desc': return (b.title || '').localeCompare(a.title || '', 'pt')
        case 'views-desc': return (b.view_count || 0) - (a.view_count || 0)
        case 'views-asc': return (a.view_count || 0) - (b.view_count || 0)
        default: return 0
      }
    })

    return list
  }, [interviews, sortField, statusFilter, searchQuery])

  const handleToggleStatus = useCallback(async (id, currentStatus) => {
    const newLabel = currentStatus === 'published' ? 'Rascunho' : 'Publicado'
    if (!confirm(`Alterar status para "${newLabel}"?`)) return

    setActionLoading(`status-${id}`)
    try {
      const result = await toggleInterviewStatus(id, currentStatus)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao alterar status.')
    } finally {
      setActionLoading(null)
    }
  }, [router])

  const safeStats = stats || { total: 0, published: 0, drafts: 0 }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Gerir Entrevistas</h1>
        <p className="admin-page-subtitle">Criar, editar e gerir entrevistas</p>
      </div>

      {/* Stats */}
      <div className="admin-stats-grid admin-stats-grid-4" style={{ marginBottom: 24 }}>
        <div className="admin-stats-scroll">
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
          {safeStats.archived > 0 && (
            <div className="admin-stat-card stat-purple">
              <div>
                <div className="admin-stat-card-value">{safeStats.archived}</div>
                <div className="admin-stat-card-label">Arquivados</div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Filters */}
      <div className="admin-list-filters" style={{ marginBottom: 16 }}>
        <div style={{ position: 'relative', flex: 1, minWidth: 180, maxWidth: 280 }}>
          <Search size={16} style={{ position: 'absolute', left: 10, top: '50%', transform: 'translateY(-50%)', color: 'var(--admin-text-muted)', pointerEvents: 'none' }} />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Pesquisar por título, categoria ou entrevistado..."
            className="admin-select"
            style={{ width: '100%', paddingLeft: 32 }}
          />
        </div>
        <select className="admin-select" value={sortField} onChange={(e) => setSortField(e.target.value)}>
          <option value="date-desc">Mais recentes</option>
          <option value="date-asc">Mais antigos</option>
          <option value="views-desc">Mais vistas</option>
          <option value="views-asc">Menos vistas</option>
          <option value="title-asc">Título A-Z</option>
          <option value="title-desc">Título Z-A</option>
        </select>
        <select className="admin-select" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
          <option value="all">Todos os status</option>
          <option value="published">Publicados</option>
          <option value="draft">Rascunhos</option>
          <option value="archived">Arquivados</option>
        </select>
      </div>

      {/* Table */}
      <div className="admin-dashboard-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
          <h3>Lista de Entrevistas</h3>
          <Link href={`/${lang}/admin/entrevistas/new`} className="admin-btn admin-btn-primary" style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
            <Plus size={16} />
            Adicionar Entrevista
          </Link>
        </div>

        {filtered.length === 0 ? (
          <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>Nenhuma entrevista encontrada</p>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Título</th>
                  <th>Entrevistado</th>
                  <th>Categoria</th>
                  <th>Data</th>
                  <th>Views</th>
                  <th>Status</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((i) => (
                  <tr key={i.id}>
                    <td>{escapeHtml(i.title)}</td>
                    <td>
                      {escapeHtml(i.interviewee?.name || '-')}
                      {Array.isArray(i.interviewees) && i.interviewees.length > 1
                        ? ` +${i.interviewees.length - 1}`
                        : ''}
                    </td>
                    <td>{escapeHtml(i.category_label || i.category || '-')}</td>
                    <td>{formatDate(i.date)}</td>
                    <td>
                      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, whiteSpace: 'nowrap' }}>
                        <Eye size={13} style={{ color: 'var(--admin-text-muted)' }} />
                        {i.view_count || 0}
                      </span>
                    </td>
                    <td>
                      <button
                        className={`admin-status-badge ${i.status === 'published' ? 'admin-status-published' : 'admin-status-draft'}`}
                        style={{ cursor: 'pointer', border: 'none' }}
                        onClick={() => handleToggleStatus(i.id, i.status)}
                        disabled={actionLoading === `status-${i.id}`}
                      >
                        {i.status === 'published' ? 'Publicado' : 'Rascunho'}
                      </button>
                      {i.is_archived && (
                        <span className="admin-badge admin-badge-archived">
                          <Archive size={12} /> Arquivado
                        </span>
                      )}
                    </td>
                    <td>
                      <div className="admin-actions">
                        <Link href={`/${lang}/admin/entrevistas/${i.id}`} className="admin-btn admin-btn-secondary">
                          <Pencil size={14} /> Editar
                        </Link>
                        {!i.is_archived ? (
                          <button
                            type="button"
                            onClick={() => setConfirmAction({ type: 'archive', id: i.id, title: i.title })}
                            className="admin-btn admin-btn-warning"
                            disabled={actionLoading === `archive-${i.id}`}
                          >
                            <Archive size={14} /> Arquivar
                          </button>
                        ) : (
                          currentUserRole === 'superadmin' && (
                            <button
                              type="button"
                              onClick={async () => {
                                setActionLoading(`restore-${i.id}`)
                                try {
                                  const result = await restoreInterview(i.id)
                                  if (!result.success) alert(result.error)
                                  else router.refresh()
                                } catch {
                                  alert('Erro ao restaurar entrevista.')
                                } finally {
                                  setActionLoading(null)
                                }
                              }}
                              className="admin-btn admin-btn-secondary"
                              disabled={actionLoading === `restore-${i.id}`}
                            >
                              <ArchiveRestore size={14} /> Restaurar
                            </button>
                          )
                        )}
                        {currentUserRole === 'superadmin' && (
                          <button
                            type="button"
                            onClick={() => setConfirmAction({ type: 'delete', id: i.id, title: i.title })}
                            className="admin-btn admin-btn-danger"
                            disabled={actionLoading === `delete-${i.id}`}
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
              ? await archiveInterview(confirmAction.id)
              : await deleteInterview(confirmAction.id)
            if (!result.success) alert(result.error)
            else router.refresh()
          } catch {
            alert(confirmAction.type === 'archive' ? 'Erro ao arquivar entrevista.' : 'Erro ao excluir entrevista.')
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
