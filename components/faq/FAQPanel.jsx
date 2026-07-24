'use client'

import FAQItem from './FAQItem'

export default function FAQPanel({ questions, lang, t }) {
  return (
    <div className="faq-panel" role="tabpanel">
      {questions.length === 0 ? (
        <p className="faq-panel-empty">{t('faq_page.no_questions')}</p>
      ) : (
        questions.map((q) => (
          <FAQItem
            key={q.id}
            question={q[`question_${lang}`]}
            answer={q[`answer_${lang}`]}
            pending={q.pending}
            t={t}
          />
        ))
      )}
    </div>
  )
}
