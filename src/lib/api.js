// src/lib/api.js
import { supabaseClient } from '../config.js';

// --- Normalization functions ---

/**
 * Format time string from Supabase (HH:MM:SS) to frontend format (HH:MM)
 */
function formatTime(time) {
  if (!time) return null;
  return time.split(':').slice(0, 2).join(':');
}

/**
 * Normalize article from Supabase (snake_case, flat) to frontend format (camelCase, nested author)
 * Also handles JSON fallback data (already in camelCase) for consistency
 */
function normalizeArticle(row) {
  const isSupabase = 'category_label' in row || 'author_name' in row;

  return {
    id: row.id || row.slug,
    slug: row.slug,
    title: row.title,
    excerpt: row.excerpt,
    category: row.category,
    categoryLabel: isSupabase ? row.category_label : row.categoryLabel,
    category_label: isSupabase ? row.category_label : row.categoryLabel,
    image: isSupabase ? row.image_url : row.image,
    content: row.content,
    status: row.status,
    author: isSupabase ? {
      name: row.author_name,
      role: row.author_role,
      bio: row.author_bio,
      avatar: row.author_avatar,
      avatarBg: row.author_avatar_bg,
    } : row.author,
    author_name: isSupabase ? row.author_name : row.author?.name,
    date: isSupabase ? row.published_date : row.date,
    published_date: isSupabase ? row.published_date : row.date,
    readTime: isSupabase ? row.read_time : row.readTime,
    references: isSupabase ? row.references_arr : row.references,
  };
}

/**
 * Normalize event from Supabase to frontend format
 */
function normalizeEvent(row) {
  const isSupabase = 'category_label' in row || 'end_time' in row;

  return {
    id: row.id || row.slug,
    slug: row.slug,
    title: row.title,
    excerpt: row.excerpt,
    category: row.category,
    categoryLabel: isSupabase ? row.category_label : row.categoryLabel,
    category_label: isSupabase ? row.category_label : row.categoryLabel,
    image: isSupabase ? row.image_url : row.image,
    date: row.date,
    time: formatTime(isSupabase ? row.time : row.time),
    endTime: formatTime(isSupabase ? row.end_time : row.endTime),
    location: row.location,
    type: row.type,
    capacity: row.capacity,
    hosts: row.hosts,
    status: row.status,
    registrationLink: isSupabase ? row.registration_link : row.registrationLink,
  };
}

/**
 * Normalize live from Supabase (English snake_case) to frontend format (Portuguese names)
 * The live-detail.js uses Portuguese property names (titulo, hora, etc.)
 */
function normalizeLive(row) {
  const isSupabase = 'category_label' in row || 'host_name' in row;

  if (isSupabase) {
    return {
      slug: row.slug,
      id: row.id || row.slug,
      title: row.title,
      titulo: row.title,
      resumo: row.excerpt,
      category: row.category,
      categoria: row.category,
      category_label: row.category_label,
      categoriaLabel: row.category_label,
      image: row.image_url,
      imagem: row.image_url,
      date: row.date,
      data: row.date,
      hora: formatTime(row.time),
      hora_termino: formatTime(row.end_time),
      platform: row.platform,
      plataforma: row.platform,
      link_acesso: row.access_link,
      id_reuniao: row.meeting_id,
      senha: row.password,
      materiais_apoio: row.materials,
      status: row.status,
      anfitriao: {
        nome: row.host_name,
        cargo: row.host_role,
        organizacao: row.host_organization,
      },
    };
  }

  // JSON fallback — already in Portuguese format, just format times
  return {
    ...row,
    hora: formatTime(row.hora),
    hora_termino: row.hora_termino ? formatTime(row.hora_termino) : null,
  };
}

// --- API functions ---

/**
 * Fetch published articles from Supabase
 * @returns {Promise<Array>}
 */
