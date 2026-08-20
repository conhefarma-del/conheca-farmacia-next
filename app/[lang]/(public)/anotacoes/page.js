import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import NotasPageClient from '@/components/pages/NotasPageClient'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  const ptPath = '/pt/anotacoes'
  const enPath = '/en/anotacoes'

  return {
    title: `${tFn('notes_page.title')} | Conheça Farmácia`,
    description: tFn('notes_page.empty_hint'),
    alternates: {
      canonical: safeLang === 'pt' ? ptPath : enPath,
      languages: {
        pt: ptPath,
        en: enPath,
        'x-default': '/pt/anotacoes',
      },
    },
    robots: { index: false, follow: false },
  }
}

export default async function NotasPage({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  return <NotasPageClient lang={safeLang} />
}
