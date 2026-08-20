'use client'

import { useState, useEffect, useCallback, useRef, useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import {
  startCompetitionQuiz,
  validateCompetitionAnswer,
  submitAnswer,
  finishCompetition,
  getCompetitionLeaderboard,
  getCompetitionParticipantCount,
  claimSessionToAccount,
} from '@/lib/actions/competition'
import CompetitionLeaderboard from '@/components/ui/CompetitionLeaderboard'
import { Trophy, Users, Clock, Play, ArrowRight, CheckCircle2, XCircle, Flame, Loader2, LogIn, Sparkles } from 'lucide-react'
import { createClient } from '@/lib/supabase/client'

export default function CompetitionSessionClient({ lang, code }) {
  const { t } = useContext(LangContext)

  // Core state
  const [phase, setPhase] = useState('loading') // loading → lobby → quiz → result → error
  const [competition, setCompetition] = useState(null)
  const [sessionId, setSessionId] = useState(null)
  const [studentName, setStudentName] = useState('')
  const [participantCount, setParticipantCount] = useState(0)
  const [error, setError] = useState('')

  // Quiz state
  const [questions, setQuestions] = useState([])
  const [currentQ, setCurrentQ] = useState(0)
  const [selected, setSelected] = useState(null)
  const [feedback, setFeedback] = useState(null)
  const [score, setScore] = useState(0)
  const [correctCount, setCorrectCount] = useState(0)
  const [streak, setStreak] = useState(0)
  const [maxStreak, setMaxStreak] = useState(0)
  const [timeLeft, setTimeLeft] = useState(0)
  const [timePerQuestion, setTimePerQuestion] = useState(30)
  const [results, setResults] = useState([])

  // Result state
  const [leaderboard, setLeaderboard] = useState([])
  const [claiming, setClaiming] = useState(false)
  const [claimed, setClaimed] = useState(false)

  const timerRef = useRef(null)

  // Load session
  useEffect(() => {
    async function load() {
      const storedSession = localStorage.getItem('comp_session')
      const storedName = localStorage.getItem('comp_name')
      if (!storedSession) {
        window.location.href = `/${lang}/competicao`
        return
      }
      setSessionId(storedSession)
      setStudentName(storedName || '')

      // Load competition info
      const { getCompetitionByCode } = await import('@/lib/actions/competition')
      const info = await getCompetitionByCode(code)
      if (!info) {
        setPhase('error')
        setError('Competição não encontrada')
        return
      }
      setCompetition(info)

      const count = await getCompetitionParticipantCount(info.id)
      setParticipantCount(count)
      setPhase('lobby')
    }
    load()
  }, [code, lang])

  // Poll participant count in lobby
  useEffect(() => {
    if (phase !== 'lobby' || !competition) return
    const interval = setInterval(async () => {
      const count = await getCompetitionParticipantCount(competition.id)
      setParticipantCount(count)
      // Check if competition started
      const { getCompetitionByCode: refresh } = await import('@/lib/actions/competition')
      const info = await refresh(code)
      if (info?.status === 'active') {
        startQuiz()
      }
    }, 5000)
    return () => clearInterval(interval)
  }, [phase, competition, code])

  // Start quiz
  const startQuiz = useCallback(async () => {
    setPhase('loading')
    const res = await startCompetitionQuiz(sessionId, code)
    if (!res.ok) {
      setPhase('error')
      setError(res.error || 'Erro ao iniciar quiz')
      return
    }
    setQuestions(res.questions)
    setTimePerQuestion(res.timePerQuestion || 30)
    setTimeLeft(res.timePerQuestion || 30)
    setPhase('quiz')
  }, [sessionId, code])

  // Timer
  useEffect(() => {
    if (phase !== 'quiz' || selected !== null || timeLeft <= 0) return
    timerRef.current = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(timerRef.current)
          // Auto-submit wrong answer on timeout
          handleTimeout()
          return timePerQuestion
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(timerRef.current)
  }, [phase, selected, currentQ, timePerQuestion])

  const handleTimeout = useCallback(async () => {
    if (selected !== null) return
    setSelected(-1)
    const current = questions[currentQ]
    if (current) {
      const res = await validateCompetitionAnswer(sessionId, {
        key: current.key,
        selected: '',
        questionIndex: currentQ,
        timeMs: timePerQuestion * 1000,
      })
      if (res.ok) {
        setFeedback({ correct: false, correctAnswer: res.correctAnswer, explanation: res.explanation })
        setResults((r) => [...r, false])
        // Submit to competition
        await submitAnswer(sessionId, {
          questionIndex: currentQ,
          correct: false,
          points: 0,
          timeMs: timePerQuestion * 1000,
        })
        setStreak(0)
      }
    }
  }, [selected, questions, currentQ, sessionId, timePerQuestion])

  const handleSelect = async (optIndex) => {
    if (selected !== null || phase !== 'quiz') return
    clearInterval(timerRef.current)

    const current = questions[currentQ]
    const selectedValue = current.options[optIndex]
    const timeMs = (timePerQuestion - timeLeft) * 1000

    setSelected(optIndex)

    // Validate on server
    const res = await validateCompetitionAnswer(sessionId, {
      key: current.key,
      selected: selectedValue,
      questionIndex: currentQ,
      timeMs,
    })

    if (res.ok) {
      setFeedback({
        correct: res.correct,
        correctAnswer: res.correctAnswer,
        explanation: res.explanation,
      })
      setResults((r) => [...r, res.correct])

      if (res.correct) {
        // Calculate points: base 100 + time bonus (remaining seconds * 3)
        const timeBonus = timeLeft * 3
        const basePoints = 100 + timeBonus
        setScore((prev) => prev + basePoints)
        setCorrectCount((prev) => prev + 1)
        setStreak((prev) => {
          const newStreak = prev + 1
          if (newStreak > maxStreak) setMaxStreak(newStreak)
          return newStreak
        })
      } else {
        setStreak(0)
      }

      // Submit to competition sessions
      await submitAnswer(sessionId, {
        questionIndex: currentQ,
        correct: res.correct,
        points: res.correct ? 100 + timeLeft * 3 : 0,
        timeMs,
      })
    }
  }

  const handleNext = async () => {
    if (currentQ + 1 >= questions.length) {
      // Finish quiz
      await finishCompetition(sessionId)
      const lb = await getCompetitionLeaderboard(competition.id, 20)
      setLeaderboard(lb)
      setPhase('result')
      return
    }
    setCurrentQ((prev) => prev + 1)
    setSelected(null)
    setFeedback(null)
    setTimeLeft(timePerQuestion)
  }

  const handleClaimAccount = async () => {
    setClaiming(true)
    try {
      const supabase = createClient()
      const { error: oauthError } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: `${window.location.origin}/${lang}/competicao/claim?session=${sessionId}`,
        },
      })
      if (oauthError) {
        // If Google OAuth fails, try to claim directly if already logged in
        const result = await claimSessionToAccount(sessionId)
        if (result.success) setClaimed(true)
      }
    } catch {
      setClaiming(false)
    }
  }

  // ─── LOADING ───
  if (phase === 'loading' && !competition) {
    return (
      <section className="py-20 text-center">
        <Loader2 size={40} className="mx-auto mb-4 text-brand-accent animate-spin" />
        <p className="text-brand-deep/60">A carregar...</p>
      </section>
    )
  }

  // ─── ERROR ───
  if (phase === 'error') {
    return (
      <section className="py-20 text-center">
        <XCircle size={48} className="mx-auto mb-4 text-red-500" />
        <h1 className="text-2xl font-bold text-brand-deep mb-2">Erro</h1>
        <p className="text-brand-deep/60 mb-6">{error}</p>
        <Link href={`/${lang}/competicao`} className="text-brand-accent hover:underline">
          ← Voltar
        </Link>
      </section>
    )
  }

  // ─── LOBBY ───
  if (phase === 'lobby') {
    return (
      <>
        <section className="articles-hero">
          <div className="container-center">
            <div className="text-center py-20 md:py-32">
              <div className="inline-flex items-center gap-2 bg-brand-accent/10 text-brand-accent px-4 py-2 rounded-full mb-6">
                <Trophy size={18} />
                <span className="text-sm font-medium">Competição</span>
              </div>
              <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
                {competition?.name || 'Competição'}
              </h1>
              <p className="hero-subtitle text-center">
                {studentName ? `Olá, ${studentName}! ` : ''}
                Aguarda o início da competição...
              </p>
            </div>
          </div>
        </section>

        <section className="py-16 bg-background">
          <div className="container-center max-w-2xl mx-auto px-4 space-y-8">
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-card rounded-2xl border border-brand-divider p-6 text-center">
                <Users size={28} className="mx-auto mb-2 text-brand-accent" />
                <div className="text-3xl font-bold text-brand-deep">{participantCount}</div>
                <div className="text-sm text-brand-deep/60">Participantes</div>
              </div>
              <div className="bg-card rounded-2xl border border-brand-divider p-6 text-center">
                <Clock size={28} className="mx-auto mb-2 text-brand-accent" />
                <div className="text-3xl font-bold text-brand-deep">{competition?.questions_count || 10}</div>
                <div className="text-sm text-brand-deep/60">Perguntas</div>
              </div>
            </div>

            {competition?.streak_bonus !== false && (
              <div className="bg-brand-accent/5 border border-brand-accent/20 rounded-2xl p-6 text-center">
                <div className="flex items-center justify-center gap-2 text-brand-accent font-medium">
                  <Flame size={20} />
                  <span>Bónus de streak ativo</span>
                </div>
                <p className="text-sm text-brand-deep/60 mt-2">
                  3+ respostas corretas seguidas = bónus de pontos
                </p>
              </div>
            )}

            <div className="flex items-center justify-center gap-2 text-brand-deep/40">
              <span className="w-2 h-2 bg-amber-500 rounded-full animate-pulse" />
              Aguarda o organizador para iniciar...
            </div>

            <Link
              href={`/${lang}/competicao`}
              className="block text-center text-sm text-brand-deep/40 hover:text-brand-accent transition-colors"
            >
              ← Sair da competição
            </Link>
          </div>
        </section>
      </>
    )
  }

  // ─── QUIZ ───
  if (phase === 'quiz' && questions.length > 0) {
    const current = questions[currentQ]
    const progress = ((currentQ + 1) / questions.length) * 100

    return (
      <section className="py-8 md:py-16 bg-background min-h-screen">
        <div className="container-center max-w-2xl mx-auto px-4">
          {/* Header: progress + timer + score */}
          <div className="mb-6">
            <div className="flex items-center justify-between text-sm text-brand-deep/60 mb-2">
              <span>Pergunta {currentQ + 1} / {questions.length}</span>
              <div className="flex items-center gap-4">
                <span className="font-bold text-brand-accent">{score} pts</span>
                {streak >= 3 && (
                  <span className="flex items-center gap-1 text-amber-500 font-bold">
                    <Flame size={14} /> {streak}
                  </span>
                )}
              </div>
            </div>
            <div className="w-full bg-brand-divider rounded-full h-2">
              <div
                className="bg-brand-accent h-2 rounded-full transition-all duration-300"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>

          {/* Timer */}
          <div className="text-center mb-6">
            <div className={`inline-flex items-center gap-2 text-3xl font-bold ${
              timeLeft <= 10 ? 'text-red-500' : timeLeft <= 20 ? 'text-amber-500' : 'text-brand-deep'
            }`}>
              <Clock size={24} />
              {timeLeft}s
            </div>
          </div>

          {/* Question Card */}
          <div className="bg-card rounded-2xl border border-brand-divider p-6 md:p-8 mb-6">
            <h2 className="text-lg md:text-xl font-semibold text-brand-deep mb-6 leading-relaxed">
              {current?.question}
            </h2>

            {/* Options */}
            <div className="space-y-3">
              {current?.options?.map((opt, i) => {
                let optClass = 'border border-brand-divider hover:border-brand-accent/50 hover:bg-brand-accent/5'
                if (selected !== null) {
                  if (i === selected && feedback?.correct) {
                    optClass = 'border-2 border-green-500 bg-green-50 dark:bg-green-900/20'
                  } else if (i === selected && !feedback?.correct) {
                    optClass = 'border-2 border-red-500 bg-red-50 dark:bg-red-900/20'
                  } else if (opt === feedback?.correctAnswer) {
                    optClass = 'border-2 border-green-500 bg-green-50 dark:bg-green-900/20'
                  } else {
                    optClass = 'border border-brand-divider opacity-50'
                  }
                }

                return (
                  <button
                    key={i}
                    onClick={() => handleSelect(i)}
                    disabled={selected !== null}
                    className={`w-full text-left p-4 rounded-xl transition-all ${optClass} ${
                      selected === null ? 'cursor-pointer' : 'cursor-default'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <span className="w-8 h-8 rounded-full bg-brand-deep/5 flex items-center justify-center text-sm font-medium text-brand-deep/60 shrink-0">
                        {String.fromCharCode(65 + i)}
                      </span>
                      <span className="text-brand-deep">{opt}</span>
                    </div>
                  </button>
                )
              })}
            </div>
          </div>

          {/* Feedback */}
          {feedback && (
            <div className={`rounded-2xl p-4 mb-6 ${
              feedback.correct
                ? 'bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800'
                : 'bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800'
            }`}>
              <div className="flex items-center gap-2 mb-2">
                {feedback.correct ? (
                  <CheckCircle2 size={20} className="text-green-600" />
                ) : (
                  <XCircle size={20} className="text-red-600" />
                )}
                <span className={`font-bold ${feedback.correct ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}`}>
                  {feedback.correct ? 'Correto!' : 'Incorreto'}
                </span>
              </div>
              {!feedback.correct && feedback.correctAnswer && (
                <p className="text-sm text-brand-deep/70 mb-1">
                  Resposta correta: <strong>{feedback.correctAnswer}</strong>
                </p>
              )}
              {feedback.explanation && (
                <p className="text-sm text-brand-deep/60">{feedback.explanation}</p>
              )}
              <button
                onClick={handleNext}
                className="mt-4 w-full py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all flex items-center justify-center gap-2"
              >
                {currentQ + 1 >= questions.length ? (
                  <>Ver Resultado <Trophy size={18} /></>
                ) : (
                  <>Próxima <ArrowRight size={18} /></>
                )}
              </button>
            </div>
          )}
        </div>
      </section>
    )
  }

  // ─── RESULT ───
  if (phase === 'result') {
    const totalAnswered = results.length
    const accuracy = totalAnswered > 0 ? Math.round((correctCount / totalAnswered) * 100) : 0

    return (
      <>
        <section className="articles-hero">
          <div className="container-center">
            <div className="text-center py-20 md:py-32">
              <div className="inline-flex items-center gap-2 bg-brand-accent/10 text-brand-accent px-4 py-2 rounded-full mb-6">
                <Sparkles size={18} />
                <span className="text-sm font-medium">Resultado</span>
              </div>
              <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
                Competição Terminada!
              </h1>
              <p className="hero-subtitle text-center">
                Parabéns, {studentName}!
              </p>
            </div>
          </div>
        </section>

        <section className="py-16 bg-background">
          <div className="container-center max-w-2xl mx-auto px-4 space-y-8">
            {/* Score Card */}
            <div className="bg-card rounded-2xl border border-brand-divider p-8 text-center">
              <h2 className="text-2xl font-bold text-brand-deep mb-2">{studentName}</h2>
              <div className="text-5xl font-bold text-brand-accent mb-4">{score} pts</div>
              <div className="grid grid-cols-4 gap-4 text-center">
                <div>
                  <div className="text-xl font-bold text-green-600">{correctCount}</div>
                  <div className="text-xs text-brand-deep/60">Corretas</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-red-500">{totalAnswered - correctCount}</div>
                  <div className="text-xs text-brand-deep/60">Erradas</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-amber-500">{maxStreak}</div>
                  <div className="text-xs text-brand-deep/60">Máx. Streak</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-brand-accent">{accuracy}%</div>
                  <div className="text-xs text-brand-deep/60">Precisão</div>
                </div>
              </div>
            </div>

            {/* Claim Account */}
            {!claimed && (
              <div className="bg-brand-accent/5 border border-brand-accent/20 rounded-2xl p-6 text-center">
                <h3 className="font-bold text-brand-deep mb-2">Guardar o teu progresso</h3>
                <p className="text-sm text-brand-deep/60 mb-4">
                  Cria uma conta para guardar o teu histórico de competições
                </p>
                <button
                  onClick={handleClaimAccount}
                  disabled={claiming}
                  className="py-3 px-6 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 flex items-center justify-center gap-2 mx-auto"
                >
                  {claiming ? (
                    <Loader2 size={18} className="animate-spin" />
                  ) : (
                    <>
                      <LogIn size={18} />
                      Guardar na minha conta
                    </>
                  )}
                </button>
              </div>
            )}

            {claimed && (
              <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-2xl p-6 text-center">
                <CheckCircle2 size={24} className="mx-auto mb-2 text-green-600" />
                <p className="text-green-700 dark:text-green-400 font-medium">Progresso guardado! Receberás um email de boas-vindas.</p>
              </div>
            )}

            {/* Leaderboard */}
            {leaderboard.length > 0 && (
              <div className="bg-card rounded-2xl border border-brand-divider p-6">
                <h3 className="text-lg font-bold text-brand-deep mb-4 flex items-center gap-2">
                  <Trophy size={20} className="text-amber-500" /> Leaderboard
                </h3>
                <CompetitionLeaderboard
                  entries={leaderboard}
                  currentStudentName={studentName}
                  lang={lang}
                />
              </div>
            )}

            <div className="flex gap-3">
              <Link
                href={`/${lang}/competicao`}
                className="flex-1 py-3 rounded-xl border border-brand-divider text-brand-deep text-center hover:bg-brand-deep/5 transition-all"
              >
                Nova Competição
              </Link>
              <Link
                href={`/${lang}/quiz`}
                className="flex-1 py-3 rounded-xl bg-brand-accent text-white font-semibold text-center hover:bg-brand-accent/90 transition-all"
              >
                Quiz Normal
              </Link>
            </div>
          </div>
        </section>
      </>
    )
  }

  return null
}
