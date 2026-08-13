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
      .select('id, slug, title, excerpt, category, category_label, image_url, status, author_name, author_role, published_date, read_time, view_count, share_count, total_reading_time, featured, is_archived, archived_at, archived_by')
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
    const [totalResult, publishedResult, archivedResult] = await Promise.all([
      supabase
        .from('articles')
        .select('*', { count: 'exact', head: true }),
      supabase
        .from('articles')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),
      supabase
        .from('articles')
        .select('*', { count: 'exact', head: true })
        .eq('is_archived', true),
    ])

    const total = totalResult.count || 0
    const published = publishedResult.count || 0
    const archived = archivedResult.count || 0

    return { total, published, drafts: total - published, archived }
  } catch {
    return { total: 0, published: 0, drafts: 0, archived: 0 }
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
      .select('id, slug, title, excerpt, category, category_label, image_url, status, date, time, end_time, location, type, capacity, registration_link, view_count, featured, is_archived, archived_at, archived_by')
      .order('date', { ascending: false })

    if (error) return []

    // Contar inscrições por evento a partir da tabela inscricoes (FK by evento_id UUID)
    const ids = (events || []).map(e => e.id).filter(Boolean)
    if (ids.length === 0) return events || []

    const { data: inscricoes } = await supabase
      .from('inscricoes')
      .select('evento_id')
      .in('evento_id', ids)

    // Contar por id
    const countMap = {}
    for (const row of inscricoes || []) {
      countMap[row.evento_id] = (countMap[row.evento_id] || 0) + 1
    }

    return (events || []).map(e => ({
      ...e,
      inscricoes_count: countMap[e.id] || 0,
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
    const [totalResult, publishedResult, archivedResult] = await Promise.all([
      supabase
        .from('events')
        .select('*', { count: 'exact', head: true }),
      supabase
        .from('events')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),
      supabase
        .from('events')
        .select('*', { count: 'exact', head: true })
        .eq('is_archived', true),
    ])

    const total = totalResult.count || 0
    const published = publishedResult.count || 0
    const archived = archivedResult.count || 0

    return { total, published, drafts: total - published, archived }
  } catch {
    return { total: 0, published: 0, drafts: 0, archived: 0 }
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

      // Contar inscrições por evento (FK by evento_id UUID)
      const ids = events.map(e => e.id).filter(Boolean)
      const { data: inscricoes } = await supabase
        .from('inscricoes')
        .select('evento_id')
        .in('evento_id', ids)

      const countMap = {}
      for (const row of inscricoes || []) {
        countMap[row.evento_id] = (countMap[row.evento_id] || 0) + 1
      }

      // Calcular percentagem de lotação
      const withFill = events.map(e => ({
        ...e,
        fill_percentage: Math.round(((countMap[e.id] || 0) / e.capacity) * 100),
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
      .select('id, slug, title, excerpt, category, category_label, image_url, status, date, time, end_time, platform, access_link, view_count, access_count, download_count, featured, is_archived, archived_at, archived_by')
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
    const [totalResult, publishedResult, archivedResult] = await Promise.all([
      supabase
        .from('lives')
        .select('*', { count: 'exact', head: true }),
      supabase
        .from('lives')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published'),
      supabase
        .from('lives')
        .select('*', { count: 'exact', head: true })
        .eq('is_archived', true),
    ])

    const total = totalResult.count || 0
    const published = publishedResult.count || 0
    const archived = archivedResult.count || 0

    return { total, published, drafts: total - published, archived }
  } catch {
    return { total: 0, published: 0, drafts: 0, archived: 0 }
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

// ============================================================
//  ENTREVISTAS — Lista para CMS (Módulo de Entrevistas, migration 152)
// ============================================================

export async function getAllInterviewsAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('interviews')
      .select('id, slug, title, excerpt, category, category_label, interviewee, date, read_time, video_duration, video_id, status, featured, is_archived, archived_at, archived_by, view_count')
      .order('date', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

export async function getInterviewStats() {
  const ctx = await requireAdmin()
  if (!ctx) return { total: 0, published: 0, drafts: 0, archived: 0 }

  const { supabase } = ctx

  try {
    const [totalResult, publishedResult, archivedResult] = await Promise.all([
      supabase.from('interviews').select('*', { count: 'exact', head: true }),
      supabase.from('interviews').select('*', { count: 'exact', head: true }).eq('status', 'published'),
      supabase.from('interviews').select('*', { count: 'exact', head: true }).eq('is_archived', true),
    ])

    const total = totalResult.count || 0
    const published = publishedResult.count || 0
    const archived = archivedResult.count || 0

    return { total, published, drafts: total - published, archived }
  } catch {
    return { total: 0, published: 0, drafts: 0, archived: 0 }
  }
}

// ============================================================
//  INSCRIÇÕES — Lista para CMS (Inscritos)
// ============================================================

/**
 * Todas as inscrições com dados do evento (id, title, date) para a listagem do CMS.
 * SEC-API-03: colunas explícitas. Ordenado por created_at DESC.
 * Apenas admin+.
 */
export async function getAllInscricoesAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('inscricoes')
      .select(`
        id, nome, email, telefone, profissao, created_at, evento_id, evento_slug,
        compareceu, certificado_token, certificado_emitido_at, menor_consentimento,
        evento:events ( id, title, date )
      `)
      .order('created_at', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Eventos publicados para o filtro da listagem de inscritos (apenas id + title).
 * Apenas admin+.
 */
export async function getAllEventsForFilter() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('events')
      .select('id, title')
      .order('date', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

// ============================================================
//  FLASHCARDS — Listas para CMS (decks + cartões)
// ============================================================

/**
 * Decks (todos os estados) com contagem de cartões — para a listagem admin.
 */
export async function getAllFlashcardDecksAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const [decksResult, cardsResult] = await Promise.all([
      supabase
        .from('flashcard_decks')
        .select('id, slug, name_pt, description_pt, atc_prefix, color, sort_order, status, is_archived, archived_at')
        .order('sort_order', { ascending: true }),
      supabase.from('flashcards').select('deck_id, status'),
    ])

    if (decksResult.error) return []

    const countByDeck = new Map()
    const publishedByDeck = new Map()
    for (const c of cardsResult.data || []) {
      countByDeck.set(c.deck_id, (countByDeck.get(c.deck_id) || 0) + 1)
      if (c.status === 'published') {
        publishedByDeck.set(c.deck_id, (publishedByDeck.get(c.deck_id) || 0) + 1)
      }
    }

    return (decksResult.data || []).map((d) => ({
      ...d,
      cardCount: countByDeck.get(d.id) || 0,
      publishedCount: publishedByDeck.get(d.id) || 0,
    }))
  } catch {
    return []
  }
}

/**
 * Estatísticas globais dos flashcards para o admin.
 */
export async function getFlashcardStats() {
  const ctx = await requireAdmin()
  if (!ctx) return { decks: 0, publishedDecks: 0, cards: 0, publishedCards: 0, archivedCards: 0 }

  const { supabase } = ctx

  try {
    const [decksResult, cardsResult] = await Promise.all([
      supabase.from('flashcard_decks').select('*', { count: 'exact', head: true }),
      supabase.from('flashcards').select('*', { count: 'exact', head: true }),
    ])
    const publishedDecks = await supabase
      .from('flashcard_decks')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'published')
    const publishedCards = await supabase
      .from('flashcards')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'published')
    const archivedCards = await supabase
      .from('flashcards')
      .select('*', { count: 'exact', head: true })
      .eq('is_archived', true)

    return {
      decks: decksResult.count || 0,
      publishedDecks: publishedDecks.count || 0,
      cards: cardsResult.count || 0,
      publishedCards: publishedCards.count || 0,
      archivedCards: archivedCards.count || 0,
    }
  } catch {
    return { decks: 0, publishedDecks: 0, cards: 0, publishedCards: 0, archivedCards: 0 }
  }
}

/**
 * Cartões de um deck (admin) — para a listagem de cartões no form do deck.
 */
export async function getFlashcardsByDeckAdmin(deckId) {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('flashcards')
      .select('id, deck_id, drug_id, card_type, front_pt, back_pt, source_note, status, is_archived')
      .eq('deck_id', deckId)
      .order('created_at', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Cartão por id (admin) — para o form de edição de cartão.
 */
export async function getFlashcardCardByIdAdmin(id) {
  const ctx = await requireAdmin()
  if (!ctx) return null

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('flashcards')
      .select('id, deck_id, drug_id, card_type, front_pt, front_en, back_pt, back_en, source_note, status')
      .eq('id', id)
      .single()

    if (error) return null
    return data || null
  } catch {
    return null
  }
}
