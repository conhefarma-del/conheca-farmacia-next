'use client'

import { useContext, useEffect, useMemo, useRef, useState } from 'react'
import { usePathname, useRouter, useSearchParams } from 'next/navigation'
import { Search } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import ProtocolCard from '@/components/protocolos/ProtocolCard'

export default function ProtocolosPageClient({ lang, categories, protocols }) {
  const { t } = useContext(LangContext)
  const router = useRouter()
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const [activeCategory, setActiveCategory] = useState(() => {
    if (typeof window === 'undefined') return 'all'
    const cat = new URLSearchParams(window.location.search).get('categoria')
    return cat && categories.some((c) => c.slug === cat) ? cat : 'all'
  })
  const [query, setQuery] = useState('')
  const searchRef = useRef(null)

  // Sincroniza com ?categoria= (back/forward, links externos, breadcrumb do detalhe)
  useEffect(() => {
    const cat = searchParams.get('categoria')
    const valid = cat && categories.some((c) => c.slug === cat)
    setActiveCategory(valid ? cat : 'all')
  }, [searchParams, categories])

  const selectCategory = (slug) => {
    setActiveCategory(slug)
    const params = new URLSearchParams(searchParams.toString())
    if (slug === 'all') params.delete('categoria')
    else params.set('categoria', slug)
    const qs = params.toString()
    router.replace(qs ? `${pathname}?${qs}` : pathname, { scroll: false })
  }

  // Atalhos: "/" foca a pesquisa; Ctrl/Cmd+K idem
  useEffect(() => {
    const onKey = (e) => {
      if (e.key === '/' && document.activeElement !== searchRef.current) {
        e.preventDefault()
        searchRef.current?.focus()
      }
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault()
        searchRef.current?.focus()
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase()
    return protocols.filter((p) => {
      if (activeCategory !== 'all' && p.categorySlug !== activeCategory) return false
      if (!q) return true
      return (p.title + ' ' + p.description + ' ' + p.categoryName).toLowerCase().includes(q)
    })
  }, [protocols, activeCategory, query])

  return (
    <>
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('protocolos_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('protocolos_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Search + Filtros de categoria */}
      <section className="articles-filter-section">
        <div className="container-center">
          <div className="max-w-4xl mx-auto">
            <div className="relative mb-8">
              <span className="absolute inset-y-0 left-0 flex items-center pl-4 text-brand-deep/40">
                <Search size={20} aria-hidden="true" />
              </span>
              <input
                ref={searchRef}
                type="text"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder={t('protocolos_page.placeholder')}
                className="w-full pl-12 pr-4 py-4 rounded-2xl border border-brand-divider shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
              />
            </div>

            <div className="flex flex-wrap justify-center gap-3 pb-8">
              <button
                className={`protocol-filter-btn${activeCategory === 'all' ? ' active' : ''}`}
                onClick={() => selectCategory('all')}
              >
                {t('protocolos_page.todos')}
              </button>
              {categories.map((c) => (
                <button
                  key={c.id}
                  className={`protocol-filter-btn${activeCategory === c.slug ? ' active' : ''}`}
                  onClick={() => selectCategory(c.slug)}
                >
                  {c.name}
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Grid de protocolos */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="protocolos-grid">
            {filtered.map((p) => (
              <ProtocolCard key={p.id} protocol={p} lang={lang} t={t} />
            ))}
          </div>
          {filtered.length === 0 && (
            <div className="protocol-empty-state">{t('protocolos_page.no_results')}</div>
          )}
        </div>
      </section>
    </>
  )
}
