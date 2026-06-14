'use client'

import { createClient } from '../supabase/client'

/**
 * Search across public content types (articles, events, lives) in a
 * given language.
 *
 * Behaviour:
 *  - `lang === 'pt'` (or omitted): searches the base tables directly,
 *    identical to the pre-i18n implementation.
 *  - `lang === 'en'`: searches the matching translation tables, which
 *    already contain EN slugs and EN text. Each result row carries the
 *    EN slug, so the UI navigates to `/en/articles/[en-slug]`.
 *
 * @param {string} query
 * @param {'pt'|'en'} lang
 * @param {string} type - 'todos'|'artigos'|'eventos'|'lives'
 * @param {string} order - 'recente'|'antigo'
 */
export async function searchAllContent(query, lang = 'pt', type = 'todos', order = 'recente') {
  if (!query || !query.trim()) {
    return { articles: [], events: [], lives: [], total: 0 }
  }

  const supabase = createClient()
  const searchTerm = `%${query.trim()}%`
  const ascending = order === 'antigo'
  const isEn = lang === 'en'

  const queries = []

  // Articles
  if (type === 'todos' || type === 'artigos') {
    if (isEn) {
      queries.push(
        supabase
          .from('article_translations')
          .select('article_id, title, slug, excerpt, category_label')
          .eq('lang', 'en')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .order('translated_at', { ascending })
      )
    } else {
      queries.push(
        supabase
          .from('articles')
          .select('id, title, slug, excerpt, image_url, category_label, author_name, published_date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .order('published_date', { ascending })
      )
    }
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Events
  if (type === 'todos' || type === 'eventos') {
    if (isEn) {
      queries.push(
        supabase
          .from('event_translations')
          .select('event_id, title, slug, location, date')
          .eq('lang', 'en')
          .or(`title.ilike.${searchTerm},description.ilike.${searchTerm}`)
          .order('date', { ascending })
      )
    } else {
      queries.push(
        supabase
          .from('events')
          .select('id, title, slug, excerpt, image_url, category_label, location, date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .order('date', { ascending })
      )
    }
  } else {
    queries.push(Promise.resolve({ data: [], error: null }))
  }

  // Lives
  if (type === 'todos' || type === 'lives') {
    if (isEn) {
      queries.push(
        supabase
          .from('live_translations')
          .select('live_id, title, slug, topic, date')
          .eq('lang', 'en')
          .or(`title.ilike.${searchTerm},description.ilike.${searchTerm},topic.ilike.${searchTerm}`)
          .order('date', { ascending })
      )
    } else {
      queries.push(
        supabase
          .from('lives')
          .select('id, title, slug, excerpt, image_url, platform, date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .order('date', { ascending })
      )
    }
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
