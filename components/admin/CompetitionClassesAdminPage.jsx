'use client'

import { useState, useCallback, useEffect } from 'react'
import { Pencil, Trash2, Plus, Archive, ArchiveRestore } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import { getAllSchoolsAdmin, getAllClassesAdmin, createClass, updateClass, archiveClass, restoreClass, deleteClass } from '@/lib/actions/competition'

export default function CompetitionClassesAdminPage({ initialClasses = [], initialSchools = [], currentUserRole }) {
  const [classes, setClasses] = useState(initialClasses)
  const [schools, setSchools] = useState(initialSchools)
  const [message, setMessage] = useState(null)
  const [error, setError] = useState(null)
  const [editing, setEditing] = useState(null)
  const [showForm, setShowForm] = useState(false)
  const [schoolFilter, setSchoolFilter] = useState('')
  const isSuper = currentUserRole === 'superadmin'

  const refresh = useCallback(async () => {
    const list = await getAllClassesAdmin(schoolFilter || undefined)
    setClasses(list || [])
  }, [schoolFilter])

  useEffect(() => { refresh() }, [refresh])

  const showMessage = (ok, text) => {
    if (ok) { setMessage(text); setError(null) } else { setError(text); setMessage(null) }
  }

  const handleSave = async (e) => {
    e.preventDefault()
    const form = new FormData(e.target)
    const data = {
      name: form.get('name'),
      slug: form.get('slug') || form.get('name').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-'),
      school_id: form.get('school_id'),
      grade: form.get('grade') || '',
      status: form.get('status') || 'published',
    }
    if (!data.school_id) { showMessage(false, 'Seleciona uma escola'); return }
    const res = editing ? await updateClass(editing.id, data) : await createClass(data)
    if (res.success) { showMessage(true, editing ? 'Atualizada.' : 'Criada.'); setShowForm(false); setEditing(null); refresh() }
    else showMessage(false, res.error)
  }

  return (
    <div>
      <div className="admin-page-header">
        <h1>Turmas</h1>
        <p className="admin-page-subtitle">Gerir turmas por escola</p>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}
      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="admin-card">
        <div className="admin-card-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <h3>Lista de Turmas</h3>
            <select className="admin-dim-input" style={{ width: 200 }} value={schoolFilter} onChange={(e) => setSchoolFilter(e.target.value)}>
              <option value="">Todas as escolas</option>
              {schools.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
            </select>
          </div>
          <button className="admin-btn admin-btn-primary admin-btn-sm" onClick={() => { setEditing(null); setShowForm(true) }}>
            <Plus size={14} /> Nova Turma
          </button>
        </div>

        {showForm && (
          <form onSubmit={handleSave} style={{ padding: 20, background: 'var(--admin-card-bg)', borderBottom: '1px solid var(--admin-border)' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
              <div>
                <label className="admin-dim-label">Escola</label>
                <select name="school_id" className="admin-dim-input" defaultValue={editing?.school_id || ''} required>
                  <option value="">Selecionar...</option>
                  {schools.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
                </select>
              </div>
              <div>
                <label className="admin-dim-label">Nome</label>
                <input name="name" className="admin-dim-input" defaultValue={editing?.name || ''} placeholder="ex: 10.ª A" required />
              </div>
              <div>
                <label className="admin-dim-label">Ano</label>
                <input name="grade" className="admin-dim-input" defaultValue={editing?.grade || ''} placeholder="ex: 10" />
              </div>
              <div>
                <label className="admin-dim-label">Slug</label>
                <input name="slug" className="admin-dim-input" defaultValue={editing?.slug || ''} />
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
              <tr><th>Turma</th><th>Escola</th><th>Ano</th><th>Estado</th><th>Ações</th></tr>
            </thead>
            <tbody>
              {classes.map((c) => (
                <tr key={c.id} className={c.is_archived ? 'admin-table-row-archived' : ''}>
                  <td><strong>{escapeHtml(c.name)}</strong></td>
                  <td>{escapeHtml(c.school?.name || '-')}</td>
                  <td>{escapeHtml(c.grade || '-')}</td>
                  <td>
                    <span className={`admin-badge ${c.status === 'published' ? 'admin-badge-success' : 'admin-badge-warning'}`}>
                      {c.status === 'published' ? 'Publicado' : 'Rascunho'}
                    </span>
                  </td>
                  <td>
                    <div className="admin-table-actions">
                      <button className="admin-btn admin-btn-sm" onClick={() => { setEditing(c); setShowForm(true) }}>Editar</button>
                      {!c.is_archived ? (
                        <button className="admin-btn admin-btn-sm" onClick={async () => { const r = await archiveClass(c.id); if (r.success) { showMessage(true, 'Arquivada.'); refresh() } }}>Arquivar</button>
                      ) : isSuper && (
                        <button className="admin-btn admin-btn-sm" onClick={async () => { const r = await restoreClass(c.id); if (r.success) { showMessage(true, 'Restaurada.'); refresh() } }}>Restaurar</button>
                      )}
                      {isSuper && (
                        <button className="admin-btn admin-btn-sm admin-btn-danger" onClick={async () => { if (window.confirm(`Eliminar "${c.name}"?`)) { const r = await deleteClass(c.id); if (r.success) { showMessage(true, 'Eliminada.'); refresh() } } }}>Eliminar</button>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
              {classes.length === 0 && (
                <tr><td colSpan={5} style={{ textAlign: 'center', padding: 40, color: 'var(--admin-text-muted)' }}>Nenhuma turma registada</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
