'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Save, Trash2, RotateCcw, CheckCircle, XCircle } from 'lucide-react'
import { createFAQTab, archiveFAQTab, restoreFAQTab, getFAQQuestions, createFAQQuestion, updateFAQQuestion, archiveFAQQuestion, restoreFAQQuestion } from '@/lib/actions/legalContent'

export default function FAQAdminPage({ lang, initialTabs, currentUserRole }) {
  const router = useRouter()
  const [tabs, setTabs] = useState(initialTabs || [])
  const [selectedTabId, setSelectedTabId] = useState(tabs[0]?.id || null)
  const [questions, setQuestions] = useState([])
  const [loadingQuestions, setLoadingQuestions] = useState(false)
  const [message, setMessage] = useState(null)

  // Load questions when tab changes
  const handleSelectTab = useCallback(async (tabId) => {
    setSelectedTabId(tabId)
    setLoadingQuestions(true)
    const qs = await getFAQQuestions(tabId)
    setQuestions(qs)
    setLoadingQuestions(false)
  }, [])

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

  // Create a new question
  const handleCreateQuestion = useCallback(async () => {
    if (!selectedTabId) return
    const questionPt = prompt('Pergunta PT:')
    if (!questionPt) return
    const questionEn = prompt('Pergunta EN:')
    if (!questionEn) return

    const result = await createFAQQuestion({
      tab_id: selectedTabId,
      question_pt: questionPt,
      question_en: questionEn,
      answer_pt: '',
      answer_en: '',
      pending: true,
      sort_order: questions.length + 1,
    })
    if (result.success) {
      setMessage('Pergunta criada!')
      handleSelectTab(selectedTabId)
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [selectedTabId, questions, handleSelectTab])

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

  // Clear message after 3s
  const clearMessage = useCallback(() => {
    setTimeout(() => setMessage(null), 3000)
  }, [])

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
            <button className="admin-btn admin-btn-primary" onClick={handleCreateQuestion}>
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
                  <th>Pergunta EN</th>
                  <th>Estado</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {questions.map((q) => (
                  <tr key={q.id} className={q.is_archived ? 'admin-table-row-archived' : ''}>
                    <td>{q.sort_order}</td>
                    <td>{q.question_pt}</td>
                    <td>{q.question_en}</td>
                    <td>
                      <span className={`admin-badge ${q.pending ? 'admin-badge-warning' : 'admin-badge-success'}`}>
                        {q.pending ? 'Pendente' : 'Publicado'}
                      </span>
                    </td>
                    <td>
                      <div className="admin-table-actions">
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
    </div>
  )
}
