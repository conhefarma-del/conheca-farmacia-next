'use client'

import { useEffect, useMemo, useState } from 'react'
import Link from 'next/link'
import { ArrowLeft, RotateCcw, CheckCircle2, XCircle, AlertTriangle, Sparkles, BookOpen, RefreshCw } from 'lucide-react'
import { useAnonymousSession } from '@/hooks/useAnonymousSession'
import { getDeckReviewState, answerCard, resetDeckProgress } from '@/lib/actions/flashcards'
import { formatInterval } from '@/lib/flashcards/sm2'

const TYPE_LABELS = {
  mecanismo: 'Mecanismo de ação',
  classe: 'Classe terapêutica',
  perfil: 'Perfil / visão geral',
  interacao: 'Interação fármaco-fármaco',
  manual: 'Cartão',
}

/**
 * FlashcardReviewClient — sessão de revisão de um deck.
 * Flip card (perspective) → 4 botões SM-2 → resumo final.
 * O progresso vive na cloud via sessão anónima (decisão 1A).
 */
export default function FlashcardReviewClient({ deck, drugMap = {}, lang = 'pt' }) {
  const { status, error: sessionError } = useAnonymousSession()

  const [sessionIds, setSessionIds] = useState([])
  const [stats, setStats] = useState(null)
  const [phase, setPhase] = useState('loading') // 'loading' | 'review' | 'summary'
  const [index, setIndex] = useState(0)
  const [flipped, setFlipped] = useState(false)
  const [grading, setGrading] = useState(false)
  const [results, setResults] = useState([])
  const [message, setMessage] = useState('')

  // Cartões da sessão (ordem do server: devidos por data, depois novos)
  const sessionCards = useMemo(() => {
    const byId = new Map(deck.cards.map((c) => [c.id, c]))
    return sessionIds.map((id) => byId.get(id)).filter(Boolean)
  }, [deck.cards, sessionIds])

  useEffect(() => {
    if (status !== 'ready') return
    let cancelled = false
    getDeckReviewState(deck.slug).then((data) => {
      if (cancelled) return
      if (!data.loggedIn) return
      setSessionIds(data.sessionIds || [])
      setStats({
        mastered: data.mastered,
        dueCount: data.dueCount,
        newCount: data.newCount,
        totalCount: data.totalCount,
      })
      setPhase(data.sessionIds.length > 0 ? 'review' : 'empty')
    })
    return () => {
      cancelled = true
    }
  }, [status, deck.slug])

  const current = sessionCards[index]

  const handleGrade = async (grade) => {
    if (!current || grading) return
    setGrading(true)
    setMessage('')
    try {
      const res = await answerCard(current.id, grade)
      if (!res.ok) {
        setMessage(res.error)
        return
      }
      setResults((r) => [
        ...r,
        { cardId: current.id, grade, intervalDays: res.next.intervalDays, isLapse: res.next.isLapse },
      ])
      setFlipped(false)
      if (index + 1 >= sessionCards.length) {
        setPhase('summary')
      } else {
        setIndex((i) => i + 1)
      }
    } catch {
      setMessage('Erro ao guardar a resposta.')
    } finally {
      setGrading(false)
    }
  }

  const handleReset = async () => {
    setMessage('')
    const res = await resetDeckProgress(deck.id)
    if (res.ok) {
      setResults([])
      setIndex(0)
      setFlipped(false)
      const data = await getDeckReviewState(deck.slug)
      if (data.loggedIn) {
        setSessionIds(data.sessionIds || [])
        setStats({
          mastered: data.mastered,
          dueCount: data.dueCount,
          newCount: data.newCount,
          totalCount: data.totalCount,
        })
        setPhase(data.sessionIds.length > 0 ? 'review' : 'empty')
      }
    } else {
      setMessage(res.error)
    }
  }

  const lapsed = results.filter((r) => r.isLapse || r.grade === 0).length
  const correct = results.filter((r) => r.grade >= 2).length
  const accuracy = results.length > 0 ? Math.round((correct / results.length) * 100) : 100

  // ---------- Loading ----------
  if (phase === 'loading') {
    return (
      <div className="flash-session">
        <div className="flash-session-loading">
          <Sparkles size={22} className="flash-session-spin" />
          <p>A preparar a sessão…</p>
        </div>
      </div>
    )
  }

  // ---------- Sem devidos ----------
  if (phase === 'empty') {
    return (
      <div className="flash-session">
        <Link href={`/${lang}/flashcards`} className="flash-topbar-link">
          <ArrowLeft size={14} /> Voltar para os decks
        </Link>
        <div className="flash-session-head">
          <h1 className="flash-session-title">{deck.name}</h1>
          <span className="flash-session-meta">
            {stats?.mastered ?? 0} dominados · {stats?.totalCount ?? deck.cards.length} cartões
          </span>
        </div>
        <div className="flash-empty-review">
          <CheckCircle2 size={34} className="flash-empty-ic" />
          <h2>Nada para revisar hoje</h2>
          <p>
            Estás em dia com este deck{stats?.dueCount ? ` — faltam ${stats.dueCount} por rever` : ''}.
            Volta amanhã ou começa um novo deck.
          </p>
          <div className="flash-empty-actions">
            <Link href={`/${lang}/flashcards`} className="flash-grade-btn flash-grade-good">
              <BookOpen size={15} /> Mais decks
            </Link>
            <button className="flash-grade-btn flash-grade-hard" onClick={handleReset}>
              <RefreshCw size={15} /> Repor progresso
            </button>
          </div>
        </div>
        {sessionError && (
          <div className="flash-session-warn">
            <AlertTriangle size={15} /> {sessionError}
          </div>
        )}
      </div>
    )
  }

  // ---------- Sessão ----------
  const progressPct = sessionCards.length > 0 ? Math.round((index / sessionCards.length) * 100) : 0
  const drug = current?.drugId ? drugMap[current.drugId] : null
  const inSession = phase === 'review' && current

  return (
    <div className="flash-session">
      <Link href={`/${lang}/flashcards`} className="flash-topbar-link">
        <ArrowLeft size={14} /> Voltar para os decks
      </Link>

      {inSession && (
      <>
      <div className="flash-session-head">
        <h1 className="flash-session-title">{deck.name}</h1>
        <span className="flash-session-meta">
          Cartão {index + 1} de {sessionCards.length} · {stats?.dueCount ?? 0} para revisar hoje
        </span>
      </div>

      <div className="flash-session-progress">
        <div className="flash-session-progress-fill" style={{ width: `${progressPct}%` }} />
      </div>

      {/* Flip card */}
      <div className="flash-flip-wrap">
        <div
          className={`flash-flip-card${flipped ? ' is-flipped' : ''}`}
          onClick={() => !flipped && setFlipped(true)}
        >
          <div className="flash-face flash-face-front">
            <div className="flash-card-tag">{TYPE_LABELS[current.cardType] || 'Cartão'}</div>
            <p className="flash-card-q">{current.front}</p>
            {!flipped && (
              <div className="flash-flip-hint">
                <RotateCcw size={14} />
                Clique para ver a resposta
              </div>
            )}
          </div>
          <div className="flash-face flash-face-back">
            <div className="flash-card-tag">Resposta</div>
            <div className="flash-back-scroll">
              <div className="flash-answer-val">{current.back}</div>
            </div>
            <div className="flash-links-row">
              {drug && (
                <Link
                  href={`/${lang}/${lang === 'pt' ? 'medicamento' : 'medicine'}/${drug.slug}`}
                  className="flash-link-chip"
                  onClick={(e) => e.stopPropagation()}
                >
                  Ver perfil: {drug.name}
                </Link>
              )}
              {current.sourceNote && (
                <span className="flash-source-note">{current.sourceNote}</span>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Botões SM-2 */}
      <div className={`flash-grade-row${flipped ? ' is-visible' : ''}`}>
        <button className="flash-grade-btn flash-grade-again" disabled={grading} onClick={() => handleGrade(0)}>
          <span className="flash-g-label">Outra vez</span>
          <span className="flash-g-days">&lt;1 min</span>
        </button>
        <button className="flash-grade-btn flash-grade-hard" disabled={grading} onClick={() => handleGrade(1)}>
          <span className="flash-g-label">Difícil</span>
          <span className="flash-g-days">1 dia</span>
        </button>
        <button className="flash-grade-btn flash-grade-good" disabled={grading} onClick={() => handleGrade(2)}>
          <span className="flash-g-label">Boa</span>
          <span className="flash-g-days">1–6 dias</span>
        </button>
        <button className="flash-grade-btn flash-grade-easy" disabled={grading} onClick={() => handleGrade(3)}>
          <span className="flash-g-label">Fácil</span>
          <span className="flash-g-days">4–13 dias</span>
        </button>
      </div>

      {message && (
        <div className="flash-session-warn" style={{ marginTop: 12 }}>
          <AlertTriangle size={15} /> {message}
        </div>
      )}

      <div className="flash-deck-stats">
        <div className="flash-stat-box">
          <div className="flash-stat-n">{stats?.totalCount ?? deck.cards.length}</div>
          <div className="flash-stat-l">Cartões no deck</div>
        </div>
        <div className="flash-stat-box">
          <div className="flash-stat-n">{stats?.mastered ?? 0}</div>
          <div className="flash-stat-l">Dominados</div>
        </div>
        <div className="flash-stat-box">
          <div className="flash-stat-n">{stats?.newCount ?? 0}</div>
          <div className="flash-stat-l">Novos hoje</div>
        </div>
      </div>
      </>
      )}

      {/* Resumo final */}
      {phase === 'summary' && (
        <div className="flash-summary">
          <div className="flash-summary-head">
            <CheckCircle2 size={30} className="flash-summary-ic" />
            <h2>Sessão concluída</h2>
            <p>
              {results.length} cartões revistos · {correct} acertos · {lapsed} a repetir
            </p>
            <div className="flash-summary-accuracy">
              <span className="flash-summary-accuracy-num">{accuracy}%</span>
              <span className="flash-summary-accuracy-lbl">taxa de acerto nesta sessão</span>
            </div>
          </div>
          <div className="flash-summary-list">
            {results.slice(0, 8).map((r) => {
              const card = deck.cards.find((c) => c.id === r.cardId)
              return (
                <div key={r.cardId} className="flash-summary-row">
                  {r.grade >= 2 ? (
                    <CheckCircle2 size={15} className="flash-summary-ok" />
                  ) : (
                    <XCircle size={15} className="flash-summary-no" />
                  )}
                  <span className="flash-summary-row-text">
                    {card?.front?.slice(0, 70)}
                    {card?.front?.length > 70 ? '…' : ''}
                  </span>
                  <span className="flash-summary-row-int">{formatInterval(r.intervalDays)}</span>
                </div>
              )
            })}
          </div>
          <div className="flash-summary-actions">
            <Link href={`/${lang}/flashcards`} className="flash-grade-btn flash-grade-good">
              <BookOpen size={15} /> Mais decks
            </Link>
            <button className="flash-grade-btn flash-grade-hard" onClick={() => { setResults([]); setIndex(0); setFlipped(false); setPhase('review') }}>
              <RefreshCw size={15} /> Refazer sessão
            </button>
          </div>
        </div>
      )}
    </div>
  )
}


