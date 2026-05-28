'use client'

import { useEffect, useRef, useCallback } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { createClient } from '../lib/supabase/client'

const IDLE_TIMEOUT = 30 * 60 * 1000 // 30 minutes

export function useIdleTimeout() {
  const timerRef = useRef(null)
  const router = useRouter()
  const params = useParams()
  const supabase = createClient()

  const logout = useCallback(async () => {
    await supabase.auth.signOut()
    router.push(`/${params.lang}/admin`)
  }, [supabase, router, params.lang])

  const resetTimer = useCallback(() => {
    if (timerRef.current) clearTimeout(timerRef.current)
    timerRef.current = setTimeout(logout, IDLE_TIMEOUT)
  }, [logout])

  useEffect(() => {
    const events = ['click', 'keydown', 'mousemove', 'scroll', 'touchstart']
    events.forEach((evt) =>
      document.addEventListener(evt, resetTimer, { passive: true })
    )
    resetTimer()

    return () => {
      if (timerRef.current) clearTimeout(timerRef.current)
      events.forEach((evt) => document.removeEventListener(evt, resetTimer))
    }
  }, [resetTimer])
}
