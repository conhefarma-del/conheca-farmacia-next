'use client'

import { useEffect, Suspense } from 'react'
import { usePathname } from 'next/navigation'
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

  useEffect(() => {
    if (pathname.startsWith('/admin') || pathname.startsWith('/_next') || pathname.startsWith('/api')) return

    const key = `_pv_${pathname}`
    if (sessionStorage.getItem(key)) return
    sessionStorage.setItem(key, '1')

    // MED-08: do not include the querystring in page_path. Email addresses,
    // share tokens and other PII can appear there; we only need the route
    // shape for analytics. The pathname is already available from usePathname.
    const url = pathname
    const sessionId = getSessionId()
    trackPageView(url, document.referrer, sessionId).catch(() => {})
  }, [pathname])

  return null
}

export default function PageViewTracker() {
  return (
    <Suspense fallback={null}>
      <PageViewTrackerInner />
    </Suspense>
  )
}
