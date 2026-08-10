'use client'

import { useContext, useMemo, useState } from 'react'
import Link from 'next/link'
import {
  AlertTriangle,
  Apple,
  ArrowUpRight,
  Baby,
  BookOpen,
  Check,
  CheckCircle2,
  ChevronDown,
  Copy,
  Flag,
  HeartPulse,
  Info,
  Library,
  MessageCircle,
  Pill,
  Plus,
  Printer,
  Search,
  Share2,
  ShieldAlert,
  X,
} from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { INTERACOES_FAQ_ITEMS } from '@/lib/interacoes-faq'
import FeedbackBox from '@/components/feedback/FeedbackBox'

// Ordem de apresentação: documentadas primeiro, depois desconhecidas.
// `unknown` = par SEM registo na base (não confundir com `none` da BD,
// que significa interação confirmadamente sem relevância clínica).
const SEVERITY_ORDER = { critical: 0, moderate: 1, minor: 2, none: 3, unknown: 4 }

const SEVERITY_META = {
  critical: { icon: ShieldAlert },
  moderate: { icon: AlertTriangle },
  minor: { icon: Info },
  none: { icon: CheckCircle2 },
  unknown: { icon: BookOpen },
}

function severityLabelKey(severity) {
  return `interacoes_page.severidade_${severity}`
}

// Mapeia a categoria de gestação para uma severidade (barra lateral + filtro).
// Reutiliza as classes .interaction-card.is-* / níveis de severidade existentes.
function pregnancySeverity(category) {
  if (category === 'contraindicated') return 'critical'
  if (category === 'caution') return 'moderate'
  if (category === 'compatible') return 'none'
  return 'unknown'
}

function pregnancyBarClass(category) {
  return `is-${pregnancySeverity(category)}`
}

// Conteúdo estático do FAQ da calculadora (i18n) — partilhado com o server
// para o schema FAQPage (ver lib/interacoes-faq.js).
const FAQ_ITEMS = INTERACOES_FAQ_ITEMS

// Maneiras de filtrar por severidade (chips). Reutiliza os rótulos de severidade.
const SEVERITY_FILTERS = [
  { value: 'all', labelKey: 'interacoes_page.filter_todas' },
  { value: 'critical', labelKey: 'interacoes_page.severidade_critical' },
  { value: 'moderate', labelKey: 'interacoes_page.severidade_moderate' },
  { value: 'minor', labelKey: 'interacoes_page.severidade_minor' },
  { value: 'none', labelKey: 'interacoes_page.severidade_none' },
]

// Fontes reais do seed (domínio público, sem violar direitos autorais):
// cada par é ancorado aos rótulos aprovados pela FDA via DailyMed (NIH/NLM) —
// ver migration 051 — complementados por fontes clínicas NIH (MedlinePlus,
// PubMed). Os RCM oficiais europeus são consultáveis na EMA e, em Portugal,
// no portal do INFARMED (Infomed).
const SOURCES = [
  { name: 'interacoes_page.fonte_dailymed', url: 'https://dailymed.nlm.nih.gov' },
  { name: 'interacoes_page.fonte_medlineplus', url: 'https://medlineplus.gov' },
  { name: 'interacoes_page.fonte_pubmed', url: 'https://pubmed.ncbi.nlm.nih.gov' },
  { name: 'interacoes_page.fonte_ema', url: 'https://www.ema.europa.eu' },
  { name: 'interacoes_page.fonte_infarmed', url: 'https://www.infarmed.pt' },
  { name: 'interacoes_page.fonte_emcuk', url: 'https://www.medicines.org.uk/emc' },
  { name: 'interacoes_page.fonte_healthcanada', url: 'https://health-products.canada.ca/dpd-bdpp/' },
]

// Abas por tipo de interação (Fluxo 1 = fármaco-fármaco; Fluxo 2 = o resto).
const TYPES_TABS = [
  { key: 'tab_farmacos', icon: Pill },
  { key: 'tab_alimentos', icon: Apple },
  { key: 'tab_doencas', icon: HeartPulse },
  { key: 'tab_gravidez', icon: Baby },
]

