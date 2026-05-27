import { createClient } from '@/lib/supabase/server'
import { normalizeLive } from '@/lib/api/normalize'

const LIVE_COLUMNS = 'id, slug, title, excerpt, category, category_label, image_url, date, time, end_time, platform, access_link, meeting_id, password, materials, status, featured, host_name, host_role, host_organization, view_count, access_count, download_count'

export async function getLives() {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('lives')
    .select(LIVE_COLUMNS)
    .eq('status', 'published')
    .order('date', { ascending: true })

  if (error) throw error
  return (data || []).map(normalizeLive)
}

export async function getLiveBySlug(slug) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('lives')
    .select(LIVE_COLUMNS)
    .eq('slug', slug)
    .eq('status', 'published')
    .single()

  if (error) return null
  return data ? normalizeLive(data) : null
}

export async function getFeaturedLives(limit = 2) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('lives')
    .select(LIVE_COLUMNS)
    .eq('status', 'published')
    .eq('featured', true)
    .order('date', { ascending: true })
    .limit(limit)

  if (error) throw error
  return (data || []).map(normalizeLive)
}
