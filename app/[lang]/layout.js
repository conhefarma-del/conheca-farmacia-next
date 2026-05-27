import { Suspense } from 'react'
import { loadTranslations, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import LangProvider from '@/components/providers/LangProvider'
import PageViewTracker from '@/components/content/PageViewTracker'

export async function generateStaticParams() {
  return SUPPORTED_LANGS.map((lang) => ({ lang }))
}

export default async function LangLayout({ children, params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)

  return (
    <LangProvider lang={safeLang} translations={translations}>
      <Suspense fallback={null}>
        <PageViewTracker />
      </Suspense>
      {children}
    </LangProvider>
  )
}
