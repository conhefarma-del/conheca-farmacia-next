'use client'

import React, { useState, useCallback, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Save, Trash2, RotateCcw, CheckCircle, XCircle, Edit3 } from 'lucide-react'
import { createPrivacySection, updatePrivacySection, archivePrivacySection, restorePrivacySection } from '@/lib/actions/legalContent'

export default function PrivacyAdminPage({ lang, initialSections, currentUserRole }) {
  const router = useRouter()
  const [sections, setSections] = useState(initialSections || [])
  const [message, setMessage] = useState(null)

  // Slide panel state
  const [panelRendered, setPanelRendered] = useState(false)
  const [panelOpen, setPanelOpen] = useState(false)
  const [panelMode, setPanelMode] = useState('create') // 'create' | 'edit'
  const [editingSection, setEditingSection] = useState(null)
  const [saving, setSaving] = useState(false)

  // Form state
  const [formAnchorSlug, setFormAnchorSlug] = useState('')
  const [formTitlePt, setFormTitlePt] = useState('')
  const [formTitleEn, setFormTitleEn] = useState('')
  const [formContentPt, setFormContentPt] = useState('')
  const [formContentEn, setFormContentEn] = useState('')
  const [formPending, setFormPending] = useState(true)
  const [formSortOrder, setFormSortOrder] = useState(0)
  const [formLevel, setFormLevel] = useState(1)
  const [formParentId, setFormParentId] = useState('')
  const [formError, setFormError] = useState(null)

  // Determine available parent sections (level 1 sections) for level 2 children
  const parentOptions = sections.filter((s) => !s.is_archived && s.level !== 2)

  // Helper to generate anchor slug from title
  const generateAnchorSlug = (title) => {
    return title
      .toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
  }

  // --- Slide panel: Open create ---
  const openCreatePanel = useCallback((level = 1, parentId = null) => {
    setPanelMode('create')
    setEditingSection(null)
    setFormAnchorSlug('')
    setFormTitlePt('')
    setFormTitleEn('')
    setFormContentPt('')
    setFormContentEn('')
    setFormPending(true)
    setFormSortOrder(sections.length + 1)
    setFormLevel(level)
    setFormParentId(parentId || '')
    setFormError(null)
    setPanelRendered(true)
    requestAnimationFrame(() => setPanelOpen(true))
  }, [sections])

  // --- Slide panel: Open edit ---
  const openEditPanel = useCallback((section) => {
    setPanelMode('edit')
    setEditingSection(section)
    setFormAnchorSlug(section.anchor_slug || '')
    setFormTitlePt(section.title_pt || '')
    setFormTitleEn(section.title_en || '')
    setFormContentPt(section.content_pt || '')
    setFormContentEn(section.content_en || '')
    setFormPending(section.pending !== false)
    setFormSortOrder(section.sort_order || 0)
    setFormLevel(section.level || 1)
    setFormParentId(section.parent_id || '')
    setFormError(null)
    setPanelRendered(true)
    requestAnimationFrame(() => setPanelOpen(true))
  }, [])

  // --- Slide panel: Close ---
  const closePanel = useCallback(() => {
    setPanelOpen(false)
    setTimeout(() => {
      setPanelRendered(false)
      setEditingSection(null)
    }, 250)
  }, [])

  // Escape key handler
  useEffect(() => {
    const onKey = (e) => { if (e.key === 'Escape' && panelRendered) closePanel() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [panelRendered, closePanel])

  // --- Slide panel: Save ---
  const handleSaveSection = useCallback(async () => {
    if (!formAnchorSlug.trim()) {
      setFormError('O anchor slug é obrigatório.')
      return
    }
    if (!formTitlePt.trim()) {
      setFormError('O título PT é obrigatório.')
      return
    }
    if (!formTitleEn.trim()) {
      setFormError('O título EN é obrigatório.')
      return
    }

    setSaving(true)
    setFormError(null)

    try {
      if (panelMode === 'create') {
        const result = await createPrivacySection({
          parent_id: formLevel === 2 ? (formParentId || null) : null,
          anchor_slug: formAnchorSlug,
          title_pt: formTitlePt,
          title_en: formTitleEn,
          content_pt: formContentPt,
          content_en: formContentEn,
          level: formLevel,
          pending: formPending,
          sort_order: formSortOrder,
        })
        if (result.success) {
          setMessage('Secção criada com sucesso!')
          closePanel()
          router.refresh()
        } else {
          setFormError(result.error || 'Erro ao criar secção.')
        }
      } else {
        const result = await updatePrivacySection(editingSection.id, {
          anchor_slug: formAnchorSlug,
          title_pt: formTitlePt,
          title_en: formTitleEn,
          content_pt: formContentPt,
          content_en: formContentEn,
          pending: formPending,
          sort_order: formSortOrder,
        })
        if (result.success) {
          setMessage('Secção atualizada com sucesso!')
          closePanel()
          router.refresh()
        } else {
          setFormError(result.error || 'Erro ao atualizar secção.')
        }
      }
    } catch (err) {
      setFormError('Erro inesperado: ' + (err.message || 'desconhecido'))
    } finally {
      setSaving(false)
    }
  }, [formAnchorSlug, formTitlePt, formTitleEn, formContentPt, formContentEn, formPending, formSortOrder, formLevel, formParentId, panelMode, editingSection, closePanel, router])

  // Archive/restore section
  const handleArchive = useCallback(async (id) => {
    const result = await archivePrivacySection(id)
    if (result.success) {
      setMessage('Secção arquivada.')
      router.refresh()
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [router])

  const handleRestore = useCallback(async (id) => {
    const result = await restorePrivacySection(id)
    if (result.success) {
      setMessage('Secção restaurada.')
      router.refresh()
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [router])

  // Render a section row
  const renderSectionRow = (section, isChild = false) => (
    <tr key={section.id} className={`${section.is_archived ? 'admin-table-row-archived' : ''} ${isChild ? 'admin-table-row-child' : ''}`}>
      <td style={{ paddingLeft: isChild ? 40 : 12 }}>{section.anchor_slug}</td>
      <td style={{ fontWeight: isChild ? 'normal' : 600, maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
        {section.title_pt}
      </td>
      <td style={{ maxWidth: 200, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
        {section.title_en}
      </td>
      <td>
        <span className={`admin-badge ${section.pending ? 'admin-badge-warning' : 'admin-badge-success'}`}>
          {section.pending ? 'Pendente' : 'Publicado'}
        </span>
      </td>
      <td>{section.is_archived ? 'Sim' : 'Não'}</td>
      <td>
        <div className="admin-table-actions">
          <button className="admin-btn admin-btn-sm" onClick={() => openEditPanel(section)}>
            <Edit3 size={14} /> Editar
          </button>
          {!isChild && (
            <button className="admin-btn admin-btn-sm" onClick={() => openCreatePanel(2, section.id)} title="Adicionar sub-secção">
              <Plus size={14} /> Sub
            </button>
          )}
          {currentUserRole === 'superadmin' && section.is_archived && (
            <button className="admin-btn admin-btn-sm" onClick={() => handleRestore(section.id)}>
              <RotateCcw size={14} /> Restaurar
            </button>
          )}
          {!section.is_archived && (
            <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => handleArchive(section.id)}>
              <Trash2 size={14} /> Arquivar
            </button>
          )}
        </div>
      </td>
    </tr>
  )

  return (
    <div className="admin-privacy">
      <div className="admin-page-header">
        <h1>Gerir Política de Privacidade</h1>
        <p className="admin-page-subtitle">Gerir secções da política de privacidade e cookies.</p>
      </div>

      {message && (
        <div className={`admin-message ${message.startsWith('Erro') ? 'admin-error-message' : 'admin-success-message'}`}>
          {message}
          <button onClick={() => setMessage(null)} style={{ marginLeft: 12, background: 'none', border: 'none', cursor: 'pointer' }}>×</button>
        </div>
      )}

      <div className="admin-card">
        <div className="admin-card-header">
          <h2>Secções</h2>
          <button className="admin-btn admin-btn-primary" onClick={() => openCreatePanel(1)}>
            <Plus size={16} /> Nova Secção
          </button>
        </div>
        <div className="admin-card-body">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Anchor</th>
                <th>PT</th>
                <th>EN</th>
                <th>Estado</th>
                <th>Arquivado</th>
                <th>Ações</th>
              </tr>
            </thead>
            <tbody>
              {sections.length === 0 ? (
                <tr><td colSpan={6} className="admin-table-empty">Nenhuma secção encontrada.</td></tr>
              ) : (
                sections.map((section) => (
                  <React.Fragment key={section.id}>
                    {renderSectionRow(section)}
                    {section.children && section.children.length > 0 && section.children.map((child) => (
                      <React.Fragment key={child.id}>
                        {renderSectionRow(child, true)}
                      </React.Fragment>
                    ))}
                  </React.Fragment>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* ===== Slide Panel: Edit/Create Section ===== */}
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
            aria-label={panelMode === 'create' ? 'Nova secção' : 'Editar secção'}
            style={{
              position: 'fixed',
              top: 0,
              right: 0,
              bottom: 0,
              zIndex: 1000,
              width: '100%',
              maxWidth: 680,
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
                {panelMode === 'create'
                  ? (formLevel === 2 ? 'Nova Sub-Secção' : 'Nova Secção')
                  : 'Editar Secção'}
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

              {/* Level + Parent (only for create mode) */}
              {panelMode === 'create' && (
                <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
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
                      Nível
                    </label>
                    <div style={{ display: 'flex', gap: 8 }}>
                      <button
                        type="button"
                        onClick={() => { setFormLevel(1); setFormParentId('') }}
                        style={{
                          flex: 1,
                          padding: '10px 14px',
                          border: `2px solid ${formLevel === 1 ? '#00493a' : '#d1d5db'}`,
                          borderRadius: 8,
                          fontSize: 14,
                          fontFamily: 'Inter, sans-serif',
                          cursor: 'pointer',
                          background: formLevel === 1 ? 'rgba(0,73,58,0.06)' : 'transparent',
                          color: formLevel === 1 ? '#00493a' : '#6b7280',
                          fontWeight: formLevel === 1 ? 600 : 400,
                          transition: 'all 0.15s ease',
                        }}
                      >
                        Secção (nível 1)
                      </button>
                      <button
                        type="button"
                        onClick={() => setFormLevel(2)}
                        style={{
                          flex: 1,
                          padding: '10px 14px',
                          border: `2px solid ${formLevel === 2 ? '#00493a' : '#d1d5db'}`,
                          borderRadius: 8,
                          fontSize: 14,
                          fontFamily: 'Inter, sans-serif',
                          cursor: 'pointer',
                          background: formLevel === 2 ? 'rgba(0,73,58,0.06)' : 'transparent',
                          color: formLevel === 2 ? '#00493a' : '#6b7280',
                          fontWeight: formLevel === 2 ? 600 : 400,
                          transition: 'all 0.15s ease',
                        }}
                        disabled={parentOptions.length === 0}
                      >
                        Sub-secção (nível 2)
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* Parent selector — only for level 2 in create mode */}
              {panelMode === 'create' && formLevel === 2 && (
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
                    Secção Pai
                  </label>
                  {parentOptions.length > 0 ? (
                    <select
                      value={formParentId}
                      onChange={(e) => setFormParentId(e.target.value)}
                      style={{
                        width: '100%',
                        padding: '10px 14px',
                        border: '1px solid #d1d5db',
                        borderRadius: 8,
                        fontSize: 14,
                        fontFamily: 'Inter, sans-serif',
                        outline: 'none',
                        background: '#fff',
                      }}
                      onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                      onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                    >
                      <option value="">Selecionar secção pai...</option>
                      {parentOptions.map((s) => (
                        <option key={s.id} value={s.id}>
                          {s.title_pt} ({s.anchor_slug})
                        </option>
                      ))}
                    </select>
                  ) : (
                    <p style={{ color: '#9ca3af', fontSize: 14, fontStyle: 'italic' }}>
                      Crie primeiro uma secção de nível 1.
                    </p>
                  )}
                </div>
              )}

              {/* Anchor slug */}
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
                  Anchor Slug *
                </label>
                <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                  <input
                    type="text"
                    value={formAnchorSlug}
                    onChange={(e) => setFormAnchorSlug(e.target.value)}
                    style={{
                      flex: 1,
                      padding: '10px 14px',
                      border: '1px solid #d1d5db',
                      borderRadius: 8,
                      fontSize: 14,
                      fontFamily: 'monospace',
                      outline: 'none',
                    }}
                    onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                    onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                    placeholder="ex: nova-seccao"
                  />
                  <button
                    type="button"
                    onClick={() => setFormAnchorSlug(generateAnchorSlug(formTitlePt || formTitleEn))}
                    title="Gerar slug a partir do título"
                    style={{
                      padding: '10px 14px',
                      border: '1px solid #d1d5db',
                      borderRadius: 8,
                      fontSize: 12,
                      fontFamily: 'Inter, sans-serif',
                      cursor: 'pointer',
                      background: '#f9fafb',
                      color: '#6b7280',
                      whiteSpace: 'nowrap',
                      transition: 'all 0.15s ease',
                    }}
                    onMouseEnter={(e) => { e.currentTarget.style.borderColor = '#00493a'; e.currentTarget.style.color = '#00493a' }}
                    onMouseLeave={(e) => { e.currentTarget.style.borderColor = '#d1d5db'; e.currentTarget.style.color = '#6b7280' }}
                  >
                    Gerar
                  </button>
                </div>
              </div>

              {/* Title PT */}
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
                  Título PT *
                </label>
                <input
                  type="text"
                  value={formTitlePt}
                  onChange={(e) => setFormTitlePt(e.target.value)}
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
                  placeholder="Ex: Quem somos"
                />
              </div>

              {/* Title EN */}
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
                  Título EN *
                </label>
                <input
                  type="text"
                  value={formTitleEn}
                  onChange={(e) => setFormTitleEn(e.target.value)}
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
                  placeholder="Ex: Who we are"
                />
              </div>

              {/* Content PT */}
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
                  Conteúdo PT
                </label>
                <textarea
                  value={formContentPt}
                  onChange={(e) => setFormContentPt(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    border: '1px solid #d1d5db',
                    borderRadius: 8,
                    fontSize: 14,
                    fontFamily: 'Inter, sans-serif',
                    resize: 'vertical',
                    minHeight: 120,
                    outline: 'none',
                    lineHeight: 1.6,
                  }}
                  onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                  onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                  placeholder="Escreva o conteúdo em português..."
                  rows={5}
                />
              </div>

              {/* Content EN */}
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
                  Conteúdo EN
                </label>
                <textarea
                  value={formContentEn}
                  onChange={(e) => setFormContentEn(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    border: '1px solid #d1d5db',
                    borderRadius: 8,
                    fontSize: 14,
                    fontFamily: 'Inter, sans-serif',
                    resize: 'vertical',
                    minHeight: 120,
                    outline: 'none',
                    lineHeight: 1.6,
                  }}
                  onFocus={(e) => { e.target.style.borderColor = '#00493a'; e.target.style.boxShadow = '0 0 0 3px rgba(0,73,58,0.1)' }}
                  onBlur={(e) => { e.target.style.borderColor = '#d1d5db'; e.target.style.boxShadow = 'none' }}
                  placeholder="Write the content in English..."
                  rows={5}
                />
              </div>

              {/* Sort order + Pending */}
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
                onClick={handleSaveSection}
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
                {saving ? 'A guardar...' : panelMode === 'create' ? 'Criar Secção' : 'Guardar Alterações'}
              </button>
            </div>
          </div>
        </>
      )}

      <style>{`
        .admin-privacy .admin-table th,
        .admin-privacy .admin-table td {
          padding: 10px 12px;
          text-align: left;
          border-bottom: 1px solid var(--admin-border, #e5e7eb);
        }
        .admin-privacy .admin-table th {
          font-weight: 600;
          font-size: 13px;
          color: #6b7280;
          text-transform: uppercase;
          letter-spacing: 0.05em;
        }
        .admin-privacy .admin-table td {
          font-size: 14px;
        }
        .admin-privacy .admin-table-row-child td {
          font-size: 13px;
        }
      `}</style>
    </div>
  )
}
