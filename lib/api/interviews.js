import { unstable_cache } from 'next/cache'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { normalizeInterview } from '@/lib/api/normalize'

const INTERVIEW_COLUMNS = 'id, slug, title, excerpt, category, category_label, interviewee, interviewer, date, read_time, video_duration, thumbnail_url, video_id, audio_url, executive_summary, pull_quotes, qa, content, references_arr, related, status, featured, view_count, meta_description'

/**
 * Lista de entrevistas publicadas, ordenadas por data DESC.
 * Módulo de Entrevistas (migration 152) — apenas PT por agora.
 */
export const getInterviews = unstable_cache(
  async () => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase
    .from('interviews')
    .select(INTERVIEW_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .order('date', { ascending: false })

  if (error) throw error
  return (data || []).map(normalizeInterview)
  },
  ['api', 'interviews', 'list'],
  { revalidate: 3600, tags: ['interviews'] }
)

/**
 * Entrevista publicada por slug.
 */
export const getInterviewBySlug = unstable_cache(
  async (slug) => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase
    .from('interviews')
    .select(INTERVIEW_COLUMNS)
    .eq('slug', slug)
    .eq('status', 'published')
    .eq('is_archived', false)
    .single()

  if (error) return null
  return data ? normalizeInterview(data) : null
  },
  ['api', 'interviews', 'by-slug'],
  { revalidate: 3600, tags: ['interviews'] }
)

/**
 * Entrevistas relacionadas (pelo array `related` de slugs, ou mesma categoria).
 */
export const getRelatedInterviews = unstable_cache(
  async (slug, category, limit = 3) => {
  const supabase = await createAnonClient()
  const { data, error } = await supabase
    .from('interviews')
    .select(INTERVIEW_COLUMNS)
    .eq('status', 'published')
    .eq('is_archived', false)
    .neq('slug', slug)
    .order('date', { ascending: false })
    .limit(limit * 4)

  if (error) throw error
  const all = (data || []).map(normalizeInterview)
  const sameCat = all.filter((i) => i.category === category).slice(0, limit)
  if (sameCat.length === limit) return sameCat
  return [...sameCat, ...all.filter((i) => i.category !== category)].slice(0, limit)
  },
  ['api', 'interviews', 'related'],
  { revalidate: 3600, tags: ['interviews'] }
)
