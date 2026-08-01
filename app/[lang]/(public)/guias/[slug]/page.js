import { notFound } from 'next/navigation'
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicGuideCourseBySlug } from '@/lib/actions/guides'
import GuiasCursoClient from './guiasCursoClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const course = await getPublicGuideCourseBySlug(slug, safeLang)
  if (!course) return { title: 'Guias de Estudo | Conheça Farmácia' }

  return {
    title: `${course.name} — Guias de Estudo | Conheça Farmácia`,
    description: course.description || course.heroSubtitle,
    alternates: { languages: { pt: `/pt/guias/${slug}`, en: `/en/guides/${slug}` } },
  }
}

export default async function GuiaCursoPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const course = await getPublicGuideCourseBySlug(slug, safeLang)
  if (!course) notFound()

  return <GuiasCursoClient lang={safeLang} course={course} />
}
