'use client'

import { useEffect, Suspense } from 'react'
import { usePathname, useSearchParams } from 'next/navigation'
import { trackPageView } from '@/lib/api/analytics'

function getSessionId() {
  try {
    let sid = sessionStorage.getItem('_pv_session_id')
    if (!sid) {
      sid = crypto.randomUUID()
      sessionStorage.setItem('_pv_session_id', sid)
    }
    return sid
  } catch { return crypto.randomUUID() }
}

function PageViewTrackerInner() {
  const pathname = usePathname()
  const searchParams = useSearchParams()

  useEffect(() => {
    if (pathname.startsWith('/admin') || pathname.startsWith('/_next') || pathname.startsWith('/api')) return

    const key = `_pv_${pathname}`
    if (sessionStorage.getItem(key)) return
    sessionStorage.setItem(key, '1')

    const url = pathname + (searchParams.toString() ? `?${searchParams}` : '')
    const sessionId = getSessionId()
    trackPageView(url, document.referrer, sessionId).catch(() => {})
  }, [pathname, searchParams])

  return null
}

export default function PageViewTracker() {
  return (
    <Suspense fallback={null}>
      <PageViewTrackerInner />
    </Suspense>
  )
}
