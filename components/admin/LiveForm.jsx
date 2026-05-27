'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Save, X } from 'lucide-react'
import ImageUpload from '@/components/admin/ImageUpload'
import { createLive, updateLive } from '@/lib/actions/content'

const CATEGORIES = [
  { value: 'live', label: 'Live' },
  { value: 'webinar', label: 'Webinar' },
  { value: 'entrevista', label: 'Entrevista' },
]

function generateSlug(title) {
  return title.toLowerCase()
    .replace(/[àáâäãå]/g, 'a').replace(/[èéêë]/g, 'e')
    .replace(/[ìíîï]/g, 'i').replace(/[òóôöõ]/g, 'o')
    .replace(/[ùúûü]/g, 'u').replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

export default function LiveForm({ mode = 'create', initialData = null, lang = 'pt' }) {
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
  const [platform, setPlatform] = useState(initialData?.platform || '')
  const [accessLink, setAccessLink] = useState(initialData?.access_link || '')
  const [meetingId, setMeetingId] = useState(initialData?.meeting_id || '')
  const [password, setPassword] = useState(initialData?.password || '')
  const [materials, setMaterials] = useState(
    initialData?.materials ? JSON.stringify(initialData.materials, null, 2) : ''
  )
  const [hostName, setHostName] = useState(initialData?.host_name || '')
  const [hostRole, setHostRole] = useState(initialData?.host_role || '')
  const [hostOrg, setHostOrg] = useState(initialData?.host_organization || '')
  const [imageUrl, setImageUrl] = useState(initialData?.image_url || '')

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
      excerpt, date, time, end_time: endTime, platform,
      access_link: accessLink, meeting_id: meetingId, password,
      materials, host_name: hostName, host_role: hostRole,
      host_organization: hostOrg, image_url: imageUrl,
    }

    try {
      const result = mode === 'edit' && initialData?.id
        ? await updateLive(initialData.id, formData)
        : await createLive(formData)

      if (result.success) {
        router.push(`/${lang}/admin/lives`)
      } else {
        setError(result.error)
      }
    } catch {
      setError('Erro ao salvar live.')
    } finally {
      setSaving(false)
    }
  }, [title, slug, category, status, featured, excerpt, date, time, endTime,
    platform, accessLink, meetingId, password, materials, hostName, hostRole,
    hostOrg, imageUrl, mode, initialData, router, lang])

  return (
    <form onSubmit={handleSubmit} className="admin-card admin-form">
      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Título</label>
          <input type="text" value={title} onChange={(e) => handleTitleChange(e.target.value)}
            required className="admin-input" placeholder="Título da live" />
        </div>
        <div className="admin-form-group">
          <label>Slug</label>
          <input type="text" value={slug} onChange={(e) => handleSlugChange(e.target.value)}
            required className="admin-input" placeholder="nome-da-live" />
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
          className="admin-textarea" style={{ minHeight: 100 }} placeholder="Breve resumo da live" />
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
          <label>Plataforma</label>
          <input type="text" value={platform} onChange={(e) => setPlatform(e.target.value)}
            className="admin-input" placeholder="YouTube Live, Zoom, Google Meet..." />
        </div>
      </div>

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Link de Acesso</label>
          <input type="url" value={accessLink} onChange={(e) => setAccessLink(e.target.value)}
            className="admin-input" placeholder="https://..." />
        </div>
        <div className="admin-form-group">
          <label>ID da Reunião</label>
          <input type="text" value={meetingId} onChange={(e) => setMeetingId(e.target.value)}
            className="admin-input" placeholder="ID da reunião (se aplicável)" />
        </div>
        <div className="admin-form-group">
          <label>Senha</label>
          <input type="password" value={password} onChange={(e) => setPassword(e.target.value)}
            className="admin-input" placeholder="Senha de acesso (se aplicável)" />
        </div>
      </div>

      <div className="admin-form-group">
        <label>Materiais de Apoio (JSON Array)</label>
        <textarea value={materials} onChange={(e) => setMaterials(e.target.value)}
          className="admin-textarea" style={{ minHeight: 80 }}
          placeholder='["https://exemplo.com/material1.pdf", "https://exemplo.com/material2.pdf"]' />
        <small className="admin-hint" style={{ color: 'var(--admin-text-muted)', fontSize: 12 }}>
          Formato JSON Array de URLs
        </small>
      </div>

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Nome do Anfitrião</label>
          <input type="text" value={hostName} onChange={(e) => setHostName(e.target.value)}
            className="admin-input" placeholder="Nome completo" />
        </div>
        <div className="admin-form-group">
          <label>Cargo/Função</label>
          <input type="text" value={hostRole} onChange={(e) => setHostRole(e.target.value)}
            className="admin-input" placeholder="Farmacêutico · Palestrante" />
        </div>
        <div className="admin-form-group">
          <label>Organização</label>
          <input type="text" value={hostOrg} onChange={(e) => setHostOrg(e.target.value)}
            className="admin-input" placeholder="Nome da organização" />
        </div>
      </div>

      <ImageUpload value={imageUrl} onChange={setImageUrl} bucket="live-images" folder="lives" label="Imagem" />

      {error && <div className="admin-error-message" style={{ display: 'block' }}>{error}</div>}

      <div className="admin-form-actions">
        <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
          <Save size={16} />
          {saving ? 'A guardar...' : mode === 'edit' ? 'Atualizar Live' : 'Salvar Live'}
        </button>
        <a href={`/${lang}/admin/lives`} className="admin-btn admin-btn-secondary">
          <X size={16} /> Cancelar
        </a>
      </div>
    </form>
  )
}
