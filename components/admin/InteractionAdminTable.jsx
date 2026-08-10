'use client'

import { useMemo, useState } from 'react'
import Link from 'next/link'
import AdminPagination from './AdminPagination'

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">Arquivado</span>
}

const SEVERITY_LABELS = {
  critical: 'Grave',
  moderate: 'Moderada',
  minor: 'Menor',
  none: 'Sem relevância',
}

/**
 * Tabela de interações com filtros (busca, severidade, estado) e paginação.
 *  - `limit` (ex.: 10): modo "visão geral" — só as primeiras N + "Ver todos".
 *  - sem `limit`: modo completo — páginaSize por página com paginação.
 */
export default function InteractionAdminTable({
  interactions,
  currentUserRole,
  limit = null,
  pageSize = 25,
  viewAllHref = null,
  viewAllLabel = 'Ver todas as interações',
  onEdit,
  onArchive,
  onRestore,
  onDelete,
}) {
  const [search, setSearch] = useState('')
  const [severityFilter, setSeverityFilter] = useState('all')
  const [statusFilter, setStatusFilter] = useState('all')
  const [page, setPage] = useState(1)

  const isSuper = currentUserRole === 'superadmin'

  const filtered = useMemo(() => {
    const termo = search.trim().toLowerCase()
    let list = interactions.filter((i) => {
      const okBusca =
        !termo ||
        (i.drugAName && i.drugAName.toLowerCase().includes(termo)) ||
        (i.drugBName && i.drugBName.toLowerCase().includes(termo))
      const okSev = severityFilter === 'all' || i.severity === severityFilter
      const okStatus =
        statusFilter === 'all' ||
        (statusFilter === 'archived' ? i.is_archived : !i.is_archived && i.status === statusFilter)
      return okBusca && okSev && okStatus
    })
    const order = { critical: 0, moderate: 1, minor: 2, none: 3 }
    list = [...list].sort((a, b) => (order[a.severity] ?? 9) - (order[b.severity] ?? 9))
    return list
  }, [interactions, search, severityFilter, statusFilter])

  const totalShown = filtered.length
  const totalPages = limit ? 1 : Math.max(1, Math.ceil(totalShown / pageSize))
  const safePage = Math.min(page, totalPages)

  const visible = useMemo(() => {
    if (limit) return filtered.slice(0, limit)
    const start = (safePage - 1) * pageSize
    return filtered.slice(start, start + pageSize)
  }, [filtered, limit, pageSize, safePage])

  const rangeStart = limit ? 1 : (safePage - 1) * pageSize + 1
  const rangeEnd = limit ? Math.min(limit, totalShown) : Math.min(safePage * pageSize, totalShown)

  return (
    <div className="admin-card">
      <div className="admin-card-header">
        <h2>Interações</h2>
        {viewAllHref && (
          <Link href={viewAllHref} className="admin-btn admin-btn-secondary">
            {viewAllLabel} →
          </Link>
        )}
      </div>

      <div className="admin-filters">
        <input
          className="admin-filters-search"
          type="search"
          placeholder="Procurar por fármaco…"
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
        />
        <select className="admin-filters-select" value={severityFilter} onChange={(e) => { setSeverityFilter(e.target.value); setPage(1) }} aria-label="Filtrar por severidade">
          <option value="all">Todas as severidades</option>
          {Object.entries(SEVERITY_LABELS).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </select>
        <select className="admin-filters-select" value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(1) }} aria-label="Filtrar por estado">
          <option value="all">Todos os estados</option>
          <option value="published">Publicadas</option>
          <option value="draft">Rascunhos</option>
          <option value="archived">Arquivadas</option>
        </select>
      </div>

      <div className="admin-card-body">
        {totalShown > 0 && (
          <p className="admin-filters-count">
            A mostrar {rangeStart}–{rangeEnd} de {totalShown} interações.
          </p>
        )}
        {visible.length === 0 ? (
          <p className="admin-table-empty">Sem interações com os filtros atuais.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr><th>Fármaco A</th><th>Fármaco B</th><th>Severidade</th><th>Estado</th><th>Ações</th></tr>
            </thead>
            <tbody>
              {visible.map((i) => (
                <tr key={i.id} className={i.is_archived ? 'admin-table-row-archived' : ''}>
                  <td>{i.drugAName}</td>
                  <td>{i.drugBName}</td>
                  <td>
                    <span className={`admin-badge ${i.severity === 'critical' ? 'admin-badge-danger' : i.severity === 'moderate' ? 'admin-badge-warning' : i.severity === 'minor' ? 'admin-badge-warning' : 'admin-badge-success'}`}>
                      {SEVERITY_LABELS[i.severity] || i.severity}
                    </span>
                  </td>
                  <td>{statusBadge(i.is_archived ? 'archived' : i.status)}</td>
                  <td>
                    <div className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => onEdit(i)}>Editar</button>
                      {!i.is_archived ? (
                        <button className="admin-btn admin-btn-sm" onClick={() => onArchive(i)}>Arquivar</button>
                      ) : (
                        isSuper && (
                          <button className="admin-btn admin-btn-sm" onClick={() => onRestore(i)}>Restaurar</button>
                        )
                      )}
                      {isSuper && (
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => onDelete(i)}>Eliminar</button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        {!limit && (
          <AdminPagination page={safePage} totalPages={totalPages} onPageChange={setPage} />
        )}
      </div>
    </div>
  )
}