export async function getArticles() {
  try {
    const { data, error } = await supabaseClient
      .from('articles')
      .select('*')
      .eq('status', 'published')
      .order('published_date', { ascending: false });

    if (error) throw error;
    return (data || []).map(normalizeArticle);
  } catch (error) {
    console.error('Error fetching articles:', error);
    const { getFallbackArticles } = await import('./fallback-data.js');
    return getFallbackArticles().map(normalizeArticle);
  }
}

/**
 * Fetch single article by slug
 * @param {string} slug
 * @returns {Promise<Object|null>}
 */
export async function getArticleBySlug(slug) {
  try {
    const { data, error } = await supabaseClient
      .from('articles')
      .select('*')
      .eq('slug', slug)
      .eq('status', 'published')
      .single();

    if (error) throw error;
    return data ? normalizeArticle(data) : null;
  } catch (error) {
    console.error('Error fetching article:', error);
    const { getFallbackArticleBySlug } = await import('./fallback-data.js');
    const fallback = getFallbackArticleBySlug(slug);
    return fallback ? normalizeArticle(fallback) : null;
  }
}

/**
 * Fetch published events from Supabase
 * @returns {Promise<Array>}
 */
export async function getEvents() {
  try {
    const { data, error } = await supabaseClient
      .from('events')
      .select('*')
      .eq('status', 'published')
      .order('date', { ascending: true });

    if (error) throw error;
    return (data || []).map(normalizeEvent);
  } catch (error) {
    console.error('Error fetching events:', error);
    const { getFallbackEvents } = await import('./fallback-data.js');
    return getFallbackEvents().map(normalizeEvent);
  }
}

/**
 * Fetch single event by slug
 * @param {string} slug
 * @returns {Promise<Object|null>}
 */
export async function getEventBySlug(slug) {
  try {
    const { data, error } = await supabaseClient
      .from('events')
      .select('*')
      .eq('slug', slug)
      .eq('status', 'published')
      .single();

    if (error) throw error;
    return data ? normalizeEvent(data) : null;
  } catch (error) {
    console.error('Error fetching event:', error);
    const { getFallbackEventBySlug } = await import('./fallback-data.js');
    const fallback = getFallbackEventBySlug(slug);
    return fallback ? normalizeEvent(fallback) : null;
  }
}

/**
 * Fetch published lives from Supabase
 * @returns {Promise<Array>}
 */
export async function getLives() {
  try {
    const { data, error } = await supabaseClient
      .from('lives')
      .select('id, slug, title, excerpt, category, category_label, image_url, date, time, end_time, platform, access_link, materials, status, host_name, host_role, host_organization, view_count, access_count, download_count, published_at')
      .eq('status', 'published')
      .order('date', { ascending: true });

    if (error) throw error;
    return (data || []).map(normalizeLive);
  } catch (error) {
    console.error('Error fetching lives:', error);
    const { getFallbackLives } = await import('./fallback-data.js');
    return getFallbackLives().map(normalizeLive);
  }
}

/**
 * Fetch single live by slug
 * @param {string} slug
 * @returns {Promise<Object|null>}
 */
export async function getLiveBySlug(slug) {
  try {
    const { data, error } = await supabaseClient
      .from('lives')
      .select('id, slug, title, excerpt, category, category_label, image_url, date, time, end_time, platform, access_link, materials, status, host_name, host_role, host_organization, view_count, access_count, download_count, published_at')
      .eq('slug', slug)
      .eq('status', 'published')
      .single();

    if (error) throw error;
    return data ? normalizeLive(data) : null;
  } catch (error) {
    console.error('Error fetching live:', error);
    const { getFallbackLiveBySlug } = await import('./fallback-data.js');
    const fallback = getFallbackLiveBySlug(slug);
    return fallback ? normalizeLive(fallback) : null;
  }
}

/**
 * Fetch count of published articles from Supabase
 * @returns {Promise<number>}
 */
export async function getPublishedArticlesCount() {
  try {
    const { count, error } = await supabaseClient
      .from('articles')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'published');

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching published articles count:', error);
    return 0;
  }
}

