import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import FriendChallengeClient from './FriendChallengeClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('friend_challenge.lobby_title') || 'Desafio'} | Conheça Farmácia`,
    robots: { index: false, follow: true },
  }
}

export default async function FriendChallengeCodePage({ params }) {
  const { lang, code } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <FriendChallengeClient lang={safeLang} code={code} />
}
