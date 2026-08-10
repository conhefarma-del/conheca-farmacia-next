'use client'

import { useCallback, useEffect, useState } from 'react'
import { Loader2, Save, X } from 'lucide-react'
import { getDrugProfile, saveDrugProfile } from '@/lib/actions/medicamentos'

/**
 * InlineProfileForm — formulário compacto de perfil do fármaco para ser
 * renderizado dentro de uma linha expansível da tabela (sem overlay/slide).
 */
export default function InlineProfileForm({ drug, onClose, onSaved }) {
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const [status, setStatus] = useState('draft')
  const [overviewPublicPt, setOverviewPublicPt] = useState('')
  const [overviewProPt, setOverviewProPt] = useState('')
  const [indicationsPt, setIndicationsPt] = useState('')
  const [sideEffectsPt, setSideEffectsPt] = useState('')
  const [precautionsPt, setPrecautionsPt] = useState('')
  const [sourcePt, setSourcePt] = useState('')

  useEffect(() => {
    getDrugProfile(drug.id).then((data) => {
      setProfile(data)
      if (data) {
        setStatus(data.status || 'draft')
        setOverviewPublicPt(data.overview_public_pt || '')
        setOverviewProPt(data.overview_pro_pt || '')
        setIndicationsPt(data.indications_pt || '')
        setSideEffectsPt(data.side_effects_pt || '')
        setPrecautionsPt(data.precautions_pt || '')
        setSourcePt(data.source_pt || '')
      }
      setLoading(false)
    })
  }, [drug.id])

  const handleSave = useCallback(async () => {
    setSaving(true)
    setError(null)
    try {
      const res = await saveDrugProfile(drug.id, {
        status,
        overview_public_pt: overviewPublicPt,
        overview_pro_pt: overviewProPt,
        indications_pt: indicationsPt,
        side_effects_pt: sideEffectsPt,
        precautions_pt: precautionsPt,
        source_pt: sourcePt,
      })
      if (res.success) {
        onSaved(true, profile ? 'Perfil atualizado.' : 'Perfil criado.')
      } else {
        setError(res.error || 'Erro ao guardar.')
      }
    } catch (err) {
      setError('Erro: ' + (err.message || ''))
    } finally {
      setSaving(false)
    }
  }, [drug.id, status, overviewPublicPt, overviewProPt, indicationsPt, sideEffectsPt, precautionsPt, sourcePt, profile, onSaved])

  if (loading) {
    return (
      <div className="inline-form-loading">
        <Loader2 size={16} className="spin" /> A carregar perfil…
      </div>
    )
  }

  return (
    <div className="inline-form">
      <div className="inline-form-header">
        <strong>Perfil — {drug.name_pt}</strong>
        <span className="inline-form-id">
          {profile ? `atualizado ${new Date(profile.updated_at).toLocaleString('pt-PT')}` : 'novo'}
        </span>
        <button type="button" className="inline-form-close" onClick={onClose} aria-label="Fechar">
          <X size={14} />
        </button>
      </div>

      {error && <div className="admin-message admin-error-message">{error}</div>}

      <div className="inline-form-body">
        <div className="inline-form-row">
          <div className="inline-form-field">
            <label className="inline-form-label">Estado</label>
            <select className="inline-form-select" value={status} onChange={(e) => setStatus(e.target.value)}>
              <option value="draft">Rascunho</option>
              <option value="published">Publicado</option>
            </select>
          </div>
          <div className="inline-form-field">
            <label className="inline-form-label">Fonte PT</label>
            <input className="inline-form-input" type="text" value={sourcePt} onChange={(e) => setSourcePt(e.target.value)} placeholder="DailyMed/FDA …" />
          </div>
        </div>
        <div className="inline-form-field">
          <label className="inline-form-label">Overview Público PT</label>
          <textarea className="inline-form-textarea" rows={2} value={overviewPublicPt} onChange={(e) => setOverviewPublicPt(e.target.value)} />
        </div>
        <div className="inline-form-field">
          <label className="inline-form-label">Overview Profissionais PT</label>
          <textarea className="inline-form-textarea" rows={2} value={overviewProPt} onChange={(e) => setOverviewProPt(e.target.value)} />
        </div>
        <details className="inline-form-details">
          <summary className="inline-form-summary">Mais campos</summary>
          <div className="inline-form-field">
            <label className="inline-form-label">Indicações PT</label>
            <textarea className="inline-form-textarea" rows={2} value={indicationsPt} onChange={(e) => setIndicationsPt(e.target.value)} />
          </div>
          <div className="inline-form-field">
            <label className="inline-form-label">Efeitos secundários PT</label>
            <textarea className="inline-form-textarea" rows={2} value={sideEffectsPt} onChange={(e) => setSideEffectsPt(e.target.value)} />
          </div>
          <div className="inline-form-field">
            <label className="inline-form-label">Precauções PT</label>
            <textarea className="inline-form-textarea" rows={2} value={precautionsPt} onChange={(e) => setPrecautionsPt(e.target.value)} />
          </div>
        </details>
      </div>

      <div className="inline-form-footer">
        <button type="button" className="admin-btn admin-btn-sm" onClick={onClose}>Cancelar</button>
        <button type="button" className="admin-btn admin-btn-sm admin-btn-primary" onClick={handleSave} disabled={saving}>
          {saving ? <Loader2 size={14} className="spin" /> : <Save size={14} />}
          {saving ? 'A guardar…' : 'Guardar'}
        </button>
      </div>
    </div>
  )
}