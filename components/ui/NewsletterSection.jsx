'use client'

import { useContext } from 'react'
import { LangContext } from '@/lib/contexts'
import NewsletterForm from '@/components/ui/NewsletterForm'

export default function NewsletterSection({ keys = 'artigos_page' }) {
  const { t } = useContext(LangContext)

  return (
    <section className="newsletter-section">
      <div className="container-center">
        <div className="max-w-2xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
            {t(`${keys}.newsletter_title`)}
          </h2>
          <p className="text-white/80 mb-8">
            {t(`${keys}.newsletter_subtitle`)}
          </p>
          <NewsletterForm keys={keys} variant="dark" />
          <p className="text-white/60 text-sm mt-4">
            {t(`${keys}.newsletter_privacy`)}
          </p>
        </div>
      </div>
    </section>
  )
}
