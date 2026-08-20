'use client'

import { useState, useEffect, useCallback } from 'react'
import Link from 'next/link'
import { Trophy, Users, Clock, Play, ArrowRight, Trophy as Crown } from 'lucide-react'
import { getCompetitionByCode, getCompetitionParticipantCount, submitAnswer, finishCompetition, getCompetitionLeaderboard } from '@/lib/actions/competition'

export default function CompeticaoLobbyClient({ lang, code }) {
  const [competition, setCompetition] = useState(null)
  const [sessionId, setSessionId] = useState(null)
  const [studentName, setStudentName] = useState('')
  const [participantCount, setParticipantCount] = useState(0)
  const [loading, setLoading] = useState(true)
  const [phase, setPhase] = useState('lobby') // lobby → quiz → result

  // Quiz state
  const [questions, setQuestions] = useState([])
  const [currentQ, setCurrentQ] = useState(0)
  const [score, setScore] = useState(0)
  const [correctCount, setCorrectCount] = useState(0)
  const [streak, setStreak] = useState(0)
  const [maxStreak, setMaxStreak] = useState(0)
  const [selectedAnswer, setSelectedAnswer] = useState(null)
  const [showResult, setShowResult] = useState(false)
  const [timeLeft, setTimeLeft] = useState(0)
  const [quizLoading, setQuizLoading] = useState(false)

  // Result state
  const [leaderboard, setLeaderboard] = useState([])

  // Load competition info
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

      const info = await getCompetitionByCode(code)
      if (!info) {
        window.location.href = `/${lang}/competicao`
        return
      }
      setCompetition(info)

      const count = await getCompetitionParticipantCount(info.id)
      setParticipantCount(count)
      setLoading(false)
    }
    load()
  }, [code, lang])

  // Poll participant count
  useEffect(() => {
    if (!competition || phase !== 'lobby') return
    const interval = setInterval(async () => {
      const count = await getCompetitionParticipantCount(competition.id)
      setParticipantCount(count)
      // Also refresh competition status
      const info = await getCompetitionByCode(code)
      if (info?.status === 'active') {
        startQuiz()
      }
    }, 5000)
    return () => clearInterval(interval)
  }, [competition, code, phase])

  const startQuiz = useCallback(async () => {
    setQuizLoading(true)
    // In a real implementation, we'd fetch questions from the quiz engine
    // For now, set phase to quiz with placeholder
    setPhase('quiz')
    setTimeLeft(competition?.time_per_question || 30)
    setQuizLoading(false)
  }, [competition])

  // Timer
  useEffect(() => {
    if (phase !== 'quiz' || timeLeft <= 0) return
    const timer = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(timer)
          handleNextQuestion()
          return competition?.time_per_question || 30
        }
        return prev - 1
      })
    }, 1000)
    return () => clearInterval(timer)
  }, [phase, timeLeft, currentQ])

  const handleNextQuestion = async () => {
    if (currentQ >= (competition?.questions_count || 10) - 1) {
      // Quiz finished
      await finishCompetition(sessionId)
      const lb = await getCompetitionLeaderboard(competition.id, 20)
      setLeaderboard(lb)
      setPhase('result')
      return
    }
    setSelectedAnswer(null)
    setShowResult(false)
    setCurrentQ((prev) => prev + 1)
    setTimeLeft(competition?.time_per_question || 30)
  }

  const handleAnswer = async (correct, points) => {
    setSelectedAnswer('answered')
    setShowResult(true)
    const result = await submitAnswer(sessionId, {
      questionIndex: currentQ,
      correct,
      points,
      timeMs: ((competition?.time_per_question || 30) - timeLeft) * 1000,
    })
    if (result.success) {
      setScore(result.totalScore)
      setCorrectCount((prev) => prev + (correct ? 1 : 0))
      setStreak(result.streak)
      if (result.streak > maxStreak) setMaxStreak(result.streak)
    }
  }

  if (loading) {
    return (
      <section className="py-20 text-center">
        <span className="w-8 h-8 border-3 border-brand-accent/30 border-t-brand-accent rounded-full animate-spin inline-block" />
      </section>
    )
  }

  if (!competition) {
    return (
      <section className="py-20 text-center">
        <p className="text-brand-deep/60">Competição não encontrada</p>
        <Link href={`/${lang}/competicao`} className="text-brand-accent mt-4 inline-block">
          ← Voltar
        </Link>
      </section>
    )
  }

  // LOBBY PHASE
  if (phase === 'lobby') {
    return (
      <>
        <section className="articles-hero">
          <div className="container-center">
            <div className="text-center py-20 md:py-32">
              <Trophy size={48} className="mx-auto mb-4 text-brand-accent" />
              <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
                {competition.name}
              </h1>
              <p className="hero-subtitle text-center">
                {studentName ? `Olá, ${studentName}! ` : ''}
                {competition.status === 'lobby'
                  ? 'Aguarda o início da competição...'
                  : 'Competição em curso'}
              </p>
            </div>
          </div>
        </section>

        <section className="py-16 bg-background">
          <div className="container-center max-w-lg mx-auto px-4 text-center space-y-8">
            <div className="grid grid-cols-2 gap-4">
              <div className="bg-card rounded-2xl border border-brand-divider p-6">
                <Users size={28} className="mx-auto mb-2 text-brand-accent" />
                <div className="text-3xl font-bold text-brand-deep">{participantCount}</div>
                <div className="text-sm text-brand-deep/60">Participantes</div>
              </div>
              <div className="bg-card rounded-2xl border border-brand-divider p-6">
                <Clock size={28} className="mx-auto mb-2 text-brand-accent" />
                <div className="text-3xl font-bold text-brand-deep">{competition.questions_count}</div>
                <div className="text-sm text-brand-deep/60">Perguntas</div>
              </div>
            </div>

            <div className="bg-brand-accent/5 border border-brand-accent/20 rounded-2xl p-6">
              <div className="flex items-center justify-center gap-2 text-brand-deep/60 mb-2">
                <Clock size={16} />
                <span>{competition.time_per_question} segundos por pergunta</span>
              </div>
              {competition.streak_bonus && (
                <div className="flex items-center justify-center gap-2 text-brand-accent font-medium">
                  <Trophy size={16} />
                  <span>Bónus de streak ativo</span>
                </div>
              )}
            </div>

            {competition.status === 'lobby' && (
              <div className="flex items-center justify-center gap-2 text-brand-deep/40">
                <span className="w-2 h-2 bg-amber-500 rounded-full animate-pulse" />
                Aguarda o organizador para iniciar...
              </div>
            )}

            <Link
              href={`/${lang}/competicao`}
              className="text-sm text-brand-deep/40 hover:text-brand-accent transition-colors"
            >
              ← Sair da competição
            </Link>
          </div>
        </section>
      </>
    )
  }

  // QUIZ PHASE (simplified — full quiz engine integration would be needed)
  if (phase === 'quiz') {
    return (
      <section className="py-20 bg-background">
        <div className="container-center max-w-2xl mx-auto px-4">
          <div className="text-center mb-8">
            <div className="flex items-center justify-center gap-6 text-sm text-brand-deep/60 mb-4">
              <span>Pergunta {currentQ + 1} / {competition.questions_count}</span>
              <span>{score} pts</span>
              <span className={streak >= 3 ? 'text-amber-500 font-bold' : ''}>
                Streak: {streak}
              </span>
            </div>
            <div className="w-full bg-brand-divider rounded-full h-2 mb-4">
              <div
                className="bg-brand-accent h-2 rounded-full transition-all duration-300"
                style={{ width: `${((currentQ + 1) / competition.questions_count) * 100}%` }}
              />
            </div>
            <div className={`text-4xl font-bold ${timeLeft <= 10 ? 'text-red-500' : 'text-brand-deep'}`}>
              {timeLeft}s
            </div>
          </div>

          {/* Quiz content would be populated from the quiz engine */}
          <div className="bg-card rounded-2xl border border-brand-divider p-8 text-center">
            <p className="text-brand-deep/60">A carregar pergunta...</p>
          </div>
        </div>
      </section>
    )
  }

  // RESULT PHASE
  return (
    <>
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-20 md:py-32">
            <Trophy size={48} className="mx-auto mb-4 text-brand-accent" />
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              Competição Terminada!
            </h1>
          </div>
        </div>
      </section>

      <section className="py-16 bg-background">
        <div className="container-center max-w-2xl mx-auto px-4 space-y-8">
          <div className="bg-card rounded-2xl border border-brand-divider p-8 text-center">
            <h2 className="text-2xl font-bold text-brand-deep mb-2">{studentName}</h2>
            <div className="text-5xl font-bold text-brand-accent mb-4">{score} pts</div>
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <div className="text-xl font-bold text-brand-deep">{correctCount}</div>
                <div className="text-xs text-brand-deep/60">Corretas</div>
              </div>
              <div>
                <div className="text-xl font-bold text-brand-deep">{competition.questions_count - correctCount}</div>
                <div className="text-xs text-brand-deep/60">Erradas</div>
              </div>
              <div>
                <div className="text-xl font-bold text-amber-500">{maxStreak}</div>
                <div className="text-xs text-brand-deep/60">Máx. Streak</div>
              </div>
            </div>
          </div>

          {/* Leaderboard */}
          {leaderboard.length > 0 && (
            <div className="bg-card rounded-2xl border border-brand-divider p-6">
              <h3 className="text-lg font-bold text-brand-deep mb-4 flex items-center gap-2">
                <Crown size={20} className="text-amber-500" /> Leaderboard
              </h3>
              <div className="space-y-2">
                {leaderboard.map((entry, i) => (
                  <div
                    key={entry.id}
                    className={`flex items-center gap-3 p-3 rounded-xl ${
                      entry.student_name === studentName ? 'bg-brand-accent/10 border border-brand-accent/20' : ''
                    }`}
                  >
                    <span className="w-8 text-center font-bold text-brand-deep">
                      {i === 0 ? '🥇' : i === 1 ? '🥈' : i === 2 ? '🥉' : `${entry.position}`}
                    </span>
                    <span className="flex-1 text-brand-deep font-medium">{entry.student_name}</span>
                    <span className="text-brand-accent font-bold">{entry.total_score} pts</span>
                  </div>
                ))}
              </div>
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
