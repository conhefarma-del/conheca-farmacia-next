'use server'

import { createClient } from '@/lib/supabase/server'

export async function incrementViewCount(articleSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_view_count', { article_slug: articleSlug })
}

export async function incrementShareCount(articleId) {
  const supabase = await createClient()
  await supabase.rpc('increment_share_count', { row_id: articleId })
}

export async function addReadingTime(articleId, seconds) {
  const supabase = await createClient()
  await supabase.rpc('add_reading_time', { row_id: articleId, seconds })
}

export async function incrementEventViewCount(eventSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_event_view_count', { event_slug: eventSlug })
}

export async function incrementLiveViewCount(liveSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_live_view_count', { live_slug: liveSlug })
}

export async function incrementLiveAccessCount(liveSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_live_access_count', { live_slug: liveSlug })
}

export async function incrementLiveDownloadCount(liveSlug) {
  const supabase = await createClient()
  await supabase.rpc('increment_live_download_count', { live_slug: liveSlug })
}

export async function trackPageView(path, referrer, sessionId) {
  const supabase = await createClient()
  await supabase.from('page_views').insert({
    page_path: path,
    referrer: referrer || null,
    session_id: sessionId,
  })
}
