import { createClient } from '@/lib/supabase/server'
import { normalizeLive } from '@/lib/api/normalize'
import { findTranslationBySlug, mergeEntity } from '@/lib/api/translations'

const LIVE_COLUMNS = 'id, slug, title, excerpt, category, category_label, image_url, date, time, end_time, platform, access_link, meeting_id, password, materials, status, featured, host_name, host_role, host_organization, view_count, access_count, download_count'

export async function getLives(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('lives')
    .select(LIVE_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('date', { ascending: true })

  if (error) throw error
  const bases = (data || []).map(normalizeLive)

  if (lang === 'pt' || bases.length === 0) {
    return bases
  }

  const ids = bases.map((l) => l.id)
  const { data: translations, error: trErr } = await supabase
    .from('live_translations')
    .select('*')
    .eq('lang', lang)
    .in('live_id', ids)

  if (trErr) {
    console.error('getLives translations fetch error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.live_id, t]))
  return bases.map((base) => mergeEntity(base, byId.get(base.id) || null, lang))
}

export async function getLiveBySlug(slug, lang = 'pt') {
  const supabase = await createClient()

  if (lang !== 'pt') {
    const translation = await findTranslationBySlug(supabase, 'live', slug, lang)
    if (translation) {
      const { data, error } = await supabase
        .from('lives')
        .select(LIVE_COLUMNS)
        .eq('id', translation.live_id)
        .eq('status', 'published')
        .eq('is_archived', false)
        .single()
      if (!error && data) {
        return mergeEntity(normalizeLive(data), translation, lang)
      }
    }
  }

  const { data, error } = await supabase
    .from('lives')
    .select(LIVE_COLUMNS)
    .eq('slug', slug)
    .eq('status', 'published')
    .eq('is_archived', false)
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
    .eq('is_archived', false)
    .eq('featured', true)
    .order('date', { ascending: true })
    .limit(limit)

  if (error) throw error
  return (data || []).map(normalizeLive)
}
