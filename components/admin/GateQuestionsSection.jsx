'use client'

import { useState, useCallback, useEffect } from 'react'
import { KeyRound, Edit3, Save, X, ShieldCheck, ShieldOff } from 'lucide-react'
import { getGateQuestionsForEdit, saveGateQuestions, getGateQuestionsEnabled, toggleGateQuestions } from '@/lib/actions/settings'

/**
 * GateQuestionsSection — Client Component
 *
 * Secção de Perguntas de Segurança (Gate) para a página de definições.
 * - Carrega perguntas atuais via RPC
 * - Modo edição: alterar perguntas e respostas
 * - Guarda via Server Action com SHA256 no servidor
 *
 * SEC-ATH-02: Todas as operações passam por Server Actions
 * que verificam sessão + admin_users.
 */

export default function GateQuestionsSection() {
  const [questions, setQuestions] = useState([])
  const [loading, setLoading] = useState(true)
  const [enabled, setEnabled] = useState(true)
  const [toggling, setToggling] = useState(false)

  // Edição
  const [editMode, setEditMode] = useState(false)
  const [q1, setQ1] = useState('')
  const [a1, setA1] = useState('')
  const [q2, setQ2] = useState('')
  const [a2, setA2] = useState('')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  // Carregar perguntas e estado ao montar
  useEffect(() => {
    const loadQuestions = async () => {
      setLoading(true)
      try {
        const [questionsResult, enabledResult] = await Promise.all([
          getGateQuestionsForEdit(),
          getGateQuestionsEnabled(),
        ])

        if (questionsResult.success && questionsResult.questions) {
          setQuestions(questionsResult.questions)
          if (questionsResult.questions.length > 0) {
            setQ1(questionsResult.questions[0]?.question || '')
            setQ2(questionsResult.questions[1]?.question || '')
          }
        }

        if (enabledResult.success) {
          setEnabled(enabledResult.enabled)
        }
      } catch {
        // Erro silencioso
      } finally {
        setLoading(false)
      }
    }
    loadQuestions()
  }, [])

  // Toggle perguntas de segurança
  const handleToggle = useCallback(async () => {
    setToggling(true)
    setError('')
    setSuccess('')
    try {
      const newState = !enabled
      const result = await toggleGateQuestions(newState)
      if (result.success) {
        setEnabled(newState)
        setSuccess(newState
          ? 'Perguntas de segurança ativadas.'
          : 'Perguntas de segurança desativadas.')
      } else {
        setError(result.error || 'Erro ao atualizar.')
      }
    } catch {
      setError('Erro ao atualizar.')
    } finally {
      setToggling(false)
    }
  }, [enabled])

  // Entrar em modo edição
  const handleEdit = useCallback(() => {
    if (questions.length > 0) {
      setQ1(questions[0]?.question || '')
      setQ2(questions[1]?.question || '')
    }
    setA1('')
    setA2('')
    setError('')
    setSuccess('')
    setEditMode(true)
  }, [questions])

  // Cancelar edição
  const handleCancel = useCallback(() => {
    setEditMode(false)
    setError('')
    setSuccess('')
  }, [])

  // Guardar perguntas
  const handleSave = useCallback(async () => {
    setError('')
    setSuccess('')
    setSaving(true)

    try {
      if (!q1.trim() || !a1.trim() || !q2.trim() || !a2.trim()) {
        setError('Todas as perguntas e respostas são obrigatórias.')
        setSaving(false)
        return
      }

      const result = await saveGateQuestions(q1, a1, q2, a2)
      if (result.success) {
        setSuccess('Perguntas de segurança atualizadas com sucesso!')
        setEditMode(false)
        // Recarregar perguntas
        const updated = await getGateQuestionsForEdit()
        if (updated.success) {
          setQuestions(updated.questions || [])
        }
      } else {
        setError(result.error || 'Erro ao guardar perguntas.')
      }
    } catch {
      setError('Erro ao guardar perguntas.')
    } finally {
      setSaving(false)
    }
  }, [q1, a1, q2, a2])

  if (loading) {
    return (
      <div className="settings-section">
        <h3 className="settings-section-title">
          <KeyRound size={20} />
          Perguntas de Segurança
        </h3>
        <p style={{ color: 'var(--admin-text-muted)', fontSize: 14 }}>A carregar...</p>
      </div>
    )
  }

  return (
    <div className="settings-section">
      <h3 className="settings-section-title">
        <KeyRound size={20} />
        Perguntas de Segurança
      </h3>

      <p style={{ color: 'var(--admin-text-muted)', fontSize: 13, marginBottom: 16, lineHeight: 1.6 }}>
        Estas perguntas são mostradas antes do login como camada extra de segurança.
        As respostas são guardadas com hash SHA256 no servidor — nunca são armazenadas em texto simples.
      </p>

      {/* Toggle ativar/desativar */}
      <div style={{
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '14px 16px', marginBottom: 16, borderRadius: 8,
        background: enabled ? 'rgba(10, 132, 79, 0.06)' : 'rgba(220, 38, 38, 0.06)',
        border: `1px solid ${enabled ? 'rgba(10, 132, 79, 0.15)' : 'rgba(220, 38, 38, 0.15)'}`,
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          {enabled ? <ShieldCheck size={20} color="#0a844f" /> : <ShieldOff size={20} color="#dc2626" />}
          <div>
            <div style={{ fontSize: 14, fontWeight: 600, color: 'var(--admin-text)' }}>
              {enabled ? 'Perguntas ativadas' : 'Perguntas desativadas'}
            </div>
            <div style={{ fontSize: 12, color: 'var(--admin-text-muted)', marginTop: 2 }}>
              {enabled
                ? 'Os administradores devem responder às perguntas antes de fazer login.'
                : 'O login não requer respostas de segurança.'}
            </div>
          </div>
        </div>
        <button
          type="button"
          onClick={handleToggle}
          disabled={toggling}
          style={{
            position: 'relative', width: 48, height: 26, borderRadius: 13,
            border: 'none', cursor: toggling ? 'wait' : 'pointer',
            background: enabled ? '#0a844f' : '#ccc',
            transition: 'background 0.2s',
          }}
        >
          <span style={{
            position: 'absolute', top: 3, left: enabled ? 25 : 3,
            width: 20, height: 20, borderRadius: '50%', background: '#fff',
            transition: 'left 0.2s', boxShadow: '0 1px 3px rgba(0,0,0,0.2)',
          }} />
        </button>
      </div>

      {/* Sucesso */}
      {success && (
        <div style={{
          padding: '10px 16px', marginBottom: 16, borderRadius: 8,
          background: 'rgba(10, 132, 79, 0.08)', color: '#0a844f',
          fontSize: 14, border: '1px solid rgba(10, 132, 79, 0.2)',
        }}>
          {success}
        </div>
      )}

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

      {/* Modo visualização */}
      {!editMode && (
        <>
          {questions.length > 0 ? (
            <div style={{ marginBottom: 16 }}>
              {questions.map((q, i) => (
                <div key={q.id || i} style={{
                  padding: '12px 16px', marginBottom: 8, borderRadius: 8,
                  background: 'var(--admin-bg)', border: '1px solid var(--admin-border)',
                }}>
                  <div style={{ fontSize: 12, color: 'var(--admin-text-muted)', marginBottom: 4 }}>
                    Pergunta {i + 1}
                  </div>
                  <div style={{ fontSize: 14, color: 'var(--admin-text)', fontWeight: 500 }}>
                    {q.question}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p style={{ color: 'var(--admin-text-muted)', fontSize: 14, marginBottom: 16 }}>
              Nenhuma pergunta de segurança configurada.
            </p>
          )}

          <button type="button" className="admin-btn admin-btn-secondary" onClick={handleEdit}>
            <Edit3 size={16} />
            {questions.length > 0 ? 'Editar Perguntas' : 'Configurar Perguntas'}
          </button>
        </>
      )}

      {/* Modo edição */}
      {editMode && (
        <div>
          {/* Pergunta 1 */}
          <div className="admin-form-group" style={{ marginBottom: 16 }}>
            <label>Pergunta 1</label>
            <input
              type="text"
              value={q1}
              onChange={(e) => setQ1(e.target.value)}
              className="admin-input"
              placeholder="Ex: Qual o nome do seu primeiro animal de estimação?"
            />
          </div>
          <div className="admin-form-group" style={{ marginBottom: 20 }}>
            <label>Resposta 1</label>
            <input
              type="password"
              value={a1}
              onChange={(e) => setA1(e.target.value)}
              className="admin-input"
              placeholder="A sua resposta (será guardada com hash SHA256)"
              autoComplete="off"
            />
          </div>

          {/* Pergunta 2 */}
          <div className="admin-form-group" style={{ marginBottom: 16 }}>
            <label>Pergunta 2</label>
            <input
              type="text"
              value={q2}
              onChange={(e) => setQ2(e.target.value)}
              className="admin-input"
              placeholder="Ex: Qual a cidade onde nasceu?"
            />
          </div>
          <div className="admin-form-group" style={{ marginBottom: 20 }}>
            <label>Resposta 2</label>
            <input
              type="password"
              value={a2}
              onChange={(e) => setA2(e.target.value)}
              className="admin-input"
              placeholder="A sua resposta (será guardada com hash SHA256)"
              autoComplete="off"
            />
          </div>

          <div style={{ display: 'flex', gap: 12, marginTop: 8 }}>
            <button
              type="button"
              className="admin-btn admin-btn-primary"
              onClick={handleSave}
              disabled={saving}
            >
              <Save size={16} />
              {saving ? 'A guardar...' : 'Guardar Alterações'}
            </button>
            <button
              type="button"
              className="admin-btn admin-btn-secondary"
              onClick={handleCancel}
              disabled={saving}
            >
              <X size={16} />
              Cancelar
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
