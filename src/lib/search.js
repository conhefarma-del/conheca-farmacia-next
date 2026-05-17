import { supabaseClient } from '../config.js';

/**
 * Search across all content types (articles, events, lives, admin users)
 * @param {string} query - Search query
 * @returns {Promise<{articles: Array, events: Array, lives: Array, users: Array}>}
 */
export async function searchAllContent(query) {
  try {
    if (!query || !query.trim()) {
      return { articles: [], events: [], lives: [], users: [] };
    }

    const searchTerm = `%${query.trim()}%`;

    // Search articles
    const { data: articles, error: articlesError } = await supabaseClient
      .from('articles')
      .select('id, title, slug, author_name, published_at')
      .ilike('title', searchTerm)
      .eq('status', 'published')
      .limit(10);

    if (articlesError) throw articlesError;

    // Search events
    const { data: events, error: eventsError } = await supabaseClient
      .from('events')
      .select('id, title, slug, location, date')
      .ilike('title', searchTerm)
      .eq('status', 'published')
      .limit(10);

    if (eventsError) throw eventsError;

    // Search lives
    const { data: lives, error: livesError } = await supabaseClient
      .from('lives')
      .select('id, title, slug, author_name, published_at')
      .ilike('title', searchTerm)
      .eq('status', 'published')
      .limit(10);

    if (livesError) throw livesError;

    // Search admin users
    const { data: users, error: usersError } = await supabaseClient
      .from('admin_users')
      .select('id, name, email, role')
      .ilike('name', searchTerm)
      .limit(10);

    if (usersError) throw usersError;

    return {
      articles: articles || [],
      events: events || [],
      lives: lives || [],
      users: users || []
    };
  } catch (error) {
    console.error('Error searching content:', error);
    return { articles: [], events: [], lives: [], users: [] };
  }
}
