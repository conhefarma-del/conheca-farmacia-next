'use client'

import { useState, useContext } from 'react'
import { LangContext } from '@/lib/contexts'

export default function SpeakersList({ hosts = [], categoryColor }) {
  const { t } = useContext(LangContext)
  const [showAll, setShowAll] = useState(false)
  const color = categoryColor || '#00493a'

  if (!hosts || !hosts.length) return null

  const isMobile = typeof window !== 'undefined' && window.innerWidth < 768
  const initialLimit = isMobile ? 2 : 3
  const shouldShowButton = hosts.length > initialLimit
  const visibleHosts = showAll ? hosts : hosts.slice(0, initialLimit)

  return (
    <section className="speakers-section mt-16">
      <h3 className="speakers-title">
        {t('evento_detail.speakers_title') || 'Conheça os Palestrantes'}
      </h3>
      <div className="speakers-grid">
        {hosts.map((host, i) => {
          const initials = host.name
            ? host.name.split(' ').map((n) => n[0]).join('').substring(0, 2).toUpperCase()
            : '??'
          const isHidden = !showAll && i >= initialLimit

          return (
            <div
              key={i}
              className={`speaker-card${isHidden ? ' speaker-card--hidden' : ''}`}
            >
              <div className="speaker-card-avatar" style={{ backgroundColor: color }}>
                {initials}
              </div>
              <div className="speaker-card-name">{host.name}</div>
              {host.role && <div className="speaker-card-role">{host.role}</div>}
              {host.organization && <div className="speaker-card-organization">{host.organization}</div>}
            </div>
          )
        })}
      </div>
      {shouldShowButton && (
        <div className="text-center">
          {!showAll ? (
            <button
              onClick={() => setShowAll(true)}
              className="speaker-show-more-btn"
            >
              Mostrar mais {hosts.length - initialLimit} palestrantes
            </button>
          ) : (
            <button
              onClick={() => setShowAll(false)}
              className="speaker-show-less-btn"
            >
              Ocultar palestrantes
            </button>
          )}
        </div>
      )}
    </section>
  )
}
