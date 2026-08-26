'use client'

import { useState } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { Mail, KeyRound, ArrowLeft, CheckCircle } from 'lucide-react'

export default function EsqueciClient({ lang }) {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [sent, setSent] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!email) return
    setLoading(true)
    setError('')

    try {
      const supabase = createClient()
      const { error: resetError } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/${lang}/repor-palavra-passe`,
      })

      if (resetError) {
        setError(resetError.message || 'Erro ao enviar email')
        setLoading(false)
        return
      }

      setSent(true)
    } catch {
      setError('Erro ao conectar ao servidor')
    } finally {
      setLoading(false)
    }
  }

  if (sent) {
    return (
      <section className="py-20 bg-background">
        <div className="container-center max-w-md mx-auto px-4 text-center">
          <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-100 dark:bg-green-900/30 mb-6">
            <CheckCircle size={32} className="text-green-600 dark:text-green-400" />
          </div>
          <h1 className="text-2xl font-bold text-brand-deep mb-3">Email enviado!</h1>
          <p className="text-brand-deep/60 mb-2">
            Enviámos um link para repor a palavra-passe para:
          </p>
          <p className="font-medium text-brand-deep mb-6">{email}</p>
          <p className="text-sm text-brand-deep/50 mb-8">
            Verifica a tua caixa de entrada e clica no link. Se não encontrares o email, verifica a pasta de spam.
          </p>
          <Link
            href={`/${lang}/entrar`}
            className="inline-flex items-center gap-2 text-brand-accent hover:underline font-medium"
          >
            <ArrowLeft size={16} />
            Voltar ao login
          </Link>
        </div>
      </section>
    )
  }

  return (
    <section className="py-20 bg-background">
      <div className="container-center max-w-md mx-auto px-4">
        <div className="text-center mb-8">
          <KeyRound size={40} className="mx-auto mb-4 text-brand-accent" />
          <h1 className="text-3xl font-bold text-brand-deep mb-2">Esqueci a palavra-passe</h1>
          <p className="text-brand-deep/60">
            Introduz o teu email e enviámos-te um link para repor a palavra-passe.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-brand-deep mb-2">Email</label>
            <div className="relative">
              <Mail size={18} className="absolute left-3 top-1/2 -translate-y-1/2 text-brand-deep/40" />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="teu@email.com"
                className="w-full pl-10 pr-4 py-3 rounded-xl border border-brand-divider focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
                required
                autoFocus
              />
            </div>
          </div>

          {error && <p className="text-red-600 text-sm text-center">{error}</p>}

          <button
            type="submit"
            disabled={loading || !email}
            className="w-full py-3 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {loading ? (
              <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
            ) : (
              <>
                <Mail size={18} />
                Enviar link de reposição
              </>
            )}
          </button>
        </form>

        <p className="text-center text-sm text-brand-deep/60 mt-6">
          Lembra-te da password?{' '}
          <Link href={`/${lang}/entrar`} className="text-brand-accent hover:underline">
            Entrar
          </Link>
        </p>
      </div>
    </section>
  )
}
