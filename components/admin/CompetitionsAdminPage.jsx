'use client'

import { useState, useCallback } from 'react'
import Link from 'next/link'
import { Plus, Play, Square, Trash2, Eye, Clock } from 'lucide-react'
import { getAllCompetitionsAdmin, startCompetition, endCompetition, cancelCompetition, deleteCompetition } from '@/lib/actions/competition'

const STATUS_LABELS = {
  draft: { label: 'Rascunho', color: 'admin-badge-warning' },
  lobby: { label: 'Lobby', color: 'admin-badge-info' },
  active: { label: 'Ativa', color: 'admin-badge-success' },
  ended: { label: 'Terminada', color: 'admin-badge' },
  cancelled: { label: 'Cancelada', color: 'admin-badge-danger' },
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-PT', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })
}

export default function CompetitionsAdminPage({ lang, initialCompetitions = [], currentUserRole }) {
  const [competitions, setCompetitions] = useState(initialCompetitions)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)
  const isSuper = currentUserRole === 'superadmin'

  const refresh = useCallback(async () => {
    const list = await getAllCompetitionsAdmin()
    setCompetitions(list || [])
  }, [])

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) } else { setError(text); setMessage(null) }
  }

  const handleAction = async (fn, okText) => {
    const res = await fn()
    if (res.success) { showMessage(true, okText); refresh() } else showMessage(false, res.error)
  }

  return (
    <div>
      <div className="admin-page-header">
        <h1>Competições</h1>
        <p className="admin-page-subtitle">Gerir competições de quiz inter-escolas</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-card">
        <div className="admin-card-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h3>Lista de Competições</h3>
          <Link href={`/${lang}/admin/competicoes/new`} className="admin-btn admin-btn-primary admin-btn-sm">
            <Plus size={14} /> Nova Competição
          </Link>
        </div>

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr><th>Nome</th><th>Código</th><th>Estado</th><th>Participantes</th><th>Criada</th><th>Ações</th></tr>
            </thead>
            <tbody>
              {competitions.map((c) => {
                const status = STATUS_LABELS[c.status] || STATUS_LABELS.draft
                return (
                  <tr key={c.id}>
                    <td>
                      <Link href={`/${lang}/admin/competicoes/${c.id}`} style={{ fontWeight: 600, color: 'var(--admin-accent)' }}>
                        {c.name}
                      </Link>
                      <div style={{ fontSize: 12, color: 'var(--admin-text-muted)' }}>{c.questions_count} perguntas · {c.time_per_question}s</div>
                    </td>
                    <td><code style={{ fontWeight: 700 }}>{c.access_code}</code></td>
                    <td><span className={`admin-badge ${status.color}`}>{status.label}</span></td>
                    <td>{c.participantCount}</td>
                    <td style={{ fontSize: 12 }}>{formatDate(c.created_at)}</td>
                    <td>
                      <div className="admin-table-actions">
                        <Link href={`/${lang}/admin/competicoes/${c.id}`} className="admin-btn admin-btn-sm">
                          <Eye size={14} /> Detalhe
                        </Link>
                        {c.status === 'draft' && (
                          <button className="admin-btn admin-btn-sm admin-btn-success" onClick={() => handleAction(() => startCompetition(c.id), 'Lobby aberto!')}>
                            <Play size={14} /> Iniciar
                          </button>
                        )}
                        {(c.status === 'lobby' || c.status === 'active') && (
                          <button className="admin-btn admin-btn-sm admin-btn-warning" onClick={() => handleAction(() => endCompetition(c.id), 'Competição terminada.')}>
                            <Square size={14} /> Terminar
                          </button>
                        )}
                        {c.status === 'lobby' && (
                          <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => handleAction(() => cancelCompetition(c.id), 'Cancelada.')}>
                            Cancelar
                          </button>
                        )}
                        {isSuper && c.status === 'ended' && (
                          <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => {
                            if (window.confirm(`Eliminar "${c.name}"?`)) handleAction(() => deleteCompetition(c.id), 'Eliminada.')
                          }}>
                            <Trash2 size={14} />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                )
              })}
              {competitions.length === 0 && (
                <tr><td colSpan={6} style={{ textAlign: 'center', padding: 40, color: 'var(--admin-text-muted)' }}>Nenhuma competição criada</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
