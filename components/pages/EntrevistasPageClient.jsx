'use client'

import { useState, useEffect, useContext } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Search, Clock, Video, Mic, Play, Eye, ChevronLeft, ChevronRight, Music2, FileText } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { parseAudioEmbed } from '@/lib/utils/audio-embed'

const CATEGORIES = [
  { value: 'profissionais', labelKey: 'entrevistas_page.category_profissionais', color: '#ff6c23' },
  { value: 'lideres', labelKey: 'entrevistas_page.category_lideres', color: '#0a844f' },
  { value: 'educadores', labelKey: 'entrevistas_page.category_educadores', color: '#002a32' },
  { value: 'investigadores', labelKey: 'entrevistas_page.category_investigadores', color: '#006171' },
]

const PER_PAGE = 15

/**
 * Lista de páginas para a navegação, com reticências quando há muitas:
 * ex. total 12, atual 6 → [1, '…', 4, 5, 6, 7, 8, '…', 12]
 */
function pageList(current, total) {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1)
  const pages = new Set([1, total, current - 1, current, current + 1])
  const sorted = [...pages].filter((p) => p >= 1 && p <= total).sort((a, b) => a - b)
  const out = []
  let prev = 0
  for (const p of sorted) {
    if (p - prev > 1) out.push('ellipsis')
    out.push(p)
    prev = p
  }
  return out
}

/**
 * Constrói a URL da listagem a partir do estado de filtros (server-side).
 * Parâmetros omitidos = predefinição; página 1 não gera `?page=1`.
 */
function buildUrl(lang, { categoria = '', q = '', ordenar = 'recent', page = 1 } = {}) {
  const params = new URLSearchParams()
  if (categoria) params.set('categoria', categoria)
  if (q.trim()) params.set('q', q.trim())
  if (ordenar && ordenar !== 'recent') params.set('ordenar', ordenar)
  if (page > 1) params.set('page', String(page))
  const qs = params.toString()
  return `/${lang}/entrevistas${qs ? `?${qs}` : ''}`
}

function formatDate(dateStr, lang) {
  if (!dateStr) return ''
  const locale = lang === 'en' ? 'en-US' : 'pt-PT'
  return new Date(dateStr).toLocaleDateString(locale, { year: 'numeric', month: 'long', day: 'numeric' })
}

/**
 * Tipo de mídia da entrevista para o badge do card:
 * video | spotify | audio | text. Usa parseAudioEmbed para distinguir o
 * Spotify dos restantes URLs de áudio.
 */
function getMediaBadge(i) {
  if (i.videoId) return { type: 'video', icon: Video, labelKey: 'entrevistas_page.media_video' }
  if (i.audioUrl) {
    const embed = parseAudioEmbed(i.audioUrl)
    if (embed?.type === 'spotify') {
      return { type: 'spotify', icon: Music2, labelKey: 'entrevistas_page.media_spotify' }
    }
    return { type: 'audio', icon: Mic, labelKey: 'entrevistas_page.media_audio' }
  }
  return { type: 'text', icon: FileText, labelKey: 'entrevistas_page.media_text' }
}

/**
 * EntrevistasPageClient — listagem pública das Entrevistas.
 * Server-side: a página server filtra/ordena/pagina (15 por página) e passa
 * a fatia atual + total + estado ativo; este componente só navega (router).
 * A pesquisa tem debounce; filtros, ordenação e páginas são URLs indexáveis.
 */
