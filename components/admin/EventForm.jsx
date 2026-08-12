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
  const [featuredLangs, setFeaturedLangs] = useState(initialData?.featured_langs || [])
  const [excerpt, setExcerpt] = useState(initialData?.excerpt || '')
  const [date, setDate] = useState(initialData?.date || '')
  const [time, setTime] = useState(initialData?.time || '')
  const [endTime, setEndTime] = useState(initialData?.end_time || '')
  const [location, setLocation] = useState(initialData?.location || '')
  const [locationMapsUrl, setLocationMapsUrl] = useState(initialData?.location_maps_url || '')
  const [locationMapsEmbedUrl, setLocationMapsEmbedUrl] = useState(initialData?.location_maps_embed_url || '')
  const [type, setType] = useState(initialData?.type || '')
  const [capacity, setCapacity] = useState(initialData?.capacity || '')
  const [registrationLink, setRegistrationLink] = useState(initialData?.registration_link || '')
  const [imageUrl, setImageUrl] = useState(initialData?.image_url || '')
  const [hosts, setHosts] = useState(initialData?.hosts || [])

  // Campos de template de certificado
  const [certificadoCor, setCertificadoCor] = useState(initialData?.certificado_cor || '#00493A')
  const [certificadoTexto, setCertificadoTexto] = useState(
    initialData?.certificado_texto || 'Certificamos que o participante concluiu com aproveitamento.'
  )
  const [certificadoLogoUrl, setCertificadoLogoUrl] = useState(initialData?.certificado_logo_url || '')
  const [certificadoCargaHoraria, setCertificadoCargaHoraria] = useState(initialData?.certificado_carga_horaria || '')
  const [assinante1Nome, setAssinante1Nome] = useState(initialData?.certificado_assinante_1_nome || 'Conheça Farmácia')
  const [assinante1Cargo, setAssinante1Cargo] = useState(initialData?.certificado_assinante_1_cargo || 'Conheça Farmácia')
  const [assinante2Nome, setAssinante2Nome] = useState(initialData?.certificado_assinante_2_nome || '')
  const [assinante2Cargo, setAssinante2Cargo] = useState(initialData?.certificado_assinante_2_cargo || 'Ordem dos Farmacêuticos')

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
      title, slug, category, category_label: categoryLabel, status, featured_langs: featuredLangs,
      excerpt, date, time, end_time: endTime, location, location_maps_url: locationMapsUrl,
      location_maps_embed_url: locationMapsEmbedUrl, type, capacity,
      registration_link: registrationLink, image_url: imageUrl, hosts,
      // Campos de certificado
      certificado_cor: certificadoCor,
      certificado_texto: certificadoTexto,
      certificado_logo_url: certificadoLogoUrl || null,
      certificado_carga_horaria: certificadoCargaHoraria || null,
      certificado_assinante_1_nome: assinante1Nome,
      certificado_assinante_1_cargo: assinante1Cargo,
      certificado_assinante_2_nome: assinante2Nome || null,
      certificado_assinante_2_cargo: assinante2Cargo || null,
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
  }, [title, slug, category, status, featuredLangs, excerpt, date, time, endTime,
    location, locationMapsUrl, locationMapsEmbedUrl, type, capacity, registrationLink, imageUrl, hosts,
    certificadoCor, certificadoTexto, certificadoLogoUrl, certificadoCargaHoraria,
    assinante1Nome, assinante1Cargo, assinante2Nome, assinante2Cargo,
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
          <span style={{ marginRight: '0.5rem', fontWeight: 500 }}>Destacar na página principal:</span>
        </label>
        <div style={{ display: 'flex', gap: '1.25rem', flexWrap: 'wrap' }}>
          <label className="admin-checkbox-label">
            <input
              type="checkbox"
              checked={featuredLangs.includes('pt')}
              onChange={(e) => {
                const next = new Set(featuredLangs)
                if (e.target.checked) next.add('pt')
                else next.delete('pt')
                setFeaturedLangs([...next])
              }}
            />
            <span>PT</span>
          </label>
          <label className="admin-checkbox-label">
            <input
              type="checkbox"
              checked={featuredLangs.includes('en')}
              onChange={(e) => {
                const next = new Set(featuredLangs)
                if (e.target.checked) next.add('en')
                else next.delete('en')
                setFeaturedLangs([...next])
              }}
            />
            <span>EN</span>
          </label>
        </div>
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

      <div className="admin-form-group">
        <label>Link Google Maps (opcional)</label>
        <input type="url" value={locationMapsUrl} onChange={(e) => setLocationMapsUrl(e.target.value)}
          className="admin-input" placeholder="https://maps.app.goo.gl/... ou https://www.google.com/maps?q=..." />
        <small className="admin-field-hint" style={{ display: 'block', marginTop: 4, color: 'var(--admin-text-muted)', fontSize: 12 }}>
          Coloque aqui o link do Google Maps com a localização exata — os inscritos poderão abri-lo a partir da página do evento.
        </small>
      </div>

      <div className="admin-form-group">
        <label>Mapa embutido Google Maps (opcional)</label>
        <input type="url" value={locationMapsEmbedUrl} onChange={(e) => setLocationMapsEmbedUrl(e.target.value)}
          className="admin-input" placeholder="https://www.google.com/maps/embed?pb=..." />
        <small className="admin-field-hint" style={{ display: 'block', marginTop: 4, color: 'var(--admin-text-muted)', fontSize: 12 }}>
          Opcional — mostra um mapa interativo na página do evento. No Google Maps: <b>Partilhar → Incorporar um mapa</b> e copie o <code>src</code> do iframe (começa por <code>https://www.google.com/maps/embed?pb=...</code>).
        </small>
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

      {/* ===== Certificado de Participação ===== */}
      <div style={{ marginTop: 32, marginBottom: 16, borderTop: '1px solid var(--admin-border)', paddingTop: 24 }}>
        <h3 style={{ fontSize: 18, fontWeight: 700, marginBottom: 16, color: 'var(--admin-text)' }}>
          Certificado de Participação
        </h3>
        <p style={{ fontSize: 13, color: 'var(--admin-text-muted)', marginBottom: 16 }}>
          Personalize o template do certificado para este evento.
        </p>

        <div className="admin-form-grid">
          <div className="admin-form-group">
            <label>Cor do certificado (hex)</label>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <input
                type="color"
                value={certificadoCor}
                onChange={(e) => setCertificadoCor(e.target.value)}
                style={{ width: 40, height: 40, padding: 2, border: '1px solid var(--admin-border)', borderRadius: 6, cursor: 'pointer' }}
              />
              <input
                type="text"
                value={certificadoCor}
                onChange={(e) => setCertificadoCor(e.target.value)}
                className="admin-input"
                style={{ maxWidth: 120, fontFamily: 'monospace' }}
                placeholder="#00493A"
              />
            </div>
          </div>

          <div className="admin-form-group">
            <label>Logo URL (opcional)</label>
            <input
              type="url"
              value={certificadoLogoUrl}
              onChange={(e) => setCertificadoLogoUrl(e.target.value)}
              className="admin-input"
              placeholder="https://..."
            />
          </div>

          <div className="admin-form-group">
            <label>Carga horária (opcional)</label>
            <input
              type="text"
              value={certificadoCargaHoraria}
              onChange={(e) => setCertificadoCargaHoraria(e.target.value)}
              className="admin-input"
              placeholder="ex: 8 horas"
            />
          </div>
        </div>

        <div className="admin-form-group">
          <label>Texto do certificado</label>
          <textarea
            value={certificadoTexto}
            onChange={(e) => setCertificadoTexto(e.target.value)}
            className="admin-textarea"
            style={{ minHeight: 80 }}
            placeholder="Certificamos que o participante concluiu com aproveitamento."
          />
        </div>

        <div className="admin-form-grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
          <div className="admin-form-group">
            <label>Assinante 1 — Nome</label>
            <input
              type="text"
              value={assinante1Nome}
              onChange={(e) => setAssinante1Nome(e.target.value)}
              className="admin-input"
            />
          </div>
          <div className="admin-form-group">
            <label>Assinante 1 — Cargo</label>
            <input
              type="text"
              value={assinante1Cargo}
              onChange={(e) => setAssinante1Cargo(e.target.value)}
              className="admin-input"
            />
          </div>
          <div className="admin-form-group">
            <label>Assinante 2 — Nome (opcional)</label>
            <input
              type="text"
              value={assinante2Nome}
              onChange={(e) => setAssinante2Nome(e.target.value)}
              className="admin-input"
              placeholder="Deixe vazio para 1 assinante"
            />
          </div>
          <div className="admin-form-group">
            <label>Assinante 2 — Cargo (opcional)</label>
            <input
              type="text"
              value={assinante2Cargo}
              onChange={(e) => setAssinante2Cargo(e.target.value)}
              className="admin-input"
            />
          </div>
        </div>
      </div>

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
