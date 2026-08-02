'use client'

import { useContext, useMemo, useState } from 'react'
import {
  AlertTriangle,
  ArrowUpRight,
  Check,
  CheckCircle2,
  ChevronDown,
  Info,
  Plus,
  Search,
  Share2,
  ShieldAlert,
  X,
} from 'lucide-react'
import { LangContext } from '@/lib/contexts'

const SEVERITY_ORDER = { critical: 0, moderate: 1, minor: 2, none: 3 }

const SEVERITY_META = {
  critical: { icon: ShieldAlert },
  moderate: { icon: AlertTriangle },
  minor: { icon: Info },
  none: { icon: CheckCircle2 },
}

function severityLabelKey(severity) {
  return `interacoes_page.severidade_${severity}`
}

export default function InteracoesPageClient({ lang, drugs, interactions }) {
  const { t } = useContext(LangContext)
  const [selectedIds, setSelectedIds] = useState(() => {
    if (typeof window === 'undefined') return []
    const params = new URLSearchParams(window.location.search)
    const list = params.get('farmacos')
    if (list) {
      const slugs = list.split(',').map((s) => s.trim()).filter(Boolean)
      const ids = drugs.filter((d) => slugs.includes(d.slug)).map((d) => d.id)
      if (ids.length) return ids
    }
    const single = params.get('farmaco')
    if (single) {
      const d = drugs.find((x) => x.slug === single)
      if (d) return [d.id]
    }
    return []
  })
  const [query, setQuery] = useState('')
  const [focused, setFocused] = useState(false)
  const [verified, setVerified] = useState(false)
  const [expanded, setExpanded] = useState({})
  const [copied, setCopied] = useState(false)

  const drugsById = useMemo(() => {
    const map = {}
    drugs.forEach((d) => { map[d.id] = d })
    return map
  }, [drugs])

  // Autocomplete: nome, classe ou alias
  const suggestions = useMemo(() => {
    const q = query.trim().toLowerCase()
    if (!q) return []
    return drugs
      .filter((d) => !selectedIds.includes(d.id))
      .filter((d) =>
        d.name.toLowerCase().includes(q) ||
        d.className.toLowerCase().includes(q) ||
        (d.aliases || []).some((a) => a.toLowerCase().includes(q))
      )
      .slice(0, 8)
  }, [query, drugs, selectedIds])

  const addDrug = (id) => {
    if (selectedIds.includes(id)) return
    setSelectedIds([...selectedIds, id])
    setQuery('')
  }

  const removeDrug = (id) => {
    setSelectedIds(selectedIds.filter((x) => x !== id))
    setExpanded({})
  }

  const clearAll = () => {
    setSelectedIds([])
    setVerified(false)
    setExpanded({})
  }

  // Todos os pares possíveis, com a interação documentada (se existir)
  const results = useMemo(() => {
    const pairs = []
    for (let i = 0; i < selectedIds.length; i++) {
      for (let j = i + 1; j < selectedIds.length; j++) {
        const a = selectedIds[i]
        const b = selectedIds[j]
        const inter = interactions.find(
          (x) =>
            (x.drugAId === a && x.drugBId === b) ||
            (x.drugAId === b && x.drugBId === a)
        ) || null
        pairs.push({ a, b, interaction: inter })
      }
    }
    const rank = (p) =>
      p.interaction ? SEVERITY_ORDER[p.interaction.severity] : SEVERITY_ORDER.none
    return pairs.sort((p1, p2) => {
      const diff = rank(p1) - rank(p2)
      if (diff !== 0) return diff
      return (drugsById[p1.a]?.name || '').localeCompare(drugsById[p2.a]?.name || '')
    })
  }, [selectedIds, interactions, drugsById])

  const counts = useMemo(() => {
    const c = { critical: 0, moderate: 0, minor: 0, none: 0 }
    results.forEach((p) => {
      const s = p.interaction ? p.interaction.severity : 'none'
      c[s] += 1
    })
    return c
  }, [results])

  const handleVerify = () => {
    setVerified(true)
  }

  const toggleExpand = (key) => {
    setExpanded((prev) => ({ ...prev, [key]: !prev[key] }))
  }

  const handleShare = async () => {
    const slugs = selectedIds.map((id) => drugsById[id]?.slug).filter(Boolean)
    if (slugs.length === 0) return
    const url = `${window.location.origin}${window.location.pathname}?farmacos=${slugs.join(',')}`
    try {
      await navigator.clipboard.writeText(url)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // clipboard indisponível — ignora silenciosamente
    }
  }

  const canVerify = selectedIds.length >= 2
  const showResults = verified && canVerify

  return (
    <>
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('interacoes_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('interacoes_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      <div className="container-center">
        <div className="calc-layout">
          {/* Painel de input */}
          <aside className="calc-input-panel">
            <div className="panel-title">{t('interacoes_page.farmacos_a_verificar')}</div>

            {/* Fármacos selecionados */}
            {selectedIds.length > 0 && (
              <div className="selected-drugs-bar">
                {selectedIds.map((id, i) => {
                  const d = drugsById[id]
                  if (!d) return null
                  return (
                    <span key={id} className="drug-tag">
                      <span className="drug-tag-num">{i + 1}</span>
                      {d.name}
                      <button
                        className="drug-tag-remove"
                        onClick={() => removeDrug(id)}
                        aria-label={d.name}
                      >
                        <X size={14} aria-hidden="true" />
                      </button>
                    </span>
                  )
                })}
              </div>
            )}

            {/* Autocomplete */}
            <div className="drug-input-group">
              <div className="drug-input-wrap">
                <Search size={16} className="drug-input-icon" aria-hidden="true" />
                <input
                  type="text"
                  className="drug-input"
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  onFocus={() => setFocused(true)}
                  onBlur={() => setTimeout(() => setFocused(false), 150)}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' && suggestions[0]) addDrug(suggestions[0].id)
                  }}
                  placeholder={t('interacoes_page.placeholder_farmaco')}
                />
              </div>
              {focused && suggestions.length > 0 && (
                <div className="suggestions-dropdown">
                  {suggestions.map((d) => (
                    <button
                      key={d.id}
                      className="suggestion-item"
                      onMouseDown={(e) => e.preventDefault()}
                      onClick={() => addDrug(d.id)}
                    >
                      <span className="suggestion-name">{d.name}</span>
                      {d.className && <span className="suggestion-detail">{d.className}</span>}
                    </button>
                  ))}
                </div>
              )}
            </div>

            <button
              className="add-btn"
              onClick={() => setFocused(true)}
            >
              <Plus size={14} aria-hidden="true" />
              {t('interacoes_page.adicionar_outro')}
            </button>

            <button className="check-btn" onClick={handleVerify} disabled={!canVerify}>
              {t('interacoes_page.verificar')}
            </button>

            {selectedIds.length > 1 && (
              <button className="clear-btn" onClick={clearAll}>
                {t('interacoes_page.limpar')}
              </button>
            )}

            <p className="disclaimer">{t('interacoes_page.disclaimer')}</p>
          </aside>

          {/* Painel de resultados */}
          <main className="calc-results-panel">
            {!showResults ? (
              <div className="results-empty">
                <div className="search-empty-icon">
                  <Search size={28} aria-hidden="true" />
                </div>
                <p>{t('interacoes_page.adicionar_pelo_menos')}</p>
              </div>
            ) : (
              <>
                <div className="results-header">
                  <div className="results-title">{t('interacoes_page.resultados')}</div>
                  <div className="results-count">
                    {results.length} {t('interacoes_page.interacoes_encontradas')}
                  </div>
                </div>

                {(counts.critical > 0 || counts.moderate > 0 || counts.minor > 0) && (
                  <div className="interaction-summary-bar">
                    {counts.critical > 0 && (
                      <span className="summary-chip is-critical">
                        <ShieldAlert size={13} aria-hidden="true" />
                        {counts.critical} {t('interacoes_page.severidade_critical')}
                        {counts.critical !== 1 ? 's' : ''}
                      </span>
                    )}
                    {counts.moderate > 0 && (
                      <span className="summary-chip is-moderate">
                        <AlertTriangle size={13} aria-hidden="true" />
                        {counts.moderate} {t('interacoes_page.severidade_moderate')}
                        {counts.moderate !== 1 ? 's' : ''}
                      </span>
                    )}
                    {counts.minor > 0 && (
                      <span className="summary-chip is-minor">
                        <Info size={13} aria-hidden="true" />
                        {counts.minor} {t('interacoes_page.severidade_minor')}
                        {counts.minor !== 1 ? 's' : ''}
                      </span>
                    )}
                  </div>
                )}

                <div className="selected-drugs-bar">
                  {selectedIds.map((id) => {
                    const d = drugsById[id]
                    if (!d) return null
                    return <span key={id} className="drug-tag">{d.name}</span>
                  })}
                  <button className="share-btn" onClick={handleShare}>
                    {copied ? (
                      <Check size={13} aria-hidden="true" />
                    ) : (
                      <Share2 size={13} aria-hidden="true" />
                    )}
                    {copied ? t('interacoes_page.copiado') : t('interacoes_page.partilhar')}
                  </button>
                </div>

                {results.map((pair) => {
                  const drugA = drugsById[pair.a]
                  const drugB = drugsById[pair.b]
                  const inter = pair.interaction
                  const severity = inter ? inter.severity : 'none'
                  const Icon = SEVERITY_META[severity].icon
                  const key = `${pair.a}-${pair.b}`
                  const isExpanded = !!expanded[key]
                  const hasDetails = inter && (
                    inter.mechanism || inter.monitoring || inter.redFlags ||
                    inter.management || inter.source
                  )

                  return (
                    <div key={key} className={`interaction-card is-${severity}`}>
                      <div className="card-header">
                        <div className="card-drugs">
                          <span className="card-drug">{drugA?.name || '—'}</span>
                          <span className="card-vs">+</span>
                          <span className="card-drug">{drugB?.name || '—'}</span>
                        </div>
                        <span className={`severity-badge is-${severity}`}>
                          <Icon size={12} aria-hidden="true" />
                          {t(severityLabelKey(severity))}
                        </span>
                      </div>

                      <p className="card-description">
                        {inter ? inter.summary : t('interacoes_page.sem_registo_desc')}
                      </p>

                      {hasDetails && (
                        <button
                          className="card-toggle"
                          onClick={() => toggleExpand(key)}
                          aria-expanded={isExpanded}
                        >
                          {t(isExpanded ? 'interacoes_page.recolher' : 'interacoes_page.expandir')}
                          <ChevronDown
                            size={14}
                            aria-hidden="true"
                            className={isExpanded ? 'is-open' : ''}
                          />
                        </button>
                      )}

                      {isExpanded && inter && (
                        <div className="interaction-detail">
                          {inter.mechanism && (
                            <div className="detail-block">
                              <h4 className="detail-title">{t('interacoes_page.mecanismo')}</h4>
                              <p>{inter.mechanism}</p>
                            </div>
                          )}
                          {inter.monitoring && (
                            <div className="detail-block">
                              <h4 className="detail-title">{t('interacoes_page.monitorizacao')}</h4>
                              <p>{inter.monitoring}</p>
                            </div>
                          )}
                          {inter.redFlags && (
                            <div className="detail-block detail-red-flags">
                              <h4 className="detail-title">
                                <ShieldAlert size={13} aria-hidden="true" />
                                {t('interacoes_page.sinais_alerta')}
                              </h4>
                              <p>{inter.redFlags}</p>
                            </div>
                          )}
                          {inter.management && (
                            <div className="detail-block detail-recommendation">
                              <h4 className="detail-title">{t('interacoes_page.recomendacao')}</h4>
                              <p>{inter.management}</p>
                            </div>
                          )}
                          {inter.source && (
                            <div className="detail-block detail-source">
                              <h4 className="detail-title">{t('interacoes_page.fonte')}</h4>
                              <p>
                                {inter.source}
                                {inter.sourceUrl && (
                                  <a
                                    href={inter.sourceUrl}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                  >
                                    <ArrowUpRight size={13} aria-hidden="true" />
                                  </a>
                                )}
                              </p>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  )
                })}
              </>
            )}
          </main>
        </div>
      </div>
    </>
  )
}
