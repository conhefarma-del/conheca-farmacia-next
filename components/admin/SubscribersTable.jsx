'use client'

import { useState, useCallback, useMemo } from 'react'
import { useRouter } from 'next/navigation'
import { RotateCcw, Trash2 } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { unsubscribeSubscriber, reactivateSubscriber } from '@/lib/actions/newsletter'
import RemoveSubscriberModal from '@/components/admin/RemoveSubscriberModal'

/**
 * SubscribersTable — Client Component
 *
 * Tabela interativa de subscritores com:
 * - Filtros (all/active/unsubscribed)
 * - Pesquisa por email
 * - Checkboxes para seleção manual (modo "manual" de envio)
 * - Ações: cancelar inscrição, reativar
 *
 * Props:
 *   - subscribers: Array
 *   - sendMode: 'all' | 'manual' | 'random'
 *   - selectedEmails: Set
 *   - onSelectionChange: (emails: Set) => void
 */

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('pt-PT', {
    day: '2-digit', month: 'short', year: 'numeric',
  }).toUpperCase()
}

export default function SubscribersTable({
  subscribers = [],
  sendMode = 'all',
  selectedEmails = new Set(),
  onSelectionChange,
}) {
  const router = useRouter()
  const [statusFilter, setStatusFilter] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [actionLoading, setActionLoading] = useState(null)
  const [removeTarget, setRemoveTarget] = useState(null)

  // Filtrar subscritores
  const filteredSubscribers = useMemo(() => {
    return subscribers.filter((sub) => {
      if (statusFilter !== 'all' && sub.status !== statusFilter) return false
      if (searchQuery) {
        const q = searchQuery.toLowerCase()
        if (!sub.email.toLowerCase().includes(q)) return false
      }
      return true
    })
  }, [subscribers, statusFilter, searchQuery])

  // Toggle seleção de email
  const handleCheckboxChange = useCallback((email, checked) => {
    const next = new Set(selectedEmails)
    if (checked) next.add(email)
    else next.delete(email)
    onSelectionChange?.(next)
  }, [selectedEmails, onSelectionChange])

  // Select all / deselect all
  const handleSelectAll = useCallback((checked) => {
    if (checked) {
      const allActive = filteredSubscribers
        .filter(s => s.status === 'active')
        .map(s => s.email)
      onSelectionChange?.(new Set(allActive))
    } else {
      onSelectionChange?.(new Set())
    }
  }, [filteredSubscribers, onSelectionChange])

  // Cancelar inscrição (soft delete)
  const handleUnsubscribe = useCallback(async (id) => {
    setActionLoading(`unsub-${id}`)
    try {
      const result = await unsubscribeSubscriber(id)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao cancelar inscrição.')
    } finally {
      setActionLoading(null)
      setRemoveTarget(null)
    }
  }, [router])

  // Reativar subscritor
  const handleReactivate = useCallback(async (id) => {
    setActionLoading(`reactivate-${id}`)
    try {
      const result = await reactivateSubscriber(id)
      if (!result.success) alert(result.error)
      else router.refresh()
    } catch {
      alert('Erro ao reativar subscritor.')
    } finally {
      setActionLoading(null)
    }
  }, [router])

  const showCheckbox = sendMode === 'manual'

  return (
    <>
      {/* Filtros */}
      <div className="admin-list-filters" style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
        {['all', 'active', 'unsubscribed'].map((status) => (
          <button
            key={status}
            className={`filter-btn${statusFilter === status ? ' active' : ''}`}
            onClick={() => setStatusFilter(status)}
            style={{
              padding: '6px 16px', borderRadius: 20, fontSize: 13, cursor: 'pointer',
              border: '1px solid var(--admin-border)', fontWeight: 500,
              background: statusFilter === status ? 'var(--admin-primary)' : 'var(--admin-card-bg)',
              color: statusFilter === status ? 'white' : 'var(--admin-text)',
            }}
          >
            {status === 'all' ? 'Todos' : status === 'active' ? 'Ativos' : 'Cancelados'}
          </button>
        ))}
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Pesquisar por email..."
          className="admin-input"
          style={{ marginLeft: 'auto', maxWidth: 250 }}
        />
      </div>

      {/* Tabela */}
      {filteredSubscribers.length === 0 ? (
        <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>
          Nenhum subscritor encontrado.
        </p>
      ) : (
        <div className="admin-table-wrapper">
          <table className="admin-table" style={{ width: '100%' }}>
            <thead>
              <tr>
                {showCheckbox && (
                  <th style={{ width: 40, textAlign: 'center' }}>
                    <input
                      type="checkbox"
                      onChange={(e) => handleSelectAll(e.target.checked)}
                      checked={filteredSubscribers.filter(s => s.status === 'active').every(s => selectedEmails.has(s.email))}
                      title="Selecionar todos"
                      style={{ cursor: 'pointer' }}
                    />
                  </th>
                )}
                <th>Email</th>
                <th>Estado</th>
                <th>Data</th>
                <th style={{ width: 50 }}></th>
              </tr>
            </thead>
            <tbody>
              {filteredSubscribers.map((sub) => (
                <tr key={sub.id}>
                  {showCheckbox && (
                    <td style={{ textAlign: 'center' }}>
                      {sub.status === 'active' && (
                        <input
                          type="checkbox"
                          checked={selectedEmails.has(sub.email)}
                          onChange={(e) => handleCheckboxChange(sub.email, e.target.checked)}
                          style={{ cursor: 'pointer' }}
                        />
                      )}
                    </td>
                  )}
                  <td style={{ fontSize: 14 }}>{escapeHtml(sub.email)}</td>
                  <td>
                    <span style={{
                      display: 'inline-block', padding: '4px 10px', borderRadius: 12,
                      fontSize: 12, fontWeight: 600,
                      background: sub.status === 'active' ? '#dcfce7' : '#fee2e2',
                      color: sub.status === 'active' ? '#166534' : '#991b1b',
                    }}>
                      {sub.status === 'active' ? 'Ativo' : 'Cancelado'}
                    </span>
                  </td>
                  <td style={{ fontSize: 13, color: 'var(--admin-text-muted)' }}>{formatDate(sub.created_at)}</td>
                  <td style={{ textAlign: 'center' }}>
                    {sub.status === 'unsubscribed' ? (
                      <button
                        onClick={() => handleReactivate(sub.id)}
                        disabled={actionLoading === `reactivate-${sub.id}`}
                        title="Reativar subscrição"
                        style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#16a34a', padding: 4 }}
                      >
                        <RotateCcw size={16} />
                      </button>
                    ) : (
                      <button
                        onClick={() => setRemoveTarget(sub)}
                        title="Remover subscritor"
                        style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--admin-text-muted)', padding: 4 }}
                      >
                        <Trash2 size={16} />
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Modal de remoção */}
      <RemoveSubscriberModal
        isOpen={!!removeTarget}
        subscriber={removeTarget}
        onClose={() => setRemoveTarget(null)}
        onComplete={() => router.refresh()}
      />
    </>
  )
}
