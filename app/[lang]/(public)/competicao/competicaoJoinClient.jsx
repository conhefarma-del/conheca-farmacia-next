'use client'

import { useState } from 'react'
import Link from 'next/link'
import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { joinCompetition, getCompetitionByCode } from '@/lib/actions/competition'
import { Trophy, Users, ArrowRight, Search } from 'lucide-react'

export default function CompeticaoJoinClient({ lang }) {
  const { t } = useContext(LangContext)
  const [code, setCode] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [step, setStep] = useState('code') // code → info → join
  const [compInfo, setCompInfo] = useState(null)
  const [studentName, setStudentName] = useState('')
  const [schoolName, setSchoolName] = useState('')
  const [className, setClassName] = useState('')
  const [joining, setJoining] = useState(false)

  const handleLookupCode = async (e) => {
    e.preventDefault()
    if (!code.trim()) return
    setLoading(true)
    setError('')
    try {
      const info = await getCompetitionByCode(code.trim())
      if (!info) {
        setError(t('competition.join.error_not_found') || 'Competição não encontrada ou inativa')
        setLoading(false)
        return
      }
      setCompInfo(info)
      setStep('info')
    } catch {
      setError(t('competition.join.error_not_found') || 'Competição não encontrada ou inativa')
    } finally {
      setLoading(false)
    }
  }

  const handleJoin = async (e) => {
    e.preventDefault()
    if (!studentName.trim()) return
    setJoining(true)
    setError('')
    try {
      const result = await joinCompetition(code.trim(), {
        studentName: studentName.trim(),
        schoolName: schoolName.trim() || undefined,
        className: className.trim() || undefined,
      })
      if (result.success) {
        // Store session for later
        localStorage.setItem('comp_session', result.sessionId)
        localStorage.setItem('comp_name', studentName.trim())
        // Navigate to lobby
        window.location.href = `/${lang}/competicao/${code.trim()}`
      } else {
        setError(result.error || 'Erro ao entrar na competição')
      }
    } catch {
      setError('Erro ao entrar na competição')
    } finally {
      setJoining(false)
    }
  }

  return (
    <>
      {/* Hero Section — padrão /artigos */}
      <section className="articles-hero">
        <div className="container-center">
          <div className="text-center py-20 md:py-32">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('competition.join.title') || 'Entrar numa Competição'}
            </h1>
            <p className="hero-subtitle text-center">
              {t('competition.join.subtitle') || 'Insere o código da competição para te juntares ao quiz interativo'}
            </p>
          </div>
        </div>
      </section>

      {/* Join Form */}
      <section className="py-16 bg-background">
        <div className="container-center max-w-xl mx-auto px-4">
          {step === 'code' && (
            <form onSubmit={handleLookupCode} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-brand-deep mb-2">
                  {t('competition.join.code_label') || 'Código da Competição'}
                </label>
                <div className="relative">
                  <Search size={20} className="absolute left-4 top-1/2 -translate-y-1/2 text-brand-deep/40" />
                  <input
                    type="text"
                    value={code}
                    onChange={(e) => setCode(e.target.value.toUpperCase())}
                    placeholder="CF-XXXXXX"
                    className="w-full pl-12 pr-4 py-4 rounded-2xl border border-brand-divider shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep text-center text-2xl font-mono tracking-wider"
                    autoFocus
                  />
                </div>
              </div>
              {error && (
                <p className="text-red-600 text-sm text-center">{error}</p>
              )}
              <button
                type="submit"
                disabled={loading || !code.trim()}
                className="w-full py-4 rounded-2xl bg-brand-accent text-white font-semibold text-lg hover:bg-brand-accent/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {loading ? (
                  <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                ) : (
                  <>
                    {t('competition.join.lookup') || 'Verificar Código'}
                    <ArrowRight size={20} />
                  </>
                )}
              </button>
            </form>
          )}

          {step === 'info' && compInfo && (
            <div className="space-y-6">
              <div className="bg-brand-accent/5 border border-brand-accent/20 rounded-2xl p-6 text-center">
                <Trophy size={32} className="mx-auto mb-3 text-brand-accent" />
                <h2 className="text-xl font-bold text-brand-deep mb-1">{compInfo.name}</h2>
                <div className="flex items-center justify-center gap-4 text-sm text-brand-deep/60">
                  <span>{compInfo.questions_count || 10} perguntas</span>
                  <span>·</span>
                  <span>{compInfo.time_per_question || 30}s por pergunta</span>
                </div>
              </div>

              <form onSubmit={handleJoin} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-brand-deep mb-2">
                    {t('competition.join.name_label') || 'O teu nome'}
                  </label>
                  <input
                    type="text"
                    value={studentName}
                    onChange={(e) => setStudentName(e.target.value)}
                    placeholder={t('competition.join.name_placeholder') || 'Como te chamas?'}
                    className="w-full px-4 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                    autoFocus
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-brand-deep mb-2">
                    {t('competition.join.school_label') || 'Escola (opcional)'}
                  </label>
                  <input
                    type="text"
                    value={schoolName}
                    onChange={(e) => setSchoolName(e.target.value)}
                    placeholder={t('competition.join.school_placeholder') || 'Nome da escola'}
                    className="w-full px-4 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-brand-deep mb-2">
                    {t('competition.join.class_label') || 'Turma (opcional)'}
                  </label>
                  <input
                    type="text"
                    value={className}
                    onChange={(e) => setClassName(e.target.value)}
                    placeholder={t('competition.join.class_placeholder') || 'Ex: 10.ª A'}
                    className="w-full px-4 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                  />
                </div>

                {error && (
                  <p className="text-red-600 text-sm text-center">{error}</p>
                )}

                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={() => { setStep('code'); setCompInfo(null); setError('') }}
                    className="px-6 py-3 rounded-xl border border-brand-divider text-brand-deep hover:bg-brand-deep/5 transition-all"
                  >
                    {t('common.back') || 'Voltar'}
                  </button>
                  <button
                    type="submit"
                    disabled={joining || !studentName.trim()}
                    className="flex-1 py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                  >
                    {joining ? (
                      <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    ) : (
                      <>
                        <Users size={18} />
                        {t('competition.join.enter') || 'Entrar na Competição'}
                      </>
                    )}
                  </button>
                </div>
              </form>
            </div>
          )}
        </div>
      </section>
    </>
  )
}
