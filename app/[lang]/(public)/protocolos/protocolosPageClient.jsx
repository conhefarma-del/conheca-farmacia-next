'use client'

import { useContext, useEffect, useMemo, useRef, useState } from 'react'
import { Search } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import Breadcrumb from '@/components/ui/Breadcrumb'
import ProtocolCard from '@/components/protocolos/ProtocolCard'

export default function ProtocolosPageClient({ lang, categories, protocols }) {
  const { t } = useContext(LangContext)
  const [activeCategory, setActiveCategory] = useState('all')
  const [query, setQuery] = useState('')
  const searchRef = useRef(null)

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
    <div>
      <Breadcrumb items={[
        { label: t('nav.inicio'), href: '/' + lang },
        { label: t('protocolos_page.hero_title') },
      ]} />

      <section className="hero">
        <h1 className="hero-title">{t('protocolos_page.hero_title')}</h1>
        <p className="hero-subtitle">{t('protocolos_page.hero_subtitle')}</p>
      </section>

      <nav className="protocol-filters-bar" aria-label={t('protocolos_page.hero_title')}>
        <button
          className={`protocol-filter-btn ${activeCategory === 'all' ? 'active' : ''}`}
          onClick={() => setActiveCategory('all')}
        >
          {t('protocolos_page.todos')}
        </button>
        {categories.map((c) => (
          <button
            key={c.id}
            className={`protocol-filter-btn ${activeCategory === c.slug ? 'active' : ''}`}
            onClick={() => setActiveCategory(c.slug)}
          >
            {c.name}
          </button>
        ))}
        <div className="protocol-search">
          <Search size={16} aria-hidden="true" />
          <input
            ref={searchRef}
            type="search"
            className="protocol-search-input"
            placeholder={t('protocolos_page.placeholder')}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
          />
        </div>
      </nav>

      <section className="protocolos-section">
        <div className="protocolos-grid">
          {filtered.map((p) => (
            <ProtocolCard key={p.id} protocol={p} lang={lang} t={t} />
          ))}
        </div>
        {filtered.length === 0 && (
          <div className="protocol-empty-state">{t('protocolos_page.no_results')}</div>
        )}
      </section>
    </div>
  )
}
