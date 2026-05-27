'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import Link from 'next/link'
import Image from 'next/image'
import { LIVE_CATEGORY_COLORS } from '@/lib/constants'
import { validateUrl } from '@/lib/security'

export default function LiveCard({ live, lang = 'pt', variant = 'list' }) {
  const { t } = useContext(LangContext)
  const color = LIVE_CATEGORY_COLORS[live.categoria || live.category] || '#666'
  const dateObj = new Date((live.data || live.date) + 'T00:00:00')
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

  const hora = live.hora || live.time || ''
  const plataforma = live.plataforma || live.platform || ''
  const categoriaLabel = live.categoriaLabel || live.category || live.categoria || ''
  const resumo = live.resumo || live.summary || ''
  const linkAcesso = validateUrl(live.link_acesso || live.access_link || '#')

  if (variant === 'home') {
    return (
      <article className="event-card home-card">
        <div className="event-card-header relative">
          <div className="event-card-date-box" style={{ backgroundColor: color }}>
            <div className="day">{day}</div>
            <div className="month">{month}</div>
          </div>
          {live.imagem && (
            <Image
              src={live.imagem}
              alt={live.titulo}
              width={400}
              height={192}
              className="event-card-image"
              loading="lazy"
            />
          )}
        </div>
        <div className="event-card-content home-card-content">
          <div className="event-date">{fullDate}</div>
          <h3 className="event-card-title">{live.titulo}</h3>
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
        {live.imagem && (
          <Image
            src={live.imagem}
            alt={live.titulo}
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

        <h3 className="event-card-title">{live.titulo}</h3>
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
