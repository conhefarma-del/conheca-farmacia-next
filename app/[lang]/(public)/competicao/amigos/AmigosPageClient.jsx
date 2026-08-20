'use client'

import { useState, useEffect, useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import {
  getPendingInvites,
  acceptFriendInvite,
  declineFriendInvite,
  joinFriendChallengeByCode,
  getFriendChallengeHistory,
} from '@/lib/actions/competition'
import { Trophy, Users, Plus, Clock, Check, X, ArrowRight, Flame, Loader2, Swords } from 'lucide-react'

export default function AmigosPageClient({ lang }) {
  const { t } = useContext(LangContext)
  const [invites, setInvites] = useState([])
  const [history, setHistory] = useState([])
  const [loading, setLoading] = useState(true)
  const [code, setCode] = useState('')
  const [joiningCode, setJoiningCode] = useState(false)
  const [error, setError] = useState('')
  const [actionLoading, setActionLoading] = useState(null) // inviteId being processed

  useEffect(() => {
    async function load() {
      try {
        const [inv, hist] = await Promise.all([getPendingInvites(), getFriendChallengeHistory()])
        setInvites(inv || [])
        setHistory(hist || [])
      } catch {} finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const handleAccept = async (inviteId) => {
    setActionLoading(inviteId)
    setError('')
    try {
      const result = await acceptFriendInvite(inviteId)
      if (result.success) {
        localStorage.setItem('comp_session', result.sessionId)
        window.location.href = `/${lang}/competicao/amigos/${result.accessCode}`
      } else {
        setError(result.error || 'Erro ao aceitar convite')
        setInvites((prev) => prev.filter((i) => i.id !== inviteId))
      }
    } catch {
      setError('Erro ao aceitar convite')
    } finally {
      setActionLoading(null)
    }
  }

  const handleDecline = async (inviteId) => {
    setActionLoading(inviteId)
    try {
      await declineFriendInvite(inviteId)
      setInvites((prev) => prev.filter((i) => i.id !== inviteId))
    } catch {} finally {
      setActionLoading(null)
    }
  }

  const handleJoinByCode = async (e) => {
    e.preventDefault()
    if (!code.trim()) return
    setJoiningCode(true)
    setError('')
    try {
      const result = await joinFriendChallengeByCode(code.trim())
      if (result.success) {
        localStorage.setItem('comp_session', result.sessionId)
        window.location.href = `/${lang}/competicao/amigos/${result.accessCode}`
      } else {
        setError(result.error || 'Desafio não encontrado')
      }
    } catch {
      setError('Erro ao entrar no desafio')
    } finally {
      setJoiningCode(false)
    }
  }

  if (loading) {
    return (
      <section className="articles-hero">
        <div className="container-center text-center py-20 md:py-32">
          <Loader2 size={40} className="mx-auto mb-4 text-brand-accent animate-spin" />
        </div>
      </section>
    )
  }

  return (
    <>
      <section className="articles-hero">
        <div className="container-center text-center py-20 md:py-32">
          <Swords size={48} className="mx-auto mb-4 text-brand-accent" />
          <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
            Desafios entre Amigos
          </h1>
          <p className="text-lg text-brand-deep/60 max-w-xl mx-auto">
            Desafia os teus amigos a um quiz de farmacologia!
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

          {/* Pending Invites */}
          {invites.length > 0 && (
            <div className="bg-card rounded-2xl border border-brand-divider p-6">
              <h3 className="text-lg font-bold text-brand-deep mb-4 flex items-center gap-2">
                <Clock size={20} className="text-amber-500" />
                Desafios Pendentes ({invites.length})
              </h3>
              <div className="space-y-3">
                {invites.map((inv) => (
                  <div key={inv.id} className="bg-background rounded-xl p-4">
                    <div className="flex items-start justify-between gap-3 mb-3">
                      <div className="min-w-0">
                        <div className="font-semibold text-brand-deep text-sm">
                          {inv.inviterName} desafiou-te!
                        </div>
                        <div className="text-xs text-brand-deep/50 mt-0.5">
                          {inv.competitionName}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => handleAccept(inv.id)}
                        disabled={actionLoading === inv.id}
                        className="flex-1 py-2 px-3 rounded-lg bg-brand-accent text-white text-sm font-semibold hover:bg-brand-accent/90 transition-all flex items-center justify-center gap-1 disabled:opacity-50"
                      >
                        {actionLoading === inv.id ? (
                          <Loader2 size={14} className="animate-spin" />
                        ) : (
                          <><Check size={14} /> Aceitar</>
                        )}
                      </button>
                      <button
                        onClick={() => handleDecline(inv.id)}
                        disabled={actionLoading === inv.id}
                        className="flex-1 py-2 px-3 rounded-lg border border-brand-divider text-brand-deep/60 text-sm font-medium hover:bg-brand-deep/5 transition-all flex items-center justify-center gap-1 disabled:opacity-50"
                      >
                        <X size={14} /> Rejeitar
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Actions */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <Link
              href={`/${lang}/competicao/amigos/criar`}
              className="bg-card rounded-2xl border border-brand-divider p-6 hover:border-brand-accent hover:shadow-md transition-all flex flex-col items-center gap-3 text-center group"
            >
              <div className="w-12 h-12 rounded-xl bg-brand-accent/10 flex items-center justify-center text-brand-accent group-hover:bg-brand-accent group-hover:text-white transition-all">
                <Plus size={24} />
              </div>
              <div>
                <div className="font-bold text-brand-deep">Criar Desafio</div>
                <div className="text-xs text-brand-deep/50 mt-1">Configura e convida amigos</div>
              </div>
            </Link>

            <div className="bg-card rounded-2xl border border-brand-divider p-6 flex flex-col items-center gap-3 text-center">
              <div className="w-12 h-12 rounded-xl bg-brand-accent/10 flex items-center justify-center text-brand-accent">
                <Users size={24} />
              </div>
              <div className="font-bold text-brand-deep">Entrar com Código</div>
              <form onSubmit={handleJoinByCode} className="w-full flex gap-2">
                <input
                  type="text"
                  value={code}
                  onChange={(e) => setCode(e.target.value.toUpperCase())}
                  placeholder="CF-XXXXXX"
                  className="flex-1 px-3 py-2 rounded-lg border border-brand-divider bg-background text-brand-deep text-sm font-mono text-center focus:outline-none focus:ring-2 focus:ring-brand-accent uppercase"
                  maxLength={10}
                />
                <button
                  type="submit"
                  disabled={joiningCode || !code.trim()}
                  className="px-4 py-2 rounded-lg bg-brand-accent text-white text-sm font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 flex items-center gap-1"
                >
                  {joiningCode ? <Loader2 size={14} className="animate-spin" /> : <><ArrowRight size={14} /></>}
                </button>
              </form>
            </div>
          </div>

          {/* History */}
          {history.length > 0 && (
            <div className="bg-card rounded-2xl border border-brand-divider p-6">
              <h3 className="text-lg font-bold text-brand-deep mb-4 flex items-center gap-2">
                <Trophy size={20} className="text-brand-accent" />
                Histórico de Desafios
              </h3>
              <div className="space-y-3">
                {history.map((h) => (
                  <div key={h.id} className="bg-background rounded-xl p-4">
                    <div className="flex items-start justify-between gap-3 mb-2">
                      <div className="min-w-0">
                        <div className="font-semibold text-brand-deep text-sm truncate">
                          {h.competitionName}
                        </div>
                        <div className="text-xs text-brand-deep/50 mt-0.5">
                          vs {h.opponents.map((o) => o.name).join(', ')}
                        </div>
                      </div>
                      <div className="text-right flex-shrink-0">
                        <div className={`text-lg font-bold ${h.position === 1 ? 'text-amber-500' : 'text-brand-deep/40'}`}>
                          {h.position}º
                        </div>
                        <div className="text-xs text-brand-deep/50">{h.myScore} pts</div>
                      </div>
                    </div>
                    <div className="flex items-center gap-4 text-xs text-brand-deep/60">
                      <span>{h.accuracy}% precisão</span>
                      {h.maxStreak > 0 && (
                        <span className="flex items-center gap-1">
                          <Flame size={12} className="text-amber-500" /> {h.maxStreak} streak
                        </span>
                      )}
                      <span className="ml-auto">
                        {new Date(h.finishedAt).toLocaleDateString('pt-PT', { day: 'numeric', month: 'short' })}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </section>
    </>
  )
}
