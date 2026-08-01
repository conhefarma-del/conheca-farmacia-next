'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import GuideDisciplinaCard from '@/components/guias/GuideDisciplinaCard'
import Breadcrumb from '@/components/ui/Breadcrumb'
import { getSectionHref } from '@/lib/i18n-routes'

export default function GuiasCursoClient({ lang, course }) {
  const { t } = useContext(LangContext)

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
          <div className="flex items-center gap-4 mb-4">
            <span className="text-5xl">{course.iconEmoji || '📚'}</span>
            <h1 className="article-hero-title">{course.name}</h1>
          </div>
          {course.heroSubtitle && (
            <p className="text-lg text-brand-deep/70 max-w-2xl">
              {course.heroSubtitle}
            </p>
          )}
        </div>
      </section>

      {/* Disciplinas */}
      <section className="section-padding">
        <div className="container-center max-w-4xl mx-auto">
          {course.disciplines.length === 0 ? (
            <p className="text-center text-brand-deep/70">
              {t('guias_curso.disciplinas_preparacao')}
            </p>
          ) : (
            <div className="space-y-6">
              {course.disciplines.map((disc) => (
                <GuideDisciplinaCard key={disc.id} disciplina={disc} t={t} />
              ))}
            </div>
          )}
        </div>
      </section>
    </>
  )
}