/**
 * Fetch count of published events from Supabase
 * @returns {Promise<number>}
 */
export async function getPublishedEventsCount() {
  try {
    const { count, error } = await supabaseClient
      .from('events')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'published');

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching published events count:', error);
    return 0;
  }
}

/**
 * Fetch count of published lives from Supabase
 * @returns {Promise<number>}
 */
export async function getPublishedLivesCount() {
  try {
    const { count, error } = await supabaseClient
      .from('lives')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'published');

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching published lives count:', error);
    return 0;
  }
}

/**
 * Fetch count of admin users from Supabase
 * @returns {Promise<number>}
 */
export async function getAdminUsersCount() {
  try {
    const { count, error } = await supabaseClient
      .from('admin_users')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'active');

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching admin users count:', error);
    return 0;
  }
}

/**
 * Fetch count of newsletter subscribers from Supabase
 * @returns {Promise<number>}
 */
export async function getNewsletterSubscribersCount() {
  try {
    const { count, error } = await supabaseClient
      .from('newsletter')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'active');

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching newsletter subscribers count:', error);
    return 0;
  }
}

/**
 * Fetch count of articles published in the last 30 days
 * @returns {Promise<number>}
 */
export async function getArticlesLast30DaysCount() {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const thirtyDaysAgoISO = thirtyDaysAgo.toISOString();

    const { count, error } = await supabaseClient
      .from('articles')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'published')
      .gte('published_at', thirtyDaysAgoISO);

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching articles from last 30 days count:', error);
    return 0; // fallback to 0 on error
  }
}

/**
 * Fetch count of unique categories from Supabase
 * @returns {Promise<number>}
 */
export async function getUniqueCategoriesCount() {
  try {
    // Get unique categories from articles, events, and lives
    const [articlesResult, eventsResult, livesResult] = await Promise.all([
      supabaseClient
        .from('articles')
        .select('category')
        .eq('status', 'published')
        .not('category', 'is', null),

      supabaseClient
        .from('events')
        .select('category')
        .eq('status', 'published')
        .not('category', 'is', null),

      supabaseClient
        .from('lives')
        .select('category')
        .eq('status', 'published')
        .not('category', 'is', null)
    ]);

    if (articlesResult.error) throw articlesResult.error;
    if (eventsResult.error) throw eventsResult.error;
    if (livesResult.error) throw livesResult.error;

    // Collect all categories
    const allCategories = [
      ...(articlesResult.data || []).map(item => item.category),
      ...(eventsResult.data || []).map(item => item.category),
      ...(livesResult.data || []).map(item => item.category)
    ].filter(Boolean); // Remove null/undefined/empty values

    // Count unique categories using Set
    const uniqueCategories = new Set(allCategories);
    return uniqueCategories.size;
  } catch (error) {
    console.error('Error fetching unique categories count:', error);
    return 0;
  }
}

/**
 * Get category distribution across all content types
 * @returns {Promise<Array<{category: string, count: number}>}
 */
export async function getCategoryDistribution() {
  try {
    // Get categories from articles, events, and lives
    const [articlesResult, eventsResult, livesResult] = await Promise.all([
      supabaseClient
      .from('articles')
      .select('category')
      .eq('status', 'published')
      .not('category', 'is', null),

      supabaseClient
      .from('events')
      .select('category')
      .eq('status', 'published')
      .not('category', 'is', null),

      supabaseClient
      .from('lives')
      .select('category')
      .eq('status', 'published')
      .not('category', 'is', null)
    ]);

    if (articlesResult.error) throw articlesResult.error;
    if (eventsResult.error) throw eventsResult.error;
    if (livesResult.error) throw livesResult.error;

    // Collect all categories
    const allCategories = [
      ...(articlesResult.data || []).map(item => item.category),
      ...(eventsResult.data || []).map(item => item.category),
      ...(livesResult.data || []).map(item => item.category)
    ].filter(Boolean);

    // Count occurrences of each category
    const categoryCounts = {};
    allCategories.forEach(category => {
      categoryCounts[category] = (categoryCounts[category] || 0) + 1;
    });

    // Convert to array of objects for Chart.js
    const distribution = Object.keys(categoryCounts).map(category => ({
      category,
      count: categoryCounts[category]
    }));

    // Sort by count descending
    distribution.sort((a, b) => b.count - a.count);

    return distribution;
  } catch (error) {
    console.error('Error fetching category distribution:', error);
    return [];
  }
}

