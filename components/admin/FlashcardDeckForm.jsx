'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Save, ArrowLeft } from 'lucide-react'
import { createFlashcardDeck, updateFlashcardDeck } from '@/lib/actions/flashcards'

function generateSlug(name) {
  return (name || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
}

/**
 * FlashcardDeckForm — criar/editar um deck de flashcards.
 * mode: 'create' | 'edit'
 */
export default function FlashcardDeckForm({ mode = 'create', initialData = null }) {
  const router = useRouter()
  const [form, setForm] = useState({
    name_pt: initialData?.name_pt || '',
    name_en: initialData?.name_en || '',
    description_pt: initialData?.description_pt || '',
    description_en: initialData?.description_en || '',
    atc_prefix: initialData?.atc_prefix || '',
    color: initialData?.color || '#0a844f',
    sort_order: initialData?.sort_order ?? 0,
    status: initialData?.status || 'draft',
  })
  const [slugEdited, setSlugEdited] = useState(false)
  const [slug, setSlug] = useState(initialData?.slug || '')
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const handleName = (value) => {
    setForm((f) => ({ ...f, name_pt: value }))
    if (!slugEdited && mode === 'create') setSlug(generateSlug(value))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)
    try {
      const payload = { ...form, slug }
      const res =
        mode === 'create'
          ? await createFlashcardDeck(payload)
          : await updateFlashcardDeck(initialData.id, payload)
      if (res.ok) {
        router.push(`/pt/admin/flashcards${mode === 'edit' ? '' : ''}`)
        router.refresh()
      } else {
        setError(res.error)
      }
    } catch {
      setError('Erro ao guardar o deck.')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div>
      <div className="admin-page-header">
        <h1 className="admin-page-title">{mode === 'create' ? 'Novo Deck' : 'Editar Deck'}</h1>
        <p className="admin-page-subtitle">
          {mode === 'create'
            ? 'Cria um deck — o prefixo ATC gera decks automáticos por grupo'
            : initialData?.name_pt}
        </p>
      </div>

      <Link href="/pt/admin/flashcards" className="admin-back-link">
        <ArrowLeft size={14} /> Voltar para os decks
      </Link>

      <form onSubmit={handleSubmit} className="admin-form">
        <div className="admin-form-grid">
          <div className="admin-form-field">
            <label className="admin-form-label">Nome (PT) *</label>
            <input
              className="admin-form-input"
              value={form.name_pt}
              onChange={(e) => handleName(e.target.value)}
              required
            />
          </div>
          <div className="admin-form-field">
            <label className="admin-form-label">Nome (EN)</label>
            <input
              className="admin-form-input"
              value={form.name_en}
              onChange={(e) => setForm((f) => ({ ...f, name_en: e.target.value }))}
            />
          </div>
          <div className="admin-form-field">
            <label className="admin-form-label">Slug</label>
            <input
              className="admin-form-input"
              value={slug}
              onChange={(e) => { setSlug(e.target.value); setSlugEdited(true) }}
              placeholder="anti-infeciosos"
            />
          </div>
          <div className="admin-form-field">
            <label className="admin-form-label">Prefixo ATC (opcional)</label>
            <input
              className="admin-form-input"
              value={form.atc_prefix}
              onChange={(e) => setForm((f) => ({ ...f, atc_prefix: e.target.value.toUpperCase() }))}
              placeholder="J01, C, N… (gera automaticamente os cartões)"
            />
          </div>
        </div>

        <div className="admin-form-field">
          <label className="admin-form-label">Descrição (PT)</label>
          <textarea
            className="admin-form-input"
            rows={3}
            value={form.description_pt}
            onChange={(e) => setForm((f) => ({ ...f, description_pt: e.target.value }))}
          />
        </div>
        <div className="admin-form-field">
          <label className="admin-form-label">Descrição (EN)</label>
          <textarea
            className="admin-form-input"
            rows={3}
            value={form.description_en}
            onChange={(e) => setForm((f) => ({ ...f, description_en: e.target.value }))}
          />
        </div>

        <div className="admin-form-grid">
          <div className="admin-form-field">
            <label className="admin-form-label">Cor</label>
            <input
              type="color"
              className="admin-form-input admin-color-input"
              value={form.color}
              onChange={(e) => setForm((f) => ({ ...f, color: e.target.value }))}
            />
          </div>
          <div className="admin-form-field">
            <label className="admin-form-label">Ordem</label>
            <input
              type="number"
              className="admin-form-input"
              value={form.sort_order}
              onChange={(e) => setForm((f) => ({ ...f, sort_order: Number(e.target.value) }))}
            />
          </div>
          <div className="admin-form-field">
            <label className="admin-form-label">Estado</label>
            <select
              className="admin-form-input"
              value={form.status}
              onChange={(e) => setForm((f) => ({ ...f, status: e.target.value }))}
            >
              <option value="draft">Rascunho</option>
              <option value="published">Publicado</option>
            </select>
          </div>
        </div>

        {error && <div className="admin-form-error">{error}</div>}

        <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
          <Save size={16} /> {saving ? 'A guardar…' : 'Guardar Deck'}
        </button>
      </form>
    </div>
  )
}
