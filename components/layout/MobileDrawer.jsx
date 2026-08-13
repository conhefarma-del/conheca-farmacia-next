'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import Image from 'next/image'
import { usePathname } from 'next/navigation'
import { ChevronDown } from 'lucide-react'
import { getSectionHref } from '@/lib/i18n-routes'
import ThemeToggle from '@/components/ui/ThemeToggle'

export default function MobileDrawer({ lang, t, open, onClose }) {
  const pathname = usePathname()
  const [toolsOpen, setToolsOpen] = useState(false)

  // Map subpaths to their parent section (matches MPA PAGE_SECTION_MAP)
  const SECTION_MAP = {
    inscricao: 'eventos',
  }

  const isActive = (path) => {
    const segments = pathname.split('/').filter(Boolean)
    const section = segments[1] || ''
    const mapped = SECTION_MAP[section] || section
    return mapped === path ? 'drawer-link-active' : ''
  }

  // Sync body.drawer-open class with open prop (triggers CSS push animation)
  useEffect(() => {
    if (open) {
      document.body.classList.add('drawer-open')
    } else {
      document.body.classList.remove('drawer-open')
    }
    return () => document.body.classList.remove('drawer-open')
  }, [open])

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

  // Sub-menu "Ferramentas": Guias de Estudo + Protocolos + Interações + Medicamentos
  const toolsLinks = [
    { href: getSectionHref(lang, 'guias'), label: t('nav.guias'), path: 'guias' },
    { href: getSectionHref(lang, 'protocolos'), label: t('nav.protocolos'), path: 'protocolos' },
    { href: getSectionHref(lang, 'interacoes'), label: t('nav.interacoes'), path: 'interacoes' },
    { href: getSectionHref(lang, 'medicamentos'), label: t('nav.medicamentos'), path: 'medicamentos' },
    { href: getSectionHref(lang, 'flashcards'), label: t('nav.flashcards'), path: 'flashcards' },
  ]

  const toolsActive = toolsLinks.some((l) => isActive(l.path))

  const handleClose = () => {
    onClose()
  }

  return (
    <>
      <div
        className={`drawer-overlay${open ? ' active' : ''}`}
        onClick={handleClose}
      />
      <div className={`mobile-drawer${open ? ' open' : ''}`}>
        <button className="drawer-close" onClick={handleClose} aria-label="Close menu">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>

        <div className="drawer-logo">
          <Image src="/logo/3.png" alt="Conheça Farmácia" width={120} height={40} />
        </div>

        <ul className="drawer-links">
          {navLinks.map((link) => (
            <li key={link.path}>
              <Link href={link.href} className={isActive(link.path)} onClick={handleClose}>
                {link.label}
              </Link>
            </li>
          ))}
          <li>
            <button
              className={`drawer-submenu-btn${toolsActive ? ' drawer-submenu-btn--active' : ''}`}
              onClick={() => setToolsOpen((o) => !o)}
              aria-expanded={toolsOpen}
            >
              {t('nav.ferramentas')}
              <ChevronDown
                size={16}
                aria-hidden="true"
                className={toolsOpen ? 'is-open' : ''}
              />
            </button>
            {toolsOpen && (
              <ul className="drawer-submenu">
                {toolsLinks.map((link) => (
                  <li key={link.path}>
                    <Link href={link.href} className={isActive(link.path)} onClick={handleClose}>
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            )}
          </li>
        </ul>

        <div className="drawer-footer">
          <ThemeToggle className="drawer-theme-toggle" />
        </div>
      </div>
    </>
  )
}