/**
 * Get top 5 most viewed articles
 * @returns {Promise<Array<{id: string, title: string, slug: string, view_count: number, author_name: string, published_at: string}>}
 */
export async function getTopViewedArticles() {
  try {
    const { data, error } = await supabaseClient
      .from('articles')
      .select('id, title, slug, view_count, author_name, published_at')
      .eq('status', 'published')
      .order('view_count', { ascending: false })
      .limit(5);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top viewed articles:', error);
    return [];
  }
}

// --- Admin functions (return ALL content, not just published) ---

/**
 * Fetch ALL articles (including drafts) for admin
 * @returns {Promise<Array>}
 */
export async function getAllArticles() {
  try {
    const { data, error } = await supabaseClient
      .from('articles')
      .select('*')
      .order('published_date', { ascending: false });

    if (error) throw error;
    return (data || []).map(normalizeArticle);
  } catch (error) {
    console.error('Error fetching all articles:', error);
    return [];
  }
}

/**
 * Fetch ALL events (including drafts) for admin
 * @returns {Promise<Array>}
 */
export async function getAllEvents() {
  try {
    const { data, error } = await supabaseClient
      .from('events')
      .select('*')
      .order('date', { ascending: true });

    if (error) throw error;
    return (data || []).map(normalizeEvent);
  } catch (error) {
    console.error('Error fetching all events:', error);
    return [];
  }
}

/**
 * Fetch ALL lives (including drafts) for admin
 * @returns {Promise<Array>}
 */
export async function getAllLives() {
  try {
    const { data, error } = await supabaseClient
      .from('lives')
      .select('*')
      .order('date', { ascending: true });

    if (error) throw error;
    return (data || []).map(normalizeLive);
  } catch (error) {
    console.error('Error fetching all lives:', error);
    return [];
  }
}

// --- Delete functions for admin ---

/**
 * Delete an article by ID
 * @param {string} id
 * @returns {Promise<null>}
 */
export async function deleteArticle(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized: login required');
  const { error } = await supabaseClient
    .from('articles')
    .delete()
    .eq('id', id);
  if (error) throw error;
}

/**
 * Delete an event by ID
 * @param {string} id
 * @returns {Promise<null>}
 */
export async function deleteEvent(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized: login required');
  const { error } = await supabaseClient
    .from('events')
    .delete()
    .eq('id', id);
  if (error) throw error;
}

/**
 * Delete a live by ID
 * @param {string} id
 * @returns {Promise<null>}
 */
export async function deleteLive(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized: login required');
  const { error } = await supabaseClient
    .from('lives')
    .delete()
    .eq('id', id);
  if (error) throw error;
}

/**
 * Get total content count (sum of articles, events, and lives)
 * @returns {Promise<number>}
 */
export async function getTotalContentCount() {
  try {
    const [articlesCount, eventsCount, livesCount] = await Promise.all([
      getPublishedArticlesCount(),
      getPublishedEventsCount(),
      getPublishedLivesCount()
    ]);

    return (articlesCount || 0) + (eventsCount || 0) + (livesCount || 0);
  } catch (error) {
    console.error('Error fetching total content count:', error);
    return 0;
  }
}

/**
 * Get recent admin activity from audit_logs
 * @param {number} limit - Number of activities to return
 * @returns {Promise<Array<{id: string, action: string, table_name: string, record_id: string, created_at: string, user_email: string}>}
 */
