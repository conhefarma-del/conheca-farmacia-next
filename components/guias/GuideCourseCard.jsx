import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import GuideCourseIcon from './GuideCourseIcon'

/**
 * Card de curso no índice /[lang]/guias (e secção "Outros Cursos" no detalhe).
 * O slug é partilhado PT/EN (ex: 'farmacia') → href direto na mesma rota.
 * Toda a card é clicável; o rodapé mostra o nº de disciplinas + seta.
 */
export default function GuideCourseCard({ course, lang, t }) {
  const count = course.disciplineCount || 0
  return (
    <Link href={`/${lang}/guias/${course.slug}`} className="guide-course-card">
      <div className="guide-course-icon">
        <GuideCourseIcon name={course.iconEmoji} size={40} />
      </div>
      <h2 className="guide-course-name">{course.name}</h2>
      <p className="guide-course-desc">{course.description}</p>
      <div className="guide-course-footer">
        <span className="guide-course-count">
          {count} {count === 1 ? t('guias_page.disciplina') : t('guias_page.disciplinas')}
        </span>
        <span className="guide-course-arrow">
          <ArrowRight size={16} aria-hidden="true" />
        </span>
      </div>
    </Link>
  )
}
