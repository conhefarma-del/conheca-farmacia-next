import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getInterviews } from '@/lib/api/interviews'
import EntrevistasPageClient from '@/components/pages/EntrevistasPageClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('entrevistas_page.hero_title')} | Conheça Farmácia`,
    description: tFn('entrevistas_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/entrevistas', en: '/en/entrevistas' } },
  }
}

export default async function EntrevistasPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  let interviews = []
  try {
    interviews = await getInterviews()
  } catch (err) {
    console.error('Error fetching interviews:', err)
  }

  return (
    <EntrevistasPageClient
      interviews={interviews}
      lang={safeLang}
    />
  )
}
