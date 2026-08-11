'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Plus, Save, X, Pencil, Trash2 } from 'lucide-react'
import { escapeHtml } from '@/lib/security'
import {
  createScientificCategory,
  updateScientificCategory,
  deleteScientificCategory,
} from '@/lib/actions/scientific'
import ConfirmModal from '@/components/admin/ConfirmModal'

function generateSlug(name) {
  return (name || '')
    .toLowerCase()
    .replace(/[àáâäãå]/g, 'a').replace(/[èéêë]/g, 'e')
    .replace(/[ìíîï]/g, 'i').replace(/[òóôöõ]/g, 'o')
    .replace(/[ùúûü]/g, 'u').replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

const EMPTY = { name_pt: '', name_en: '', slug: '', color: '#0a844f', sort_order: 0 }

/**
 * ScientificCategoriesAdminPage — CRUD das categorias científicas
 * (geríveis — decisão 2026-08-11). Adição no topo + edição inline por linha.
 * Eliminação só superadmin e bloqueada quando a categoria tem artigos.
 */
export default function ScientificCategoriesAdminPage({ categories = [], currentUserRole }) {
  const router = useRouter()
  const [newCat, setNewCat] = useState({ ...EMPTY })
  const [editId, setEditId] = useState(null)
  const [editCat, setEditCat] = useState({ ...EMPTY })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [confirmDelete, setConfirmDelete] = useState(null)
  const [slugEdited, setSlugEdited] = useState(false)

  const handleNewName = (value) => {
    setNewCat((prev) => ({ ...prev, name_pt: value, slug: slugEdited ? prev.slug : generateSlug(value) }))
  }

  const handleCreate = async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)
    try {
      const result = await createScientificCategory(newCat)
      if (result.success) {
        setNewCat({ ...EMPTY })
        setSlugEdited(false)
        router.refresh()
      } else {
        setError(result.error)
      }
    } catch {
      setError('Erro ao criar categoria.')
    } finally {
      setSaving(false)
    }
  }

  const startEdit = (cat) => {
    setEditId(cat.id)
    setEditCat({ name_pt: cat.name_pt, name_en: cat.name_en || '', slug: cat.slug, color: cat.color, sort_order: cat.sort_order })
    setError('')
  }

  const handleUpdate = async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)
    try {
      const result = await updateScientificCategory(editId, editCat)
      if (result.success) {
        setEditId(null)
        router.refresh()
      } else {
        setError(result.error)
      }
    } catch {
      setError('Erro ao atualizar categoria.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Categorias Científicas</h1>
        <p className="admin-page-subtitle">Gerir as categorias dos artigos científicos (adicionar novas ao longo do tempo)</p>
      </div>

      <div className="admin-dashboard-card" style={{ marginBottom: 16 }}>
        <h3 style={{ marginBottom: 12 }}>Adicionar Categoria</h3>
        <form onSubmit={handleCreate} className="admin-form">
          <div className="admin-form-grid">
            <div className="admin-form-group">
              <label>Nome (PT)</label>
              <input type="text" value={newCat.name_pt} required
                onChange={(e) => handleNewName(e.target.value)} className="admin-input" placeholder="Farmacologia Clínica" />
            </div>
            <div className="admin-form-group">
              <label>Nome (EN)</label>
              <input type="text" value={newCat.name_en}
                onChange={(e) => setNewCat((prev) => ({ ...prev, name_en: e.target.value }))}
                className="admin-input" placeholder="Clinical Pharmacology" />
            </div>
            <div className="admin-form-group">
              <label>Slug</label>
              <input type="text" value={newCat.slug} required
                onChange={(e) => { setNewCat((prev) => ({ ...prev, slug: e.target.value })); setSlugEdited(true) }}
                className="admin-input" placeholder="farmacologia-clinica" />
            </div>
            <div className="admin-form-group">
              <label>Cor</label>
              <input type="text" value={newCat.color} required
                onChange={(e) => setNewCat((prev) => ({ ...prev, color: e.target.value }))}
                className="admin-input" placeholder="#0a844f" />
            </div>
            <div className="admin-form-group">
              <label>Ordem</label>
              <input type="number" value={newCat.sort_order}
                onChange={(e) => setNewCat((prev) => ({ ...prev, sort_order: parseInt(e.target.value, 10) || 0 }))}
                className="admin-input" />
            </div>
          </div>
          {error && <div className="admin-error-message" style={{ display: 'block' }}>{error}</div>}
          <div className="admin-form-actions">
            <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}
              style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
              <Plus size={16} /> {saving ? 'A guardar...' : 'Adicionar Categoria'}
            </button>
          </div>
        </form>
      </div>

      <div className="admin-dashboard-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <h3>Categorias ({categories.length})</h3>
        </div>

        {categories.length === 0 ? (
          <p style={{ color: 'var(--admin-text-muted)', textAlign: 'center', padding: 40 }}>
            Nenhuma categoria criada
          </p>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Nome PT</th>
                  <th>Nome EN</th>
                  <th>Slug</th>
                  <th>Cor</th>
                  <th>Ordem</th>
                  <th>Ações</th>
                </tr>
              </thead>
              <tbody>
                {categories.map((cat) =>
                  editId === cat.id ? (
                    <tr key={cat.id}>
                      <td colSpan={6}>
                        <form onSubmit={handleUpdate} className="admin-form" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 120px 80px auto', gap: 8, alignItems: 'end' }}>
                          <div className="admin-form-group">
                            <label>Nome PT</label>
                            <input type="text" value={editCat.name_pt} required
                              onChange={(e) => setEditCat((prev) => ({ ...prev, name_pt: e.target.value }))}
                              className="admin-input" />
                          </div>
                          <div className="admin-form-group">
                            <label>Nome EN</label>
                            <input type="text" value={editCat.name_en}
                              onChange={(e) => setEditCat((prev) => ({ ...prev, name_en: e.target.value }))}
                              className="admin-input" />
                          </div>
                          <div className="admin-form-group">
                            <label>Slug</label>
                            <input type="text" value={editCat.slug}
                              onChange={(e) => setEditCat((prev) => ({ ...prev, slug: e.target.value }))}
                              className="admin-input" />
                          </div>
                          <div className="admin-form-group">
                            <label>Cor</label>
                            <input type="text" value={editCat.color}
                              onChange={(e) => setEditCat((prev) => ({ ...prev, color: e.target.value }))}
                              className="admin-input" />
                          </div>
                          <div className="admin-form-group">
                            <label>Ordem</label>
                            <input type="number" value={editCat.sort_order}
                              onChange={(e) => setEditCat((prev) => ({ ...prev, sort_order: parseInt(e.target.value, 10) || 0 }))}
                              className="admin-input" />
                          </div>
                          <div style={{ display: 'flex', gap: 6 }}>
                            <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
                              <Save size={14} />
                            </button>
                            <button type="button" className="admin-btn admin-btn-secondary" onClick={() => setEditId(null)}>
                              <X size={14} />
                            </button>
                          </div>
                        </form>
                      </td>
                    </tr>
                  ) : (
                    <tr key={cat.id}>
                      <td>{escapeHtml(cat.name_pt)}</td>
                      <td>{escapeHtml(cat.name_en || '-')}</td>
                      <td>{escapeHtml(cat.slug)}</td>
                      <td>
                        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
                          <span style={{ width: 16, height: 16, borderRadius: 4, background: cat.color, display: 'inline-block' }} />
                          {escapeHtml(cat.color)}
                        </span>
                      </td>
                      <td>{cat.sort_order}</td>
                      <td>
                        <div className="admin-actions">
                          <button type="button" className="admin-btn admin-btn-secondary" onClick={() => startEdit(cat)}>
                            <Pencil size={14} /> Editar
                          </button>
                          {currentUserRole === 'superadmin' && (
                            <button type="button" className="admin-btn admin-btn-danger"
                              onClick={() => setConfirmDelete(cat)}>
                              <Trash2 size={14} /> Eliminar
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  )
                )}
              </tbody>
            </table>
          </div>
        )}
      </div>

      <ConfirmModal
        isOpen={!!confirmDelete}
        onClose={() => setConfirmDelete(null)}
        onConfirm={async () => {
          if (!confirmDelete) return
          setSaving(true)
          try {
            const result = await deleteScientificCategory(confirmDelete.id)
            if (!result.success) alert(result.error)
            else router.refresh()
          } catch {
            alert('Erro ao eliminar categoria.')
          } finally {
            setSaving(false)
            setConfirmDelete(null)
          }
        }}
        title="Eliminar categoria?"
        message={`"${confirmDelete?.name_pt}" será removida. Categorias com artigos associados não podem ser eliminadas.`}
        confirmLabel="Eliminar"
        variant="danger"
        loading={saving}
      />
    </>
  )
}
