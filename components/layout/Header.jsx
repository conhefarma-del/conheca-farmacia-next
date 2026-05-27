'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import ThemeToggle from '@/components/ui/ThemeToggle'

export default function Header({ lang, t, onToggleDrawer }) {
  const pathname = usePathname()

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

  const navLinks = [
    { href: `/${lang}`, label: t('nav.inicio'), path: '' },
    { href: `/${lang}/artigos`, label: t('nav.artigos'), path: 'artigos' },
    { href: `/${lang}/eventos`, label: t('nav.eventos'), path: 'eventos' },
    { href: `/${lang}/lives`, label: t('nav.lives'), path: 'lives' },
    { href: `/${lang}/sobre`, label: t('nav.sobre'), path: 'sobre' },
  ]

  return (
    <header className="header">
      <nav className="nav-container">
        <Link href={`/${lang}`} className="logo">
          <img src="/logo/3.png" alt="Conheça Farmácia" />
        </Link>

        <div className="nav-links">
          {navLinks.map((link) => (
            <Link key={link.path} href={link.href} className={isActive(link.path)}>
              {link.label}
            </Link>
          ))}
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
