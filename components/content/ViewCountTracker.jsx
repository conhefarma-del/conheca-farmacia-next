'use client'

import { useEffect } from 'react'
import { incrementViewCount } from '@/lib/api/analytics'
import { hasTracked, markTracked } from '@/lib/analytics-dedup'

export default function ViewCountTracker({ articleSlug }) {
  useEffect(() => {
    if (!articleSlug) return
    const key = `cf_view_article_${articleSlug}`
    if (hasTracked(key)) return
    incrementViewCount(articleSlug).then(() => markTracked(key)).catch(() => {})
  }, [articleSlug])

  return null
}
