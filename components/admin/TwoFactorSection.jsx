'use client'

import { useState, useCallback, useEffect } from 'react'
import { ShieldCheck, ShieldOff, Copy, Check } from 'lucide-react'
import ConfirmModal from '@/components/admin/ConfirmModal'
import { enrollMFA, verifyMFAEnrollment, unenrollMFA, listMFAFactors } from '@/lib/actions/settings'

/**
 * TwoFactorSection — Client Component
 *
 * Secção de 2FA (TOTP) para a página de definições.
 * - Exibe estado atual (ativado/desativado)
 * - Setup: mostra QR code + secret, pede código de verificação
 * - Disable: modal de confirmação destrutiva
 *
 * SEC-ATH-02: Todas as operações passam por Server Actions
 * que verificam sessão + admin_users.
 */

export default function TwoFactorSection() {
  const [mfaEnabled, setMfaEnabled] = useState(false)
  const [factorId, setFactorId] = useState(null)
  const [loading, setLoading] = useState(false)

  // Setup state
  const [setupMode, setSetupMode] = useState(false)
  const [qrCode, setQrCode] = useState('')
  const [secret, setSecret] = useState('')
  const [verifyCode, setVerifyCode] = useState('')
  const [setupError, setSetupError] = useState('')
  const [setupSuccess, setSetupSuccess] = useState('')
  const [copied, setCopied] = useState(false)

  // Disable state
  const [showDisableModal, setShowDisableModal] = useState(false)
  const [disableLoading, setDisableLoading] = useState(false)
  const [disableError, setDisableError] = useState('')

  // Carregar estado MFA ao montar
  useEffect(() => {
    const loadMFAStatus = async () => {
      try {
        const result = await listMFAFactors()
        if (result.success && result.factors?.length > 0) {
          const verified = result.factors.find(f => f.status === 'verified')
          if (verified) {
            setMfaEnabled(true)
            setFactorId(verified.id)
          }
        }
      } catch {
        // Erro silencioso — assume MFA desativado
      }
    }
    loadMFAStatus()
  }, [])

  // Iniciar setup 2FA
  const handleEnable = useCallback(async () => {
    setSetupError('')
    setSetupSuccess('')
    setLoading(true)

    try {
      const result = await enrollMFA()
      if (result.success) {
        setQrCode(result.qrCode)
        setSecret(result.secret)
        setFactorId(result.factorId)
        setSetupMode(true)
      } else {
        setSetupError(result.error || 'Erro ao iniciar setup 2FA.')
      }
    } catch {
      setSetupError('Erro ao iniciar setup 2FA.')
    } finally {
      setLoading(false)
    }
  }, [])

  // Verificar código e confirmar enrollment
  const handleVerify = useCallback(async () => {
    setSetupError('')
    setLoading(true)

    try {
      if (verifyCode.length !== 6) {
        setSetupError('O código deve ter 6 dígitos.')
        setLoading(false)
        return
      }

      const result = await verifyMFAEnrollment(factorId, verifyCode)
      if (result.success) {
        setMfaEnabled(true)
        setSetupMode(false)
        setSetupSuccess('Autenticação de dois fatores ativada com sucesso!')
        setVerifyCode('')
      } else {
        setSetupError(result.error || 'Código inválido ou expirado.')
      }
    } catch {
      setSetupError('Erro ao verificar código.')
    } finally {
      setLoading(false)
    }
  }, [factorId, verifyCode])

  // Desativar 2FA
  const handleDisable = useCallback(async () => {
    setDisableError('')
    setDisableLoading(true)

    try {
      const result = await unenrollMFA(factorId)
      if (result.success) {
        setMfaEnabled(false)
        setFactorId(null)
        setShowDisableModal(false)
        setSetupMode(false)
      } else {
        setDisableError(result.error || 'Erro ao desativar 2FA.')
      }
    } catch {
      setDisableError('Erro ao desativar 2FA.')
    } finally {
      setDisableLoading(false)
    }
  }, [factorId])

  // Copiar secret para clipboard
  const handleCopySecret = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(secret)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // Fallback para browsers antigos
    }
  }, [secret])

  return (
    <div className="settings-section">
      <h3 className="settings-section-title">
        <ShieldCheck size={20} />
        Autenticação de Dois Fatores
      </h3>

      {/* Status */}
      <div style={{
        display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20,
        padding: '12px 16px', borderRadius: 12,
        background: mfaEnabled ? 'rgba(10, 132, 79, 0.08)' : 'rgba(245, 158, 11, 0.08)',
        border: `1px solid ${mfaEnabled ? 'rgba(10, 132, 79, 0.2)' : 'rgba(245, 158, 11, 0.2)'}`,
      }}>
        <div style={{
          width: 8, height: 8, borderRadius: '50%',
          background: mfaEnabled ? '#0a844f' : '#f59e0b',
        }} />
        <span style={{ fontSize: 14, fontWeight: 500, color: 'var(--admin-text)' }}>
          2FA está <strong>{mfaEnabled ? 'ativado' : 'desativado'}</strong>
        </span>
      </div>

      {/* Sucesso */}
      {setupSuccess && (
        <div style={{
          padding: '10px 16px', marginBottom: 16, borderRadius: 8,
          background: 'rgba(10, 132, 79, 0.08)', color: '#0a844f',
          fontSize: 14, border: '1px solid rgba(10, 132, 79, 0.2)',
        }}>
          {setupSuccess}
        </div>
      )}

      {/* Erro */}
      {(setupError || disableError) && (
        <div style={{
          padding: '10px 16px', marginBottom: 16, borderRadius: 8,
          background: 'rgba(220, 38, 38, 0.08)', color: '#dc2626',
          fontSize: 14, border: '1px solid rgba(220, 38, 38, 0.2)',
        }}>
          {setupError || disableError}
        </div>
      )}

      {/* Setup mode — QR Code */}
      {setupMode && (
        <div style={{ marginBottom: 20 }}>
          <p style={{ fontSize: 14, color: 'var(--admin-text-muted)', marginBottom: 16, lineHeight: 1.6 }}>
            Escaneie o código QR abaixo com a sua aplicação autenticadora
            (Google Authenticator, Authy, Microsoft Authenticator, etc.)
            e introduza o código de 6 dígitos gerado.
          </p>

          {/* QR Code */}
          {qrCode && (
            <div style={{
              display: 'flex', justifyContent: 'center', marginBottom: 20,
              padding: 20, background: 'white', borderRadius: 12,
              border: '1px solid var(--admin-border)',
            }}>
              <img
                src={qrCode}
                alt="QR Code para 2FA"
                style={{ width: 200, height: 200, imageRendering: 'pixelated' }}
              />
            </div>
          )}

          {/* Secret manual */}
          {secret && (
            <div style={{ marginBottom: 16 }}>
              <p style={{ fontSize: 12, color: 'var(--admin-text-muted)', marginBottom: 8 }}>
                Ou introduza manualmente esta chave na sua app:
              </p>
              <div style={{
                display: 'flex', alignItems: 'center', gap: 8,
                padding: '8px 12px', borderRadius: 8,
                background: 'var(--admin-bg)', border: '1px solid var(--admin-border)',
              }}>
                <code style={{
                  flex: 1, fontSize: 14, fontFamily: "'JetBrains Mono', monospace",
                  letterSpacing: '0.05em', wordBreak: 'break-all', color: 'var(--admin-text)',
                }}>
                  {secret}
                </code>
                <button
                  type="button"
                  onClick={handleCopySecret}
                  style={{
                    background: 'none', border: 'none', cursor: 'pointer',
                    color: 'var(--admin-text-muted)', padding: 4,
                  }}
                  title="Copiar chave"
                >
                  {copied ? <Check size={16} color="#0a844f" /> : <Copy size={16} />}
                </button>
              </div>
            </div>
          )}

          {/* Input código */}
          <div className="settings-form-row" style={{ display: 'flex', gap: 12, alignItems: 'flex-end' }}>
            <div className="admin-form-group" style={{ flex: 1 }}>
              <label>Código de Verificação</label>
              <input
                type="text"
                inputMode="numeric"
                maxLength={6}
                value={verifyCode}
                onChange={(e) => setVerifyCode(e.target.value.replace(/\D/g, ''))}
                placeholder="000000"
                className="admin-input"
                style={{
                  fontFamily: "'JetBrains Mono', monospace",
                  letterSpacing: '0.3em', fontSize: 20, textAlign: 'center',
                }}
              />
            </div>
            <button
              type="button"
              className="admin-btn admin-btn-primary"
              onClick={handleVerify}
              disabled={loading || verifyCode.length !== 6}
              style={{ whiteSpace: 'nowrap' }}
            >
              {loading ? 'A verificar...' : 'Confirmar e Ativar'}
            </button>
          </div>

          <button
            type="button"
            className="admin-btn admin-btn-secondary"
            onClick={() => { setSetupMode(false); setSetupError(''); setVerifyCode('') }}
            style={{ marginTop: 8 }}
          >
            Cancelar
          </button>
        </div>
      )}

      {/* Botões de ação */}
      {!setupMode && (
        <div style={{ display: 'flex', gap: 12 }}>
          {!mfaEnabled ? (
            <button
              type="button"
              className="admin-btn admin-btn-primary"
              onClick={handleEnable}
              disabled={loading}
            >
              <ShieldCheck size={16} />
              {loading ? 'A preparar...' : 'Ativar 2FA'}
            </button>
          ) : (
            <button
              type="button"
              className="admin-btn admin-btn-danger"
              onClick={() => setShowDisableModal(true)}
            >
              <ShieldOff size={16} />
              Desativar 2FA
            </button>
          )}
        </div>
      )}

      {/* Modal de confirmação — desativar 2FA */}
      <ConfirmModal
        isOpen={showDisableModal}
        onClose={() => { setShowDisableModal(false); setDisableError('') }}
        onConfirm={handleDisable}
        title="Desativar 2FA?"
        message="Ao desativar a autenticação de dois fatores, a sua conta ficará protegida apenas pela password. Recomendamos manter o 2FA ativado."
        confirmLabel="Desativar"
        variant="danger"
        loading={disableLoading}
      />
    </div>
  )
}
