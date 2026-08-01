'use client'

import { useState } from 'react'
import { Save, X, CheckCircle, XCircle } from 'lucide-react'
import { createGuideUniversity, updateGuideUniversity } from '@/lib/actions/guides'

const inputStyle = {
  width: '100%',
  padding: '10px 14px',
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

/**
 * Slide-in panel para criar/editar uma universidade que leciona o curso
 * (nome, cidade, tipo público/privado, links do site e da página do curso).
 */
export default function GuideUniversidadeForm({ courseId, universidade, panelOpen, onClose, onSaved }) {
  const [name, setName] = useState(universidade?.name || '')
  const [city, setCity] = useState(universidade?.city || '')
  const [isPublic, setIsPublic] = useState(universidade?.is_public !== false)
  const [websiteUrl, setWebsiteUrl] = useState(universidade?.website_url || '')
  const [courseUrl, setCourseUrl] = useState(universidade?.course_url || '')
  const [status, setStatus] = useState(universidade?.status === 'published' ? 'published' : 'draft')
  const [sortOrder, setSortOrder] = useState(universidade?.sort_order ?? 0)
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const handleSave = async () => {
    if (!name.trim()) return setError('O nome da universidade é obrigatório.')

    setSaving(true)
    setError(null)
    try {
      const payload = {
        name: name.trim(),
        city: city.trim(),
        is_public: isPublic,
        website_url: websiteUrl.trim(),
        course_url: courseUrl.trim(),
        status,
        sort_order: parseInt(sortOrder, 10) || 0,
      }

      let res
      if (universidade) {
        res = await updateGuideUniversity(universidade.id, payload)
      } else {
        res = await createGuideUniversity(courseId, payload)
      }
      if (!res.success) return setError(res.error || 'Erro ao guardar universidade.')

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
        aria-label={universidade ? 'Editar universidade' : 'Nova universidade'}
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 560,
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
            {universidade ? 'Editar Universidade' : 'Nova Universidade'}
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
            <label style={labelStyle}>Nome *</label>
            <input type="text" value={name} onChange={(e) => setName(e.target.value)} style={inputStyle} placeholder="Ex: Universidade Agostinho Neto" />
          </div>

          <div style={{ display: 'flex', gap: 16, marginBottom: 24 }}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Cidade</label>
              <input type="text" value={city} onChange={(e) => setCity(e.target.value)} style={inputStyle} placeholder="Ex: Luanda" />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Ordem</label>
              <input type="number" value={sortOrder} onChange={(e) => setSortOrder(parseInt(e.target.value) || 0)} min={0} style={inputStyle} />
            </div>
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Tipo de instituição</label>
            <div style={{ display: 'flex', gap: 10 }}>
              <button
                type="button"
                onClick={() => setIsPublic(true)}
                style={{
                  flex: 1,
                  padding: '10px 14px',
                  border: isPublic ? '2px solid #00493a' : '1px solid #d1d5db',
                  borderRadius: 8,
                  fontSize: 13,
                  fontFamily: 'Inter, sans-serif',
                  cursor: 'pointer',
                  background: isPublic ? '#f0fdf4' : '#fff',
                  color: isPublic ? '#166534' : '#374151',
                  fontWeight: 500,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 8,
                  outline: 'none',
                }}
              >
                {isPublic && <CheckCircle size={16} />}
                Pública
              </button>
              <button
                type="button"
                onClick={() => setIsPublic(false)}
                style={{
                  flex: 1,
                  padding: '10px 14px',
                  border: !isPublic ? '2px solid #00493a' : '1px solid #d1d5db',
                  borderRadius: 8,
                  fontSize: 13,
                  fontFamily: 'Inter, sans-serif',
                  cursor: 'pointer',
                  background: !isPublic ? '#fdf2f8' : '#fff',
                  color: !isPublic ? '#9d174d' : '#374151',
                  fontWeight: 500,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 8,
                  outline: 'none',
                }}
              >
                {!isPublic && <CheckCircle size={16} />}
                Privada
              </button>
            </div>
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Website (https:// ou /relativo)</label>
            <input type="text" value={websiteUrl} onChange={(e) => setWebsiteUrl(e.target.value)} style={inputStyle} placeholder="https://www.uan.ao" />
          </div>

          <div style={{ marginBottom: 24 }}>
            <label style={labelStyle}>Página do curso (https:// ou /relativo)</label>
            <input type="text" value={courseUrl} onChange={(e) => setCourseUrl(e.target.value)} style={inputStyle} placeholder="https://www.uan.ao/curso/farmacia" />
          </div>

          <div style={{ display: 'flex', gap: 20, alignItems: 'center' }}>
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
            {saving ? 'A guardar...' : universidade ? 'Guardar Alterações' : 'Adicionar Universidade'}
          </button>
        </div>
      </div>
    </>
  )
}
