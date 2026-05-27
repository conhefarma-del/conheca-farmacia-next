'use client'

import { useRouter } from 'next/navigation'
import LanguageSwitcher from '@/components/ui/LanguageSwitcher'

export default function UtilityBar({ lang, t }) {
  const router = useRouter()

  const handleSearch = (e) => {
    if (e.key === 'Enter' && e.target.value.trim()) {
      router.push(`/${lang}/pesquisa?q=${encodeURIComponent(e.target.value.trim())}`)
    }
  }

  const handleSearchClick = () => {
    const input = document.querySelector('.utility-search-input')
    if (input && input.value.trim()) {
      router.push(`/${lang}/pesquisa?q=${encodeURIComponent(input.value.trim())}`)
    } else {
      router.push(`/${lang}/pesquisa`)
    }
  }

  return (
    <div className="utility-bar">
      <div className="utility-bar-container">
        <div className="utility-search">
          <span className="utility-search-icon" onClick={handleSearchClick} role="button" tabIndex={0}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="11" cy="11" r="8" />
              <line x1="21" y1="21" x2="16.65" y2="16.65" />
            </svg>
          </span>
          <input
            type="text"
            className="utility-search-input"
            placeholder={t('search.placeholder') || 'Pesquisar...'}
            onKeyDown={handleSearch}
          />
        </div>
        <LanguageSwitcher currentLang={lang} />
      </div>
    </div>
  )
}
