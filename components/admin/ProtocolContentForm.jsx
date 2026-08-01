'use client'

import { useMemo, useState } from 'react'
import { Save, X } from 'lucide-react'
import {
  createProtocolQuiz, createProtocolReference, createProtocolStep,
  deleteProtocolQuiz, deleteProtocolReference, deleteProtocolStep,
  updateProtocolQuiz, updateProtocolReference, updateProtocolStep,
} from '@/lib/actions/protocolos'

/**
 * Slide-in largo (maxWidth 780) para editar o conteúdo editorial de um protocolo:
 * Passos (com badges de recomendação/evidência e chips de fármacos com dose),
 * Referências e Quiz "Testa-te". Grava em ordem: apaga removidos → upsert passos
 * → upsert referências → upsert quizzes, com sort_order: i + 1.
 */
export default function ProtocolContentForm({ protocolId, protocolTitle, initialContent, panelOpen, onClose, onSaved }) {
  // -------- Passos --------
  const [steps, setSteps] = useState(() =>
    (initialContent?.steps || []).map((s) => ({
      id: s.id, label_pt: s.label_pt, label_en: s.label_en,
      title_pt: s.title_pt, title_en: s.title_en, body_pt: s.body_pt, body_en: s.body_en,
      recommendation: s.recommendation || '', evidence: s.evidence || '',
      drugs: (s.drugs || []).map((d) => ({ label_pt: d.label_pt, label_en: d.label_en, dose: d.dose || '' })),
    }))
  )
  const [removedStepIds, setRemovedStepIds] = useState([])

  // -------- Referências --------
  const [refs, setRefs] = useState(() =>
    (initialContent?.references || []).map((r) => ({ id: r.id, title_pt: r.title_pt, title_en: r.title_en, url: r.url }))
  )
  const [removedRefIds, setRemovedRefIds] = useState([])

  // -------- Quiz --------
  const [quizzes, setQuizzes] = useState(() =>
    (initialContent?.quizzes || []).map((q) => ({
      id: q.id, question_pt: q.question_pt, question_en: q.question_en,
      option_a_pt: q.option_a_pt, option_b_pt: q.option_b_pt, option_c_pt: q.option_c_pt, option_d_pt: q.option_d_pt,
      option_a_en: q.option_a_en, option_b_en: q.option_b_en, option_c_en: q.option_c_en, option_d_en: q.option_d_en,
      correct_index: q.correct_index, explanation_pt: q.explanation_pt, explanation_en: q.explanation_en,
    }))
  )
  const [removedQuizIds, setRemovedQuizIds] = useState([])

  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState(null)

  const dirty = useMemo(
    () => steps.length + refs.length + quizzes.length + removedStepIds.length + removedRefIds.length + removedQuizIds.length > 0,
    [steps, refs, quizzes, removedStepIds, removedRefIds, removedQuizIds]
  )

  // helpers genéricos de arrays
  const update = (setter, index, patch) => setter((arr) => arr.map((it, i) => (i === index ? { ...it, ...patch } : it)))
  const remove = (setter, arr, setRemoved, index) => {
    const item = arr[index]
    if (item?.id) setRemoved((ids) => [...ids, item.id])
    setter((list) => list.filter((_, i) => i !== index))
  }

  // -------- Save --------
  const save = async () => {
    setSaving(true)
    setError(null)
    setMessage(null)

    // 1) apagar removidos
    for (const id of removedStepIds) await deleteProtocolStep(id)
    for (const id of removedRefIds) await deleteProtocolReference(id)
    for (const id of removedQuizIds) await deleteProtocolQuiz(id)

    // 2) upsert passos (com sort_order sequencial)
    for (let i = 0; i < steps.length; i += 1) {
      const s = steps[i]
      const payload = {
        label_pt: s.label_pt, label_en: s.label_en, title_pt: s.title_pt, title_en: s.title_en,
        body_pt: s.body_pt, body_en: s.body_en,
        recommendation: s.recommendation || null, evidence: s.evidence || null,
        drugs: s.drugs.filter((d) => d.label_pt.trim() || d.label_en.trim()),
        sort_order: i + 1,
      }
      const res = s.id ? await updateProtocolStep(s.id, payload) : await createProtocolStep(protocolId, payload)
      if (!res.success) { setSaving(false); setError(`Erro no passo ${i + 1}: ${res.error}`); return }
    }

    // 3) upsert referências
    for (let i = 0; i < refs.length; i += 1) {
      const r = refs[i]
      const payload = { title_pt: r.title_pt, title_en: r.title_en, url: r.url, sort_order: i + 1 }
      const res = r.id ? await updateProtocolReference(r.id, payload) : await createProtocolReference(protocolId, payload)
      if (!res.success) { setSaving(false); setError(`Erro na referência ${i + 1}: ${res.error}`); return }
    }

    // 4) upsert quizzes
    for (let i = 0; i < quizzes.length; i += 1) {
      const q = quizzes[i]
      const payload = {
        question_pt: q.question_pt, question_en: q.question_en,
        option_a_pt: q.option_a_pt, option_b_pt: q.option_b_pt, option_c_pt: q.option_c_pt, option_d_pt: q.option_d_pt,
        option_a_en: q.option_a_en, option_b_en: q.option_b_en, option_c_en: q.option_c_en, option_d_en: q.option_d_en,
        correct_index: Number(q.correct_index),
        explanation_pt: q.explanation_pt, explanation_en: q.explanation_en,
        sort_order: i + 1,
      }
      const res = q.id ? await updateProtocolQuiz(q.id, payload) : await createProtocolQuiz(protocolId, payload)
      if (!res.success) { setSaving(false); setError(`Erro na pergunta ${i + 1}: ${res.error}`); return }
    }

    setSaving(false)
    setMessage('Conteúdo guardado.')
    onSaved(true, 'Conteúdo guardado.')
  }

  const inputStyle = {
    width: '100%',
    padding: '9px 12px',
    border: '1px solid #d1d5db',
    borderRadius: 8,
    fontSize: 14,
    fontFamily: 'Inter, sans-serif',
    outline: 'none',
    background: '#fff',
    color: '#111827',
    marginBottom: 10,
  }
  const labelStyle = { display: 'block', fontSize: 12, fontWeight: 600, color: '#374151', marginBottom: 3 }
  const btnStyle = { padding: '9px 16px', borderRadius: 8, border: 'none', cursor: 'pointer', fontWeight: 600, fontFamily: 'Inter, sans-serif' }
  const sectionStyle = { border: '1px solid #e5e7e4', borderRadius: 12, padding: 18, marginBottom: 20, background: '#fafaf8' }
  const rowStyle = { display: 'flex', gap: 8, alignItems: 'flex-start', marginBottom: 10, background: '#fff', border: '1px solid #e5e7e4', borderRadius: 10, padding: 12 }

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
        aria-label="Conteúdo do protocolo"
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 780,
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
            Conteúdo: {protocolTitle}
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
          {message && <p style={{ color: '#065f46', background: '#ecfdf5', border: '1px solid #a7f3d0', padding: 10, borderRadius: 8, fontSize: 14, marginBottom: 20 }}>{message}</p>}
          {error && <p style={{ color: '#b91c1c', background: '#fef2f2', border: '1px solid #fecaca', padding: 10, borderRadius: 8, fontSize: 14, marginBottom: 20 }}>{error}</p>}

          {/* ============ PASSOS ============ */}
          <div style={sectionStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <h3 style={{ margin: 0 }}>Passos ({steps.length})</h3>
              <button
                style={{ ...btnStyle, background: '#0a844f', color: '#fff' }}
                onClick={() => setSteps((arr) => [...arr, { id: null, label_pt: '', label_en: '', title_pt: '', title_en: '', body_pt: '', body_en: '', recommendation: '', evidence: '', drugs: [] }])}
              >+ Passo</button>
            </div>
            {steps.length === 0 && <p style={{ opacity: 0.6, fontSize: 13 }}>Sem passos. O protocolo aparece só na listagem.</p>}
            {steps.map((s, i) => (
              <div key={s.id ?? `new-${i}`} style={rowStyle}>
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Label (PT) — ex. "Confirmar"</label>
                      <input style={inputStyle} value={s.label_pt} onChange={(e) => update(setSteps, i, { label_pt: e.target.value })} />
                    </div>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Label (EN)</label>
                      <input style={inputStyle} value={s.label_en} onChange={(e) => update(setSteps, i, { label_en: e.target.value })} />
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Título (PT)</label>
                      <input style={inputStyle} value={s.title_pt} onChange={(e) => update(setSteps, i, { title_pt: e.target.value })} />
                    </div>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Title (EN)</label>
                      <input style={inputStyle} value={s.title_en} onChange={(e) => update(setSteps, i, { title_en: e.target.value })} />
                    </div>
                  </div>
                  <label style={labelStyle}>Corpo (PT)</label>
                  <textarea style={{ ...inputStyle, minHeight: 60, resize: 'vertical' }} value={s.body_pt} onChange={(e) => update(setSteps, i, { body_pt: e.target.value })} />
                  <label style={labelStyle}>Body (EN)</label>
                  <textarea style={{ ...inputStyle, minHeight: 60, resize: 'vertical' }} value={s.body_en} onChange={(e) => update(setSteps, i, { body_en: e.target.value })} />
                  <div style={{ display: 'flex', gap: 8 }}>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Recomendação</label>
                      <select style={inputStyle} value={s.recommendation} onChange={(e) => update(setSteps, i, { recommendation: e.target.value })}>
                        <option value="">— sem badge —</option>
                        <option value="strong">Forte</option>
                        <option value="conditional">Condicional</option>
                      </select>
                    </div>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Evidência</label>
                      <select style={inputStyle} value={s.evidence} onChange={(e) => update(setSteps, i, { evidence: e.target.value })}>
                        <option value="">— sem badge —</option>
                        <option value="high">Alta</option>
                        <option value="moderate">Moderada</option>
                        <option value="low">Baixa</option>
                      </select>
                    </div>
                  </div>

                  {/* Fármacos com dose */}
                  <div style={{ marginTop: 4 }}>
                    <label style={labelStyle}>Fármacos mencionados</label>
                    {s.drugs.map((d, di) => (
                      <div key={di} style={{ display: 'flex', gap: 6, marginBottom: 6 }}>
                        <input style={{ ...inputStyle, marginBottom: 0, flex: 1 }} placeholder="label_pt" value={d.label_pt} onChange={(e) => update(setSteps, i, { drugs: s.drugs.map((x, xi) => xi === di ? { ...x, label_pt: e.target.value } : x) })} />
                        <input style={{ ...inputStyle, marginBottom: 0, flex: 1 }} placeholder="label_en" value={d.label_en} onChange={(e) => update(setSteps, i, { drugs: s.drugs.map((x, xi) => xi === di ? { ...x, label_en: e.target.value } : x) })} />
                        <input style={{ ...inputStyle, marginBottom: 0, flex: 1 }} placeholder="dose (ex. 25 mg/dia)" value={d.dose} onChange={(e) => update(setSteps, i, { drugs: s.drugs.map((x, xi) => xi === di ? { ...x, dose: e.target.value } : x) })} />
                        <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c' }} onClick={() => update(setSteps, i, { drugs: s.drugs.filter((_, xi) => xi !== di) })}>x</button>
                      </div>
                    ))}
                    <button
                      style={{ ...btnStyle, background: '#eef2ef', fontSize: 12 }}
                      onClick={() => update(setSteps, i, { drugs: [...s.drugs, { label_pt: '', label_en: '', dose: '' }] })}
                    >+ Fármaco</button>
                  </div>
                </div>
                <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c', flexShrink: 0 }} onClick={() => remove(setSteps, steps, setRemovedStepIds, i)}>Remover</button>
              </div>
            ))}
          </div>

          {/* ============ REFERÊNCIAS ============ */}
          <div style={sectionStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <h3 style={{ margin: 0 }}>Referências ({refs.length})</h3>
              <button style={{ ...btnStyle, background: '#0a844f', color: '#fff' }} onClick={() => setRefs((arr) => [...arr, { id: null, title_pt: '', title_en: '', url: '' }])}>+ Referência</button>
            </div>
            {refs.map((r, i) => (
              <div key={r.id ?? `new-ref-${i}`} style={rowStyle}>
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Título (PT)</label>
                      <input style={inputStyle} value={r.title_pt} onChange={(e) => update(setRefs, i, { title_pt: e.target.value })} />
                    </div>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Title (EN)</label>
                      <input style={inputStyle} value={r.title_en} onChange={(e) => update(setRefs, i, { title_en: e.target.value })} />
                    </div>
                  </div>
                  <label style={labelStyle}>URL</label>
                  <input style={{ ...inputStyle, marginBottom: 0 }} value={r.url} onChange={(e) => update(setRefs, i, { url: e.target.value })} placeholder="https://..." />
                </div>
                <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c', flexShrink: 0 }} onClick={() => remove(setRefs, refs, setRemovedRefIds, i)}>Remover</button>
              </div>
            ))}
          </div>

          {/* ============ QUIZ ============ */}
          <div style={sectionStyle}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
              <h3 style={{ margin: 0 }}>Quiz "Testa-te" ({quizzes.length})</h3>
              <button style={{ ...btnStyle, background: '#0a844f', color: '#fff' }} onClick={() => setQuizzes((arr) => [...arr, { id: null, question_pt: '', question_en: '', option_a_pt: '', option_b_pt: '', option_c_pt: '', option_d_pt: '', option_a_en: '', option_b_en: '', option_c_en: '', option_d_en: '', correct_index: 0, explanation_pt: '', explanation_en: '' }])}>+ Pergunta</button>
            </div>
            {quizzes.map((q, i) => (
              <div key={q.id ?? `new-q-${i}`} style={rowStyle}>
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Pergunta (PT)</label>
                      <input style={inputStyle} value={q.question_pt} onChange={(e) => update(setQuizzes, i, { question_pt: e.target.value })} />
                    </div>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Question (EN)</label>
                      <input style={inputStyle} value={q.question_en} onChange={(e) => update(setQuizzes, i, { question_en: e.target.value })} />
                    </div>
                  </div>
                  {['a', 'b', 'c', 'd'].map((opt) => (
                    <div key={opt} style={{ display: 'flex', gap: 8 }}>
                      <div style={{ flex: 1 }}>
                        <label style={labelStyle}>Opção {opt.toUpperCase()} (PT)</label>
                        <input style={inputStyle} value={q[`option_${opt}_pt`]} onChange={(e) => update(setQuizzes, i, { [`option_${opt}_pt`]: e.target.value })} />
                      </div>
                      <div style={{ flex: 1 }}>
                        <label style={labelStyle}>Option {opt.toUpperCase()} (EN)</label>
                        <input style={inputStyle} value={q[`option_${opt}_en`]} onChange={(e) => update(setQuizzes, i, { [`option_${opt}_en`]: e.target.value })} />
                      </div>
                    </div>
                  ))}
                  <label style={labelStyle}>Resposta correta</label>
                  <select style={inputStyle} value={q.correct_index} onChange={(e) => update(setQuizzes, i, { correct_index: Number(e.target.value) })}>
                    {['A', 'B', 'C', 'D'].map((letter, li) => <option key={letter} value={li}>Opção {letter}</option>)}
                  </select>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Explicação (PT)</label>
                      <textarea style={{ ...inputStyle, minHeight: 50, resize: 'vertical' }} value={q.explanation_pt} onChange={(e) => update(setQuizzes, i, { explanation_pt: e.target.value })} />
                    </div>
                    <div style={{ flex: 1 }}>
                      <label style={labelStyle}>Explanation (EN)</label>
                      <textarea style={{ ...inputStyle, minHeight: 50, resize: 'vertical' }} value={q.explanation_en} onChange={(e) => update(setQuizzes, i, { explanation_en: e.target.value })} />
                    </div>
                  </div>
                </div>
                <button style={{ ...btnStyle, background: '#fee2e2', color: '#b91c1c', flexShrink: 0 }} onClick={() => remove(setQuizzes, quizzes, setRemovedQuizIds, i)}>Remover</button>
              </div>
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
            Fechar
          </button>
          <button
            type="button"
            onClick={save}
            disabled={saving || !dirty}
            style={{ padding: '10px 24px', borderRadius: 8, border: 'none', background: saving || !dirty ? '#9ca3af' : '#00493a', color: '#fff', fontSize: 14, fontWeight: 600, fontFamily: 'Inter, sans-serif', cursor: saving || !dirty ? 'not-allowed' : 'pointer', transition: 'all 0.15s ease', display: 'flex', alignItems: 'center', gap: 8 }}
          >
            <Save size={16} />
            {saving ? 'A guardar...' : 'Guardar conteúdo'}
          </button>
        </div>
      </div>
    </>
  )
}
