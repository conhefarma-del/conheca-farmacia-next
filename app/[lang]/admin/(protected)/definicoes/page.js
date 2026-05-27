'use client'

import { useState, useCallback, useEffect } from 'react'
import { User, Lock, Edit3, Save, X } from 'lucide-react'
import { getAdminProfile, updateProfile, changePassword } from '@/lib/actions/settings'
import TwoFactorSection from '@/components/admin/TwoFactorSection'
import GateQuestionsSection from '@/components/admin/GateQuestionsSection'

/**
 * Definições Page — Client Component
 *
 * 4 secções modulares:
 * 1. Perfil (nome, email, email de recuperação)
 * 2. Password (alterar password)
 * 3. 2FA (TwoFactorSection)
 * 4. Perguntas de Segurança (GateQuestionsSection)
 *
 * Usa classes CSS do admin.css (`.settings-section`, `.settings-form-row`, etc.)
 */

export default function DefinicoesPage() {
  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Definições</h1>
        <p className="admin-page-subtitle">Gerir perfil, segurança e preferências</p>
      </div>

      <ProfileSection />
      <PasswordSection />
      <TwoFactorSection />
      <GateQuestionsSection />
    </>
  )
}

// ============================================================
//  Secção 1: Perfil
// ============================================================

function ProfileSection() {
  const [loading, setLoading] = useState(true)
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [recoveryEmail, setRecoveryEmail] = useState('')
  const [editMode, setEditMode] = useState(false)
  const [editName, setEditName] = useState('')
  const [editRecoveryEmail, setEditRecoveryEmail] = useState('')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  // Carregar perfil ao montar
  useEffect(() => {
    const loadProfile = async () => {
      try {
        const profile = await getAdminProfile()
        if (profile) {
          setName(profile.name || '')
          setEmail(profile.email || '')
          setRecoveryEmail(profile.recovery_email || '')
        }
      } catch {
        // Erro silencioso
      } finally {
        setLoading(false)
      }
    }
    loadProfile()
  }, [])

  // Entrar em modo edição
  const handleEdit = useCallback(() => {
    setEditName(name)
    setEditRecoveryEmail(recoveryEmail)
    setError('')
    setSuccess('')
    setEditMode(true)
  }, [name, recoveryEmail])

  // Cancelar
  const handleCancel = useCallback(() => {
    setEditMode(false)
    setError('')
    setSuccess('')
  }, [])

  // Guardar
  const handleSave = useCallback(async () => {
    setError('')
    setSuccess('')
    setSaving(true)

    try {
      const result = await updateProfile(editName, editRecoveryEmail)
      if (result.success) {
        setName(editName)
        setRecoveryEmail(editRecoveryEmail)
        setEditMode(false)
        setSuccess('Perfil atualizado com sucesso!')
      } else {
        setError(result.error || 'Erro ao atualizar perfil.')
      }
    } catch {
      setError('Erro ao atualizar perfil.')
    } finally {
      setSaving(false)
    }
  }, [editName, editRecoveryEmail])

  if (loading) {
    return (
      <div className="settings-section">
        <h3 className="settings-section-title"><User size={20} /> Perfil</h3>
        <p style={{ color: 'var(--admin-text-muted)', fontSize: 14 }}>A carregar...</p>
      </div>
    )
  }

  return (
    <div className="settings-section">
      <h3 className="settings-section-title">
        <User size={20} /> Perfil
      </h3>
      <p style={{ color: 'var(--admin-text-muted)', fontSize: 13, marginBottom: 20, lineHeight: 1.6 }}>
        Gerir os seus dados pessoais. O email é gerido pelo sistema de autenticação e não pode ser alterado aqui.
      </p>

      {success && (
        <div style={{
          padding: '10px 16px', marginBottom: 16, borderRadius: 8,
          background: 'rgba(10, 132, 79, 0.08)', color: '#0a844f',
          fontSize: 14, border: '1px solid rgba(10, 132, 79, 0.2)',
        }}>{success}</div>
      )}

      {error && (
        <div style={{
          padding: '10px 16px', marginBottom: 16, borderRadius: 8,
          background: 'rgba(220, 38, 38, 0.08)', color: '#dc2626',
          fontSize: 14, border: '1px solid rgba(220, 38, 38, 0.2)',
        }}>{error}</div>
      )}

      {/* Nome + Email */}
      <div className="settings-form-row" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
        <div className="admin-form-group">
          <label>Nome</label>
          <div style={{ position: 'relative' }}>
            <input
              type="text"
              value={editMode ? editName : name}
              onChange={(e) => setEditName(e.target.value)}
              disabled={!editMode}
              className="admin-input"
              placeholder="O seu nome"
              autoComplete="name"
              style={{ paddingRight: editMode ? 12 : 40 }}
            />
            {!editMode && (
              <button
                type="button"
                onClick={handleEdit}
                style={{
                  position: 'absolute', right: 8, top: '50%', transform: 'translateY(-50%)',
                  background: 'none', border: 'none', cursor: 'pointer',
                  color: 'var(--admin-text-muted)', padding: 4,
                }}
                title="Editar nome"
              >
                <Edit3 size={16} />
              </button>
            )}
          </div>
        </div>
        <div className="admin-form-group">
          <label>Email</label>
          <input
            type="email"
            value={email}
            disabled
            className="admin-input"
            title="O email não pode ser alterado"
          />
          <span className="admin-hint" style={{ color: 'var(--admin-text-muted)', fontSize: 12 }}>
            O email é gerido pelo sistema de autenticação.
          </span>
        </div>
      </div>

      {/* Email de recuperação */}
      <div className="admin-form-group" style={{ marginBottom: 16 }}>
        <label>Email de Recuperação</label>
        <div style={{ position: 'relative' }}>
          <input
            type="email"
            value={editMode ? editRecoveryEmail : recoveryEmail}
            onChange={(e) => setEditRecoveryEmail(e.target.value)}
            disabled={!editMode}
            className="admin-input"
            placeholder="email-recuperacao@exemplo.com"
            style={{ paddingRight: editMode ? 12 : 40 }}
          />
          {!editMode && (
            <button
              type="button"
              onClick={handleEdit}
              style={{
                position: 'absolute', right: 8, top: '50%', transform: 'translateY(-50%)',
                background: 'none', border: 'none', cursor: 'pointer',
                color: 'var(--admin-text-muted)', padding: 4,
              }}
              title="Editar email de recuperação"
            >
              <Edit3 size={16} />
            </button>
          )}
        </div>
        <span className="admin-hint" style={{ color: 'var(--admin-text-muted)', fontSize: 12 }}>
          Email alternativo para recuperação de conta.
        </span>
      </div>

      {/* Ações */}
      {editMode && (
        <div style={{ display: 'flex', gap: 12, marginTop: 8 }}>
          <button type="button" className="admin-btn admin-btn-primary" onClick={handleSave} disabled={saving}>
            <Save size={16} />
            {saving ? 'A guardar...' : 'Guardar Alterações'}
          </button>
          <button type="button" className="admin-btn admin-btn-secondary" onClick={handleCancel} disabled={saving}>
            <X size={16} /> Cancelar
          </button>
        </div>
      )}
    </div>
  )
}

