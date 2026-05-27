'use client'

import { useEffect } from 'react'
import { incrementLiveViewCount } from '@/lib/api/analytics'
import { hasTracked, markTracked } from '@/lib/analytics-dedup'

export default function LiveViewTracker({ liveSlug }) {
  useEffect(() => {
    if (!liveSlug) return
    const key = `cf_view_live_${liveSlug}`
    if (hasTracked(key)) return
    incrementLiveViewCount(liveSlug).then(() => markTracked(key)).catch(() => {})
  }, [liveSlug])

  return null
}
