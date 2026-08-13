'use client'

import { useContext, useEffect, useMemo, useState } from 'react'
import Link from 'next/link'
import {
  AlertTriangle, ArrowLeft, ArrowRight, CheckCircle2, RotateCcw, Sparkles, Target, TrendingDown, TrendingUp, XCircle,
} from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { startQuiz, answerQuiz, finishQuiz } from '@/lib/actions/quiz'
import { normalizeAnswer } from '@/lib/quiz/engine'

/**
 * QuizSessionClient — sessão de escolha múltipla.
 * As perguntas vêm do servidor SEM a resposta correta; cada resposta é
 * validada no servidor (answerQuiz) contra o dado real.
 */
export default function QuizSessionClient({ lang = 'pt', mode = 'rapido', level = '', source = 'mixed', deckSlug = '', deckName = '', save = true }) {
  const { t } = useContext(LangContext)

  const [phase, setPhase] = useState('loading') // loading | question | summary | error
  const [questions, setQuestions] = useState([])
  const [deckId, setDeckId] = useState(null)
  const [index, setIndex] = useState(0)
  const [selected, setSelected] = useState(null) // índice da opção escolhida
  const [feedback, setFeedback] = useState(null) // { correct, correctAnswer, explanation, source }
  const [results, setResults] = useState([]) // booleanos por pergunta
  const [saveMsg, setSaveMsg] = useState('') // 'saved' | 'not_saved' | 'error' | ''
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false
    setPhase('loading')
    startQuiz({ mode, level, deckSlug, source, count: 10 }).then((res) => {
      if (cancelled) return
      if (!res.ok) {
        setPhase('error')
        setError(res.error || t('quiz_session.no_questions'))
        return
      }
      if (!res.questions || res.questions.length === 0) {
        setPhase('error')
        setError(t('quiz_session.no_questions'))
        return
      }
      setQuestions(res.questions)
      setDeckId(res.deckId)
      setPhase('question')
    })
    return () => {
      cancelled = true
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mode, level, deckSlug, source])

  const levelLabel = mode === 'nivel' && level ? t(`quiz_page.level_${level}`) : ''

  const current = questions[index]

  const typeLabel = useMemo(() => {
    const key = {
      flashcard: 'quiz_session.type_flashcard',
      pharmacology: 'quiz_session.type_pharmacology',
      interaction: 'quiz_session.type_interaction',
      protocol: 'quiz_session.type_protocol',
    }[current?.type]
    return key ? t(key) : ''
  }, [current, t])

  const handleSelect = async (optIndex) => {
    if (!current || selected !== null) return
    setSelected(optIndex)
    const res = await answerQuiz({ key: current.key, selected: current.options[optIndex] })
    if (!res.ok) {
      setFeedback({ error: res.error || 'Erro ao validar' })
      setResults((r) => [...r, false])
      return
    }
    setFeedback(res)
    setResults((r) => [...r, res.correct])
  }

  const handleNext = async () => {
    if (index + 1 >= questions.length) {
      setPhase('summary')
      if (save) {
        const res = await finishQuiz({
          mode,
          level,
          source,
          deckId,
          total: questions.length,
          correct: results.filter(Boolean).length,
          details: questions.map((q, i) => ({ key: q.key, correct: Boolean(results[i]) })),
        })
        setSaveMsg(res?.ok && res.saved ? 'saved' : res?.ok ? 'not_saved' : 'error')
      } else {
        setSaveMsg('not_saved')
      }
      return
    }
    setIndex((i) => i + 1)
    setSelected(null)
    setFeedback(null)
  }

  const handleRestart = () => {
    setQuestions([])
    setIndex(0)
    setSelected(null)
    setFeedback(null)
    setResults([])
    setSaveMsg('')
    setPhase('loading')
    startQuiz({ mode, level, deckSlug, source, count: 10 }).then((res) => {
      if (!res.ok || !res.questions?.length) {
        setPhase('error')
        setError(res.error || t('quiz_session.no_questions'))
        return
      }
      setQuestions(res.questions)
      setDeckId(res.deckId)
      setPhase('question')
    })
  }

  const correctCount = results.filter(Boolean).length
  const pct = questions.length > 0 ? Math.round((correctCount / questions.length) * 100) : 0

  // Sugestão de nível no fim da sessão (só em modo nível) com base no acerto
  const levelSuggestion = (() => {
    if (mode !== 'nivel' || !level || questions.length === 0) return null
    const order = ['facil', 'medio', 'dificil']
    const idx = order.indexOf(level)
    if (idx === -1) return null
    if (pct >= 80 && idx < order.length - 1) {
      const next = order[idx + 1]
      return {
        tone: 'up',
        next,
        text: t('quiz_session.level_suggest_up', { pct, level: t(`quiz_page.level_${next}`) }),
      }
    }
    if (pct < 50 && idx > 0) {
      const next = order[idx - 1]
      return {
        tone: 'down',
        next,
        text: t('quiz_session.level_suggest_down', { pct, level: t(`quiz_page.level_${next}`) }),
      }
    }
    return { tone: 'ok', next: '', text: t('quiz_session.level_suggest_ok') }
  })()

  // ---------- Loading ----------
  if (phase === 'loading') {
    return (
      <div className="quiz-session">
        <div className="quiz-session-loading">
          <Sparkles size={22} className="quiz-session-spin" />
          <p>{t('quiz_session.loading')}</p>
        </div>
      </div>
    )
  }

  // ---------- Erro ----------
  if (phase === 'error') {
    return (
      <div className="quiz-session">
        <Link href={`/${lang}/quiz`} className="quiz-topbar-link">
          <ArrowLeft size={14} /> {t('quiz_session.back')}
        </Link>
        <div className="quiz-empty-review">
          <AlertTriangle size={30} className="quiz-empty-ic" />
          <h2>{error}</h2>
          <Link href={`/${lang}/quiz`} className="quiz-grade-btn quiz-grade-good">
            {t('quiz_session.another_mode')}
          </Link>
        </div>
      </div>
    )
  }

  // ---------- Resumo ----------
  if (phase === 'summary') {
    return (
      <div className="quiz-session">
        <Link href={`/${lang}/quiz`} className="quiz-topbar-link">
          <ArrowLeft size={14} /> {t('quiz_session.back')}
        </Link>
        <div className="quiz-summary">
          <div className="quiz-summary-head">
            <CheckCircle2 size={30} className="quiz-summary-ic" />
            <h2>{t('quiz_session.summary_title')}</h2>
            <div className="quiz-summary-accuracy">
              <span className="quiz-summary-accuracy-num">{pct}%</span>
              <span className="quiz-summary-accuracy-lbl">{t('quiz_session.score_label')}</span>
            </div>
            <p className="quiz-summary-count">
              {correctCount} {t('quiz_session.of')} {questions.length} {t('quiz_session.questions_correct')}
            </p>
            {saveMsg === 'saved' && <p className="quiz-save-msg ok">{t('quiz_session.saved')}</p>}
            {saveMsg === 'not_saved' && <p className="quiz-save-msg warn">{t('quiz_session.not_saved')}</p>}
            {saveMsg === 'error' && <p className="quiz-save-msg warn">{t('quiz_session.save_error')}</p>}
          </div>
          {levelSuggestion && (
            <div className={`quiz-level-suggest is-${levelSuggestion.tone}`}>
              {levelSuggestion.tone === 'up' && <TrendingUp size={18} aria-hidden="true" />}
              {levelSuggestion.tone === 'down' && <TrendingDown size={18} aria-hidden="true" />}
              {levelSuggestion.tone === 'ok' && <Target size={18} aria-hidden="true" />}
              <div className="quiz-level-suggest-body">
                <p className="quiz-level-suggest-text">{levelSuggestion.text}</p>
                {levelSuggestion.next && (
                  <Link
                    href={`/${lang}/quiz/nivel-${levelSuggestion.next}${save ? '' : '?save=0'}`}
                    className="quiz-level-suggest-cta"
                  >
                    {t('quiz_session.level_try')} {t(`quiz_page.level_${levelSuggestion.next}`)} →
                  </Link>
                )}
              </div>
            </div>
          )}
          <div className="quiz-summary-actions">
            <button className="quiz-grade-btn quiz-grade-good" onClick={handleRestart}>
              <RotateCcw size={15} /> {t('quiz_session.repeat')}
            </button>
            <Link href={`/${lang}/quiz`} className="quiz-grade-btn quiz-grade-hard">
              {t('quiz_session.another_mode')}
            </Link>
          </div>
        </div>
      </div>
    )
  }

  // ---------- Pergunta ----------
  const progressPct = questions.length > 0 ? Math.round((index / questions.length) * 100) : 0

  return (
    <div className="quiz-session">
      <Link href={`/${lang}/quiz`} className="quiz-topbar-link">
        <ArrowLeft size={14} /> {t('quiz_session.back')}
      </Link>

      <div className="quiz-session-head">
        <h1 className="quiz-session-title">{deckName || levelLabel || t('quiz_session.page_title')}</h1>
        <span className="quiz-session-meta">
          {t('quiz_session.question_of', { current: index + 1, total: questions.length })}
        </span>
      </div>

      <div className="quiz-session-progress">
        <div className="quiz-session-progress-fill" style={{ width: `${progressPct}%` }} />
      </div>

      {current && (
        <div className="quiz-question-card">
          {typeLabel && <span className="quiz-question-tag">{typeLabel}</span>}
          <h2 className="quiz-question-text">{current.question}</h2>

          <div className="quiz-options">
            {current.options.map((opt, i) => {
              let cls = 'quiz-option'
              if (selected !== null) {
                const isCorrectOpt = feedback?.correctAnswer && normalizeAnswer(opt) === normalizeAnswer(feedback.correctAnswer)
                const isSelected = i === selected
                if (isCorrectOpt) cls += ' is-correct'
                else if (isSelected) cls += ' is-wrong'
                else cls += ' is-dim'
              }
              return (
                <button
                  key={i}
                  type="button"
                  className={cls}
                  disabled={selected !== null}
                  onClick={() => handleSelect(i)}
                >
                  <span className="quiz-option-letter">{String.fromCharCode(65 + i)}</span>
                  <span className="quiz-option-text">{opt}</span>
                  {selected !== null && feedback?.correctAnswer && normalizeAnswer(opt) === normalizeAnswer(feedback.correctAnswer) && (
                    <CheckCircle2 size={18} className="quiz-option-ic ok" />
                  )}
                  {selected !== null && i === selected && feedback?.correct === false && (
                    <XCircle size={18} className="quiz-option-ic no" />
                  )}
                </button>
              )
            })}
          </div>

          {feedback && (
            <div className={`quiz-feedback${feedback.correct ? ' is-correct' : ' is-wrong'}`}>
              <div className="quiz-feedback-head">
                {feedback.correct ? (
                  <CheckCircle2 size={18} />
                ) : (
                  <XCircle size={18} />
                )}
                <strong>{feedback.correct ? t('quiz_session.correct') : t('quiz_session.incorrect')}</strong>
              </div>
              {!feedback.correct && feedback.correctAnswer && (
                <p className="quiz-feedback-answer">
                  {t('quiz_session.correct_answer')}: <strong>{feedback.correctAnswer}</strong>
                </p>
              )}
              {feedback.explanation && (
                <p className="quiz-feedback-explanation">
                  {t('quiz_session.explanation')}: {feedback.explanation}
                </p>
              )}
              {feedback.source && (
                <p className="quiz-feedback-source">
                  {t('quiz_session.source')}: {feedback.source}
                </p>
              )}
            </div>
          )}

          {selected !== null && (
            <button className="quiz-next-btn" onClick={handleNext}>
              {index + 1 >= questions.length ? t('quiz_session.finish') : t('quiz_session.next')}
              <ArrowRight size={16} />
            </button>
          )}
        </div>
      )}
    </div>
  )
}
