'use client'

import { useEffect, useCallback } from 'react'
import { AlertTriangle, X } from 'lucide-react'

/**
 * ConfirmModal — Client Component genérico
 *
 * Modal de confirmação para ações destrutivas.
 * Previne apagamentos acidentais.
 *
 * Props:
 *   - isOpen: boolean
 *   - onClose: () => void
 *   - onConfirm: () => void
 *   - title: string
 *   - message: string
 *   - confirmLabel: string (default: "Confirmar")
 *   - variant: 'danger' | 'warning' (default: 'danger')
 *   - loading: boolean
 */

export default function ConfirmModal({
  isOpen,
  onClose,
  onConfirm,
  title = 'Confirmar ação',
  message = 'Tem certeza que deseja continuar?',
  confirmLabel = 'Confirmar',
  variant = 'danger',
  loading = false,
}) {
  // Fechar com Escape
  useEffect(() => {
    if (!isOpen) return
    const handleEscape = (e) => {
      if (e.key === 'Escape') onClose?.()
    }
    document.addEventListener('keydown', handleEscape)
    return () => document.removeEventListener('keydown', handleEscape)
  }, [isOpen, onClose])

  const handleConfirm = useCallback(() => {
    if (!loading) onConfirm?.()
  }, [onConfirm, loading])

  if (!isOpen) return null

  return (
    <div
      className="admin-modal-overlay"
      onClick={(e) => { if (e.target === e.currentTarget) onClose?.() }}
    >
      <div className="admin-modal" style={{ maxWidth: 440, padding: 32 }}>
        {/* Ícone */}
        <div className={`admin-modal-icon ${variant}`} style={{
          width: 64, height: 64, borderRadius: '50%',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          margin: '0 auto 20px',
          background: variant === 'danger' ? 'rgba(220, 38, 38, 0.1)' : 'rgba(245, 158, 11, 0.1)',
          color: variant === 'danger' ? '#dc2626' : '#f59e0b',
        }}>
          <AlertTriangle size={32} />
        </div>

        {/* Título */}
        <h3 style={{
          textAlign: 'center', fontSize: 20, fontWeight: 700,
          color: 'var(--admin-text)', marginBottom: 12,
          fontFamily: "'Fraunces', serif",
        }}>
          {title}
        </h3>

        {/* Mensagem */}
        <p style={{
          textAlign: 'center', fontSize: 14, color: 'var(--admin-text-muted)',
          marginBottom: 28, lineHeight: 1.6,
        }}>
          {message}
        </p>

        {/* Botões */}
        <div style={{ display: 'flex', gap: 12, justifyContent: 'center' }}>
          <button
            type="button"
            className="admin-btn admin-btn-secondary"
            onClick={onClose}
            disabled={loading}
            style={{ minWidth: 100 }}
          >
            Cancelar
          </button>
          <button
            type="button"
            className={`admin-btn admin-btn-${variant}`}
            onClick={handleConfirm}
            disabled={loading}
            style={{ minWidth: 100 }}
          >
            {loading ? 'A processar...' : confirmLabel}
          </button>
        </div>
      </div>
    </div>
  )
}
