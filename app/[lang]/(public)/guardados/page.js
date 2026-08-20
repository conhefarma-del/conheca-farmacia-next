import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import SavedPageClient from './SavedPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('saved.title') || 'Guardados'} | Conheça Farmácia`,
    description: tFn('saved.empty_hint') || 'Guarda medicamentos, interações e mais para consultar rapidamente',
    robots: { index: false, follow: true },
  }
}

export default async function GuardadosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <SavedPageClient lang={safeLang} />
}
