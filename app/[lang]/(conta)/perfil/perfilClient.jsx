'use client'

import { useState, useEffect, useContext } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import {
  Atom,
  Bookmark,
  BrainCircuit,
  Camera,
  ChevronRight,
  ClipboardList,
  Edit3,
  Flame,
  Loader2,
  Mail,
  Newspaper,
  Pill,
  Save,
  School,
  ShieldAlert,
  StickyNote,
  Target,
  Trophy,
  X,
} from 'lucide-react'
import { getUserStats, getUserCompetitionHistory } from '@/lib/actions/profile'
import { getSavedItems, getSavedCounts, getNotesCount } from '@/lib/actions/saved'
import { featureEnabled } from '@/lib/features'
import { LangContext } from '@/lib/contexts'

export default function PerfilClient({ lang }) {
  const { t } = useContext(LangContext)
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  const [editingName, setEditingName] = useState(false)
  const [newName, setNewName] = useState('')
  const [saving, setSaving] = useState(false)
  const [saveMsg, setSaveMsg] = useState('')
  const [uploadingAvatar, setUploadingAvatar] = useState(false)
  const [stats, setStats] = useState(null)
  const [statsLoading, setStatsLoading] = useState(true)
  const [compHistory, setCompHistory] = useState([])
  const [savedItems, setSavedItems] = useState([])
  const [savedCounts, setSavedCounts] = useState(null)
  const [savedLoading, setSavedLoading] = useState(true)
  const [notesCounts, setNotesCounts] = useState(null)
  const [notesLoading, setNotesLoading] = useState(true)

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

      // Load stats + saved in parallel (non-blocking)
      Promise.allSettled([
        getUserStats().then((s) => setStats(s)),
        getUserCompetitionHistory().then((ch) => setCompHistory(ch || [])),
        getSavedItems({ limit: 4 }).then((r) => setSavedItems(r.items || [])),
        getSavedCounts().then((c) => setSavedCounts(c)).finally(() => setSavedLoading(false)),
        getNotesCount().then((c) => setNotesCounts(c)).finally(() => setNotesLoading(false)),
      ]).finally(() => setStatsLoading(false))
    }
    loadUser()
  }, [lang])

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
        setSaveMsg(`${t('student_profile.nameError')} ${error.message}`)
      } else {
        setUser((prev) => ({
          ...prev,
          user_metadata: { ...prev.user_metadata, full_name: newName.trim(), display_name: newName.trim() },
        }))
        setEditingName(false)
        setSaveMsg(t('student_profile.nameSaved'))
      }
    } catch {
      setSaveMsg(t('student_profile.connectionError'))
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <main className="conta-page">
        <div className="conta-panel" style={{ height: 108, opacity: 0.35 }} />
        <div className="conta-panel" style={{ height: 96, marginTop: '1rem', opacity: 0.25 }} />
        <div className="conta-panel" style={{ height: 220, marginTop: '1rem', opacity: 0.18 }} />
      </main>
    )
  }

  if (!user) return null

  const displayName =
    user.user_metadata?.full_name ||
    user.user_metadata?.display_name ||
    user.email?.split('@')[0] ||
    t('student_profile.user')
  // A foto carregada vive em `avatar_url_upload`: o login com Google
  // reescreve `avatar_url` com a foto da conta Google, por isso essa chave
  // não serve para guardar a escolha da pessoa.
  const avatarUrl = user.user_metadata?.avatar_url_upload || user.user_metadata?.avatar_url
  const displayAvatar = avatarUrl || null
  const initials = (() => {
    const parts = String(displayName).trim().split(/\s+/).filter(Boolean)
    if (parts.length === 0) return 'U'
    return (parts[0][0] + (parts[1]?.[0] || '')).toUpperCase()
  })()

  const handleAvatarUpload = async (e) => {
    const file = e.target.files?.[0]
    if (!file) return
    if (file.size > 2 * 1024 * 1024) {
      setSaveMsg(t('student_profile.photoTooBig'))
      return
    }
    setUploadingAvatar(true)
    try {
      const supabase = createClient()
      const fileExt = file.name.split('.').pop()
      const filePath = `${user.id}/avatar.${fileExt}`
      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(filePath, file, { upsert: true })
      if (uploadError) throw uploadError
      const { data: urlData } = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath)
      const publicUrl = urlData.publicUrl + '?t=' + Date.now()
      const { error: updateError } = await supabase.auth.updateUser({
        // `avatar_url_upload` é a chave que sobrevive ao login com Google;
        // `avatar_url` fica também para quem lê só a chave genérica.
        data: { avatar_url: publicUrl, avatar_url_upload: publicUrl },
      })
      if (updateError) throw updateError
      setUser((prev) => ({
        ...prev,
        user_metadata: {
          ...prev.user_metadata,
          avatar_url: publicUrl,
          avatar_url_upload: publicUrl,
        },
      }))
      setSaveMsg(t('student_profile.photoSaved'))
    } catch (err) {
      setSaveMsg(`${t('student_profile.photoError')} ${err.message || ''}`.trim())
    } finally {
      setUploadingAvatar(false)
    }
  }
  const createdAt = new Date(user.created_at).toLocaleDateString(
    lang === 'en' ? 'en-GB' : 'pt-PT',
    {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

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

  const schoolName = (!statsLoading && stats?.competitions?.schoolName) || user.user_metadata?.school || null
  const className_ = (!statsLoading && stats?.competitions?.className) || user.user_metadata?.class_name || null
  const mostraCompeticao = featureEnabled('competicao')
  const notas = notesCounts
    ? Object.entries(notesCounts).filter(([key, val]) => key !== 'total' && val > 0)
    : []

  return (
    <main className="conta-page conta-profile">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">{t('student_profile.kicker')}</p>
          <h1 className="conta-title">{displayName}</h1>
          <p className="conta-sub">{t('student_profile.sub')}</p>
        </div>
        <div className="conta-head-acts">
          <Link href={`/${lang}/perfil/definicoes`} className="conta-btn conta-btn--ghost conta-btn--sm">
            {t('student_profile.settings')}
          </Link>
        </div>
      </header>

      {saveMsg && (
        <p className="conta-alert" role="status">
          {saveMsg}
        </p>
      )}

      <section className="conta-panel">
        <div className="conta-identity">
          <div className="conta-avatar">
            {displayAvatar ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={displayAvatar} alt={displayName} />
            ) : (
              initials
            )}
            <label
              className="conta-avatar-edit"
              title={t('student_profile.changePhoto')}
              aria-label={t('student_profile.changePhoto')}
            >
              {uploadingAvatar ? <Loader2 size={18} className="animate-spin" /> : <Camera size={18} />}
              <input
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleAvatarUpload}
                disabled={uploadingAvatar}
              />
            </label>
          </div>

          <div className="conta-identity-main">
            {editingName ? (
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={newName}
                  onChange={(e) => setNewName(e.target.value)}
                  className="conta-field"
                  style={{ maxWidth: '22rem' }}
                  autoFocus
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') handleSaveName()
                    if (e.key === 'Escape') {
                      setEditingName(false)
                      setNewName(user.user_metadata?.full_name || '')
                    }
                  }}
                />
                <button
                  onClick={handleSaveName}
                  disabled={saving}
                  className="conta-btn conta-btn--primary conta-btn--sm"
                  aria-label={t('student_profile.saveName')}
                >
                  <Save size={14} />
                </button>
                <button
                  onClick={() => {
                    setEditingName(false)
                    setNewName(user.user_metadata?.full_name || '')
                  }}
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  aria-label={t('student_profile.cancel')}
                >
                  <X size={14} />
                </button>
              </div>
            ) : (
              <h2 className="conta-identity-name">
                {displayName}
                <button
                  onClick={() => setEditingName(true)}
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  aria-label={t('student_profile.editName')}
                  title={t('student_profile.editName')}
                >
                  <Edit3 size={13} />
                </button>
              </h2>
            )}

            <p className="conta-identity-sub">{user.email}</p>
            <div className="conta-identity-tags">
              <span className="conta-tag">
                {t('student_profile.memberSince', { date: createdAt })}
              </span>
              {schoolName && <span className="conta-tag">{schoolName}</span>}
              {className_ && <span className="conta-tag">{className_}</span>}
            </div>
          </div>
        </div>
      </section>

      <div className={`conta-stats conta-stats--${mostraCompeticao ? 4 : 3}`}>
        <div className="conta-stat">
          <span className="conta-stat-label">{t('student_profile.stats.quizzes')}</span>
          <span className="conta-stat-value">
            {!statsLoading ? stats?.quiz?.totalQuizzes || 0 : '—'}
          </span>
        </div>
        <div className="conta-stat">
          <span className="conta-stat-label">{t('student_profile.stats.accuracy')}</span>
          <span className="conta-stat-value conta-stat-value--accent">
            {!statsLoading ? `${stats?.quiz?.quizAccuracy || 0}%` : '—'}
          </span>
        </div>
        <div className="conta-stat">
          <span className="conta-stat-label">{t('student_profile.stats.streak')}</span>
          <span className="conta-stat-value">
            {!statsLoading ? stats?.quiz?.bestQuizStreak || 0 : '—'}
          </span>
        </div>
        {mostraCompeticao && (
          <div className="conta-stat">
            <span className="conta-stat-label">{t('student_profile.stats.challenges')}</span>
            <span className="conta-stat-value">
              {!statsLoading ? stats?.competitions?.totalSessions || 0 : '—'}
            </span>
          </div>
        )}
      </div>

      <div className="conta-grid2 conta-profile-grid">
        <section className="conta-panel" aria-labelledby="perfil-guardados">
          <div className="conta-panel-head">
            <h2 id="perfil-guardados" className="conta-panel-title">
              <Bookmark size={14} />
              {t('saved.title')}
              {savedCounts && savedCounts.total > 0 && (
                <span className="conta-panel-count">{savedCounts.total}</span>
              )}
            </h2>
            <Link href={`/${lang}/guardados`} className="conta-btn conta-btn--ghost conta-btn--sm">
              {t('saved.view_all')}
              <ChevronRight size={13} />
            </Link>
          </div>

          {savedLoading ? (
            <p className="conta-panel-note">{t('student_profile.loading')}</p>
          ) : savedItems.length > 0 ? (
            <ul className="conta-rows">
              {savedItems.map((item) => {
                const TypeIcon = savedTypeIcons[item.item_type] || Bookmark
                const href = savedTypeLinks[item.item_type]?.(item.item_slug) || '#'
                return (
                  <li key={item.id} className="conta-row">
                    <div className="conta-row-main">
                      <span className="conta-row-kicker">
                        <TypeIcon size={12} style={{ marginRight: 4 }} />
                        {item.item_type}
                      </span>
                      <Link href={href} className="conta-row-title">
                        {item.item_name}
                      </Link>
                      {item.item_subtitle && (
                        <span className="conta-row-meta">{item.item_subtitle}</span>
                      )}
                    </div>
                    <div className="conta-row-acts">
                      <Link href={href} className="conta-btn conta-btn--ghost conta-btn--sm">
                        {t('student_profile.open')}
                      </Link>
                    </div>
                  </li>
                )
              })}
            </ul>
          ) : (
            <div className="conta-empty">
              <Bookmark size={22} style={{ opacity: 0.25, margin: '0 auto 0.4rem' }} />
              <p className="conta-empty-sub">{t('saved.empty')}</p>
            </div>
          )}
        </section>

        <div className="conta-profile-stack">
          <section className="conta-panel" aria-labelledby="perfil-notas">
            <div className="conta-panel-head">
              <h2 id="perfil-notas" className="conta-panel-title">
                <StickyNote size={14} />
                {t('notes_page.title')}
                {notesCounts?.total > 0 && (
                  <span className="conta-panel-count">{notesCounts.total}</span>
                )}
              </h2>
            </div>

            {notesLoading ? (
              <p className="conta-panel-note">{t('student_profile.loading')}</p>
            ) : notas.length > 0 ? (
              <ul className="conta-rows">
                {notas.map(([key, count]) => (
                  <li key={key} className="conta-row">
                    <div className="conta-row-main">
                      <span className="conta-row-title">
                        {key === 'standalone' ? t('student_profile.standalone') : key}
                      </span>
                      <span className="conta-row-meta">
                        {t(count === 1 ? 'student_profile.notesOne' : 'student_profile.notesMany', {
                          n: count,
                        })}
                      </span>
                    </div>
                    <div className="conta-row-acts">
                      <Link
                        href={`/${lang}/anotacoes`}
                        className="conta-btn conta-btn--ghost conta-btn--sm"
                      >
                        {t('student_profile.open')}
                      </Link>
                    </div>
                  </li>
                ))}
              </ul>
            ) : (
              <div className="conta-empty">
                <StickyNote size={22} style={{ opacity: 0.25, margin: '0 auto 0.4rem' }} />
                <p className="conta-empty-sub">{t('student_profile.notesEmpty')}</p>
              </div>
            )}
          </section>

          <section className="conta-panel" aria-labelledby="perfil-instituicao">
            <div className="conta-panel-head">
              <h2 id="perfil-instituicao" className="conta-panel-title">
                <School size={14} />
                {t('student_profile.institution')}
              </h2>
            </div>
            <ul className="conta-rows">
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">{t('student_profile.school')}</span>
                  <span className="conta-row-title">{schoolName || '—'}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">{t('student_profile.class')}</span>
                  <span className="conta-row-title">{className_ || '—'}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">
                    <Mail size={12} style={{ marginRight: 4 }} />
                    {t('student_profile.email')}
                  </span>
                  <span className="conta-row-title">{user.email}</span>
                </div>
              </li>
            </ul>
          </section>
        </div>
      </div>

      {mostraCompeticao && !statsLoading && compHistory.length > 0 && (
        <section className="conta-panel" aria-labelledby="perfil-competicoes">
          <div className="conta-panel-head">
            <h2 id="perfil-competicoes" className="conta-panel-title">
              <Trophy size={14} />
              {t('student_profile.competitions')}
            </h2>
            <span className="conta-panel-count">{compHistory.length}</span>
          </div>
          <ul className="conta-rows">
            {compHistory.map((comp) => (
              <li key={comp.id} className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-title">{comp.competitionName}</span>
                  <span className="conta-row-meta">
                    {comp.correctCount}/{comp.totalAnswered} {t('student_profile.correct')} ·{' '}
                    {comp.accuracy}% ·{' '}
                    {new Date(comp.createdAt).toLocaleDateString(
                      lang === 'en' ? 'en-GB' : 'pt-PT',
                      { day: 'numeric', month: 'short' },
                    )}
                  </span>
                </div>
                <div className="conta-row-acts">
                  <span className="conta-row-title">{comp.totalScore}</span>
                  <span className="conta-row-meta">{t('student_profile.points')}</span>
                </div>
              </li>
            ))}
          </ul>
        </section>
      )}
    </main>
  )
}
