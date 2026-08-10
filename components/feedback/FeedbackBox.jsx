'use client'

import { useContext, useEffect, useRef, useState } from 'react'
import { Flag, Send, CheckCircle2, XCircle, MessageSquareText } from 'lucide-react'
import { LangContext } from '@/lib/contexts'
import { submitDrugFeedback } from '@/lib/actions/feedback'

/**
 * FeedbackBox — caixa de feedback reutilizável.
 *
 * Uso:
 *   <FeedbackBox drugId={drug.id} contexto="/pt/medicamento/x" />
 *   <FeedbackBox drugId={...} interactionType="drug_drug"
 *                interactionId={pair.id} interactionLabel="Warfarina + Aspirina"
 *                contexto={...} autoOpen />
 *
 * drugId é opcional (componente genérico — pode ser usado na calculadora
 * /interacoes, em artigos, etc.). interactionType/interactionId/
 * interactionLabel identificam a interação exata ao admin.
 */
export default function FeedbackBox({
  drugId = null,
  interactionType = null,
  interactionId = null,
  interactionLabel = null,
  contexto = null,
  autoOpen = false,
}) {
  const { t } = useContext(LangContext)
  const [open, setOpen] = useState(autoOpen)
  const [tipo, setTipo] = useState(interactionType ? 'erro' : 'outro')
  const [mensagem, setMensagem] = useState('')
  const [email, setEmail] = useState('')
  const [honeypot, setHoneypot] = useState('')
  const [sending, setSending] = useState(false)
  const [result, setResult] = useState(null) // { ok: boolean, msg: string }
  const boxRef = useRef(null)

  useEffect(() => {
    if (autoOpen && boxRef.current) {
      boxRef.current.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }
  }, [autoOpen])

  const submit = async (e) => {
    e.preventDefault()
    // Honeypot anti-spam: campo escondido preenchido por bots é rejeitado.
    if (honeypot) return
    if (sending) return
    setSending(true)
    setResult(null)

    const res = await submitDrugFeedback({
      drugId,
      interactionType,
      interactionId,
      interactionLabel,
      tipo,
      mensagem,
      email: email || null,
      contexto,
    })

    setSending(false)
    if (res.success) {
      setResult({ ok: true, msg: t('feedback.sucesso') })
      setMensagem('')
      setEmail('')
    } else {
      setResult({ ok: false, msg: res.error || t('feedback.erro') })
    }
  }

  return (
    <div className="feedback-box" ref={boxRef}>
      {!open ? (
        <button
          type="button"
          className="feedback-box-toggle"
          onClick={() => setOpen(true)}
        >
          <MessageSquareText size={16} aria-hidden="true" />
          {t('feedback.cta')}
        </button>
      ) : (
        <>
          <div className="feedback-box-heading">
            <Flag size={16} aria-hidden="true" />
            <span>
              {t('feedback.titulo')}
              {interactionLabel && (
                <span className="feedback-target"> — {interactionLabel}</span>
              )}
            </span>
            <button
              type="button"
              className="feedback-close"
              aria-label={t('feedback.fechar')}
              onClick={() => setOpen(false)}
            >
              <XCircle size={16} aria-hidden="true" />
            </button>
          </div>

          {result?.ok && (
            <p className="feedback-success" role="status">
              <CheckCircle2 size={14} aria-hidden="true" />
              {result.msg}
            </p>
          )}
          {result && !result.ok && (
            <p className="feedback-error" role="alert">
              <XCircle size={14} aria-hidden="true" />
              {result.msg}
            </p>
          )}

          {(!result || !result.ok) && (
            <form className="feedback-form" onSubmit={submit}>
              <div className="feedback-tipos" role="group" aria-label={t('feedback.tipo_label')}>
                {['erro', 'sugestao', 'outro'].map((k) => (
                  <button
                    key={k}
                    type="button"
                    className={`feedback-tipo-btn${tipo === k ? ' is-active' : ''}`}
                    aria-pressed={tipo === k}
                    onClick={() => setTipo(k)}
                  >
                    {t(`feedback.tipo_${k}`)}
                  </button>
                ))}
              </div>

              <label className="feedback-field">
                <span className="feedback-field-label">
                  {t('feedback.mensagem_label')}
                </span>
                <textarea
                  className="feedback-textarea"
                  value={mensagem}
                  onChange={(e) => setMensagem(e.target.value)}
                  rows={4}
                  maxLength={2000}
                  placeholder={t('feedback.mensagem_placeholder')}
                  required
                />
              </label>

              <label className="feedback-field">
                <span className="feedback-field-label">
                  {t('feedback.email_label')}
                  <em className="feedback-optional">{t('feedback.opcional')}</em>
                </span>
                <input
                  className="feedback-input"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  maxLength={254}
                  placeholder={t('feedback.email_placeholder')}
                />
              </label>

              {/* Honeypot anti-spam — invisível para humanos */}
              <div className="feedback-honeypot" aria-hidden="true">
                <label htmlFor="fb-company">Não preencher</label>
                <input
                  id="fb-company"
                  type="text"
                  tabIndex={-1}
                  autoComplete="off"
                  value={honeypot}
                  onChange={(e) => setHoneypot(e.target.value)}
                />
              </div>

              <button
                type="submit"
                className="feedback-submit"
                disabled={sending || mensagem.trim().length < 3}
              >
                <Send size={14} aria-hidden="true" />
                {sending ? t('feedback.enviando') : t('feedback.enviar')}
              </button>
            </form>
          )}
        </>
      )}
    </div>
  )
}
