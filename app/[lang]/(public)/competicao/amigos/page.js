import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import AmigosPageClient from './AmigosPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('friend_challenge.title') || 'Desafios entre Amigos'} | Conheça Farmácia`,
    description: tFn('friend_challenge.subtitle') || 'Desafia os teus amigos a um quiz de farmacologia!',
    robots: { index: false, follow: true },
  }
}

export default async function AmigosPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <AmigosPageClient lang={safeLang} />
}
