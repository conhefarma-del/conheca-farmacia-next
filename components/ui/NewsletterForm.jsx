'use client'

import { useState, useContext, useEffect, useRef } from 'react'
import { LangContext } from '@/lib/contexts'
import { sendWelcomeEmail, subscribeNewsletterAction } from '@/lib/actions/newsletter'

/**
 * Formulário de subscrição da newsletter — reutilizável.
 *
 * Extraído de NewsletterSection (2026) para permitir inscrever-se em qualquer
 * página (ex.: homepage) sem duplicar a lógica de segurança:
 *   - honeypot anti-bot
 *   - Server Action com rate limit DB-backed (vistoria 2026-08-11)
 *   - feedback de sucesso / já subscrito / erro
 *
 * Props:
 *   keys         — prefixo i18n das chaves newsletter_* (ex.: 'home', 'artigos_page')
 *   variant      — 'light' (fundo claro) | 'dark' (fundo escuro, default)
 */
export default function NewsletterForm({ keys = 'artigos_page', variant = 'dark' }) {
  const { t } = useContext(LangContext)
  const [email, setEmail] = useState('')
  const [status, setStatus] = useState(null)
  const [honeypot, setHoneypot] = useState('')
  const feedbackRef = useRef(null)
  const submittingRef = useRef(false)

  // Auto-hide feedback after 5 seconds (matches MPA behavior)
  useEffect(() => {
    if (!status) return
    const timer = setTimeout(() => setStatus(null), 5000)
    return () => clearTimeout(timer)
  }, [status])

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (honeypot) {
      setEmail('')
      return
    }
    if (!email || !email.includes('@')) {
      setStatus('error')
      return
    }
    // Guard contra double-submit (ex.: duplo clique rápido) — o disabled
    // só bloqueia depois do primeiro re-render.
    if (submittingRef.current) return
    submittingRef.current = true
    setStatus('loading')
    try {
      // SEC (vistoria 2026-08-11): a subscrição passou a usar a Server
      // Action com rate limit DB-backed em vez do RPC direto do cliente
      // (a RPC era invocável com a anon key sem limite). A action devolve
      // o unsubscribe_token (migration 050) para o email de boas-vindas.
      const res = await subscribeNewsletterAction(email.toLowerCase().trim())
      if (res.success) {
        setStatus('success')
        setEmail('')
        sendWelcomeEmail(email.toLowerCase().trim(), res.unsubscribeToken).catch(() => {})
      } else if (res.exists) {
        setStatus('exists')
      } else {
        setStatus('error')
      }
    } catch {
      setStatus('error')
    } finally {
      submittingRef.current = false
    }
  }

  const feedbackClasses = status === 'success'
    ? variant === 'light'
      ? 'bg-green-100 text-green-800 border border-green-300'
      : 'bg-green-100 text-green-800 border border-green-300'
    : status === 'exists'
    ? 'bg-yellow-100 text-yellow-800 border border-yellow-300'
    : status === 'error'
    ? 'bg-red-100 text-red-800 border border-red-300'
    : ''

  const inputClasses = variant === 'light'
    ? 'flex-1 min-w-[250px] px-4 py-3 rounded-lg border border-brand-divider bg-white text-brand-deep placeholder:text-brand-deep/40 focus:outline-none focus:ring-2 focus:ring-brand-accent/40'
    : 'flex-1 min-w-[250px] px-4 py-3 rounded-lg border border-white/30 focus:outline-none focus:ring-2 focus:ring-white/50'

  return (
    <>
      <form onSubmit={handleSubmit} className="flex flex-col md:flex-row gap-3 items-center justify-center">
        <input
          type="text"
          name="website"
          value={honeypot}
          onChange={(e) => setHoneypot(e.target.value)}
          style={{ position: 'absolute', left: '-9999px' }}
          tabIndex={-1}
          autoComplete="off"
          aria-hidden="true"
        />
        <input
          type="email"
          value={email}
          onChange={(e) => { setEmail(e.target.value); if (status) setStatus(null) }}
          placeholder={t(`${keys}.newsletter_email_placeholder`)}
          required
          className={inputClasses}
        />
        {/* NOTA (2026-09-05): NUNCA adicionar onMouseDown que faz
            setStatus('loading') aqui. Com disabled={status === 'loading'},
            o botão fica disabled entre mousedown e mouseup e o browser
            suprime o evento click → o form nunca submete e fica preso em
            "A subscrever..." (bug em produção 24/06→05/09). O estado de
            loading já é setado no início do handleSubmit. */}
        <button
          type="submit"
          disabled={status === 'loading'}
          className="btn btn-primary whitespace-nowrap"
        >
          {status === 'loading' ? t(`${keys}.newsletter_submitting`) : t(`${keys}.newsletter_submit`)}
        </button>
      </form>
      <div
        ref={feedbackRef}
        id="newsletter-feedback"
        className={`mt-4 rounded-lg px-4 py-3 text-sm text-center ${status ? '' : 'hidden'} ${feedbackClasses}`}
      >
        {status === 'success' && <p className="font-medium">{t(`${keys}.newsletter_success`)}</p>}
        {status === 'exists' && <p className="font-medium">{t(`${keys}.newsletter_exists`)}</p>}
        {status === 'error' && <p className="font-medium">{t(`${keys}.newsletter_error`)}</p>}
      </div>
    </>
  )
}
