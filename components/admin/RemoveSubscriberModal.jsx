'use client'

import { useState, useCallback, useEffect } from 'react'
import { Trash2, X } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { unsubscribeSubscriber, deleteSubscriber } from '@/lib/actions/newsletter'

/**
 * RemoveSubscriberModal — Client Component
 *
 * Modal com duas opções:
 * 1. Cancelar inscrição (soft delete — status = 'unsubscribed')
 * 2. Apagar permanentemente (hard delete — DELETE)
 *
 * Props:
 *   - isOpen: boolean
 *   - subscriber: { id, email } | null
 *   - onClose: () => void
 *   - onComplete: () => void — chamado após operação bem-sucedida
 */

export default function RemoveSubscriberModal({
  isOpen,
  subscriber,
  onClose,
  onComplete,
}) {
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  // Fechar com Escape
  useEffect(() => {
    if (!isOpen) return
    const handleEscape = (e) => {
      if (e.key === 'Escape') onClose?.()
    }
    document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [isOpen, onClose])

  const handleUnsubscribe = useCallback(async () => {
    if (!subscriber?.id) return
    setError('')
    setLoading(true)

    try {
      const result = await unsubscribeSubscriber(subscriber.id)
      if (result.success) {
        onComplete?.()
        onClose?.()
      } else {
        setError(result.error || 'Erro ao cancelar inscrição.')
      }
    } catch {
      setError('Erro ao cancelar inscrição.')
    } finally {
      setLoading(false)
    }
  }, [subscriber, onComplete, onClose])

  const handleDelete = useCallback(async () => {
    if (!subscriber?.id) return
    setError('')
    setLoading(true)

    try {
      const result = await deleteSubscriber(subscriber.id)
      if (result.success) {
        onComplete?.()
        onClose?.()
      } else {
        setError(result.error || 'Erro ao apagar subscritor.')
      }
    } catch {
      setError('Erro ao apagar subscritor.')
    } finally {
      setLoading(false)
    }
  }, [subscriber, onComplete, onClose])

  if (!isOpen || !subscriber) return null

  const isAlreadyUnsubscribed = subscriber.status === 'unsubscribed'

  return (
    <div
      className="admin-modal-overlay"
      onClick={(e) => { if (e.target === e.currentTarget) onClose?.() }}
    >
      <div className="admin-modal" style={{ maxWidth: 480, padding: 32 }}>
        {/* Ícone */}
        <div style={{
          width: 64, height: 64, borderRadius: '50%',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          margin: '0 auto 20px',
          background: 'rgba(220, 38, 38, 0.1)',
          color: '#dc2626',
        }}>
          <Trash2 size={32} />
        </div>

        {/* Título */}
        <h3 style={{
          textAlign: 'center', fontSize: 20, fontWeight: 700,
          color: 'var(--admin-text)', marginBottom: 8,
          fontFamily: "'Fraunces', serif",
        }}>
          {isAlreadyUnsubscribed ? 'Eliminar Subscritor' : 'Remover Subscritor'}
        </h3>

        {/* Email */}
        <p style={{
          textAlign: 'center', fontSize: 14, color: 'var(--admin-text-muted)',
          marginBottom: 24, lineHeight: 1.6,
        }}>
          {isAlreadyUnsubscribed
            ? <>Pretende eliminar permanentemente <strong style={{ color: 'var(--admin-text)' }}>{escapeHtml(subscriber.email)}</strong>?</>
            : <>Pretende remover <strong style={{ color: 'var(--admin-text)' }}>{escapeHtml(subscriber.email)}</strong>?</>
          }
        </p>

        {/* Erro */}
        {error && (
          <div style={{
            padding: '10px 16px', marginBottom: 16, borderRadius: 8,
            background: 'rgba(220, 38, 38, 0.08)', color: '#dc2626',
            fontSize: 14, border: '1px solid rgba(220, 38, 38, 0.2)',
          }}>
            {error}
          </div>
        )}

        {/* Opções */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 16 }}>
          {!isAlreadyUnsubscribed && (
            <button
              type="button"
              className="admin-btn admin-btn-secondary"
              onClick={handleUnsubscribe}
              disabled={loading}
              style={{ width: '100%', justifyContent: 'center' }}
            >
              {loading ? 'A processar...' : 'Cancelar inscrição'}
            </button>
          )}
          <button
            type="button"
            className="admin-btn admin-btn-danger"
            onClick={handleDelete}
            disabled={loading}
            style={{ width: '100%', justifyContent: 'center' }}
          >
            {loading ? 'A processar...' : 'Apagar permanentemente'}
          </button>
        </div>

        {/* Fechar */}
        <div style={{ textAlign: 'center' }}>
          <button
            type="button"
            onClick={onClose}
            disabled={loading}
            style={{
              background: 'none', border: 'none', cursor: 'pointer',
              color: 'var(--admin-text-muted)', fontSize: 14,
            }}
          >
            Cancelar
          </button>
        </div>
      </div>
    </div>
  )
}
