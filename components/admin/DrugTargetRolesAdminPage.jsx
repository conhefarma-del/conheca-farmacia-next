'use client'

import { useMemo, useState, useCallback } from 'react'
import { RefreshCw, Search } from 'lucide-react'
import {
  getAllDrugTargetRolesAdmin,
  updateDrugTargetRole,
  archiveDrugTargetRole,
  restoreDrugTargetRole,
  deleteDrugTargetRole,
  rederiveDrugTargetRoles,
} from '@/lib/actions/alvos'
import AdminPagination from './AdminPagination'

const ROLE_LABELS = {
  substrate: 'Substrato',
  inhibitor: 'Inibidor',
  inducer: 'Indutor',
}

const PAGE_SIZE = 25

function roleBadge(role) {
  const cls = role === 'substrate' ? 'admin-badge-success' : role === 'inhibitor' ? 'admin-badge-warning' : 'admin-badge-info'
  return <span className={`admin-badge ${cls}`}>{ROLE_LABELS[role] || role}</span>
}

// Botão de re-derivar: chama o engine do servidor (ver page.js) — nesta
// componente apenas avisa que a re-derivação é feita no lado do servidor.
export default function DrugTargetRolesAdminPage({
  lang,
  initialRoles,
  initialDrugs,
  currentUserRole,
  initialCounts,
}) {
  const [roles, setRoles] = useState(initialRoles || [])
  const [drugs] = useState(initialDrugs || [])
  const [search, setSearch] = useState('')
  const [roleFilter, setRoleFilter] = useState('todos')
  const [statusFilter, setStatusFilter] = useState('todos')
  const [page, setPage] = useState(1)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)
  const isSuper = currentUserRole === 'superadmin'

  const [editingId, setEditingId] = useState(null)
  const [sourceDraft, setSourceDraft] = useState('')
  const [rederiveBusy, setRederiveBusy] = useState(false)
  const [rederiveResult, setRederiveResult] = useState(null)

  const refreshAll = useCallback(async () => {
    const list = await getAllDrugTargetRolesAdmin()
    setRoles(list || [])
  }, [])

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) } else { setError(text); setMessage(null) }
  }

  const run = async (fn, okText) => {
    const res = await fn()
    if (res.success) { showMessage(true, okText); refreshAll(); setPage(1) }
    else showMessage(false, res.error || 'Erro.')
  }

  const filtered = useMemo(() => {
    const termo = search.trim().toLowerCase()
    return (roles || []).filter((r) => {
      if (roleFilter !== 'todos' && r.role !== roleFilter) return false
      if (statusFilter !== 'todos') {
        if (statusFilter === 'arquivadas' && !r.is_archived) return false
        if (statusFilter === 'ativas' && r.is_archived) return false
      }
      if (!termo) return true
      return (
        (r.drug?.name || '').toLowerCase().includes(termo) ||
        (r.drug?.slug || '').toLowerCase().includes(termo) ||
        (r.target?.name || '').toLowerCase().includes(termo) ||
        (r.target?.slug || '').toLowerCase().includes(termo)
      )
    })
  }, [roles, search, roleFilter, statusFilter])

  const totalShown = filtered.length
  const totalPages = Math.max(1, Math.ceil(totalShown / PAGE_SIZE))
  const safePage = Math.min(page, totalPages)
  const start = (safePage - 1) * PAGE_SIZE
  const visible = filtered.slice(start, start + PAGE_SIZE)
  const rangeEnd = Math.min(safePage * PAGE_SIZE, totalShown)

  const startEdit = (r) => {
    setEditingId(r.id)
    setSourceDraft(r.source_pt || '')
  }
  const saveSource = async (r) => {
    const res = await updateDrugTargetRole(r.id, { source_pt: sourceDraft })
    if (res.success) showMessage(true, 'Fonte atualizada.')
    else showMessage(false, res.error || 'Erro.')
    setEditingId(null)
    refreshAll()
  }

  // Contagens por fármaco (só se vierem do servidor)
  const counts = initialCounts || {}

  const runRederive = async () => {
    setRederiveBusy(true)
    setRederiveResult(null)
    const res = await rederiveDrugTargetRoles()
    setRederiveBusy(false)
    if (res.success) {
      setRederiveResult(res)
      showMessage(true, `Re-derivação concluída: ${res.total} linhas derivadas, ${res.novos.length} novas.`)
    } else {
      showMessage(false, res.error || 'Erro ao re-derivar.')
    }
  }

  return (
    <div className="admin-alvos">
      <div className="admin-page-header">
        <h1>Ligações Fármaco ↔ Alvo</h1>
        <p className="admin-page-subtitle">
          Papéis (substrato / inibidor / indutor) de cada fármaco nos alvos moleculares — derivados do
          parse dos textos dos alvos e revistos aqui. Use o botão "Re-derivar" no final para comparar
          com os textos atuais (mostra candidatos novos, sem gravar).
        </p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-filters">
        <div className="admin-filters-search-wrap">
          <Search size={15} aria-hidden="true" />
          <input
            className="admin-filters-search"
            type="search"
            placeholder="Procurar fármaco ou alvo…"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1) }}
          />
        </div>
        <select
          className="admin-dim-input"
          style={{ maxWidth: 180 }}
          value={roleFilter}
          onChange={(e) => { setRoleFilter(e.target.value); setPage(1) }}
          aria-label="Filtrar por papel"
        >
          <option value="todos">Todos os papéis</option>
          <option value="substrate">Substrato</option>
          <option value="inhibitor">Inibidor</option>
          <option value="inducer">Indutor</option>
        </select>
        <select
          className="admin-dim-input"
          style={{ maxWidth: 180 }}
          value={statusFilter}
          onChange={(e) => { setStatusFilter(e.target.value); setPage(1) }}
          aria-label="Filtrar por estado"
        >
          <option value="todos">Ativas + arquivadas</option>
          <option value="ativas">Ativas</option>
          <option value="arquivadas">Arquivadas</option>
        </select>
      </div>

      <div className="admin-card" style={{ marginBottom: 18 }}>
        <div className="admin-card-body">
          <div className="admin-page-header" style={{ marginBottom: 10 }}>
            <h2 style={{ fontSize: 15 }}>Re-derivar do parse</h2>
            <p className="admin-page-subtitle">
              Volta a correr o motor de derivação contra os textos atuais dos alvos e mostra os
              candidatos <strong>novos</strong> (que ainda não existem na tabela) — não grava nada
              automaticamente.
            </p>
          </div>
          <button className="admin-btn admin-btn-primary" onClick={runRederive} disabled={rederiveBusy}>
            <RefreshCw size={14} style={{ marginRight: 6 }} aria-hidden="true" />
            {rederiveBusy ? 'A derivar…' : 'Re-derivar do parse'}
          </button>
          {rederiveResult && rederiveResult.novos && rederiveResult.novos.length > 0 && (
            <div className="admin-rederive-result" style={{ marginTop: 12 }}>
              <p className="admin-filters-count">{rederiveResult.novos.length} candidato(s) novo(s):</p>
              <ul style={{ margin: '8px 0 0 18px', fontSize: 13 }}>
                {rederiveResult.novos.slice(0, 25).map((n, i) => (
                  <li key={i}>{n.drug} × {n.target} — <strong>{ROLE_LABELS[n.role] || n.role}</strong></li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card-body">
          {totalShown > 0 && (
            <p className="admin-filters-count">A mostrar {start + 1}–{rangeEnd} de {totalShown}</p>
          )}
          {visible.length === 0 ? (
            <p className="admin-table-empty">Sem ligações com os filtros atuais.</p>
          ) : (
            <div className="admin-table-wrapper">
              <table className="admin-table">
                <thead>
                  <tr>
                    <th>Fármaco</th>
                    <th>Alvo</th>
                    <th>Papel</th>
                    <th>Fonte</th>
                    <th>Estado</th>
                    <th>Ações</th>
                  </tr>
                </thead>
                <tbody>
                  {visible.map((r) => (
                    <tr key={r.id} className={r.is_archived ? 'admin-table-row-archived' : ''}>
                      <td>
                        <strong>{r.drug?.name || '—'}</strong>
                        {r.drug?.slug && <div className="admin-table-sub">{r.drug.slug}</div>}
                      </td>
                      <td>
                        {r.target?.name || '—'}
                        {r.target?.slug && <div className="admin-table-sub">{r.target.slug}</div>}
                      </td>
                      <td>{roleBadge(r.role)}</td>
                      <td>
                        {editingId === r.id ? (
                          <div className="admin-inline-edit">
                            <input
                              className="admin-dim-input"
                              value={sourceDraft}
                              onChange={(e) => setSourceDraft(e.target.value)}
                              aria-label="Fonte"
                            />
                            <div className="admin-inline-actions">
                              <button className="admin-btn admin-btn-sm admin-btn-primary" onClick={() => saveSource(r)}>Guardar</button>
                              <button className="admin-btn admin-btn-sm" onClick={() => setEditingId(null)}>Cancelar</button>
                            </div>
                          </div>
                        ) : (
                          <span className="admin-table-sub" style={{ maxWidth: 320, display: 'block' }}>
                            {r.source_pt || '—'}
                          </span>
                        )}
                      </td>
                      <td>
                        {r.is_archived
                          ? <span className="admin-badge">Arquivada</span>
                          : r.status === 'published'
                            ? <span className="admin-badge admin-badge-success">Publicada</span>
                            : <span className="admin-badge admin-badge-warning">Rascunho</span>}
                      </td>
                      <td>
                        <div className="admin-table-actions">
                          <button className="admin-btn admin-btn-sm" onClick={() => startEdit(r)}>Editar fonte</button>
                          {!r.is_archived ? (
                            <>
                              <button
                                className="admin-btn admin-btn-sm"
                                onClick={() => run(() => updateDrugTargetRole(r.id, { status: r.status === 'published' ? 'draft' : 'published' }), 'Estado alternado.')}
                              >
                                {r.status === 'published' ? 'Pôr em rascunho' : 'Publicar'}
                              </button>
                              <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveDrugTargetRole(r.id), 'Arquivada (removida da página).')}>Remover</button>
                            </>
                          ) : (
                            <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreDrugTargetRole(r.id), 'Restaurada.')}>Restaurar</button>
                          )}
                          {isSuper && (
                            <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                              if (window.confirm(`Eliminar esta ligação (${r.drug?.name} × ${r.target?.name})?`)) run(() => deleteDrugTargetRole(r.id), 'Eliminada.')
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
    </div>
  )
}
