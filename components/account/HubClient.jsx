'use client'

import { useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { LOCATOR_ORIGIN, SITE_ORIGIN } from '@/lib/account-urls'
import {
  Bookmark,
  CalendarCheck,
  Camera,
  Check,
  ChevronRight,
  GraduationCap,
  Loader2,
  LogOut,
  NotebookPen,
  Pencil,
  Pill,
  Shield,
  X,
} from 'lucide-react'

/**
 * Hub da conta (conta.conhecafarmacia.com/perfil).
 *
 * É a casa comum das duas operações: identidade em cima, atalhos para o que
 * cada produto guarda em baixo. As listas **não** são renderizadas aqui — os
 * cartões de produto e o formato das reservas vivem no Localizador; o hub
 * liga para lá para não duplicar UI que depois diverge.
 *
 * O nome e a foto vivem em `auth.users.raw_user_meta_data` (`full_name`,
 * `display_name`, `avatar_url`) — o mesmo sítio que o site já usa. Não há
 * tabela `profiles`, e não é aqui que ela nasce.
 */

const CARD_LINKS = [
  {
    href: `${LOCATOR_ORIGIN}/reservas`,
    title: 'As minhas reservas',
    description: 'Histórico e estado das reservas',
    icon: CalendarCheck,
  },
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
  const [leaving, setLeaving] = useState(false)
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

  async function handleSignOut() {
    setLeaving(true)
    try {
      const supabase = createClient()
      await supabase.auth.signOut()
    } catch {
      // Mesmo que o pedido falhe, sair do hub é o que a pessoa pediu.
    }
    window.location.href = '/entrar'
  }

  return (
    <div className="container-center py-10 sm:py-14">
      <div className="mx-auto max-w-3xl">
        {message && (
          <div
            className="mb-5 rounded-xl border border-brand-divider bg-brand-card px-4 py-3 text-sm text-brand-deep/80"
            role="status"
          >
            {message}
          </div>
        )}

        {/* Identidade */}
        <section className="rounded-2xl border border-brand-divider bg-brand-card p-6 shadow-soft sm:p-8">
          <div className="flex flex-col items-start gap-5 sm:flex-row sm:items-center">
            <div className="relative shrink-0 group">
              {avatar ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={avatar}
                  alt={displayName}
                  className="h-20 w-20 rounded-full object-cover"
                />
              ) : (
                <div className="flex h-20 w-20 items-center justify-center rounded-full bg-brand-accent/10 text-2xl font-semibold text-brand-accent">
                  {initial}
                </div>
              )}
              <label
                className="absolute inset-0 flex cursor-pointer items-center justify-center rounded-full bg-black/45 text-white opacity-0 transition-opacity group-hover:opacity-100"
                title="Trocar fotografia"
              >
                {uploading ? (
                  <Loader2 size={18} className="animate-spin" />
                ) : (
                  <Camera size={18} />
                )}
                <input
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={handleAvatarUpload}
                  disabled={uploading}
                />
              </label>
            </div>

            <div className="min-w-0 flex-1">
              {editing ? (
                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    value={draft}
                    onChange={(event) => setDraft(event.target.value)}
                    className="w-full rounded-lg border border-brand-divider bg-brand-bg px-3 py-2 text-lg font-semibold text-brand-deep focus:outline-none focus:ring-2 focus:ring-brand-accent"
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
                    className="rounded-lg bg-brand-accent p-2 text-white disabled:opacity-50"
                    aria-label="Guardar nome"
                  >
                    {saving ? <Loader2 size={16} className="animate-spin" /> : <Check size={16} />}
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setEditing(false)
                      setDraft(name)
                    }}
                    className="rounded-lg border border-brand-divider p-2 text-brand-deep/60"
                    aria-label="Cancelar"
                  >
                    <X size={16} />
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-2">
                  <h1 className="truncate text-2xl font-bold text-brand-deep">{displayName}</h1>
                  <button
                    type="button"
                    onClick={() => {
                      setDraft(name)
                      setEditing(true)
                    }}
                    className="rounded-lg p-1.5 text-brand-deep/40 hover:bg-brand-deep/5 hover:text-brand-deep"
                    aria-label="Editar nome"
                  >
                    <Pencil size={15} />
                  </button>
                </div>
              )}

              <p className="mt-1 truncate text-sm text-brand-deep/60">{profile.email}</p>
              <p className="mt-2 text-xs text-brand-deep/45">
                {profile.membroDesde}
                {profile.verified ? ' · e-mail confirmado' : ' · e-mail por confirmar'}
              </p>
            </div>
          </div>
        </section>

        {/*
          Guardados: cada medicamento com os dois destinos — a página do
          medicamento no site (quando existe) e as farmácias que o têm, no
          Localizador. As listas completas continuam no Localizador; aqui fica
          o que a pessoa guardou, com o resto a um clique.
        */}
        <section className="mt-6 overflow-hidden rounded-2xl border border-brand-divider bg-brand-card shadow-soft">
          <div className="flex items-center justify-between gap-3 border-b border-brand-divider px-4 py-3">
            <h2 className="flex items-center gap-2 text-sm font-semibold text-brand-deep">
              <Pill size={16} className="text-brand-accent" />
              Guardados
              {savedTotal > 0 && (
                <span className="rounded-full bg-brand-accent/10 px-2 py-0.5 text-[11px] font-semibold text-brand-accent">
                  {savedTotal}
                </span>
              )}
            </h2>
            <a
              href={`${LOCATOR_ORIGIN}/guardados`}
              className="text-xs font-medium text-brand-accent hover:underline"
            >
              Ver todos
            </a>
          </div>

          {saved.length === 0 ? (
            <p className="px-4 py-6 text-sm text-brand-deep/55">
              Ainda não guardou nenhum medicamento no Localizador. Cada medicamento que guardar
              aparece aqui com os preços das farmácias que o confirmaram.
            </p>
          ) : (
            <ul className="divide-y divide-brand-divider">
              {saved.map((item) => (
                <li
                  key={item.key}
                  className="flex flex-col gap-2 px-4 py-3 sm:flex-row sm:items-center sm:justify-between"
                >
                  <div className="min-w-0">
                    <p className="truncate text-sm font-semibold text-brand-deep">{item.name}</p>
                    {item.meta && (
                      <p className="truncate text-xs text-brand-deep/55">{item.meta}</p>
                    )}
                  </div>
                  <div className="flex shrink-0 items-center gap-2">
                    {item.siteHref && (
                      <a
                        href={item.siteHref}
                        className="rounded-lg border border-brand-divider px-3 py-1.5 text-xs font-medium text-brand-deep/75 transition-colors hover:border-brand-accent/40 hover:text-brand-deep"
                      >
                        Ver no site
                      </a>
                    )}
                    <a
                      href={item.locatorHref}
                      className="rounded-lg bg-brand-accent px-3 py-1.5 text-xs font-semibold text-white transition-colors hover:bg-brand-accent/90"
                    >
                      {item.cta}
                    </a>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>

        {/* Atalhos */}
        <section className="mt-6 grid gap-3 sm:grid-cols-2">
          {CARD_LINKS.map(({ href, title, description, icon: Icon }) => (
            <a
              key={href}
              href={href}
              className="group flex items-center gap-4 rounded-2xl border border-brand-divider bg-brand-card p-4 shadow-soft transition-colors hover:border-brand-accent/40"
            >
              <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-accent/10 text-brand-accent">
                <Icon size={18} />
              </span>
              <span className="min-w-0 flex-1">
                <span className="block truncate text-sm font-semibold text-brand-deep">{title}</span>
                <span className="block truncate text-xs text-brand-deep/55">{description}</span>
              </span>
              <ChevronRight
                size={16}
                className="shrink-0 text-brand-deep/25 transition-transform group-hover:translate-x-0.5"
              />
            </a>
          ))}
        </section>

        {/* Segurança e saída */}
        <section className="mt-6 rounded-2xl border border-brand-divider bg-brand-card p-4 shadow-soft">
          <Link
            href="/perfil/seguranca"
            className="group flex items-center gap-4 rounded-xl p-2 transition-colors hover:bg-brand-deep/5"
          >
            <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-accent/10 text-brand-accent">
              <Shield size={18} />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block text-sm font-semibold text-brand-deep">Segurança</span>
              <span className="block text-xs text-brand-deep/55">
                Palavra-passe, sessões e apagar conta
              </span>
            </span>
            <ChevronRight
              size={16}
              className="shrink-0 text-brand-deep/25 transition-transform group-hover:translate-x-0.5"
            />
          </Link>

          <div className="mt-2 border-t border-brand-divider pt-3">
            <button
              type="button"
              onClick={handleSignOut}
              disabled={leaving}
              className="flex w-full items-center justify-center gap-2 rounded-xl px-4 py-2.5 text-sm font-medium text-brand-deep/70 transition-colors hover:bg-brand-deep/5 disabled:opacity-50"
            >
              {leaving ? <Loader2 size={16} className="animate-spin" /> : <LogOut size={16} />}
              Sair da conta
            </button>
          </div>
        </section>
      </div>
    </div>
  )
}
