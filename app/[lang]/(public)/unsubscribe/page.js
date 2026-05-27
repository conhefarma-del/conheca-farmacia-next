import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import UnsubscribeClient from '@/components/pages/UnsubscribeClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('unsubscribe.success_title')} | Conheça Farmácia`,
    description: tFn('unsubscribe.success_message'),
    robots: { index: false, follow: false },
  }
}

export default async function UnsubscribePage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  return <UnsubscribeClient lang={safeLang} />
}
