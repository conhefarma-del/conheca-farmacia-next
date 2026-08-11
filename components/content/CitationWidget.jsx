'use client'

import { useState, useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { formatCitation } from '@/lib/citation'
import { Copy, Check, Download } from 'lucide-react'

const STYLES = ['abnt', 'apa', 'vancouver', 'ris', 'bibtex']

/**
 * CitationWidget — citação do artigo em ABNT/APA/Vancouver + copiar.
 * Layout do design demo 2026-08-11 (tabs + corpo monospace + botão).
 */
export default function CitationWidget({ article, url }) {
  const { t } = useContext(LangContext)
  const [style, setStyle] = useState('abnt')
  const [copied, setCopied] = useState(false)

  const citation = formatCitation(article, style, url)
  const isFileStyle = style === 'ris' || style === 'bibtex'
  const fileName = `${article.slug || 'artigo-cientifico'}.${style === 'ris' ? 'ris' : 'bib'}`

  const handleDownload = () => {
    try {
      const blob = new Blob([citation], { type: 'text/plain;charset=utf-8' })
      const href = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = href
      a.download = fileName
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(href)
    } catch {
      // silencioso
    }
  }

  const handleCopy = async () => {
    try {
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(citation)
      } else {
        const ta = document.createElement('textarea')
        ta.value = citation
        document.body.appendChild(ta)
        ta.select()
        document.execCommand('copy')
        document.body.removeChild(ta)
      }
      setCopied(true)
      setTimeout(() => setCopied(false), 1500)
    } catch {
      // silencioso
    }
  }

  return (
    <div className="citation-widget">
      <div className="citation-tabs" role="tablist" aria-label={t('cientifico_detail.citation')}>
        {STYLES.map((s) => (
          <button
            key={s}
            type="button"
            role="tab"
            aria-selected={style === s}
            className={`citation-tab${style === s ? ' active' : ''}`}
            onClick={() => setStyle(s)}
          >
            {t(`cientifico_detail.${s}`)}
          </button>
        ))}
      </div>
      <div className="citation-body" aria-live="polite">
        {citation}
      </div>
      <div className="citation-actions">
        <button type="button" className="citation-copy-btn" onClick={handleCopy}>
          {copied ? <Check size={14} /> : <Copy size={14} />}
          {copied ? t('cientifico_detail.copied') : t('cientifico_detail.copy_citation')}
        </button>
        {isFileStyle && (
          <button type="button" className="citation-copy-btn" onClick={handleDownload}>
            <Download size={14} /> {t('cientifico_detail.download')}
          </button>
        )}
      </div>
    </div>
  )
}
