'use client'

import { useState, useRef, useEffect, useContext } from 'react'
import Link from 'next/link'
import { LangContext } from '@/lib/contexts'
import { slugify } from '@/lib/utils/slugify'
import { ChevronDown, BookOpen, UserRound } from 'lucide-react'

/**
 * AuthorMenu — nome de autor clicável no detalhe do artigo científico.
 * Ao clicar abre um pequeno menu com duas opções:
 *   1. Artigos do autor  → /{lang}/cientificos/autores/{slug}
 *   2. Ver perfil        → /{lang}/cientificos/autores/{slug}/perfil
 *
 * O slug vem do registo `scientific_authors` (desambiguado — dois autores
 * com o mesmo nome têm slugs diferentes). Fallback: slugify(nome) enquanto
 * as tabelas 144/145 não existirem.
 */
export default function AuthorMenu({ author, lang }) {
  const { t } = useContext(LangContext)
  const [open, setOpen] = useState(false)
  const ref = useRef(null)

  const slug = author?.slug || slugify(author?.name)

  useEffect(() => {
    if (!open) return
    function onClickOutside(e) {
      if (ref.current && !ref.current.contains(e.target)) setOpen(false)
    }
    function onKey(e) {
      if (e.key === 'Escape') setOpen(false)
    }
    document.addEventListener('mousedown', onClickOutside)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', onClickOutside)
      document.removeEventListener('keydown', onKey)
    }
  }, [open])

  if (!slug) return <span className="sci-author-name">{author?.name}</span>

  return (
    <span className="sci-author-menu" ref={ref}>
      <button
        type="button"
        className="sci-author-menu-btn"
        onClick={() => setOpen((v) => !v)}
        aria-expanded={open}
        aria-haspopup="menu"
      >
        <span className="sci-author-menu-label">{author.name}</span>
        <ChevronDown size={12} aria-hidden="true" />
      </button>
      {open && (
        <span className="sci-author-menu-pop" role="menu">
          <Link
            role="menuitem"
            href={`/${lang}/cientificos/autores/${slug}`}
            onClick={() => setOpen(false)}
          >
            <BookOpen size={14} aria-hidden="true" />
            {t('cientifico_detail.author_articles')}
          </Link>
          <Link
            role="menuitem"
            href={`/${lang}/cientificos/autores/${slug}/perfil`}
            onClick={() => setOpen(false)}
          >
            <UserRound size={14} aria-hidden="true" />
            {t('cientifico_detail.author_profile')}
          </Link>
        </span>
      )}
    </span>
  )
}
