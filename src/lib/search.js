import { supabaseClient } from '../config.js';

/**
 * Search across public content types (articles, events, lives)
 * @param {string} query - Search query
 * @returns {Promise<{articles: Array, events: Array, lives: Array}>}
 */
export async function searchAllContent(query) {
  try {
    if (!query || !query.trim()) {
      return { articles: [], events: [], lives: [] };
    }

    const searchTerm = `%${query.trim()}%`;

    const [articlesResult, eventsResult, livesResult] = await Promise.all([
      supabaseClient
        .from('articles')
        .select('id, title, slug, author_name, published_at')
        .ilike('title', searchTerm)
        .eq('status', 'published')
        .limit(10),
      supabaseClient
        .from('events')
        .select('id, title, slug, location, date')
        .ilike('title', searchTerm)
        .eq('status', 'published')
        .limit(10),
      supabaseClient
        .from('lives')
        .select('id, title, slug, author_name, published_at')
        .ilike('title', searchTerm)
        .eq('status', 'published')
        .limit(10)
    ]);

    return {
      articles: articlesResult.data || [],
      events: eventsResult.data || [],
      lives: livesResult.data || []
    };
  } catch (error) {
    return { articles: [], events: [], lives: [] };
  }
}
