import { unstable_cache } from 'next/cache'
import { createAnonClient } from '@/lib/supabase/server-anon'
import { normalizeInterview } from '@/lib/api/normalize'

const INTERVIEW_COLUMNS = 'id, slug, title, excerpt, category, category_label, interviewee, interviewer, date, read_time, video_duration, thumbnail_url, video_id, audio_url, executive_summary, pull_quotes, qa, content, references_arr, related, status, featured, view_count, meta_description'

/**
 * Anexa o slug do perfil (interview_people) a cada entrevistado das
 * entrevistas recebidas. A position da junction corresponde à ordem do
 * array JSONB `interviewee` (posição 1 = primeiro entrevistado). Cada
 * entrada ganha `slug` quando existe registo — usado para ligar os nomes
 * ao mini perfil. RLS anon expõe pessoas/links só de entrevistas publicadas
 * (as queries aqui são sempre de entrevistas publicadas).
 */
async function attachPersonSlugs(supabase, rows) {
  if (!rows || rows.length === 0) return rows
  const ids = rows.map((r) => r.id).filter(Boolean)
  const { data: links, error } = await supabase
    .from('interview_person_links')
    .select('interview_id, person_id, position')
    .in('interview_id', ids)
  if (error || !links || links.length === 0) return rows

  const personIds = [...new Set(links.map((l) => l.person_id))]
  const { data: people } = await supabase
    .from('interview_people')
    .select('id, slug')
    .in('id', personIds)

  const slugById = new Map((people || []).map((p) => [p.id, p.slug]))
  const byInterview = new Map()
  for (const l of links) {
    if (!byInterview.has(l.interview_id)) byInterview.set(l.interview_id, new Map())
    byInterview.get(l.interview_id).set(l.position, slugById.get(l.person_id))
  }

  return rows.map((r) => {
    const posMap = byInterview.get(r.id)
    if (!posMap) return r
    const raw = r.interviewee
    if (Array.isArray(raw)) {
      return {
        ...r,
        interviewee: raw.map((p, i) =>
          p && posMap.has(i + 1) ? { ...p, slug: posMap.get(i + 1) } : p
        ),
      }
    }
    if (raw && typeof raw === 'object' && Object.keys(raw).length > 0) {
      return {
        ...r,
        interviewee: { ...raw, ...(posMap.has(1) ? { slug: posMap.get(1) } : {}) },
      }
    }
    return r
  })
}

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
  const rows = await attachPersonSlugs(supabase, data || [])
  return rows.map(normalizeInterview)
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
  if (!data) return null
  const [row] = await attachPersonSlugs(supabase, [data])
  return row ? normalizeInterview(row) : null
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
  const all = await attachPersonSlugs(supabase, data || [])
  const normalized = all.map(normalizeInterview)
  const sameCat = normalized.filter((i) => i.category === category).slice(0, limit)
  if (sameCat.length === limit) return sameCat
  return [...sameCat, ...normalized.filter((i) => i.category !== category)].slice(0, limit)
  },
  ['api', 'interviews', 'related'],
  { revalidate: 3600, tags: ['interviews'] }
)

/**
 * Índice de entrevistados (mini perfis) — todas as pessoas ligadas a
 * entrevistas publicadas, com a contagem de entrevistas de cada uma.
 * A paginação/filtros vivem na página server (padrão getScientificAuthors).
 */
export const getInterviewPeople = unstable_cache(
  async () => {
  const supabase = await createAnonClient()
  const { data: people, error: pErr } = await supabase
    .from('interview_people')
    .select('id, name, slug, role, bio, avatar, avatar_bg')
    .order('name', { ascending: true })
  if (pErr) throw pErr

  const counts = new Map()
  if ((people || []).length > 0) {
    const { data: links, error: lErr } = await supabase
      .from('interview_person_links')
      .select('person_id')
    if (!lErr && links) {
      for (const l of links) {
        counts.set(l.person_id, (counts.get(l.person_id) || 0) + 1)
      }
    }
  }

  return (people || []).map((p) => ({
    id: p.id,
    name: p.name,
    slug: p.slug,
    role: p.role,
    bio: p.bio,
    avatar: p.avatar,
    avatarBg: p.avatar_bg || '#00493a',
    interviewCount: counts.get(p.id) || 0,
  }))
  },
  ['api', 'interviews', 'people'],
  { revalidate: 3600, tags: ['interviews'] }
)

/**
 * Mini perfil de um entrevistado — resolve pelo slug ÚNICO do registo
 * (interview_people.slug, desambiguado) e devolve o perfil consolidado +
 * todas as entrevistas publicadas onde aparece, por data DESC.
 */
export const getInterviewPerson = unstable_cache(
  async (slug) => {
  const supabase = await createAnonClient()
  const { data: personRow, error: pErr } = await supabase
    .from('interview_people')
    .select('id, name, slug, role, bio, avatar, avatar_bg')
    .eq('slug', slug)
    .maybeSingle()
  if (pErr) throw pErr
  if (!personRow) return null

  const { data: links, error: lErr } = await supabase
    .from('interview_person_links')
    .select('interview_id, position')
    .eq('person_id', personRow.id)
    .order('position', { ascending: true })
  if (lErr) throw lErr

  let interviews = []
  const ids = (links || []).map((l) => l.interview_id)
  if (ids.length > 0) {
    const { data: rows, error: ivErr } = await supabase
      .from('interviews')
      .select(INTERVIEW_COLUMNS)
      .eq('status', 'published')
      .eq('is_archived', false)
      .in('id', ids)
      .order('date', { ascending: false })
    if (!ivErr && rows) interviews = rows.map(normalizeInterview)
  }

  return {
    person: {
      id: personRow.id,
      name: personRow.name,
      slug: personRow.slug,
      role: personRow.role,
      bio: personRow.bio,
      avatar: personRow.avatar,
      avatarBg: personRow.avatar_bg || '#00493a',
      interviewCount: interviews.length,
    },
    interviews,
  }
  },
  ['api', 'interviews', 'person-by-slug'],
  { revalidate: 3600, tags: ['interviews'] }
)
