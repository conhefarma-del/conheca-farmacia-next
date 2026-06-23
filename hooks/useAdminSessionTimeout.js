'use client'

import { useEffect, useRef, useCallback } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { createClient } from '../lib/supabase/client'

const IDLE_TIMEOUT = 30 * 60 * 1000 // 30 minutes
const MAX_SESSION = 4 * 60 * 60 * 1000 // 4 hours — absolute session ceiling

/**
 * useAdminSessionTimeout — SEC-ATH-03 + SEC-ATH-04
 *
 * Auto-logout after 30 minutes of inactivity OR 4 hours from session
 * start, whichever comes first. The 4h ceiling protects against
 * scenarios where the user remains "active" (e.g. a long-running
 * dashboard tab left open overnight) but should not retain elevated
 * access indefinitely.
 *
 * Resets the idle timer on user interaction (click, keydown,
 * mousemove, scroll, touchstart) — passive listeners, no perf impact.
 *
 * On logout: supabase.auth.signOut() then redirect to /[lang]/admin.
 */
export function useAdminSessionTimeout() {
  const idleTimerRef = useRef(null)
  const startRef = useRef(Date.now())
  const router = useRouter()
  const params = useParams()
  const supabase = createClient()

  const logout = useCallback(async () => {
    await supabase.auth.signOut()
    router.push(`/${params.lang}/admin`)
  }, [supabase, router, params.lang])

  const resetIdleTimer = useCallback(() => {
    if (idleTimerRef.current) clearTimeout(idleTimerRef.current)
    idleTimerRef.current = setTimeout(logout, IDLE_TIMEOUT)
  }, [logout])

  useEffect(() => {
    const events = ['click', 'keydown', 'mousemove', 'scroll', 'touchstart']
    events.forEach((evt) =>
      document.addEventListener(evt, resetIdleTimer, { passive: true })
    )
    resetIdleTimer()

    // Absolute session ceiling — poll every minute, log out if exceeded.
    // The 60s granularity is acceptable because we are enforcing a 4h
    // ceiling — a 60s slip is irrelevant at that scale.
    const sessionInterval = setInterval(() => {
      if (Date.now() - startRef.current >= MAX_SESSION) {
        clearInterval(sessionInterval)
        logout()
      }
    }, 60_000)

    return () => {
      if (idleTimerRef.current) clearTimeout(idleTimerRef.current)
      clearInterval(sessionInterval)
      events.forEach((evt) => document.removeEventListener(evt, resetIdleTimer))
    }
  }, [resetIdleTimer, logout])
}
