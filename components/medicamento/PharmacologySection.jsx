'use client'

import { useContext } from 'react'
import { FlaskConical } from 'lucide-react'
import { LangContext } from '@/lib/contexts'

function PharmacologyBlock({ titleKey, text }) {
  const { t } = useContext(LangContext)
  if (!text) return null
  return (
    <div className="pharmacology-block">
      <h4 className="pharmacology-title">{t(titleKey)}</h4>
      <p>{text}</p>
    </div>
  )
}

// Secção de farmacologia da ficha do fármaco (/medicamento/[slug]) — lazy-loaded
// via next/dynamic porque fica abaixo da dobra e só existe quando o fármaco tem
// dados de farmacologia preenchidos.
export default function PharmacologySection({ drug }) {
  const { t } = useContext(LangContext)
  if (!drug?.pharmacology) return null
  return (
    <section className="medicamento-section">
      <h2 className="medicamento-section-title">
        <FlaskConical size={18} aria-hidden="true" />
        {t('medicamento_detalhe.secao_farmacologia')}
      </h2>
      <div className="medicamento-cards">
        <div className="pharmacology-grid">
          <PharmacologyBlock
            titleKey="medicamento_detalhe.farmacodinamica"
            text={drug.pharmacology.pharmacodynamics}
          />
          <PharmacologyBlock
            titleKey="medicamento_detalhe.mecanismo_acao"
            text={drug.pharmacology.mechanism}
          />
          <PharmacologyBlock
            titleKey="medicamento_detalhe.absorcao"
            text={drug.pharmacology.absorption}
          />
          <PharmacologyBlock
            titleKey="medicamento_detalhe.metabolismo"
            text={drug.pharmacology.metabolism}
          />
          <PharmacologyBlock
            titleKey="medicamento_detalhe.meia_vida"
            text={drug.pharmacology.halfLife}
          />
        </div>
      </div>
    </section>
  )
}
