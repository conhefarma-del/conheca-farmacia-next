'use client'

import { useState } from 'react'
import { Save, X } from 'lucide-react'
import { createDrug, updateDrug } from '@/lib/actions/interacoes'

/**
 * Slide-in panel para criar/editar um fármaco (tabela drugs).
 * Usado na calculadora de interações medicamentosas.
 */
export default function DrugForm({ drug, panelOpen, onClose, onSaved }) {
  const [slug, setSlug] = useState(drug?.slug || '')
  const [namePt, setNamePt] = useState(drug?.name_pt || '')
  const [nameEn, setNameEn] = useState(drug?.name_en || '')
  const [classPt, setClassPt] = useState(drug?.class_pt || '')
  const [classEn, setClassEn] = useState(drug?.class_en || '')
  const [aliases, setAliases] = useState((drug?.aliases || []).join(', '))
  const [status, setStatus] = useState(drug?.status || 'draft')
  const [sortOrder, setSortOrder] = useState(drug?.sort_order ?? 0)
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const handleSave = async () => {
    if (!slug.trim()) return setError('O slug é obrigatório.')
    if (!slug.trim().match(/^[a-z0-9-]+$/)) return setError('Slug inválido (apenas letras minúsculas, números e hífens).')
    if (!namePt.trim()) return setError('O nome (PT) é obrigatório.')
    if (!nameEn.trim()) return setError('The name (EN) is required.')

    setSaving(true)
    setError(null)
    try {
      const payload = {
        slug: slug.trim(),
        name_pt: namePt.trim(),
        name_en: nameEn.trim(),
        class_pt: classPt.trim(),
        class_en: classEn.trim(),
        aliases: aliases.split(',').map((a) => a.trim()).filter(Boolean),
        status,
        sort_order: parseInt(sortOrder, 10) || 0,
      }
      const res = drug
        ? await updateDrug(drug.id, payload)
        : await createDrug(payload)
      if (res.success) {
        onSaved(true, drug ? 'Fármaco atualizado.' : 'Fármaco criado.')
      } else {
        setError(res.error || 'Erro ao guardar fármaco.')
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
  const fieldGap = { marginBottom: 22 }
  const rowGap = { display: 'flex', gap: 16, marginBottom: 22 }

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
        aria-label={drug ? 'Editar fármaco' : 'Novo fármaco'}
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 520,
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
            {drug ? 'Editar Fármaco' : 'Novo Fármaco'}
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

          <div style={fieldGap}>
            <label style={labelStyle}>Slug *</label>
            <input type="text" value={slug} onChange={(e) => setSlug(e.target.value)} style={inputStyle} placeholder="enalapril" />
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Nome PT *</label>
              <input type="text" value={namePt} onChange={(e) => setNamePt(e.target.value)} style={inputStyle} />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Name EN *</label>
              <input type="text" value={nameEn} onChange={(e) => setNameEn(e.target.value)} style={inputStyle} />
            </div>
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Classe PT</label>
              <input type="text" value={classPt} onChange={(e) => setClassPt(e.target.value)} style={inputStyle} placeholder="IECA — inibidor da ECA" />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Class EN</label>
              <input type="text" value={classEn} onChange={(e) => setClassEn(e.target.value)} style={inputStyle} placeholder="ACE inhibitor" />
            </div>
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Aliases — separados por vírgula</label>
            <input type="text" value={aliases} onChange={(e) => setAliases(e.target.value)} style={inputStyle} placeholder="renitec, ecazide, vasotec" />
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Estado</label>
              <select value={status} onChange={(e) => setStatus(e.target.value)} style={inputStyle}>
                <option value="draft">Rascunho</option>
                <option value="published">Publicado</option>
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Ordem</label>
              <input type="number" value={sortOrder} onChange={(e) => setSortOrder(parseInt(e.target.value) || 0)} min={0} style={inputStyle} />
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
            {saving ? 'A guardar...' : drug ? 'Guardar Alterações' : 'Criar Fármaco'}
          </button>
        </div>
      </div>
    </>
  )
}
