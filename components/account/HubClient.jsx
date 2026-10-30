'use client'

import { useContext, useEffect, useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { LOCATOR_ORIGIN, SITE_ORIGIN } from '@/lib/account-urls'
import { useTheme } from '@/components/providers/ThemeProvider'
import { LangContext } from '@/lib/contexts'
import {
  Bookmark,
  CalendarDays,
  Camera,
  Check,
  GraduationCap,
  Loader2,
  NotebookPen,
  Pencil,
  Pill,
  X,
} from 'lucide-react'

/**
 * Visão geral da conta (conta.conhecafarmacia.com/perfil).
 *
 * É a casa comum das duas operações: identidade em cima, guardados e o
 * resumo da conta em baixo. As listas completas vivem no Localizador — aqui
 * fica o que a pessoa guardou, com o resto a um clique.
 *
 * O nome e a foto vivem em `auth.users.raw_user_meta_data` (`full_name`,
 * `display_name`, `avatar_url`) — o mesmo sítio que o site já usa. Não há
 * tabela `profiles`, e não é aqui que ela nasce.
 *
 * O conteúdo usa o chassi `.conta-*` partilhado com o site e o Localizador:
 * painéis hairline, listas em linhas e raio de 12px. O antigo `max-w-3xl`
 * centrado com cartões de 16px saiu com a unificação.
 */

const SITE_LINKS = [
  {
    path: '/guardados',
    titleKey: 'account.overview.siteSaved',
    descriptionKey: 'account.overview.siteSavedSub',
    icon: Bookmark,
  },
  {
    path: '/anotacoes',
    titleKey: 'account.overview.siteNotes',
    descriptionKey: 'account.overview.siteNotesSub',
    icon: NotebookPen,
  },
  {
    path: '/perfil',
    titleKey: 'account.overview.siteStudent',
    descriptionKey: 'account.overview.siteStudentSub',
    icon: GraduationCap,
  },
]

const fmtDia = (value, locale) =>
  value
    ? new Date(`${value}T00:00:00`).toLocaleDateString(locale, {
        day: '2-digit',
        month: 'long',
      })
    : ''

export default function HubClient({
  profile,
  saved = [],
  savedTotal = 0,
  proximoEvento = null,
  inscricoesTotal = 0,
  preferencias = {},
}) {
  const { t, lang } = useContext(LangContext)
  const locale = lang === 'en' ? 'en-GB' : 'pt-PT'
  const [name, setName] = useState(profile.name)
  const [avatarUrl, setAvatarUrl] = useState(profile.avatarUrl)
  const [editing, setEditing] = useState(false)
  const [draft, setDraft] = useState(profile.name)
  const [saving, setSaving] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [feedback, setFeedback] = useState({ tone: '', text: '' })
  const { setMode } = useTheme()

  // Aparelho novo (sem cookie partilhada): a aparência guardada na conta é a
  // que manda. Com cookie já existe uma escolha local — e é essa que fica.
  useEffect(() => {
    if (!preferencias.theme) return
    const hasLocalChoice = document.cookie
      .split('; ')
      .some((cookie) => cookie.startsWith('cf-theme='))
    if (!hasLocalChoice) setMode(preferencias.theme)
  }, [preferencias.theme, setMode])

  const displayName = name || profile.email.split('@')[0] || t('account.kicker')
  const initial = displayName.charAt(0).toUpperCase()
  const avatar = avatarUrl || null

  async function handleSaveName() {
    const value = draft.trim()
    if (!value) return
    setSaving(true)
    setFeedback({ tone: '', text: '' })
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({
        data: { full_name: value, display_name: value },
      })
      if (error) {
        setFeedback({ tone: 'bad', text: t('account.overview.nameFailed') })
      } else {
        setName(value)
        setEditing(false)
        setFeedback({ tone: 'ok', text: t('account.overview.nameSaved') })
      }
    } catch {
      setFeedback({ tone: 'bad', text: t('account.overview.nameFailed') })
    } finally {
      setSaving(false)
    }
  }

  async function handleAvatarUpload(event) {
    const file = event.target.files?.[0]
    if (!file) return
    if (file.size > 2 * 1024 * 1024) {
      setFeedback({ tone: 'bad', text: t('account.overview.photoTooBig') })
      return
    }

    setUploading(true)
    setFeedback({ tone: '', text: '' })
    try {
      const supabase = createClient()
      const extension = (file.name.split('.').pop() || 'jpg').toLowerCase()
      const path = `${profile.id}/avatar.${extension}`
      const { error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(path, file, { upsert: true, contentType: file.type })
      if (uploadError) throw uploadError

      const { data } = supabase.storage.from('avatars').getPublicUrl(path)
      const publicUrl = `${data.publicUrl}?t=${Date.now()}`
      const { error: updateError } = await supabase.auth.updateUser({
        // `avatar_url_upload` guarda a escolha da pessoa; `avatar_url` sozinho
        // é reescrito pela foto da conta Google no login seguinte.
        data: { avatar_url: publicUrl, avatar_url_upload: publicUrl },
      })
      if (updateError) throw updateError

      setAvatarUrl(publicUrl)
      setFeedback({ tone: 'ok', text: t('account.overview.photoSaved') })
    } catch {
      setFeedback({ tone: 'bad', text: t('account.overview.photoFailed') })
    } finally {
      setUploading(false)
    }
  }

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">{t('account.kicker')}</p>
          <h1 className="conta-title">{displayName}</h1>
          <p className="conta-sub">{t('account.overview.sub')}</p>
        </div>
        <div className="conta-head-acts">
          <Link href="/perfil/seguranca" className="conta-btn conta-btn--ghost conta-btn--sm">
            {t('account.overview.securityCta')}
          </Link>
        </div>
      </header>

      {feedback.text && (
        <p
          className={`conta-alert${feedback.tone === 'ok' ? ' conta-alert--ok' : ' conta-alert--bad'}`}
          role="status"
        >
          {feedback.text}
        </p>
      )}

      <section className="conta-panel">
        <div className="conta-identity">
          <div className="conta-avatar">
            {avatar ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={avatar} alt={displayName} />
            ) : (
              initial
            )}
            <label
              className="conta-avatar-edit"
              title={t('account.overview.changePhoto')}
              aria-label={t('account.overview.changePhoto')}
            >
              {uploading ? <Loader2 size={18} className="animate-spin" /> : <Camera size={18} />}
              <input
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleAvatarUpload}
                disabled={uploading}
              />
            </label>
          </div>

          <div className="conta-identity-main">
            {editing ? (
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={draft}
                  onChange={(event) => setDraft(event.target.value)}
                  className="conta-field"
                  style={{ maxWidth: '22rem' }}
                  autoFocus
                  onKeyDown={(event) => {
                    if (event.key === 'Enter') handleSaveName()
                    if (event.key === 'Escape') {
                      setEditing(false)
                      setDraft(name)
                    }
                  }}
                />
                <button
                  type="button"
                  onClick={handleSaveName}
                  disabled={saving}
                  className="conta-btn conta-btn--primary conta-btn--sm"
                  aria-label={t('account.overview.saveName')}
                >
                  {saving ? <Loader2 size={14} className="animate-spin" /> : <Check size={14} />}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setEditing(false)
                    setDraft(name)
                  }}
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  aria-label={t('account.common.cancel')}
                >
                  <X size={14} />
                </button>
              </div>
            ) : (
              <h2 className="conta-identity-name">
                {displayName}
                <button
                  type="button"
                  onClick={() => {
                    setDraft(name)
                    setEditing(true)
                  }}
                  className="conta-btn conta-btn--ghost conta-btn--sm"
                  aria-label={t('account.overview.editName')}
                  title={t('account.overview.editName')}
                >
                  <Pencil size={13} />
                </button>
              </h2>
            )}

            <p className="conta-identity-sub">{profile.email}</p>
            <div className="conta-identity-tags">
              <span className="conta-tag">{profile.membroDesde}</span>
              <span className={`conta-tag${profile.verified ? ' conta-tag--ok' : ''}`}>
                {profile.verified
                  ? t('account.overview.emailVerified')
                  : t('account.overview.emailPending')}
              </span>
            </div>
          </div>
        </div>
      </section>

      <div className="conta-grid2">
        <section className="conta-panel" aria-labelledby="conta-guardados">
          <div className="conta-panel-head">
            <h2 id="conta-guardados" className="conta-panel-title">
              <Pill size={14} />
              {t('account.overview.savedTitle')}
              {savedTotal > 0 && <span className="conta-panel-count">{savedTotal}</span>}
            </h2>
            <a
              href={`${LOCATOR_ORIGIN}/guardados`}
              className="conta-btn conta-btn--ghost conta-btn--sm"
            >
              {t('account.common.seeAll')}
            </a>
          </div>

          {saved.length === 0 ? (
            <div className="conta-empty">
              <p className="conta-empty-title">{t('account.overview.savedEmptyTitle')}</p>
              <p className="conta-empty-sub">{t('account.overview.savedEmptySub')}</p>
            </div>
          ) : (
            <ul className="conta-rows">
              {saved.map((item) => (
                <li key={item.key} className="conta-row">
                  <div className="conta-row-main">
                    <span className="conta-row-title">{item.name}</span>
                    {item.meta && <span className="conta-row-meta">{item.meta}</span>}
                  </div>
                  <div className="conta-row-acts">
                    {item.siteHref && (
                      <a
                        href={item.siteHref}
                        className="conta-btn conta-btn--ghost conta-btn--sm"
                      >
                        {t('account.overview.viewOnSite')}
                      </a>
                    )}
                    <a
                      href={item.locatorHref}
                      className="conta-btn conta-btn--primary conta-btn--sm"
                    >
                      {item.cta}
                    </a>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>

        <div>
          <section className="conta-panel" aria-labelledby="conta-eventos">
            <div className="conta-panel-head">
              <h2 id="conta-eventos" className="conta-panel-title">
                <CalendarDays size={14} aria-hidden="true" />
                {t('account.overview.eventsTitle')}
                {inscricoesTotal > 0 && (
                  <span className="conta-panel-count">{inscricoesTotal}</span>
                )}
              </h2>
              <Link
                href="/perfil/eventos"
                className="conta-btn conta-btn--ghost conta-btn--sm"
              >
                {t('account.overview.viewEvents')}
              </Link>
            </div>

            {proximoEvento ? (
              <ul className="conta-rows">
                <li className="conta-row">
                  <div className="conta-row-main">
                    <span className="conta-row-kicker">
                      {t('account.overview.next')} · {fmtDia(proximoEvento.date, locale)}
                      {proximoEvento.time ? ` · ${proximoEvento.time}` : ''}
                    </span>
                    <a
                      className="conta-row-title"
                      href={`${SITE_ORIGIN}/${lang}/eventos/${proximoEvento.slug}`}
                    >
                      {proximoEvento.title}
                    </a>
                    <span className="conta-row-meta">
                      {[
                        proximoEvento.location || proximoEvento.platform,
                        t('account.overview.confirmed'),
                      ]
                        .filter(Boolean)
                        .join(' · ')}
                    </span>
                  </div>
                </li>
              </ul>
            ) : (
              <div className="conta-empty">
                <p className="conta-empty-title">{t('account.overview.eventsEmptyTitle')}</p>
                <p className="conta-empty-sub">{t('account.overview.eventsEmptySub')}</p>
              </div>
            )}
          </section>

          <section className="conta-panel" aria-labelledby="conta-gerir">
            <div className="conta-panel-head">
              <h2 id="conta-gerir" className="conta-panel-title">
                {t('account.overview.manageTitle')}
              </h2>
            </div>
            <ul className="conta-rows">
              <li className="conta-row">
                <div className="conta-row-main">
                  <Link className="conta-row-title" href="/perfil/preferencias">
                    {t('account.overview.preferences')}
                  </Link>
                  <span className="conta-row-meta">{t('account.overview.preferencesSub')}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <Link className="conta-row-title" href="/perfil/privacidade">
                    {t('account.overview.privacy')}
                  </Link>
                  <span className="conta-row-meta">{t('account.overview.privacySub')}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <Link className="conta-row-title" href="/perfil/atividade">
                    {t('account.overview.activity')}
                  </Link>
                  <span className="conta-row-meta">{t('account.overview.activitySub')}</span>
                </div>
              </li>
            </ul>
          </section>

          <section className="conta-panel" aria-labelledby="conta-dados">
            <div className="conta-panel-head">
              <h2 id="conta-dados" className="conta-panel-title">
                {t('account.overview.accountTitle')}
              </h2>
            </div>
            <ul className="conta-rows">
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">{t('account.overview.email')}</span>
                  <span className="conta-row-title">{profile.email}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">{t('account.overview.status')}</span>
                  <span className="conta-row-title">
                    {profile.verified
                      ? t('account.overview.verified')
                      : t('account.overview.pending')}
                  </span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">{t('account.overview.memberSince')}</span>
                  <span className="conta-row-title">{profile.membroDesde}</span>
                </div>
              </li>
            </ul>
          </section>

          <section className="conta-panel" aria-labelledby="conta-site">
            <div className="conta-panel-head">
              <h2 id="conta-site" className="conta-panel-title">
                {t('account.overview.onSite')}
              </h2>
            </div>
            <ul className="conta-rows">
              {SITE_LINKS.map(({ path, titleKey, descriptionKey, icon: Icon }) => {
                const href = `${SITE_ORIGIN}/${lang}${path}`
                return (
                  <li key={path} className="conta-row">
                    <div className="conta-row-main">
                      <a className="conta-row-title" href={href}>
                        {t(titleKey)}
                      </a>
                      <span className="conta-row-meta">{t(descriptionKey)}</span>
                    </div>
                    <div className="conta-row-acts">
                      <a href={href} className="conta-btn conta-btn--ghost conta-btn--sm">
                        <Icon size={13} />
                        {t('account.common.open')}
                      </a>
                    </div>
                  </li>
                )
              })}
            </ul>
          </section>
        </div>
      </div>
    </main>
  )
}
