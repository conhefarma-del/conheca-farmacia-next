'use client'

import { useState, useEffect, useContext } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { LogOut, Mail, Bookmark, Pill, ShieldAlert, ClipboardList, Atom, Newspaper, Loader2, School, Target, BrainCircuit, Flame, Trophy, Edit3, Save, X, ChevronRight } from 'lucide-react'
import { getUserStats, getUserCompetitionHistory } from '@/lib/actions/profile'
import { getSavedItems, getSavedCounts } from '@/lib/actions/saved'
import { LangContext } from '@/lib/contexts'

export default function PerfilClient({ lang }) {
  const { t } = useContext(LangContext)
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
  const [savedItems, setSavedItems] = useState([])
  const [savedCounts, setSavedCounts] = useState(null)
  const [editingSchool, setEditingSchool] = useState(false)
  const [newSchool, setNewSchool] = useState('')
  const [editingClass, setEditingClass] = useState(false)
  const [newClass, setNewClass] = useState('')

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
      setNewSchool(user.user_metadata?.school || '')
      setNewClass(user.user_metadata?.class_name || '')
      setLoading(false)
      // Load stats + saved in parallel (non-blocking)
      Promise.allSettled([
        getUserStats().then(s => setStats(s)),
        getUserCompetitionHistory().then(ch => setCompHistory(ch || [])),
        getSavedItems({ limit: 4 }).then(r => setSavedItems(r.items || [])),
        getSavedCounts().then(c => setSavedCounts(c)),
      ]).finally(() => setStatsLoading(false))
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

  const handleSaveSchool = async () => {
    setSaving(true)
    try {
      const supabase = await createClient()
      const { error } = await supabase.auth.updateUser({
        data: { school: newSchool.trim() },
      })
      if (error) {
        setSaveMsg('Erro ao guardar escola')
      } else {
        setUser((prev) => ({
          ...prev,
          user_metadata: { ...prev.user_metadata, school: newSchool.trim() },
        }))
        setSaveMsg('Escola atualizada!')
      }
    } catch {
      setSaveMsg('Erro ao conectar ao servidor')
    } finally {
      setSaving(false)
    }
  }

  const handleSaveClass = async () => {
    setSaving(true)
    try {
      const supabase = await createClient()
      const { error } = await supabase.auth.updateUser({
        data: { class_name: newClass.trim() },
      })
      if (error) {
        setSaveMsg('Erro ao guardar turma')
      } else {
        setUser((prev) => ({
          ...prev,
          user_metadata: { ...prev.user_metadata, class_name: newClass.trim() },
        }))
        setSaveMsg('Turma atualizada!')
      }
    } catch {
      setSaveMsg('Erro ao conectar ao servidor')
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <>
        {/* Hero skeleton */}
        <section className="profile-hero-v2">
          <div className="container-center">
            <div className="profile-hero-inner">
              <div className="w-22 h-22 rounded-full" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.3, width: 88, height: 88 }} />
              <div className="profile-hero-info">
                <div className="flex items-center gap-2">
                  <div className="h-8 w-48 rounded-lg" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.3 }} />
                </div>
                <div className="h-4 w-40 rounded mt-2" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.2 }} />
                <div className="flex gap-2 mt-3">
                  <div className="h-6 w-36 rounded-md" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.2 }} />
                </div>
              </div>
            </div>
          </div>
        </section>
        {/* Stats skeleton */}
        <section className="profile-stats-v2">
          <div className="container-center">
            <div className="profile-stats-grid">
              {Array.from({ length: 4 }).map((_, i) => (
                <div key={i} className="profile-stat-card">
                  <div className="profile-stat-top">
                    <div className="w-10 h-10 rounded-xl" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.15 }} />
                  </div>
                  <div className="h-9 w-16 mx-auto rounded-lg mb-2" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.2 }} />
                  <div className="h-3 w-20 mx-auto rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.4 }} />
                </div>
              ))}
            </div>
          </div>
        </section>
        {/* Content skeleton */}
        <section className="profile-content-v2">
          <div className="container-center">
            <div className="profile-grid-v2">
              <div className="profile-card-v2">
                <div className="flex items-center gap-2 mb-4">
                  <div className="w-1.5 h-1.5 rounded-full" style={{ background: 'var(--color-brand-accent)', opacity: 0.4 }} />
                  <div className="h-4 w-24 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.6 }} />
                </div>
                <div className="space-y-3">
                  {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className="h-14 rounded-xl" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.1 }} />
                  ))}
                </div>
              </div>
              <div className="profile-card-v2">
                <div className="flex items-center gap-2 mb-4">
                  <div className="w-1.5 h-1.5 rounded-full" style={{ background: 'var(--color-brand-accent)', opacity: 0.4 }} />
                  <div className="h-4 w-24 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.6 }} />
                </div>
                <div className="space-y-0">
                  {Array.from({ length: 3 }).map((_, i) => (
                    <div key={i} className="flex items-center gap-3 py-3" style={{ borderBottom: i < 2 ? '1px solid var(--color-brand-divider)' : 'none' }}>
                      <div className="w-7 h-7 rounded-lg flex-shrink-0" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.12 }} />
                      <div className="flex-1">
                        <div className="h-3 w-12 rounded mb-1.5" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.3 }} />
                        <div className="h-4 w-28 rounded" style={{ background: 'var(--color-brand-divider)', animation: 'pulse 1.5s ease-in-out infinite', opacity: 0.5 }} />
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>
      </>
    )
  }

  if (!user) return null

  const displayName = user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0] || 'Utilizador'
  const avatarUrl = user.user_metadata?.avatar_url
  const createdAt = new Date(user.created_at).toLocaleDateString('pt-PT', { year: 'numeric', month: 'long', day: 'numeric' })

  const savedTypeIcons = {
    drug: Pill,
    interaction: ShieldAlert,
    drug_class: ClipboardList,
    molecular_target: Atom,
    article: Newspaper,
  }

  const savedTypeLinks = {
    drug: (slug) => `/${lang}/medicamentos/${slug}`,
    interaction: (slug) => {
      if (slug && slug.includes('+')) {
        const [a, b] = slug.split('+')
        return `/${lang}/interacoes?farmaco=${a}&par=${b}`
      }
      return `/${lang}/interacoes`
    },
    drug_class: (slug) => `/${lang}/classes/${slug}`,
    molecular_target: (slug) => `/${lang}/alvos/${slug}`,
    article: (slug) => `/${lang}/artigos/${slug}`,
  }

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
              {editingName ? (
                <div className="profile-hero-edit-row">
                  <input
                    type="text"
                    value={newName}
                    onChange={(e) => setNewName(e.target.value)}
                    className="profile-hero-edit-input"
                    autoFocus
                    onKeyDown={(e) => {
                      if (e.key === 'Enter') handleSaveName()
                      if (e.key === 'Escape') { setEditingName(false); setNewName(user.user_metadata?.full_name || '') }
                    }}
                  />
                  <button onClick={handleSaveName} disabled={saving} className="profile-hero-edit-btn profile-hero-edit-save">
                    <Save size={14} />
                  </button>
                  <button onClick={() => { setEditingName(false); setNewName(user.user_metadata?.full_name || '') }} className="profile-hero-edit-btn profile-hero-edit-cancel">
                    <X size={14} />
                  </button>
                </div>
              ) : (
                <div className="profile-hero-name-row">
                  <h1 className="profile-hero-name">{displayName}</h1>
                  <button onClick={() => setEditingName(true)} className="profile-hero-edit-trigger" title="Editar nome">
                    <Edit3 size={14} />
                  </button>
                </div>
              )}
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
              <div className="profile-stat-top">
                <div className="profile-stat-icon"><BrainCircuit size={18} /></div>
              </div>
              <div className="profile-stat-value">{!statsLoading ? (stats?.quiz?.totalQuizzes || 0) : '—'}</div>
              <div className="profile-stat-label">Quizzes realizados</div>
            </div>
            <div className="profile-stat-card">
              <div className="profile-stat-top">
                <div className="profile-stat-icon"><Target size={18} /></div>
              </div>
              <div className="profile-stat-value profile-stat-accent">{!statsLoading ? `${stats?.quiz?.quizAccuracy || 0}%` : '—'}</div>
              <div className="profile-stat-label">Precisão média</div>
            </div>
            <div className="profile-stat-card">
              <div className="profile-stat-top">
                <div className="profile-stat-icon"><Flame size={18} /></div>
              </div>
              <div className="profile-stat-value profile-stat-amber">{!statsLoading ? (stats?.quiz?.bestQuizStreak || 0) : '—'}</div>
              <div className="profile-stat-label">Melhor streak</div>
            </div>
            <div className="profile-stat-card">
              <div className="profile-stat-top">
                <div className="profile-stat-icon"><Trophy size={18} /></div>
              </div>
              <div className="profile-stat-value">{!statsLoading ? (stats?.competitions?.totalSessions || 0) : '—'}</div>
              <div className="profile-stat-label">Desafios ganhos</div>
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
            {/* Saved Items Card */}
            <div className="profile-card-v2 profile-saved-card">
              <div className="profile-card-header">
                <div className="profile-card-dot" /> {t('saved.title')}
                {savedCounts && savedCounts.total > 0 && (
                  <span className="profile-saved-count">{savedCounts.total}</span>
                )}
              </div>
              {savedItems.length > 0 ? (
                <>
                  <div className="profile-saved-list">
                    {savedItems.map((item) => {
                      const TypeIcon = savedTypeIcons[item.item_type] || Bookmark
                      const href = savedTypeLinks[item.item_type]?.(item.item_slug) || '#'
                      return (
                        <Link key={item.id} href={href} className="profile-saved-item">
                          <div className="profile-saved-item-icon">
                            <TypeIcon size={16} />
                          </div>
                          <div className="profile-saved-item-info">
                            <div className="profile-saved-item-name">{item.item_name}</div>
                            {item.item_subtitle && (
                              <div className="profile-saved-item-subtitle">{item.item_subtitle}</div>
                            )}
                          </div>
                        </Link>
                      )
                    })}
                  </div>
                  <Link href={`/${lang}/guardados`} className="profile-saved-viewall">
                    {t('saved.view_all')}
                    <ChevronRight size={14} />
                  </Link>
                </>
              ) : (
                <div className="profile-saved-empty">
                  <Bookmark size={24} className="opacity-20 mb-2" />
                  <p className="text-sm opacity-50">{t('saved.empty')}</p>
                </div>
              )}
            </div>

            {/* Institution Card */}
            <div className="profile-card-v2 profile-info-card">
              <div className="profile-card-header">
                <div className="profile-card-dot" /> Instituição
              </div>
              <div className="profile-info-list">
                {/* School */}
                <div className="profile-info-item">
                  <div className="profile-info-icon"><School size={14} /></div>
                  <div className="flex-1 min-w-0">
                    <div className="profile-info-label">Escola</div>
                    {editingSchool ? (
                      <div className="flex items-center gap-1.5 mt-1">
                        <input
                          type="text"
                          value={newSchool}
                          onChange={(e) => setNewSchool(e.target.value)}
                          className="profile-info-edit-input"
                          autoFocus
                          onKeyDown={(e) => {
                            if (e.key === 'Enter') { handleSaveSchool(); setEditingSchool(false) }
                            if (e.key === 'Escape') { setEditingSchool(false); setNewSchool(schoolName || '') }
                          }}
                        />
                        <button onClick={() => { handleSaveSchool(); setEditingSchool(false) }} className="profile-info-edit-btn save"><Save size={12} /></button>
                        <button onClick={() => { setEditingSchool(false); setNewSchool(schoolName || '') }} className="profile-info-edit-btn cancel"><X size={12} /></button>
                      </div>
                    ) : (
                      <div className="flex items-center gap-1.5">
                        <div className="profile-info-value">{schoolName || '—'}</div>
                        <button onClick={() => setEditingSchool(true)} className="profile-info-edit-trigger"><Edit3 size={12} /></button>
                      </div>
                    )}
                  </div>
                </div>
                {/* Class */}
                <div className="profile-info-item">
                  <div className="profile-info-icon"><ClipboardList size={14} /></div>
                  <div className="flex-1 min-w-0">
                    <div className="profile-info-label">Turma</div>
                    {editingClass ? (
                      <div className="flex items-center gap-1.5 mt-1">
                        <input
                          type="text"
                          value={newClass}
                          onChange={(e) => setNewClass(e.target.value)}
                          className="profile-info-edit-input"
                          autoFocus
                          onKeyDown={(e) => {
                            if (e.key === 'Enter') { handleSaveClass(); setEditingClass(false) }
                            if (e.key === 'Escape') { setEditingClass(false); setNewClass(className_ || '') }
                          }}
                        />
                        <button onClick={() => { handleSaveClass(); setEditingClass(false) }} className="profile-info-edit-btn save"><Save size={12} /></button>
                        <button onClick={() => { setEditingClass(false); setNewClass(className_ || '') }} className="profile-info-edit-btn cancel"><X size={12} /></button>
                      </div>
                    ) : (
                      <div className="flex items-center gap-1.5">
                        <div className="profile-info-value">{className_ || '—'}</div>
                        <button onClick={() => setEditingClass(true)} className="profile-info-edit-trigger"><Edit3 size={12} /></button>
                      </div>
                    )}
                  </div>
                </div>
                {/* Email (read-only) */}
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
