'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { LogOut, Mail, Trophy, BookOpen, Pill, ShieldAlert, ClipboardList, Atom, Loader2, School, Target, BrainCircuit, Flame } from 'lucide-react'
import { getUserStats, getUserCompetitionHistory } from '@/lib/actions/profile'

export default function PerfilClient({ lang }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [signingOut, setSigningOut] = useState(false)
  const [editingName, setEditingName] = useState(false)
  const [newName, setNewName] = useState('')
  const [saving, setSaving] = useState(false)
  const [saveMsg, setSaveMsg] = useState('')
  const [stats, setStats] = useState(null)
  const [statsLoading, setStatsLoading] = useState(true)
  const [compHistory, setCompHistory] = useState([])

  useEffect(() => {
    async function loadUser() {
      const supabase = createClient()
      const { data: { user }, error } = await supabase.auth.getUser()
      if (error || !user) {
        window.location.href = `/${lang}/entrar`
        return
      }
      setUser(user)
      setNewName(user.user_metadata?.full_name || user.user_metadata?.display_name || '')
      setLoading(false)
      // Load stats after user is loaded
      try {
        const [s, ch] = await Promise.all([getUserStats(), getUserCompetitionHistory()])
        setStats(s)
        setCompHistory(ch || [])
      } catch {
        // Stats load failed silently
      } finally {
        setStatsLoading(false)
      }
    }
    loadUser()
  }, [lang])

  const handleSignOut = async () => {
    setSigningOut(true)
    const supabase = createClient()
    await supabase.auth.signOut()
    window.location.href = `/${lang}`
  }

  const handleSaveName = async () => {
    if (!newName.trim()) return
    setSaving(true)
    setSaveMsg('')
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({
        data: { full_name: newName.trim(), display_name: newName.trim() },
      })
      if (error) {
        setSaveMsg('Erro ao guardar: ' + error.message)
      } else {
        setUser((prev) => ({
          ...prev,
          user_metadata: { ...prev.user_metadata, full_name: newName.trim(), display_name: newName.trim() },
        }))
        setEditingName(false)
        setSaveMsg('Nome atualizado!')
      }
    } catch {
      setSaveMsg('Erro ao conectar ao servidor')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <section className="py-20 text-center">
        <Loader2 size={40} className="mx-auto mb-4 text-brand-accent animate-spin" />
      </section>
    )
  }

  if (!user) return null

  const displayName = user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0] || 'Utilizador'
  const avatarUrl = user.user_metadata?.avatar_url
  const createdAt = new Date(user.created_at).toLocaleDateString('pt-PT', { year: 'numeric', month: 'long', day: 'numeric' })

  const tools = [
    { href: `/${lang}/medicamentos`, label: 'Medicamentos', desc: 'Explora fármacos, mecanismos e perfis clínicos', icon: <Pill size={20} /> },
    { href: `/${lang}/interacoes`, label: 'Interações', desc: 'Verifica interações medicamentosas', icon: <ShieldAlert size={20} /> },
    { href: `/${lang}/competicao`, label: 'Competição', desc: 'Quiz competitivo entre escolas', icon: <Trophy size={20} /> },
    { href: `/${lang}/praticar`, label: 'Quiz', desc: 'Testa os teus conhecimentos', icon: <BrainCircuit size={20} /> },
    { href: `/${lang}/flashcards`, label: 'Flashcards', desc: 'Memoriza conceitos-chave', icon: <BookOpen size={20} /> },
    { href: `/${lang}/classes`, label: 'Classes Terapêuticas', desc: 'Explora classes ATC e exemplos', icon: <ClipboardList size={20} /> },
    { href: `/${lang}/alvos`, label: 'Alvos Moleculares', desc: 'Mecanismos de ação dos fármacos', icon: <Atom size={20} /> },
  ]

  const schoolName = !statsLoading && stats?.competitions?.schoolName
    || user.user_metadata?.school || null
  const className_ = !statsLoading && stats?.competitions?.className
    || user.user_metadata?.class_name || null

  return (
    <>
      {/* ===== V2 GRADIENT HERO ===== */}
      <section className="profile-hero-v2">
        <div className="container-center">
          <div className="profile-hero-inner">
            {avatarUrl ? (
              <img src={avatarUrl} alt={displayName} className="profile-hero-avatar" />
            ) : (
              <div className="profile-hero-avatar profile-hero-avatar-fallback">
                {displayName.charAt(0).toUpperCase()}
              </div>
            )}
            <div className="profile-hero-info">
              <h1 className="profile-hero-name">{displayName}</h1>
              <p className="profile-hero-email">{user.email}</p>
              <div className="profile-hero-tags">
                {schoolName && <span className="profile-hero-tag">{schoolName}</span>}
                {className_ && <span className="profile-hero-tag">{className_}</span>}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== FLOATING STATS ===== */}
      <section className="profile-stats-v2">
        <div className="container-center">
          <div className="profile-stats-grid">
            <div className="profile-stat-card">
              <div className="profile-stat-icon"><BrainCircuit size={16} /></div>
              <div className="profile-stat-value">{!statsLoading ? (stats?.quiz?.totalQuizzes || 0) : '—'}</div>
              <div className="profile-stat-label">Quizzes</div>
            </div>
            <div className="profile-stat-card">
              <div className="profile-stat-icon"><Target size={16} /></div>
              <div className="profile-stat-value profile-stat-accent">{!statsLoading ? `${stats?.quiz?.quizAccuracy || 0}%` : '—'}</div>
              <div className="profile-stat-label">Precisão</div>
            </div>
            <div className="profile-stat-card">
              <div className="profile-stat-icon"><Flame size={16} /></div>
              <div className="profile-stat-value profile-stat-amber">{!statsLoading ? (stats?.quiz?.bestQuizStreak || 0) : '—'}</div>
              <div className="profile-stat-label">Streak</div>
            </div>
            <div className="profile-stat-card">
              <div className="profile-stat-icon"><BookOpen size={16} /></div>
              <div className="profile-stat-value">{!statsLoading ? (stats?.flashcards?.totalFlashcardsStudied || 0) : '—'}</div>
              <div className="profile-stat-label">Flashcards</div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== MAIN CONTENT ===== */}
      <section className="profile-content-v2">
        <div className="container-center">
          {saveMsg && (
            <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-xl p-3 text-green-600 text-sm text-center mb-4">
              {saveMsg}
            </div>
          )}

          <div className="profile-grid-v2">
            {/* Tools Card */}
            <div className="profile-card-v2 profile-tools-card">
              <div className="profile-card-header">
                <div className="profile-card-dot" /> Ferramentas
              </div>
              <div className="profile-tools-grid">
                {tools.map((tool) => (
                  <Link key={tool.href} href={tool.href} className="profile-tool-card">
                    <div className="profile-tool-icon">{tool.icon}</div>
                    <div className="profile-tool-label">{tool.label}</div>
                  </Link>
                ))}
              </div>
            </div>

            {/* Institution Card */}
            <div className="profile-card-v2 profile-info-card">
              <div className="profile-card-header">
                <div className="profile-card-dot" /> Instituição
              </div>
              <div className="profile-info-list">
                <div className="profile-info-item">
                  <div className="profile-info-icon"><School size={14} /></div>
                  <div>
                    <div className="profile-info-label">Escola</div>
                    <div className="profile-info-value">{schoolName || '—'}</div>
                  </div>
                </div>
                <div className="profile-info-item">
                  <div className="profile-info-icon"><ClipboardList size={14} /></div>
                  <div>
                    <div className="profile-info-label">Turma</div>
                    <div className="profile-info-value">{className_ || '—'}</div>
                  </div>
                </div>
                <div className="profile-info-item">
                  <div className="profile-info-icon"><Mail size={14} /></div>
                  <div>
                    <div className="profile-info-label">Email</div>
                    <div className="profile-info-value">{user.email}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Competition History */}
          {!statsLoading && compHistory.length > 0 && (
            <div className="profile-card-v2" style={{ marginTop: 20 }}>
              <div className="profile-card-header">
                <div className="profile-card-dot" /> Competições Recentes
              </div>
              {compHistory.map((comp) => (
                <div key={comp.id} className="profile-comp-item">
                  <div className={`profile-comp-rank ${comp.position === 1 ? 'gold' : comp.position === 2 ? 'silver' : comp.position === 3 ? 'bronze' : ''}`}>
                    {comp.position}º
                  </div>
                  <div className="profile-comp-info">
                    <div className="profile-comp-name">{comp.competitionName}</div>
                    <div className="profile-comp-meta">vs {comp.opponents.map((o) => o.name).join(', ')} • {new Date(comp.finishedAt).toLocaleDateString('pt-PT', { day: 'numeric', month: 'short' })}</div>
                  </div>
                  <div className="profile-comp-score">
                    <div className="profile-comp-score-value">{comp.myScore}</div>
                    <div className="profile-comp-score-label">pontos</div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Logout */}
          <button
            onClick={handleSignOut}
            disabled={signingOut}
            className="profile-logout-btn"
          >
            {signingOut ? (
              <Loader2 size={16} className="animate-spin" />
            ) : (
              <><LogOut size={16} /> Terminar Sessão</>
            )}
          </button>
        </div>
      </section>
    </>
  )
}
