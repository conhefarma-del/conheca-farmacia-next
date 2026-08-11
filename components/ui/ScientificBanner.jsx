'use client'

import Link from 'next/link'
import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import { ArrowRight } from 'lucide-react'

/**
 * ScientificBanner — banner "Artigos Científicos" para a página /artigos
 * (variante A light do design demo 2026-08-11). Liga para /[lang]/cientificos.
 */
export default function ScientificBanner() {
  const { lang, t } = useContext(LangContext)

  return (
    <div className="sci-banner">
      <Link href={`/${lang}/cientificos`} className="sci-banner-link">
        <div className="sci-banner-icon" aria-hidden="true">
          {/* Ícone: livro aberto */}
          <svg viewBox="0 0 24 24">
            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
            <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
          </svg>
        </div>
        <div className="sci-banner-text">
          <div className="sci-banner-title">{t('cientificos_page.hero_title')}</div>
          <div className="sci-banner-desc">{t('cientificos_page.banner_desc')}</div>
        </div>
        <div className="sci-banner-arrow" aria-hidden="true">
          <ArrowRight size={16} />
        </div>
      </Link>
    </div>
  )
}
