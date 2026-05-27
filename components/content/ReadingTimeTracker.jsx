'use client'

import { useEffect, useRef } from 'react'
import { addReadingTime } from '@/lib/api/analytics'

export default function ReadingTimeTracker({ articleId }) {
  const secondsRef = useRef(0)
  const intervalRef = useRef(null)

  useEffect(() => {
    if (!articleId) return

    const trackTime = () => {
      secondsRef.current += 30
      addReadingTime(articleId, 30).catch(() => {})
    }

    intervalRef.current = setInterval(trackTime, 30000)

    const handleVisibility = () => {
      if (document.hidden) {
        clearInterval(intervalRef.current)
        intervalRef.current = null
      } else if (!intervalRef.current) {
        intervalRef.current = setInterval(trackTime, 30000)
      }
    }

    document.addEventListener('visibilitychange', handleVisibility)

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current)
      document.removeEventListener('visibilitychange', handleVisibility)
    }
  }, [articleId])

  return null
}
