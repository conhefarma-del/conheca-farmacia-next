import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import PerfilClient from './perfilClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('auth.profile_title') || 'Perfil'} | Conheça Farmácia`,
    robots: { index: false, follow: true },
  }
}

export default async function PerfilPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <PerfilClient lang={safeLang} />
}
