'use client'

import { useEffect, useRef, useState } from 'react'
import { createClient } from '@/lib/supabase/client'

/**
 * useAnonymousSession — garante uma sessão (anónima se não existir).
 *
 * Decisão 1A do plano de flashcards: o progresso de revisão vive na cloud
 * via Supabase anonymous sign-in. Este hook:
 *  1. Lê a sessão atual (cookie).
 *  2. Se não existir, cria uma conta anónima silenciosa (signInAnonymously).
 *  3. Expõe { status, error, supabase }.
 *
 * Se o provider de contas anónimas não estiver ativo no Supabase, `status`
 * fica 'error' e a UI mostra o aviso (o review não persiste sem sessão).
 */
export function useAnonymousSession() {
  const supabaseRef = useRef(null)
  if (!supabaseRef.current) supabaseRef.current = createClient()

  const [status, setStatus] = useState('loading') // 'loading' | 'ready' | 'error'
  const [error, setError] = useState('')

  useEffect(() => {
    let cancelled = false

    const ensure = async () => {
      try {
        const { data: { session } } = await supabaseRef.current.auth.getSession()
        if (cancelled) return
        if (session) {
          setStatus('ready')
          return
        }
        const { error: signInError } = await supabaseRef.current.auth.signInAnonymously()
        if (cancelled) return
        if (signInError) {
          setStatus('error')
          setError(signInError.message)
          return
        }
        setStatus('ready')
      } catch (e) {
        if (!cancelled) {
          setStatus('error')
          setError(String(e?.message || e))
        }
      }
    }

    ensure()
    return () => {
      cancelled = true
    }
  }, [])

  return { status, error, supabase: supabaseRef.current }
}
