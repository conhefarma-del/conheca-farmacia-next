import { notFound } from 'next/navigation'
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicGuideCourseBySlug, getPublicGuideCourses } from '@/lib/actions/guides'
import GuiasCursoClient from '../../guias/[slug]/guiasCursoClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const course = await getPublicGuideCourseBySlug(slug, safeLang)
  if (!course) return { title: 'Study Guides | Conheça Farmácia' }

  return {
    title: `${course.name} — Study Guides | Conheça Farmácia`,
    description: course.description || course.heroSubtitle,
    alternates: { languages: { pt: `/pt/guias/${slug}`, en: `/en/guides/${slug}` } },
  }
}

export default async function GuideCoursePage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const [course, allCourses] = await Promise.all([
    getPublicGuideCourseBySlug(slug, safeLang),
    getPublicGuideCourses(safeLang),
  ])
  if (!course) notFound()

  const otherCourses = (allCourses || []).filter((c) => c.slug !== slug)

  return <GuiasCursoClient lang={safeLang} course={course} otherCourses={otherCourses} />
}