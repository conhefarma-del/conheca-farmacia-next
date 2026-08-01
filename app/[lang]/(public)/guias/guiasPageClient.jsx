'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import GuideCourseCard from '@/components/guias/GuideCourseCard'

export default function GuiasPageClient({ lang, courses }) {
  const { t } = useContext(LangContext)

  return (
    <>
      {/* Hero */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('guias_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('guias_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Grid de Cursos */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          {courses.length === 0 ? (
            <p className="text-center text-brand-deep/70">
              {t('guias_page.no_courses')}
            </p>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto">
              {courses.map((course) => (
                <GuideCourseCard key={course.id} course={course} lang={lang} t={t} />
              ))}
            </div>
          )}
        </div>
      </section>
    </>
  )
}
