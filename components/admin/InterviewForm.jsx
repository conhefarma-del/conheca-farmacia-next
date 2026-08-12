'use client'

import { useState, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import { Save, X, Plus, Trash2 } from 'lucide-react'
import { createInterview, updateInterview } from '@/lib/actions/content'

const CATEGORIES = [
  { value: 'profissionais', label: 'Profissionais', color: '#ff6c23' },
  { value: 'lideres', label: 'Líderes', color: '#0a844f' },
  { value: 'educadores', label: 'Educadores', color: '#002a32' },
  { value: 'investigadores', label: 'Investigadores', color: '#006171' },
]

function generateSlug(title) {
  return title.toLowerCase()
    .replace(/[àáâäãå]/g, 'a').replace(/[èéêë]/g, 'e')
    .replace(/[ìíîï]/g, 'i').replace(/[òóôöõ]/g, 'o')
    .replace(/[ùúûü]/g, 'u').replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')
}

/**
 * Extrai o ID de vídeo do YouTube a partir de um link completo ou ID puro.
 * Suporta: youtube.com/watch?v=, youtu.be/, /embed/, /shorts/, /live/ e ID
 * simples (11 caracteres). Devolve null se não reconhecer nenhum formato.
 */
function extractYouTubeId(value) {
  if (!value) return ''
  const v = String(value).trim()
  if (!v) return ''

  // ID puro: 11 caracteres [A-Za-z0-9_-]
  if (/^[A-Za-z0-9_-]{11}$/.test(v)) return v

  // Links com parâmetro v= (watch, short, etc.) ou path direto
  const m = v.match(/(?:youtube(?:-nocookie)?\.com\/(?:watch\?.*v=|embed\/|shorts\/|live\/|v\/)|youtu\.be\/)([A-Za-z0-9_-]{11})/)
  if (m) return m[1]

  // watch com v= antes do domain (ex.: https://www.youtube.com/watch?v=...) já
  // coberto acima; fallback final: qualquer v= no URL
  const vParam = v.match(/[?&]v=([A-Za-z0-9_-]{11})/)
  if (vParam) return vParam[1]

  return ''
}

export default function InterviewForm({ mode = 'create', initialData = null, lang = 'pt' }) {
  const router = useRouter()
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const [title, setTitle] = useState(initialData?.title || '')
  const [slug, setSlug] = useState(initialData?.slug || '')
  const [slugEdited, setSlugEdited] = useState(!!initialData?.slug)
  const [category, setCategory] = useState(initialData?.category || '')
  const [status, setStatus] = useState(initialData?.status || 'draft')
  const [featured, setFeatured] = useState(Boolean(initialData?.featured))
  const [excerpt, setExcerpt] = useState(initialData?.excerpt || '')
  const [metaDescription, setMetaDescription] = useState(initialData?.meta_description || '')
  const [date, setDate] = useState(initialData?.date || '')
  const [readTime, setReadTime] = useState(initialData?.read_time || '')
  const [videoDuration, setVideoDuration] = useState(initialData?.video_duration || '')
  const [videoId, setVideoId] = useState(initialData?.video_id || '')
  const [videoInput, setVideoInput] = useState(
    initialData?.video_id
      ? `https://www.youtube.com/watch?v=${initialData.video_id}`
      : ''
  )
  const [videoInputValid, setVideoInputValid] = useState(true)
  const [thumbnailUrl, setThumbnailUrl] = useState(initialData?.thumbnail_url || '')
  const [audioUrl, setAudioUrl] = useState(initialData?.audio_url || '')
  const [executiveSummary, setExecutiveSummary] = useState(initialData?.executive_summary || '')
  const [content, setContent] = useState(initialData?.content || '')

  const [interviewee, setInterviewee] = useState({
    name: initialData?.interviewee?.name || '',
    role: initialData?.interviewee?.role || '',
    bio: initialData?.interviewee?.bio || '',
    avatar: initialData?.interviewee?.avatar || '',
    avatarBg: initialData?.interviewee?.avatarBg || '#00493a',
  })
  const [interviewer, setInterviewer] = useState({
    name: initialData?.interviewer?.name || '',
    role: initialData?.interviewer?.role || '',
    avatar: initialData?.interviewer?.avatar || '',
    avatarBg: initialData?.interviewer?.avatarBg || '#0a844f',
  })

  const [pullQuotes, setPullQuotes] = useState(
    Array.isArray(initialData?.pull_quotes) && initialData.pull_quotes.length > 0
      ? initialData.pull_quotes
      : ['']
  )
  const [qa, setQa] = useState(
    Array.isArray(initialData?.qa) && initialData.qa.length > 0
      ? initialData.qa
      : [{ question: '', answer: '' }]
  )
  const [references, setReferences] = useState(
    Array.isArray(initialData?.references_arr) && initialData.references_arr.length > 0
      ? initialData.references_arr
      : ['']
  )
  const [related, setRelated] = useState(
    Array.isArray(initialData?.related) && initialData.related.length > 0
      ? initialData.related
      : ['']
  )

  const handleTitleChange = useCallback((value) => {
    setTitle(value)
    if (!slugEdited) setSlug(generateSlug(value))
  }, [slugEdited])

  const handleSlugChange = useCallback((value) => {
    setSlug(value)
    setSlugEdited(true)
  }, [])

  const updateList = useCallback((setter) => (index, value) => {
    setter((prev) => prev.map((item, i) => (i === index ? value : item)))
  }, [])

  const handleSubmit = useCallback(async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)

    const categoryLabel = CATEGORIES.find(c => c.value === category)?.label || category

    const formData = {
      title, slug, category, category_label: categoryLabel, status, featured,
      excerpt, meta_description: metaDescription, date,
      read_time: readTime, video_duration: videoDuration,
      video_id: videoId, thumbnail_url: thumbnailUrl, audio_url: audioUrl,
      executive_summary: executiveSummary, content,
      interviewee, interviewer,
      pull_quotes: pullQuotes.filter(q => q.trim()),
      qa: qa.filter(item => item.question.trim() || item.answer.trim()),
      references_arr: references.filter(r => r.trim()),
      related: related.filter(r => r.trim()),
    }

    try {
      const result = mode === 'edit' && initialData?.id
        ? await updateInterview(initialData.id, formData)
        : await createInterview(formData)

      if (result.success) {
        router.push(`/${lang}/admin/entrevistas`)
      } else {
        setError(result.error)
      }
    } catch {
      setError('Erro ao salvar entrevista.')
    } finally {
      setSaving(false)
    }
  }, [title, slug, category, status, featured, excerpt, metaDescription, date,
    readTime, videoDuration, videoId, thumbnailUrl, audioUrl, executiveSummary, content,
    interviewee, interviewer, pullQuotes, qa, references, related,
    mode, initialData, router, lang])

  return (
    <form onSubmit={handleSubmit} className="admin-card admin-form">
      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Título</label>
          <input type="text" value={title} onChange={(e) => handleTitleChange(e.target.value)}
            required className="admin-input" placeholder="Título da entrevista" />
        </div>
        <div className="admin-form-group">
          <label>Slug</label>
          <input type="text" value={slug} onChange={(e) => handleSlugChange(e.target.value)}
            required className="admin-input" placeholder="nome-da-entrevista" />
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
          <span>Destacar (featured)</span>
        </label>
      </div>

      <div className="admin-form-group">
        <label>Excerto</label>
        <textarea value={excerpt} onChange={(e) => setExcerpt(e.target.value)}
          className="admin-textarea" style={{ minHeight: 80 }} placeholder="Breve resumo da entrevista (mostrado nos cards)" />
      </div>

      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Data</label>
          <input type="date" value={date} onChange={(e) => setDate(e.target.value)}
            required className="admin-input" />
        </div>
        <div className="admin-form-group">
          <label>Tempo de leitura (min)</label>
          <input type="number" value={readTime} onChange={(e) => setReadTime(e.target.value)}
            className="admin-input" placeholder="24" />
        </div>
        <div className="admin-form-group">
          <label>Duração do vídeo</label>
          <input type="text" value={videoDuration} onChange={(e) => setVideoDuration(e.target.value)}
            className="admin-input" placeholder="24:18" />
        </div>
        <div className="admin-form-group">
          <label>Meta description</label>
          <input type="text" value={metaDescription} onChange={(e) => setMetaDescription(e.target.value)}
            className="admin-input" placeholder="SEO description (opcional)" maxLength={170} />
        </div>
      </div>

      {/* Vídeo */}
      <div className="admin-form-grid">
        <div className="admin-form-group">
          <label>Vídeo do YouTube (link ou ID)</label>
          <input
            type="text"
            value={videoInput}
            onChange={(e) => {
              const raw = e.target.value
              setVideoInput(raw)
              const extracted = extractYouTubeId(raw)
              setVideoInputValid(!raw.trim() || Boolean(extracted))
              setVideoId(extracted)
            }}
            className="admin-input"
            placeholder="https://www.youtube.com/watch?v=dQw4w9WgXcQ ou só dQw4w9WgXcQ (opcional)"
          />
          {!videoInputValid && (
            <p style={{ color: '#b45309', fontSize: 12, marginTop: 6 }}>
              Não reconhecido como link do YouTube. Cola o link normal (watch/youtu.be/embed/shorts) ou só o ID de 11 caracteres.
            </p>
          )}
          {videoId && videoInputValid && (
            <p style={{ color: 'var(--admin-text-muted)', fontSize: 12, marginTop: 6 }}>
              ID detetado: <code style={{ fontFamily: 'monospace' }}>{videoId}</code>
            </p>
          )}
        </div>
        <div className="admin-form-group">
          <label>Thumbnail URL</label>
          <input type="url" value={thumbnailUrl} onChange={(e) => setThumbnailUrl(e.target.value)}
            className="admin-input" placeholder="https://img.youtube.com/vi/.../hqdefault.jpg (opcional)" />
        </div>
        <div className="admin-form-group">
          <label>Áudio URL</label>
          <input type="url" value={audioUrl} onChange={(e) => setAudioUrl(e.target.value)}
            className="admin-input" placeholder="https://... (opcional)" />
        </div>
      </div>

      {/* Preview do vídeo — ao vivo, para validar o ID antes de guardar */}
      {videoId && videoInputValid && (
        <div className="admin-video-preview" style={{ maxWidth: 480, marginTop: 12 }}>
          <iframe
            src={`https://www.youtube.com/embed/${videoId}`}
            title="Pré-visualização do vídeo da entrevista"
            width="100%"
            height="270"
            style={{ border: 0 }}
            loading="lazy"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
            referrerPolicy="strict-origin-when-cross-origin"
          />
        </div>
      )}

      {/* Entrevistado */}
      <div style={{ marginTop: 24, marginBottom: 16, borderTop: '1px solid var(--admin-border)', paddingTop: 20 }}>
        <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 12, color: 'var(--admin-text)' }}>Entrevistado</h3>
        <div className="admin-form-grid">
          <div className="admin-form-group"><label>Nome</label>
            <input type="text" value={interviewee.name} onChange={(e) => setInterviewee({ ...interviewee, name: e.target.value })} className="admin-input" /></div>
          <div className="admin-form-group"><label>Cargo</label>
            <input type="text" value={interviewee.role} onChange={(e) => setInterviewee({ ...interviewee, role: e.target.value })} className="admin-input" placeholder="Farmacêutica Clínica · Hospital Nacional" /></div>
          <div className="admin-form-group"><label>Avatar (iniciais)</label>
            <input type="text" value={interviewee.avatar} onChange={(e) => setInterviewee({ ...interviewee, avatar: e.target.value })} className="admin-input" placeholder="AS" maxLength={2} /></div>
          <div className="admin-form-group"><label>Cor do avatar (hex)</label>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <input type="color" value={interviewee.avatarBg} onChange={(e) => setInterviewee({ ...interviewee, avatarBg: e.target.value })} style={{ width: 40, height: 40, padding: 2, border: '1px solid var(--admin-border)', borderRadius: 6, cursor: 'pointer' }} />
              <input type="text" value={interviewee.avatarBg} onChange={(e) => setInterviewee({ ...interviewee, avatarBg: e.target.value })} className="admin-input" style={{ maxWidth: 100, fontFamily: 'monospace' }} />
            </div>
          </div>
          <div className="admin-form-group" style={{ gridColumn: '1 / -1' }}><label>Bio</label>
            <input type="text" value={interviewee.bio} onChange={(e) => setInterviewee({ ...interviewee, bio: e.target.value })} className="admin-input" /></div>
        </div>
      </div>

      {/* Entrevistador */}
      <div style={{ marginBottom: 16 }}>
        <h3 style={{ fontSize: 16, fontWeight: 700, marginBottom: 12, color: 'var(--admin-text)' }}>Entrevistador</h3>
        <div className="admin-form-grid">
          <div className="admin-form-group"><label>Nome</label>
            <input type="text" value={interviewer.name} onChange={(e) => setInterviewer({ ...interviewer, name: e.target.value })} className="admin-input" /></div>
          <div className="admin-form-group"><label>Cargo</label>
            <input type="text" value={interviewer.role} onChange={(e) => setInterviewer({ ...interviewer, role: e.target.value })} className="admin-input" placeholder="Editor · Conheça Farmácia" /></div>
          <div className="admin-form-group"><label>Avatar (iniciais)</label>
            <input type="text" value={interviewer.avatar} onChange={(e) => setInterviewer({ ...interviewer, avatar: e.target.value })} className="admin-input" placeholder="JS" maxLength={2} /></div>
          <div className="admin-form-group"><label>Cor do avatar (hex)</label>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <input type="color" value={interviewer.avatarBg} onChange={(e) => setInterviewer({ ...interviewer, avatarBg: e.target.value })} style={{ width: 40, height: 40, padding: 2, border: '1px solid var(--admin-border)', borderRadius: 6, cursor: 'pointer' }} />
              <input type="text" value={interviewer.avatarBg} onChange={(e) => setInterviewer({ ...interviewer, avatarBg: e.target.value })} className="admin-input" style={{ maxWidth: 100, fontFamily: 'monospace' }} />
            </div>
          </div>
        </div>
      </div>

      {/* Sumário executivo + Conteúdo */}
      <div className="admin-form-group">
        <label>Sumário executivo</label>
        <textarea value={executiveSummary} onChange={(e) => setExecutiveSummary(e.target.value)}
          className="admin-textarea" style={{ minHeight: 90 }} placeholder="Resumo no topo do artigo" />
      </div>

      <div className="admin-form-group">
        <label>Conteúdo (parágrafos separados por linha em branco)</label>
        <textarea value={content} onChange={(e) => setContent(e.target.value)}
          className="admin-textarea" style={{ minHeight: 160 }} placeholder="Texto completo da entrevista..." />
      </div>

      {/* Pull quotes */}
      <div className="admin-form-group">
        <label>Pull quotes</label>
        {pullQuotes.map((q, i) => (
          <div key={i} style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
            <input type="text" value={q} onChange={(e) => updateList(setPullQuotes)(i, e.target.value)}
              className="admin-input" placeholder="Citação em destaque" />
            <button type="button" className="admin-btn admin-btn-sm admin-btn-danger"
              onClick={() => setPullQuotes(pullQuotes.filter((_, idx) => idx !== i))}>
              <Trash2 size={14} />
            </button>
          </div>
        ))}
        <button type="button" className="admin-btn admin-btn-sm" onClick={() => setPullQuotes([...pullQuotes, ''])}>
          <Plus size={14} /> Adicionar pull quote
        </button>
      </div>

      {/* Q&A */}
      <div className="admin-form-group">
        <label>Perguntas e Respostas</label>
        {qa.map((item, i) => (
          <div key={i} className="admin-qa-row" style={{ border: '1px solid var(--admin-border)', borderRadius: 8, padding: 12, marginBottom: 10 }}>
            <input type="text" value={item.question} onChange={(e) => updateList(setQa)(i, { ...item, question: e.target.value })}
              className="admin-input" placeholder="Pergunta" style={{ marginBottom: 8 }} />
            <textarea value={item.answer} onChange={(e) => updateList(setQa)(i, { ...item, answer: e.target.value })}
              className="admin-textarea" style={{ minHeight: 60 }} placeholder="Resposta" />
            <button type="button" className="admin-btn admin-btn-sm admin-btn-danger"
              style={{ marginTop: 8 }} onClick={() => setQa(qa.filter((_, idx) => idx !== i))}>
              <Trash2 size={14} /> Remover
            </button>
          </div>
        ))}
        <button type="button" className="admin-btn admin-btn-sm" onClick={() => setQa([...qa, { question: '', answer: '' }])}>
          <Plus size={14} /> Adicionar pergunta
        </button>
      </div>

      {/* Referências */}
      <div className="admin-form-group">
        <label>Referências (uma por linha)</label>
        {references.map((r, i) => (
          <div key={i} style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
            <input type="text" value={r} onChange={(e) => updateList(setReferences)(i, e.target.value)}
              className="admin-input" placeholder="Fonte / referência" />
            <button type="button" className="admin-btn admin-btn-sm admin-btn-danger"
              onClick={() => setReferences(references.filter((_, idx) => idx !== i))}>
              <Trash2 size={14} />
            </button>
          </div>
        ))}
        <button type="button" className="admin-btn admin-btn-sm" onClick={() => setReferences([...references, ''])}>
          <Plus size={14} /> Adicionar referência
        </button>
      </div>

      {/* Relacionadas */}
      <div className="admin-form-group">
        <label>Relacionadas (slugs, uma por linha)</label>
        {related.map((r, i) => (
          <div key={i} style={{ display: 'flex', gap: 8, marginBottom: 8 }}>
            <input type="text" value={r} onChange={(e) => updateList(setRelated)(i, e.target.value)}
              className="admin-input" placeholder="slug-de-outra-entrevista" />
            <button type="button" className="admin-btn admin-btn-sm admin-btn-danger"
              onClick={() => setRelated(related.filter((_, idx) => idx !== i))}>
              <Trash2 size={14} />
            </button>
          </div>
        ))}
        <button type="button" className="admin-btn admin-btn-sm" onClick={() => setRelated([...related, ''])}>
          <Plus size={14} /> Adicionar slug
        </button>
      </div>

      {error && <div className="admin-error-message" style={{ display: 'block' }}>{error}</div>}

      <div className="admin-form-actions">
        <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
          <Save size={16} />
          {saving ? 'A guardar...' : mode === 'edit' ? 'Atualizar Entrevista' : 'Salvar Entrevista'}
        </button>
        <a href={`/${lang}/admin/entrevistas`} className="admin-btn admin-btn-secondary">
          <X size={16} /> Cancelar
        </a>
      </div>
    </form>
  )
}
