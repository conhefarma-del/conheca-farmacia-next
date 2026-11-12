'use client'

import { useState, useEffect, useRef, useCallback } from 'react'

const INITIAL_INTERVAL = 30000  // 30s
const MAX_INTERVAL = 120000     // 2min
const MAX_RETRIES = 5

/**
 * Poll inscription count for an event with exponential backoff.
 *
 * Usa a rota pública `/api/events/[id]/capacity`, que devolve apenas um
 * número e tem cache curto (10s). Antes chamava uma Server Action por
 * visitante a cada 30s, sem cache.
 */
export function useCapacityPolling(eventId, initialCount = 0) {
  const [inscriptionCount, setInscriptionCount] = useState(initialCount)
  const [loading, setLoading] = useState(false)
  const intervalRef = useRef(INITIAL_INTERVAL)
  const retriesRef = useRef(0)
  const timerRef = useRef(null)

  const fetchCount = useCallback(async () => {
    if (!eventId) return

    try {
      setLoading(true)
      const res = await fetch(`/api/events/${eventId}/capacity`, { cache: 'no-store' })
      if (!res.ok) throw new Error('capacity fetch failed')
      const json = await res.json()

      setInscriptionCount(Number(json.count) || 0)
      intervalRef.current = INITIAL_INTERVAL
      retriesRef.current = 0
    } catch {
      retriesRef.current += 1
      if (retriesRef.current >= MAX_RETRIES) {
        intervalRef.current = MAX_INTERVAL
      } else {
        intervalRef.current = Math.min(intervalRef.current * 2, MAX_INTERVAL)
      }
    } finally {
      setLoading(false)
    }
  }, [eventId])

  useEffect(() => {
    if (!eventId) return

    const poll = () => {
      timerRef.current = setTimeout(() => {
        fetchCount().then(poll)
      }, intervalRef.current)
    }

    // Start polling
    poll()

    // Pause when tab is hidden
    const handleVisibility = () => {
      if (document.visibilityState === 'hidden') {
        clearTimeout(timerRef.current)
      } else {
        fetchCount().then(poll)
      }
    }

    document.addEventListener('visibilitychange', handleVisibility)

    return () => {
      clearTimeout(timerRef.current)
      document.removeEventListener('visibilitychange', handleVisibility)
    }
  }, [eventId, fetchCount])

  return { inscriptionCount, loading }
}
