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

/**
 * Buscar estatísticas do dashboard.
 * SEC-API-03: SELECT com colunas explícitas.
 */
export async function getDashboardStats() {
  const ctx = await requireAdmin()
  if (!ctx) return null

  const { supabase } = ctx

  try {
    const [
      articlesResult,
      eventsResult,
      livesResult,
      usersResult,
      categoriesResult,
    ] = await Promise.all([
      // SEC-API-03: head: true — apenas count, sem dados
      supabase
        .from('articles')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),

      supabase
        .from('events')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),

      supabase
        .from('lives')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),

      supabase
        .from('admin_users')
        .select('*', { count: 'exact', head: true }),

      // Categorias únicas — buscar apenas a coluna category
      Promise.all([
        supabase
          .from('articles')
          .select('category')
          .eq('status', 'published')
          .not('category', 'is', null),
        supabase
          .from('events')
          .select('category')
          .eq('status', 'published')
          .not('category', 'is', null),
        supabase
          .from('lives')
          .select('category')
          .eq('status', 'published')
          .not('category', 'is', null),
      ]),
    ])

    const articles = articlesResult.count || 0
    const events = eventsResult.count || 0
    const lives = livesResult.count || 0
    const users = usersResult.count || 0

    // Contar categorias únicas
    const [artCats, evtCats, liveCats] = categoriesResult
    const allCategories = [
      ...(artCats.data || []).map((r) => r.category),
      ...(evtCats.data || []).map((r) => r.category),
      ...(liveCats.data || []).map((r) => r.category),
    ].filter(Boolean)
    const uniqueCategories = new Set(allCategories).size

    return {
      articles,
      events,
      lives,
      users,
      categories: uniqueCategories,
      total: articles + events + lives,
    }
  } catch {
    return {
      articles: 0,
      events: 0,
      lives: 0,
      users: 0,
      categories: 0,
      total: 0,
    }
  }
}

/**
 * Buscar timeline de atividades recentes (audit_logs).
 * SEC-API-03: colunas explícitas.
 */
export async function getActivityTimeline(limit = 10) {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('audit_logs')
      .select('id, action, table_name, record_id, created_at, user_email, new_values')
      .order('created_at', { ascending: false })
      .limit(limit)

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Buscar contagem de page_views para um período.
 * SEC-API-03: apenas count.
 */
export async function getPageViewsByPeriod(period = 'week') {
  const ctx = await requireAdmin()
  if (!ctx) return 0

  const { supabase } = ctx

  try {
    const now = new Date()
    let startDate

    switch (period) {
      case 'day':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        break
      case 'week':
        startDate = new Date(now)
        startDate.setDate(startDate.getDate() - 7)
        break
      case 'month':
        startDate = new Date(now)
        startDate.setMonth(startDate.getMonth() - 1)
        break
      case '6months':
        startDate = new Date(now)
        startDate.setMonth(startDate.getMonth() - 6)
        break
      case 'year':
        startDate = new Date(now)
        startDate.setFullYear(startDate.getFullYear() - 1)
        break
      default:
        startDate = new Date(now)
        startDate.setDate(startDate.getDate() - 7)
    }

    const { count, error } = await supabase
      .from('page_views')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', startDate.toISOString())

    if (error) return 0
    return count || 0
  } catch {
    return 0
  }
}

/**
 * Buscar contagem de inscrições para um período.
 * SEC-API-03: apenas count.
 */
export async function getInscriptionsByPeriod(period = 'week') {
  const ctx = await requireAdmin()
  if (!ctx) return 0

  const { supabase } = ctx

  try {
    const now = new Date()
    let startDate

    switch (period) {
      case 'day':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
        break
      case 'week':
        startDate = new Date(now)
        startDate.setDate(startDate.getDate() - 7)
        break
      case 'month':
        startDate = new Date(now)
        startDate.setMonth(startDate.getMonth() - 1)
        break
      case '6months':
        startDate = new Date(now)
        startDate.setMonth(startDate.getMonth() - 6)
        break
      case 'year':
        startDate = new Date(now)
        startDate.setFullYear(startDate.getFullYear() - 1)
        break
      default:
        startDate = new Date(now)
        startDate.setDate(startDate.getDate() - 7)
    }

    const { count, error } = await supabase
      .from('inscricoes')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', startDate.toISOString())

    if (error) return 0
    return count || 0
  } catch {
    return 0
  }
}

/**
 * Buscar distribuição de categorias (articles + events + lives).
 * SEC-API-03: apenas coluna category.
 */
export async function getCategoryDistribution() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const [articlesResult, eventsResult, livesResult] = await Promise.all([
      supabase
        .from('articles')
        .select('category')
        .eq('status', 'published')
        .not('category', 'is', null),
      supabase
        .from('events')
        .select('category')
        .eq('status', 'published')
        .not('category', 'is', null),
      supabase
        .from('lives')
        .select('category')
        .eq('status', 'published')
        .not('category', 'is', null),
    ])

    const allCategories = [
      ...(articlesResult.data || []).map((r) => r.category),
      ...(eventsResult.data || []).map((r) => r.category),
      ...(livesResult.data || []).map((r) => r.category),
    ].filter(Boolean)

    const categoryCounts = {}
    allCategories.forEach((cat) => {
      categoryCounts[cat] = (categoryCounts[cat] || 0) + 1
    })

    const distribution = Object.keys(categoryCounts).map((category) => ({
      category,
      count: categoryCounts[category],
    }))

    distribution.sort((a, b) => b.count - a.count)
    return distribution
  } catch {
    return []
  }
}
