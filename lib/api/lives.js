import { unstable_cache } from 'next/cache'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { normalizeLive } from '@/lib/api/normalize'
import { findTranslationBySlug, mergeEntity } from '@/lib/api/translations'

const LIVE_COLUMNS = 'id, slug, title, excerpt, category, category_label, image_url, date, time, end_time, platform, access_link, meeting_id, password, materials, status, featured_langs, hosts, topic, view_count, access_count, download_count'

export const getLives = unstable_cache(
  async (lang = 'pt') => {
  const supabase = await createAnonClient()
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
  },
  ['api', 'lives', 'list'],
  { revalidate: 3600, tags: ['lives'] }
)

export const getLiveBySlug = unstable_cache(
  async (slug, lang = 'pt') => {
  const supabase = await createAnonClient()

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
  },
  ['api', 'lives', 'by-slug'],
  { revalidate: 3600, tags: ['lives'] }
)

export const getFeaturedLives = unstable_cache(
  async (limit = 2, lang = 'pt') => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase
    .from('lives')
    .select(LIVE_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .contains('featured_langs', [lang])
    .order('date', { ascending: true })
    .limit(limit)

  if (error) throw error
  const bases = (data || []).map(normalizeLive)

  if (lang === 'pt' || bases.length === 0) {
    return bases
  }

  // EN: merge with translation table. Mirrors `getLives()`.
  const ids = bases.map((l) => l.id)
  const { data: translations, error: trErr } = await supabase
    .from('live_translations')
    .select('*')
    .eq('lang', lang)
    .in('live_id', ids)

  if (trErr) {
    console.error('getFeaturedLives translations fetch error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.live_id, t]))
  return bases
    .map((base) => mergeEntity(base, byId.get(base.id) || null, lang))
    .filter((merged) => {
      if (lang === 'en') return merged.has_translation === true
      return true
    })
  },
  ['api', 'lives', 'featured'],
  { revalidate: 3600, tags: ['lives'] }
)
