'use client'

import { useState, useCallback, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Save, Trash2, RotateCcw, CheckCircle, XCircle, Edit3 } from 'lucide-react'
import { createFAQTab, archiveFAQTab, restoreFAQTab, getFAQQuestions, createFAQQuestion, updateFAQQuestion, archiveFAQQuestion, restoreFAQQuestion } from '@/lib/actions/legalContent'

export default function FAQAdminPage({ lang, initialTabs, currentUserRole }) {
  const router = useRouter()
  const [tabs, setTabs] = useState(initialTabs || [])
  const [selectedTabId, setSelectedTabId] = useState(tabs[0]?.id || null)
  const [questions, setQuestions] = useState([])
  const [loadingQuestions, setLoadingQuestions] = useState(false)
  const [message, setMessage] = useState(null)

  // Slide panel state
  const [panelRendered, setPanelRendered] = useState(false)
  const [panelOpen, setPanelOpen] = useState(false)
  const [panelMode, setPanelMode] = useState('create') // 'create' | 'edit'
  const [editingQuestion, setEditingQuestion] = useState(null)
  const [saving, setSaving] = useState(false)

  // Form state
  const [formQuestionPt, setFormQuestionPt] = useState('')
  const [formQuestionEn, setFormQuestionEn] = useState('')
  const [formAnswerPt, setFormAnswerPt] = useState('')
  const [formAnswerEn, setFormAnswerEn] = useState('')
  const [formPending, setFormPending] = useState(true)
  const [formSortOrder, setFormSortOrder] = useState(0)
  const [formError, setFormError] = useState(null)

  // Load questions when tab changes
  const handleSelectTab = useCallback(async (tabId) => {
    setSelectedTabId(tabId)
    setLoadingQuestions(true)
    const qs = await getFAQQuestions(tabId)
    setQuestions(qs)
    setLoadingQuestions(false)
  }, [])

  // --- Slide panel: Open create ---
  const openCreatePanel = useCallback(() => {
    setPanelMode('create')
    setEditingQuestion(null)
    setFormQuestionPt('')
    setFormQuestionEn('')
    setFormAnswerPt('')
    setFormAnswerEn('')
    setFormPending(true)
    setFormSortOrder(questions.length + 1)
    setFormError(null)
    setPanelRendered(true)
    requestAnimationFrame(() => setPanelOpen(true))
  }, [questions])

  // --- Slide panel: Open edit ---
  const openEditPanel = useCallback((question) => {
    setPanelMode('edit')
    setEditingQuestion(question)
    setFormQuestionPt(question.question_pt || '')
    setFormQuestionEn(question.question_en || '')
    setFormAnswerPt(question.answer_pt || '')
    setFormAnswerEn(question.answer_en || '')
    setFormPending(question.pending !== false)
    setFormSortOrder(question.sort_order || 0)
    setFormError(null)
    setPanelRendered(true)
    requestAnimationFrame(() => setPanelOpen(true))
  }, [])

  // --- Slide panel: Close ---
  const closePanel = useCallback(() => {
    setPanelOpen(false)
    setTimeout(() => {
      setPanelRendered(false)
      setEditingQuestion(null)
    }, 250)
  }, [])

  // Escape key handler
  useEffect(() => {
    const onKey = (e) => { if (e.key === 'Escape' && panelOpen) closePanel() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [panelOpen, closePanel])

  // --- Slide panel: Save ---
  const handleSaveQuestion = useCallback(async () => {
    if (!formQuestionPt.trim()) {
      setFormError('A pergunta em PT é obrigatória.')
      return
    }
    if (!formQuestionEn.trim()) {
      setFormError('A pergunta em EN é obrigatória.')
      return
    }

    setSaving(true)
    setFormError(null)

    try {
      if (panelMode === 'create') {
        const result = await createFAQQuestion({
          tab_id: selectedTabId,
          question_pt: formQuestionPt,
          question_en: formQuestionEn,
          answer_pt: formAnswerPt,
          answer_en: formAnswerEn,
          pending: formPending,
          sort_order: formSortOrder,
        })
        if (result.success) {
          setMessage('Pergunta criada com sucesso!')
          closePanel()
          handleSelectTab(selectedTabId)
        } else {
          setFormError(result.error || 'Erro ao criar pergunta.')
        }
      } else {
        const result = await updateFAQQuestion(editingQuestion.id, {
          question_pt: formQuestionPt,
          question_en: formQuestionEn,
          answer_pt: formAnswerPt,
          answer_en: formAnswerEn,
          pending: formPending,
          sort_order: formSortOrder,
        })
        if (result.success) {
          setMessage('Pergunta atualizada com sucesso!')
          closePanel()
          handleSelectTab(selectedTabId)
        } else {
          setFormError(result.error || 'Erro ao atualizar pergunta.')
        }
      }
    } catch (err) {
      setFormError('Erro inesperado: ' + (err.message || 'desconhecido'))
    } finally {
      setSaving(false)
    }
  }, [formQuestionPt, formQuestionEn, formAnswerPt, formAnswerEn, formPending, formSortOrder, panelMode, selectedTabId, editingQuestion, closePanel, handleSelectTab])

  // Create a new tab
  const handleCreateTab = useCallback(async () => {
    const slug = prompt('Slug do separador (ex: novo-tema):')
    if (!slug) return
    const labelPt = prompt('Nome PT:')
    if (!labelPt) return
    const labelEn = prompt('Nome EN:')
    if (!labelEn) return

    const result = await createFAQTab({ slug, label_pt: labelPt, label_en: labelEn, sort_order: tabs.length + 1 })
    if (result.success) {
      setMessage('Separador criado!')
      router.refresh()
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [tabs, router])

  // Archive/restore tab
  const handleArchiveTab = useCallback(async (tabId) => {
    const result = await archiveFAQTab(tabId)
    if (result.success) {
      setMessage('Separador arquivado.')
      router.refresh()
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [router])

  const handleRestoreTab = useCallback(async (tabId) => {
    const result = await restoreFAQTab(tabId)
    if (result.success) {
      setMessage('Separador restaurado.')
      router.refresh()
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [router])

  // Toggle pending status
  const handleTogglePending = useCallback(async (question) => {
    const result = await updateFAQQuestion(question.id, {
      question_pt: question.question_pt,
      question_en: question.question_en,
      answer_pt: question.answer_pt,
      answer_en: question.answer_en,
      pending: !question.pending,
      sort_order: question.sort_order,
    })
    if (result.success) {
      handleSelectTab(selectedTabId)
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [selectedTabId, handleSelectTab])

  // Archive question
  const handleArchiveQuestion = useCallback(async (questionId) => {
    const result = await archiveFAQQuestion(questionId)
    if (result.success) {
      handleSelectTab(selectedTabId)
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [selectedTabId, handleSelectTab])

  return (
    <div className="admin-faq">
      <div className="admin-page-header">
        <h1>Gerir FAQ</h1>
        <p className="admin-page-subtitle">Gerir separadores e perguntas frequentes.</p>
      </div>

      {message && (
        <div className={`admin-message ${message.startsWith('Erro') ? 'admin-error-message' : 'admin-success-message'}`}>
          {message}
          <button onClick={() => setMessage(null)} style={{ marginLeft: 12, background: 'none', border: 'none', cursor: 'pointer' }}>×</button>
        </div>
      )}

      <div className="admin-card" style={{ marginBottom: 24 }}>
        <div className="admin-card-header">
          <h2>Separadores</h2>
          <button className="admin-btn admin-btn-primary" onClick={handleCreateTab}>
            <Plus size={16} /> Novo Separador
          </button>
        </div>
        <div className="admin-card-body">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Slug</th>
                <th>PT</th>
                <th>EN</th>
                <th>Ordem</th>
                <th>Arquivado</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {tabs.length === 0 ? (
                <tr><td colSpan={6} className="admin-table-empty">Nenhum separador encontrado.</td></tr>
              ) : tabs.map((tab) => (
                <tr key={tab.id} className={tab.is_archived ? 'admin-table-row-archived' : ''}>
                  <td>{tab.slug}</td>
                  <td>{tab.label_pt}</td>
                  <td>{tab.label_en}</td>
                  <td>{tab.sort_order}</td>
                  <td>{tab.is_archived ? `Sim (${tab.archived_at ? new Date(tab.archived_at).toLocaleDateString() : ''})` : 'Não'}</td>
                  <td>
                    <div className="admin-table-actions">
                      <button
                        className="admin-btn admin-btn-sm"
                        onClick={() => handleSelectTab(tab.id)}
                        title="Ver perguntas"
                      >
                        <CheckCircle size={14} /> Perguntas
                      </button>
                      {currentUserRole === 'superadmin' && tab.is_archived && (
                        <button
                          className="admin-btn admin-btn-sm"
                          onClick={() => handleRestoreTab(tab.id)}
                          title="Restaurar"
                        >
                          <RotateCcw size={14} /> Restaurar
                        </button>
                      )}
                      {!tab.is_archived && (
                        <button
                          className="admin-btn admin-btn-sm admin-btn-danger"
                          onClick={() => handleArchiveTab(tab.id)}
                          title="Arquivar"
                        >
                          <Trash2 size={14} /> Arquivar
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="admin-card">
        <div className="admin-card-header">
          <h2>Perguntas {selectedTabId ? `(${tabs.find(t => t.id === selectedTabId)?.label_pt || ''})` : ''}</h2>
          {selectedTabId && (
            <button className="admin-btn admin-btn-primary" onClick={openCreatePanel}>
              <Plus size={16} /> Nova Pergunta
            </button>
          )}
        </div>
        <div className="admin-card-body">
          {!selectedTabId ? (
            <p className="admin-table-empty">Selecione um separador para ver as perguntas.</p>
          ) : loadingQuestions ? (
            <p className="admin-table-empty">A carregar perguntas...</p>
          ) : questions.length === 0 ? (
            <p className="admin-table-empty">Nenhuma pergunta neste separador.</p>
          ) : (
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Ordem</th>
                  <th>Pergunta PT</th>
                  <th>Resposta PT</th>
                  <th>Estado</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {questions.map((q) => (
                  <tr key={q.id} className={q.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{q.sort_order}</td>
                    <td style={{ maxWidth: 220, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {q.question_pt}
                    </td>
                    <td style={{ maxWidth: 220, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                      {q.answer_pt || <span style={{ color: '#9ca3af', fontStyle: 'italic' }}>vazio</span>}
                    </td>
                    <td>
                      <span className={`admin-badge ${q.pending ? 'admin-badge-warning' : 'admin-badge-success'}`}>
                        {q.pending ? 'Pendente' : 'Publicado'}
                      </span>
                    </td>
                    <td>
                      <div className="admin-table-actions">
                        <button
                          className="admin-btn admin-btn-sm"
                          onClick={() => openEditPanel(q)}
                          title="Editar pergunta"
                        >
                          <Edit3 size={14} /> Editar
                        </button>
                        <button
                          className="admin-btn admin-btn-sm"
                          onClick={() => handleTogglePending(q)}
                          title={q.pending ? 'Marcar como publicado' : 'Marcar como pendente'}
                        >
                          {q.pending ? <CheckCircle size={14} /> : <XCircle size={14} />}
                          {q.pending ? 'Publicar' : 'Pendente'}
                        </button>
                        {currentUserRole === 'superadmin' && q.is_archived && (
                          <button
                            className="admin-btn admin-btn-sm"
                            onClick={async () => {
                              await restoreFAQQuestion(q.id)
                              handleSelectTab(selectedTabId)
                            }}
                          >
                            <RotateCcw size={14} /> Restaurar
                          </button>
                        )}
                        {!q.is_archived && (
                          <button
                            className="admin-btn admin-btn-sm admin-btn-danger"
                            onClick={() => handleArchiveQuestion(q.id)}
                          >
                            <Trash2 size={14} /> Arquivar
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>

      {/* ===== Slide Panel: Edit/Create Question ===== */}
      {panelRendered && (
        <>
          {/* Overlay */}
          <div
            onClick={closePanel}
            style={{
              position: 'fixed',
              inset: 0,
              zIndex: 999,
              background: panelOpen ? 'rgba(0, 42, 50, 0.45)' : 'rgba(0, 42, 50, 0)',
              backdropFilter: panelOpen ? 'blur(4px)' : 'blur(0px)',
              WebkitBackdropFilter: panelOpen ? 'blur(4px)' : 'blur(0px)',
              transition: 'all 250ms ease-out',
            }}
          />

          {/* Panel */}
          <div
            role="dialog"
            aria-modal="true"
            aria-label={panelMode === 'create' ? 'Nova pergunta' : 'Editar pergunta'}
            style={{
              position: 'fixed',
              top: 0,
              right: 0,
              bottom: 0,
              zIndex: 1000,
              width: '100%',
              maxWidth: 640,
              background: '#fff',
              boxShadow: panelOpen
                ? '-8px 0 40px rgba(0, 42, 50, 0.15)'
                : '-8px 0 40px rgba(0, 42, 50, 0)',
              transform: panelOpen ? 'translateX(0)' : 'translateX(100%)',
              transition: 'transform 250ms cubic-bezier(0.16, 1, 0.3, 1), box-shadow 250ms ease-out',
              display: 'flex',
              flexDirection: 'column',
              overflow: 'hidden',
            }}
          >
            {/* Header */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '20px 28px',
                borderBottom: '1px solid #e5e7eb',
                flexShrink: 0,
              }}
            >
              <h2
                style={{
                  margin: 0,
                  fontSize: 18,
                  fontWeight: 600,
                  color: '#002a32',
                  fontFamily: 'Inter, sans-serif',
                }}
              >
                {panelMode === 'create' ? 'Nova Pergunta' : 'Editar Pergunta'}
              </h2>
              <button
                type="button"
                onClick={closePanel}
                aria-label="Fechar"
                style={{
                  background: 'none',
                  border: 'none',
                  cursor: 'pointer',
                  width: 36,
                  height: 36,
                  borderRadius: 8,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#6b7280',
                  fontSize: 20,
                  fontWeight: 300,
                  lineHeight: 1,
                  transition: 'all 0.15s ease',
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.background = '#f3f4f6'
                  e.currentTarget.style.color = '#002a32'
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.background = 'none'
                  e.currentTarget.style.color = '#6b7280'
                }}
              >
                ✕
              </button>
            </div>

            {/* Content — scrollable form */}
            <div
              style={{
                flex: 1,
                overflowY: 'auto',
                padding: '28px',
              }}
            >
              {formError && (
                <div
                  style={{
                    background: '#fef2f2',
                    border: '1px solid #fecaca',
                    color: '#991b1b',
                    padding: '12px 16px',
                    borderRadius: 8,
                    fontSize: 14,
                    marginBottom: 20,
                  }}
                >
                  {formError}
                </div>
              )}

              <div style={{ marginBottom: 24 }}>
                <label
                  style={{
                    display: 'block',
                    fontSize: 13,
                    fontWeight: 600,
                    color: '#374151',
                    marginBottom: 6,
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                  }}
                >
                  Pergunta PT *
                </label>
                <textarea
                  value={formQuestionPt}
                  onChange={(e) => setFormQuestionPt(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    border: '1px solid #d1d5db',
                    borderRadius: 8,
                    fontSize: 14,
                    fontFamily: 'Inter, sans-serif',
                    resize: 'vertical',
                    minHeight: 48,
                    outline: 'none',
                  }}
                  onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                  onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                  placeholder="Ex: Como me inscrevo num evento?"
                  rows={2}
                />
              </div>

              <div style={{ marginBottom: 24 }}>
                <label
                  style={{
                    display: 'block',
                    fontSize: 13,
                    fontWeight: 600,
                    color: '#374151',
                    marginBottom: 6,
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                  }}
                >
                  Pergunta EN *
                </label>
                <textarea
                  value={formQuestionEn}
                  onChange={(e) => setFormQuestionEn(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    border: '1px solid #d1d5db',
                    borderRadius: 8,
                    fontSize: 14,
                    fontFamily: 'Inter, sans-serif',
                    resize: 'vertical',
                    minHeight: 48,
                    outline: 'none',
                  }}
                  onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                  onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                  placeholder="Ex: How do I register for an event?"
                  rows={2}
                />
              </div>

              <div style={{ marginBottom: 24 }}>
                <label
                  style={{
                    display: 'block',
                    fontSize: 13,
                    fontWeight: 600,
                    color: '#374151',
                    marginBottom: 6,
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                  }}
                >
                  Resposta PT
                </label>
                <textarea
                  value={formAnswerPt}
                  onChange={(e) => setFormAnswerPt(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    border: '1px solid #d1d5db',
                    borderRadius: 8,
                    fontSize: 14,
                    fontFamily: 'Inter, sans-serif',
                    resize: 'vertical',
                    minHeight: 80,
                    outline: 'none',
                    lineHeight: 1.5,
                  }}
                  onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                  onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                  placeholder="Escreva a resposta em português..."
                  rows={4}
                />
              </div>

              <div style={{ marginBottom: 24 }}>
                <label
                  style={{
                    display: 'block',
                    fontSize: 13,
                    fontWeight: 600,
                    color: '#374151',
                    marginBottom: 6,
                    textTransform: 'uppercase',
                    letterSpacing: '0.05em',
                  }}
                >
                  Resposta EN
                </label>
                <textarea
                  value={formAnswerEn}
                  onChange={(e) => setFormAnswerEn(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    border: '1px solid #d1d5db',
                    borderRadius: 8,
                    fontSize: 14,
                    fontFamily: 'Inter, sans-serif',
                    resize: 'vertical',
                    minHeight: 80,
                    outline: 'none',
                    lineHeight: 1.5,
                  }}
                  onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                  onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                  placeholder="Write the answer in English..."
                  rows={4}
                />
              </div>

              <div style={{ display: 'flex', gap: 20, marginBottom: 24, alignItems: 'center' }}>
                <div style={{ flex: 1 }}>
                  <label
                    style={{
                      display: 'block',
                      fontSize: 13,
                      fontWeight: 600,
                      color: '#374151',
                      marginBottom: 6,
                      textTransform: 'uppercase',
                      letterSpacing: '0.05em',
                    }}
                  >
                    Ordem
                  </label>
                  <input
                    type="number"
                    value={formSortOrder}
                    onChange={(e) => setFormSortOrder(parseInt(e.target.value) || 0)}
                    min={0}
                    max={999}
                    style={{
                      width: '100%',
                      padding: '10px 14px',
                      border: '1px solid #d1d5db',
                      borderRadius: 8,
                      fontSize: 14,
                      fontFamily: 'Inter, sans-serif',
                      outline: 'none',
                    }}
                    onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                    onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                  />
                </div>

                <div style={{ flex: 1 }}>
                  <label
                    style={{
                      display: 'block',
                      fontSize: 13,
                      fontWeight: 600,
                      color: '#374151',
                      marginBottom: 6,
                      textTransform: 'uppercase',
                      letterSpacing: '0.05em',
                    }}
                  >
                    Estado
                  </label>
                  <button
                    type="button"
                    onClick={() => setFormPending(!formPending)}
                    style={{
                      width: '100%',
                      padding: '10px 14px',
                      border: '1px solid #d1d5db',
                      borderRadius: 8,
                      fontSize: 14,
                      fontFamily: 'Inter, sans-serif',
                      cursor: 'pointer',
                      background: formPending ? '#fffbeb' : '#f0fdf4',
                      color: formPending ? '#92400e' : '#166534',
                      fontWeight: 500,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      gap: 8,
                      outline: 'none',
                      transition: 'all 0.15s ease',
                    }}
                    onFocus={(e) => { e.currentTarget.style.borderColor = '#00493a'; e.currentTarget.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                    onBlur={(e) => { e.currentTarget.style.borderColor = '#d1d5db'; e.currentTarget.style.boxShadow = 'none' }}
                  >
                    {formPending ? (
                      <>
                        <XCircle size={16} /> Pendente
                      </>
                    ) : (
                      <>
                        <CheckCircle size={16} /> Publicado
                      </>
                    )}
                  </button>
                </div>
              </div>
            </div>

            {/* Footer */}
            <div
              style={{
                display: 'flex',
                gap: 12,
                justifyContent: 'flex-end',
                alignItems: 'center',
                padding: '16px 28px',
                borderTop: '1px solid #e5e7eb',
                background: '#f9fafb',
                flexShrink: 0,
              }}
            >
              <button
                type="button"
                onClick={closePanel}
                disabled={saving}
                style={{
                  padding: '10px 20px',
                  borderRadius: 8,
                  border: '2px solid #00493a',
                  background: 'transparent',
                  color: '#00493a',
                  fontSize: 14,
                  fontWeight: 500,
                  fontFamily: 'Inter, sans-serif',
                  cursor: saving ? 'not-allowed' : 'pointer',
                  opacity: saving ? 0.5 : 1,
                  transition: 'all 0.15s ease',
                }}
                onMouseEnter={(e) => {
                  if (!saving) e.currentTarget.style.background = 'rgba(0, 73, 58, 0.06)'
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.background = 'transparent'
                }}
              >
                Cancelar
              </button>
              <button
                type="button"
                onClick={handleSaveQuestion}
                disabled={saving}
                style={{
                  padding: '10px 24px',
                  borderRadius: 8,
                  border: 'none',
                  background: saving ? '#6b7280' : '#00493a',
                  color: '#fff',
                  fontSize: 14,
                  fontWeight: 600,
                  fontFamily: 'Inter, sans-serif',
                  cursor: saving ? 'not-allowed' : 'pointer',
                  transition: 'all 0.15s ease',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8,
                }}
                onMouseEnter={(e) => {
                  if (!saving) {
                    e.currentTarget.style.background = '#005c4a'
                    e.currentTarget.style.transform = 'scale(1.02)'
                  }
                }}
                onMouseLeave={(e) => {
                  if (!saving) {
                    e.currentTarget.style.background = '#00493a'
                    e.currentTarget.style.transform = 'scale(1)'
                  }
                }}
              >
                <Save size={16} />
                {saving ? 'A guardar...' : panelMode === 'create' ? 'Criar Pergunta' : 'Guardar Alterações'}
              </button>
            </div>
          </div>
        </>
      )}

      <style>{`
        .admin-faq .admin-table th,
        .admin-faq .admin-table td {
          padding: 10px 12px;
          text-align: left;
          border-bottom: 1px solid var(--admin-border, #e5e7eb);
        }
        .admin-faq .admin-table th {
          font-weight: 600;
          font-size: 13px;
          color: #6b7280;
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }
        .admin-faq .admin-table td {
          font-size: 14px;
        }
      `}</style>
    </div>
  )
}
