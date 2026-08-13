'use client'

import { useState } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import Link from 'next/link'
import { Save, ArrowLeft, Search, Sparkles } from 'lucide-react'
import {
  createFlashcard,
  updateFlashcard,
  generateCardFromDrug,
  searchDrugsForFlashcards,
} from '@/lib/actions/flashcards'

const CARD_TYPE_LABELS = {
  mecanismo: 'Mecanismo de ação',
  classe: 'Classe terapêutica',
  perfil: 'Perfil / visão geral',
  interacao: 'Interação fármaco-fármaco',
  manual: 'Manual (conteúdo livre)',
}

/**
 * FlashcardForm — criar/editar um cartão de flashcards, com geração
 * assistida a partir de um fármaco do banco (decisão 3A do plano).
 */
export default function FlashcardForm({ mode = 'create', decks = [], initialData = null }) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const initialDeck = initialData?.deck_id || searchParams.get('deck') || ''

  const [form, setForm] = useState({
    deck_id: initialDeck,
    card_type: initialData?.card_type || 'mecanismo',
    drug_id: initialData?.drug_id || '',
    front_pt: initialData?.front_pt || '',
    front_en: initialData?.front_en || '',
    back_pt: initialData?.back_pt || '',
    back_en: initialData?.back_en || '',
    source_note: initialData?.source_note || '',
    status: initialData?.status || 'draft',
  })
  const [drugQuery, setDrugQuery] = useState('')
  const [drugResults, setDrugResults] = useState([])
  const [searching, setSearching] = useState(false)
  const [generating, setGenerating] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const set = (key, value) => setForm((f) => ({ ...f, [key]: value }))

  const handleSearch = async (q) => {
    setDrugQuery(q)
    if (q.trim().length < 2) {
      setDrugResults([])
      return
    }
    setSearching(true)
    try {
      const results = await searchDrugsForFlashcards(q)
      setDrugResults(results || [])
    } catch {
      setDrugResults([])
    } finally {
      setSearching(false)
    }
  }

  const pickDrug = (drug) => {
    setForm((f) => ({ ...f, drug_id: drug.id }))
    setDrugQuery(drug.name_pt)
    setDrugResults([])
  }

  const handleGenerate = async () => {
    setError('')
    if (!form.drug_id) {
      setError('Escolhe primeiro um fármaco (pesquisa acima).')
      return
    }
    if (form.card_type === 'manual') {
      setError('O tipo "Manual" não usa geração — escreve o conteúdo livremente.')
      return
    }
    setGenerating(true)
    try {
      const res = await generateCardFromDrug(form.drug_id, form.card_type)
      if (res.ok) {
        setForm((f) => ({
          ...f,
          front_pt: res.frontPt,
          back_pt: res.backPt,
          source_note: res.sourceNote,
        }))
      } else {
        setError(res.error)
      }
    } catch {
      setError('Erro ao gerar o cartão.')
    } finally {
      setGenerating(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setSaving(true)
    try {
      const res =
        mode === 'create'
          ? await createFlashcard(form)
          : await updateFlashcard(initialData.id, form)
      if (res.ok) {
        router.push(`/pt/admin/flashcards/decks/${form.deck_id}`)
        router.refresh()
      } else {
        setError(res.error)
      }
    } catch {
      setError('Erro ao guardar o cartão.')
    } finally {
      setSaving(false)
    }
  }

  const deck = decks.find((d) => d.id === form.deck_id)

  return (
    <div>
      <div className="admin-page-header">
        <h1 className="admin-page-title">{mode === 'create' ? 'Novo Cartão' : 'Editar Cartão'}</h1>
        <p className="admin-page-subtitle">Cartão de repetição espaçada — gerado do fármaco ou manual</p>
      </div>

      <Link
        href={form.deck_id ? `/pt/admin/flashcards/decks/${form.deck_id}` : '/pt/admin/flashcards'}
        className="admin-back-link"
      >
        <ArrowLeft size={14} /> Voltar
      </Link>

      <form onSubmit={handleSubmit} className="admin-form">
        <div className="admin-form-grid">
          <div className="admin-form-field">
            <label className="admin-form-label">Deck *</label>
            <select
              className="admin-form-input"
              value={form.deck_id}
              onChange={(e) => set('deck_id', e.target.value)}
              required
            >
              <option value="">— Selecionar deck —</option>
              {decks.map((d) => (
                <option key={d.id} value={d.id}>
                  {d.name_pt}
                </option>
              ))}
            </select>
          </div>
          <div className="admin-form-field">
            <label className="admin-form-label">Tipo de cartão</label>
            <select
              className="admin-form-input"
              value={form.card_type}
              onChange={(e) => set('card_type', e.target.value)}
            >
              {Object.entries(CARD_TYPE_LABELS).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>
          </div>
          <div className="admin-form-field">
            <label className="admin-form-label">Estado</label>
            <select
              className="admin-form-input"
              value={form.status}
              onChange={(e) => set('status', e.target.value)}
            >
              <option value="draft">Rascunho</option>
              <option value="published">Publicado</option>
            </select>
          </div>
        </div>

        {/* Geração assistida */}
        <div className="admin-form-field">
          <label className="admin-form-label">Fármaco de origem (opcional — para gerar)</label>
          <div className="admin-drug-picker">
            <div className="admin-drug-search">
              <Search size={15} className="admin-drug-search-icon" />
              <input
                className="admin-form-input"
                value={drugQuery}
                onChange={(e) => handleSearch(e.target.value)}
                placeholder="Pesquisar fármaco (ex.: amoxicilina)"
              />
            </div>
            {drugResults.length > 0 && (
              <div className="admin-drug-results">
                {drugResults.map((d) => (
                  <button
                    key={d.id}
                    type="button"
                    className={`admin-drug-result${form.drug_id === d.id ? ' is-selected' : ''}`}
                    onClick={() => pickDrug(d)}
                  >
                    <span className="admin-drug-result-name">{d.name_pt}</span>
                    {d.class_pt && <span className="admin-drug-result-class">{d.class_pt}</span>}
                  </button>
                ))}
              </div>
            )}
            {searching && <div className="admin-drug-hint">A pesquisar…</div>}
          </div>
          <button
            type="button"
            className="admin-btn admin-btn-secondary"
            onClick={handleGenerate}
            disabled={generating}
            style={{ marginTop: 8 }}
          >
            <Sparkles size={15} />
            {generating ? 'A gerar…' : 'Gerar a partir do fármaco'}
          </button>
        </div>

        <div className="admin-form-field">
          <label className="admin-form-label">Frente (PT) *</label>
          <textarea
            className="admin-form-input"
            rows={2}
            value={form.front_pt}
            onChange={(e) => set('front_pt', e.target.value)}
            required
          />
        </div>
        <div className="admin-form-field">
          <label className="admin-form-label">Frente (EN)</label>
          <textarea
            className="admin-form-input"
            rows={2}
            value={form.front_en}
            onChange={(e) => set('front_en', e.target.value)}
          />
        </div>
        <div className="admin-form-field">
          <label className="admin-form-label">Verso / resposta (PT) *</label>
          <textarea
            className="admin-form-input"
            rows={4}
            value={form.back_pt}
            onChange={(e) => set('back_pt', e.target.value)}
            required
          />
        </div>
        <div className="admin-form-field">
          <label className="admin-form-label">Verso / resposta (EN)</label>
          <textarea
            className="admin-form-input"
            rows={4}
            value={form.back_en}
            onChange={(e) => set('back_en', e.target.value)}
          />
        </div>
        <div className="admin-form-field">
          <label className="admin-form-label">Fonte (nota)</label>
          <input
            className="admin-form-input"
            value={form.source_note}
            onChange={(e) => set('source_note', e.target.value)}
            placeholder="DailyMed / EMC / classificação interna"
          />
        </div>

        {error && <div className="admin-form-error">{error}</div>}

        <button type="submit" className="admin-btn admin-btn-primary" disabled={saving}>
          <Save size={16} /> {saving ? 'A guardar…' : 'Guardar Cartão'}
        </button>
      </form>
    </div>
  )
}
