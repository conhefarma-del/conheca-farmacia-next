import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import ClaimClient from './claimClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('competition.claim_title') || 'Guardar Progresso'} | Conheça Farmácia`,
    robots: { index: false, follow: true },
  }
}

export default async function ClaimRoute({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  return <ClaimClient lang={safeLang} />
}
