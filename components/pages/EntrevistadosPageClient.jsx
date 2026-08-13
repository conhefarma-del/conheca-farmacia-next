'use client'

import { useState, useEffect, useContext } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { LangContext } from '@/lib/contexts'
import { ArrowLeft, Search, Mic, ChevronLeft, ChevronRight } from 'lucide-react'

const PER_PAGE = 30

/**
 * Lista de páginas para a navegação, com reticências quando há muitas.
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
 * URL da listagem de entrevistados a partir do estado de filtros (server-side).
 */
function buildUrl(lang, { q = '', ordenar = 'az', page = 1 } = {}) {
  const params = new URLSearchParams()
  if (q.trim()) params.set('q', q.trim())
  if (ordenar && ordenar !== 'az') params.set('ordenar', ordenar)
  if (page > 1) params.set('page', String(page))
  const qs = params.toString()
  return `/${lang}/entrevistas/entrevistados${qs ? `?${qs}` : ''}`
}

/**
 * EntrevistadosPageClient — índice de entrevistados (mini perfis).
 * Server-side: pesquisa/ordenação/paginação (30 por página) vivem na URL;
 * este componente navega (router) e renderiza os links indexáveis.
 */
export default function EntrevistadosPageClient({
  people = [],
  lang = 'pt',
  total = 0,
  page = 1,
  totalPages = 1,
  q = '',
  ordenar = 'az',
}) {
  const { t } = useContext(LangContext)
  const router = useRouter()
  const [searchInput, setSearchInput] = useState(q)

  useEffect(() => {
    setSearchInput(q)
  }, [q])

  // Pesquisa com debounce → router.push (scroll: false; volta à página 1)
  useEffect(() => {
    if (searchInput.trim() === q) return
    const timer = setTimeout(() => {
      router.push(buildUrl(lang, { q: searchInput, ordenar }), { scroll: false })
    }, 350)
    return () => clearTimeout(timer)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchInput])

  const setSort = (mode) => {
    if (mode === ordenar) return
    router.push(buildUrl(lang, { q, ordenar: mode }), { scroll: false })
  }

  const countLabel = (n) =>
    n === 1
      ? t('entrevistados_page.interviews_count_one')
      : t('entrevistados_page.interviews_count_other', { count: n })

  const pageFrom = total ? (page - 1) * PER_PAGE + 1 : 0
  const pageTo = total ? Math.min(page * PER_PAGE, total) : 0

  return (
    <>
      {/* ← Voltar para Entrevistas */}
      <div className="max-w-[1100px] mx-auto px-6 md:px-12 pt-6">
        <Link
          href={`/${lang}/entrevistas`}
          className="inline-flex items-center gap-2 text-sm font-semibold text-[var(--color-brand-accent)] hover:underline"
        >
          <ArrowLeft size={16} /> {t('entrevistado_profile.back_to_entrevistas')}
        </Link>
      </div>

      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('entrevistados_page.title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('entrevistados_page.subtitle')}
            </p>

            {/* Pesquisa por nome / cargo */}
            <div className="max-w-2xl mx-auto mt-10 relative">
              <Search
                size={18}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-brand-deep/40"
                aria-hidden="true"
              />
              <input
                type="search"
                value={searchInput}
                onChange={(e) => setSearchInput(e.target.value)}
                placeholder={t('entrevistados_page.search_placeholder')}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Lista de entrevistados */}
      <section className="bg-brand-bg-alt">
        <div className="max-w-[1100px] mx-auto px-6 md:px-12 py-12">
          {/* Barra: ordenação */}
          <div className="flex flex-wrap items-center justify-end gap-3 mb-8">
            <div className="inline-flex rounded-full border border-brand-divider overflow-hidden" role="group" aria-label={t('entrevistados_page.sort_label')}>
              <button
                type="button"
                className={`sci-sort-btn ${ordenar === 'az' ? 'active' : ''}`}
                onClick={() => setSort('az')}
              >
                {t('entrevistados_page.sort_az')}
              </button>
              <button
                type="button"
                className={`sci-sort-btn ${ordenar === 'interviews' ? 'active' : ''}`}
                onClick={() => setSort('interviews')}
              >
                <Mic size={13} /> {t('entrevistados_page.sort_most_interviews')}
              </button>
            </div>
          </div>

          {people.length > 0 ? (
            <div className="sci-authors-index-grid">
              {people.map((person) => (
                <div key={person.id} className="sci-author-index-card">
                  <Link
                    href={`/${lang}/entrevistas/entrevistados/${person.slug}`}
                    className="sci-author-index-main"
                  >
                    <span className="sci-avatar" style={{ background: person.avatarBg || '#00493a' }}>
                      {(person.avatar || (person.name || '?')[0]).toUpperCase()}
                    </span>
                    <span className="sci-author-index-info">
                      <span className="sci-author-index-name">{person.name}</span>
                      {person.role && (
                        <span className="sci-author-index-affil">{person.role}</span>
                      )}
                    </span>
                  </Link>
                  <div className="sci-author-index-actions">
                    <span className="sci-author-count">{countLabel(person.interviewCount)}</span>
                    <div className="sci-author-index-links">
                      <Link href={`/${lang}/entrevistas/entrevistados/${person.slug}`}>
                        <Mic size={13} /> {t('entrevistados_page.view_interviews')}
                      </Link>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-16 text-gray-500">
              <p>{t('entrevistados_page.no_results')}</p>
            </div>
          )}

          {/* Paginação — 30 entrevistados por página, links indexáveis */}
          {totalPages > 1 && (
            <div className="mt-10">
              <p className="text-center text-xs text-brand-deep/50 mb-4">
                {t('entrevistas_page.showing_range', { from: pageFrom, to: pageTo, total })}
              </p>
              <nav className="sci-pagination" aria-label={t('entrevistas_page.pagination_label')}>
                {page > 1 && (
                  <Link
                    href={buildUrl(lang, { q, ordenar, page: page - 1 })}
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
                      href={buildUrl(lang, { q, ordenar, page: p })}
                      className={`sci-page-btn${p === page ? ' active' : ''}`}
                      aria-current={p === page ? 'page' : undefined}
                    >
                      {p}
                    </Link>
                  )
                )}
                {page < totalPages && (
                  <Link
                    href={buildUrl(lang, { q, ordenar, page: page + 1 })}
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
