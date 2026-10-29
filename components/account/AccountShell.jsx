'use client'

import Image from 'next/image'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { useCallback, useEffect, useState } from 'react'
import {
  Bookmark,
  CalendarCheck,
  GraduationCap,
  LayoutDashboard,
  Settings2,
  ShieldCheck,
  X,
} from 'lucide-react'
import { createClient } from '@/lib/supabase/client'
import ThemeToggle from '@/components/ui/ThemeToggle'
import { ACCOUNT_ORIGIN, LOCATOR_ORIGIN, SITE_ORIGIN } from '@/lib/account-urls'

/**
 * Chassi das páginas de conta — a mesma peça no Localizador.
 *
 * Herda a estrutura do portal da farmácia: sidebar de altura total à
 * esquerda, top-bar dentro da coluna de conteúdo e drawer em ecrã estreito.
 * A versão clara é a do portal v2 (branco + hairline + números estruturais),
 * para a conta não parecer um produto diferente do resto da plataforma.
 *
 * Uma só lista nos três hosts: as secções vivem em sítios diferentes e os
 * itens atravessam-nos com URLs absolutas. `surface` diz onde estamos e é
 * o que evita que «Visão geral» (`/perfil` em conta.*) e «Perfil de
 * estudante» (`/pt/perfil` no site) se acendam ao mesmo tempo.
 */
const NAV = [
  {
    group: 'Conta',
    items: [
      {
        key: 'geral',
        surface: 'conta',
        href: `${ACCOUNT_ORIGIN}/perfil`,
        path: '/perfil',
        exact: true,
        label: 'Visão geral',
        icon: LayoutDashboard,
      },
      {
        key: 'guardados',
        surface: 'localizador',
        href: `${LOCATOR_ORIGIN}/guardados`,
        path: '/guardados',
        label: 'Guardados',
        icon: Bookmark,
      },
      {
        key: 'reservas',
        surface: 'localizador',
        href: `${LOCATOR_ORIGIN}/reservas`,
        path: '/reservas',
        label: 'Reservas',
        icon: CalendarCheck,
      },
      {
        key: 'seguranca',
        surface: 'conta',
        href: `${ACCOUNT_ORIGIN}/perfil/seguranca`,
        path: '/perfil/seguranca',
        label: 'Segurança',
        icon: ShieldCheck,
      },
    ],
  },
  {
    group: 'Estudo',
    items: [
      {
        key: 'estudante',
        surface: 'site',
        href: `${SITE_ORIGIN}/pt/perfil`,
        path: '/perfil',
        exact: true,
        label: 'Perfil de estudante',
        icon: GraduationCap,
      },
      {
        key: 'definicoes',
        surface: 'site',
        href: `${SITE_ORIGIN}/pt/perfil/definicoes`,
        path: '/perfil/definicoes',
        label: 'Definições',
        icon: Settings2,
      },
    ],
  },
]

function iniciais(nome, email) {
  const parts = String(nome || '')
    .trim()
    .split(/\s+/)
    .filter(Boolean)
  if (parts.length === 0) {
    return String(email || 'U').trim().charAt(0).toUpperCase() || 'U'
  }
  return parts
    .slice(0, 2)
    .map((p) => p[0].toUpperCase())
    .join('')
}