export default function EntrevistasPageClient({
  interviews = [],
  lang = 'pt',
  total = 0,
  page = 1,
  totalPages = 1,
  categoria = '',
  q = '',
  ordenar = 'recent',
}) {
  const { t } = useContext(LangContext)
  const router = useRouter()
  const [searchInput, setSearchInput] = useState(q)

  // Sincroniza o input quando a URL muda (navegação/voltar)
  useEffect(() => {
    setSearchInput(q)
  }, [q])

  // Pesquisa com debounce → router.push (scroll: false; página volta a 1)
  useEffect(() => {
    if (searchInput.trim() === q) return
    const timer = setTimeout(() => {
      router.push(buildUrl(lang, { categoria, q: searchInput, ordenar }), { scroll: false })
    }, 350)
    return () => clearTimeout(timer)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchInput])

  const handleFilterChange = (value) => {
    router.push(buildUrl(lang, { categoria: value === 'all' ? '' : value }), { scroll: false })
  }

  const handleSortChange = (mode) => {
    if (mode === ordenar) return
    router.push(buildUrl(lang, { categoria, q, ordenar: mode }), { scroll: false })
  }

  const pageFrom = total ? (page - 1) * PER_PAGE + 1 : 0
  const pageTo = total ? Math.min(page * PER_PAGE, total) : 0

  return (
    <>
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
                value={searchInput}
                onChange={(e) => setSearchInput(e.target.value)}
                placeholder={t('entrevistas_page.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>

            {/* Filtros por categoria + ordenação */}
            <div className="flex flex-wrap items-center justify-center gap-3 mt-6">
              <button
                type="button"
                className={`filter-btn ${!categoria ? 'active' : ''}`}
                style={!categoria ? { background: '#0a844f', borderColor: '#0a844f' } : undefined}
                onClick={() => handleFilterChange('all')}
              >
                {t('entrevistas_page.filter_all')}
              </button>
              {CATEGORIES.map((cat) => (
                <button
                  key={cat.value}
                  type="button"
                  className={`filter-btn ${categoria === cat.value ? 'active' : ''}`}
                  style={categoria === cat.value ? { background: cat.color, borderColor: cat.color } : undefined}
                  onClick={() => handleFilterChange(cat.value)}
                >
                  {t(cat.labelKey)}
                </button>
              ))}

              {/* Ordenação: Mais recentes / Mais vistas */}
              <div
                className="inline-flex rounded-full border border-brand-divider overflow-hidden"
                role="group"
                aria-label={t('entrevistas_page.sort_label')}
              >
                <button
                  type="button"
                  className={`interview-sort-btn ${ordenar === 'recent' ? 'active' : ''}`}
                  onClick={() => handleSortChange('recent')}
                >
                  {t('entrevistas_page.sort_recent')}
                </button>
                <button
                  type="button"
                  className={`interview-sort-btn ${ordenar === 'views' ? 'active' : ''}`}
                  onClick={() => handleSortChange('views')}
                >
                  <Eye size={13} /> {t('entrevistas_page.sort_views')}
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Grid de cards */}
      <section className="bg-brand-bg-alt sci-pagination-scroll">
        <div className="max-w-[1400px] mx-auto px-6 md:px-12 py-12">
          {interviews.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {interviews.map((i) => {
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
                      {(() => {
                        const media = getMediaBadge(i)
                        const Icon = media.icon
                        return (
                          <span className="interview-media-badge" title={t(media.labelKey)}>
                            <Icon size={11} aria-hidden="true" /> {t(media.labelKey)}
                          </span>
                        )
                      })()}
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

          {/* Paginação — 15 entrevistas por página, links indexáveis */}
          {totalPages > 1 && (
            <div className="mt-10">
              <p className="text-center text-xs text-brand-deep/50 mb-4">
                {t('entrevistas_page.showing_range', {
                  from: pageFrom,
                  to: pageTo,
                  total,
                })}
              </p>
              <nav className="sci-pagination" aria-label={t('entrevistas_page.pagination_label')}>
                {page > 1 && (
                  <Link
                    href={buildUrl(lang, { categoria, q, ordenar, page: page - 1 })}
                    className="sci-page-btn"
                    aria-label={t('entrevistas_page.pagination_prev')}
                  >
                    <ChevronLeft size={16} />
                  </Link>
                )}
                {pageList(page, totalPages).map((p, i) =>
                  p === 'ellipsis' ? (
                    <span key={`e${i}`} className="sci-page-ellipsis" aria-hidden="true">…</span>
                  ) : (
                    <Link
                      key={p}
                      href={buildUrl(lang, { categoria, q, ordenar, page: p })}
                      className={`sci-page-btn${p === page ? ' active' : ''}`}
                      aria-current={p === page ? 'page' : undefined}
                    >
                      {p}
                    </Link>
                  )
                )}
                {page < totalPages && (
                  <Link
                    href={buildUrl(lang, { categoria, q, ordenar, page: page + 1 })}
                    className="sci-page-btn"
                    aria-label={t('entrevistas_page.pagination_next')}
                  >
                    <ChevronRight size={16} />
                  </Link>
                )}
              </nav>
            </div>
          )}
        </div>
      </section>
    </>
  )
}
