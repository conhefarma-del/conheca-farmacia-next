import { createClient } from '@/lib/supabase/server'
import { normalizeEvent } from '@/lib/api/normalize'
import { findTranslationBySlug, mergeEntity } from '@/lib/api/translations'

const EVENT_COLUMNS = 'id, slug, title, excerpt, image_url, category, category_label, date, time, end_time, location, type, capacity, hosts, status, featured, registration_link'

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
export async function getEventsWithInscriptionCounts(lang = 'pt') {
  const supabase = await createClient()
  const { data, error } = await supabase.rpc('get_events_with_inscription_counts')
  if (error) throw error
  const bases = (data || []).map(normalizeEventWithCount)

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
}

export async function getEvents(lang = 'pt') {
  return getEventsWithInscriptionCounts(lang)
}

export async function getEventBySlug(slug, lang = 'pt') {
  const supabase = await createClient()

  if (lang !== 'pt') {
    const translation = await findTranslationBySlug(supabase, 'event', slug, lang)
    if (translation) {
      const { data, error } = await supabase
        .from('events')
        .select(EVENT_COLUMNS)
        .eq('id', translation.event_id)
        .eq('status', 'published')
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
    .single()

  if (error) return null
  return data ? normalizeEvent(data) : null
}

export async function getFeaturedEvents(limit = 2) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('events')
    .select(EVENT_COLUMNS)
    .eq('status', 'published')
    .eq('featured', true)
    .order('date', { ascending: true })
    .limit(limit)

  if (error) throw error
  return (data || []).map(normalizeEvent)
}

export async function getSimilarEvents(slug, category, limit = 3) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('events')
    .select(EVENT_COLUMNS)
    .eq('status', 'published')
    .eq('category', category)
    .neq('slug', slug)
    .order('date', { ascending: true })
    .limit(limit)

  if (error) throw error
  return (data || []).map(normalizeEvent)
}
