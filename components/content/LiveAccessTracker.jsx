'use client'

import { useCallback } from 'react'
import { createClient } from '../../lib/supabase/client'

export function useTrackLiveAccess(liveSlug) {
  return useCallback(async () => {
    if (!liveSlug) return
    try {
      const supabase = createClient()
      await supabase.rpc('increment_live_access_count', { live_slug: liveSlug })
    } catch {}
  }, [liveSlug])
}
