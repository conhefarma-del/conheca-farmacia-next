'use client'

import { useMemo, useState, useCallback } from 'react'
import {
  getAllClassesAdmin,
  archiveClass,
  restoreClass,
  deleteClass,
} from '@/lib/actions/classes'
import AdminPagination from './AdminPagination'
import ClassForm from './ClassForm'

const PAGE_SIZE = 25

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">—</span>
}

export default function ClassesAdminPage({ lang, initialClasses, currentUserRole }) {
  const [classes, setClasses] = useState(initialClasses || [])
  const [search, setSearch] = useState('')
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
    const list = await getAllClassesAdmin()
    setClasses(list || [])
  }, [])

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) } else { setError(text); setMessage(null) }
  }

  const filtered = useMemo(() => {
    const termo = search.trim().toLowerCase()
    return (classes || []).filter((c) => {
      if (!termo) return true
      return (
        c.name_pt.toLowerCase().includes(termo) ||
        c.name_en.toLowerCase().includes(termo) ||
        c.slug.toLowerCase().includes(termo) ||
        (c.atc_prefix || '').toLowerCase().includes(termo)
      )
    })
  }, [classes, search])

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
        <h1>Classes Terapêuticas</h1>
        <p className="admin-page-subtitle">Gerir classes de fármacos, descrições e códigos ATC.</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-filters">
        <input
          className="admin-filters-search"
          type="search"
          placeholder="Procurar por nome, slug ou ATC…"
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
        />
        <button className="admin-btn admin-btn-primary admin-btn-sm" onClick={() => openPanel(null)}>Nova classe</button>
      </div>

      <div className="admin-card">
        <div className="admin-card-body">
          {totalShown > 0 && (
            <p className="admin-filters-count">A mostrar {start + 1}–{rangeEnd} de {totalShown}</p>
          )}
          {visible.length === 0 ? (
            <p className="admin-table-empty">Sem classes com os filtros atuais.</p>
          ) : (
            <div className="admin-table-wrapper">
              <table className="admin-table">
                <thead>
                  <tr>
                    <th>Nome</th>
                    <th>ATC</th>
                    <th>Fármacos</th>
                    <th>Estado</th>
                    <th>Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {visible.map((c) => (
                    <tr key={c.id} className={c.is_archived ? 'admin-table-row-archived' : ''}>
                      <td>
                        <strong>{c.name_pt}</strong>
                        <div className="admin-table-sub">{c.name_en}</div>
                      </td>
                      <td><code>{c.atc_prefix || '—'}</code></td>
                      <td>{c.drugCount ?? 0}</td>
                      <td>{statusBadge(c.is_archived ? null : c.status)}</td>
                      <td>
                        <div className="admin-table-actions">
                          <button className="admin-btn admin-btn-sm" onClick={() => openPanel(c)}>Editar</button>
                          {!c.is_archived ? (
                            <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveClass(c.id), 'Arquivada.')}>Arquivar</button>
                          ) : (
                            isSuper && <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreClass(c.id), 'Restaurada.')}>Restaurar</button>
                          )}
                          {isSuper && (
                            <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                              if (window.confirm(`Eliminar "${c.name_pt}"? Os fármacos ficarão sem classe.`)) run(() => deleteClass(c.id), 'Eliminada.')
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
        <ClassForm
          initialData={editing}
          panelOpen={panelOpen}
          onClose={closePanel}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) { refreshAll(); closePanel() } }}
        />
      )}
    </div>
  )
}