export async function getRecentAdminActivity(limit = 10) {
  try {
    const { data, error } = await supabaseClient
      .from('audit_logs')
      .select('id, action, table_name, record_id, created_at, user_email, new_values')
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching recent admin activity:', error);
    return [];
  }
}

/**
 * Get top publishing admin (admin with most publications)
 * @returns {Promise<{performer_name: string, count: number}>}
 */
export async function getTopPublishingAdmin() {
  try {
    const { data, error } = await supabaseClient
      .from('audit_logs')
      .select('user_email')
      .eq('action', 'CREATE')
      .in('table_name', ['articles', 'events', 'lives']);

    if (error) throw error;

    if (!data || data.length === 0) {
      return { performer_name: 'Nenhum', count: 0 };
    }

    // Group by user_email in JavaScript
    const counts = {};
    data.forEach(row => {
      const name = row.user_email || 'Desconhecido';
      counts[name] = (counts[name] || 0) + 1;
    });

    // Find the top performer
    const topName = Object.keys(counts).reduce((a, b) => counts[a] > counts[b] ? a : b);
    return { performer_name: topName, count: counts[topName] };
  } catch (error) {
    console.error('Error fetching top publishing admin:', error);
    return { performer_name: 'Erro', count: 0 };
  }
}

/**
 * Get event fill rate for next upcoming event
 * @returns {Promise<{event: Object|null, fillRate: number}>}
 */
export async function getEventFillRate() {
  try {
    // Get the next upcoming event
    const { data: upcomingEvents, error: upcomingError } = await supabaseClient
      .from('events')
      .select('id, title, date, capacity')
      .gte('date', new Date().toISOString().split('T')[0])
      .eq('status', 'published')
      .order('date', { ascending: true })
      .limit(1);

    if (upcomingError) throw upcomingError;

    if (!upcomingEvents || upcomingEvents.length === 0) {
      return { event: null, fillRate: 0 };
    }

    const event = upcomingEvents[0];

    // Get registration count for this event
    const { count, error: countError } = await supabaseClient
      .from('event_registrations')
      .select('*', { count: 'exact', head: true })
      .eq('event_id', event.id);

    if (countError) throw countError;

    const registrationCount = count || 0;
    const fillRate = event.capacity > 0 ? (registrationCount / event.capacity) * 100 : 0;

    return {
      event: {
        id: event.id,
        title: event.title,
        date: event.date,
        capacity: event.capacity
      },
      fillRate: parseFloat(fillRate.toFixed(2))
    };
  } catch (error) {
    console.error('Error fetching event fill rate:', error);
    return { event: null, fillRate: 0 };
  }
}

/**
 * Fetch page view count for a given period
 * @param {'day'|'week'|'month'|'6months'|'year'} period
 * @returns {Promise<number>}
 */
export async function getPageViewsByPeriod(period = 'month') {
  try {
    const now = new Date();
    let startDate;

    if (period === 'day') {
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    } else if (period === 'week') {
      startDate = new Date(now);
      startDate.setDate(startDate.getDate() - 7);
    } else if (period === 'month') {
      startDate = new Date(now);
      startDate.setMonth(startDate.getMonth() - 1);
    } else if (period === '6months') {
      startDate = new Date(now);
      startDate.setMonth(startDate.getMonth() - 6);
    } else if (period === 'year') {
      startDate = new Date(now);
      startDate.setFullYear(startDate.getFullYear() - 1);
    }

    const { count, error } = await supabaseClient
      .from('page_views')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', startDate.toISOString());

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching page views:', error);
    return 0;
  }
}

/**
 * Fetch inscription count for a given period
 * @param {'day'|'week'|'month'|'6months'|'year'} period
 * @returns {Promise<number>}
 */
