'use client'

import { createClient } from '@/lib/supabase/client'

/**
 * Search across public content types (articles, events, lives)
 * Returns all matching results — client-side handles pagination.
 *
 * @param {string} query
 * @param {string} type - 'todos'|'artigos'|'eventos'|'lives'
 * @param {string} order - 'recente'|'antigo'
 */
export async function searchAllContent(query, type = 'todos', order = 'recente') {
  if (!query || !query.trim()) {
    return { articles: [], events: [], lives: [], total: 0 }
  }

  const supabase = createClient()
  const searchTerm = `%${query.trim()}%`
  const ascending = order === 'antigo'

  const queries = []

  // Articles
  if (type === 'todos' || type === 'artigos') {
    queries.push(
      supabase
        .from('articles')
        .select('id, title, slug, excerpt, image_url, category_label, author_name, published_date')
        .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
        .eq('status', 'published')
        .order('published_date', { ascending })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Events
  if (type === 'todos' || type === 'eventos') {
    queries.push(
      supabase
        .from('events')
        .select('id, title, slug, excerpt, image_url, category_label, location, date')
        .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
        .eq('status', 'published')
        .order('date', { ascending })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Lives
  if (type === 'todos' || type === 'lives') {
    queries.push(
      supabase
        .from('lives')
        .select('id, title, slug, excerpt, image_url, platform, date')
        .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
        .eq('status', 'published')
        .order('date', { ascending })
    )
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  const [articlesRes, eventsRes, livesRes] = await Promise.all(queries)

  const articles = articlesRes.data || []
  const events = eventsRes.data || []
  const lives = livesRes.data || []

  return {
    articles,
    events,
    lives,
    total: articles.length + events.length + lives.length,
  }
}
