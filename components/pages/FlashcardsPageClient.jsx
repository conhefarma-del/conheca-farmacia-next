'use client'

import { useEffect, useState, useMemo, useContext } from 'react'
import Link from 'next/link'
import { AlertTriangle, Brain, Clock3, Database, Search } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import FilterButtons from '@/components/ui/FilterButtons'
import { useAnonymousSession } from '@/hooks/useAnonymousSession'
import { getFlashcardsReviewOverview } from '@/lib/actions/flashcards'

/**
 * FlashcardsPageClient — página principal dos flashcards no padrão de
 * /cientificos e /eventos: hero grande (events-hero) com pesquisa e filtros
 * dentro, e secção de cards com fundo alternado (bg-brand-bg-alt).
 * As contagens de revisão (devidos/dominados/acerto) são carregadas após
 * garantir a sessão anónima.
 */
export default function FlashcardsPageClient({ decks = [], lang = 'pt' }) {
  const { t } = useContext(LangContext)
  const { status, error: sessionError } = useAnonymousSession()
  const [overview, setOverview] = useState(null)
  const [filter, setFilter] = useState('all')
  const [query, setQuery] = useState('')

  useEffect(() => {
    if (status !== 'ready') return
    let cancelled = false
    getFlashcardsReviewOverview().then((data) => {
      if (!cancelled) setOverview(data)
    })
    return () => {
      cancelled = true
    }
  }, [status])

  // Filtros por deck (padrão FilterButtons de /cientificos)
  const deckCategories = useMemo(() => {
    const o = {}
    decks.forEach((d) => { o[d.slug] = d.name })
    return o
  }, [decks])

  const filtered = decks.filter((d) => {
    if (filter !== 'all' && d.slug !== filter) return false
    const q = query.trim().toLowerCase()
    if (!q) return true
    return (
      d.name?.toLowerCase().includes(q) ||
      (d.description || '').toLowerCase().includes(q) ||
      (d.atcPrefix || '').toLowerCase().includes(q)
    )
  })

  const duePerDeck = overview?.perDeck || {}
  const dueTotal = overview?.dueTotal ?? 0

  // Deck com mais devidos para o CTA "Começar revisão"
  const mostDueDeck = decks
    .map((d) => ({ deck: d, due: duePerDeck[d.id] || 0 }))
    .sort((a, b) => b.due - a.due)[0]

  return (
    <>
      {/* Hero — mesmo tamanho de /cientificos e /eventos, com pesquisa + filtros dentro */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('flashcards_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('flashcards_page.hero_subtitle')}
            </p>

            {/* Pesquisa */}
            <div className="max-w-3xl mx-auto mt-10 relative">
              <Search
                size={18}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-brand-deep/40"
                aria-hidden="true"
              />
              <input
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder={t('flashcards_page.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>

            {/* Filtros por deck */}
            <div className="sci-filters flex flex-wrap items-center justify-center gap-3 mt-6">
              <FilterButtons
                categories={deckCategories}
                activeFilter={filter}
                onFilterChange={setFilter}
                dataAttr="flash-filter"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Secção abaixo do hero — fundo alternado, como /cientificos */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {/* Painel de revisão */}
          <div className="flash-review-grid mb-10">
            <div className="flash-review-card flash-review-due">
              <div className="flash-review-num">{status === 'loading' ? '…' : dueTotal}</div>
              <div className="flash-review-lbl">{t('flashcards_page.due_today')}</div>
              {dueTotal > 0 && mostDueDeck && (
                <Link href={`/${lang}/flashcards/${mostDueDeck.deck.slug}`} className="flash-review-cta">
                  {t('flashcards_page.start_review')}
                </Link>
              )}
            </div>
            <div className="flash-review-card">
              <div className="flash-review-num">{status === 'loading' ? '…' : (overview?.mastered ?? 0)}</div>
              <div className="flash-review-lbl">{t('flashcards_page.mastered')}</div>
            </div>
            <div className="flash-review-card">
              <div className="flash-review-num">{status === 'loading' ? '…' : (overview?.cardTotal ?? 0)}</div>
              <div className="flash-review-lbl">{t('flashcards_page.total_cards')}</div>
            </div>
            <div className="flash-review-card">
              <div className="flash-review-num">
                {status === 'loading' ? '…' : overview?.accuracy == null ? '—' : `${overview.accuracy}%`}
              </div>
              <div className="flash-review-lbl">{t('flashcards_page.accuracy_7d')}</div>
            </div>
          </div>
          {sessionError && (
            <div className="flash-session-warn mb-10">
              <AlertTriangle size={15} />
              <span>{t('flashcards_page.anon_warn')}</span>
            </div>
          )}

          {/* Grid de decks */}
          {filtered.length === 0 ? (
            <div className="flash-empty-state">{t('flashcards_page.no_results')}</div>
          ) : (
            <div className="flash-deck-grid">
              {filtered.map((deck) => {
                const due = duePerDeck[deck.id] || 0
                const pct = deck.cardCount > 0 ? Math.min(100, Math.round((due / deck.cardCount) * 100)) : 0
                return (
                  <div className="flash-deck-card" key={deck.id} style={{ '--deck-color': deck.color }}>
                    <div className="flash-deck-top">
                      <span className="flash-deck-badge">{deck.atcPrefix || 'Deck'}</span>
                      <span className="flash-deck-count">{deck.cardCount} {t('flashcards_page.cards_count')}</span>
                    </div>
                    <div className="flash-deck-body">
                      <h3 className="flash-deck-title">{deck.name}</h3>
                      <p className="flash-deck-desc">{deck.description}</p>
                      <div className="flash-progress-row">
                        <span>{t('flashcards_page.due_today')}</span>
                        <div className="flash-progress-track">
                          <div className="flash-progress-fill" style={{ width: `${pct}%`, background: deck.color }} />
                        </div>
                        <span>{status === 'loading' ? '…' : due}</span>
                      </div>
                    </div>
                    <div className="flash-deck-foot">
                      <span className="flash-deck-due">
                        {due > 0 ? `${due} ${t('flashcards_page.due_count')}` : t('flashcards_page.up_to_date')}
                      </span>
                      <Link
                        href={`/${lang}/flashcards/${deck.slug}`}
                        className={`flash-deck-review${due === 0 && status === 'ready' ? ' is-empty' : ''}`}
                      >
                        {due > 0 ? t('flashcards_page.review') : t('flashcards_page.start')}
                      </Link>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      </section>

      {/* Como funciona */}
      <section className="flash-how">
        <h2 className="flash-how-title">{t('flashcards_page.how_title')}</h2>
        <div className="flash-how-grid">
          <div className="flash-how-card">
            <Brain size={22} className="flash-how-ic" />
            <h4>{t('flashcards_page.how_1_title')}</h4>
            <p>{t('flashcards_page.how_1_desc')}</p>
          </div>
          <div className="flash-how-card">
            <Database size={22} className="flash-how-ic" />
            <h4>{t('flashcards_page.how_2_title')}</h4>
            <p>{t('flashcards_page.how_2_desc')}</p>
          </div>
          <div className="flash-how-card">
            <Clock3 size={22} className="flash-how-ic" />
            <h4>{t('flashcards_page.how_3_title')}</h4>
            <p>{t('flashcards_page.how_3_desc')}</p>
          </div>
        </div>
      </section>
    </>
  )
}
