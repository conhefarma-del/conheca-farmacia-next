import { unstable_cache } from 'next/cache'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { createAdminClient } from '@/lib/supabase/admin'
import { normalizeEvent } from '@/lib/api/normalize'
import { findTranslationBySlug, mergeEntity } from '@/lib/api/translations'

const EVENT_COLUMNS = 'id, slug, title, excerpt, image_url, category, category_label, date, time, end_time, location, location_maps_url, location_maps_embed_url, type, capacity, hosts, status, featured_langs, registration_link'

/**
 * Normalize event from RPC result with inscription count
 */
export function normalizeEventWithCount(row) {
  const base = normalizeEvent(row)
  return {
    ...base,
    inscriptionCount: row.inscription_count || 0,
  }
}

/**
 * Fetch events with inscription counts, then merge with translations.
 * On PT (or when lang is omitted), behaviour is identical to the previous
 * `getEvents()` — we don't touch the RPC or its return shape, except to
 * overlay translation fields on top.
 */
export const getEventsWithInscriptionCounts = unstable_cache(
  async (lang = 'pt') => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase.rpc('get_events_with_inscription_counts')
  if (error) throw error
  const bases = (data || []).filter((e) => !e.is_archived).map(normalizeEventWithCount)

  if (lang === 'pt' || bases.length === 0) {
    return bases
  }

  const ids = bases.map((e) => e.id)
  const { data: translations, error: trErr } = await supabase
    .from('event_translations')
    .select('*')
    .eq('lang', lang)
    .in('event_id', ids)

  if (trErr) {
    console.error('getEventsWithInscriptionCounts translations fetch error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.event_id, t]))
  return bases.map((base) => mergeEntity(base, byId.get(base.id) || null, lang))
  },
  ['api', 'events', 'with-counts'],
  { revalidate: 3600, tags: ['events'] }
)

export const getEvents = unstable_cache(
  async (lang = 'pt') => {
  return getEventsWithInscriptionCounts(lang)
  },
  ['api', 'events', 'list'],
  { revalidate: 3600, tags: ['events'] }
)

export const getEventBySlug = unstable_cache(
  async (slug, lang = 'pt') => {
  const supabase = await createAnonClient()

  if (lang !== 'pt') {
    const translation = await findTranslationBySlug(supabase, 'event', slug, lang)
    if (translation) {
      const { data, error } = await supabase
        .from('events')
        .select(EVENT_COLUMNS)
        .eq('id', translation.event_id)
        .eq('status', 'published')
        .eq('is_archived', false)
        .single()
      if (!error && data) {
        return mergeEntity(normalizeEvent(data), translation, lang)
      }
    }
  }

  const { data, error } = await supabase
    .from('events')
    .select(EVENT_COLUMNS)
    .eq('slug', slug)
    .eq('status', 'published')
    .eq('is_archived', false)
    .single()

  if (error) return null
  return data ? normalizeEvent(data) : null
  },
  ['api', 'events', 'by-slug'],
  { revalidate: 3600, tags: ['events'] }
)

/**
 * Fetch featured events for the homepage, in the requested language.
 *
 * Reuses the public RPC `get_events_with_inscription_counts` (which
 * projects `featured_langs` and aggregates `inscription_count`) and
 * filters client-side by `featured_langs.includes(lang)` so a featured
 * event is only shown on the homepages of the languages it is marked for.
 *
 * On EN, merges with the translation table (mirrors `getEvents()`); on
 * PT or when no EN translation exists, returns the base PT row.
 */
export const getFeaturedEvents = unstable_cache(
  async (limit = 2, lang = 'pt') => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase.rpc('get_events_with_inscription_counts')
  if (error) throw error

  const bases = (data || [])
    .filter((e) => !e.is_archived)
    .filter((e) => Array.isArray(e.featured_langs) && e.featured_langs.includes(lang))
    .map(normalizeEventWithCount)
    .sort((a, b) => {
      // RPC already orders by date ASC; re-sort defensively in case the
      // future RPC orders differently.
      const ad = a.date || ''
      const bd = b.date || ''
      return ad.localeCompare(bd)
    })
    .slice(0, limit)

  if (lang === 'pt' || bases.length === 0) {
    return bases
  }

  // EN: merge with translation table.
  const ids = bases.map((e) => e.id)
  const { data: translations, error: trErr } = await supabase
    .from('event_translations')
    .select('*')
    .eq('lang', lang)
    .in('event_id', ids)

  if (trErr) {
    console.error('getFeaturedEvents translations fetch error:', trErr)
    return bases
  }

  const byId = new Map((translations || []).map((t) => [t.event_id, t]))
  return bases
    .map((base) => mergeEntity(base, byId.get(base.id) || null, lang))
    .filter((merged) => {
      if (lang === 'en') return merged.has_translation === true
      return true
    })
  },
  ['api', 'events', 'featured'],
  { revalidate: 3600, tags: ['events'] }
)

/**
 * Filter inscricoes by evento_id (UUID, stable across translations).
 * Uses Service Role because RLS blocks SELECT on `inscricoes` for `anon`.
 * Only returns `count` (non-PII) — mirrors the public RPC
 * `get_events_with_inscription_counts`. The admin client is never imported
 * from a Client Component.
 */
export const getEventInscriptionCount = unstable_cache(
  async (eventId) => {
  if (!eventId) return 0
  const supabase = createAdminClient()
  const { count, error } = await supabase
    .from('inscricoes')
    .select('*', { count: 'exact', head: true })
    .eq('evento_id', eventId)
  if (error) {
    console.error('getEventInscriptionCount error:', error)
    return 0
  }
  return count || 0
  },
  ['api', 'events', 'inscription-count'],
  { revalidate: 3600, tags: ['events'] }
)

export const getSimilarEvents = unstable_cache(
  async (slug, category, limit = 3) => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase
    .from('events')
    .select(EVENT_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .eq('category', category)
    .neq('slug', slug)
    .order('date', { ascending: true })
    .limit(limit)

  if (error) throw error
  return (data || []).map(normalizeEvent)
  },
  ['api', 'events', 'similar'],
  { revalidate: 3600, tags: ['events'] }
)
