import { supabaseClient } from '../config.js';

/**
 * Search across public content types (articles, events, lives)
 * Returns all matching results — client-side handles pagination.
 *
 * @param {string} query - Search query
 * @param {string} type - Filter: 'todos'|'artigos'|'eventos'|'lives'
 * @param {string} order - Sort: 'recente'|'antigo'
 * @returns {Promise<{articles: Array, events: Array, lives: Array, total: number}>}
 */
export async function searchAllContent(query, type = 'todos', order = 'recente') {
  try {
    if (!query || !query.trim()) {
      return { articles: [], events: [], lives: [], total: 0 };
    }

    const searchTerm = `%${query.trim()}%`;
    const ascending = order === 'antigo';

    const queries = [];

    // Articles
    if (type === 'todos' || type === 'artigos') {
      queries.push(
        supabaseClient
          .from('articles')
          .select('id, title, slug, excerpt, image_url, category_label, author_name, published_date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .order('published_date', { ascending })
      );
    } else {
      queries.push(Promise.resolve({ data: [], error: null }));
    }

    // Events
    if (type === 'todos' || type === 'eventos') {
      queries.push(
        supabaseClient
          .from('events')
          .select('id, title, slug, excerpt, image_url, category_label, location, date')
          .or(`title.ilike.${searchTerm},excerpt.ilike.${searchTerm}`)
          .eq('status', 'published')
          .order('date', { ascending })
      );
    } else {
      queries.push(Promise.resolve({ data: [], error: null }));
    }

    // Lives
    if (type === 'todos' || type === 'lives') {
      queries.push(
        supabaseClient
          .from('lives')
          .select('id, title, slug, description, image_url, date, time, platform')
          .or(`title.ilike.${searchTerm},description.ilike.${searchTerm}`)
          .eq('status', 'published')
          .order('date', { ascending })
      );
    } else {
      queries.push(Promise.resolve({ data: [], error: null }));
    }

    const [articlesResult, eventsResult, livesResult] = await Promise.all(queries);

    // Check for errors
    if (articlesResult.error) console.error('Search articles error:', articlesResult.error);
    if (eventsResult.error) console.error('Search events error:', eventsResult.error);
    if (livesResult.error) console.error('Search lives error:', livesResult.error);

    const articles = (articlesResult.data || []).map(row => ({
      id: row.id,
      title: row.title,
      slug: row.slug,
      excerpt: row.excerpt,
      imageUrl: row.image_url,
      categoryLabel: row.category_label,
      authorName: row.author_name,
      publishedDate: row.published_date
    }));

    const events = (eventsResult.data || []).map(row => ({
      id: row.id,
      title: row.title,
      slug: row.slug,
      excerpt: row.excerpt,
      imageUrl: row.image_url,
      categoryLabel: row.category_label,
      location: row.location,
      date: row.date
    }));

    const lives = (livesResult.data || []).map(row => ({
      id: row.id,
      title: row.title,
      slug: row.slug,
      excerpt: row.description,
      imageUrl: row.image_url,
      date: row.date,
      time: row.time,
      platform: row.platform
    }));

    const total = articles.length + events.length + lives.length;

    return { articles, events, lives, total };
  } catch (error) {
    console.error('searchAllContent error:', error);
    return { articles: [], events: [], lives: [], total: 0 };
  }
}
