'use client'

import { useRouter, usePathname } from 'next/navigation'
import { useState, useEffect, useRef } from 'react'

export default function LanguageSwitcher({ currentLang }) {
  const router = useRouter()
  const pathname = usePathname()
  const [open, setOpen] = useState(false)
  const ref = useRef(null)

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (ref.current && !ref.current.contains(e.target)) {
        setOpen(false)
      }
    }
    document.addEventListener('click', handleClickOutside)
    return () => document.removeEventListener('click', handleClickOutside)
  }, [])

  const switchLang = (newLang) => {
    const segments = pathname.split('/')
    segments[1] = newLang
    router.push(segments.join('/'))
    setOpen(false)
  }

  return (
    <div className="utility-lang" ref={ref}>
      <button
        className="lang-toggle"
        onClick={() => setOpen(!open)}
        aria-expanded={open}
        aria-haspopup="true"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="12" cy="12" r="10" />
          <line x1="2" y1="12" x2="22" y2="12" />
          <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
        </svg>
        <span>{currentLang.toUpperCase()}</span>
      </button>
      <div className={`lang-dropdown${open ? ' open' : ''}`} role="menu">
        <button
          className={`lang-option${currentLang === 'pt' ? ' active' : ''}`}
          data-lang="pt"
          role="menuitem"
          onClick={() => switchLang('pt')}
        >
          Português
        </button>
        <button
          className={`lang-option${currentLang === 'en' ? ' active' : ''}`}
          data-lang="en"
          role="menuitem"
          onClick={() => switchLang('en')}
        >
          English
        </button>
      </div>
    </div>
  )
}
