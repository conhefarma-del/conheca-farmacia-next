'use client'

import { useState } from 'react'
import { CheckCircle2, Circle, FlaskConical, Pill } from 'lucide-react'

// Heurística simples: chip de medicamento → Pill; chip de teste/analítica → FlaskConical
function chipIcon(label) {
  return /test|analit|exame|k\+|egfr|map|glic/i.test(label) ? FlaskConical : Pill
}

export default function ProtocolStep({ step, index, done, onToggle, t }) {
  const [openDrug, setOpenDrug] = useState(null)
  return (
    <div className={`protocol-step ${done ? 'is-done' : ''}`} id={`passo-${index + 1}`}>
      <button
        className="step-check"
        onClick={onToggle}
        aria-pressed={done}
        aria-label={`${t('protocolos_detalhe.passo')} ${index + 1}`}
      >
        {done ? <CheckCircle2 size={24} aria-hidden="true" /> : <Circle size={24} aria-hidden="true" />}
      </button>
      <div className="step-number">{index + 1}</div>
      <div className="step-content">
        {step.label && <div className="step-label">{step.label}</div>}
        {(step.recommendation || step.evidence) && (
          <div className="step-badges">
            {step.recommendation && (
              <span className={`step-badge step-badge--rec-${step.recommendation}`}>
                {t(`protocolos_detalhe.recomendacao_${step.recommendation}`)}
              </span>
            )}
            {step.evidence && (
              <span className={`step-badge step-badge--ev-${step.evidence}`}>
                {t(`protocolos_detalhe.evidencia_${step.evidence}`)}
              </span>
            )}
          </div>
        )}
        <div className="step-title">{step.title}</div>
        <p className="step-body">{step.body}</p>
        {step.drugs.length > 0 && (
          <div className="step-drugs">
            {step.drugs.map((d, i) => {
              const Icon = chipIcon(d.label)
              return (
                <div key={i} className="step-drug-wrap">
                  <button
                    className={`step-drug ${openDrug === i ? 'is-open' : ''}`}
                    onClick={() => setOpenDrug(openDrug === i ? null : i)}
                    aria-expanded={openDrug === i}
                  >
                    <Icon size={13} aria-hidden="true" />
                    {d.label}
                  </button>
                  {openDrug === i && d.dose && (
                    <div className="step-drug-dose">
                      {t('protocolos_detalhe.dose')}: {d.dose}
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
