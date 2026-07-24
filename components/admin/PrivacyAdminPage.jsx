'use client'

import React, { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Save, Trash2, RotateCcw, CheckCircle, XCircle } from 'lucide-react'
import { createPrivacySection, updatePrivacySection, archivePrivacySection, restorePrivacySection } from '@/lib/actions/legalContent'

export default function PrivacyAdminPage({ lang, initialSections, currentUserRole }) {
  const router = useRouter()
  const [sections, setSections] = useState(initialSections || [])
  const [editingId, setEditingId] = useState(null)
  const [editData, setEditData] = useState({})
  const [message, setMessage] = useState(null)

  // Create a new section
  const handleCreate = useCallback(async (level = 1, parentId = null) => {
    const anchorSlug = prompt('Anchor slug (ex: nova-seccao):')
    if (!anchorSlug) return
    const titlePt = prompt('Título PT:')
    if (!titlePt) return
    const titleEn = prompt('Título EN:')
    if (!titleEn) return

    const result = await createPrivacySection({
      parent_id: parentId,
      anchor_slug: anchorSlug,
      title_pt: titlePt,
      title_en: titleEn,
      content_pt: '',
      content_en: '',
      level,
      pending: true,
      sort_order: sections.length + 1,
    })
    if (result.success) {
      setMessage('Secção criada!')
      router.refresh()
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [sections, router])

  // Start editing a section
  const handleEdit = useCallback((section) => {
    setEditingId(section.id)
    setEditData({
      anchor_slug: section.anchor_slug,
      title_pt: section.title_pt,
      title_en: section.title_en,
      content_pt: section.content_pt,
      content_en: section.content_en,
      pending: section.pending,
      sort_order: section.sort_order,
    })
  }, [])

  // Save section edits
  const handleSave = useCallback(async (id) => {
    const result = await updatePrivacySection(id, editData)
    if (result.success) {
      setMessage('Secção atualizada!')
      setEditingId(null)
      router.refresh()
    } else {
      setMessage(`Erro: ${result.error}`)
    }
  }, [editData, router])

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
      <td style={{ fontWeight: isChild ? 'normal' : 600 }}>{section.title_pt}</td>
      <td>{section.title_en}</td>
      <td>
        <span className={`admin-badge ${section.pending ? 'admin-badge-warning' : 'admin-badge-success'}`}>
          {section.pending ? 'Pendente' : 'Publicado'}
        </span>
      </td>
      <td>{section.is_archived ? 'Sim' : 'Não'}</td>
      <td>
        <div className="admin-table-actions">
          <button className="admin-btn admin-btn-sm" onClick={() => handleEdit(section)}>
            <Save size={14} /> Editar
          </button>
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
          <button className="admin-btn admin-btn-primary" onClick={() => handleCreate(1)}>
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

      {/* Edit Modal */}
      {editingId && (
        <div className="admin-modal-overlay" onClick={() => setEditingId(null)}>
          <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
            <div className="admin-modal-header">
              <h3>Editar Secção</h3>
              <button className="admin-btn admin-btn-sm" onClick={() => setEditingId(null)}>×</button>
            </div>
            <div className="admin-modal-body">
              <div className="admin-form-group">
                <label>Anchor Slug</label>
                <input
                  type="text"
                  className="admin-input"
                  value={editData.anchor_slug || ''}
                  onChange={(e) => setEditData({ ...editData, anchor_slug: e.target.value })}
                />
              </div>
              <div className="admin-form-group">
                <label>Título PT</label>
                <input
                  type="text"
                  className="admin-input"
                  value={editData.title_pt || ''}
                  onChange={(e) => setEditData({ ...editData, title_pt: e.target.value })}
                />
              </div>
              <div className="admin-form-group">
                <label>Título EN</label>
                <input
                  type="text"
                  className="admin-input"
                  value={editData.title_en || ''}
                  onChange={(e) => setEditData({ ...editData, title_en: e.target.value })}
                />
              </div>
              <div className="admin-form-group">
                <label>Conteúdo PT</label>
                <textarea
                  className="admin-textarea"
                  rows={6}
                  value={editData.content_pt || ''}
                  onChange={(e) => setEditData({ ...editData, content_pt: e.target.value })}
                />
              </div>
              <div className="admin-form-group">
                <label>Conteúdo EN</label>
                <textarea
                  className="admin-textarea"
                  rows={6}
                  value={editData.content_en || ''}
                  onChange={(e) => setEditData({ ...editData, content_en: e.target.value })}
                />
              </div>
              <div className="admin-form-group">
                <label>
                  <input
                    type="checkbox"
                    checked={editData.pending || false}
                    onChange={(e) => setEditData({ ...editData, pending: e.target.checked })}
                    style={{ marginRight: 8 }}
                  />
                  Pendente
                </label>
              </div>
            </div>
            <div className="admin-modal-footer">
              <button className="admin-btn" onClick={() => setEditingId(null)}>Cancelar</button>
              <button className="admin-btn admin-btn-primary" onClick={() => handleSave(editingId)}>
                <Save size={16} /> Guardar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
