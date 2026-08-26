'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import PrivacyTOC from '@/components/privacy/PrivacyTOC'
import PrivacyContent from '@/components/privacy/PrivacyContent'

export default function TermosPageClient({ lang, sections }) {
  const { t } = useContext(LangContext)

  return (
    <>
      {/* Hero */}
      <section className="hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t('termos_page.hero_title')}
            </h1>
            <p className="hero-subtitle text-center">
              {t('termos_page.hero_subtitle')}
            </p>
          </div>
        </div>
      </section>

      {/* Content + TOC */}
      <section className="section-padding bg-brand-bg-alt">
        <div className="container-center">
          <div className="privacy-layout">
            <aside className="privacy-layout-toc">
              <PrivacyTOC sections={sections} lang={lang} t={t} />
            </aside>
            <div className="privacy-layout-content">
              <PrivacyContent sections={sections} lang={lang} t={t} />
            </div>
          </div>
        </div>
      </section>
    </>
  )
}
