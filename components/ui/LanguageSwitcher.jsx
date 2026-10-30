'use client'

import { useRouter, usePathname } from 'next/navigation'
import { useState, useEffect, useRef } from 'react'
import { getLocalizedPath } from '@/lib/i18n-routes'
import { createClient } from '@/lib/supabase/client'

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

  /**
   * O site guarda o idioma no URL (`/pt/...`, `/en/...`); a conta
   * (`conta.conhecafarmacia.com`) não tem `[lang]` — lê a preferência de
   * `user_metadata.lang`. Sem gravar aqui, trocar para inglês no utility bar
   * mudava o site e deixava o perfil em português.
   *
   * A gravação não bloqueia a navegação: o pedido segue e o `router.push`
   * acontece logo depois. Sem sessão (ou sem rede), nada disto corre e o
   * caminho normal do site continua a funcionar.
   */
  const switchLang = (newLang) => {
    setOpen(false)
    const destino = getLocalizedPath(pathname, newLang)

    if (newLang !== currentLang) {
      try {
        const supabase = createClient()
        supabase.auth
          .getUser()
          .then(({ data }) =>
            data?.user ? supabase.auth.updateUser({ data: { lang: newLang } }) : null,
          )
          .catch(() => {})
      } catch {
        // Sem cliente (ambiente sem chaves): fica só o idioma do URL.
      }
    }

    router.push(destino)
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
