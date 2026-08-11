'use client'

import { useMemo, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Pencil, Trash2, Plus, Search, Archive, ArchiveRestore } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import {
  deleteScientificArticle,
  toggleScientificArticleStatus,
  archiveScientificArticle,
  restoreScientificArticle,
} from '@/lib/actions/scientific'
import ConfirmModal from '@/components/admin/ConfirmModal'
import AdminPagination from '@/components/admin/AdminPagination'

const PAGE_SIZE = 10

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-PT')
}

/**
 * ScientificAdminListPage — lista paginada dos artigos científicos.
 * Pesquisa, filtros (status + categoria), ordenação, paginação (10/página)
 * e ações (status/arquivar/restaurar/eliminar — delete só superadmin).
 */
export default function ScientificAdminListPage({
  articles = [],
  categories = [],
  currentUserRole,
  lang = 'pt',
}) {
  const router = useRouter()
  const [sortField, setSortField] = useState('date-desc')
  const [statusFilter, setStatusFilter] = useState('all')
  const [categoryFilter, setCategoryFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [page, setPage] = useState(1)
  const [confirmAction, setConfirmAction] = useState(null)
  const [actionLoading, setActionLoading] = useState(null)

  const catById = useMemo(() => {
    const m = new Map()
    categories.forEach((c) => m.set(c.id, c))
    return m
  }, [categories])

  const filteredArticles = useMemo(() => {
    let filtered = articles.filter((article) => {
      if (statusFilter === 'archived') {
        if (!article.is_archived) return false
      } else if (statusFilter !== 'all' && article.status !== statusFilter) {
        return false
      } else if (statusFilter === 'all' && article.is_archived) {
        return false
      }
      if (categoryFilter !== 'all' && article.categoryId !== categoryFilter) return false
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        const haystack = [
          article.title,
          article.abstract,
          article.doi,
          article.category?.name,
          (article.authors || []).map((a) => a.name).join(' '),
        ].filter(Boolean).join(' ').toLowerCase()
        if (!haystack.includes(q)) return false
      }
      return true
    })

    filtered.sort((a, b) => {
      switch (sortField) {
        case 'date-asc': return new Date(a.publishedAt || 0) - new Date(b.publishedAt || 0)
        case 'date-desc': return new Date(b.publishedAt || 0) - new Date(a.publishedAt || 0)
        case 'title-asc': return (a.title || '').localeCompare(b.title || '', 'pt')
        case 'title-desc': return (b.title || '').localeCompare(a.title || '', 'pt')
        default: return 0
      }
    })

    return filtered
  }, [articles, sortField, statusFilter, categoryFilter, searchQuery])

  const totalPages = Math.max(1, Math.ceil(filteredArticles.length / PAGE_SIZE))
  const safePage = Math.min(page, totalPages)
  const pageArticles = filteredArticles.slice((safePage - 1) * PAGE_SIZE, safePage * PAGE_SIZE)

  const handleToggleStatus = async (id, currentStatus) => {
    const newLabel = currentStatus === 'published' ? 'Rascunho' : 'Publicado'
    if (!confirm(`Alterar status para "${newLabel}"?`)) return
    setActionLoading(`status-${id}`)
    try {
      const result = await toggleScientificArticleStatus(id, currentStatus)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao alterar status.')
    } finally {
      setActionLoading(null)
    }
  }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Artigos Científicos</h1>
        <p className="admin-page-subtitle">Gerir publicações académicas (perfil próprio, separado dos Artigos)</p>
      </div>

      <div style={{ display: 'flex', gap: 10, marginBottom: 16, flexWrap: 'wrap' }}>
        <Link href={`/${lang}/admin/cientificos/new`} className="admin-btn admin-btn-primary"
          style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
          <Plus size={16} /> Adicionar Artigo Científico
        </Link>
        <Link href={`/${lang}/admin/cientificos/categorias`} className="admin-btn admin-btn-secondary"
          style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
          Gerir Categorias
        </Link>
      </div>

      <div className="admin-list-filters" style={{ marginBottom: 16 }}>
        <div style={{ position: 'relative', flex: 1, minWidth: 180, maxWidth: 280 }}>
          <Search size={16} style={{ position: 'absolute', left: 10, top: '50%', transform: 'translateY(-50%)', color: 'var(--admin-text-muted)', pointerEvents: 'none' }} />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => { setSearchQuery(e.target.value); setPage(1) }}
            placeholder="Pesquisar título, autor, DOI..."
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
        <select className="admin-select" value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(1) }}>
          <option value="all">Todos os status</option>
          <option value="published">Publicados</option>
          <option value="draft">Rascunhos</option>
          <option value="archived">Arquivados</option>
        </select>
        <select className="admin-select" value={categoryFilter} onChange={(e) => { setCategoryFilter(e.target.value); setPage(1) }}>
          <option value="all">Todas as categorias</option>
          {categories.map((c) => (
            <option key={c.id} value={c.id}>{c.name}</option>
          ))}
        </select>
      </div>

      <div className="admin-dashboard-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <h3>Lista de Artigos Científicos</h3>
          <span style={{ fontSize: 13, color: 'var(--admin-text-muted)' }}>
            {filteredArticles.length} artigo(s)
          </span>
        </div>

        {pageArticles.length === 0 ? (
          <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>
            Nenhum artigo científico encontrado
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
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {pageArticles.map((article) => {
                  const cat = article.categoryId ? catById.get(article.categoryId) : null
                  return (
                    <tr key={article.id}>
                      <td>
                        <div style={{ fontWeight: 600 }}>{escapeHtml(article.title)}</div>
                        <div style={{ fontSize: 12, color: 'var(--admin-text-muted)' }}>
                          {escapeHtml(article.doi || 'sem DOI')}
                        </div>
                      </td>
                      <td>
                        {cat ? (
                          <span className="admin-status-badge" style={{ background: `${cat.color}22`, color: cat.color }}>
                            {escapeHtml(cat.name)}
                          </span>
                        ) : (
                          '-'
                        )}
                      </td>
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
                          <span className="admin-badge admin-badge-archived">
                            <Archive size={12} /> Arquivado
                          </span>
                        )}
                      </td>
                      <td>{formatDate(article.publishedAt)}</td>
                      <td>
                        <div className="admin-actions">
                          <Link href={`/${lang}/admin/cientificos/${article.id}`} className="admin-btn admin-btn-secondary">
                            <Pencil size={14} /> Editar
                          </Link>
                          {!article.is_archived ? (
                            <button type="button" onClick={() => setConfirmAction({ type: 'archive', id: article.id, title: article.title })}
                              className="admin-btn admin-btn-warning">
                              <Archive size={14} /> Arquivar
                            </button>
                          ) : (
                            currentUserRole === 'superadmin' && (
                              <button type="button"
                                onClick={async () => {
                                  setActionLoading(`restore-${article.id}`)
                                  try {
                                    const result = await restoreScientificArticle(article.id)
                                    if (!result.success) alert(result.error)
                                    else router.refresh()
                                  } catch {
                                    alert('Erro ao restaurar artigo.')
                                  } finally {
                                    setActionLoading(null)
                                  }
                                }}
                                className="admin-btn admin-btn-secondary">
                                <ArchiveRestore size={14} /> Restaurar
                              </button>
                            )
                          )}
                          {currentUserRole === 'superadmin' && (
                            <button type="button" onClick={() => setConfirmAction({ type: 'delete', id: article.id, title: article.title })}
                              className="admin-btn admin-btn-danger">
                              <Trash2 size={14} /> Eliminar
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
        )}

        <AdminPagination page={safePage} totalPages={totalPages} onPageChange={setPage} />
      </div>

      <ConfirmModal
        isOpen={!!confirmAction}
        onClose={() => setConfirmAction(null)}
        onConfirm={async () => {
          if (!confirmAction) return
          setActionLoading(`${confirmAction.type}-${confirmAction.id}`)
          try {
            const result = confirmAction.type === 'archive'
              ? await archiveScientificArticle(confirmAction.id)
              : await deleteScientificArticle(confirmAction.id)
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
            ? `"${confirmAction?.title}" será removido permanentemente (incluindo a tradução EN). Esta ação não pode ser revertida.`
            : `"${confirmAction?.title}" ficará oculto do público mas pode ser restaurado depois.`
        }
        confirmLabel={confirmAction?.type === 'delete' ? 'Eliminar' : 'Arquivar'}
        variant={confirmAction?.type === 'delete' ? 'danger' : 'warning'}
        loading={!!actionLoading && actionLoading.startsWith(confirmAction?.type ?? '')}
      />
    </>
  )
}
