'use server'

import { createClient } from '@/lib/supabase/server'

/**
 * SEC-ATH-02: Helper — verifica sessão + admin_users.
 */
async function requireAdmin() {
  const supabase = await createClient()
  const { data: { user }, error: authError } = await supabase.auth.getUser()

  if (authError || !user) return null

  const { data: adminUser, error: adminError } = await supabase
    .from('admin_users')
    .select('user_id')
    .eq('user_id', user.id)
    .single()

  if (adminError || !adminUser) return null

  return { supabase, user }
}

// ============================================================
//  ARTIGOS — List + Stats + Analytics
// ============================================================

/**
 * Buscar todos os artigos para admin (incluindo drafts).
 * SEC-API-03: colunas explícitas.
 */
export async function getAllArticlesAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('articles')
      .select('id, slug, title, excerpt, category, category_label, image_url, status, author_name, author_role, published_date, read_time, view_count, share_count, total_reading_time, featured')
      .order('published_date', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Estatísticas de artigos (total, published, drafts).
 */
export async function getArticleStats() {
  const ctx = await requireAdmin()
  if (!ctx) return { total: 0, published: 0, drafts: 0 }

  const { supabase } = ctx

  try {
    const [totalResult, publishedResult] = await Promise.all([
      supabase
        .from('articles')
        .select('*', { count: 'exact', head: true }),
      supabase
        .from('articles')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),
    ])

    const total = totalResult.count || 0
    const published = publishedResult.count || 0

    return { total, published, drafts: total - published }
  } catch {
    return { total: 0, published: 0, drafts: 0 }
  }
}

/**
 * Top artigos por métrica (views, shares, reading time).
 * SEC-API-03: colunas explícitas.
 */
export async function getTopArticles(metric = 'views', limit = 3) {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const orderColumn = metric === 'shares'
      ? 'share_count'
      : metric === 'reading'
        ? 'total_reading_time'
        : 'view_count'

    const { data, error } = await supabase
      .from('articles')
      .select(`title, slug, ${orderColumn}`)
      .eq('status', 'published')
      .order(orderColumn, { ascending: false })
      .limit(limit)

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

// ============================================================
//  EVENTOS — List + Stats + Analytics
// ============================================================

/**
 * Buscar todos os eventos para admin (incluindo drafts).
 * SEC-API-03: colunas explícitas.
 */
export async function getAllEventsAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data: events, error } = await supabase
      .from('events')
      .select('id, slug, title, excerpt, category, category_label, image_url, status, date, time, end_time, location, type, capacity, registration_link, view_count, featured')
      .order('date', { ascending: false })

    if (error) return []

    // Contar inscrições por evento a partir da tabela inscricoes
    const slugs = (events || []).map(e => e.slug).filter(Boolean)
    if (slugs.length === 0) return events || []

    const { data: inscricoes } = await supabase
      .from('inscricoes')
      .select('evento_slug')
      .in('evento_slug', slugs)

    // Contar por slug
    const countMap = {}
    for (const row of inscricoes || []) {
      countMap[row.evento_slug] = (countMap[row.evento_slug] || 0) + 1
    }

    return (events || []).map(e => ({
      ...e,
      inscricoes_count: countMap[e.slug] || 0,
    }))
  } catch {
    return []
  }
}

/**
 * Estatísticas de eventos.
 */
export async function getEventStats() {
  const ctx = await requireAdmin()
  if (!ctx) return { total: 0, published: 0, drafts: 0 }

  const { supabase } = ctx

  try {
    const [totalResult, publishedResult] = await Promise.all([
      supabase
        .from('events')
        .select('*', { count: 'exact', head: true }),
      supabase
        .from('events')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),
    ])

    const total = totalResult.count || 0
    const published = publishedResult.count || 0

    return { total, published, drafts: total - published }
  } catch {
    return { total: 0, published: 0, drafts: 0 }
  }
}

/**
 * Top eventos por métrica.
 */
export async function getTopEvents(metric = 'views', limit = 3) {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    if (metric === 'fill') {
      // Buscar eventos com capacidade
      const { data: events, error } = await supabase
        .from('events')
        .select('title, slug, capacity')
        .eq('status', 'published')
        .not('capacity', 'is', null)
        .gt('capacity', 0)

      if (error) return []
      if (!events || events.length === 0) return []

      // Contar inscrições por evento
      const slugs = events.map(e => e.slug).filter(Boolean)
      const { data: inscricoes } = await supabase
        .from('inscricoes')
        .select('evento_slug')
        .in('evento_slug', slugs)

      const countMap = {}
      for (const row of inscricoes || []) {
        countMap[row.evento_slug] = (countMap[row.evento_slug] || 0) + 1
      }

      // Calcular percentagem de lotação
      const withFill = events.map(e => ({
        ...e,
        fill_percentage: Math.round(((countMap[e.slug] || 0) / e.capacity) * 100),
      }))

      // Ordenar por lotação decrescente e limitar
      withFill.sort((a, b) => b.fill_percentage - a.fill_percentage)
      return withFill.slice(0, limit)
    }

    const orderColumn = 'view_count'

    const { data, error } = await supabase
      .from('events')
      .select(`title, slug, ${orderColumn}`)
      .eq('status', 'published')
      .order(orderColumn, { ascending: false })
      .limit(limit)

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

// ============================================================
//  LIVES — List + Stats + Analytics
// ============================================================

/**
 * Buscar todas as lives para admin (incluindo drafts).
 * SEC-API-03: colunas explícitas.
 */
export async function getAllLivesAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('lives')
      .select('id, slug, title, excerpt, category, category_label, image_url, status, date, time, end_time, platform, access_link, view_count, access_count, download_count, featured')
      .order('date', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Estatísticas de lives.
 */
export async function getLiveStats() {
  const ctx = await requireAdmin()
  if (!ctx) return { total: 0, published: 0, drafts: 0 }

  const { supabase } = ctx

  try {
    const [totalResult, publishedResult] = await Promise.all([
      supabase
        .from('lives')
        .select('*', { count: 'exact', head: true }),
      supabase
        .from('lives')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),
    ])

    const total = totalResult.count || 0
    const published = publishedResult.count || 0

    return { total, published, drafts: total - published }
  } catch {
    return { total: 0, published: 0, drafts: 0 }
  }
}

/**
 * Top lives por métrica.
 */
export async function getTopLives(metric = 'views', limit = 3) {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const orderColumn = metric === 'access'
      ? 'access_count'
      : metric === 'downloads'
        ? 'download_count'
        : 'view_count'

    const { data, error } = await supabase
      .from('lives')
      .select(`title, slug, ${orderColumn}`)
      .eq('status', 'published')
      .order(orderColumn, { ascending: false })
      .limit(limit)

    if (error) return []
    return data || []
  } catch {
    return []
  }
}