export default function AccountShell({ user = {}, surface = 'conta', lang = 'pt', children }) {
  const pathname = usePathname() || '/'
  const [navOpen, setNavOpen] = useState(false)

  const prefix = surface === 'site' ? `/${lang}` : ''
  const isActive = useCallback(
    (item) => {
      if (item.surface !== surface) return false
      const target = `${prefix}${item.path}`
      if (item.exact) return pathname === target
      return pathname === target || pathname.startsWith(`${target}/`)
    },
    [pathname, prefix, surface],
  )

  const flat = NAV.flatMap((group) => group.items)
  const active = flat.find(isActive)
  const closeNav = useCallback(() => setNavOpen(false), [])

  // Em ecrã largo a sidebar é fixa: se o estado ficar «aberto» ao passar do
  // telemóvel para o desktop, o conteúdo ficava inerte sem nada para fechar.
  useEffect(() => {
    const mq = window.matchMedia('(max-width: 60rem)')
    const sync = () => {
      if (!mq.matches) setNavOpen(false)
    }
    sync()
    mq.addEventListener('change', sync)
    return () => mq.removeEventListener('change', sync)
  }, [])

  // Fecha o drawer em cada navegação e com Escape.
  useEffect(() => {
    queueMicrotask(() => setNavOpen(false))
  }, [pathname])

  useEffect(() => {
    if (!navOpen) return undefined
    const onKey = (event) => {
      if (event.key === 'Escape') setNavOpen(false)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [navOpen])

  async function sair() {
    try {
      await createClient().auth.signOut()
    } catch {
      // Mesmo que o pedido falhe, a pessoa pediu para sair.
    }
    window.location.href = surface === 'site' ? `/${lang}/entrar` : '/entrar'
  }

  const nome = user.name || user.email || 'A minha conta'
  const avatar = user.avatarUrl || null
  const inicial = iniciais(user.name, user.email)
  const logoHref = surface === 'site' ? `${SITE_ORIGIN}/${lang}` : `${ACCOUNT_ORIGIN}/perfil`

  return (
    <div className="conta-shell">
      {navOpen && <div className="conta-scrim" onClick={closeNav} aria-hidden="true" />}

      <aside className={`conta-sidebar${navOpen ? ' conta-sidebar--open' : ''}`}>
        <div className="conta-side-brand">
          <Link href={logoHref} className="conta-side-logo" aria-label="Conheça Farmácia — início">
            <Image
              src="/logo/logo-principal-verde.png"
              alt="Conheça Farmácia"
              width={150}
              height={51}
              priority
              className="conta-logo-green"
            />
            <Image
              src="/logo/logo-principal-branco.png"
              alt=""
              width={150}
              height={51}
              priority
              aria-hidden="true"
              className="conta-logo-white"
            />
          </Link>
          <p className="conta-side-eyebrow">A minha conta</p>
          <button
            type="button"
            className="conta-side-close"
            aria-label="Fechar menu"
            onClick={closeNav}
          >
            <X size={16} />
          </button>
        </div>

        <nav className="conta-nav" aria-label="Secções da conta">
          {NAV.map((group) => (
            <div className="conta-nav-group" key={group.group}>
              <span className="conta-nav-label">{group.group}</span>
              {group.items.map((item) => {
                const numero = String(flat.indexOf(item) + 1).padStart(2, '0')
                const ativo = isActive(item)
                const externo = item.surface !== surface
                const href =
                  item.surface === 'site'
                    ? `${SITE_ORIGIN}/${lang}${item.path}`
                    : item.href
                const Icon = item.icon
                const conteudo = (
                  <>
                    <span className="conta-nav-num">{numero}</span>
                    <Icon strokeWidth={1.8} />
                    <span className="conta-nav-text">{item.label}</span>
                  </>
                )
                const props = {
                  className: `conta-nav-item${ativo ? ' conta-nav-item--active' : ''}`,
                  'aria-current': ativo ? 'page' : undefined,
                  onClick: closeNav,
                }
                return externo ? (
                  <a key={item.key} href={href} {...props}>
                    {conteudo}
                  </a>
                ) : (
                  <Link key={item.key} href={href} {...props}>
                    {conteudo}
                  </Link>
                )
              })}
            </div>
          ))}
        </nav>

        <div className="conta-sidebar-foot">
          <div className="conta-foot-user">
            <span className="conta-foot-avatar" aria-hidden="true">
              {avatar ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={avatar} alt="" />
              ) : (
                inicial
              )}
            </span>
            <span className="conta-foot-meta">
              <span className="conta-foot-name" title={nome}>
                {nome}
              </span>
              <button type="button" className="conta-foot-leave" onClick={sair}>
                Sair
              </button>
            </span>
          </div>

          {/* As duas portas de saída da conta — o mesmo par em todos os
              hosts, para ninguém ficar preso no sítio onde entrou. */}
          <div className="conta-foot-exits">
            <a href={SITE_ORIGIN}>Site</a>
            <span aria-hidden="true">·</span>
            <a href={LOCATOR_ORIGIN}>Localizador</a>
          </div>
        </div>
      </aside>

      <div className="conta-main" inert={navOpen}>
        <header className="conta-topbar">
          <button
            type="button"
            className="conta-menu-btn"
            aria-label={navOpen ? 'Fechar menu' : 'Abrir menu'}
            aria-expanded={navOpen}
            onClick={() => setNavOpen((v) => !v)}
          >
            <svg
              width="18"
              height="18"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              aria-hidden="true"
            >
              {navOpen ? (
                <path d="M6 6l12 12M18 6L6 18" />
              ) : (
                <>
                  <path d="M4 7h16" />
                  <path d="M4 12h16" />
                  <path d="M4 17h16" />
                </>
              )}
            </svg>
          </button>

          <p className="conta-topbar-crumb">
            <span>A minha conta</span>
            <span className="conta-topbar-sep" aria-hidden="true">
              /
            </span>
            <strong>{active?.label || 'Visão geral'}</strong>
          </p>

          <div className="conta-topbar-right">
            <ThemeToggle className="theme-toggle" />
          </div>
        </header>

        {children}
      </div>
    </div>
  )
}
