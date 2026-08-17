'use client'

import { useMemo, useState, useCallback } from 'react'
import {
  getAllTargetsAdmin,
  archiveTarget,
  restoreTarget,
  deleteTarget,
} from '@/lib/actions/alvos'
import AdminPagination from './AdminPagination'
import AlvoForm from './AlvoForm'

const TYPE_LABELS = {
  cyp450: 'CYP450',
  cox: 'COX',
  transporter: 'Transportadores',
  mao: 'MAO',
  enzyme: 'Enzimas',
  receptor: 'Recetores',
  other: 'Outros',
}

const PAGE_SIZE = 25

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">—</span>
}

export default function AlvosAdminPage({ lang, initialTargets, currentUserRole }) {
  const [targets, setTargets] = useState(initialTargets || [])
  const [search, setSearch] = useState('')
  const [typeFilter, setTypeFilter] = useState('todos')
  const [page, setPage] = useState(1)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)
  const isSuper = currentUserRole === 'superadmin'

  const [panelOpen, setPanelOpen] = useState(false)
  const [panelRendered, setPanelRendered] = useState(false)
  const [editing, setEditing] = useState(null)

  const openPanel = (data) => {
    setEditing(data)
    setPanelRendered(true)
    requestAnimationFrame(() => setPanelOpen(true))
  }
  const closePanel = () => {
    setPanelOpen(false)
    setTimeout(() => setPanelRendered(false), 250)
  }

  const refreshAll = useCallback(async () => {
    const list = await getAllTargetsAdmin()
    setTargets(list || [])
  }, [])

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) } else { setError(text); setMessage(null) }
  }

  const filtered = useMemo(() => {
    const termo = search.trim().toLowerCase()
    return (targets || []).filter((t) => {
      if (typeFilter !== 'todos' && t.target_type !== typeFilter) return false
      if (!termo) return true
      return (
        t.name_pt.toLowerCase().includes(termo) ||
        t.name_en.toLowerCase().includes(termo) ||
        t.slug.toLowerCase().includes(termo) ||
        (t.full_name_pt || '').toLowerCase().includes(termo) ||
        (t.aliases || []).some((a) => a.toLowerCase().includes(termo))
      )
    })
  }, [targets, search, typeFilter])

  const totalShown = filtered.length
  const totalPages = Math.max(1, Math.ceil(totalShown / PAGE_SIZE))
  const safePage = Math.min(page, totalPages)
  const start = (safePage - 1) * PAGE_SIZE
  const visible = filtered.slice(start, start + PAGE_SIZE)
  const rangeEnd = Math.min(safePage * PAGE_SIZE, totalShown)

  const run = async (fn, okText) => {
    const res = await fn()
    if (res.success) { showMessage(true, okText); refreshAll(); setPage(1) }
    else showMessage(false, res.error || 'Erro.')
  }

  return (
    <div className="admin-alvos">
      <div className="admin-page-header">
        <h1>Alvos Moleculares</h1>
        <p className="admin-page-subtitle">CYP450, COX, transportadores e enzimas — o que são e como explicam as interações.</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-filters">
        <input
          className="admin-filters-search"
          type="search"
          placeholder="Procurar por nome, slug ou alias…"
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
        />
        <select
          className="admin-dim-input"
          style={{ maxWidth: 220 }}
          value={typeFilter}
          onChange={(e) => { setTypeFilter(e.target.value); setPage(1) }}
          aria-label="Filtrar por tipo"
        >
          <option value="todos">Todos os tipos</option>
          {Object.entries(TYPE_LABELS).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </select>
        <button className="admin-btn admin-btn-primary admin-btn-sm" onClick={() => openPanel(null)}>Novo alvo</button>
      </div>

      <div className="admin-card">
        <div className="admin-card-body">
          {totalShown > 0 && (
            <p className="admin-filters-count">A mostrar {start + 1}–{rangeEnd} de {totalShown}</p>
          )}
          {visible.length === 0 ? (
            <p className="admin-table-empty">Sem alvos com os filtros atuais.</p>
          ) : (
            <div className="admin-table-wrapper">
              <table className="admin-table">
                <thead>
                  <tr>
                    <th>Nome</th>
                    <th>Tipo</th>
                    <th>Slug</th>
                    <th>Aliases</th>
                    <th>Estado</th>
                    <th>Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {visible.map((t) => (
                    <tr key={t.id} className={t.is_archived ? 'admin-table-row-archived' : ''}>
                      <td>
                        <strong>{t.name_pt}</strong>
                        {t.full_name_pt && <div className="admin-table-sub">{t.full_name_pt}</div>}
                      </td>
                      <td>
                        <span className="admin-badge">{TYPE_LABELS[t.target_type] || t.target_type}</span>
                      </td>
                      <td><code>{t.slug}</code></td>
                      <td>{(t.aliases || []).join(', ') || '—'}</td>
                      <td>{statusBadge(t.is_archived ? null : t.status)}</td>
                      <td>
                        <div className="admin-table-actions">
                          <button className="admin-btn admin-btn-sm" onClick={() => openPanel(t)}>Editar</button>
                          {!t.is_archived ? (
                            <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveTarget(t.id), 'Arquivado.')}>Arquivar</button>
                          ) : (
                            isSuper && <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreTarget(t.id), 'Restaurado.')}>Restaurar</button>
                          )}
                          {isSuper && (
                            <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                              if (window.confirm(`Eliminar "${t.name_pt}"?`)) run(() => deleteTarget(t.id), 'Eliminado.')
                            }}>Eliminar</button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
          <AdminPagination page={safePage} totalPages={totalPages} onPageChange={setPage} />
        </div>
      </div>

      {panelRendered && (
        <AlvoForm
          initialData={editing}
          panelOpen={panelOpen}
          onClose={closePanel}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) { refreshAll(); closePanel() } }}
        />
      )}
    </div>
  )
}
