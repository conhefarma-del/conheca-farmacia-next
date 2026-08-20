import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import CompeticaoJoinClient from './competicaoJoinClient'

export const revalidate = 0

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('competition.page_title') || 'Competição'} | Conheça Farmácia`,
    description: tFn('competition.page_description') || 'Entra numa competição de quiz de farmacologia',
    alternates: { languages: { pt: '/pt/competicao', en: '/en/competition' } },
    robots: { index: false, follow: true },
  }
}

export default async function CompeticaoPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <CompeticaoJoinClient lang={safeLang} />
}
