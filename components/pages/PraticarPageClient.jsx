'use client'

import { useContext } from 'react'
import Link from 'next/link'
import { ArrowRight, BrainCircuit, Layers } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

/**
 * PraticarPageClient — hub de estudo: acesso direto ao Quiz e aos
 * Flashcards, com contagens reais da base de dados.
 */
export default function PraticarPageClient({ lang = 'pt', counts = {}, flashcards = {} }) {
  const { t } = useContext(LangContext)

  return (
    <>
      {/* Hero — mesmo padrão de /cientificos e /eventos */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('praticar_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('praticar_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Dois cartões de acesso */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Quiz */}
            <Link href={`/${lang}/quiz`} className="praticar-card praticar-card-quiz">
              <div className="praticar-card-top">
                <span className="praticar-card-ic">
                  <BrainCircuit size={30} aria-hidden="true" />
                </span>
                <span className="praticar-card-count">
                  {(counts.questionTotal || 0).toLocaleString('pt-PT')} {t('praticar_page.questions_count')}
                </span>
              </div>
              <h2 className="praticar-card-title">{t('praticar_page.quiz_title')}</h2>
              <p className="praticar-card-desc">{t('praticar_page.quiz_desc')}</p>
              <div className="praticar-card-meta">
                {counts.drugs || 0} {t('praticar_page.drugs_label')} · {counts.interactions || 0}{' '}
                {t('praticar_page.interactions_label')} · {counts.protocols || 0} {t('praticar_page.protocols_label')}
              </div>
              <span className="praticar-card-cta">
                {t('praticar_page.quiz_cta')} <ArrowRight size={16} aria-hidden="true" />
              </span>
            </Link>

            {/* Flashcards */}
            <Link href={`/${lang}/flashcards`} className="praticar-card praticar-card-flash">
              <div className="praticar-card-top">
                <span className="praticar-card-ic">
                  <Layers size={30} aria-hidden="true" />
                </span>
                <span className="praticar-card-count">
                  {flashcards.cards || 0} {t('praticar_page.cards_count')} · {flashcards.decks || 0}{' '}
                  {t('praticar_page.decks_count')}
                </span>
              </div>
              <h2 className="praticar-card-title">{t('praticar_page.flashcards_title')}</h2>
              <p className="praticar-card-desc">{t('praticar_page.flashcards_desc')}</p>
              <div className="praticar-card-meta">
                {t('praticar_page.spaced_label')} · {t('praticar_page.progress_label')}
              </div>
              <span className="praticar-card-cta">
                {t('praticar_page.flashcards_cta')} <ArrowRight size={16} aria-hidden="true" />
              </span>
            </Link>
          </div>
        </div>
      </section>
    </>
  )
}
