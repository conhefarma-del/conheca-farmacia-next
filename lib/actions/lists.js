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
    const { data, error } = await supabase
      .from('events')
      .select('id, slug, title, excerpt, category, category_label, image_url, status, date, time, end_time, location, type, capacity, registration_link, view_count, event_registrations(count), featured')
      .order('date', { ascending: false })

    if (error) return []
    return data || []
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
    const orderColumn = metric === 'fill' ? 'capacity' : 'view_count'

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
