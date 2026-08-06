import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicGuideCourses } from '@/lib/actions/guides'
import GuiasPageClient from '../guias/guiasPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('guias_page.hero_title')} | Conheça Farmácia`,
    description: tFn('guias_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/guias', en: '/en/guides' } },
  }
}

export default async function GuidesPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const courses = await getPublicGuideCourses(safeLang)

  return <GuiasPageClient lang={safeLang} courses={courses} />
}