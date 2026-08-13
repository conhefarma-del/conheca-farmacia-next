'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { Brain, Database, Clock3, Search, AlertTriangle } from 'lucide-react'
import { useAnonymousSession } from '@/hooks/useAnonymousSession'
import { getFlashcardsReviewOverview } from '@/lib/actions/flashcards'

/**
 * FlashcardsPageClient — página principal dos flashcards:
 * hero, painel "Para revisar hoje", filtros/pesquisa e grid de decks.
 * As contagens de revisão (devidos/dominados/acerto) são carregadas após
 * garantir a sessão anónima.
 */
export default function FlashcardsPageClient({ decks = [], lang = 'pt' }) {
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
    <div>
      {/* HERO */}
      <section className="flash-hero">
        <div className="flash-hero-inner">
          <p className="flash-hero-eyebrow">Repetição espaçada</p>
          <h1 className="flash-hero-title">Flashcards de Farmacologia</h1>
          <p className="flash-hero-sub">
            Domina os fármacos do banco de dados com revisão inteligente: os cartões que sabes
            aparecem menos, os que falhas aparecem mais.
          </p>
        </div>
      </section>

      {/* PAINEL DE REVISÃO */}
      <div className="flash-review-strip">
        <div className="flash-review-grid">
          <div className="flash-review-card flash-review-due">
            <div className="flash-review-num">
              {status === 'loading' ? '…' : dueTotal}
            </div>
            <div className="flash-review-lbl">Para revisar hoje</div>
            {dueTotal > 0 && mostDueDeck && (
              <Link href={`/${lang}/flashcards/${mostDueDeck.deck.slug}`} className="flash-review-cta">
                Começar revisão
              </Link>
            )}
          </div>
          <div className="flash-review-card">
            <div className="flash-review-num">{status === 'loading' ? '…' : (overview?.mastered ?? 0)}</div>
            <div className="flash-review-lbl">Cartões dominados</div>
          </div>
          <div className="flash-review-card">
            <div className="flash-review-num">{status === 'loading' ? '…' : (overview?.cardTotal ?? 0)}</div>
            <div className="flash-review-lbl">Total de cartões</div>
          </div>
          <div className="flash-review-card">
            <div className="flash-review-num">
              {status === 'loading' ? '…' : overview?.accuracy == null ? '—' : `${overview.accuracy}%`}
            </div>
            <div className="flash-review-lbl">Taxa de acerto (7 dias)</div>
          </div>
        </div>
        {sessionError && (
          <div className="flash-session-warn">
            <AlertTriangle size={15} />
            <span>
              Não foi possível iniciar a sessão anónima no Supabase (ativa "Anonymous Sign-Ins" em
              Authentication → Providers). A revisão não guarda progresso sem sessão.
            </span>
          </div>
        )}
      </div>

      {/* FILTROS + PESQUISA */}
      <div className="flash-tools-bar">
        <button
          className={`flash-filter-btn${filter === 'all' ? ' is-active' : ''}`}
          onClick={() => setFilter('all')}
        >
          Todos
        </button>
        {decks.map((d) => (
          <button
            key={d.slug}
            className={`flash-filter-btn${filter === d.slug ? ' is-active' : ''}`}
            onClick={() => setFilter(d.slug)}
          >
            {d.name}
          </button>
        ))}
        <div className="flash-search">
          <Search size={15} className="flash-search-icon" />
          <input
            type="search"
            className="flash-search-input"
            placeholder="Pesquisar decks ou fármacos…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
        </div>
      </div>

      {/* DECKS */}
      <section className="flash-decks">
        {filtered.length === 0 ? (
          <div className="flash-empty-state">
            Sem decks com esse nome. Experimenta outra pesquisa.
          </div>
        ) : (
          <div className="flash-deck-grid">
            {filtered.map((deck) => {
              const due = duePerDeck[deck.id] || 0
              const pct = deck.cardCount > 0 ? Math.min(100, Math.round((due / deck.cardCount) * 100)) : 0
              return (
                <div className="flash-deck-card" key={deck.id} style={{ '--deck-color': deck.color }}>
                  <div className="flash-deck-top">
                    <span className="flash-deck-badge">{deck.atcPrefix || 'Deck'}</span>
                    <span className="flash-deck-count">{deck.cardCount} cartões</span>
                  </div>
                  <div className="flash-deck-body">
                    <h3 className="flash-deck-title">{deck.name}</h3>
                    <p className="flash-deck-desc">{deck.description}</p>
                    <div className="flash-progress-row">
                      <span>Para revisar</span>
                      <div className="flash-progress-track">
                        <div className="flash-progress-fill" style={{ width: `${pct}%`, background: deck.color }} />
                      </div>
                      <span>{status === 'loading' ? '…' : due}</span>
                    </div>
                  </div>
                  <div className="flash-deck-foot">
                    <span className="flash-deck-due">{due > 0 ? `${due} para revisar` : 'Em dia'}</span>
                    <Link
                      href={`/${lang}/flashcards/${deck.slug}`}
                      className={`flash-deck-review${due === 0 && status === 'ready' ? ' is-empty' : ''}`}
                    >
                      {due > 0 ? 'Revisar' : 'Começar'}
                    </Link>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </section>

      {/* COMO FUNCIONA */}
      <section className="flash-how">
        <h2 className="flash-how-title">Como funciona</h2>
        <div className="flash-how-grid">
          <div className="flash-how-card">
            <Brain size={22} className="flash-how-ic" />
            <h4>O algoritmo adapta-se a ti</h4>
            <p>Cada resposta ajusta o intervalo: falhas voltam em minutos, acertos fáceis sobem para dias e semanas.</p>
          </div>
          <div className="flash-how-card">
            <Database size={22} className="flash-how-ic" />
            <h4>Conteúdo do banco de dados</h4>
            <p>Cartões gerados a partir dos perfis, farmacologia e interações reais de cada fármaco — com link para a página do medicamento.</p>
          </div>
          <div className="flash-how-card">
            <Clock3 size={22} className="flash-how-ic" />
            <h4>Revisões curtas e diárias</h4>
            <p>5–10 minutos por dia bastam para manter o conhecimento em consolidação.</p>
          </div>
        </div>
      </section>
    </div>
  )
}
