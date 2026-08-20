import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import CompetitionSessionClient from '@/components/pages/CompetitionSessionClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('competition.quiz_title') || 'Competição'} | Conheça Farmácia`,
    description: tFn('competition.quiz_description') || 'Quiz de farmacologia em tempo real',
    robots: { index: false, follow: true },
  }
}

export default async function CompeticaoLobbyRoute({ params }) {
  const { lang, code } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <CompetitionSessionClient lang={safeLang} code={code} />
}
