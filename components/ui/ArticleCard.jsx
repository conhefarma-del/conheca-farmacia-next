'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import Link from 'next/link'
import Image from 'next/image'
import { ARTICLE_CATEGORY_COLORS } from '@/lib/constants'

export default function ArticleCard({ article, lang = 'pt' }) {
  const { t } = useContext(LangContext)
  const color = ARTICLE_CATEGORY_COLORS[article.category] || '#666'
  const lerMais = t('content.ler_mais')

  return (
    <article className="article-card">
      <Link href={`/${lang}/artigos/${article.slug}`} className="block">
        {article.image && (
          <Image
            src={article.image}
            alt={article.title}
            width={400}
            height={192}
            className="article-card-img"
            loading="lazy"
          />
        )}
      </Link>
      <div className="article-card-content">
        <span
          className="article-tag"
          style={{
            backgroundColor: `${color}20`,
            color: color,
            border: `1px solid ${color}40`,
          }}
        >
          {article.categoryLabel}
        </span>
        <Link href={`/${lang}/artigos/${article.slug}`}>
          <h3 className="article-card-title">{article.title}</h3>
        </Link>
        <p className="article-card-excerpt">{article.excerpt}</p>
        <Link
          href={`/${lang}/artigos/${article.slug}`}
          className="article-card-link"
        >
          {lerMais}
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="m9 18 6-6-6-6" />
          </svg>
        </Link>
      </div>
    </article>
  )
}
