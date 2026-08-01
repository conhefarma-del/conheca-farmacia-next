'use client'

import { useContext, useEffect, useMemo, useState } from 'react'
import {
  ArrowUpRight, CalendarDays, CheckCircle2, Clock, Copy, Download, ListChecks, Share2,
  ShieldAlert, TriangleAlert, Zap,
} from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { getSectionHref } from '@/lib/i18n-routes'
import Breadcrumb from '@/components/ui/Breadcrumb'
import ProtocolStep from '@/components/protocolos/ProtocolStep'
import ProtocolSidebar from '@/components/protocolos/ProtocolSidebar'
import ProtocolQuiz from '@/components/protocolos/ProtocolQuiz'

function estimateReadingTime(protocol) {
  const text = [
    protocol.summary,
    protocol.safetyNotes,
    protocol.redFlags,
    ...protocol.steps.map((s) => `${s.label} ${s.title} ${s.body}`),
  ].join(' ')
  return Math.max(1, Math.round(text.split(/\s+/).filter(Boolean).length / 200))
}

function formatMonthYear(iso, lang) {
  if (!iso) return ''
  try {
    return new Intl.DateTimeFormat(lang === 'pt' ? 'pt-PT' : 'en-US', {
      month: 'long', year: 'numeric',
    }).format(new Date(iso))
  } catch {
    return iso.slice(0, 7)
  }
}

