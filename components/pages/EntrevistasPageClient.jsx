'use client'

import { useState, useMemo, useContext } from 'react'
import Link from 'next/link'
import { ArrowLeft, Search, Clock, Video, Mic, Play, Eye } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

const CATEGORIES = [
  { value: 'profissionais', labelKey: 'entrevistas_page.category_profissionais', color: '#ff6c23' },
  { value: 'lideres', labelKey: 'entrevistas_page.category_lideres', color: '#0a844f' },
  { value: 'educadores', labelKey: 'entrevistas_page.category_educadores', color: '#002a32' },
  { value: 'investigadores', labelKey: 'entrevistas_page.category_investigadores', color: '#006171' },
]

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
}

export default function EntrevistasPageClient({ interviews = [], lang = 'pt', backHref = '/pt/artigos', backLabel = '← Voltar para Artigos' }) {
  const { t } = useContext(LangContext)
  const [currentFilter, setCurrentFilter] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')

  const filtered = useMemo(() => {
    return interviews.filter((i) => {
      const matchesCategory = currentFilter === 'all' || i.category === currentFilter
      const matchesSearch =
        !searchTerm ||
        i.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        i.excerpt?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (i.interviewee?.name || '').toLowerCase().includes(searchTerm.toLowerCase())
      return matchesCategory && matchesSearch
    })
  }, [interviews, currentFilter, searchTerm])

  return (
    <>
      {/* ← Voltar para Artigos */}
      <div className="max-w-[1400px] mx-auto px-6 md:px-12 pt-6">
        <Link
          href={backHref}
          className="inline-flex items-center gap-2 text-sm font-semibold text-[var(--color-brand-accent)] hover:underline"
        >
          <ArrowLeft size={16} /> {backLabel}
        </Link>
      </div>

      {/* Hero — mesma altura que /eventos, com pesquisa + filtros dentro (como /artigos) */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('entrevistas_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('entrevistas_page.hero_subtitle')}
            </p>

            {/* Pesquisa */}
            <div className="max-w-3xl mx-auto mt-10 relative">
              <Search
                size={18}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-brand-deep/40"
                aria-hidden="true"
              />
              <input
                type="search"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder={t('entrevistas_page.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>

            {/* Filtros por categoria */}
            <div className="flex flex-wrap items-center justify-center gap-3 mt-6">
              <button
                type="button"
                className={`filter-btn ${currentFilter === 'all' ? 'active' : ''}`}
                onClick={() => setCurrentFilter('all')}
              >
                {t('entrevistas_page.filter_all')}
              </button>
              {CATEGORIES.map((cat) => (
                <button
                  key={cat.value}
                  type="button"
                  className={`filter-btn ${currentFilter === cat.value ? 'active' : ''}`}
                  style={currentFilter === cat.value ? { background: cat.color, borderColor: cat.color } : undefined}
                  onClick={() => setCurrentFilter(cat.value)}
                >
                  {t(cat.labelKey)}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Grid de cards */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {filtered.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filtered.map((i) => {
                const cat = CATEGORIES.find((c) => c.value === i.category)
                const color = cat?.color || '#0a844f'
                return (
                  <Link
                    key={i.slug}
                    href={`/${lang}/entrevistas/${i.slug}`}
                    className="interview-card"
                  >
                    {/* Thumbnail */}
                    <div className="interview-card-thumb" style={{ background: `${color}15` }}>
                      {i.videoId ? (
                        <>
                          {i.thumbnailUrl ? (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img src={i.thumbnailUrl} alt="" className="interview-card-thumb-img" loading="lazy" />
                          ) : (
                            <div className="interview-card-thumb-placeholder">
                              <Video size={40} strokeWidth={1.5} style={{ color }} aria-hidden="true" />
                            </div>
                          )}
                          <span className="interview-play-overlay">
                            <span className="interview-play-btn" style={{ color }}>
                              <Play size={20} fill="currentColor" aria-hidden="true" />
                            </span>
                          </span>
                        </>
                      ) : (
                        <div className="interview-card-thumb-placeholder">
                          <Mic size={40} strokeWidth={1.5} style={{ color }} aria-hidden="true" />
                        </div>
                      )}
                      <span className="interview-badge" style={{ background: color }}>
                        {cat?.labelKey ? t(cat.labelKey) : i.categoryLabel}
                      </span>
                      {i.videoDuration && (
                        <span className="interview-duration">{i.videoDuration}</span>
                      )}
                    </div>

                    {/* Body */}
                    <div className="interview-card-body">
                      <div className="interview-card-meta">
                        <time>{formatDate(i.date, lang)}</time>
                        {i.readTime && (
                          <>
                            <span>·</span>
                            <span className="inline-flex items-center gap-1">
                              <Clock size={12} aria-hidden="true" /> {i.readTime} {t('entrevistas_page.min_read')}
                            </span>
                          </>
                        )}
                        <span title={t('entrevistas_page.views')}>
                          <Eye size={12} aria-hidden="true" /> {i.viewCount || 0}
                        </span>
                      </div>
                      <h2 className="interview-card-title">{i.title}</h2>
                      {i.excerpt && <p className="interview-card-excerpt">{i.excerpt}</p>}
                      <div className="interview-card-footer">
                        <div className="interview-card-person">
                          <span
                            className="avatar"
                            style={{ background: i.interviewee?.avatarBg || color }}
                          >
                            {(i.interviewee?.avatar || (i.interviewee?.name || '?')[0] || '?').toUpperCase()}
                          </span>
                          <span>{i.interviewee?.name || t('entrevistas_page.unknown_interviewee')}</span>
                        </div>
                        <span className="interview-card-cta">
                          {i.videoId
                            ? t('entrevistas_page.watch_cta')
                            : t('entrevistas_page.read_cta')}
                        </span>
                      </div>
                    </div>
                  </Link>
                )
              })}
            </div>
          ) : (
            <div className="text-center py-16 text-gray-500">
              <p>{t('entrevistas_page.no_results')}</p>
            </div>
          )}
        </div>
      </section>
    </>
  )
}
