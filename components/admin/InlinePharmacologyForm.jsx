'use client'

import { useCallback, useEffect, useState } from 'react'
import { Loader2, Save, X } from 'lucide-react'
import { getDrugPharmacology, saveDrugPharmacology } from '@/lib/actions/medicamentos'

/**
 * InlinePharmacologyForm — formulário compacto de farmacologia para ser
 * renderizado dentro de uma linha expansível da tabela (sem overlay/slide).
 */
export default function InlinePharmacologyForm({ drug, onClose, onSaved }) {
  const [pharm, setPharm] = useState(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState(null)

  const [status, setStatus] = useState('draft')
  const [pharmacodynamicsPt, setPharmacodynamicsPt] = useState('')
  const [mechanismPt, setMechanismPt] = useState('')
  const [metabolismPt, setMetabolismPt] = useState('')
  const [absorptionPt, setAbsorptionPt] = useState('')
  const [halfLifePt, setHalfLifePt] = useState('')
  const [sourcePt, setSourcePt] = useState('')

  useEffect(() => {
    getDrugPharmacology(drug.id).then((data) => {
      setPharm(data)
      if (data) {
        setStatus(data.status || 'draft')
        setPharmacodynamicsPt(data.pharmacodynamics_pt || '')
        setMechanismPt(data.mechanism_pt || '')
        setMetabolismPt(data.metabolism_pt || '')
        setAbsorptionPt(data.absorption_pt || '')
        setHalfLifePt(data.half_life_pt || '')
        setSourcePt(data.source_pt || '')
      }
      setLoading(false)
    })
  }, [drug.id])

  const handleSave = useCallback(async () => {
    setSaving(true)
    setError(null)
    try {
      const res = await saveDrugPharmacology(drug.id, {
        status,
        pharmacodynamics_pt: pharmacodynamicsPt,
        mechanism_pt: mechanismPt,
        metabolism_pt: metabolismPt,
        absorption_pt: absorptionPt,
        half_life_pt: halfLifePt,
        source_pt: sourcePt,
      })
      if (res.success) {
        onSaved(true, pharm ? 'Farmacologia atualizada.' : 'Farmacologia criada.')
      } else {
        setError(res.error || 'Erro ao guardar.')
      }
    } catch (err) {
      setError('Erro: ' + (err.message || ''))
    } finally {
      setSaving(false)
    }
  }, [drug.id, status, pharmacodynamicsPt, mechanismPt, metabolismPt, absorptionPt, halfLifePt, sourcePt, pharm, onSaved])

  if (loading) {
    return (
      <div className="inline-form-loading">
        <Loader2 size={16} className="spin" /> A carregar farmacologia…
      </div>
    )
  }

  return (
    <div className="inline-form">
      <div className="inline-form-header">
        <strong>Farmacologia — {drug.name_pt}</strong>
        <span className="inline-form-id">
          {pharm ? `atualizado ${new Date(pharm.updated_at).toLocaleString('pt-PT')}` : 'novo'}
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
            <input className="inline-form-input" type="text" value={sourcePt} onChange={(e) => setSourcePt(e.target.value)} placeholder="DailyMed secção 12 …" />
          </div>
        </div>
        <div className="inline-form-row">
          <div className="inline-form-field">
            <label className="inline-form-label">Farmacodinâmica PT</label>
            <textarea className="inline-form-textarea" rows={2} value={pharmacodynamicsPt} onChange={(e) => setPharmacodynamicsPt(e.target.value)} />
          </div>
          <div className="inline-form-field">
            <label className="inline-form-label">Mecanismo de Ação PT</label>
            <textarea className="inline-form-textarea" rows={2} value={mechanismPt} onChange={(e) => setMechanismPt(e.target.value)} />
          </div>
        </div>
        <div className="inline-form-row">
          <div className="inline-form-field">
            <label className="inline-form-label">Metabolismo PT</label>
            <textarea className="inline-form-textarea" rows={2} value={metabolismPt} onChange={(e) => setMetabolismPt(e.target.value)} />
          </div>
          <div className="inline-form-field">
            <label className="inline-form-label">Absorção PT</label>
            <textarea className="inline-form-textarea" rows={2} value={absorptionPt} onChange={(e) => setAbsorptionPt(e.target.value)} />
          </div>
        </div>
        <div className="inline-form-row">
          <div className="inline-form-field">
            <label className="inline-form-label">Meia-Vida PT</label>
            <textarea className="inline-form-textarea" rows={2} value={halfLifePt} onChange={(e) => setHalfLifePt(e.target.value)} />
          </div>
          <div className="inline-form-field" />
        </div>
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