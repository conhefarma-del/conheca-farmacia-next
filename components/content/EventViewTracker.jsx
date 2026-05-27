'use client'

import { useEffect } from 'react'
import { incrementEventViewCount } from '@/lib/api/analytics'
import { hasTracked, markTracked } from '@/lib/analytics-dedup'

export default function EventViewTracker({ eventSlug }) {
  useEffect(() => {
    if (!eventSlug) return
    const key = `cf_view_event_${eventSlug}`
    if (hasTracked(key)) return
    incrementEventViewCount(eventSlug).then(() => markTracked(key)).catch(() => {})
  }, [eventSlug])

  return null
}
