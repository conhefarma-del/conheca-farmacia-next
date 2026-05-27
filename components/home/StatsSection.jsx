'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'

export default function StatsSection() {
  const { t } = useContext(LangContext)
  const stats = [
    { number: '30+', labelKey: 'home.stats_profissionais' },
    { number: '10+', labelKey: 'home.stats_entrevistas' },
    { number: '3+', labelKey: 'home.stats_eventos' },
    { number: '2k+', labelKey: 'home.stats_leitores' },
  ]

  return (
    <section className="stats-section">
      <div className="container-center">
        <div className="stats-grid">
          {stats.map((stat) => (
            <div key={stat.labelKey} className="stat-item">
              <span className="stat-number">{stat.number}</span>
              <span className="stat-label">
                {t(stat.labelKey)}
              </span>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
