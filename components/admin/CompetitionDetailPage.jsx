'use client'

import { useState, useEffect, useCallback } from 'react'
import { ArrowLeft, Play, Square, Users, Clock, Trophy, Zap } from 'lucide-react'
import Link from 'next/link'
import { getCompetitionById, getCompetitionLeaderboardAdmin, activateCompetition, endCompetition } from '@/lib/actions/competition'

export default function CompetitionDetailPage({ lang, competitionId }) {
  const [comp, setComp] = useState(null)
  const [leaderboard, setLeaderboard] = useState([])
  const [loading, setLoading] = useState(true)
  const [message, setMessage] = useState(null)

  const refresh = useCallback(async () => {
    const [c, lb] = await Promise.all([
      getCompetitionById(competitionId),
      getCompetitionLeaderboardAdmin(competitionId),
    ])
    setComp(c)
    setLeaderboard(lb || [])
    setLoading(false)
  }, [competitionId])

  useEffect(() => { refresh() }, [refresh])

  // Polling a cada 5s se competição estiver ativa
  useEffect(() => {
    if (!comp || (comp.status !== 'lobby' && comp.status !== 'active')) return
    const interval = setInterval(refresh, 5000)
    return () => clearInterval(interval)
  }, [comp?.status, refresh])

  const handleAction = async (fn, okText) => {
    const res = await fn()
    if (res.success) { setMessage(okText); refresh() } else alert(res.error)
  }

  if (loading) return <div style={{ padding: 40, textAlign: 'center' }}>A carregar...</div>
  if (!comp) return <div style={{ padding: 40, textAlign: 'center' }}>Competição não encontrada</div>

  const statusColors = { draft: '#d97706', lobby: '#2563eb', active: '#059669', ended: '#6b7280', cancelled: '#dc2626' }

  return (
    <div>
      <Link href={`/${lang}/admin/competicoes`} style={{ display: 'inline-flex', alignItems: 'center', gap: 6, color: 'var(--admin-accent)', fontSize: 14, marginBottom: 16 }}>
        <ArrowLeft size={16} /> Voltar
      </Link>

      <div className="admin-page-header">
        <div>
          <h1>{comp.name}</h1>
          <p className="admin-page-subtitle">
            <span style={{ color: statusColors[comp.status], fontWeight: 700 }}>{comp.status.toUpperCase()}</span>
            {' · '}{comp.questions_count} perguntas · {comp.time_per_question}s · {comp.access_code}
          </p>
        </div>
        <div style={{ display: 'flex', gap: 8 }}>
          {comp.status === 'lobby' && (
            <button className="admin-btn admin-btn-success" onClick={() => handleAction(() => activateCompetition(comp.id), 'Competição iniciada!')}>
              <Play size={16} /> Iniciar Quiz
            </button>
          )}
          {(comp.status === 'lobby' || comp.status === 'active') && (
            <button className="admin-btn admin-btn-warning" onClick={() => handleAction(() => endCompetition(comp.id), 'Competição terminada.')}>
              <Square size={16} /> Terminar
            </button>
          )}
        </div>
      </div>

      {message && <div className="admin-message admin-success-message">{message}</div>}

      {/* Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 24 }}>
        <div className="admin-dashboard-card" style={{ textAlign: 'center', padding: 20 }}>
          <Users size={24} style={{ color: 'var(--admin-accent)', marginBottom: 8 }} />
          <div style={{ fontSize: 28, fontWeight: 800 }}>{leaderboard.length}</div>
          <div style={{ fontSize: 12, color: 'var(--admin-text-muted)' }}>Participantes</div>
        </div>
        <div className="admin-dashboard-card" style={{ textAlign: 'center', padding: 20 }}>
          <Trophy size={24} style={{ color: '#d97706', marginBottom: 8 }} />
          <div style={{ fontSize: 28, fontWeight: 800 }}>{leaderboard[0]?.total_score || 0}</div>
          <div style={{ fontSize: 12, color: 'var(--admin-text-muted)' }}>Maior Pontuação</div>
        </div>
        <div className="admin-dashboard-card" style={{ textAlign: 'center', padding: 20 }}>
          <Zap size={24} style={{ color: '#dc2626', marginBottom: 8 }} />
          <div style={{ fontSize: 28, fontWeight: 800 }}>{leaderboard.reduce((max, r) => Math.max(max, r.max_streak || 0), 0)}</div>
          <div style={{ fontSize: 12, color: 'var(--admin-text-muted)' }}>Maior Streak</div>
        </div>
        <div className="admin-dashboard-card" style={{ textAlign: 'center', padding: 20 }}>
          <Clock size={24} style={{ color: 'var(--admin-text-muted)', marginBottom: 8 }} />
          <div style={{ fontSize: 28, fontWeight: 800 }}>{leaderboard.length > 0 ? Math.round(leaderboard.reduce((s, r) => s + (r.correct_count / Math.max(r.total_answered, 1)), 0) / leaderboard.length * 100) : 0}%</div>
          <div style={{ fontSize: 12, color: 'var(--admin-text-muted)' }}>Precisão Média</div>
        </div>
      </div>

      {/* Leaderboard */}
      <div className="admin-dashboard-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
          <h3 style={{ margin: 0 }}>Leaderboard</h3>
          {(comp.status === 'lobby' || comp.status === 'active') && (
            <span style={{ fontSize: 12, color: 'var(--admin-text-muted)' }}>Auto-refresh a cada 5s</span>
          )}
        </div>
        {leaderboard.length === 0 ? (
          <p style={{ textAlign: 'center', padding: 40, color: 'var(--admin-text-muted)' }}>Nenhum resultado ainda</p>
        ) : (
          <div className="admin-table-wrapper">
            <table className="admin-table">
              <thead>
                <tr><th>#</th><th>Aluno</th><th>Turma</th><th>Pontos</th><th>Precisão</th><th>Streak</th></tr>
              </thead>
              <tbody>
                {leaderboard.map((r) => (
                  <tr key={r.id}>
                    <td style={{ fontWeight: 800, fontSize: 16 }}>{r.position <= 3 ? ['🥇','🥈','🥉'][r.position-1] : r.position}</td>
                    <td><strong>{r.student_name}</strong></td>
                    <td style={{ fontSize: 13, color: 'var(--admin-text-muted)' }}>{r.class_name || '-'}{r.school_name ? ` · ${r.school_name}` : ''}</td>
                    <td style={{ fontWeight: 800, fontSize: 16 }}>{r.total_score}</td>
                    <td>{r.total_answered > 0 ? Math.round((r.correct_count / r.total_answered) * 100) : 0}%</td>
                    <td>🔥 {r.max_streak}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}
