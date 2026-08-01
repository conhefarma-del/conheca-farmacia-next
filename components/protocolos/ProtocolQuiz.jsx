'use client'

import { useState } from 'react'
import { CheckCircle2, CircleHelp, XCircle } from 'lucide-react'

/**
 * Quiz "Testa-te" do protocolo — pontuação efémera (sem contas, sem persistência).
 */
export default function ProtocolQuiz({ quizzes, t }) {
  const [index, setIndex] = useState(0)
  const [selected, setSelected] = useState(null)
  const [score, setScore] = useState(0)
  const [finished, setFinished] = useState(false)

  const total = quizzes.length
  if (total === 0) return null

  const q = quizzes[index]

  const choose = (i) => {
    if (selected !== null) return
    setSelected(i)
    if (i === q.correctIndex) setScore((s) => s + 1)
  }

  const next = () => {
    if (index + 1 < total) {
      setIndex(index + 1)
      setSelected(null)
    } else {
      setFinished(true)
    }
  }

  if (finished) {
    return (
      <section className="quiz-box quiz-finished">
        <div className="quiz-heading">
          <CircleHelp size={20} aria-hidden="true" />
          {t('protocolos_detalhe.testa_te')}
        </div>
        <div className="quiz-score">
          {t('protocolos_detalhe.acertaste')} {score} {t('protocolos_detalhe.de')} {total}
        </div>
      </section>
    )
  }

  return (
    <section className="quiz-box">
      <div className="quiz-heading">
        <CircleHelp size={20} aria-hidden="true" />
        {t('protocolos_detalhe.testa_te')}
      </div>
      <div className="quiz-question">
        <span className="quiz-q-num">{index + 1}.</span> {q.question}
      </div>
      <div className="quiz-options">
        {q.options.map((opt, i) => {
          const isCorrect = selected !== null && i === q.correctIndex
          const isWrong = selected === i && i !== q.correctIndex
          const isDim = selected !== null && !isCorrect && !isWrong
          return (
            <button
              key={i}
              className={`quiz-option ${isCorrect ? 'is-correct' : ''} ${isWrong ? 'is-wrong' : ''} ${isDim ? 'is-dim' : ''}`}
              onClick={() => choose(i)}
              disabled={selected !== null}
            >
              <span className="quiz-opt-letter">{String.fromCharCode(65 + i)}</span>
              <span className="quiz-opt-text">{opt}</span>
              {isCorrect && <CheckCircle2 size={18} className="quiz-opt-icon" aria-hidden="true" />}
              {isWrong && <XCircle size={18} className="quiz-opt-icon" aria-hidden="true" />}
            </button>
          )
        })}
      </div>
      {selected !== null && (
        <div className="quiz-feedback">
          <div className={`quiz-feedback-title ${selected === q.correctIndex ? 'is-correct' : 'is-wrong'}`}>
            {selected === q.correctIndex
              ? t('protocolos_detalhe.acertaste')
              : q.options[q.correctIndex]}
          </div>
          {q.explanation && (
            <p className="quiz-explanation">
              <strong>{t('protocolos_detalhe.explicacao')}:</strong> {q.explanation}
            </p>
          )}
          <button className="quiz-next" onClick={next}>
            {index + 1 < total ? t('protocolos_detalhe.continuar') : t('protocolos_detalhe.ver_resultado')}
          </button>
        </div>
      )}
    </section>
  )
}