export default function ProtocoloDetailClient({ lang, protocol }) {
  const { t } = useContext(LangContext)
  const storageKey = `cf_protocolo_progress_${protocol.slug}`

  const [done, setDone] = useState(() => {
    if (typeof window === 'undefined') return []
    try { return JSON.parse(localStorage.getItem(storageKey) || '[]') } catch { return [] }
  })
  const [copied, setCopied] = useState(false)
  const total = protocol.steps.length
  const readingMin = useMemo(() => estimateReadingTime(protocol), [protocol])

  useEffect(() => {
    try { localStorage.setItem(storageKey, JSON.stringify(done)) } catch { /* privado/erro */ }
  }, [done, storageKey])

  const toggleStep = (id) =>
    setDone((d) => (d.includes(id) ? d.filter((x) => x !== id) : [...d, id]))

  const pageUrl = typeof window !== 'undefined'
    ? window.location.href
    : `/${lang}/protocolos/${protocol.slug}`

  const share = async () => {
    if (typeof navigator !== 'undefined' && navigator.share) {
      try { await navigator.share({ title: protocol.title, url: pageUrl }) } catch { /* cancelado */ }
      return
    }
    window.open(`https://wa.me/?text=${encodeURIComponent(`${protocol.title} — ${pageUrl}`)}`, '_blank', 'noopener')
  }

  const copyLink = async () => {
    try {
      await navigator.clipboard.writeText(pageUrl)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch { /* clipboard indisponível */ }
  }

  const mentionedDrugs = useMemo(() => {
    const seen = new Set()
    const out = []
    for (const s of protocol.steps) {
      for (const d of s.drugs) {
        const key = d.label.toLowerCase()
        if (!seen.has(key)) { seen.add(key); out.push(d.label) }
      }
    }
    return out
  }, [protocol])

  return (
    <div className="protocol-detail">
      <Breadcrumb items={[
        { label: t('nav.inicio'), href: '/' + lang },
        { label: t('protocolos_detalhe.breadcrumb_protocolos'), href: getSectionHref(lang, 'protocolos') },
        { label: protocol.category.name, href: getSectionHref(lang, 'protocolos') },
        { label: protocol.title },
      ]} />

      {total > 0 && (
        <div className="protocol-progress">
          <div className="protocol-progress-track">
            <div className="protocol-progress-fill" style={{ width: `${Math.round((done.length / total) * 100)}%` }} />
          </div>
          <span className="protocol-progress-label">
            {t('protocolos_detalhe.passo')} {done.length} {t('protocolos_detalhe.de')} {total}
          </span>
        </div>
      )}

      <div className="protocol-detail-layout">
        <main>
          <div className="protocol-hero">
            <span className="protocol-category">{protocol.category.name}</span>
            <h1>{protocol.title}</h1>
            <div className="protocol-hero-meta">
              <span className="protocol-meta-item">
                <CalendarDays size={14} aria-hidden="true" />
                {t('protocolos_detalhe.actualizado_em')}: {formatMonthYear(protocol.updatedAt, lang)}
              </span>
              <span className="protocol-meta-sep">·</span>
              <span className="protocol-meta-item">
                <ListChecks size={14} aria-hidden="true" />
                {total} {t('protocolos_detalhe.passos')}
              </span>
              <span className="protocol-meta-sep">·</span>
              <span className="protocol-meta-item">
                <Clock size={14} aria-hidden="true" />
                {readingMin} {t('protocolos_detalhe.minutos_leitura')}
              </span>
            </div>
          </div>

          {protocol.summary && (
            <div className="quick-summary">
              <Zap size={20} className="qs-icon" aria-hidden="true" />
              <div className="qs-body">
                <div className="qs-title">{t('protocolos_detalhe.resumo_rapido')}</div>
                <p className="qs-text">{protocol.summary}</p>
              </div>
            </div>
          )}

          {protocol.redFlags && (
            <div className="red-flags-box">
              <ShieldAlert size={18} className="rf-icon" aria-hidden="true" />
              <div>
                <div className="rf-title">{t('protocolos_detalhe.sinais_alarme')}</div>
                <p className="rf-body">{protocol.redFlags}</p>
              </div>
            </div>
          )}

          {total > 0 && (
            <section className="steps-section">
              <div className="steps-title">{t('protocolos_detalhe.passo_a_passo')}</div>
              {protocol.steps.map((step, i) => (
                <ProtocolStep
                  key={step.id}
                  step={step}
                  index={i}
                  done={done.includes(step.id)}
                  onToggle={() => toggleStep(step.id)}
                  t={t}
                />
              ))}
            </section>
          )}

          {protocol.safetyNotes && (
            <div className="notes-box">
              <TriangleAlert size={18} className="notes-icon" aria-hidden="true" />
              <div>
                <div className="notes-title">{t('protocolos_detalhe.notas_seguranca')}</div>
                <p className="notes-body">{protocol.safetyNotes}</p>
              </div>
            </div>
          )}

          {protocol.source && (
            <div className="provenance-box">
              <div className="provenance-title">{t('protocolos_detalhe.o_que_diz_a_norma')}</div>
              <p className="provenance-text">{protocol.source}</p>
              {protocol.sourceUrl && (
                <a href={protocol.sourceUrl} target="_blank" rel="noopener noreferrer" className="provenance-link">
                  {t('protocolos_detalhe.fonte_oficial')}
                  <ArrowUpRight size={14} aria-hidden="true" />
                </a>
              )}
            </div>
          )}

          {protocol.quizzes.length > 0 && <ProtocolQuiz quizzes={protocol.quizzes} t={t} />}

          <div className="protocol-share-row">
            <a
              href={`https://wa.me/?text=${encodeURIComponent(`${protocol.title} — ${pageUrl}`)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="protocol-share-btn"
            >
              <Share2 size={16} aria-hidden="true" />
              {t('protocolos_detalhe.partilhar')}
            </a>
            <button className="protocol-share-btn" onClick={copyLink}>
              {copied ? <CheckCircle2 size={16} aria-hidden="true" /> : <Copy size={16} aria-hidden="true" />}
              {copied ? t('protocolos_detalhe.copiado') : t('protocolos_detalhe.copiar_link')}
            </button>
          </div>
        </main>

        <ProtocolSidebar protocol={protocol} mentionedDrugs={mentionedDrugs} t={t} />
      </div>

      <div className="protocol-mobile-bar">
        {protocol.pdfUrl && (
          <a href={protocol.pdfUrl} target="_blank" rel="noopener noreferrer" className="protocol-mobile-btn protocol-mobile-btn--secondary">
            <Download size={16} aria-hidden="true" />
            {t('protocolos_detalhe.descarregar_pdf')}
          </a>
        )}
        <button onClick={share} className="protocol-mobile-btn protocol-mobile-btn--primary">
          <Share2 size={16} aria-hidden="true" />
          {t('protocolos_detalhe.partilhar')}
        </button>
      </div>
    </div>
  )
}
