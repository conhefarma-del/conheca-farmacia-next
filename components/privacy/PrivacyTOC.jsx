'use client'

import { useEffect, useState, useRef, useCallback } from 'react'
import { Menu, X } from 'lucide-react'

export default function PrivacyTOC({ sections, lang, t }) {
  const [activeId, setActiveId] = useState(null)
  const [mobileOpen, setMobileOpen] = useState(false)
  const observerRef = useRef(null)

  // Scroll-spy via IntersectionObserver
  useEffect(() => {
    const headings = sections
      .flatMap((s) => [s, ...(s.children || [])])
      .map((s) => document.getElementById(`section-${s.anchor_slug}`))
      .filter(Boolean)

    if (headings.length === 0) return

    observerRef.current = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((e) => e.isIntersecting)
          .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)
        if (visible.length > 0) {
          const id = visible[0].target.id.replace('section-', '')
          setActiveId(id)
        }
      },
      { rootMargin: '-80px 0px -60% 0px', threshold: 0.1 }
    )

    headings.forEach((el) => observerRef.current.observe(el))
    return () => observerRef.current?.disconnect()
  }, [sections])

  // Smooth scroll on TOC click
  const handleClick = useCallback((e, anchorSlug) => {
    e.preventDefault()
    const el = document.getElementById(`section-${anchorSlug}`)
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
    setMobileOpen(false)
  }, [])

  const renderTOCItems = (items, isChild = false) => (
    <ul className={`privacy-toc-list ${isChild ? 'privacy-toc-sublist' : ''}`}>
      {items.map((section) => (
        <li key={section.anchor_slug}>
          <a
            href={`#section-${section.anchor_slug}`}
            onClick={(e) => handleClick(e, section.anchor_slug)}
            className={`privacy-toc-link ${activeId === section.anchor_slug ? 'privacy-toc-link--active' : ''} ${section.pending ? 'privacy-toc-link--pending' : ''}`}
          >
            {section[`title_${lang}`] || section.title_pt}
            {section.pending && (
              <span className="privacy-toc-pending-dot" title={t('privacy_page.pending_badge')} />
            )}
          </a>
          {section.children && section.children.length > 0 && (
            renderTOCItems(section.children, true)
          )}
        </li>
      ))}
    </ul>
  )

  return (
    <nav className="privacy-toc" aria-label={t('privacy_page.toc_label')}>
      {/* Mobile toggle */}
      <button
        className="privacy-toc-toggle"
        onClick={() => setMobileOpen(!mobileOpen)}
        aria-expanded={mobileOpen}
        aria-label={t('privacy_page.toc_toggle')}
      >
        {mobileOpen ? <X size={20} /> : <Menu size={20} />}
        <span>{t('privacy_page.toc_toggle')}</span>
      </button>

      {/* TOC content */}
      <div className={`privacy-toc-content ${mobileOpen ? 'privacy-toc-content--open' : ''}`}>
        {renderTOCItems(sections)}
      </div>
    </nav>
  )
}