export default function InteracoesPageClient({
  lang,
  drugs,
  interactions,
  foodInteractions = [],
  diseaseInteractions = [],
  pregnancyInfo = [],
}) {
  const { t } = useContext(LangContext)
  const [activeTab, setActiveTab] = useState(() => {
    if (typeof window === 'undefined') return 0
    const params = new URLSearchParams(window.location.search)
    const tab = parseInt(params.get('aba'), 10)
    return Number.isInteger(tab) && tab >= 0 && tab <= 3 ? tab : 0
  })
  const [severityFilter, setSeverityFilter] = useState('all')
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
  const [copied, setCopied] = useState(false)
  const [copiedSummary, setCopiedSummary] = useState(false)

  // Interação reportada pelo botão "reportar" em cada cartão.
  const [report, setReport] = useState(null) // { interactionType, interactionId, label }

  const setReportFrom = (interactionType, interactionId, label) => {
    setReport({ interactionType, interactionId, label })
  }

  const contexto = `/${lang}/${lang === 'pt' ? 'interacoes' : 'interactions'}`

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
  }

  const clearAll = () => {
    setSelectedIds([])
  }

  // Resultados:
  //  - 1 fármaco → todas as interações DOCUMENTADAS em que esse fármaco participa
  //    (o "explora tudo do primeiro fármaco").
  //  - 2+ fármacos → pares entre os selecionados, marcando unknown os sem registo.
  const results = useMemo(() => {
    const pairs = []
    if (selectedIds.length === 1) {
      const soloId = selectedIds[0]
      interactions.forEach((inter) => {
        let partnerId = null
        if (inter.drugAId === soloId) partnerId = inter.drugBId
        else if (inter.drugBId === soloId) partnerId = inter.drugAId
        if (partnerId == null) return
        pairs.push({ a: soloId, b: partnerId, interaction: inter })
      })
    } else {
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
    }
    const rank = (p) =>
      p.interaction ? SEVERITY_ORDER[p.interaction.severity] : SEVERITY_ORDER.unknown
    return pairs.sort((p1, p2) => {
      const diff = rank(p1) - rank(p2)
      if (diff !== 0) return diff
      return (drugsById[p1.a]?.name || '').localeCompare(drugsById[p2.a]?.name || '')
    })
  }, [selectedIds, interactions, drugsById])

  // Dados por tipo (Fluxo 2), filtrados pelos fármacos selecionados.
  const foodForSelection = useMemo(
    () => foodInteractions.filter((x) => selectedIds.includes(x.drugId)),
    [foodInteractions, selectedIds],
  )
  const diseaseForSelection = useMemo(
    () => diseaseInteractions.filter((x) => selectedIds.includes(x.drugId)),
    [diseaseInteractions, selectedIds],
  )
  // Gestação é 1:1 por fármaco (a chave é drugId).
  const pregnancyForSelection = useMemo(
    () => pregnancyInfo.filter((x) => selectedIds.includes(x.drugId)),
    [pregnancyInfo, selectedIds],
  )

  // Filtro de severidade (aplica-se às 4 abas; gravidez mapeia a categoria).
  const filteredResults = useMemo(
    () =>
      results.filter((p) => {
        const s = p.interaction ? p.interaction.severity : 'unknown'
        return severityFilter === 'all' || severityFilter === s
      }),
    [results, severityFilter],
  )
  const filteredFood = useMemo(
    () => foodForSelection.filter((x) => severityFilter === 'all' || severityFilter === x.severity),
    [foodForSelection, severityFilter],
  )
  const filteredDisease = useMemo(
    () => diseaseForSelection.filter((x) => severityFilter === 'all' || severityFilter === x.severity),
    [diseaseForSelection, severityFilter],
  )
  const filteredPregnancy = useMemo(
    () =>
      pregnancyForSelection.filter(
        (x) => severityFilter === 'all' || severityFilter === pregnancySeverity(x.pregnancyCategory)
      ),
    [pregnancyForSelection, severityFilter],
  )

  const counts = useMemo(() => {
    const c = { critical: 0, moderate: 0, minor: 0, none: 0, unknown: 0 }
    filteredResults.forEach((p) => {
      const s = p.interaction ? p.interaction.severity : 'unknown'
      c[s] += 1
    })
    return c
  }, [filteredResults])

  const calcUrl = () => {
    const slugs = selectedIds.map((id) => drugsById[id]?.slug).filter(Boolean)
    if (slugs.length === 0) return ''
    const qs = slugs.length === 1 ? `?farmaco=${slugs[0]}` : `?farmacos=${slugs.join(',')}`
    return `${window.location.origin}${window.location.pathname}${qs}`
  }

  const handleShare = async () => {
    const url = calcUrl()
    if (!url) return
    try {
      await navigator.clipboard.writeText(url)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // clipboard indisponível — ignora silenciosamente
    }
  }

  const handleCopySummary = async () => {
    if (selectedIds.length === 0) return
    try {
      await navigator.clipboard.writeText(buildSummaryText())
      setCopiedSummary(true)
      setTimeout(() => setCopiedSummary(false), 2000)
    } catch {
      // clipboard indisponível — ignora silenciosamente
    }
  }

  const handleWhatsApp = () => {
    const url = calcUrl()
    if (!url) return
    const text = `${t('interacoes_page.hero_title')} — ${t('interacoes_page.farmacos_a_verificar')}: ${selectedIds
      .map((id) => drugsById[id]?.name)
      .filter(Boolean)
      .join(', ')}`
    window.open(`https://wa.me/?text=${encodeURIComponent(`${text}\n${url}`)}`, '_blank', 'noopener,noreferrer')
  }

  const handlePrint = () => {
    if (typeof window !== 'undefined') window.print()
  }

  // Resumo de texto simples (para copiar/colar) com todas as dimensões.
  const buildSummaryText = () => {
    const sev = (s) => t(severityLabelKey(s))
    const link = calcUrl()
    const drugLine = selectedIds.map((id) => drugsById[id]?.name).filter(Boolean).join(' + ')
    const lines = [`${t('interacoes_page.hero_title')} — ${drugLine}`]
    if (results.length) {
      lines.push('', t('interacoes_page.tab_farmacos') + ':')
      results.forEach((p) => {
        const s = p.interaction ? p.interaction.severity : 'unknown'
        lines.push(`• ${drugsById[p.a]?.name} + ${drugsById[p.b]?.name} — ${sev(s)}${p.interaction?.summary ? `: ${p.interaction.summary}` : ''}`)
      })
    }
    if (foodForSelection.length) {
      lines.push('', t('interacoes_page.tab_alimentos') + ':')
      foodForSelection.forEach((x) => {
        lines.push(`• ${drugsById[x.drugId]?.name} × ${x.entity} — ${sev(x.severity)}${x.mechanism ? `: ${x.mechanism}` : ''}`)
      })
    }
    if (diseaseForSelection.length) {
      lines.push('', t('interacoes_page.tab_doencas') + ':')
      diseaseForSelection.forEach((x) => {
        lines.push(`• ${drugsById[x.drugId]?.name} × ${x.condition} — ${x.interactionType === 'contraindication' ? t('interacoes_page.tipo_contraindicacao') : t('interacoes_page.tipo_precaucao')} (${sev(x.severity)})${x.reason ? `: ${x.reason}` : ''}`)
      })
    }
    if (pregnancyForSelection.length) {
      lines.push('', t('interacoes_page.tab_gravidez') + ':')
      pregnancyForSelection.forEach((x) => {
        lines.push(`• ${drugsById[x.drugId]?.name} — ${x.pregnancyCategory === 'contraindicated' ? t('interacoes_page.tipo_contraindicacao') : t('interacoes_page.categoria_gravidez')} (${sev(pregnancySeverity(x.pregnancyCategory))})${x.risk ? `: ${x.risk}` : ''}`)
      })
    }
    lines.push('', `${t('interacoes_page.disclaimer')}`, link)
    return lines.join('\n')
  }

  const hasSelection = selectedIds.length > 0
  const isSingleDrug = selectedIds.length === 1
  const firstName = drugsById[selectedIds[0]]?.name || ''
  const detailPath = (slug) => `/${lang}/${lang === 'pt' ? 'medicamento' : 'medicine'}/${slug}`

  return (
    <div className="interacoes-page">
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6 break-words">
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

            <span className="flow-hint">{t('interacoes_page.flow_hint')}</span>

            {selectedIds.length > 0 && (
              <button className="clear-btn" onClick={clearAll}>
                {t('interacoes_page.limpar')}
              </button>
            )}

            <p className="disclaimer">{t('interacoes_page.disclaimer')}</p>
          </aside>

          {/* Painel de resultados */}
          <main className="calc-results-panel">
            {/* Barra de abas por tipo de interação */}
            <div
              className="calc-type-tabs faq-tab-bar"
              role="tablist"
              aria-label={t('interacoes_page.tabs_aria_label')}
            >
              {TYPES_TABS.map((tab, i) => (
                <button
                  key={tab.key}
                  role="tab"
                  id={`type-tab-${i}`}
                  aria-selected={activeTab === i}
                  aria-controls={`type-panel-${i}`}
                  className={`faq-tab${activeTab === i ? ' faq-tab--active' : ''}`}
                  onClick={() => setActiveTab(i)}
                >
                  <tab.icon size={15} aria-hidden="true" className="calc-type-tab-icon" />
                  {t(`interacoes_page.${tab.key}`)}
                </button>
              ))}
            </div>

            {/* Barra de ferramentas: filtro de severidade + ações (copiar/partilhar/imprimir) */}
            {hasSelection && (
              <div className="interacoes-toolbar">
                <div
                  className="severity-filters"
                  role="group"
                  aria-label={t('interacoes_page.filter_aria_label')}
                >
                  {SEVERITY_FILTERS.map((f) => (
                    <button
                      key={f.value}
                      className={`severity-filter-chip${severityFilter === f.value ? ' is-active' : ''}`}
                      aria-pressed={severityFilter === f.value}
                      onClick={() => setSeverityFilter(f.value)}
                    >
                      {t(f.labelKey)}
                    </button>
                  ))}
                </div>
                <div className="interacoes-actions">
                  <button className="toolbar-btn" onClick={handleCopySummary}>
                    {copiedSummary ? <Check size={14} aria-hidden="true" /> : <Copy size={14} aria-hidden="true" />}
                    {copiedSummary ? t('interacoes_page.copiado_resumo') : t('interacoes_page.copiar_resumo')}
                  </button>
                  <button className="toolbar-btn" onClick={handleShare}>
                    {copied ? <Check size={14} aria-hidden="true" /> : <Share2 size={14} aria-hidden="true" />}
                    {copied ? t('interacoes_page.copiado') : t('interacoes_page.partilhar')}
                  </button>
                  <button className="toolbar-btn" onClick={handleWhatsApp}>
                    <MessageCircle size={14} aria-hidden="true" />
                    {t('interacoes_page.partilhar_whatsapp')}
                  </button>
                  <button className="toolbar-btn" onClick={handlePrint}>
                    <Printer size={14} aria-hidden="true" />
                    {t('interacoes_page.imprimir')}
                  </button>
                </div>
              </div>
            )}

            {!hasSelection ? (
              <div className="results-empty">
                <div className="search-empty-icon">
                  <Search size={28} aria-hidden="true" />
                </div>
                <p>{t('interacoes_page.adicionar_pelo_menos')}</p>
              </div>
            ) : (
              <>
                {/* ---- Aba 0: Fármaco-fármaco ---- */}
                <div
                  role="tabpanel"
                  id="type-panel-0"
                  className="calc-tab-panel"
                  hidden={activeTab !== 0}
                >
                  {results.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <BookOpen size={28} aria-hidden="true" />
                      </div>
                      <p>
                        {isSingleDrug
                          ? t('interacoes_page.sem_interacoes_farmaco', { name: firstName })
                          : t('interacoes_page.adicionar_pelo_menos')}
                      </p>
                    </div>
                  ) : filteredResults.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <BookOpen size={28} aria-hidden="true" />
                      </div>
                      <p>{t('interacoes_page.filter_sem_resultados')}</p>
                    </div>
                  ) : (
                    <>
                      <div className="results-header">
                        <div className="results-title">
                          {isSingleDrug
                            ? t('interacoes_page.interacoes_de', { name: firstName })
                            : t('interacoes_page.resultados')}
                        </div>
                        <div className="results-count">
                          {filteredResults.length} {t('interacoes_page.interacoes_encontradas')}
                        </div>
                      </div>

                      {isSingleDrug && drugsById[selectedIds[0]]?.slug && (
                        <div className="interacoes-ficha-link">
                          <Link href={detailPath(drugsById[selectedIds[0]].slug)} className="toolbar-btn">
                            <ArrowUpRight size={13} aria-hidden="true" />
                            {t('interacoes_page.ver_ficha_completa', { name: firstName })}
                          </Link>
                        </div>
                      )}

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
                      </div>

                      {filteredResults.map((pair) => {
                        const drugA = drugsById[pair.a]
                        const drugB = drugsById[pair.b]
                        const inter = pair.interaction
                        const severity = inter ? inter.severity : 'unknown'
                        const Icon = SEVERITY_META[severity].icon
                        const hasDetails = inter && (
                          inter.explanation || inter.summaryPro ||
                          inter.mechanism || inter.monitoring || inter.redFlags ||
                          inter.management || inter.source
                        )

                        return (
                          <div key={`${pair.a}-${pair.b}`} className={`interaction-card is-${severity}`}>
                            <div className="card-header">
                              <div className="card-drugs">
                                <span className="card-drug">
                                  {drugA?.slug ? (
                                    <Link href={detailPath(drugA.slug)} className="card-drug-link">{drugA.name}</Link>
                                  ) : (drugA?.name || '—')}
                                </span>
                                <span className="card-vs">+</span>
                                <span className="card-drug">
                                  {drugB?.slug ? (
                                    <Link href={detailPath(drugB.slug)} className="card-drug-link">{drugB.name}</Link>
                                  ) : (drugB?.name || '—')}
                                </span>
                              </div>
                              <span className={`severity-badge is-${severity}`}>
                                <Icon size={12} aria-hidden="true" />
                                {t(severityLabelKey(severity))}
                              </span>
                              <button
                                type="button"
                                className="card-report-btn"
                                onClick={() => setReportFrom('drug_drug', inter?.id || null, `${drugA?.name} + ${drugB?.name}`)}
                                title={t('feedback.reportar_interacao')}
                                aria-label={`${t('feedback.reportar_interacao')}: ${drugA?.name} + ${drugB?.name}`}
                              >
                                <Flag size={12} aria-hidden="true" />
                                {t('feedback.reportar_interacao')}
                              </button>
                            </div>

                            <p className="card-description">
                              {inter ? inter.summary : t('interacoes_page.sem_registo_desc')}
                            </p>

                            {hasDetails && (
                              <details className="card-details">
                                <summary className="card-toggle">
                                  {t('interacoes_page.expandir')}
                                  <ChevronDown size={14} aria-hidden="true" />
                                </summary>
                                <div className="interaction-detail">
                                  {inter.explanation && (
                                    <div className="detail-block detail-explanation">
                                      <h4 className="detail-title">{t('interacoes_page.explicacao')}</h4>
                                      <p>{inter.explanation}</p>
                                    </div>
                                  )}
                                  {inter.summaryPro && (
                                    <div className="detail-block">
                                      <h4 className="detail-title">{t('interacoes_page.resumo_profissionais')}</h4>
                                      <p>{inter.summaryPro}</p>
                                    </div>
                                  )}
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
                              </details>
                            )}
                          </div>
                        )
                      })}
                    </>
                  )}
                </div>

                {/* ---- Aba 1: Alimento / Bebida ---- */}
                <div
                  role="tabpanel"
                  id="type-panel-1"
                  className="calc-tab-panel"
                  hidden={activeTab !== 1}
                >
                  {foodForSelection.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <Apple size={28} aria-hidden="true" />
                      </div>
                      <p>{t('interacoes_page.sem_alimentos_tab')}</p>
                    </div>
                  ) : filteredFood.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <Apple size={28} aria-hidden="true" />
                      </div>
                      <p>{t('interacoes_page.filter_sem_resultados')}</p>
                    </div>
                  ) : (
                    <>
                      <div className="results-header">
                        <div className="results-title">
                          {isSingleDrug
                            ? t('interacoes_page.interacoes_de', { name: firstName })
                            : t('interacoes_page.tab_alimentos')}
                        </div>
                        <div className="results-count">
                          {filteredFood.length} {t('interacoes_page.interacoes_encontradas')}
                        </div>
                      </div>
                      {filteredFood.map((item) => {
                        const Icon = SEVERITY_META[item.severity]?.icon || Info
                        const drugName = drugsById[item.drugId]?.name || '—'
                        return (
                          <div
                            key={`${item.drugId}-${item.entitySlug}`}
                            className={`interaction-card is-${item.severity}`}
                          >
                            <div className="card-header">
                              <div className="card-drugs">
                                <span className="card-drug">{drugName}</span>
                                <span className="card-vs">×</span>
                                <span className="card-drug">{item.entity}</span>
                              </div>
                              <span className={`severity-badge is-${item.severity}`}>
                                <Icon size={12} aria-hidden="true" />
                                {t(severityLabelKey(item.severity))}
                              </span>
                              <button
                                type="button"
                                className="card-report-btn"
                                onClick={() => setReportFrom('food', item.id || null, `${drugName} × ${item.entity}`)}
                                title={t('feedback.reportar_interacao')}
                                aria-label={`${t('feedback.reportar_interacao')}: ${drugName} × ${item.entity}`}
                              >
                                <Flag size={12} aria-hidden="true" />
                                {t('feedback.reportar_interacao')}
                              </button>
                            </div>
                            {item.mechanism && (
                              <p className="card-description">{item.mechanism}</p>
                            )}
                            <details className="card-details">
                              <summary className="card-toggle">
                                {t('interacoes_page.expandir')}
                                <ChevronDown size={14} aria-hidden="true" />
                              </summary>
                              <div className="interaction-detail">
                                {item.advice && (
                                  <div className="detail-block detail-recommendation">
                                    <h4 className="detail-title">{t('interacoes_page.recomendacao')}</h4>
                                    <p>{item.advice}</p>
                                  </div>
                                )}
                                {item.source && (
                                  <div className="detail-block detail-source">
                                    <h4 className="detail-title">{t('interacoes_page.fonte')}</h4>
                                    <p>{item.source}</p>
                                  </div>
                                )}
                              </div>
                            </details>
                          </div>
                        )
                      })}
                    </>
                  )}
                </div>

                {/* ---- Aba 2: Doença ---- */}
                <div
                  role="tabpanel"
                  id="type-panel-2"
                  className="calc-tab-panel"
                  hidden={activeTab !== 2}
                >
                  {diseaseForSelection.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <HeartPulse size={28} aria-hidden="true" />
                      </div>
                      <p>{t('interacoes_page.sem_doencas_tab')}</p>
                    </div>
                  ) : filteredDisease.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <HeartPulse size={28} aria-hidden="true" />
                      </div>
                      <p>{t('interacoes_page.filter_sem_resultados')}</p>
                    </div>
                  ) : (
                    <>
                      <div className="results-header">
                        <div className="results-title">
                          {isSingleDrug
                            ? t('interacoes_page.interacoes_de', { name: firstName })
                            : t('interacoes_page.tab_doencas')}
                        </div>
                        <div className="results-count">
                          {filteredDisease.length} {t('interacoes_page.interacoes_encontradas')}
                        </div>
                      </div>
                      {filteredDisease.map((item) => {
                        const drugName = drugsById[item.drugId]?.name || '—'
                        const isCI = item.interactionType === 'contraindication'
                        return (
                          <div
                            key={`${item.drugId}-${item.conditionSlug}`}
                            className={`interaction-card is-${item.severity}`}
                          >
                            <div className="card-header">
                              <div className="card-drugs">
                                <span className="card-drug">{drugName}</span>
                                <span className="card-vs">×</span>
                                <span className="card-drug">{item.condition}</span>
                              </div>
                              <span className={`type-badge ${isCI ? 'is-ci' : 'is-precaution'}`}>
                                <HeartPulse size={12} aria-hidden="true" />
                                {isCI
                                  ? t('interacoes_page.tipo_contraindicacao')
                                  : t('interacoes_page.tipo_precaucao')}
                              </span>
                              <button
                                type="button"
                                className="card-report-btn"
                                onClick={() => setReportFrom('disease', item.id || null, `${drugName} × ${item.condition}`)}
                                title={t('feedback.reportar_interacao')}
                                aria-label={`${t('feedback.reportar_interacao')}: ${drugName} × ${item.condition}`}
                              >
                                <Flag size={12} aria-hidden="true" />
                                {t('feedback.reportar_interacao')}
                              </button>
                            </div>
                            {item.reason && (
                              <p className="card-description">{item.reason}</p>
                            )}
                            <details className="card-details">
                              <summary className="card-toggle">
                                {t('interacoes_page.expandir')}
                                <ChevronDown size={14} aria-hidden="true" />
                              </summary>
                              <div className="interaction-detail">
                                {item.advice && (
                                  <div className="detail-block detail-recommendation">
                                    <h4 className="detail-title">{t('interacoes_page.recomendacao')}</h4>
                                    <p>{item.advice}</p>
                                  </div>
                                )}
                                {item.source && (
                                  <div className="detail-block detail-source">
                                    <h4 className="detail-title">{t('interacoes_page.fonte')}</h4>
                                    <p>{item.source}</p>
                                  </div>
                                )}
                              </div>
                            </details>
                          </div>
                        )
                      })}
                    </>
                  )}
                </div>

                {/* ---- Aba 3: Gestação ---- */}
                <div
                  role="tabpanel"
                  id="type-panel-3"
                  className="calc-tab-panel"
                  hidden={activeTab !== 3}
                >
                  {pregnancyForSelection.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <Baby size={28} aria-hidden="true" />
                      </div>
                      <p>{t('interacoes_page.sem_gravidez_tab')}</p>
                    </div>
                  ) : filteredPregnancy.length === 0 ? (
                    <div className="results-empty">
                      <div className="search-empty-icon">
                        <Baby size={28} aria-hidden="true" />
                      </div>
                      <p>{t('interacoes_page.filter_sem_resultados')}</p>
                    </div>
                  ) : (
                    <>
                      <div className="results-header">
                        <div className="results-title">
                          {isSingleDrug
                            ? t('interacoes_page.interacoes_de', { name: firstName })
                            : t('interacoes_page.tab_gravidez')}
                        </div>
                        <div className="results-count">
                          {filteredPregnancy.length} {t('interacoes_page.interacoes_encontradas')}
                        </div>
                      </div>
                      {filteredPregnancy.map((item) => {
                        const drugName = drugsById[item.drugId]?.name || '—'
                        const isCI = item.pregnancyCategory === 'contraindicated'
                        return (
                          <div
                            key={item.drugId}
                            className={`interaction-card ${pregnancyBarClass(item.pregnancyCategory)}`}
                          >
                            <div className="card-header">
                              <div className="card-drugs">
                                <span className="card-drug">{drugName}</span>
                              </div>
                              <span className={`type-badge ${isCI ? 'is-ci' : 'is-pregnancy'}`}>
                                <Baby size={12} aria-hidden="true" />
                                {isCI
                                  ? t('interacoes_page.tipo_contraindicacao')
                                  : t('interacoes_page.categoria_gravidez')}
                              </span>
                              <button
                                type="button"
                                className="card-report-btn"
                                onClick={() => setReportFrom('pregnancy', item.id || null, drugName)}
                                title={t('feedback.reportar_interacao')}
                                aria-label={`${t('feedback.reportar_interacao')}: ${drugName}`}
                              >
                                <Flag size={12} aria-hidden="true" />
                                {t('feedback.reportar_interacao')}
                              </button>
                            </div>
                            {item.risk && (
                              <p className="card-description">{item.risk}</p>
                            )}
                            <details className="card-details">
                              <summary className="card-toggle">
                                {t('interacoes_page.expandir')}
                                <ChevronDown size={14} aria-hidden="true" />
                              </summary>
                              <div className="interaction-detail">
                                {item.trimester && (
                                  <div className="detail-block">
                                    <h4 className="detail-title">{t('interacoes_page.trimestre')}</h4>
                                    <p>{item.trimester}</p>
                                  </div>
                                )}
                                {item.lactation && (
                                  <div className="detail-block">
                                    <h4 className="detail-title">{t('interacoes_page.lactacao')}</h4>
                                    <p>{item.lactation}</p>
                                  </div>
                                )}
                                {item.contraception && (
                                  <div className="detail-block detail-recommendation">
                                    <h4 className="detail-title">{t('interacoes_page.contracepcao')}</h4>
                                    <p>{item.contraception}</p>
                                  </div>
                                )}
                                {item.source && (
                                  <div className="detail-block detail-source">
                                    <h4 className="detail-title">{t('interacoes_page.fonte')}</h4>
                                    <p>{item.source}</p>
                                  </div>
                                )}
                              </div>
                            </details>
                          </div>
                        )
                      })}
                    </>
                  )}
                </div>
              </>
            )}
          </main>
        </div>

        {/* ---- Feedback dos leitores ---- */}
        <FeedbackBox
          drugId={null}
          contexto={contexto}
          interactionType={report?.interactionType || null}
          interactionId={report?.interactionId || null}
          interactionLabel={report?.label || null}
          autoOpen={Boolean(report)}
        />

        {/* ---- Secção Fontes ---- */}
        <div className="sources-section">
          <div className="section-heading-row">
            <Library size={18} aria-hidden="true" />
            <h2 className="sources-title">{t('interacoes_page.fontes_title')}</h2>
          </div>
          <p className="sources-subtitle">{t('interacoes_page.fontes_subtitle')}</p>
          <ul className="sources-list">
            {SOURCES.map((s) => (
              <li key={s.name}>
                <a href={s.url} target="_blank" rel="noopener noreferrer">
                  {t(s.name)}
                  <ArrowUpRight size={13} aria-hidden="true" />
                </a>
              </li>
            ))}
          </ul>
        </div>

        {/* ---- Secção FAQ ---- */}
        <div className="interacoes-faq section-padding">
          <div className="container-center max-w-3xl">
            <div className="section-heading text-center mb-8">
              <h2 className="text-3xl md:text-4xl font-bold text-brand-deep">
                {t('interacoes_faq.title')}
              </h2>
              <p className="hero-subtitle text-center">{t('interacoes_faq.subtitle')}</p>
            </div>
            <div className="faq-tabs">
              {FAQ_ITEMS.map((item) => (
                <details className="faq-item" key={item.q}>
                  <summary className="faq-item-summary">
                    <span>{t(item.q)}</span>
                    <ChevronDown size={20} className="faq-item-chevron" />
                  </summary>
                  <div className="faq-item-answer prose prose-muted dark:prose-invert max-w-none">
                    {t(item.a)}
                  </div>
                </details>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}