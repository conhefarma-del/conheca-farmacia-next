'use client'

import { useState } from 'react'
import { Save, X } from 'lucide-react'
import { createProtocol, updateProtocol } from '@/lib/actions/protocolos'

/**
 * Slide-in panel para criar/editar um protocolo clínico (campos base).
 * O conteúdo editorial (passos/referências/quiz) fica no ProtocolContentForm.
 */
export default function ProtocolForm({ protocol, categories, panelOpen, onClose, onSaved }) {
  const [slug, setSlug] = useState(protocol?.slug || '')
  const [categoryId, setCategoryId] = useState(protocol?.category_id || categories[0]?.id || '')
  const [titlePt, setTitlePt] = useState(protocol?.title_pt || '')
  const [titleEn, setTitleEn] = useState(protocol?.title_en || '')
  const [descriptionPt, setDescriptionPt] = useState(protocol?.description_pt || '')
  const [descriptionEn, setDescriptionEn] = useState(protocol?.description_en || '')
  const [summaryPt, setSummaryPt] = useState(protocol?.summary_pt || '')
  const [summaryEn, setSummaryEn] = useState(protocol?.summary_en || '')
  const [safetyNotesPt, setSafetyNotesPt] = useState(protocol?.safety_notes_pt || '')
  const [safetyNotesEn, setSafetyNotesEn] = useState(protocol?.safety_notes_en || '')
  const [redFlagsPt, setRedFlagsPt] = useState(protocol?.red_flags_pt || '')
  const [redFlagsEn, setRedFlagsEn] = useState(protocol?.red_flags_en || '')
  const [sourcePt, setSourcePt] = useState(protocol?.source_pt || '')
  const [sourceEn, setSourceEn] = useState(protocol?.source_en || '')
  const [sourceUrl, setSourceUrl] = useState(protocol?.source_url || '')
  const [difficulty, setDifficulty] = useState(protocol?.difficulty || 'iniciante')
  const [pdfUrl, setPdfUrl] = useState(protocol?.pdf_url || '')
  const [isUpdated, setIsUpdated] = useState(protocol?.is_updated ?? true)
  const [status, setStatus] = useState(protocol?.status || 'draft')
  const [sortOrder, setSortOrder] = useState(protocol?.sort_order ?? 0)
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const handleSave = async () => {
    if (!slug.trim()) return setError('O slug é obrigatório.')
    if (!categoryId) return setError('Seleciona uma categoria.')
    if (!titlePt.trim()) return setError('O título (PT) é obrigatório.')
    if (!titleEn.trim()) return setError('The title (EN) is required.')

    setSaving(true)
    setError(null)
    try {
      const payload = {
        slug: slug.trim(),
        category_id: categoryId,
        title_pt: titlePt.trim(),
        title_en: titleEn.trim(),
        description_pt: descriptionPt,
        description_en: descriptionEn,
        summary_pt: summaryPt,
        summary_en: summaryEn,
        safety_notes_pt: safetyNotesPt,
        safety_notes_en: safetyNotesEn,
        red_flags_pt: redFlagsPt,
        red_flags_en: redFlagsEn,
        source_pt: sourcePt,
        source_en: sourceEn,
        source_url: sourceUrl || null,
        difficulty,
        pdf_url: pdfUrl || null,
        is_updated: isUpdated,
        status,
        sort_order: parseInt(sortOrder, 10) || 0,
      }
      const res = protocol
        ? await updateProtocol(protocol.id, payload)
        : await createProtocol(payload)
      if (res.success) {
        onSaved(true, protocol ? 'Protocolo atualizado.' : 'Protocolo criado.')
      } else {
        setError(res.error || 'Erro ao guardar protocolo.')
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
        aria-label={protocol ? 'Editar protocolo' : 'Novo protocolo'}
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 720,
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
            {protocol ? 'Editar Protocolo' : 'Novo Protocolo'}
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

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Slug *</label>
              <input type="text" value={slug} onChange={(e) => setSlug(e.target.value)} style={inputStyle} placeholder="hipertensao-arterial-resistente" />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Categoria *</label>
              <select value={categoryId} onChange={(e) => setCategoryId(e.target.value)} style={inputStyle}>
                {categories.map((c) => <option key={c.id} value={c.id}>{c.name_pt} / {c.name_en}</option>)}
              </select>
            </div>
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Título PT *</label>
              <input type="text" value={titlePt} onChange={(e) => setTitlePt(e.target.value)} style={inputStyle} />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Title EN *</label>
              <input type="text" value={titleEn} onChange={(e) => setTitleEn(e.target.value)} style={inputStyle} />
            </div>
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Descrição PT — card da listagem</label>
            <textarea value={descriptionPt} onChange={(e) => setDescriptionPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Description EN</label>
            <textarea value={descriptionEn} onChange={(e) => setDescriptionEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Resumo rápido PT — "Resumo Rápido" no detalhe</label>
            <textarea value={summaryPt} onChange={(e) => setSummaryPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 70, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Quick summary EN</label>
            <textarea value={summaryEn} onChange={(e) => setSummaryEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 70, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Notas de Segurança PT</label>
            <textarea value={safetyNotesPt} onChange={(e) => setSafetyNotesPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Safety notes EN</label>
            <textarea value={safetyNotesEn} onChange={(e) => setSafetyNotesEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Sinais de Alarme PT — uma linha por sinal</label>
            <textarea value={redFlagsPt} onChange={(e) => setRedFlagsPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} placeholder="PA ≥ 180/120 mmHg com sintomas → encaminhar de imediato" />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Red flags EN</label>
            <textarea value={redFlagsEn} onChange={(e) => setRedFlagsEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Proveniência PT — "O que diz a Norma"</label>
            <input type="text" value={sourcePt} onChange={(e) => setSourcePt(e.target.value)} style={inputStyle} placeholder="Norma DGS n.º 001/2026 — Abordagem da Hipertensão Arterial" />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Source EN</label>
            <input type="text" value={sourceEn} onChange={(e) => setSourceEn(e.target.value)} style={inputStyle} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Source URL</label>
            <input type="text" value={sourceUrl} onChange={(e) => setSourceUrl(e.target.value)} style={inputStyle} placeholder="https://www.dgs.pt/..." />
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Dificuldade</label>
              <select value={difficulty} onChange={(e) => setDifficulty(e.target.value)} style={inputStyle}>
                <option value="iniciante">Iniciante</option>
                <option value="intermedio">Intermedio</option>
                <option value="avancado">Avancado</option>
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Ordem</label>
              <input type="number" value={sortOrder} onChange={(e) => setSortOrder(parseInt(e.target.value) || 0)} min={0} style={inputStyle} />
            </div>
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>URL do PDF (opcional)</label>
            <input type="text" value={pdfUrl} onChange={(e) => setPdfUrl(e.target.value)} style={inputStyle} placeholder="https://..." />
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Estado</label>
              <select value={status} onChange={(e) => setStatus(e.target.value)} style={inputStyle}>
                <option value="draft">Rascunho</option>
                <option value="published">Publicado</option>
              </select>
            </div>
            <div style={{ flex: 1, display: 'flex', alignItems: 'flex-end', paddingBottom: 4 }}>
              <label style={{ ...labelStyle, display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer', textTransform: 'none', letterSpacing: 0, fontWeight: 500 }}>
                <input type="checkbox" checked={isUpdated} onChange={(e) => setIsUpdated(e.target.checked)} style={{ width: 16, height: 16 }} />
                Chip "Actualizado" no card
              </label>
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
            {saving ? 'A guardar...' : protocol ? 'Guardar Alterações' : 'Criar Protocolo'}
          </button>
        </div>
      </div>
    </>
  )
}
