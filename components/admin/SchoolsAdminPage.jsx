'use client'

import { useState, useCallback } from 'react'
import { Pencil, Trash2, Plus, Archive, ArchiveRestore } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { getAllSchoolsAdmin, createSchool, updateSchool, archiveSchool, restoreSchool, deleteSchool } from '@/lib/actions/competition'

export default function SchoolsAdminPage({ initialSchools = [], currentUserRole }) {
  const [schools, setSchools] = useState(initialSchools)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)
  const [editing, setEditing] = useState(null)
  const [showForm, setShowForm] = useState(false)
  const isSuper = currentUserRole === 'superadmin'

  const refresh = useCallback(async () => {
    const list = await getAllSchoolsAdmin()
    setSchools(list || [])
  }, [])

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) } else { setError(text); setMessage(null) }
  }

  const handleSave = async (e) => {
    e.preventDefault()
    const form = new FormData(e.target)
    const data = {
      name: form.get('name'),
      slug: form.get('slug') || form.get('name').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-'),
      location: form.get('location') || '',
      status: form.get('status') || 'published',
    }
    const res = editing ? await updateSchool(editing.id, data) : await createSchool(data)
    if (res.success) { showMessage(true, editing ? 'Atualizada.' : 'Criada.'); setShowForm(false); setEditing(null); refresh() }
    else showMessage(false, res.error)
  }

  const handleArchive = async (id) => {
    const res = await archiveSchool(id)
    if (res.success) { showMessage(true, 'Arquivada.'); refresh() } else showMessage(false, res.error)
  }

  const handleRestore = async (id) => {
    const res = await restoreSchool(id)
    if (res.success) { showMessage(true, 'Restaurada.'); refresh() } else showMessage(false, res.error)
  }

  const handleDelete = async (id, name) => {
    if (!window.confirm(`Eliminar "${name}"? As turmas associadas serão removidas.`)) return
    const res = await deleteSchool(id)
    if (res.success) { showMessage(true, 'Eliminada.'); refresh() } else showMessage(false, res.error)
  }

  return (
    <div>
      <div className="admin-page-header">
        <h1>Escolas</h1>
        <p className="admin-page-subtitle">Gerir escolas participantes nas competições</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-card">
        <div className="admin-card-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h3>Lista de Escolas</h3>
          <button className="admin-btn admin-btn-primary admin-btn-sm" onClick={() => { setEditing(null); setShowForm(true) }}>
            <Plus size={14} /> Nova Escola
          </button>
        </div>

        {showForm && (
          <form onSubmit={handleSave} style={{ padding: 20, background: 'var(--admin-card-bg)', borderBottom: '1px solid var(--admin-border)' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div>
                <label className="admin-dim-label">Nome</label>
                <input name="name" className="admin-dim-input" defaultValue={editing?.name || ''} required />
              </div>
              <div>
                <label className="admin-dim-label">Slug</label>
                <input name="slug" className="admin-dim-input" defaultValue={editing?.slug || ''} />
              </div>
              <div>
                <label className="admin-dim-label">Localização</label>
                <input name="location" className="admin-dim-input" defaultValue={editing?.location || ''} />
              </div>
              <div>
                <label className="admin-dim-label">Estado</label>
                <select name="status" className="admin-dim-input" defaultValue={editing?.status || 'published'}>
                  <option value="published">Publicado</option>
                  <option value="draft">Rascunho</option>
                </select>
              </div>
            </div>
            <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
              <button type="submit" className="admin-btn admin-btn-primary">Guardar</button>
              <button type="button" className="admin-btn admin-btn-secondary" onClick={() => { setShowForm(false); setEditing(null) }}>Cancelar</button>
            </div>
          </form>
        )}

        <div className="admin-table-wrapper">
          <table className="admin-table">
            <thead>
              <tr><th>Nome</th><th>Slug</th><th>Localização</th><th>Estado</th><th>Ações</th></tr>
            </thead>
            <tbody>
              {schools.map((s) => (
                <tr key={s.id} className={s.is_archived ? 'admin-table-row-archived' : ''}>
                  <td><strong>{escapeHtml(s.name)}</strong></td>
                  <td><code>{s.slug}</code></td>
                  <td>{escapeHtml(s.location || '-')}</td>
                  <td>
                    <span className={`admin-badge ${s.status === 'published' ? 'admin-badge-success' : 'admin-badge-warning'}`}>
                      {s.status === 'published' ? 'Publicado' : 'Rascunho'}
                    </span>
                    {s.is_archived && <span className="admin-badge admin-badge-archived" style={{ marginLeft: 4 }}>Arquivado</span>}
                  </td>
                  <td>
                    <div className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => { setEditing(s); setShowForm(true) }}>Editar</button>
                      {!s.is_archived ? (
                        <button className="admin-btn admin-btn-sm" onClick={() => handleArchive(s.id)}>Arquivar</button>
                      ) : isSuper && (
                        <button className="admin-btn admin-btn-sm" onClick={() => handleRestore(s.id)}>Restaurar</button>
                      )}
                      {isSuper && (
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={() => handleDelete(s.id, s.name)}>Eliminar</button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
              {schools.length === 0 && (
                <tr><td colSpan={5} style={{ textAlign: 'center', padding: 40, color: 'var(--admin-text-muted)' }}>Nenhuma escola registada</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
