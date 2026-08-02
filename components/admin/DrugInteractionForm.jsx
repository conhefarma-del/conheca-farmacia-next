'use client'

import { useState } from 'react'
import { Save, X } from 'lucide-react'
import { createDrugInteraction, updateDrugInteraction } from '@/lib/actions/interacoes'

const SEVERITY_OPTIONS = [
  { value: 'critical', label: 'Grave' },
  { value: 'moderate', label: 'Moderada' },
  { value: 'minor', label: 'Menor' },
  { value: 'none', label: 'Sem relevância' },
]

/**
 * Slide-in panel largo para criar/editar uma interação medicamentosa
 * (tabela drug_interactions). Os IDs são ordenados de forma canónica
 * (drug_a_id < drug_b_id) no server action.
 */
export default function DrugInteractionForm({ interaction, drugs, panelOpen, onClose, onSaved }) {
  // Apenas fármacos ativos nos selects; se estiver a editar um par cujo
  // fármaco já foi arquivado, o valor atual é mantido na opção.
  const activeDrugs = drugs.filter((d) => !d.is_archived)
  const optionPool = drugs.filter((d) => !d.is_archived || d.id === interaction?.drug_a_id || d.id === interaction?.drug_b_id)

  const [drugAId, setDrugAId] = useState(interaction?.drug_a_id || '')
  const [drugBId, setDrugBId] = useState(interaction?.drug_b_id || '')
  const [severity, setSeverity] = useState(interaction?.severity || 'moderate')
  const [summaryPt, setSummaryPt] = useState(interaction?.summary_pt || '')
  const [summaryEn, setSummaryEn] = useState(interaction?.summary_en || '')
  const [mechanismPt, setMechanismPt] = useState(interaction?.mechanism_pt || '')
  const [mechanismEn, setMechanismEn] = useState(interaction?.mechanism_en || '')
  const [managementPt, setManagementPt] = useState(interaction?.management_pt || '')
  const [managementEn, setManagementEn] = useState(interaction?.management_en || '')
  const [monitoringPt, setMonitoringPt] = useState(interaction?.monitoring_pt || '')
  const [monitoringEn, setMonitoringEn] = useState(interaction?.monitoring_en || '')
  const [redFlagsPt, setRedFlagsPt] = useState(interaction?.red_flags_pt || '')
  const [redFlagsEn, setRedFlagsEn] = useState(interaction?.red_flags_en || '')
  const [sourcePt, setSourcePt] = useState(interaction?.source_pt || '')
  const [sourceEn, setSourceEn] = useState(interaction?.source_en || '')
  const [sourceUrl, setSourceUrl] = useState(interaction?.source_url || '')
  const [status, setStatus] = useState(interaction?.status || 'draft')
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const drugLabel = (d) => (d ? `${d.name_pt} / ${d.name_en}` : '')

  const handleSave = async () => {
    if (!drugAId) return setError('Seleciona o fármaco A.')
    if (!drugBId) return setError('Seleciona o fármaco B.')
    if (drugAId === drugBId) return setError('Os fármacos A e B têm de ser diferentes.')
    if (!summaryPt.trim() && !summaryEn.trim()) return setError('Preenche pelo menos um resumo (PT ou EN).')

    setSaving(true)
    setError(null)
    try {
      const payload = {
        drug_a_id: drugAId,
        drug_b_id: drugBId,
        severity,
        summary_pt: summaryPt,
        summary_en: summaryEn,
        mechanism_pt: mechanismPt,
        mechanism_en: mechanismEn,
        management_pt: managementPt,
        management_en: managementEn,
        monitoring_pt: monitoringPt,
        monitoring_en: monitoringEn,
        red_flags_pt: redFlagsPt,
        red_flags_en: redFlagsEn,
        source_pt: sourcePt,
        source_en: sourceEn,
        source_url: sourceUrl || null,
        status,
      }
      const res = interaction
        ? await updateDrugInteraction(interaction.id, payload)
        : await createDrugInteraction(payload)
      if (res.success) {
        onSaved(true, interaction ? 'Interação atualizada.' : 'Interação criada.')
      } else {
        setError(res.error || 'Erro ao guardar interação.')
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
        aria-label={interaction ? 'Editar interação' : 'Nova interação'}
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
            {interaction ? 'Editar Interação' : 'Nova Interação'}
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
              <label style={labelStyle}>Fármaco A *</label>
              <select value={drugAId} onChange={(e) => setDrugAId(e.target.value)} style={inputStyle}>
                <option value="">Seleciona...</option>
                {optionPool.map((d) => (
                  <option key={d.id} value={d.id}>{drugLabel(d)}</option>
                ))}
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Fármaco B *</label>
              <select value={drugBId} onChange={(e) => setDrugBId(e.target.value)} style={inputStyle}>
                <option value="">Seleciona...</option>
                {optionPool.filter((d) => d.id !== drugAId).map((d) => (
                  <option key={d.id} value={d.id}>{drugLabel(d)}</option>
                ))}
              </select>
            </div>
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Severidade</label>
              <select value={severity} onChange={(e) => setSeverity(e.target.value)} style={inputStyle}>
                {SEVERITY_OPTIONS.map((s) => (
                  <option key={s.value} value={s.value}>{s.label}</option>
                ))}
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Estado</label>
              <select value={status} onChange={(e) => setStatus(e.target.value)} style={inputStyle}>
                <option value="draft">Rascunho</option>
                <option value="published">Publicado</option>
              </select>
            </div>
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Resumo PT * — frase do cartão</label>
            <textarea value={summaryPt} onChange={(e) => setSummaryPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Summary EN</label>
            <textarea value={summaryEn} onChange={(e) => setSummaryEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Mecanismo PT</label>
            <textarea value={mechanismPt} onChange={(e) => setMechanismPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Mechanism EN</label>
            <textarea value={mechanismEn} onChange={(e) => setMechanismEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Monitorização PT</label>
            <textarea value={monitoringPt} onChange={(e) => setMonitoringPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Monitoring EN</label>
            <textarea value={monitoringEn} onChange={(e) => setMonitoringEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Sinais de Alerta PT</label>
            <textarea value={redFlagsPt} onChange={(e) => setRedFlagsPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Warning signs EN</label>
            <textarea value={redFlagsEn} onChange={(e) => setRedFlagsEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Recomendação PT</label>
            <textarea value={managementPt} onChange={(e) => setManagementPt(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Recommendation EN</label>
            <textarea value={managementEn} onChange={(e) => setManagementEn(e.target.value)} style={{ ...inputStyle, resize: 'vertical', minHeight: 60, lineHeight: 1.5 }} rows={3} />
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Fonte PT</label>
              <input type="text" value={sourcePt} onChange={(e) => setSourcePt(e.target.value)} style={inputStyle} placeholder="Stockley's Drug Interactions" />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Source EN</label>
              <input type="text" value={sourceEn} onChange={(e) => setSourceEn(e.target.value)} style={inputStyle} />
            </div>
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Source URL</label>
            <input type="text" value={sourceUrl} onChange={(e) => setSourceUrl(e.target.value)} style={inputStyle} placeholder="https://..." />
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
            {saving ? 'A guardar...' : interaction ? 'Guardar Alterações' : 'Criar Interação'}
          </button>
        </div>
      </div>
    </>
  )
}
