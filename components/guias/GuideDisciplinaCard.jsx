'use client'

import { useState } from 'react'
import { ChevronDown } from 'lucide-react'
import GuideBookCard from './GuideBookCard'
import GuideResourceLink from './GuideResourceLink'

/**
 * Accordion de disciplina na página de detalhe do curso.
 * Expande para mostrar "porquê é essencial", livros e recursos.
 */
export default function GuideDisciplinaCard({ disciplina, t }) {
  const [open, setOpen] = useState(false)

  return (
    <div id={`disciplina-${disciplina.slug}`} className="guide-discipline-card">
      <button
        className="guide-discipline-header"
        aria-expanded={open}
        onClick={() => setOpen(!open)}
      >
        <div className="guide-discipline-text">
          <h3 className="guide-discipline-name">{disciplina.name}</h3>
          {disciplina.description && (
            <p className="guide-discipline-desc">{disciplina.description}</p>
          )}
        </div>
        <div className="guide-discipline-meta">
          {disciplina.phase && (
            <span className="guide-discipline-phase">{disciplina.phase}</span>
          )}
          <ChevronDown
            size={20}
            className={`guide-discipline-toggle${open ? ' expanded' : ''}`}
          />
        </div>
      </button>

      {open && (
        <div className="guide-discipline-content">
          {disciplina.importance && (
            <div className="guide-importance-box">
              <div className="guide-importance-label">{t('guias_curso.porque_essencial')}</div>
              <p>{disciplina.importance}</p>
            </div>
          )}

          {disciplina.books?.length > 0 && (
            <div className="guide-section-block">
              <div className="guide-section-label">{t('guias_curso.livros_essenciais')}</div>
              <div className="space-y-4">
                {disciplina.books.map((book) => (
                  <GuideBookCard key={book.id} book={book} />
                ))}
              </div>
            </div>
          )}

          {disciplina.resources?.length > 0 && (
            <div className="guide-section-block">
              <div className="guide-section-label">{t('guias_curso.recursos_gratuitos')}</div>
              <div className="space-y-2">
                {disciplina.resources.map((resource) => (
                  <GuideResourceLink key={resource.id} resource={resource} />
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  )
}
