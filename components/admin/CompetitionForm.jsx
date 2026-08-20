'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createCompetition, updateCompetition } from '@/lib/actions/competition'

const QUESTION_TYPES = [
  { value: 'pharmacology', label: 'Farmacologia' },
  { value: 'interaction', label: 'Interações' },
  { value: 'flashcard', label: 'Flashcards' },
  { value: 'protocol', label: 'Protocolos' },
  { value: 'drug_class', label: 'Classes Terapêuticas' },
]

export default function CompetitionForm({ lang, initialData = null, schools = [] }) {
  const router = useRouter()
  const isNew = !initialData?.id

  const [name, setName] = useState(initialData?.name || '')
  const [slug, setSlug] = useState(initialData?.slug || '')
  const [accessCode, setAccessCode] = useState(initialData?.access_code || '')
  const [description, setDescription] = useState(initialData?.description || '')
  const [questionTypes, setQuestionTypes] = useState(initialData?.question_types || ['pharmacology', 'interaction', 'flashcard', 'protocol', 'drug_class'])
  const [questionsCount, setQuestionsCount] = useState(initialData?.questions_count || 10)
  const [timePerQuestion, setTimePerQuestion] = useState(initialData?.time_per_question || 30)
  const [streakBonus, setStreakBonus] = useState(initialData?.streak_bonus !== false)
  const [selectedSchools, setSelectedSchools] = useState(initialData?.school_ids || [])
  const [error, setError] = useState(null)
  const [saving, setSaving] = useState(false)

  const toggleType = (type) => {
    setQuestionTypes((prev) => prev.includes(type) ? prev.filter((t) => t !== type) : [...prev, type])
  }

  const toggleSchool = (id) => {
    setSelectedSchools((prev) => prev.includes(id) ? prev.filter((s) => s !== id) : [...prev, id])
  }

  const handleSave = async () => {
    if (!name.trim()) return setError('Nome é obrigatório.')
    setSaving(true)
    setError(null)

    const data = {
      name: name.trim(),
      slug: slug || name.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-'),
      access_code: accessCode || undefined,
      description: description.trim(),
      question_types: questionTypes,
      questions_count: questionsCount,
      time_per_question: timePerQuestion,
      streak_bonus: streakBonus,
      school_ids: selectedSchools,
    }

    const res = isNew ? await createCompetition(data) : await updateCompetition(initialData.id, data)
    if (res.success) {
      router.push(`/${lang}/admin/competicoes`)
    } else {
      setError(res.error)
      setSaving(false)
    }
  }

  return (
    <div className="admin-card" style={{ maxWidth: 700 }}>
      <div className="admin-card-body" style={{ padding: 24 }}>
        {error && <div className="admin-message admin-error-message" style={{ marginBottom: 16 }}>{error}</div>}

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
          <div>
            <label className="admin-dim-label">Nome da Competição</label>
            <input className="admin-dim-input" value={name} onChange={(e) => setName(e.target.value)} placeholder="ex: Competição Inter-Escolas 2026" />
          </div>
          <div>
            <label className="admin-dim-label">Slug</label>
            <input className="admin-dim-input" value={slug} onChange={(e) => setSlug(e.target.value)} placeholder="auto-gerado se vazio" />
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
          <div>
            <label className="admin-dim-label">Código de Acesso</label>
            <input className="admin-dim-input" value={accessCode} onChange={(e) => setAccessCode(e.target.value.toUpperCase())} placeholder="CF-XXXXXX (auto-gerado se vazio)" />
          </div>
          <div>
            <label className="admin-dim-label">Descrição</label>
            <input className="admin-dim-input" value={description} onChange={(e) => setDescription(e.target.value)} />
          </div>
        </div>

        <div style={{ marginBottom: 16 }}>
          <label className="admin-dim-label">Tipos de Pergunta</label>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {QUESTION_TYPES.map((t) => (
              <button key={t.value} type="button" className={`class-chip${questionTypes.includes(t.value) ? ' active' : ''}`} onClick={() => toggleType(t.value)}>
                {t.label}
              </button>
            ))}
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 16, marginBottom: 16 }}>
          <div>
            <label className="admin-dim-label">N.º de Perguntas</label>
            <select className="admin-dim-input" value={questionsCount} onChange={(e) => setQuestionsCount(Number(e.target.value))}>
              {[5, 10, 15, 20, 25, 30].map((n) => <option key={n} value={n}>{n}</option>)}
            </select>
          </div>
          <div>
            <label className="admin-dim-label">Tempo por Pergunta</label>
            <select className="admin-dim-input" value={timePerQuestion} onChange={(e) => setTimePerQuestion(Number(e.target.value))}>
              {[15, 20, 30, 45, 60].map((n) => <option key={n} value={n}>{n}s</option>)}
            </select>
          </div>
          <div>
            <label className="admin-dim-label">Streak Bonus</label>
            <select className="admin-dim-input" value={streakBonus ? 'on' : 'off'} onChange={(e) => setStreakBonus(e.target.value === 'on')}>
              <option value="on">Ativado</option>
              <option value="off">Desativado</option>
            </select>
          </div>
        </div>

        <div style={{ marginBottom: 24 }}>
          <label className="admin-dim-label">Escolas Convidadas (deixe vazio para todas)</label>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            {schools.map((s) => (
              <button key={s.id} type="button" className={`class-chip${selectedSchools.includes(s.id) ? ' active' : ''}`} onClick={() => toggleSchool(s.id)}>
                {s.name}
              </button>
            ))}
            {schools.length === 0 && <span style={{ color: 'var(--admin-text-muted)', fontSize: 13 }}>Nenhuma escola criada</span>}
          </div>
        </div>

        <div style={{ display: 'flex', gap: 8 }}>
          <button className="admin-btn admin-btn-primary" onClick={handleSave} disabled={saving}>
            {saving ? 'A guardar...' : isNew ? 'Criar Competição' : 'Guardar'}
          </button>
          <button className="admin-btn admin-btn-secondary" onClick={() => router.push(`/${lang}/admin/competicoes`)}>
            Cancelar
          </button>
        </div>
      </div>
    </div>
  )
}
