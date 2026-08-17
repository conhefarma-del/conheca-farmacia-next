'use client'

import { useState } from 'react'
import { Save, X } from 'lucide-react'
import { createTarget, updateTarget } from '@/lib/actions/alvos'

const TYPES = ['cyp450', 'cox', 'transporter', 'mao', 'enzyme', 'receptor', 'other']
const TYPE_LABELS = {
  cyp450: 'CYP450',
  cox: 'COX',
  transporter: 'Transportadores',
  mao: 'MAO',
  enzyme: 'Enzimas',
  receptor: 'Recetores',
  other: 'Outros',
}

function slugify(str) {
  return (str || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

export default function AlvoForm({ initialData, panelOpen, onClose, onSaved }) {
  const isNew = !initialData?.id

  const [slug, setSlug] = useState(initialData?.slug || '')
  const [targetType, setTargetType] = useState(initialData?.target_type || 'cyp450')
  const [namePt, setNamePt] = useState(initialData?.name_pt || '')
  const [nameEn, setNameEn] = useState(initialData?.name_en || '')
  const [fullNamePt, setFullNamePt] = useState(initialData?.full_name_pt || '')
  const [fullNameEn, setFullNameEn] = useState(initialData?.full_name_en || '')
  const [aliases, setAliases] = useState((initialData?.aliases || []).join(', '))
  const [whatIsPt, setWhatIsPt] = useState(initialData?.what_is_pt || '')
  const [whatIsEn, setWhatIsEn] = useState(initialData?.what_is_en || '')
  const [rolePt, setRolePt] = useState(initialData?.role_pt || '')
  const [roleEn, setRoleEn] = useState(initialData?.role_en || '')
  const [substratesPt, setSubstratesPt] = useState(initialData?.substrates_pt || '')
  const [substratesEn, setSubstratesEn] = useState(initialData?.substrates_en || '')
  const [inhibitorsPt, setInhibitorsPt] = useState(initialData?.inhibitors_pt || '')
  const [inhibitorsEn, setInhibitorsEn] = useState(initialData?.inhibitors_en || '')
  const [inducersPt, setInducersPt] = useState(initialData?.inducers_pt || '')
  const [inducersEn, setInducersEn] = useState(initialData?.inducers_en || '')
  const [clinicalNotesPt, setClinicalNotesPt] = useState(initialData?.clinical_notes_pt || '')
  const [clinicalNotesEn, setClinicalNotesEn] = useState(initialData?.clinical_notes_en || '')
  const [sourcePt, setSourcePt] = useState(initialData?.source_pt || '')
  const [sourceEn, setSourceEn] = useState(initialData?.source_en || '')
  const [sortOrder, setSortOrder] = useState(initialData?.sort_order ?? 0)
  const [status, setStatus] = useState(initialData?.status || 'draft')

  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const handleSave = async () => {
    if (!namePt.trim()) return setError('O nome (PT) é obrigatório.')
    if (!nameEn.trim()) return setError('O nome (EN) é obrigatório.')
    if (!slug.trim()) return setError('O slug é obrigatório.')

    setSaving(true)
    setError(null)
    try {
      const payload = {
        slug: slug.trim(),
        target_type: targetType,
        name_pt: namePt.trim(),
        name_en: nameEn.trim(),
        full_name_pt: fullNamePt.trim(),
        full_name_en: fullNameEn.trim(),
        aliases: aliases.split(',').map((a) => a.trim()).filter(Boolean),
        what_is_pt: whatIsPt.trim(),
        what_is_en: whatIsEn.trim(),
        role_pt: rolePt.trim(),
        role_en: roleEn.trim(),
        substrates_pt: substratesPt.trim(),
        substrates_en: substratesEn.trim(),
        inhibitors_pt: inhibitorsPt.trim(),
        inhibitors_en: inhibitorsEn.trim(),
        inducers_pt: inducersPt.trim(),
        inducers_en: inducersEn.trim(),
        clinical_notes_pt: clinicalNotesPt.trim(),
        clinical_notes_en: clinicalNotesEn.trim(),
        source_pt: sourcePt.trim(),
        source_en: sourceEn.trim(),
        sort_order: parseInt(sortOrder, 10) || 0,
        status,
      }
      const res = isNew
        ? await createTarget(payload)
        : await updateTarget(initialData.id, payload)

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
    <div className={`admin-dim-form alvo-admin-form${panelOpen ? ' open' : ''}`}>
      <div className="admin-dim-header">
        <h3>{isNew ? 'Novo' : 'Editar'} alvo molecular</h3>
        <button className="admin-dim-close" onClick={onClose}><X size={20} /></button>
      </div>
      <div className="admin-dim-body">
        {error && <p className="admin-dim-error">{error}</p>}

        <label className={labelClass}>Nome (PT)</label>
        <input
          className={inputClass}
          value={namePt}
          onChange={(e) => {
            setNamePt(e.target.value)
            if (isNew) setSlug(slugify(e.target.value))
          }}
          placeholder="ex: CYP3A4"
        />

        <label className={labelClass}>Nome (EN)</label>
        <input className={inputClass} value={nameEn} onChange={(e) => setNameEn(e.target.value)} />

        <label className={labelClass}>Nome completo (PT)</label>
        <input className={inputClass} value={fullNamePt} onChange={(e) => setFullNamePt(e.target.value)} placeholder="ex: Citocromo P450 3A4" />

        <label className={labelClass}>Nome completo (EN)</label>
        <input className={inputClass} value={fullNameEn} onChange={(e) => setFullNameEn(e.target.value)} placeholder="ex: Cytochrome P450 3A4" />

        <label className={labelClass}>Slug</label>
        <input className={inputClass} value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="ex: cyp3a4" />

        <label className={labelClass}>Tipo</label>
        <select className={inputClass} value={targetType} onChange={(e) => setTargetType(e.target.value)}>
          {TYPES.map((t) => <option key={t} value={t}>{TYPE_LABELS[t]}</option>)}
        </select>

        <label className={labelClass}>Aliases (separados por vírgula)</label>
        <input className={inputClass} value={aliases} onChange={(e) => setAliases(e.target.value)} placeholder="ex: CYP3A, CYP3A4" />

        <label className={labelClass}>O que é (PT)</label>
        <textarea className={inputClass} rows={3} value={whatIsPt} onChange={(e) => setWhatIsPt(e.target.value)} />

        <label className={labelClass}>O que é (EN)</label>
        <textarea className={inputClass} rows={3} value={whatIsEn} onChange={(e) => setWhatIsEn(e.target.value)} />

        <label className={labelClass}>Papel nas interações (PT)</label>
        <textarea className={inputClass} rows={3} value={rolePt} onChange={(e) => setRolePt(e.target.value)} />

        <label className={labelClass}>Papel nas interações (EN)</label>
        <textarea className={inputClass} rows={3} value={roleEn} onChange={(e) => setRoleEn(e.target.value)} />

        <label className={labelClass}>Substratos comuns (PT)</label>
        <textarea className={inputClass} rows={2} value={substratesPt} onChange={(e) => setSubstratesPt(e.target.value)} />

        <label className={labelClass}>Substratos comuns (EN)</label>
        <textarea className={inputClass} rows={2} value={substratesEn} onChange={(e) => setSubstratesEn(e.target.value)} />

        <label className={labelClass}>Inibidores (PT)</label>
        <textarea className={inputClass} rows={2} value={inhibitorsPt} onChange={(e) => setInhibitorsPt(e.target.value)} />

        <label className={labelClass}>Inibidores (EN)</label>
        <textarea className={inputClass} rows={2} value={inhibitorsEn} onChange={(e) => setInhibitorsEn(e.target.value)} />

        <label className={labelClass}>Indutores (PT)</label>
        <textarea className={inputClass} rows={2} value={inducersPt} onChange={(e) => setInducersPt(e.target.value)} />

        <label className={labelClass}>Indutores (EN)</label>
        <textarea className={inputClass} rows={2} value={inducersEn} onChange={(e) => setInducersEn(e.target.value)} />

        <label className={labelClass}>Notas clínicas (PT)</label>
        <textarea className={inputClass} rows={2} value={clinicalNotesPt} onChange={(e) => setClinicalNotesPt(e.target.value)} />

        <label className={labelClass}>Notas clínicas (EN)</label>
        <textarea className={inputClass} rows={2} value={clinicalNotesEn} onChange={(e) => setClinicalNotesEn(e.target.value)} />

        <label className={labelClass}>Fonte (PT)</label>
        <input className={inputClass} value={sourcePt} onChange={(e) => setSourcePt(e.target.value)} />

        <label className={labelClass}>Fonte (EN)</label>
        <input className={inputClass} value={sourceEn} onChange={(e) => setSourceEn(e.target.value)} />

        <label className={labelClass}>Ordem</label>
        <input className={inputClass} type="number" value={sortOrder} onChange={(e) => setSortOrder(e.target.value)} />

        <label className={labelClass}>Estado</label>
        <select className={inputClass} value={status} onChange={(e) => setStatus(e.target.value)}>
          <option value="draft">Rascunho</option>
          <option value="published">Publicado</option>
        </select>

        {/* Revisão visual — como o card aparece na página pública */}
        {(namePt || whatIsPt || rolePt) && (
          <div className="alvo-admin-preview">
            <p className="alvo-admin-preview-label">Revisão visual (página pública)</p>
            <div className="alvo-card" style={{ pointerEvents: 'none' }}>
              <div className="alvo-card-head">
                <span className={`alvo-badge alvo-badge-${targetType}`}>
                  {TYPE_LABELS[targetType]}
                </span>
                {fullNamePt && <span className="alvo-card-fullname">{fullNamePt}</span>}
              </div>
              <h2 className="alvo-card-name">{namePt || 'Nome do alvo'}</h2>
              <p className="alvo-card-role">{rolePt || 'Descrição breve do papel nas interações.'}</p>
              <span className="alvo-card-cta">Ver detalhe →</span>
            </div>
          </div>
        )}
      </div>
      <div className="admin-dim-footer">
        <button className="admin-btn admin-btn-primary" onClick={handleSave} disabled={saving}>
          <Save size={14} /> {saving ? 'A guardar…' : 'Guardar'}
        </button>
      </div>
    </div>
  )
}
