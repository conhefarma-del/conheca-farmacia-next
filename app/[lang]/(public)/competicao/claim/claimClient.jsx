'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { claimSessionToAccount } from '@/lib/actions/competition'
import { CheckCircle, Loader2, AlertCircle, UserPlus } from 'lucide-react'

export default function ClaimClient({ lang }) {
  const [status, setStatus] = useState('loading') // loading → success → error
  const [error, setError] = useState('')

  useEffect(() => {
    async function claim() {
      const sessionId = localStorage.getItem('comp_session')
      if (!sessionId) {
        setStatus('error')
        setError('Nenhuma sessão encontrada')
        return
      }

      try {
        const result = await claimSessionToAccount(sessionId)
        if (result.success) {
          setStatus('success')
          localStorage.removeItem('comp_session')
        } else {
          setStatus('error')
          setError(result.error || 'Erro ao guardar progresso')
        }
      } catch {
        setStatus('error')
        setError('Erro ao conectar ao servidor')
      }
    }
    claim()
  }, [])

  return (
    <section className="py-20 bg-background">
      <div className="container-center max-w-md mx-auto px-4 text-center">
        {status === 'loading' && (
          <>
            <Loader2 size={48} className="mx-auto mb-4 text-brand-accent animate-spin" />
            <h1 className="text-2xl font-bold text-brand-deep mb-2">A guardar o teu progresso...</h1>
            <p className="text-brand-deep/60">Estamos a ligar a tua conta Google à sessão.</p>
          </>
        )}

        {status === 'success' && (
          <>
            <CheckCircle size={48} className="mx-auto mb-4 text-green-500" />
            <h1 className="text-2xl font-bold text-brand-deep mb-2">Progresso guardado!</h1>
            <p className="text-brand-deep/60 mb-6">
              A tua conta foi criada com sucesso. Receberás um email de boas-vindas em breve.
            </p>
            <Link
              href={`/${lang}`}
              className="inline-block py-3 px-6 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all"
            >
              Ir para o início
            </Link>
          </>
        )}

        {status === 'error' && (
          <>
            <AlertCircle size={48} className="mx-auto mb-4 text-red-500" />
            <h1 className="text-2xl font-bold text-brand-deep mb-2">Erro ao guardar</h1>
            <p className="text-brand-deep/60 mb-6">{error}</p>
            <Link
              href={`/${lang}`}
              className="inline-block py-3 px-6 rounded-xl bg-brand-accent text-white font-semibold hover:bg-brand-accent/90 transition-all"
            >
              Voltar ao início
            </Link>
          </>
        )}
      </div>
    </section>
  )
}
