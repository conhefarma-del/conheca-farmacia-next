'use client'

import { useState, useEffect } from 'react'
import { X, Save, Loader2 } from 'lucide-react'

export default function SchoolForm({ school, onSave, onClose }) {
  const [form, setForm] = useState({
    slug: '',
    name: '',
    location: '',
    status: 'published',
  })
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    if (school) {
      setForm({
        slug: school.slug || '',
        name: school.name || '',
        location: school.location || '',
        status: school.status || 'published',
      })
    } else {
      setForm({ slug: '', name: '', location: '', status: 'published' })
    }
  }, [school])

  const slugify = (str) =>
    str.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')

  const handleNameChange = (name) => {
    setForm((f) => ({
      ...f,
      name,
      slug: school ? f.slug : slugify(name),
    }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!form.name.trim() || !form.slug.trim()) return
    setSaving(true)
    setError('')
    try {
      await onSave(form)
      onClose()
    } catch (err) {
      setError(err.message || 'Erro ao guardar')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <div className="absolute inset-0 bg-black/30" onClick={onClose} />
      <div className="relative w-full max-w-lg bg-card border-l border-brand-divider shadow-xl overflow-y-auto">
        <div className="sticky top-0 bg-card border-b border-brand-divider px-6 py-4 flex items-center justify-between">
          <h2 className="text-lg font-bold text-brand-deep">
            {school ? 'Editar Escola' : 'Nova Escola'}
          </h2>
          <button onClick={onClose} className="text-brand-deep/40 hover:text-brand-deep">
            <X size={20} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-brand-deep mb-1">Nome *</label>
            <input
              type="text"
              value={form.name}
              onChange={(e) => handleNameChange(e.target.value)}
              className="w-full px-3 py-2 rounded-lg border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none text-brand-deep"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-brand-deep mb-1">Slug *</label>
            <input
              type="text"
              value={form.slug}
              onChange={(e) => setForm((f) => ({ ...f, slug: e.target.value }))}
              className="w-full px-3 py-2 rounded-lg border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none text-brand-deep font-mono text-sm"
              required
              pattern="[a-z0-9-]+"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-brand-deep mb-1">Localização</label>
            <input
              type="text"
              value={form.location}
              onChange={(e) => setForm((f) => ({ ...f, location: e.target.value }))}
              className="w-full px-3 py-2 rounded-lg border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none text-brand-deep"
              placeholder="Ex: Luanda, Angola"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-brand-deep mb-1">Estado</label>
            <select
              value={form.status}
              onChange={(e) => setForm((f) => ({ ...f, status: e.target.value }))}
              className="w-full px-3 py-2 rounded-lg border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none text-brand-deep"
            >
              <option value="published">Publicado</option>
              <option value="draft">Rascunho</option>
            </select>
          </div>

          {error && <p className="text-red-600 text-sm">{error}</p>}

          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 py-2 rounded-lg border border-brand-divider text-brand-deep hover:bg-brand-deep/5 transition-all"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={saving || !form.name.trim()}
              className="flex-1 py-2 rounded-lg bg-brand-accent text-white font-medium hover:bg-brand-accent/90 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
            >
              {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
              Guardar
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
