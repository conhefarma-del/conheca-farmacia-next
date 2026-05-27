'use client'

import { useEffect } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import ThemeToggle from '@/components/ui/ThemeToggle'

export default function MobileDrawer({ lang, t, open, onClose }) {
  const pathname = usePathname()

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
    { href: `/${lang}/artigos`, label: t('nav.artigos'), path: 'artigos' },
    { href: `/${lang}/eventos`, label: t('nav.eventos'), path: 'eventos' },
    { href: `/${lang}/lives`, label: t('nav.lives'), path: 'lives' },
    { href: `/${lang}/sobre`, label: t('nav.sobre'), path: 'sobre' },
  ]

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
          <img src="/logo/3.png" alt="Conheça Farmácia" />
        </div>

        <ul className="drawer-links">
          {navLinks.map((link) => (
            <li key={link.path}>
              <Link href={link.href} className={isActive(link.path)} onClick={handleClose}>
                {link.label}
              </Link>
            </li>
          ))}
        </ul>

        <div className="drawer-footer">
          <ThemeToggle className="drawer-theme-toggle" />
          <div className="drawer-social">
            <a href="https://www.instagram.com/conheca.farmacia/" target="_blank" rel="noopener noreferrer" aria-label="Instagram">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <rect x="2" y="2" width="20" height="20" rx="5" ry="5" />
                <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
                <line x1="17.5" y1="6.5" x2="17.51" y2="6.5" />
              </svg>
            </a>
            <a href="https://www.facebook.com/conheca.farmacia/" target="_blank" rel="noopener noreferrer" aria-label="Facebook">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z" />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </>
  )
}
