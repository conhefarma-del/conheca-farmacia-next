import Link from 'next/link'
import { ArrowRight } from 'lucide-react'
import GuideCourseIcon from './GuideCourseIcon'

/**
 * Card de curso no índice /[lang]/guias (e secção "Outros Cursos" no detalhe).
 * O slug é partilhado PT/EN (ex: 'farmacia') → href direto na mesma rota.
 * Toda a card é clicável; o rodapé mostra o nº de disciplinas + seta.
 *
 * Variantes (layout bento do índice):
 *  - 'featured' — card grande em destaque (ícone 56px, badge, descrição);
 *  - 'compact'  — linha horizontal (ícone + nome + contagem);
 *  - 'default'  — card original (usado em "Outros Cursos" no detalhe).
 */
export default function GuideCourseCard({ course, lang, t, variant = 'default' }) {
  const count = course.disciplineCount || 0
  const isFeatured = variant === 'featured'
  const isCompact = variant === 'compact'
  const classes = [
    'guide-course-card',
    isFeatured ? 'guide-course-card--featured' : '',
    isCompact ? 'guide-course-card--compact' : '',
  ].filter(Boolean).join(' ')

  return (
    <Link href={`/${lang}/guias/${course.slug}`} className={classes}>
      <div className="guide-course-icon">
        <GuideCourseIcon name={course.iconEmoji} size={isFeatured ? 56 : isCompact ? 36 : 40} />
      </div>
      {isFeatured && (
        <span className="guide-course-featured-badge">{t('guias_page.featured')}</span>
      )}
      <h2 className="guide-course-name">{course.name}</h2>
      {course.description && (isFeatured || !isCompact) && (
        <p className="guide-course-desc">{course.description}</p>
      )}
      <div className="guide-course-footer">
        <span className="guide-course-count">
          {count} {count === 1 ? t('guias_page.disciplina') : t('guias_page.disciplinas')}
        </span>
        <span className="guide-course-arrow">
          <ArrowRight size={isCompact ? 14 : 16} aria-hidden="true" />
        </span>
      </div>
    </Link>
  )
}
