'use client'

import { useEffect, useRef, useState } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import { Atom, Bookmark, BookOpen, BrainCircuit, ChevronDown, ClipboardList, LogIn, LogOut, Pencil, Pill, Tablets, Trophy, User } from 'lucide-react'
import ThemeToggle from '@/components/ui/ThemeToggle'
import InviteNotifications from '@/components/ui/InviteNotifications'
import { getSectionHref } from '@/lib/i18n-routes'
import { featureEnabled } from '@/lib/features'
import { createClient } from '@/lib/supabase/client'

export default function Header({ lang, t, onToggleDrawer }) {
  const pathname = usePathname()
  const [toolsOpen, setToolsOpen] = useState(false)
  const toolsRef = useRef(null)
  const [profileOpen, setProfileOpen] = useState(false)
  const profileRef = useRef(null)
  const [user, setUser] = useState(null)
  const [avatarUrl, setAvatarUrl] = useState(null)

  useEffect(() => {
    const supabase = createClient()
    supabase.auth.getUser().then(({ data }) => {
      if (data.user) {
        setUser(data.user)
        setAvatarUrl(data.user.user_metadata?.avatar_url || null)
      }
    })
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        setUser(session.user)
        setAvatarUrl(session.user.user_metadata?.avatar_url || null)
      } else {
        setUser(null)
        setAvatarUrl(null)
      }
    })
    return () => subscription.unsubscribe()
  }, [])

  // Map subpaths to their parent section (matches MPA PAGE_SECTION_MAP)
  const SECTION_MAP = {
    inscricao: 'eventos',
  }

  const isActive = (path) => {
    const segments = pathname.split('/').filter(Boolean) // ['', 'pt', 'artigos', 'slug'] → ['pt', 'artigos', 'slug']
    const section = segments[1] || '' // index 0 = lang, 1 = section
    const mapped = SECTION_MAP[section] || section
    return mapped === path ? 'nav-link-active' : ''
  }

  // Fecha os dropdowns ao clicar fora
  useEffect(() => {
    const onDocClick = (e) => {
      if (toolsRef.current && !toolsRef.current.contains(e.target)) setToolsOpen(false)
      if (profileRef.current && !profileRef.current.contains(e.target)) setProfileOpen(false)
    }
    document.addEventListener('click', onDocClick)
    return () => document.removeEventListener('click', onDocClick)
  }, [])

  const navLinks = [
    { href: `/${lang}`, label: t('nav.inicio'), path: '' },
    { href: getSectionHref(lang, 'artigos'), label: t('nav.artigos'), path: 'artigos' },
    ...(featureEnabled('cientificos')
      ? [{ href: getSectionHref(lang, 'cientificos'), label: t('nav.cientificos'), path: 'cientificos' }]
      : []),
    { href: getSectionHref(lang, 'eventos'), label: t('nav.eventos'), path: 'eventos' },
    ...(lang === 'pt'
      ? [{ href: `/${lang}/entrevistas`, label: t('nav.entrevistas'), path: 'entrevistas' }]
      : []),
    { href: getSectionHref(lang, 'sobre'), label: t('nav.sobre'), path: 'sobre' },
  ]

  // Sub-menu "Ferramentas": mega menu com ícones e descrições
  const toolsLinks = [
    {
      href: getSectionHref(lang, 'praticar'),
      label: t('nav.praticar'),
      desc: t('nav.praticar_desc'),
      path: 'praticar',
      icon: <BrainCircuit size={18} aria-hidden="true" />,
    },
    {
      href: getSectionHref(lang, 'guias'),
      label: t('nav.guias'),
      desc: t('nav.guias_desc'),
      path: 'guias',
      icon: <BookOpen size={18} aria-hidden="true" />,
    },
    ...(featureEnabled('protocolos')
      ? [{
          href: getSectionHref(lang, 'protocolos'),
          label: t('nav.protocolos'),
          desc: t('nav.protocolos_desc'),
          path: 'protocolos',
          icon: <ClipboardList size={18} aria-hidden="true" />,
        }]
      : []),
    {
      href: getSectionHref(lang, 'interacoes'),
      label: t('nav.interacoes'),
      desc: t('nav.interacoes_desc'),
      path: 'interacoes',
      icon: <Pill size={18} aria-hidden="true" />,
    },
    {
      href: getSectionHref(lang, 'medicamentos'),
      label: t('nav.medicamentos'),
      desc: t('nav.medicamentos_desc'),
      path: 'medicamentos',
      icon: <Tablets size={18} aria-hidden="true" />,
    },
    {
      href: getSectionHref(lang, 'alvos'),
      label: t('nav.alvos'),
      desc: t('nav.alvos_desc'),
      path: 'alvos',
      icon: <Atom size={18} aria-hidden="true" />,
    },
    ...(featureEnabled('competicao')
      ? [{
          href: `/${lang}/competicao`,
          label: t('competition.nav') || 'Competição',
          desc: t('competition.page_description') || 'Quiz competitivo entre escolas',
          path: 'competicao',
          icon: <Trophy size={18} aria-hidden="true" />,
        }]
      : []),
  ]

  const toolsActive = toolsLinks.some((l) => isActive(l.path))

  return (
    <header className="header">
      <nav className="nav-container">
        <Link href={`/${lang}`} className="logo">
          <Image src="/logo/3.png" alt="Conheça Farmácia" width={120} height={40} priority />
        </Link>

        <div className="nav-links">
          {navLinks.map((link) => (
            <Link key={link.path} href={link.href} className={isActive(link.path)}>
              {link.label}
            </Link>
          ))}

          <div
            className="nav-item"
            ref={toolsRef}
            onMouseEnter={() => setToolsOpen(true)}
            onMouseLeave={() => setToolsOpen(false)}
          >
            <button
              className={`nav-dropdown-btn${toolsActive ? ' nav-link-active' : ''}`}
              onClick={() => setToolsOpen((o) => !o)}
              aria-expanded={toolsOpen}
              aria-haspopup="true"
            >
              {t('nav.ferramentas')}
              <ChevronDown
                size={14}
                aria-hidden="true"
                className={`nav-dropdown-chevron${toolsOpen ? ' is-open' : ''}`}
              />
            </button>
            <div className={`mega-menu${toolsOpen ? ' is-open' : ''}`}>
              <div className="mega-grid">
                {toolsLinks.map((link) => (
                  <Link
                    key={link.path}
                    href={link.href}
                    className="mega-link"
                    onClick={() => setToolsOpen(false)}
                  >
                    <span className="mega-icon">{link.icon}</span>
                    <span className="mega-body">
                      <span className="mega-label">{link.label}</span>
                      <span className="mega-desc">{link.desc}</span>
                    </span>
                  </Link>
                ))}
              </div>
            </div>
          </div>
        </div>

        <div className="header-right">
          <ThemeToggle />
          {user && featureEnabled('competicao') && <InviteNotifications lang={lang} />}

          {/* Profile dropdown / Entrar link */}
          <div className="profile-wrapper" ref={profileRef}>
            {user ? (
              <>
                <button
                  className="profile-btn"
                  onClick={() => setProfileOpen((o) => !o)}
                  aria-expanded={profileOpen}
                  aria-haspopup="true"
                  aria-label="Perfil"
                >
                  {avatarUrl ? (
                    <img src={avatarUrl} alt="" className="profile-avatar" width={32} height={32} />
                  ) : (
                    <div className="profile-avatar-placeholder">
                      <User size={18} />
                    </div>
                  )}
                </button>
                <div className={`profile-dropdown${profileOpen ? ' is-open' : ''}`}>
                  <div className="profile-dropdown-header">
                    <span className="profile-dropdown-name">
                      {user.user_metadata?.full_name || user.user_metadata?.display_name || user.email?.split('@')[0]}
                    </span>
                    <span className="profile-dropdown-email">{user.email}</span>
                  </div>
                  <div className="profile-dropdown-divider" />
                  <Link href={`/${lang}/perfil`} className="profile-dropdown-item" onClick={() => setProfileOpen(false)}>
                    <User size={16} />
                    Perfil
                  </Link>
                  <Link href={`/${lang}/anotacoes`} className="profile-dropdown-item" onClick={() => setProfileOpen(false)}>
                    <Pencil size={16} />
                    Anotações
                  </Link>
                  <Link href={`/${lang}/guardados`} className="profile-dropdown-item" onClick={() => setProfileOpen(false)}>
                    <Bookmark size={16} />
                    Guardados
                  </Link>
                  <div className="profile-dropdown-divider" />
                  <button
                    className="profile-dropdown-item profile-dropdown-logout"
                    onClick={async () => {
                      const supabase = createClient()
                      await supabase.auth.signOut()
                      window.location.href = `/${lang}`
                    }}
                  >
                    <LogOut size={16} />
                    Terminar Sessão
                  </button>
                </div>
              </>
            ) : (
              <Link href={`/${lang}/entrar`} className="profile-login-link">
                <span>Entrar</span>
              </Link>
            )}
          </div>

          <button
            className="hamburger"
            onClick={onToggleDrawer}
            aria-label="Menu"
          >
            <span></span>
            <span></span>
            <span></span>
          </button>
        </div>
      </nav>
    </header>
  )
}
