'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import Link from 'next/link'
import Image from 'next/image'
import { LIVE_CATEGORY_COLORS } from '@/lib/constants'
import { validateUrl } from '@/lib/security'

export default function LiveCard({ live, lang = 'pt', variant = 'list' }) {
  const { t } = useContext(LangContext)
  const color = LIVE_CATEGORY_COLORS[live.category || live.categoria] || '#666'
  const dateObj = new Date((live.date || live.data) + 'T00:00:00')
  const day = String(dateObj.getDate()).padStart(2, '0')
  const month = dateObj.toLocaleString(lang === 'en' ? 'en' : 'pt-PT', { month: 'short' }).toUpperCase()
  const fullDate = dateObj.toLocaleDateString(lang === 'en' ? 'en' : 'pt-PT', {
    day: 'numeric', month: 'long', year: 'numeric',
  })
  const saberMais = t('content.saber_mais')

  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const isPast = dateObj < today
  const accessLabel = isPast
    ? t('lives_page.ver_gravacao')
    : t('lives_page.aceder_live')

  const hora = live.time || live.hora || ''
  const plataforma = live.platform || live.plataforma || ''
  // Prefer camelCase merged keys (set by mergeEntity from EN translation),
  // fall back to PT keys for backwards compatibility.
  const categoriaLabel = live.category_label || live.categoriaLabel || live.category || live.categoria || ''
  const resumo = live.excerpt || live.resumo || live.description || live.summary || ''
  const titulo = live.title || live.titulo || ''
  const linkAcesso = validateUrl(live.access_link || live.link_acesso || '#')

  if (variant === 'home') {
    return (
      <article className="event-card home-card">
        <div className="event-card-header relative">
          <div className="event-card-date-box" style={{ backgroundColor: color }}>
            <div className="day">{day}</div>
            <div className="month">{month}</div>
          </div>
          {(live.image_url || live.imagem) && (
            <Image
              src={live.image_url || live.imagem}
              alt={titulo}
              width={400}
              height={192}
              className="event-card-image"
              loading="lazy"
            />
          )}
        </div>
        <div className="event-card-content home-card-content">
          <div className="event-date">{fullDate}</div>
          <h3 className="event-card-title">{titulo}</h3>
          <p className="event-card-excerpt">{resumo}</p>
          <div className="event-card-actions mt-auto">
            <a
              href={linkAcesso}
              target="_blank"
              rel="noopener noreferrer"
              className="btn btn-primary btn-small w-full"
              style={{ backgroundColor: color, borderColor: color }}
            >
              {accessLabel}
            </a>
          </div>
        </div>
      </article>
    )
  }

  return (
    <article className="event-card">
      <div className="event-card-header relative">
        <div className="event-card-date-box" style={{ backgroundColor: color }}>
          <div className="day">{day}</div>
          <div className="month">{month}</div>
        </div>
        {(live.image_url || live.imagem) && (
          <Image
            src={live.image_url || live.imagem}
            alt={titulo}
            width={400}
            height={192}
            className="event-card-image"
            loading="lazy"
          />
        )}
      </div>

      <div className="event-card-content">
        <div className="flex flex-row flex-wrap items-center gap-2 mb-4">
          <span
            className="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider"
            style={{ backgroundColor: `${color}20`, color, border: `1px solid ${color}40` }}
          >
            {categoriaLabel}
          </span>
          {plataforma && (
            <span className="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider bg-slate-100 text-slate-600 border border-slate-200">
              {plataforma}
            </span>
          )}
        </div>

        <h3 className="event-card-title">{titulo}</h3>
        <p className="event-card-excerpt">{resumo}</p>

        <div className="event-card-meta">
          <div className="event-meta-item">
            <span>{hora}</span>
          </div>
          <div className="event-meta-item">
            <span>{plataforma}</span>
          </div>
        </div>

        <div className="event-card-actions mt-auto">
          <Link
            href={`/${lang}/lives/${live.slug}`}
            className="btn btn-secondary btn-small"
          >
            {saberMais}
          </Link>
          <a
            href={linkAcesso}
            target="_blank"
            rel="noopener noreferrer"
            className="btn btn-primary btn-small"
            style={{ backgroundColor: color, borderColor: color }}
          >
            {accessLabel}
          </a>
        </div>
      </div>
    </article>
  )
}
