import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import CriarDesafioClient from './CriarDesafioClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('friend_challenge.create_title') || 'Criar Desafio'} | Conheça Farmácia`,
    description: tFn('friend_challenge.create_subtitle') || 'Configura o teu quiz e convida amigos!',
    robots: { index: false, follow: true },
  }
}

export default async function CriarDesafioPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <CriarDesafioClient lang={safeLang} />
}
