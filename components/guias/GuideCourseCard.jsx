import Link from 'next/link'
import GuideCourseIcon from './GuideCourseIcon'

/**
 * Card de curso no índice /[lang]/guias.
 * O slug é partilhado PT/EN (ex: 'farmacia') → href direto na mesma rota.
 */
export default function GuideCourseCard({ course, lang, t }) {
  return (
    <Link href={`/${lang}/guias/${course.slug}`} className="guide-course-card">
      <div className="guide-course-icon">
        <GuideCourseIcon name={course.iconEmoji} size={40} />
      </div>
      <h2 className="guide-course-name">{course.name}</h2>
      <p className="guide-course-desc">{course.description}</p>
      <span className="guide-course-count">{t('guias_page.ver_disciplinas')}</span>
    </Link>
  )
}