export async function getInscriptionsByPeriod(period = 'month') {
  try {
    const now = new Date();
    let startDate;

    if (period === 'day') {
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    } else if (period === 'week') {
      startDate = new Date(now);
      startDate.setDate(startDate.getDate() - 7);
    } else if (period === 'month') {
      startDate = new Date(now);
      startDate.setMonth(startDate.getMonth() - 1);
    } else if (period === '6months') {
      startDate = new Date(now);
      startDate.setMonth(startDate.getMonth() - 6);
    } else if (period === 'year') {
      startDate = new Date(now);
      startDate.setFullYear(startDate.getFullYear() - 1);
    }

    const { count, error } = await supabaseClient
      .from('inscricoes')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', startDate.toISOString());

    if (error) throw error;
    return count || 0;
  } catch (error) {
    console.error('Error fetching inscriptions:', error);
    return 0;
  }
}

/**
 * Get top articles by view count
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopArticlesByViews(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('articles')
      .select('title, slug, view_count')
      .eq('status', 'published')
      .order('view_count', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top articles by views:', error);
    return [];
  }
}

/**
 * Get top articles by share count
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopArticlesByShares(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('articles')
      .select('title, slug, share_count')
      .eq('status', 'published')
      .order('share_count', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top articles by shares:', error);
    return [];
  }
}

/**
 * Get top articles by reading time
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopArticlesByReadingTime(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('articles')
      .select('title, slug, total_reading_time')
      .eq('status', 'published')
      .order('total_reading_time', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top articles by reading time:', error);
    return [];
  }
}

/**
 * Get top events by view count
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopEventsByViews(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('events')
      .select('title, slug, view_count')
      .eq('status', 'published')
      .order('view_count', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top events by views:', error);
    return [];
  }
}

/**
 * Get top events by fill rate (inscritos/capacity)
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopEventsByFillRate(limit = 3) {
  try {
    const { data: events, error } = await supabaseClient
      .from('events')
      .select('title, slug, capacity')
      .eq('status', 'published')
      .gt('capacity', 0);

    if (error) throw error;
    if (!events || events.length === 0) return [];

    for (const event of events) {
      const { count } = await supabaseClient
        .from('inscricoes')
        .select('*', { count: 'exact', head: true })
        .eq('evento_slug', event.slug);
      event.inscription_count = count || 0;
      event.fill_rate = Math.round((count / event.capacity) * 100);
    }

    return events.sort((a, b) => b.fill_rate - a.fill_rate).slice(0, limit);
  } catch (error) {
    console.error('Error fetching top events by fill rate:', error);
    return [];
  }
}

/**
 * Get upcoming published events
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getUpcomingEvents(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('events')
      .select('title, slug, date, location')
      .eq('status', 'published')
      .gte('date', new Date().toISOString().split('T')[0])
      .order('date', { ascending: true })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching upcoming events:', error);
    return [];
  }
}

/**
 * Get top lives by view count
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopLivesByViews(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('lives')
      .select('title, slug, view_count')
      .eq('status', 'published')
      .order('view_count', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top lives by views:', error);
    return [];
  }
}

/**
 * Get top lives by access count (Aceder Agora clicks)
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopLivesByAccess(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('lives')
      .select('title, slug, access_count')
      .eq('status', 'published')
      .order('access_count', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top lives by access:', error);
    return [];
  }
}

/**
 * Get top lives by download count
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getTopLivesByDownloads(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('lives')
      .select('title, slug, download_count')
      .eq('status', 'published')
      .order('download_count', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching top lives by downloads:', error);
    return [];
  }
}

/**
 * Get upcoming published lives
 * @param {number} limit
 * @returns {Promise<Array>}
 */
export async function getUpcomingLives(limit = 3) {
  try {
    const { data, error } = await supabaseClient
      .from('lives')
      .select('title, slug, date, time, platform')
      .eq('status', 'published')
      .gte('date', new Date().toISOString().split('T')[0])
      .order('date', { ascending: true })
      .limit(limit);

    if (error) throw error;
    return data || [];
  } catch (error) {
    console.error('Error fetching upcoming lives:', error);
    return [];
  }
}
