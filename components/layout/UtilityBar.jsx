'use client'

import { useRouter } from 'next/navigation'
import { useEffect, useRef, useState } from 'react'
import LanguageSwitcher from '@/components/ui/LanguageSwitcher'
import { getSectionHref } from '@/lib/i18n-routes'

const MOBILE_QUERY = '(max-width: 768px)'

export default function UtilityBar({ lang, t }) {
  const router = useRouter()
  const [searchOpen, setSearchOpen] = useState(false)
  const inputRef = useRef(null)

  const handleSearch = (e) => {
    if (e.key === 'Enter' && e.target.value.trim()) {
      router.push(`${getSectionHref(lang, 'pesquisa')}?q=${encodeURIComponent(e.target.value.trim())}`)
    }
  }

  const handleSearchClick = () => {
    const input = inputRef.current
    if (input && input.value.trim()) {
      router.push(`${getSectionHref(lang, 'pesquisa')}?q=${encodeURIComponent(input.value.trim())}`)
    } else {
      router.push(`${getSectionHref(lang, 'pesquisa')}`)
    }
  }

  // Mobile: clique no ícone expande a caixa em vez de navegar já.
  const handleSearchIconClick = () => {
    if (typeof window !== 'undefined' && window.matchMedia(MOBILE_QUERY).matches) {
      setSearchOpen(true)
    } else {
      handleSearchClick()
    }
  }

  // Ao expandir em mobile, foca o input para o teclado abrir de imediato.
  useEffect(() => {
    if (searchOpen && inputRef.current) {
      inputRef.current.focus()
    }
  }, [searchOpen])

  const handleSearchClose = () => {
    setSearchOpen(false)
    if (inputRef.current) inputRef.current.value = ''
  }

  return (
    <div className="utility-bar">
      <div className={`utility-bar-container${searchOpen ? ' search-open' : ''}`}>
        <div className={`utility-search${searchOpen ? ' mobile-open' : ''}`}>
          <span
            className="utility-search-icon"
            onClick={handleSearchIconClick}
            onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); handleSearchIconClick(); } }}
            role="button"
            tabIndex={0}
            aria-label={t('search.pesquisa') || 'Pesquisar'}
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
          </span>
          <input
            ref={inputRef}
            type="text"
            className="utility-search-input"
            placeholder={t('search.placeholder') || 'Pesquisar...'}
            onKeyDown={handleSearch}
          />
          {searchOpen && (
            <button
              type="button"
              className="utility-search-close"
              onClick={handleSearchClose}
              aria-label={t('search.fechar_pesquisa') || 'Fechar pesquisa'}
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <line x1="18" y1="6" x2="6" y2="18" />
                <line x1="6" y1="6" x2="18" y2="18" />
              </svg>
            </button>
          )}
        </div>
        {!searchOpen && <LanguageSwitcher currentLang={lang} />}
      </div>
    </div>
  )
}