'use client'

import { useState, useEffect, useContext, useRef, useCallback } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import {
  getCompetitionByCode,
  getFriendLobbyPlayers,
  setPlayerReady,
  startFriendQuiz,
  getCompetitionSession,
  validateCompetitionAnswer,
  submitAnswer,
  finishCompetition,
  getFriendLeaderboard,
} from '@/lib/actions/competition'
import { Loader2, Check, Play, Users, Trophy, Flame, Target, Clock, ArrowRight, Medal } from 'lucide-react'

const MEDAL_COLORS = ['text-amber-500', 'text-gray-400', 'text-amber-700', 'text-brand-deep/40']

export default function FriendChallengeClient({ lang, code }) {
  const { t } = useContext(LangContext)
  const [phase, setPhase] = useState('loading') // loading → lobby → quiz → result
  const [error, setError] = useState('')

  // Lobby state
  const [players, setPlayers] = useState([])
  const [isReady, setIsReady] = useState(false)
  const [isCreator, setIsCreator] = useState(false)
  const [compInfo, setCompInfo] = useState(null)
  const [sessionId, setSessionId] = useState(null)
  const lobbyPollRef = useRef(null)

  // Quiz state
  const [questions, setQuestions] = useState([])
  const [currentQ, setCurrentQ] = useState(0)
  const [selected, setSelected] = useState(null)
  const [result, setResult] = useState(null)
  const [timeLeft, setTimeLeft] = useState(30)
  const [score, setScore] = useState(0)
  const [streak, setStreak] = useState(0)
  const [totalCorrect, setTotalCorrect] = useState(0)
  const timerRef = useRef(null)

  // Leaderboard
  const [leaderboard, setLeaderboard] = useState([])
  const lbPollRef = useRef(null)

  // Result
  const [finalData, setFinalData] = useState(null)

  // --- Load competition info + enter lobby ---
  useEffect(() => {
    async function init() {
      try {
        const comp = await getCompetitionByCode(code)
        if (!comp) {
          setError('Desafio não encontrado')
          setPhase('error')
          return
        }
        setCompInfo(comp)

        // Check if already has a session (from localStorage or active)
        const storedSession = localStorage.getItem('comp_session')
        if (storedSession) {
          const session = await getCompetitionSession(storedSession)
          if (session && session.competition_id === comp.id) {
            setSessionId(storedSession)
            if (comp.status === 'active' && !session.finished_at) {
              // Quiz already started — rejoin
              const quizData = await startFriendQuiz(comp.id)
              if (quizData?.ok) {
                setQuestions(quizData.questions)
                setTimeLeft(quizData.timePerQuestion || 30)
                setPhase('quiz')
                return
              }
            }
            if (session.finished_at) {
              // Already finished — show results
              const lb = await getFriendLeaderboard(comp.id)
              setLeaderboard(lb.leaderboard || [])
              setFinalData(session)
              setPhase('result')
              return
            }
          }
        }

        // Not in lobby yet — check if we can join
        if (comp.status === 'lobby') {
          setPhase('lobby')
        } else if (comp.status === 'active') {
          // Quiz in progress — try to start
          const quizData = await startFriendQuiz(comp.id)
          if (quizData?.ok) {
            setQuestions(quizData.questions)
            setTimeLeft(quizData.timePerQuestion || 30)
            setPhase('quiz')
          } else {
            setError('Não foi possível entrar no desafio')
            setPhase('error')
          }
        } else {
          setError('O desafio não está ativo')
          setPhase('error')
        }
      } catch {
        setError('Erro ao carregar desafio')
        setPhase('error')
      }
    }
    init()
  }, [code, lang])

  // --- Lobby polling ---
  const pollLobby = useCallback(async () => {
    if (!compInfo) return
    try {
      const pl = await getFriendLobbyPlayers(compInfo.id)
      setPlayers(pl || [])

      // Check if my session exists
      const me = pl?.find((p) => p.isCurrentUser)
      if (me) {
        setSessionId(me.sessionId)
        setIsReady(me.isReady)
        localStorage.setItem('comp_session', me.sessionId)
      }

      // Check if creator
      // We check by seeing if we're the first player (simplification)
      if (pl && pl.length > 0 && pl[0].isCurrentUser) {
        setIsCreator(true)
      }

      // Check if quiz started
      if (compInfo) {
        const comp = await getCompetitionByCode(code)
        if (comp?.status === 'active') {
          // Quiz started — try to get questions
          if (me?.sessionId) {
            const quizData = await startFriendQuiz(compInfo.id)
            if (quizData?.ok) {
              setQuestions(quizData.questions)
              setTimeLeft(quizData.timePerQuestion || 30)
              setPhase('quiz')
            }
          }
        }
      }
    } catch {}
  }, [compInfo, code])

  useEffect(() => {
    if (phase !== 'lobby' || !compInfo) return
    pollLobby()
    lobbyPollRef.current = setInterval(pollLobby, 3000)
    return () => clearInterval(lobbyPollRef.current)
  }, [phase, compInfo, pollLobby])

  // --- Ready ---
  const handleReady = async () => {
    if (!sessionId) return
    try {
      await setPlayerReady(sessionId)
      setIsReady(true)
    } catch {}
  }

  // --- Start quiz (creator only) ---
  const handleStart = async () => {
    if (!compInfo) return
    try {
      const result = await startFriendQuiz(compInfo.id)
      if (result?.ok) {
        setQuestions(result.questions)
        setTimeLeft(result.timePerQuestion || 30)
        setPhase('quiz')
      } else {
        setError(result?.error || 'Erro ao iniciar')
      }
    } catch {
      setError('Erro ao iniciar o desafio')
    }
  }

  // --- Quiz timer ---
  useEffect(() => {
    if (phase !== 'quiz' || questions.length === 0) return
    timerRef.current = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          // Time up — auto-submit as wrong
          handleAutoSubmit()
          return 0
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(timerRef.current)
  }, [phase, currentQ, questions.length])

  const handleAutoSubmit = async () => {
    if (!sessionId || !questions[currentQ]) return
    clearInterval(timerRef.current)
    try {
      const val = await validateCompetitionAnswer(sessionId, {
        key: questions[currentQ].key,
        selected: -1,
        questionIndex: currentQ,
        timeMs: (compInfo?.time_per_question || 30) * 1000,
      })
      const sub = await submitAnswer(sessionId, {
        questionIndex: currentQ,
        correct: false,
        points: 0,
        timeMs: (compInfo?.time_per_question || 30) * 1000,
      })
      setResult({ correct: false, points: 0, streak: sub.streak || 0 })
      setScore((s) => s + (sub.points || 0))
      setStreak(sub.streak || 0)
    } catch {} finally {
      advanceQuestion()
    }
  }

  // --- Submit answer ---
  const handleSubmit = async () => {
    if (selected === null || !sessionId || !questions[currentQ]) return
    clearInterval(timerRef.current)

    try {
      const val = await validateCompetitionAnswer(sessionId, {
        key: questions[currentQ].key,
        selected,
        questionIndex: currentQ,
        timeMs: ((compInfo?.time_per_question || 30) - timeLeft) * 1000,
      })
      const sub = await submitAnswer(sessionId, {
        questionIndex: currentQ,
        correct: val.correct,
        points: val.correct ? 100 : 0,
        timeMs: ((compInfo?.time_per_question || 30) - timeLeft) * 1000,
      })
      setResult({ correct: val.correct, points: sub.points || 0, streak: sub.streak || 0 })
      setScore((s) => s + (sub.points || 0))
      setStreak(sub.streak || 0)
      if (val.correct) setTotalCorrect((c) => c + 1)
    } catch {} finally {
      advanceQuestion()
    }
  }

  const advanceQuestion = () => {
    setTimeout(() => {
      setResult(null)
      setSelected(null)
      if (currentQ + 1 >= questions.length) {
        // Quiz finished
        finishCompetition(sessionId).catch(() => {})
        loadResults()
      } else {
        setCurrentQ((q) => q + 1)
        setTimeLeft(compInfo?.time_per_question || 30)
      }
    }, 1500)
  }

  const loadResults = async () => {
    if (!compInfo) return
    try {
      const lb = await getFriendLeaderboard(compInfo.id)
      setLeaderboard(lb.leaderboard || [])
      setFinalData({ score, correct: totalCorrect, total: questions.length })
      setPhase('result')
    } catch {
      setPhase('result')
    }
  }

  // --- Leaderboard polling during quiz ---
  useEffect(() => {
    if (phase !== 'quiz' || !compInfo) return
    const poll = async () => {
      try {
        const lb = await getFriendLeaderboard(compInfo.id)
        if (!lb.unchanged) setLeaderboard(lb.leaderboard || [])
      } catch {}
    }
    poll()
    lbPollRef.current = setInterval(poll, 3000)
    return () => clearInterval(lbPollRef.current)
  }, [phase, compInfo])

  // --- LOADING ---
  if (phase === 'loading' || phase === 'error') {
    return (
      <section className="articles-hero">
        <div className="container-center text-center py-20 md:py-32">
          {phase === 'loading' ? (
            <Loader2 size={40} className="mx-auto mb-4 text-brand-accent animate-spin" />
          ) : (
            <>
              <p className="text-lg text-red-500">{error}</p>
              <Link href={`/${lang}/competicao/amigos`} className="text-brand-accent text-sm mt-4 inline-block hover:underline">
                ← Voltar
              </Link>
            </>
          )}
        </div>
      </section>
    )
  }

  // --- LOBBY ---
  if (phase === 'lobby') {
    return (
      <>
        <section className="articles-hero">
          <div className="container-center text-center py-20 md:py-32">
            <Users size={48} className="mx-auto mb-4 text-brand-accent" />
            <h1 className="text-4xl md:text-6xl font-bold text-brand-deep mb-4">
              Sala de Espera
            </h1>
            <p className="text-lg text-brand-deep/60">
              {compInfo?.name || 'Desafio'} • {players.length}/{compInfo?.max_players || 4} jogadores
            </p>
          </div>
        </section>

        <section className="py-16 bg-background">
          <div className="container-center max-w-2xl mx-auto px-4 space-y-6">
            {error && (
              <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4 text-red-600 text-sm text-center">
                {error}
              </div>
            )}

            {/* Players */}
            <div className="bg-card rounded-2xl border border-brand-divider p-6">
              <h3 className="text-lg font-bold text-brand-deep mb-4">Jogadores</h3>
              <div className="space-y-3">
                {players.map((p, idx) => (
                  <div key={p.sessionId} className="flex items-center gap-3 p-3 rounded-xl bg-background">
                    {p.avatarUrl ? (
                      <img src={p.avatarUrl} alt="" className="w-10 h-10 rounded-full object-cover" />
                    ) : (
                      <div className="w-10 h-10 rounded-full bg-brand-accent/10 flex items-center justify-center text-brand-accent font-bold">
                        {p.name.charAt(0).toUpperCase()}
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-medium text-brand-deep truncate">
                        {p.name} {p.isCurrentUser && <span className="text-xs text-brand-deep/40">(tu)</span>}
                      </div>
                    </div>
                    {p.isReady ? (
                      <span className="text-xs text-green-600 font-medium flex items-center gap-1">
                        <Check size={14} /> Pronto
                      </span>
                    ) : (
                      <span className="text-xs text-brand-deep/40">A aguardar...</span>
                    )}
                  </div>
                ))}
                {players.length === 0 && (
                  <p className="text-sm text-brand-deep/40 text-center py-4">A aguardar jogadores...</p>
                )}
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-3">
              {!isReady ? (
                <button
                  onClick={handleReady}
                  className="flex-1 py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all flex items-center justify-center gap-2"
                >
                  <Check size={18} /> Estou Pronto!
                </button>
              ) : (
                <div className="flex-1 py-3 rounded-xl bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 text-green-600 font-semibold text-center flex items-center justify-center gap-2">
                  <Check size={18} /> Pronto!
                </div>
              )}
              {isCreator && players.length >= 2 && (
                <button
                  onClick={handleStart}
                  disabled={!players.every((p) => p.isReady)}
                  className="flex-1 py-3 rounded-xl bg-amber-500 text-white font-semibold hover:bg-amber-600 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                >
                  <Play size={18} /> Começar Quiz
                </button>
              )}
            </div>

            <Link href={`/${lang}/competicao/amigos`} className="block text-center text-sm text-brand-deep/50 hover:text-brand-accent transition-colors">
              ← Voltar
            </Link>
          </div>
        </section>
      </>
    )
  }

  // --- QUIZ ---
  if (phase === 'quiz' && questions.length > 0) {
    const q = questions[currentQ]
    const progress = ((currentQ + 1) / questions.length) * 100

    return (
      <section className="py-8 bg-background min-h-screen">
        <div className="container-center max-w-2xl mx-auto px-4">
          {/* Header */}
          <div className="flex items-center justify-between mb-6">
            <div className="text-sm text-brand-deep/60">
              {currentQ + 1}/{questions.length}
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-1 text-sm font-bold text-brand-accent">
                <Trophy size={14} /> {score}
              </div>
              {streak >= 3 && (
                <div className="flex items-center gap-1 text-sm font-bold text-amber-500">
                  <Flame size={14} /> {streak}
                </div>
              )}
            </div>
            <div className={`flex items-center gap-1 text-sm font-bold ${timeLeft <= 5 ? 'text-red-500' : 'text-brand-deep/60'}`}>
              <Clock size={14} /> {timeLeft}s
            </div>
          </div>

          {/* Progress bar */}
          <div className="w-full h-2 bg-brand-divider rounded-full mb-8 overflow-hidden">
            <div className="h-full bg-brand-accent rounded-full transition-all duration-300" style={{ width: `${progress}%` }} />
          </div>

          {/* Question */}
          <div className="bg-card rounded-2xl border border-brand-divider p-8 mb-6">
            <p className="text-lg font-semibold text-brand-deep mb-6">{q.question}</p>
            <div className="space-y-3">
              {q.options.map((opt, idx) => (
                <button
                  key={idx}
                  onClick={() => !result && setSelected(idx)}
                  disabled={result !== null}
                  className={`w-full text-left p-4 rounded-xl border text-sm transition-all ${
                    result !== null
                      ? idx === q.correctIndex
                        ? 'bg-green-50 dark:bg-green-900/20 border-green-400 text-green-700'
                        : idx === selected
                          ? 'bg-red-50 dark:bg-red-900/20 border-red-400 text-red-700'
                          : 'border-brand-divider text-brand-deep/40'
                      : selected === idx
                        ? 'bg-brand-accent/10 border-brand-accent text-brand-deep'
                        : 'border-brand-divider text-brand-deep hover:border-brand-accent hover:bg-brand-accent/5'
                  }`}
                >
                  {opt}
                </button>
              ))}
            </div>
          </div>

          {/* Result feedback */}
          {result && (
            <div className={`rounded-xl p-4 text-center text-sm font-medium mb-6 ${
              result.correct
                ? 'bg-green-50 dark:bg-green-900/20 text-green-600'
                : 'bg-red-50 dark:bg-red-900/20 text-red-600'
            }`}>
              {result.correct ? `Correto! +${result.points} pts` : 'Incorreto'}
              {result.streak >= 3 && ` • Streak ${result.streak}!`}
            </div>
          )}

          {/* Submit */}
          {!result && (
            <button
              onClick={handleSubmit}
              disabled={selected === null}
              className="w-full py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Confirmar Resposta
            </button>
          )}

          {/* Mini leaderboard */}
          {leaderboard.length > 0 && (
            <div className="mt-8 bg-card rounded-2xl border border-brand-divider p-4">
              <div className="text-xs text-brand-deep/50 mb-2 text-center">Leaderboard ao vivo</div>
              <div className="space-y-2">
                {leaderboard.map((p) => (
                  <div key={p.sessionId} className="flex items-center gap-2 text-sm">
                    <span className="w-5 text-center font-bold text-brand-deep/40">{p.position}</span>
                    <span className="flex-1 text-brand-deep truncate">{p.name}</span>
                    <span className="font-bold text-brand-accent">{p.score}</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </section>
    )
  }

  // --- RESULT ---
  const myResult = leaderboard.find((p) => p.isFinished) || finalData || {}
  const myPosition = leaderboard.findIndex((p) => !p.isFinished) + 1 || myResult.position || 1

  return (
    <>
      <section className="articles-hero">
        <div className="container-center text-center py-20 md:py-32">
          <Trophy size={48} className={`mx-auto mb-4 ${myPosition === 1 ? 'text-amber-500' : 'text-brand-accent'}`} />
          <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
            {myPosition === 1 ? 'Vencedor!' : `${myPosition}º Lugar`}
          </h1>
          <p className="text-lg text-brand-deep/60">{compInfo?.name || 'Desafio'}</p>
        </div>
      </section>

      <section className="py-16 bg-background">
        <div className="container-center max-w-2xl mx-auto px-4 space-y-6">
          {/* My stats */}
          <div className="bg-card rounded-2xl border border-brand-divider p-6">
            <h3 className="text-lg font-bold text-brand-deep mb-4 text-center">As Tuas Estatísticas</h3>
            <div className="grid grid-cols-3 gap-4">
              <div className="bg-background rounded-xl p-4 text-center">
                <div className="text-2xl font-bold text-brand-accent">{leaderboard.find((p) => p.isFinished)?.score || score}</div>
                <div className="text-xs text-brand-deep/50">Pontos</div>
              </div>
              <div className="bg-background rounded-xl p-4 text-center">
                <div className="text-2xl font-bold text-brand-deep">{leaderboard.find((p) => p.isFinished)?.accuracy || Math.round((totalCorrect / (questions.length || 1)) * 100)}%</div>
                <div className="text-xs text-brand-deep/50">Precisão</div>
              </div>
              <div className="bg-background rounded-xl p-4 text-center">
                <div className="text-2xl font-bold text-amber-500">{leaderboard.find((p) => p.isFinished)?.streak || 0}</div>
                <div className="text-xs text-brand-deep/50">Melhor Streak</div>
              </div>
            </div>
          </div>

          {/* Leaderboard */}
          {leaderboard.length > 0 && (
            <div className="bg-card rounded-2xl border border-brand-divider p-6">
              <h3 className="text-lg font-bold text-brand-deep mb-4 flex items-center gap-2">
                <Medal size={20} className="text-brand-accent" />
                Resultado Final
              </h3>
              <div className="space-y-3">
                {leaderboard.map((p) => (
                  <div key={p.sessionId} className={`flex items-center gap-3 p-3 rounded-xl ${p.isFinished ? 'bg-background' : 'bg-background opacity-50'}`}>
                    <span className={`text-lg font-bold w-8 text-center ${MEDAL_COLORS[p.position - 1] || 'text-brand-deep/40'}`}>
                      {p.position}º
                    </span>
                    {p.avatarUrl ? (
                      <img src={p.avatarUrl} alt="" className="w-8 h-8 rounded-full object-cover" />
                    ) : (
                      <div className="w-8 h-8 rounded-full bg-brand-accent/10 flex items-center justify-center text-brand-accent text-xs font-bold">
                        {p.name.charAt(0).toUpperCase()}
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-medium text-brand-deep truncate">{p.name}</div>
                      <div className="text-xs text-brand-deep/50">{p.accuracy}% • {p.total} perguntas</div>
                    </div>
                    <div className="text-right">
                      <div className="text-lg font-bold text-brand-accent">{p.score}</div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Actions */}
          <div className="flex gap-3">
            <Link
              href={`/${lang}/competicao/amigos`}
              className="flex-1 py-3 rounded-xl border border-brand-divider text-brand-deep font-medium text-center hover:bg-brand-deep/5 transition-all"
            >
              Voltar
            </Link>
            <Link
              href={`/${lang}/perfil`}
              className="flex-1 py-3 rounded-xl bg-brand-accent text-white font-semibold text-center hover:bg-brand-accent/90 transition-all"
            >
              Ver Perfil
            </Link>
          </div>
        </div>
      </section>
    </>
  )
}
