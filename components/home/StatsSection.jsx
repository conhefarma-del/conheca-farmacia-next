'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { BookOpen, Calendar, Video, Mail } from 'lucide-react'
import NewsletterForm from '@/components/ui/NewsletterForm'

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
      {/* Motivo decorativo: pílulas + cruz */}
      <div className="stats-motif" aria-hidden="true">
        <span className="stats-pill stats-pill--1">
          <span className="stats-pill-body"><span className="stats-pill-half stats-pill-half--a" /><span className="stats-pill-half stats-pill-half--b" /></span>
        </span>
        <span className="stats-pill stats-pill--2">
          <span className="stats-pill-body"><span className="stats-pill-half stats-pill-half--a" /><span className="stats-pill-half stats-pill-half--b" /></span>
        </span>
        <span className="stats-pill stats-pill--3">
          <span className="stats-pill-body"><span className="stats-pill-half stats-pill-half--a" /><span className="stats-pill-half stats-pill-half--b" /></span>
        </span>
        <span className="stats-cross" />
      </div>

      <div className="container-center">
        <div className="stats-head">
          <span className="stats-eyebrow">{t('home.stats_eyebrow')}</span>
          <h2 className="stats-title">
            {t('home.stats_title_pre')}{' '}
            <span className="stats-accent">{t('home.stats_title_accent')}</span>{' '}
            {t('home.stats_title_post')}
          </h2>
          <p className="stats-subtitle">{t('home.stats_subtitle')}</p>
        </div>

        <div className="stats-tiles">
          {FEATURES.map(({ icon: Icon, labelKey, descKey }) => (
            <div key={labelKey} className="stats-tile">
              <div className="stats-tile-icon">
                <Icon size={26} strokeWidth={1.8} aria-hidden="true" />
              </div>
              <h3>{t(labelKey)}</h3>
              <p>{t(descKey)}</p>
            </div>
          ))}
        </div>

        <div className="stats-newsletter">
          <h3 className="stats-newsletter-title">{t('home.stats_newsletter_title')}</h3>
          <p className="stats-newsletter-sub">{t('home.stats_newsletter_sub')}</p>
          <NewsletterForm keys="home" variant="light" />
          <p className="stats-newsletter-privacy">{t('home.newsletter_privacy')}</p>
        </div>
      </div>
    </section>
  )
}
