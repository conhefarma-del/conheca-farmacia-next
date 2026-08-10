'use client'

import { useContext } from 'react'
import { ChevronDown } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { INTERACOES_FAQ_ITEMS } from '@/lib/interacoes-faq'

// Ao abrir um <details>, garante que o conteúdo expandido fica visível no ecrã
// (scroll mínimo até ao item, sem "saltos" bruscos).
function scrollDetailsIntoView(e) {
  if (e.currentTarget.open) {
    e.currentTarget.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
  }
}

// Secção FAQ da calculadora /interacoes — lazy-loaded via next/dynamic porque
// fica abaixo da dobra e o conteúdo é estático (i18n).
export default function InteracoesFaq() {
  const { t } = useContext(LangContext)
  return (
    <div className="interacoes-faq section-padding">
      <div className="container-center max-w-3xl">
        <div className="section-heading text-center mb-8">
          <h2 className="text-3xl md:text-4xl font-bold text-brand-deep">
            {t('interacoes_faq.title')}
          </h2>
          <p className="hero-subtitle text-center">{t('interacoes_faq.subtitle')}</p>
        </div>
        <div className="faq-tabs">
          {INTERACOES_FAQ_ITEMS.map((item) => (
            <details className="faq-item" key={item.q} onToggle={scrollDetailsIntoView}>
              <summary className="faq-item-summary">
                <span>{t(item.q)}</span>
                <ChevronDown size={20} className="faq-item-chevron" />
              </summary>
              <div className="faq-item-answer prose prose-muted dark:prose-invert max-w-none">
                {t(item.a)}
              </div>
            </details>
          ))}
        </div>
      </div>
    </div>
  )
}
