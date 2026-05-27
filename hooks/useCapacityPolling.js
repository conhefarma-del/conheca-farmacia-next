'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'

const INITIAL_INTERVAL = 30000  // 30s
const MAX_INTERVAL = 120000     // 2min
const MAX_RETRIES = 5

/**
 * Poll inscription count for an event with exponential backoff
 */
export function useCapacityPolling(eventSlug, initialCount = 0) {
  const [inscriptionCount, setInscriptionCount] = useState(initialCount)
  const [loading, setLoading] = useState(false)
  const intervalRef = useRef(INITIAL_INTERVAL)
  const retriesRef = useRef(0)
  const timerRef = useRef(null)

  const fetchCount = useCallback(async () => {
    if (!eventSlug) return

    try {
      setLoading(true)
      const supabase = createClient()
      const { count, error } = await supabase
        .rpc('get_inscription_count', { event_slug: eventSlug })

      if (error) throw error

      setInscriptionCount(count || 0)
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
  }, [eventSlug])

  useEffect(() => {
    if (!eventSlug) return

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
  }, [eventSlug, fetchCount])

  return { inscriptionCount, loading }
}