// ============================================================
//  Secção 2: Alterar Password
// ============================================================

function PasswordSection() {
  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const handleSubmit = useCallback(async (e) => {
    e.preventDefault()
    setError('')
    setSuccess('')

    if (newPassword !== confirmPassword) {
      setError('As passwords não coincidem.')
      return
    }

    if (newPassword.length < 8) {
      setError('A nova password deve ter pelo menos 8 caracteres.')
      return
    }

    setSaving(true)

    try {
      const result = await changePassword(currentPassword, newPassword)
      if (result.success) {
        setSuccess('Password alterada com sucesso!')
        setCurrentPassword('')
        setNewPassword('')
        setConfirmPassword('')
      } else {
        setError(result.error || 'Erro ao alterar password.')
      }
    } catch {
      setError('Erro ao alterar password.')
    } finally {
      setSaving(false)
    }
  }, [currentPassword, newPassword, confirmPassword])

  return (
    <div className="settings-section">
      <h3 className="settings-section-title">
        <Lock size={20} /> Alterar Password
      </h3>
      <p style={{ color: 'var(--admin-text-muted)', fontSize: 13, marginBottom: 20, lineHeight: 1.6 }}>
        Altere a sua password de acesso ao painel. A password deve ter pelo menos 8 caracteres.
      </p>

      <form onSubmit={handleSubmit}>
        <div className="admin-form-group" style={{ marginBottom: 16 }}>
          <label>Senha Atual</label>
          <input
            type="password"
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
            required
            className="admin-input"
            placeholder="••••••••"
            autoComplete="current-password"
          />
        </div>
        <div className="admin-form-group" style={{ marginBottom: 16 }}>
          <label>Nova Senha</label>
          <input
            type="password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
            required
            className="admin-input"
            placeholder="••••••••"
            minLength={8}
            autoComplete="new-password"
          />
        </div>
        <div className="admin-form-group" style={{ marginBottom: 16 }}>
          <label>Confirmar Nova Senha</label>
          <input
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            required
            className="admin-input"
            placeholder="••••••••"
            minLength={8}
            autoComplete="new-password"
          />
        </div>

        {success && (
          <div style={{
            padding: '10px 16px', marginBottom: 16, borderRadius: 8,
            background: 'rgba(10, 132, 79, 0.08)', color: '#0a844f',
            fontSize: 14, border: '1px solid rgba(10, 132, 79, 0.2)',
          }}>{success}</div>
        )}

        {error && (
          <div style={{
            padding: '10px 16px', marginBottom: 16, borderRadius: 8,
            background: 'rgba(220, 38, 38, 0.08)', color: '#dc2626',
            fontSize: 14, border: '1px solid rgba(220, 38, 38, 0.2)',
          }}>{error}</div>
        )}

        <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
          <Lock size={16} />
          {saving ? 'A alterar...' : 'Alterar Password'}
        </button>
      </form>
    </div>
  )
}
