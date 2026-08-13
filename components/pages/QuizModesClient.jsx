'use client'

import { useContext, useState } from 'react'
import Link from 'next/link'
import { ClipboardList, FlaskConical, Flame, Gauge, Layers, Seedling, ShieldAlert } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

/**
 * QuizModesClient — escolha do modo de quiz: rápido, por deck de
 * flashcards ou por tipo de pergunta (farmacologia/interações/protocolos).
 * O toggle "Guardar progresso / Sem registo" decide se a tentativa é
 * persistida (sessão anónima) ou efémera.
 */
export default function QuizModesClient({ lang = 'pt', decks = [], typeCounts = {} }) {
  const { t } = useContext(LangContext)
  const [save, setSave] = useState(true)
  const qs = save ? '' : '?save=0'

  const levels = [
    {
      level: 'facil',
      icon: Seedling,
      color: '#0a844f',
      count: 8,
      title: t('quiz_page.level_facil'),
      desc: t('quiz_page.level_facil_desc'),
    },
    {
      level: 'medio',
      icon: Gauge,
      color: '#d97706',
      count: 12,
      title: t('quiz_page.level_medio'),
      desc: t('quiz_page.level_medio_desc'),
    },
    {
      level: 'dificil',
      icon: Flame,
      color: '#dc2626',
      count: 16,
      title: t('quiz_page.level_dificil'),
      desc: t('quiz_page.level_dificil_desc'),
    },
  ]

  const types = [
    {
      slug: 'flashcard',
      icon: Layers,
      title: t('quiz_page.type_flashcard'),
      desc: t('quiz_page.type_flashcard_desc'),
      count: typeCounts.flashcard || 0,
    },
    {
      slug: 'pharmacology',
      icon: FlaskConical,
      title: t('quiz_page.type_pharmacology'),
      desc: t('quiz_page.type_pharmacology_desc'),
      count: typeCounts.pharmacology || 0,
    },
    {
      slug: 'interaction',
      icon: ShieldAlert,
      title: t('quiz_page.type_interaction'),
      desc: t('quiz_page.type_interaction_desc'),
      count: typeCounts.interaction || 0,
    },
    {
      slug: 'protocol',
      icon: ClipboardList,
      title: t('quiz_page.type_protocol'),
      desc: t('quiz_page.type_protocol_desc'),
      count: typeCounts.protocol || 0,
    },
  ]

  return (
    <>
      {/* Hero — mesmo padrão de /cientificos e /eventos */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('quiz_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('quiz_page.hero_subtitle')}
            </p>

            {/* Toggle Guardar / Sem registo */}
            <div className="quiz-save-toggle" role="group" aria-label={t('quiz_page.save_label')}>
              <button
                type="button"
                className={`quiz-save-btn${save ? ' active' : ''}`}
                onClick={() => setSave(true)}
                aria-pressed={save}
              >
                {t('quiz_page.save_on')}
              </button>
              <button
                type="button"
                className={`quiz-save-btn${!save ? ' active' : ''}`}
                onClick={() => setSave(false)}
                aria-pressed={!save}
              >
                {t('quiz_page.save_off')}
              </button>
              <span className="quiz-save-hint">
                {save ? t('quiz_page.save_on_desc') : t('quiz_page.save_off_desc')}
              </span>
            </div>
          </div>
        </div>
      </section>

      <section className="bg-brand-bg-alt">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {/* Por nível de dificuldade */}
          <h2 className="quiz-section-title">{t('quiz_page.levels_title')}</h2>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {levels.map((lvl) => {
              const Icon = lvl.icon
              return (
                <Link
                  key={lvl.level}
                  href={`/${lang}/quiz/nivel-${lvl.level}${qs}`}
                  className="quiz-level-card"
                  style={{ '--level-color': lvl.color }}
                >
                  <span className="quiz-level-ic"><Icon size={22} aria-hidden="true" /></span>
                  <span className="quiz-level-count">{lvl.count} {t('quiz_page.questions_label')}</span>
                  <h3 className="quiz-level-name">{lvl.title}</h3>
                  <p className="quiz-level-desc">{lvl.desc}</p>
                  <span className="quiz-level-go">{t('quiz_page.level_cta')} →</span>
                </Link>
              )
            })}
          </div>

          {/* Por deck */}
          <h2 className="quiz-section-title">{t('quiz_page.decks_title')}</h2>
          {decks.length === 0 ? (
            <p className="text-sm text-brand-deep/50">—</p>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {decks.map((deck) => (
                <Link
                  key={deck.slug}
                  href={`/${lang}/quiz/deck-${deck.slug}${qs}`}
                  className="quiz-deck-card"
                  style={{ '--deck-color': deck.color }}
                >
                  <span className="quiz-deck-badge">{deck.cardCount} {t('quiz_page.cards_label')}</span>
                  <h3 className="quiz-deck-name">{deck.name}</h3>
                  <span className="quiz-deck-go">{t('quiz_page.start_deck')} →</span>
                </Link>
              ))}
            </div>
          )}

          {/* Por tipo */}
          <h2 className="quiz-section-title">{t('quiz_page.types_title')}</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {types.map((type) => {
              const Icon = type.icon
              return (
                <Link
                  key={type.slug}
                  href={`/${lang}/quiz/tipo-${type.slug}${qs}`}
                  className="quiz-type-card"
                >
                  <span className="quiz-type-ic"><Icon size={22} aria-hidden="true" /></span>
                  <h3 className="quiz-type-title">{type.title}</h3>
                  <p className="quiz-type-desc">{type.desc}</p>
                  <span className="quiz-type-count">
                    {type.count > 0 ? `${type.count} ${t('quiz_page.questions_label')}` : ''}
                  </span>
                </Link>
              )
            })}
          </div>
        </div>
      </section>
    </>
  )
}
