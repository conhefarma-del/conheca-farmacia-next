'use client'

import { useState, useContext, useEffect, useRef } from 'react'
import { LangContext } from '@/lib/contexts'
import { createClient } from '../../lib/supabase/client'
import { sendWelcomeEmail } from '@/lib/actions/newsletter'

export default function NewsletterSection({ keys = 'artigos_page' }) {
  const { t } = useContext(LangContext)
  const [email, setEmail] = useState('')
  const [status, setStatus] = useState(null)
  const [honeypot, setHoneypot] = useState('')
  const feedbackRef = useRef(null)

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
    setStatus('loading')
    try {
      const supabase = createClient()
      const { error } = await supabase.rpc('subscribe_newsletter', {
        p_email: email.toLowerCase().trim(),
      })
      if (error) {
        if (error.message?.includes('already')) {
          setStatus('exists')
        } else {
          throw error
        }
      } else {
        setStatus('success')
        setEmail('')
        // Enviar email de boas-vindas (fire-and-forget)
        sendWelcomeEmail(email.toLowerCase().trim()).catch(() => {})
      }
    } catch {
      setStatus('error')
    }
  }

  const feedbackClasses = status === 'success'
    ? 'bg-green-100 text-green-800 border border-green-300'
    : status === 'exists'
    ? 'bg-yellow-100 text-yellow-800 border border-yellow-300'
    : status === 'error'
    ? 'bg-red-100 text-red-800 border border-red-300'
    : ''

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
              className="flex-1 min-w-[250px] px-4 py-3 rounded-lg border border-white/30 focus:outline-none focus:ring-2 focus:ring-white/50"
            />
            <button
              type="submit"
              disabled={status === 'loading'}
              className="btn btn-primary whitespace-nowrap"
            >
              {status === 'loading' ? t(`${keys}.newsletter_submitting`) || 'A subscrever...' : t(`${keys}.newsletter_submit`)}
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
          <p className="text-white/60 text-sm mt-4">
            {t(`${keys}.newsletter_privacy`)}
          </p>
        </div>
      </div>
    </section>
  )
}
