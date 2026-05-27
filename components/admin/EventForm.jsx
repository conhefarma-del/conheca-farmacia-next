'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Save, X } from 'lucide-react'
import ImageUpload from '@/components/admin/ImageUpload'
import HostEditor from '@/components/admin/HostEditor'
import { createEvent, updateEvent } from '@/lib/actions/content'

const CATEGORIES = [
  { value: 'workshop', label: 'Workshop' },
  { value: 'palestra', label: 'Palestra' },
  { value: 'congresso', label: 'Congresso' },
  { value: 'seminario', label: 'Seminário' },
  { value: 'outro', label: 'Outro' },
]

const TYPES = [
  { value: 'presencial', label: 'Presencial' },
  { value: 'online', label: 'Online' },
  { value: 'hibrido', label: 'Híbrido' },
]

function generateSlug(title) {
  return title.toLowerCase()
    .replace(/[àáâäãå]/g, 'a').replace(/[èéêë]/g, 'e')
    .replace(/[ìíîï]/g, 'i').replace(/[òóôöõ]/g, 'o')
    .replace(/[ùúûü]/g, 'u').replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

export default function EventForm({ mode = 'create', initialData = null, lang = 'pt' }) {
  const router = useRouter()
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const [title, setTitle] = useState(initialData?.title || '')
  const [slug, setSlug] = useState(initialData?.slug || '')
  const [slugEdited, setSlugEdited] = useState(!!initialData?.slug)
  const [category, setCategory] = useState(initialData?.category || '')
  const [status, setStatus] = useState(initialData?.status || 'draft')
  const [featured, setFeatured] = useState(initialData?.featured || false)
  const [excerpt, setExcerpt] = useState(initialData?.excerpt || '')
  const [date, setDate] = useState(initialData?.date || '')
  const [time, setTime] = useState(initialData?.time || '')
  const [endTime, setEndTime] = useState(initialData?.end_time || '')
  const [location, setLocation] = useState(initialData?.location || '')
  const [type, setType] = useState(initialData?.type || '')
  const [capacity, setCapacity] = useState(initialData?.capacity || '')
  const [registrationLink, setRegistrationLink] = useState(initialData?.registration_link || '')
  const [imageUrl, setImageUrl] = useState(initialData?.image_url || '')
  const [hosts, setHosts] = useState(initialData?.hosts || [])

  const handleTitleChange = useCallback((value) => {
    setTitle(value)
    if (!slugEdited) setSlug(generateSlug(value))
  }, [slugEdited])

  const handleSlugChange = useCallback((value) => {
    setSlug(value)
    setSlugEdited(true)
  }, [])

  const handleSubmit = useCallback(async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)

    const categoryLabel = CATEGORIES.find(c => c.value === category)?.label || category

    const formData = {
      title, slug, category, category_label: categoryLabel, status, featured,
      excerpt, date, time, end_time: endTime, location, type, capacity,
      registration_link: registrationLink, image_url: imageUrl, hosts,
    }

    try {
      const result = mode === 'edit' && initialData?.id
        ? await updateEvent(initialData.id, formData)
        : await createEvent(formData)

      if (result.success) {
        router.push(`/${lang}/admin/eventos`)
      } else {
        setError(result.error)
      }
    } catch {
      setError('Erro ao salvar evento.')
    } finally {
      setSaving(false)
    }
  }, [title, slug, category, status, featured, excerpt, date, time, endTime,
    location, type, capacity, registrationLink, imageUrl, hosts,
    mode, initialData, router, lang])

  return (
    <form onSubmit={handleSubmit} className="admin-card admin-form">
      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Título</label>
          <input type="text" value={title} onChange={(e) => handleTitleChange(e.target.value)}
            required className="admin-input" placeholder="Título do evento" />
        </div>
        <div className="admin-form-group">
          <label>Slug</label>
          <input type="text" value={slug} onChange={(e) => handleSlugChange(e.target.value)}
            required className="admin-input" placeholder="nome-do-evento" />
        </div>
        <div className="admin-form-group">
          <label>Categoria</label>
          <select value={category} onChange={(e) => setCategory(e.target.value)} required className="admin-input">
            <option value="">Selecione...</option>
            {CATEGORIES.map(c => <option key={c.value} value={c.value}>{c.label}</option>)}
          </select>
        </div>
        <div className="admin-form-group">
          <label>Status</label>
          <select value={status} onChange={(e) => setStatus(e.target.value)} required className="admin-input">
            <option value="draft">Rascunho</option>
            <option value="published">Publicado</option>
          </select>
        </div>
      </div>

      <div className="admin-form-group">
        <label className="admin-checkbox-label">
          <input type="checkbox" checked={featured} onChange={(e) => setFeatured(e.target.checked)} />
          <span>Destacar na página principal</span>
        </label>
      </div>

      <div className="admin-form-group">
        <label>Resumo/Excerto</label>
        <textarea value={excerpt} onChange={(e) => setExcerpt(e.target.value)}
          className="admin-textarea" style={{ minHeight: 100 }} placeholder="Breve resumo do evento" />
      </div>

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Data</label>
          <input type="date" value={date} onChange={(e) => setDate(e.target.value)}
            required className="admin-input" />
        </div>
        <div className="admin-form-group">
          <label>Hora de Início</label>
          <input type="time" value={time} onChange={(e) => setTime(e.target.value)}
            required className="admin-input" />
        </div>
        <div className="admin-form-group">
          <label>Hora de Fim</label>
          <input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)}
            className="admin-input" />
        </div>
        <div className="admin-form-group">
          <label>Local</label>
          <input type="text" value={location} onChange={(e) => setLocation(e.target.value)}
            className="admin-input" placeholder="Local do evento" />
        </div>
      </div>

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Tipo</label>
          <select value={type} onChange={(e) => setType(e.target.value)} required className="admin-input">
            <option value="">Selecione...</option>
            {TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
          </select>
        </div>
        <div className="admin-form-group">
          <label>Capacidade</label>
          <input type="number" value={capacity} onChange={(e) => setCapacity(e.target.value)}
            className="admin-input" placeholder="100" />
        </div>
        <div className="admin-form-group">
          <label>Link de Inscrição</label>
          <input type="url" value={registrationLink} onChange={(e) => setRegistrationLink(e.target.value)}
            className="admin-input" placeholder="https://..." />
        </div>
      </div>

      <ImageUpload value={imageUrl} onChange={setImageUrl} bucket="event-images" folder="events" label="Imagem" />

      <HostEditor hosts={hosts} onChange={setHosts} />

      {error && <div className="admin-error-message" style={{ display: 'block' }}>{error}</div>}

      <div className="admin-form-actions">
        <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
          <Save size={16} />
          {saving ? 'A guardar...' : mode === 'edit' ? 'Atualizar Evento' : 'Salvar Evento'}
        </button>
        <a href={`/${lang}/admin/eventos`} className="admin-btn admin-btn-secondary">
          <X size={16} /> Cancelar
        </a>
      </div>
    </form>
  )
}
