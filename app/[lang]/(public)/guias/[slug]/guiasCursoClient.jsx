'use client'

import { useContext, useMemo } from 'react'
import Link from 'next/link'
import { ArrowRight, ArrowUpRight, BookOpen, CalendarDays, FileText, GraduationCap, ListChecks, MapPin } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import GuideCourseCard from '@/components/guias/GuideCourseCard'
import GuideDisciplinaCard from '@/components/guias/GuideDisciplinaCard'
import GuideSidebar from '@/components/guias/GuideSidebar'
import Breadcrumb from '@/components/ui/Breadcrumb'
import { getSectionHref } from '@/lib/i18n-routes'

export default function GuiasCursoClient({ lang, course, otherCourses = [] }) {
  const { t } = useContext(LangContext)

  const disciplines = course.disciplines || []
  const universities = course.universities || []

  // Stats do hero — derivadas do conteúdo (mantêm-se atualizadas automaticamente)
  const bookCount = disciplines.reduce((acc, d) => acc + (d.books?.length || 0), 0)
  const resourceCount = disciplines.reduce((acc, d) => acc + (d.resources?.length || 0), 0)

  // Timeline por fases — agrupa as disciplinas pela fase, preservando a ordem
  const phases = useMemo(() => {
    const map = new Map()
    for (const d of disciplines) {
      const key = d.phase || t('guias_curso.fase_geral')
      if (!map.has(key)) map.set(key, [])
      map.get(key).push(d)
    }
    return Array.from(map, ([phase, items]) => ({ phase, items }))
  }, [disciplines, t])

  const breadcrumbItems = [
    { label: t('nav.inicio'), href: `/${lang}` },
    { label: t('guias_curso.breadcrumb_guias'), href: getSectionHref(lang, 'guias') },
    { label: course.name },
  ]

  return (
    <>
      {/* Breadcrumb + Hero */}
      <section className="article-hero">
        <div className="container-center">
          <Breadcrumb items={breadcrumbItems} />
          <h1 className="article-hero-title mb-2">{course.name}</h1>
          {course.heroSubtitle && (
            <p className="text-lg text-brand-deep/70 max-w-2xl">
              {course.heroSubtitle}
            </p>
          )}

          {disciplines.length > 0 && (
            <div className="guide-hero-stats">
              <div className="guide-hero-stat">
                <ListChecks size={18} aria-hidden="true" />
                <span>
                  <strong>{disciplines.length}</strong>{' '}
                  {disciplines.length === 1 ? t('guias_page.disciplina') : t('guias_page.disciplinas')}
                </span>
              </div>
              <div className="guide-hero-stat">
                <BookOpen size={18} aria-hidden="true" />
                <span>
                  <strong>{bookCount}</strong>{' '}
                  {bookCount === 1 ? t('guias_curso.livro') : t('guias_curso.livros')}
                </span>
              </div>
              <div className="guide-hero-stat">
                <FileText size={18} aria-hidden="true" />
                <span>
                  <strong>{resourceCount}</strong>{' '}
                  {resourceCount === 1 ? t('guias_curso.recurso') : t('guias_curso.recursos')}
                </span>
              </div>
              <div className="guide-hero-stat">
                <CalendarDays size={18} aria-hidden="true" />
                <span>
                  <strong>{phases.length}</strong>{' '}
                  {phases.length === 1 ? t('guias_curso.fase') : t('guias_curso.fases')}
                </span>
              </div>
            </div>
          )}
        </div>
      </section>

      {/* Detalhe: conteúdo + sidebar */}
      <div className="guide-detail-layout">
        <div className="guide-detail-main">
          {/* Plano por fases (timeline) */}
          <section>
            <div className="guide-section-heading">
              <CalendarDays size={20} aria-hidden="true" />
              <h2>{t('guias_curso.plano_por_fases')}</h2>
            </div>

            {disciplines.length === 0 ? (
              <p className="text-brand-deep/70">
                {t('guias_curso.disciplinas_preparacao')}
              </p>
            ) : (
              <div className="guide-timeline">
                {phases.map((group, gi) => (
                  <div key={gi} className="guide-timeline-phase">
                    <div className="guide-timeline-marker">
                      <span className="guide-timeline-dot" aria-hidden="true" />
                      {gi < phases.length - 1 && (
                        <span className="guide-timeline-line" aria-hidden="true" />
                      )}
                    </div>
                    <div className="guide-timeline-content">
                      <h3 className="guide-timeline-phase-title">{group.phase}</h3>
                      <div className="guide-timeline-cards">
                        {group.items.map((disc) => (
                          <GuideDisciplinaCard key={disc.id} disciplina={disc} t={t} />
                        ))}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </section>

          {/* Onde estudar este curso */}
          {universities.length > 0 && (
            <section id="onde-estudar" className="guide-university-section">
              <div className="guide-section-heading">
                <GraduationCap size={20} aria-hidden="true" />
                <h2>{t('guias_curso.onde_estudar')}</h2>
              </div>
              <p className="guide-university-desc">{t('guias_curso.onde_estudar_desc')}</p>
              <div className="guide-university-grid">
                {universities.map((u) => (
                  <div key={u.id} className="guide-university-card">
                    <div className="guide-university-head">
                      <h3 className="guide-university-name">{u.name}</h3>
                      <span className={`guide-university-type${u.isPublic ? '' : ' is-private'}`}>
                        {u.isPublic
                          ? t('guias_curso.universidade_publica')
                          : t('guias_curso.universidade_privada')}
                      </span>
                    </div>
                    {u.city && (
                      <p className="guide-university-city">
                        <MapPin size={14} aria-hidden="true" />
                        {u.city}
                      </p>
                    )}
                    <div className="guide-university-links">
                      {u.websiteUrl && (
                        <a href={u.websiteUrl} target="_blank" rel="noopener noreferrer">
                          {t('guias_curso.site')}
                          <ArrowUpRight size={14} aria-hidden="true" />
                        </a>
                      )}
                      {u.courseUrl && (
                        <a href={u.courseUrl} target="_blank" rel="noopener noreferrer">
                          {t('guias_curso.pagina_curso')}
                          <ArrowUpRight size={14} aria-hidden="true" />
                        </a>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}
        </div>

        <GuideSidebar course={course} t={t} />
      </div>

      {/* Outros Cursos — leva de volta à lista de cursos */}
      {otherCourses.length > 0 && (
        <section className="section-padding bg-brand-bg-alt">
          <div className="container-center">
            <h2 className="text-3xl md:text-4xl font-bold text-brand-deep text-center mb-12">
              {t('guias_curso.outros_cursos')}
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              {otherCourses.map((course) => (
                <GuideCourseCard key={course.id} course={course} lang={lang} t={t} />
              ))}
            </div>
            <div className="text-center mt-12">
              <Link href={getSectionHref(lang, 'guias')} className="guide-view-all-btn">
                {t('guias_curso.ver_todos')}
                <ArrowRight size={16} aria-hidden="true" />
              </Link>
            </div>
          </div>
        </section>
      )}
    </>
  )
}
