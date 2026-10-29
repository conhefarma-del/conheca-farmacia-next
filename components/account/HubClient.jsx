'use client'

import { useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { LOCATOR_ORIGIN, SITE_ORIGIN } from '@/lib/account-urls'
import {
  Bookmark,
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
    href: `${SITE_ORIGIN}/pt/guardados`,
    title: 'Conteúdos guardados',
    description: 'Artigos, medicamentos e classes do site',
    icon: Bookmark,
  },
  {
    href: `${SITE_ORIGIN}/pt/anotacoes`,
    title: 'Anotações',
    description: 'Notas dos conteúdos que guardou',
    icon: NotebookPen,
  },
  {
    href: `${SITE_ORIGIN}/pt/perfil`,
    title: 'Perfil de estudante',
    description: 'Quizzes, competições e turma',
    icon: GraduationCap,
  },
]

export default function HubClient({ profile, saved = [], savedTotal = 0 }) {
  const [name, setName] = useState(profile.name)
  const [avatarUrl, setAvatarUrl] = useState(profile.avatarUrl)
  const [editing, setEditing] = useState(false)
  const [draft, setDraft] = useState(profile.name)
  const [saving, setSaving] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [message, setMessage] = useState('')

  const displayName = name || profile.email.split('@')[0] || 'Utilizador'
  const initial = displayName.charAt(0).toUpperCase()
  const avatar = avatarUrl || null

  async function handleSaveName() {
    const value = draft.trim()
    if (!value) return
    setSaving(true)
    setMessage('')
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({
        data: { full_name: value, display_name: value },
      })
      if (error) {
        setMessage('Não foi possível guardar o nome. Tente novamente.')
      } else {
        setName(value)
        setEditing(false)
        setMessage('Nome atualizado.')
      }
    } catch {
      setMessage('Não foi possível guardar o nome. Tente novamente.')
    } finally {
      setSaving(false)
    }
  }

  async function handleAvatarUpload(event) {
    const file = event.target.files?.[0]
    if (!file) return
    if (file.size > 2 * 1024 * 1024) {
      setMessage('A imagem deve ter menos de 2 MB.')
      return
    }

    setUploading(true)
    setMessage('')
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
        data: { avatar_url: publicUrl },
      })
      if (updateError) throw updateError

      setAvatarUrl(publicUrl)
      setMessage('Fotografia atualizada.')
    } catch {
      setMessage('Não foi possível enviar a fotografia.')
    } finally {
      setUploading(false)
    }
  }

  return (
    <main className="conta-page">
      <header className="conta-page-head">
        <div>
          <p className="conta-kicker">A minha conta</p>
          <h1 className="conta-title">{displayName}</h1>
          <p className="conta-sub">
            Uma conta para o site, o Localizador e as reservas nas farmácias.
          </p>
        </div>
        <div className="conta-head-acts">
          <Link href="/perfil/seguranca" className="conta-btn conta-btn--ghost conta-btn--sm">
            Segurança e palavra-passe
          </Link>
        </div>
      </header>

      {message && (
        <p
          className={`conta-alert${message.includes('atualiz') ? ' conta-alert--ok' : ' conta-alert--bad'}`}
          role="status"
        >
          {message}
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
              title="Trocar fotografia"
              aria-label="Trocar fotografia"
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
                  aria-label="Guardar nome"
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
                  aria-label="Cancelar"
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
                  aria-label="Editar nome"
                  title="Editar nome"
                >
                  <Pencil size={13} />
                </button>
              </h2>
            )}

            <p className="conta-identity-sub">{profile.email}</p>
            <div className="conta-identity-tags">
              <span className="conta-tag">{profile.membroDesde}</span>
              <span className={`conta-tag${profile.verified ? ' conta-tag--ok' : ''}`}>
                {profile.verified ? 'E-mail confirmado' : 'E-mail por confirmar'}
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
              Guardados
              {savedTotal > 0 && <span className="conta-panel-count">{savedTotal}</span>}
            </h2>
            <a
              href={`${LOCATOR_ORIGIN}/guardados`}
              className="conta-btn conta-btn--ghost conta-btn--sm"
            >
              Ver todos
            </a>
          </div>

          {saved.length === 0 ? (
            <div className="conta-empty">
              <p className="conta-empty-title">Ainda não guardou nenhum medicamento</p>
              <p className="conta-empty-sub">
                Cada medicamento que guardar no Localizador aparece aqui com os preços das
                farmácias que o confirmaram.
              </p>
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
                        Ver no site
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
          <section className="conta-panel" aria-labelledby="conta-dados">
            <div className="conta-panel-head">
              <h2 id="conta-dados" className="conta-panel-title">
                A conta
              </h2>
            </div>
            <ul className="conta-rows">
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">E-mail</span>
                  <span className="conta-row-title">{profile.email}</span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">Estado</span>
                  <span className="conta-row-title">
                    {profile.verified ? 'Verificada' : 'Por confirmar'}
                  </span>
                </div>
              </li>
              <li className="conta-row">
                <div className="conta-row-main">
                  <span className="conta-row-meta">Membro desde</span>
                  <span className="conta-row-title">{profile.membroDesde}</span>
                </div>
              </li>
            </ul>
          </section>

          <section className="conta-panel" aria-labelledby="conta-site">
            <div className="conta-panel-head">
              <h2 id="conta-site" className="conta-panel-title">
                No site
              </h2>
            </div>
            <ul className="conta-rows">
              {SITE_LINKS.map(({ href, title, description, icon: Icon }) => (
                <li key={href} className="conta-row">
                  <div className="conta-row-main">
                    <a className="conta-row-title" href={href}>
                      {title}
                    </a>
                    <span className="conta-row-meta">{description}</span>
                  </div>
                  <div className="conta-row-acts">
                    <a href={href} className="conta-btn conta-btn--ghost conta-btn--sm">
                      <Icon size={13} />
                      Abrir
                    </a>
                  </div>
                </li>
              ))}
            </ul>
          </section>
        </div>
      </div>
    </main>
  )
}
