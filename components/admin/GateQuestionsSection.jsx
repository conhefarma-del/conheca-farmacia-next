'use client'

import { useState, useCallback, useEffect } from 'react'
import { KeyRound, Edit3, Save, X } from 'lucide-react'
import { getGateQuestionsForEdit, saveGateQuestions } from '@/lib/actions/settings'

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

  // Edição
  const [editMode, setEditMode] = useState(false)
  const [q1, setQ1] = useState('')
  const [a1, setA1] = useState('')
  const [q2, setQ2] = useState('')
  const [a2, setA2] = useState('')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  // Carregar perguntas ao montar
  useEffect(() => {
    const loadQuestions = async () => {
      setLoading(true)
      try {
        const result = await getGateQuestionsForEdit()
        if (result.success && result.questions) {
          setQuestions(result.questions)
          if (result.questions.length > 0) {
            setQ1(result.questions[0]?.question || '')
            setQ2(result.questions[1]?.question || '')
          }
        }
      } catch {
        // Erro silencioso
      } finally {
        setLoading(false)
      }
    }
    loadQuestions()
  }, [])

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
