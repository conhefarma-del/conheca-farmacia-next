'use client'

import { useId } from 'react'
import PendingBadge from '@/components/ui/PendingBadge'
import { ChevronDown } from 'lucide-react'

export default function FAQItem({ question, answer, pending, t }) {
  const id = useId()

  if (pending) {
    return (
      <div className="faq-item faq-item--pending">
        <div className="faq-item-question">
          <span className="faq-item-text">{question}</span>
          <PendingBadge label={t('faq_page.pending_badge')} />
        </div>
        <p className="faq-item-message">{t('faq_page.pending_message')}</p>
      </div>
    )
  }

  return (
    <details className="faq-item" id={id}>
      <summary className="faq-item-summary">
        <span>{question}</span>
        <ChevronDown size={20} className="faq-item-chevron" />
      </summary>
      <div className="faq-item-answer prose prose-muted dark:prose-invert max-w-none">
        {answer}
      </div>
    </details>
  )
}
