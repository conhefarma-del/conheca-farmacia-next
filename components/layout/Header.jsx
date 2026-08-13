'use client'

import { useEffect, useRef, useState } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import { BookOpen, BrainCircuit, ChevronDown, ClipboardList, Layers, Pill, Tablets } from 'lucide-react'
import ThemeToggle from '@/components/ui/ThemeToggle'
import { getSectionHref } from '@/lib/i18n-routes'

export default function Header({ lang, t, onToggleDrawer }) {
  const pathname = usePathname()
  const [toolsOpen, setToolsOpen] = useState(false)
  const toolsRef = useRef(null)

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

  // Fecha o dropdown ao clicar fora
  useEffect(() => {
    const onDocClick = (e) => {
      if (toolsRef.current && !toolsRef.current.contains(e.target)) setToolsOpen(false)
    }
    document.addEventListener('click', onDocClick)
    return () => document.removeEventListener('click', onDocClick)
  }, [])

  const navLinks = [
    { href: `/${lang}`, label: t('nav.inicio'), path: '' },
    { href: getSectionHref(lang, 'artigos'), label: t('nav.artigos'), path: 'artigos' },
    { href: getSectionHref(lang, 'cientificos'), label: t('nav.cientificos'), path: 'cientificos' },
    { href: getSectionHref(lang, 'eventos'), label: t('nav.eventos'), path: 'eventos' },
    { href: getSectionHref(lang, 'lives'), label: t('nav.lives'), path: 'lives' },
    ...(lang === 'pt'
      ? [{ href: `/${lang}/entrevistas`, label: t('nav.entrevistas'), path: 'entrevistas' }]
      : []),
    { href: getSectionHref(lang, 'sobre'), label: t('nav.sobre'), path: 'sobre' },
  ]

  // Sub-menu "Ferramentas": Guias de Estudo + Protocolos (mega menu com ícones e descrições)
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
    {
      href: getSectionHref(lang, 'protocolos'),
      label: t('nav.protocolos'),
      desc: t('nav.protocolos_desc'),
      path: 'protocolos',
      icon: <ClipboardList size={18} aria-hidden="true" />,
    },
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
      href: getSectionHref(lang, 'flashcards'),
      label: t('nav.flashcards'),
      desc: t('nav.flashcards_desc'),
      path: 'flashcards',
      icon: <Layers size={18} aria-hidden="true" />,
    },
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
