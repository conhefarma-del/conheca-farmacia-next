'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import FAQTabs from '@/components/faq/FAQTabs'

export default function FAQPageClient({ lang, tabs }) {
  const { t } = useContext(LangContext)

  return (
    <>
      {/* Hero */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('faq_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('faq_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* FAQ Content */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center max-w-3xl">
          <FAQTabs tabs={tabs} lang={lang} t={t} />
        </div>
      </section>
    </>
  )
}
