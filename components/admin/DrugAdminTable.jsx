'use client'

import { useMemo, useState } from 'react'
import Link from 'next/link'
import AdminPagination from './AdminPagination'
import InlineProfileForm from './InlineProfileForm'
import InlinePharmacologyForm from './InlinePharmacologyForm'

function statusBadge(status) {
  if (status === 'published') return <span className="admin-badge admin-badge-success">Publicado</span>
  if (status === 'draft') return <span className="admin-badge admin-badge-warning">Rascunho</span>
  return <span className="admin-badge">Arquivado</span>
}

const ATC_LETTERS = ['A', 'B', 'C', 'D', 'G', 'H', 'J', 'L', 'M', 'N', 'P', 'R', 'S', 'V']

/**
 * Tabela de fármacos com filtros (busca, ordem, grupo/classe, letra ATC,
 * estado) e paginação.
 *  - `limit` (ex.: 10): modo "visão geral" — mostra só as primeiras N com
 *    botão "Ver todos" (sem paginação).
 *  - sem `limit`: modo completo — páginaSize por página com paginação.
 */
export default function DrugAdminTable({
  drugs,
  currentUserRole,
  limit = null,
  pageSize = 25,
  viewAllHref = null,
  viewAllLabel = 'Ver todos os fármacos',
  onProfile,
  onPharmacology,
  onEdit,
  onArchive,
  onRestore,
  onDelete,
  inlineForms = false,
  onMessage,
  onReload,
}) {
  const [search, setSearch] = useState('')
  const [sortBy, setSortBy] = useState('default') // default | alpha | atc
  const [groupFilter, setGroupFilter] = useState('')
  const [atcLetter, setAtcLetter] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [page, setPage] = useState(1)
  const [expandedDrugId, setExpandedDrugId] = useState(null)
  const [expandedPanel, setExpandedPanel] = useState(null) // 'profile' | 'pharmacology' | null

  const isSuper = currentUserRole === 'superadmin'

  const groups = useMemo(() => {
    const set = new Set()
    drugs.forEach((d) => { if (d.class_pt) set.add(d.class_pt) })
    return [...set].sort((a, b) => a.localeCompare(b, 'pt'))
  }, [drugs])

  const filtered = useMemo(() => {
    const termo = search.trim().toLowerCase()
    let list = drugs.filter((d) => {
      const okBusca =
        !termo ||
        (d.name_pt && d.name_pt.toLowerCase().includes(termo)) ||
        (d.name_en && d.name_en.toLowerCase().includes(termo)) ||
        (d.slug && d.slug.toLowerCase().includes(termo)) ||
        (d.aliases || []).some((a) => a.toLowerCase().includes(termo))
      const okGrupo = !groupFilter || d.class_pt === groupFilter
      const okAtc = !atcLetter || (d.atc_code || '').startsWith(atcLetter)
      const okStatus =
        statusFilter === 'all' ||
        (statusFilter === 'archived' ? d.is_archived : !d.is_archived && d.status === statusFilter)
      return okBusca && okGrupo && okAtc && okStatus
    })
    if (sortBy === 'alpha') list = [...list].sort((a, b) => (a.name_pt || '').localeCompare(b.name_pt || '', 'pt'))
    else if (sortBy === 'atc') list = [...list].sort((a, b) => (a.atc_code || '').localeCompare(b.atc_code || ''))
    return list
  }, [drugs, search, sortBy, groupFilter, atcLetter, statusFilter])

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

  const toggleExpand = (drugId, panel) => {
    if (expandedDrugId === drugId && expandedPanel === panel) {
      setExpandedDrugId(null)
      setExpandedPanel(null)
    } else {
      setExpandedDrugId(drugId)
      setExpandedPanel(panel)
    }
  }

  const handleInlineSaved = (ok, text) => {
    if (onMessage) onMessage(ok, text)
    if (ok && onReload) onReload()
    setExpandedDrugId(null)
    setExpandedPanel(null)
  }

  return (
    <div className="admin-card">
      <div className="admin-card-header">
        <h2>Fármacos</h2>
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
          placeholder="Procurar fármaco (nome, slug, alias)…"
          value={search}
          onChange={(e) => { setSearch(e.target.value); setPage(1) }}
        />
        <select className="admin-filters-select" value={sortBy} onChange={(e) => { setSortBy(e.target.value); setPage(1) }} aria-label="Ordenar por">
          <option value="default">Ordem padrão</option>
          <option value="alpha">Ordem alfabética</option>
          <option value="atc">Classificação ATC</option>
        </select>
        <select className="admin-filters-select" value={groupFilter} onChange={(e) => { setGroupFilter(e.target.value); setPage(1) }} aria-label="Filtrar por grupo">
          <option value="">Todos os grupos</option>
          {groups.map((g) => <option key={g} value={g}>{g}</option>)}
        </select>
        <select className="admin-filters-select" value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(1) }} aria-label="Filtrar por estado">
          <option value="all">Todos os estados</option>
          <option value="published">Publicados</option>
          <option value="draft">Rascunhos</option>
          <option value="archived">Arquivados</option>
        </select>
        <div className="admin-atc-letters" role="group" aria-label="Filtrar por letra ATC">
          <button
            type="button"
            className={`admin-atc-letter${atcLetter === '' ? ' is-active' : ''}`}
            onClick={() => { setAtcLetter(''); setPage(1) }}
          >
            Todos
          </button>
          {ATC_LETTERS.map((l) => (
            <button
              key={l}
              type="button"
              className={`admin-atc-letter${atcLetter === l ? ' is-active' : ''}`}
              onClick={() => { setAtcLetter(atcLetter === l ? '' : l); setPage(1) }}
            >
              {l}
            </button>
          ))}
        </div>
      </div>

      <div className="admin-card-body">
        {totalShown > 0 && (
          <p className="admin-filters-count">
            A mostrar {rangeStart}–{rangeEnd} de {totalShown} fármacos.
          </p>
        )}
        {visible.length === 0 ? (
          <p className="admin-table-empty">Sem fármacos com os filtros atuais.</p>
        ) : (
          <table className="admin-table">
            <thead>
              <tr><th>Nome</th><th>Classe</th><th>ATC</th><th>Estado</th><th>Interações</th><th>Perfil</th><th>Farmacologia</th><th>Ordem</th><th>Ações</th></tr>
            </thead>
            <tbody>
              {visible.map((d) => (
                <>
                  <tr key={d.id} className={d.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{d.name_pt} / {d.name_en}</td>
                    <td>{d.class_pt || '—'}</td>
                    <td>{d.atc_code || '—'}</td>
                    <td>{statusBadge(d.is_archived ? 'archived' : d.status)}</td>
                    <td>{d.interactionCount}</td>
                    <td>{d.profileStatus ? statusBadge(d.profileStatus) : <span className="admin-badge">—</span>}</td>
                    <td>{d.pharmacologyStatus ? statusBadge(d.pharmacologyStatus) : <span className="admin-badge">—</span>}</td>
                    <td>{d.sort_order}</td>
                    <td>
                      <div className="admin-table-actions">
                        <button className="admin-btn admin-btn-sm" onClick={() => inlineForms ? toggleExpand(d.id, 'profile') : onProfile(d)}>Perfil</button>
                        <button className="admin-btn admin-btn-sm" onClick={() => inlineForms ? toggleExpand(d.id, 'pharmacology') : onPharmacology(d)}>Farmacologia</button>
                        <button className="admin-btn admin-btn-sm" onClick={() => onEdit(d)}>Editar</button>
                        {!d.is_archived ? (
                          <button className="admin-btn admin-btn-sm" onClick={() => onArchive(d)}>Arquivar</button>
                        ) : (
                          isSuper && (
                            <button className="admin-btn admin-btn-sm" onClick={() => onRestore(d)}>Restaurar</button>
                          )
                        )}
                        {isSuper && (
                          <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => onDelete(d)}>Eliminar</button>
                        )}
                      </div>
                    </td>
                  </tr>
                  {expandedDrugId === d.id && expandedPanel === 'profile' && (
                    <tr key={`${d.id}-profile`} className="admin-table-expanded-row">
                      <td colSpan={9}>
                        <InlineProfileForm
                          drug={d}
                          onClose={() => { setExpandedDrugId(null); setExpandedPanel(null) }}
                          onSaved={handleInlineSaved}
                        />
                      </td>
                    </tr>
                  )}
                  {expandedDrugId === d.id && expandedPanel === 'pharmacology' && (
                    <tr key={`${d.id}-pharm`} className="admin-table-expanded-row">
                      <td colSpan={9}>
                        <InlinePharmacologyForm
                          drug={d}
                          onClose={() => { setExpandedDrugId(null); setExpandedPanel(null) }}
                          onSaved={handleInlineSaved}
                        />
                      </td>
                    </tr>
                  )}
                </>
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
