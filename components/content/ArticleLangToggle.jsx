'use client'

import Link from 'next/link'
import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'

/**
 * ArticleLangToggle — toggle PT/EN local do artigo científico.
 * Só é renderizado quando existem as duas línguas (langSlugs.en não é null).
 * O clique navega para o slug da outra língua.
 *
 * Props:
 *   - lang: 'pt' | 'en' (língua atual)
 *   - langSlugs: { pt: string, en: string|null }
 */
export default function ArticleLangToggle({ lang, langSlugs }) {
  const { t } = useContext(LangContext)

  if (!langSlugs || !langSlugs.en) return null

  const langs = [
    { code: 'pt', slug: langSlugs.pt },
    { code: 'en', slug: langSlugs.en },
  ]

  return (
    <div
      className="inline-flex rounded-full border border-[var(--color-brand-divider)] overflow-hidden"
      role="group"
      aria-label={t('cientificos_page.lang_pt') + '/' + t('cientificos_page.lang_en')}
    >
      {langs.map((l) => (
        <Link
          key={l.code}
          href={`/${l.code}/cientificos/${l.slug}`}
          className={`px-3 py-1.5 text-xs font-semibold transition-colors ${
            lang === l.code
              ? 'bg-[var(--color-brand-accent)] text-white'
              : 'bg-[var(--color-brand-bg)] text-[var(--color-brand-deep)] opacity-60 hover:opacity-100'
          }`}
          aria-current={lang === l.code ? 'page' : undefined}
        >
          {l.code === 'pt' ? t('cientificos_page.lang_pt') : t('cientificos_page.lang_en')}
        </Link>
      ))}
    </div>
  )
}
