'use client'

import { useState } from 'react'
import { Save, X } from 'lucide-react'
import { createDrugDimension, updateDrugDimension } from '@/lib/actions/interacoes'

const TABLES = {
  food: 'drug_food_interactions',
  disease: 'drug_disease_interactions',
  pregnancy: 'drug_pregnancy_info',
}

const SEVERITY_OPTIONS = ['critical', 'moderate', 'minor', 'none']
const SEVERITY_LABELS = { critical: 'Grave', moderate: 'Moderada', minor: 'Menor', none: 'Sem relevância' }

export default function DimensionForm({ type, initialData, drugs, panelOpen, onClose, onSaved }) {
  const table = TABLES[type]
  const isNew = !initialData?.id
  const isPregnancy = type === 'pregnancy'

  // Campos comuns
  const [drugId, setDrugId] = useState(initialData?.drugId || '')
  const [severity, setSeverity] = useState(initialData?.severity || 'moderate')
  const [status, setStatus] = useState(initialData?.status || 'draft')

  // Food / Disease
  const [entitySlug, setEntitySlug] = useState(initialData?.entitySlug || initialData?.conditionSlug || '')
  const [entityPt, setEntityPt] = useState(initialData?.entity || initialData?.condition || '')
  const [entityEn, setEntityEn] = useState('')
  const [mechanismPt, setMechanismPt] = useState(initialData?.mechanism || initialData?.reason || '')
  const [mechanismEn, setMechanismEn] = useState('')
  const [advicePt, setAdvicePt] = useState(initialData?.advice || '')
  const [adviceEn, setAdviceEn] = useState('')
  const [sourcePt, setSourcePt] = useState(initialData?.source || '')
  const [sourceEn, setSourceEn] = useState('')
  const [sortOrder, setSortOrder] = useState(initialData?.sortOrder ?? 0)
  const [interactionType, setInteractionType] = useState(initialData?.interactionType || 'precaution')

  // Pregnancy
  const [pregnancyCategory, setPregnancyCategory] = useState(initialData?.pregnancyCategory || 'caution')
  const [riskPt, setRiskPt] = useState(initialData?.risk || '')
  const [riskEn, setRiskEn] = useState('')
  const [trimesterPt, setTrimesterPt] = useState(initialData?.trimester || '')
  const [trimesterEn, setTrimesterEn] = useState('')
  const [lactationPt, setLactationPt] = useState(initialData?.lactation || '')
  const [lactationEn, setLactationEn] = useState('')
  const [contraceptionPt, setContraceptionPt] = useState(initialData?.contraception || '')
  const [contraceptionEn, setContraceptionEn] = useState('')

  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const handleSave = async () => {
    if (!drugId) return setError('Seleciona um fármaco.')
    if (!isPregnancy && !entityPt.trim()) return setError('O nome (PT) é obrigatório.')
    if (!isPregnancy && !entitySlug.trim()) return setError('O slug é obrigatório.')

    setSaving(true)
    setError(null)
    try {
      const payload = isPregnancy ? {
        drug_id: drugId,
        pregnancy_category: pregnancyCategory,
        risk_pt: riskPt.trim(),
        risk_en: riskEn.trim(),
        trimester_pt: trimesterPt.trim(),
        trimester_en: trimesterEn.trim(),
        lactation_pt: lactationPt.trim(),
        lactation_en: lactationEn.trim(),
        contraception_pt: contraceptionPt.trim(),
        contraception_en: contraceptionEn.trim(),
        source_pt: sourcePt.trim(),
        source_en: sourceEn.trim(),
        status,
      } : type === 'food' ? {
        drug_id: drugId,
        entity_slug: entitySlug.trim(),
        entity_pt: entityPt.trim(),
        entity_en: entityEn.trim(),
        severity,
        mechanism_pt: mechanismPt.trim(),
        mechanism_en: mechanismEn.trim(),
        advice_pt: advicePt.trim(),
        advice_en: adviceEn.trim(),
        source_pt: sourcePt.trim(),
        source_en: sourceEn.trim(),
        sort_order: parseInt(sortOrder, 10) || 0,
        status,
      } : {
        drug_id: drugId,
        condition_slug: entitySlug.trim(),
        condition_pt: entityPt.trim(),
        condition_en: entityEn.trim(),
        interaction_type: interactionType,
        severity,
        reason_pt: mechanismPt.trim(),
        reason_en: mechanismEn.trim(),
        advice_pt: advicePt.trim(),
        advice_en: adviceEn.trim(),
        source_pt: sourcePt.trim(),
        source_en: sourceEn.trim(),
        sort_order: parseInt(sortOrder, 10) || 0,
        status,
      }

      const res = isNew
        ? await createDrugDimension(table, payload)
        : await updateDrugDimension(table, initialData.id, payload)

      if (res.success) {
        onSaved(true, isNew ? 'Criado.' : 'Atualizado.')
      } else {
        setError(res.error || 'Erro ao guardar.')
      }
    } catch (err) {
      setError('Erro inesperado: ' + (err.message || ''))
    } finally {
      setSaving(false)
    }
  }

  const inputClass = 'admin-dim-input'
  const labelClass = 'admin-dim-label'

  return (
    <div className={`admin-dim-form${panelOpen ? ' open' : ''}`}>
      <div className="admin-dim-header">
        <h3>{isNew ? 'Nova' : 'Editar'} {type === 'food' ? 'interação com alimento' : type === 'disease' ? 'interação com doença' : 'informação de gestação'}</h3>
        <button className="admin-dim-close" onClick={onClose}><X size={20} /></button>
      </div>
      <div className="admin-dim-body">
        {error && <p className="admin-dim-error">{error}</p>}

        <label className={labelClass}>Fármaco</label>
        <select className={inputClass} value={drugId} onChange={(e) => setDrugId(e.target.value)}>
          <option value="">Selecionar…</option>
          {drugs.map((d) => <option key={d.id} value={d.id}>{d.name_pt}</option>)}
        </select>

        {!isPregnancy && (
          <>
            <label className={labelClass}>Slug</label>
            <input className={inputClass} value={entitySlug} onChange={(e) => setEntitySlug(e.target.value)} placeholder="ex: cafeina, diabetes" />

            <label className={labelClass}>Nome (PT)</label>
            <input className={inputClass} value={entityPt} onChange={(e) => setEntityPt(e.target.value)} />

            <label className={labelClass}>Name (EN)</label>
            <input className={inputClass} value={entityEn} onChange={(e) => setEntityEn(e.target.value)} />

            <label className={labelClass}>Severidade</label>
            <select className={inputClass} value={severity} onChange={(e) => setSeverity(e.target.value)}>
              {SEVERITY_OPTIONS.map((s) => <option key={s} value={s}>{SEVERITY_LABELS[s]}</option>)}
            </select>

            {type === 'disease' && (
              <>
                <label className={labelClass}>Tipo de interação</label>
                <select className={inputClass} value={interactionType} onChange={(e) => setInteractionType(e.target.value)}>
                  <option value="precaution">Precaução</option>
                  <option value="contraindication">Contraindicação</option>
                </select>
              </>
            )}

            <label className={labelClass}>Mecanismo / Razão (PT)</label>
            <textarea className={inputClass} rows={3} value={mechanismPt} onChange={(e) => setMechanismPt(e.target.value)} />

            <label className={labelClass}>Mecanismo / Razão (EN)</label>
            <textarea className={inputClass} rows={3} value={mechanismEn} onChange={(e) => setMechanismEn(e.target.value)} />

            <label className={labelClass}>Recomendação (PT)</label>
            <textarea className={inputClass} rows={2} value={advicePt} onChange={(e) => setAdvicePt(e.target.value)} />

            <label className={labelClass}>Recomendação (EN)</label>
            <textarea className={inputClass} rows={2} value={adviceEn} onChange={(e) => setAdviceEn(e.target.value)} />

            <label className={labelClass}>Ordem</label>
            <input className={inputClass} type="number" value={sortOrder} onChange={(e) => setSortOrder(e.target.value)} />
          </>
        )}

        {isPregnancy && (
          <>
            <label className={labelClass}>Categoria</label>
            <select className={inputClass} value={pregnancyCategory} onChange={(e) => setPregnancyCategory(e.target.value)}>
              <option value="caution">Precaução</option>
              <option value="contraindicated">Contraindicado</option>
              <option value="compatible">Compatível</option>
              <option value="no_data">Sem dados</option>
            </select>

            <label className={labelClass}>Risco (PT)</label>
            <textarea className={inputClass} rows={2} value={riskPt} onChange={(e) => setRiskPt(e.target.value)} />

            <label className={labelClass}>Risco (EN)</label>
            <textarea className={inputClass} rows={2} value={riskEn} onChange={(e) => setRiskEn(e.target.value)} />

            <label className={labelClass}>Trimestre (PT)</label>
            <textarea className={inputClass} rows={2} value={trimesterPt} onChange={(e) => setTrimesterPt(e.target.value)} />

            <label className={labelClass}>Trimestre (EN)</label>
            <textarea className={inputClass} rows={2} value={trimesterEn} onChange={(e) => setTrimesterEn(e.target.value)} />

            <label className={labelClass}>Lactação (PT)</label>
            <textarea className={inputClass} rows={2} value={lactationPt} onChange={(e) => setLactationPt(e.target.value)} />

            <label className={labelClass}>Lactação (EN)</label>
            <textarea className={inputClass} rows={2} value={lactationEn} onChange={(e) => setLactationEn(e.target.value)} />

            <label className={labelClass}>Contraceção (PT)</label>
            <textarea className={inputClass} rows={2} value={contraceptionPt} onChange={(e) => setContraceptionPt(e.target.value)} />

            <label className={labelClass}>Contraceção (EN)</label>
            <textarea className={inputClass} rows={2} value={contraceptionEn} onChange={(e) => setContraceptionEn(e.target.value)} />
          </>
        )}

        <label className={labelClass}>Fonte (PT)</label>
        <input className={inputClass} value={sourcePt} onChange={(e) => setSourcePt(e.target.value)} />

        <label className={labelClass}>Fonte (EN)</label>
        <input className={inputClass} value={sourceEn} onChange={(e) => setSourceEn(e.target.value)} />

        <label className={labelClass}>Estado</label>
        <select className={inputClass} value={status} onChange={(e) => setStatus(e.target.value)}>
          <option value="draft">Rascunho</option>
          <option value="published">Publicado</option>
        </select>
      </div>
      <div className="admin-dim-footer">
        <button className="admin-btn admin-btn-primary" onClick={handleSave} disabled={saving}>
          <Save size={14} /> {saving ? 'A guardar…' : 'Guardar'}
        </button>
      </div>
    </div>
  )
}