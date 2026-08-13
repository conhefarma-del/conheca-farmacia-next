'use client'

import { useContext, useState } from 'react'
import Link from 'next/link'
import { ClipboardList, FlaskConical, Layers, ShieldAlert, Zap } from 'lucide-react'
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
          {/* Modo rápido */}
          <Link href={`/${lang}/quiz/rapido${qs}`} className="quiz-quick-card">
            <span className="quiz-quick-ic">
              <Zap size={26} aria-hidden="true" />
            </span>
            <div className="quiz-quick-body">
              <h2 className="quiz-quick-title">{t('quiz_page.quick_title')}</h2>
              <p className="quiz-quick-desc">{t('quiz_page.quick_desc')}</p>
            </div>
            <span className="quiz-quick-cta">{t('quiz_page.quick_cta')} →</span>
          </Link>

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
