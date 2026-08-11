import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getScientificAuthors } from '@/lib/api/scientific-articles'
import CientificosAutoresPageClient from '@/components/pages/CientificosAutoresPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath) => t(translations, keyPath)

  return {
    title: `${tFn('cientifico_autores.title')} | Conheça Farmácia`,
    description: tFn('cientifico_autores.subtitle'),
    alternates: {
      languages: { pt: '/pt/cientificos/autores', en: '/en/cientificos/autores' },
    },
  }
}

export default async function CientificosAutoresPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let authors = []
  try {
    authors = await getScientificAuthors(safeLang)
  } catch (err) {
    console.error('Error fetching scientific authors:', err)
  }

  return <CientificosAutoresPageClient authors={authors} lang={safeLang} />
}
