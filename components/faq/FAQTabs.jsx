'use client'

import { useState, useCallback, useRef } from 'react'
import FAQPanel from './FAQPanel'

export default function FAQTabs({ tabs, lang, t }) {
  const [activeTab, setActiveTab] = useState(0)
  const tabRefs = useRef([])
  const tabListRef = useRef(null)

  // Keyboard navigation
  const handleKeyDown = useCallback((e) => {
    let newIndex = activeTab
    if (e.key === 'ArrowRight') {
      newIndex = (activeTab + 1) % tabs.length
    } else if (e.key === 'ArrowLeft') {
      newIndex = (activeTab - 1 + tabs.length) % tabs.length
    } else {
      return
    }
    e.preventDefault()
    setActiveTab(newIndex)
    tabRefs.current[newIndex]?.focus()
  }, [activeTab, tabs.length])

  if (tabs.length === 0) {
    return (
      <div className="faq-empty">
        <p>{t('faq_page.no_questions')}</p>
      </div>
    )
  }

  const activeTabData = tabs[activeTab]
  // Filtrar apenas questions visíveis (non-pending para o público)
  const visibleQuestions = activeTabData.questions.filter((q) => !q.pending)

  return (
    <div className="faq-tabs">
      {/* Tab Bar */}
      <div
        className="faq-tab-bar"
        ref={tabListRef}
        role="tablist"
        aria-label="FAQ categories"
      >
        {tabs.map((tab, index) => (
          <button
            key={tab.id || tab.slug}
            ref={(el) => { tabRefs.current[index] = el }}
            role="tab"
            aria-selected={index === activeTab}
            aria-controls={`faq-panel-${tab.slug}`}
            tabIndex={index === activeTab ? 0 : -1}
            className={`faq-tab ${index === activeTab ? 'faq-tab--active' : ''}`}
            onClick={() => setActiveTab(index)}
            onKeyDown={handleKeyDown}
          >
            {tab[`label_${lang}`] || tab.label_pt}
          </button>
        ))}
      </div>

      {/* Tab Panel */}
      <div
        id={`faq-panel-${activeTabData.slug}`}
        role="tabpanel"
        aria-labelledby={`faq-tab-${activeTabData.slug}`}
      >
        <FAQPanel
          questions={visibleQuestions}
          lang={lang}
          t={t}
        />
      </div>
    </div>
  )
}
