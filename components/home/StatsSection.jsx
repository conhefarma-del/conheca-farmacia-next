'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { BookOpen, Calendar, Video, Mail } from 'lucide-react'

const FEATURES = [
  {
    icon: BookOpen,
    labelKey: 'home.stats_artigos_label',
    descKey: 'home.stats_artigos_desc',
  },
  {
    icon: Calendar,
    labelKey: 'home.stats_eventos_label',
    descKey: 'home.stats_eventos_desc',
  },
  {
    icon: Video,
    labelKey: 'home.stats_lives_label',
    descKey: 'home.stats_lives_desc',
  },
  {
    icon: Mail,
    labelKey: 'home.stats_newsletter_label',
    descKey: 'home.stats_newsletter_desc',
  },
]

export default function StatsSection() {
  const { t } = useContext(LangContext)

  return (
    <section className="stats-section">
      <div className="container-center">
        <div className="stats-grid">
          {FEATURES.map(({ icon: Icon, labelKey, descKey }) => (
            <div key={labelKey} className="stat-item">
              <Icon className="stat-icon" />
              <span className="stat-label">{t(labelKey)}</span>
              <span className="stat-desc">{t(descKey)}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}