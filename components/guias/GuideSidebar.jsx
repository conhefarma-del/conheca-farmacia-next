'use client'

import { useEffect, useState } from 'react'
import { CheckCircle2, Circle, RotateCcw } from 'lucide-react'

/**
 * Sidebar do detalhe do guia de estudo.
 * TOC com âncoras para cada disciplina (scrollspy — destaca a disciplina visível)
 * e checklist de progresso do leitor, persistida em localStorage.
 */
export default function GuideSidebar({ course, t, onSelectDiscipline }) {
  const disciplines = course.disciplines || []
  const storageKey = `cf_guia_progress_${course.slug}`
  const [active, setActive] = useState(-1)
  const [done, setDone] = useState([])

  // Carregar progresso guardado (client-side apenas)
  useEffect(() => {
    try {
      const raw = window.localStorage.getItem(storageKey)
      if (raw) setDone(JSON.parse(raw) || [])
    } catch {
      setDone([])
    }
  }, [storageKey])

  // Persistir sempre que done muda
  useEffect(() => {
    try {
      window.localStorage.setItem(storageKey, JSON.stringify(done))
    } catch {
      // localStorage indisponível — ignora
    }
  }, [done, storageKey])

  // Scrollspy: destaca no TOC a disciplina na faixa superior do viewport
  useEffect(() => {
    const els = disciplines
      .map((d) => document.getElementById(`disciplina-${d.slug}`))
      .filter(Boolean)
    if (els.length === 0) return
    const io = new IntersectionObserver(
      (entries) => {
        const visible = entries.filter((e) => e.isIntersecting)
        if (visible.length === 0) return
        const top = visible.reduce((a, b) =>
          b.boundingClientRect.top < a.boundingClientRect.top ? b : a
        )
        const id = top.target.id.replace('disciplina-', '')
        setActive(disciplines.findIndex((d) => d.slug === id))
      },
      { rootMargin: '0px 0px -60% 0px' }
    )
    els.forEach((el) => io.observe(el))
    return () => io.disconnect()
  }, [disciplines])

  const toggleDone = (slug) => {
    setDone((prev) =>
      prev.includes(slug) ? prev.filter((s) => s !== slug) : [...prev, slug]
    )
  }

  const handleDisciplineClick = (slug) => {
    // Encontrar a fase desta disciplina
    const discipline = disciplines.find((d) => d.slug === slug)
    if (discipline && onSelectDiscipline) {
      onSelectDiscipline(discipline.phase || '', slug)
    }
  }

  const total = disciplines.length
  const doneCount = done.length
  const pct = total > 0 ? Math.round((doneCount / total) * 100) : 0

  return (
    <aside className="guide-sidebar">
      <div className="sidebar-card">
        <div className="sidebar-card-title">{t('guias_curso.neste_curso')}</div>
        <nav className="sidebar-toc">
          {disciplines.length === 0 && (
            <p className="sidebar-empty">{t('guias_curso.sidebar_vazio')}</p>
          )}
          {disciplines.map((d, i) => (
            <a
              key={d.id}
              href={`#disciplina-${d.slug}`}
              className={`toc-link ${active === i ? 'is-active' : ''}`}
              onClick={(e) => {
                e.preventDefault()
                handleDisciplineClick(d.slug)
              }}
            >
              <span className="toc-num">{i + 1}</span>
              {d.name}
            </a>
          ))}
        </nav>
      </div>

      <div className="sidebar-card">
        <div className="sidebar-card-title">{t('guias_curso.o_teu_progresso')}</div>
        {total === 0 ? (
          <p className="sidebar-empty">{t('guias_curso.sidebar_vazio')}</p>
        ) : (
          <>
            <div className="guide-progress-track">
              <div className="guide-progress-fill" style={{ width: `${pct}%` }} />
            </div>
            <p className="guide-progress-label">
              {t('guias_curso.progresso_label', { done: doneCount, total })}
            </p>
            <ul className="guide-progress-list">
              {disciplines.map((d) => {
                const checked = done.includes(d.slug)
                return (
                  <li key={d.id}>
                    <button
                      type="button"
                      className={`guide-progress-item${checked ? ' is-done' : ''}`}
                      onClick={() => toggleDone(d.slug)}
                      aria-pressed={checked}
                    >
                      {checked
                        ? <CheckCircle2 size={15} aria-hidden="true" />
                        : <Circle size={15} aria-hidden="true" />}
                      <span>{d.name}</span>
                    </button>
                  </li>
                )
              })}
            </ul>
            {doneCount > 0 && (
              <button type="button" className="guide-progress-reset" onClick={() => setDone([])}>
                <RotateCcw size={13} aria-hidden="true" />
                {t('guias_curso.recomecar')}
              </button>
            )}
          </>
        )}
      </div>
    </aside>
  )
}
