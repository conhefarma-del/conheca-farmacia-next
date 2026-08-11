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
          ) : courses.length === 1 ? (
            /* Só um curso → card em destaque a largura toda */
            <div className="max-w-4xl mx-auto">
              <GuideCourseCard course={courses[0]} lang={lang} t={t} variant="featured" />
            </div>
          ) : (
            /* Bento: 1 curso em destaque (esquerda) + os restantes em linha
               compacta (direita) — preenche o espaço com poucos cursos */
            <div className="max-w-5xl mx-auto">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-stretch">
                <GuideCourseCard course={courses[0]} lang={lang} t={t} variant="featured" />
                <div className="flex flex-col gap-6">
                  {courses.slice(1).map((course) => (
                    <GuideCourseCard key={course.id} course={course} lang={lang} t={t} variant="compact" />
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </section>
    </>
  )
}
