'use client'

import { useState } from 'react'
import { Save, X, Plus, Trash2, CheckCircle, XCircle } from 'lucide-react'
import {
  createGuideDiscipline,
  updateGuideDiscipline,
  deleteGuideDiscipline,
  createGuideBook,
  updateGuideBook,
  deleteGuideBook,
  createGuideResource,
  updateGuideResource,
  deleteGuideResource,
} from '@/lib/actions/guides'

const inputStyle = {
  width: '100%',
  padding: '8px 12px',
  border: '1px solid #d1d5db',
  borderRadius: 8,
  fontSize: 13,
  fontFamily: 'Inter, sans-serif',
  outline: 'none',
  background: '#fff',
  color: '#111827',
}
const labelStyle = {
  display: 'block',
  fontSize: 12,
  fontWeight: 600,
  color: '#374151',
  marginBottom: 4,
  textTransform: 'uppercase',
  letterSpacing: '0.04em',
}
const cardStyle = {
  border: '1px solid #e5e7eb',
  borderRadius: 8,
  padding: 14,
  marginBottom: 10,
  background: '#f9fafb',
}

function BookEditor({ book, onChange, onRemove }) {
  const set = (field, value) => onChange(field, value)
  const setLink = (idx, field, value) => {
    const links = [...(book.links || [])]
    links[idx] = { ...links[idx], [field]: value }
    set('links', links)
  }
  return (
    <div style={cardStyle}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', letterSpacing: '0.04em' }}>Livro</span>
        <button type="button" onClick={onRemove} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#dc2626' }} title="Remover livro">
          <Trash2 size={16} />
        </button>
      </div>
      <div style={{ display: 'flex', gap: 10, marginBottom: 8 }}>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Título PT *</label>
          <input type="text" value={book.title_pt || ''} onChange={(e) => set('title_pt', e.target.value)} style={inputStyle} />
        </div>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Title EN *</label>
          <input type="text" value={book.title_en || ''} onChange={(e) => set('title_en', e.target.value)} style={inputStyle} />
        </div>
      </div>
      <div style={{ display: 'flex', gap: 10, marginBottom: 8 }}>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Autor</label>
          <input type="text" value={book.author || ''} onChange={(e) => set('author', e.target.value)} style={inputStyle} />
        </div>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Edição</label>
          <input type="text" value={book.edition || ''} onChange={(e) => set('edition', e.target.value)} style={inputStyle} />
        </div>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Ano</label>
          <input type="number" value={book.year || ''} onChange={(e) => set('year', e.target.value === '' ? null : parseInt(e.target.value, 10))} style={inputStyle} />
        </div>
      </div>
      <div style={{ marginBottom: 8 }}>
        <label style={labelStyle}>URL da Capa (https:// ou /relativo)</label>
        <input type="text" value={book.cover_url || ''} onChange={(e) => set('cover_url', e.target.value)} style={inputStyle} />
      </div>
      <div style={{ marginBottom: 8 }}>
        <label style={labelStyle}>Nota da Equipa PT</label>
        <textarea value={book.team_paragraph_pt || ''} onChange={(e) => set('team_paragraph_pt', e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 48, lineHeight: 1.4 }} rows={2} />
      </div>
      <div style={{ marginBottom: 8 }}>
        <label style={labelStyle}>Team Note EN</label>
        <textarea value={book.team_paragraph_en || ''} onChange={(e) => set('team_paragraph_en', e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 48, lineHeight: 1.4 }} rows={2} />
      </div>
      <div style={{ marginBottom: 8 }}>
        <label style={labelStyle}>Links externos</label>
        {(book.links || []).map((link, i) => (
          <div key={i} style={{ display: 'flex', gap: 6, marginBottom: 6, alignItems: 'center' }}>
            <input type="text" placeholder="Label PT" value={link.label_pt || ''} onChange={(e) => setLink(i, 'label_pt', e.target.value)} style={{ ...inputStyle, flex: 1 }} />
            <input type="text" placeholder="Label EN" value={link.label_en || ''} onChange={(e) => setLink(i, 'label_en', e.target.value)} style={{ ...inputStyle, flex: 1 }} />
            <input type="text" placeholder="https://..." value={link.url || ''} onChange={(e) => setLink(i, 'url', e.target.value)} style={{ ...inputStyle, flex: 1.5 }} />
            <button type="button" onClick={() => set('links', (book.links || []).filter((_, x) => x !== i))} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#dc2626' }} title="Remover link">
              <X size={14} />
            </button>
          </div>
        ))}
        <button
          type="button"
          onClick={() => set('links', [...(book.links || []), { label_pt: '', label_en: '', url: '' }])}
          style={{ background: 'none', border: '1px dashed #9ca3af', borderRadius: 6, padding: '6px 10px', fontSize: 12, color: '#4b5563', cursor: 'pointer' }}
        >
          + Adicionar Link
        </button>
      </div>
      <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
        <label style={{ ...labelStyle, marginBottom: 0, display: 'flex', alignItems: 'center', gap: 6, cursor: 'pointer', textTransform: 'none' }}>
          <input
            type="checkbox"
            checked={book.status === 'published'}
            onChange={(e) => set('status', e.target.checked ? 'published' : 'draft')}
          />
          {book.status === 'published' ? <CheckCircle size={14} style={{ color: '#166534' }} /> : <XCircle size={14} style={{ color: '#92400e' }} />}
          {book.status === 'published' ? 'Publicado' : 'Rascunho'}
        </label>
      </div>
    </div>
  )
}

function ResourceEditor({ resource, onChange, onRemove }) {
  return (
    <div style={cardStyle}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
        <span style={{ fontSize: 12, fontWeight: 700, color: '#6b7280', textTransform: 'uppercase', letterSpacing: '0.04em' }}>Recurso</span>
        <button type="button" onClick={onRemove} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#dc2626' }} title="Remover recurso">
          <Trash2 size={16} />
        </button>
      </div>
      <div style={{ display: 'flex', gap: 10, marginBottom: 8 }}>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Título PT *</label>
          <input type="text" value={resource.title_pt || ''} onChange={(e) => onChange('title_pt', e.target.value)} style={inputStyle} />
        </div>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Title EN *</label>
          <input type="text" value={resource.title_en || ''} onChange={(e) => onChange('title_en', e.target.value)} style={inputStyle} />
        </div>
      </div>
      <div style={{ marginBottom: 8 }}>
        <label style={labelStyle}>Descrição PT</label>
        <textarea value={resource.description_pt || ''} onChange={(e) => onChange('description_pt', e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 40, lineHeight: 1.4 }} rows={2} />
      </div>
      <div style={{ marginBottom: 8 }}>
        <label style={labelStyle}>Description EN</label>
        <textarea value={resource.description_en || ''} onChange={(e) => onChange('description_en', e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 40, lineHeight: 1.4 }} rows={2} />
      </div>
      <div style={{ display: 'flex', gap: 10, marginBottom: 8 }}>
        <div style={{ flex: 2 }}>
          <label style={labelStyle}>URL *</label>
          <input type="text" value={resource.url || ''} onChange={(e) => onChange('url', e.target.value)} style={inputStyle} placeholder="https://..." />
        </div>
        <div style={{ flex: 1 }}>
          <label style={labelStyle}>Tipo</label>
          <select value={resource.type || 'pdf'} onChange={(e) => onChange('type', e.target.value)} style={inputStyle}>
            <option value="pdf">PDF</option>
            <option value="guideline">Guideline</option>
            <option value="article">Artigo</option>
            <option value="other">Outro</option>
          </select>
        </div>
      </div>
      <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
        <label style={{ ...labelStyle, marginBottom: 0, display: 'flex', alignItems: 'center', gap: 6, cursor: 'pointer', textTransform: 'none' }}>
          <input
            type="checkbox"
            checked={resource.status === 'published'}
            onChange={(e) => onChange('status', e.target.checked ? 'published' : 'draft')}
          />
          {resource.status === 'published' ? <CheckCircle size={14} style={{ color: '#166534' }} /> : <XCircle size={14} style={{ color: '#92400e' }} />}
          {resource.status === 'published' ? 'Publicado' : 'Rascunho'}
        </label>
      </div>
    </div>
  )
}

/**
 * Slide-in panel para criar/editar uma disciplina, incluindo os livros
 * e recursos associados (CRUD aninhado, gravado na ordem: disciplina → livros/recursos).
 */
export default function GuideDisciplinaForm({ courseId, discipline, panelOpen, onClose, onSaved }) {
  const [slug, setSlug] = useState(discipline?.slug || '')
  const [namePt, setNamePt] = useState(discipline?.name_pt || '')
  const [nameEn, setNameEn] = useState(discipline?.name_en || '')
  const [descriptionPt, setDescriptionPt] = useState(discipline?.description_pt || '')
  const [descriptionEn, setDescriptionEn] = useState(discipline?.description_en || '')
  const [phasePt, setPhasePt] = useState(discipline?.phase_pt || '')
  const [phaseEn, setPhaseEn] = useState(discipline?.phase_en || '')
  const [importancePt, setImportancePt] = useState(discipline?.importance_pt || '')
  const [importanceEn, setImportanceEn] = useState(discipline?.importance_en || '')
  const [status, setStatus] = useState(discipline?.status === 'published' ? 'published' : 'draft')
  const [sortOrder, setSortOrder] = useState(discipline?.sort_order ?? 0)
  const [books, setBooks] = useState(
    (discipline?.guide_books || []).map((b) => ({ ...b, links: b.links || [] }))
  )
  const [deletedBooks, setDeletedBooks] = useState([])
  const [resources, setResources] = useState(discipline?.guide_resources || [])
  const [deletedResources, setDeletedResources] = useState([])
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const updateBook = (idx, field, value) => {
    setBooks((prev) => prev.map((b, i) => (i === idx ? { ...b, [field]: value } : b)))
  }
  const removeBook = (idx) => {
    const b = books[idx]
    if (b && b.id) setDeletedBooks((prev) => [...prev, b.id])
    setBooks((prev) => prev.filter((_, i) => i !== idx))
  }
  const updateResource = (idx, field, value) => {
    setResources((prev) => prev.map((r, i) => (i === idx ? { ...r, [field]: value } : r)))
  }
  const removeResource = (idx) => {
    const r = resources[idx]
    if (r && r.id) setDeletedResources((prev) => [...prev, r.id])
    setResources((prev) => prev.filter((_, i) => i !== idx))
  }

  const handleSave = async () => {
    if (!slug.trim()) return setError('O slug é obrigatório.')
    if (!namePt.trim()) return setError('O nome (PT) é obrigatório.')
    if (!nameEn.trim()) return setError('The name (EN) is required.')

    setSaving(true)
    setError(null)
    try {
      const disciplinePayload = {
        slug: slug.trim(),
        name_pt: namePt.trim(),
        name_en: nameEn.trim(),
        description_pt: descriptionPt,
        description_en: descriptionEn,
        phase_pt: phasePt,
        phase_en: phaseEn,
        importance_pt: importancePt,
        importance_en: importanceEn,
        status,
        sort_order: parseInt(sortOrder, 10) || 0,
      }

      let disciplineId = discipline?.id
      if (discipline) {
        const res = await updateGuideDiscipline(discipline.id, disciplinePayload)
        if (!res.success) return setError(res.error || 'Erro ao guardar disciplina.')
      } else {
        const res = await createGuideDiscipline(courseId, disciplinePayload)
        if (!res.success) return setError(res.error || 'Erro ao criar disciplina.')
        disciplineId = res.data.id
      }

      // Removidos
      for (const id of deletedBooks) await deleteGuideBook(id)
      for (const id of deletedResources) await deleteGuideResource(id)

      // Livros — criar novos / atualizar existentes
      for (let i = 0; i < books.length; i++) {
        const b = books[i]
        const payload = {
          title_pt: b.title_pt,
          title_en: b.title_en,
          author: b.author || '',
          edition: b.edition || '',
          year: b.year ?? null,
          cover_url: b.cover_url || '',
          team_paragraph_pt: b.team_paragraph_pt || '',
          team_paragraph_en: b.team_paragraph_en || '',
          links: (b.links || []).filter((l) => l.url && l.label_pt && l.label_en),
          status: b.status || 'draft',
          sort_order: i + 1,
        }
        if (b.id) {
          const res = await updateGuideBook(b.id, payload)
          if (!res.success) return setError(res.error || 'Erro ao guardar livro.')
        } else {
          const res = await createGuideBook(disciplineId, payload)
          if (!res.success) return setError(res.error || 'Erro ao criar livro.')
        }
      }

      // Recursos — criar novos / atualizar existentes
      for (let i = 0; i < resources.length; i++) {
        const r = resources[i]
        const payload = {
          title_pt: r.title_pt,
          title_en: r.title_en,
          description_pt: r.description_pt || '',
          description_en: r.description_en || '',
          url: r.url,
          type: r.type || 'pdf',
          status: r.status || 'draft',
          sort_order: i + 1,
        }
        if (r.id) {
          const res = await updateGuideResource(r.id, payload)
          if (!res.success) return setError(res.error || 'Erro ao guardar recurso.')
        } else {
          const res = await createGuideResource(disciplineId, payload)
          if (!res.success) return setError(res.error || 'Erro ao criar recurso.')
        }
      }

      onSaved({ success: true })
    } catch (err) {
      setError('Erro inesperado: ' + (err.message || 'desconhecido'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <div
        onClick={onClose}
        style={{
          position: 'fixed',
          inset: 0,
          zIndex: 999,
          background: panelOpen ? 'rgba(0, 42, 50, 0.45)' : 'rgba(0, 42, 50, 0)',
          backdropFilter: panelOpen ? 'blur(4px)' : 'blur(0px)',
          WebkitBackdropFilter: panelOpen ? 'blur(4px)' : 'blur(0px)',
          transition: 'all 250ms ease-out',
        }}
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-label={discipline ? 'Editar disciplina' : 'Nova disciplina'}
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 760,
          background: '#fff',
          boxShadow: panelOpen ? '-8px 0 40px rgba(0, 42, 50, 0.15)' : '-8px 0 40px rgba(0, 42, 50, 0)',
          transform: panelOpen ? 'translateX(0)' : 'translateX(100%)',
          transition: 'transform 250ms cubic-bezier(0.16, 1, 0.3, 1), box-shadow 250ms ease-out',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '20px 28px', borderBottom: '1px solid #e5e7eb', flexShrink: 0 }}>
          <h2 style={{ margin: 0, fontSize: 18, fontWeight: 600, color: '#002a32', fontFamily: 'Inter, sans-serif' }}>
            {discipline ? 'Editar Disciplina' : 'Nova Disciplina'}
          </h2>
          <button
            type="button"
            onClick={onClose}
            aria-label="Fechar"
            style={{ background: 'none', border: 'none', cursor: 'pointer', width: 36, height: 36, borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#6b7280', fontSize: 20, fontWeight: 300, lineHeight: 1, transition: 'all 0.15s ease' }}
            onMouseEnter={(e) => { e.currentTarget.style.background = '#f3f4f6'; e.currentTarget.style.color = '#002a32' }}
            onMouseLeave={(e) => { e.currentTarget.style.background = 'none'; e.currentTarget.style.color = '#6b7280' }}
          >
            <X size={18} />
          </button>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', padding: '28px' }}>
          {error && (
            <div style={{ background: '#fef2f2', border: '1px solid #fecaca', color: '#991b1b', padding: '12px 16px', borderRadius: 8, fontSize: 14, marginBottom: 20 }}>
              {error}
            </div>
          )}

          <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Slug *</label>
              <input type="text" value={slug} onChange={(e) => setSlug(e.target.value)} style={{ ...inputStyle, padding: '10px 14px' }} placeholder="Ex: farmacologia" />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Fase PT</label>
              <input type="text" value={phasePt} onChange={(e) => setPhasePt(e.target.value)} style={{ ...inputStyle, padding: '10px 14px' }} placeholder="Ex: 2º Ano" />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Phase EN</label>
              <input type="text" value={phaseEn} onChange={(e) => setPhaseEn(e.target.value)} style={{ ...inputStyle, padding: '10px 14px' }} placeholder="Ex: 2nd Year" />
            </div>
          </div>

          <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Nome PT *</label>
              <input type="text" value={namePt} onChange={(e) => setNamePt(e.target.value)} style={{ ...inputStyle, padding: '10px 14px' }} />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Name EN *</label>
              <input type="text" value={nameEn} onChange={(e) => setNameEn(e.target.value)} style={{ ...inputStyle, padding: '10px 14px' }} />
            </div>
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Descrição PT</label>
            <textarea value={descriptionPt} onChange={(e) => setDescriptionPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 56, lineHeight: 1.5 }} rows={2} />
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Description EN</label>
            <textarea value={descriptionEn} onChange={(e) => setDescriptionEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 56, lineHeight: 1.5 }} rows={2} />
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Porquê é essencial (PT)</label>
            <textarea value={importancePt} onChange={(e) => setImportancePt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 64, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Why it matters (EN)</label>
            <textarea value={importanceEn} onChange={(e) => setImportanceEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 64, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={{ display: 'flex', gap: 20, marginBottom: 28, alignItems: 'center' }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Ordem</label>
              <input type="number" value={sortOrder} onChange={(e) => setSortOrder(parseInt(e.target.value) || 0)} min={0} style={{ ...inputStyle, padding: '10px 14px' }} />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Estado</label>
              <button
                type="button"
                onClick={() => setStatus(status === 'published' ? 'draft' : 'published')}
                style={{
                  width: '100%',
                  padding: '10px 14px',
                  border: '1px solid #d1d5db',
                  borderRadius: 8,
                  fontSize: 14,
                  fontFamily: 'Inter, sans-serif',
                  cursor: 'pointer',
                  background: status === 'published' ? '#f0fdf4' : '#fffbeb',
                  color: status === 'published' ? '#166534' : '#92400e',
                  fontWeight: 500,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 8,
                  outline: 'none',
                  transition: 'all 0.15s ease',
                }}
              >
                {status === 'published' ? (
                  <><CheckCircle size={16} /> Publicado</>
                ) : (
                  <><XCircle size={16} /> Rascunho</>
                )}
              </button>
            </div>
          </div>

          {/* Livros */}
          <div style={{ marginBottom: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <label style={{ ...labelStyle, marginBottom: 0, fontSize: 14 }}>Livros Essenciais</label>
              <button
                type="button"
                onClick={() => setBooks((prev) => [...prev, { title_pt: '', title_en: '', author: '', edition: '', year: null, cover_url: '', team_paragraph_pt: '', team_paragraph_en: '', links: [], status: 'draft', sort_order: prev.length + 1 }])}
                style={{ background: '#00493a', border: 'none', color: '#fff', borderRadius: 6, padding: '6px 12px', fontSize: 12, fontWeight: 600, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6 }}
              >
                <Plus size={14} /> Adicionar Livro
              </button>
            </div>
            {books.length === 0 && <p style={{ fontSize: 13, color: '#9ca3af', fontStyle: 'italic' }}>Nenhum livro associado.</p>}
            {books.map((b, i) => (
              <BookEditor key={b.id || `new-${i}`} book={b} onChange={(field, value) => updateBook(i, field, value)} onRemove={() => removeBook(i)} />
            ))}
          </div>

          {/* Recursos */}
          <div style={{ marginBottom: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <label style={{ ...labelStyle, marginBottom: 0, fontSize: 14 }}>Recursos Gratuitos</label>
              <button
                type="button"
                onClick={() => setResources((prev) => [...prev, { title_pt: '', title_en: '', description_pt: '', description_en: '', url: '', type: 'pdf', status: 'draft', sort_order: prev.length + 1 }])}
                style={{ background: '#00493a', border: 'none', color: '#fff', borderRadius: 6, padding: '6px 12px', fontSize: 12, fontWeight: 600, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6 }}
              >
                <Plus size={14} /> Adicionar Recurso
              </button>
            </div>
            {resources.length === 0 && <p style={{ fontSize: 13, color: '#9ca3af', fontStyle: 'italic' }}>Nenhum recurso associado.</p>}
            {resources.map((r, i) => (
              <ResourceEditor key={r.id || `new-${i}`} resource={r} onChange={(field, value) => updateResource(i, field, value)} onRemove={() => removeResource(i)} />
            ))}
          </div>
        </div>

        <div style={{ display: 'flex', gap: 12, justifyContent: 'flex-end', alignItems: 'center', padding: '16px 28px', borderTop: '1px solid #e5e7eb', background: '#f9fafb', flexShrink: 0 }}>
          <button
            type="button"
            onClick={onClose}
            disabled={saving}
            style={{ padding: '10px 20px', borderRadius: 8, border: '2px solid #00493a', background: 'transparent', color: '#00493a', fontSize: 14, fontWeight: 500, fontFamily: 'Inter, sans-serif', cursor: saving ? 'not-allowed' : 'pointer', opacity: saving ? 0.5 : 1, transition: 'all 0.15s ease' }}
          >
            Cancelar
          </button>
          <button
            type="button"
            onClick={handleSave}
            disabled={saving}
            style={{ padding: '10px 24px', borderRadius: 8, border: 'none', background: saving ? '#6b7280' : '#00493a', color: '#fff', fontSize: 14, fontWeight: 600, fontFamily: 'Inter, sans-serif', cursor: saving ? 'not-allowed' : 'pointer', transition: 'all 0.15s ease', display: 'flex', alignItems: 'center', gap: 8 }}
          >
            <Save size={16} />
            {saving ? 'A guardar...' : discipline ? 'Guardar Alterações' : 'Criar Disciplina'}
          </button>
        </div>
      </div>
    </>
  )
}
