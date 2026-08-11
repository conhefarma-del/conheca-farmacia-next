'use client'

import { useEffect, useRef, useState, useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { getCitedByCount } from '@/lib/actions/scientific'

/**
 * CitedByBadge — contagem 'Citado por' (OpenAlex, por DOI).
 *
 * Carrega uma única vez por mount (ref guard) através da server action
 * `getCitedByCount`; sem contagem disponível renderiza nada (a UI não
 * quebra em falhas de rede/rate-limit da API externa).
 *
 * Variantes:
 *   - 'chip'  (cards)  → <span class="sci-card-cited">Citado por N</span>
 *   - 'count' (detalhe)→ apenas o número ligado à página OpenAlex do trabalho
 */
export default function CitedByBadge({ doi, variant = 'chip' }) {
  const { t } = useContext(LangContext)
  const fired = useRef(false)
  const [data, setData] = useState(null) // null = carregando/indisponível

  useEffect(() => {
    if (!doi || fired.current) return
    fired.current = true
    getCitedByCount(doi)
      .then((d) => {
        if (d && Number.isFinite(d.count)) setData(d)
      })
      .catch(() => {
        // silencioso — sem chip
      })
  }, [doi])

  if (!data) return null

  const label = t('cientifico_detail.cited_by')
  const count = data.count > 0 ? data.count.toLocaleString() : '0'
  const link = data.workId ? `https://openalex.org/${data.workId}` : null
  const inner = link ? (
    <a
      href={link}
      target="_blank"
      rel="noopener noreferrer"
      className="sci-cited-link"
      title={label}
    >
      {count}
    </a>
  ) : (
    <span>{count}</span>
  )

  if (variant === 'count') return inner
  return (
    <span className="sci-card-cited" title={label}>
      {label} {inner}
    </span>
  )
}
