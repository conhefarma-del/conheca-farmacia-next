'use client'

import { useState } from 'react'
import { Save, X, CheckCircle, XCircle } from 'lucide-react'
import { createGuideCourse, updateGuideCourse } from '@/lib/actions/guides'

/**
 * Slide-in panel para criar/editar um curso de guia de estudo.
 * Padrão visual do painel FAQ/Privacy (commit 2826073).
 */
export default function GuideCursoForm({ course, panelOpen, onClose, onSaved }) {
  const [slug, setSlug] = useState(course?.slug || '')
  const [namePt, setNamePt] = useState(course?.name_pt || '')
  const [nameEn, setNameEn] = useState(course?.name_en || '')
  const [descriptionPt, setDescriptionPt] = useState(course?.description_pt || '')
  const [descriptionEn, setDescriptionEn] = useState(course?.description_en || '')
  const [heroSubtitlePt, setHeroSubtitlePt] = useState(course?.hero_subtitle_pt || '')
  const [heroSubtitleEn, setHeroSubtitleEn] = useState(course?.hero_subtitle_en || '')
  const [iconEmoji, setIconEmoji] = useState(course?.icon_emoji || '📚')
  const [color, setColor] = useState(course?.color || '#0a844f')
  const [status, setStatus] = useState(course?.status === 'published' ? 'published' : 'draft')
  const [sortOrder, setSortOrder] = useState(course?.sort_order ?? 0)
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const handleSave = async () => {
    if (!slug.trim()) return setError('O slug é obrigatório.')
    if (!namePt.trim()) return setError('O nome (PT) é obrigatório.')
    if (!nameEn.trim()) return setError('The name (EN) is required.')

    setSaving(true)
    setError(null)
    try {
      const payload = {
        slug: slug.trim(),
        name_pt: namePt.trim(),
        name_en: nameEn.trim(),
        description_pt: descriptionPt,
        description_en: descriptionEn,
        hero_subtitle_pt: heroSubtitlePt,
        hero_subtitle_en: heroSubtitleEn,
        icon_emoji: iconEmoji || '📚',
        color: color || '#0a844f',
        status,
        sort_order: parseInt(sortOrder, 10) || 0,
      }
      const result = course
        ? await updateGuideCourse(course.id, payload)
        : await createGuideCourse(payload)
      if (result.success) {
        onSaved(result)
      } else {
        setError(result.error || 'Erro ao guardar curso.')
      }
    } catch (err) {
      setError('Erro inesperado: ' + (err.message || 'desconhecido'))
    } finally {
      setSaving(false)
    }
  }

  const inputStyle = {
    width: '100%',
    padding: '10px 14px',
    border: '1px solid #d1d5db',
    borderRadius: 8,
    fontSize: 14,
    fontFamily: 'Inter, sans-serif',
    outline: 'none',
    background: '#fff',
    color: '#111827',
  }
  const labelStyle = {
    display: 'block',
    fontSize: 13,
    fontWeight: 600,
    color: '#374151',
    marginBottom: 6,
    textTransform: 'uppercase',
    letterSpacing: '0.05em',
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
        aria-label={course ? 'Editar curso' : 'Novo curso'}
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 640,
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
            {course ? 'Editar Curso' : 'Novo Curso'}
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

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Slug *</label>
            <input
              type="text"
              value={slug}
              onChange={(e) => setSlug(e.target.value)}
              style={inputStyle}
              placeholder="Ex: farmacia"
            />
          </div>

          <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Nome PT *</label>
              <input type="text" value={namePt} onChange={(e) => setNamePt(e.target.value)} style={inputStyle} />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Name EN *</label>
              <input type="text" value={nameEn} onChange={(e) => setNameEn(e.target.value)} style={inputStyle} />
            </div>
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Descrição PT</label>
            <textarea value={descriptionPt} onChange={(e) => setDescriptionPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 64, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Description EN</label>
            <textarea value={descriptionEn} onChange={(e) => setDescriptionEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 64, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Subtítulo PT</label>
              <input type="text" value={heroSubtitlePt} onChange={(e) => setHeroSubtitlePt(e.target.value)} style={inputStyle} />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Subtitle EN</label>
              <input type="text" value={heroSubtitleEn} onChange={(e) => setHeroSubtitleEn(e.target.value)} style={inputStyle} />
            </div>
          </div>

          <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Emoji</label>
              <input type="text" value={iconEmoji} onChange={(e) => setIconEmoji(e.target.value)} style={inputStyle} />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Cor (hex)</label>
              <input type="text" value={color} onChange={(e) => setColor(e.target.value)} style={inputStyle} placeholder="#0a844f" />
            </div>
          </div>

          <div style={{ display: 'flex', gap: 20, marginBottom: 24, alignItems: 'center' }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Ordem</label>
              <input
                type="number"
                value={sortOrder}
                onChange={(e) => setSortOrder(parseInt(e.target.value) || 0)}
                min={0}
                style={inputStyle}
              />
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
            {saving ? 'A guardar...' : course ? 'Guardar Alterações' : 'Criar Curso'}
          </button>
        </div>
      </div>
    </>
  )
}
