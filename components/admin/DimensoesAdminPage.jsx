'use client'

import { useMemo, useState, useCallback } from 'react'
import {
  archiveDrugDimension, restoreDrugDimension, deleteDrugDimension,
  getAllFoodDimensions, getAllDiseaseDimensions, getAllPregnancyDimensions,
} from '@/lib/actions/interacoes'
import AdminPagination from './AdminPagination'
import DimensionForm from './DimensionForm'

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">—</span>
}

const SEVERITY_LABELS = {
  critical: 'Grave', moderate: 'Moderada', minor: 'Menor', none: 'Sem relevância',
}

const TABS = [
  { key: 'food', label: 'Alimentos & bebidas' },
  { key: 'disease', label: 'Doenças' },
  { key: 'pregnancy', label: 'Gestação' },
]

const PAGE_SIZE = 25

function DimTable({ rows, tabKey, currentUserRole, onRefresh, onEdit, onNew }) {
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  const isSuper = currentUserRole === 'superadmin'
  const table = tabKey === 'food' ? 'drug_food_interactions' : tabKey === 'disease' ? 'drug_disease_interactions' : 'drug_pregnancy_info'

  const filtered = useMemo(() => {
    const termo = search.trim().toLowerCase()
    return rows.filter((r) => {
      if (!termo) return true
      return (
        (r.drugName && r.drugName.toLowerCase().includes(termo)) ||
        (r.entity || r.condition || '').toLowerCase().includes(termo)
      )
    })
  }, [rows, search])

  const totalShown = filtered.length
  const totalPages = Math.max(1, Math.ceil(totalShown / PAGE_SIZE))
  const safePage = Math.min(page, totalPages)
  const start = (safePage - 1) * PAGE_SIZE
  const visible = filtered.slice(start, start + PAGE_SIZE)
  const rangeEnd = Math.min(safePage * PAGE_SIZE, totalShown)

  const run = async (fn, okText) => {
    const res = await fn()
    if (res.success) { onRefresh(); setPage(1) }
  }

  return (
    <div>
      <div className="admin-filters">
        <input
          className="admin-filters-search"
          type="search"
          placeholder="Procurar por fármaco ou entidade…"
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
        />
        <button className="admin-btn admin-btn-primary admin-btn-sm" onClick={onNew}>Nova</button>
      </div>
      <div className="admin-card-body">
        {totalShown > 0 && (
          <p className="admin-filters-count">A mostrar {start + 1}–{rangeEnd} de {totalShown}</p>
        )}
        {visible.length === 0 ? (
          <p className="admin-table-empty">Sem registos com os filtros atuais.</p>
        ) : tabKey === 'pregnancy' ? (
          <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr><th>Fármaco</th><th>Categoria</th><th>Risco</th><th>Estado</th><th>Ações</th></tr>
            </thead>
            <tbody>
              {visible.map((r) => (
                <tr key={r.id} className={r.isArchived ? 'admin-table-row-archived' : ''}>
                  <td>{r.drugName}</td>
                  <td>{r.pregnancyCategory}</td>
                  <td>{r.risk}</td>
                  <td>{statusBadge(r.isArchived ? null : r.status)}</td>
                  <td>
                    <div className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => onEdit(r)}>Editar</button>
                      {!r.isArchived ? (
                        <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveDrugDimension(table, r.id), 'Arquivado.')}>Arquivar</button>
                      ) : (
                        isSuper && <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreDrugDimension(table, r.id), 'Restaurado.')}>Restaurar</button>
                      )}
                      {isSuper && (
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                          if (window.confirm('Eliminar?')) run(() => deleteDrugDimension(table, r.id), 'Eliminado.')
                        }}>Eliminar</button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          </div>
        ) : (
          <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr><th>Fármaco</th><th>{tabKey === 'food' ? 'Alimento' : 'Condição'}</th><th>Severidade</th><th>Estado</th><th>Ações</th></tr>
            </thead>
            <tbody>
              {visible.map((r) => (
                <tr key={r.id} className={r.isArchived ? 'admin-table-row-archived' : ''}>
                  <td>{r.drugName}</td>
                  <td>{r.entity || r.condition}</td>
                  <td>
                    <span className={`admin-badge ${r.severity === 'critical' ? 'admin-badge-danger' : r.severity === 'moderate' ? 'admin-badge-warning' : r.severity === 'minor' ? 'admin-badge-warning' : 'admin-badge-success'}`}>
                      {SEVERITY_LABELS[r.severity] || r.severity}
                    </span>
                  </td>
                  <td>{statusBadge(r.isArchived ? null : r.status)}</td>
                  <td>
                    <div className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => onEdit(r)}>Editar</button>
                      {!r.isArchived ? (
                        <button className="admin-btn admin-btn-sm" onClick={() => run(() => archiveDrugDimension(table, r.id), 'Arquivado.')}>Arquivar</button>
                      ) : (
                        isSuper && <button className="admin-btn admin-btn-sm" onClick={() => run(() => restoreDrugDimension(table, r.id), 'Restaurado.')}>Restaurar</button>
                      )}
                      {isSuper && (
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                          if (window.confirm('Eliminar?')) run(() => deleteDrugDimension(table, r.id), 'Eliminado.')
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
  )
}

export default function DimensoesAdminPage({ lang, initialDrugs, initialFood, initialDisease, initialPregnancy, currentUserRole }) {
  const [food, setFood] = useState(initialFood || [])
  const [disease, setDisease] = useState(initialDisease || [])
  const [pregnancy, setPregnancy] = useState(initialPregnancy || [])
  const drugs = initialDrugs || []
  const [activeTab, setActiveTab] = useState('food')
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)

  // Painel de edição
  const [dimPanelOpen, setDimPanelOpen] = useState(false)
  const [dimPanelRendered, setDimPanelRendered] = useState(false)
  const [editingDim, setEditingDim] = useState(null) // { type, data }

  const openDimPanel = (type, data) => {
    setEditingDim({ type, data })
    setDimPanelRendered(true)
    requestAnimationFrame(() => setDimPanelOpen(true))
  }
  const closeDimPanel = () => {
    setDimPanelOpen(false)
    setTimeout(() => setDimPanelRendered(false), 250)
  }

  const refreshAll = useCallback(async () => {
    const [f, d, p] = await Promise.all([getAllFoodDimensions(), getAllDiseaseDimensions(), getAllPregnancyDimensions()])
    setFood(f)
    setDisease(d)
    setPregnancy(p)
  }, [])

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) } else { setError(text); setMessage(null) }
  }

  const rows = activeTab === 'food' ? food : activeTab === 'disease' ? disease : pregnancy

  return (
    <div className="admin-interacoes">
      <div className="admin-page-header">
        <h1>Dimensões de interações</h1>
        <p className="admin-page-subtitle">Alimentos, doenças e gestação associados a cada fármaco.</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-tabs" role="tablist" aria-label="Dimensões">
        {TABS.map((t) => (
          <button
            key={t.key}
            role="tab"
            aria-selected={activeTab === t.key}
            className={`admin-tab${activeTab === t.key ? ' is-active' : ''}`}
            onClick={() => setActiveTab(t.key)}
          >
            {t.label}
            <span className="admin-tab-count">{rows.length}</span>
          </button>
        ))}
      </div>

      <div className="admin-card" role="tabpanel">
        <DimTable
          key={activeTab}
          rows={rows}
          tabKey={activeTab}
          currentUserRole={currentUserRole}
          onRefresh={refreshAll}
          onEdit={(r) => openDimPanel(activeTab, { ...r, drugId: r.drugId })}
          onNew={() => openDimPanel(activeTab, null)}
        />
      </div>

      {dimPanelRendered && (
        <DimensionForm
          type={editingDim.type}
          initialData={editingDim.data}
          drugs={drugs}
          panelOpen={dimPanelOpen}
          onClose={closeDimPanel}
          onSaved={(ok, text) => { showMessage(ok, text); if (ok) { refreshAll(); closeDimPanel() } }}
        />
      )}
    </div>
  )
}