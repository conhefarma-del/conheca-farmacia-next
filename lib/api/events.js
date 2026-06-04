import { createClient } from '@/lib/supabase/server'
import { normalizeEvent } from '@/lib/api/normalize'

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

export async function getEventsWithInscriptionCounts() {
  const supabase = await createClient()
  const { data, error } = await supabase.rpc('get_events_with_inscription_counts')
  if (error) throw error
  return (data || []).map(normalizeEventWithCount)
}

export async function getEvents() {
  return getEventsWithInscriptionCounts()
}

export async function getEventBySlug(slug) {
  const supabase = await createClient()
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

export async function getEventInscriptionCount(eventSlug) {
  const supabase = await createClient()
  const { data, error } = await supabase.rpc('get_event_inscription_count', { event_slug: eventSlug })
  if (error) return 0
  return data || 0
}

export async function getInscriptionCount(eventSlug) {
  const supabase = await createClient()
  const { count, error } = await supabase
    .from('inscricoes')
    .select('*', { count: 'exact', head: true })
    .eq('evento_slug', eventSlug)

  if (error) return 0
  return count || 0
}
