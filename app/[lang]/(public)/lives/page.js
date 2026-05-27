import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getLives } from '@/lib/api/lives'
import { LIVE_CATEGORIES } from '@/lib/constants'
import LivesPageClient from '@/components/pages/LivesPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('lives_page.hero_title')} | Conheça Farmácia`,
    description: tFn('lives_page.hero_subtitle'),
    alternates: { languages: { pt: '/pt/lives', en: '/en/lives' } },
  }
}

export default async function LivesPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let lives = []
  try {
    lives = await getLives()
  } catch (err) {
    console.error('Error fetching lives:', err)
  }

  return (
    <LivesPageClient
      lives={lives}
      categories={LIVE_CATEGORIES}
      lang={safeLang}
    />
  )
}
