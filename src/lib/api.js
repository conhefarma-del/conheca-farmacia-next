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
    id: row.slug,
    slug: row.slug,
    title: row.title,
    excerpt: row.excerpt,
    category: row.category,
    categoryLabel: isSupabase ? row.category_label : row.categoryLabel,
    image: isSupabase ? row.image_url : row.image,
    content: row.content,
    author: isSupabase ? {
      name: row.author_name,
      role: row.author_role,
      bio: row.author_bio,
      avatar: row.author_avatar,
      avatarBg: row.author_avatar_bg,
    } : row.author,
    date: isSupabase ? row.published_date : row.date,
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
    id: row.slug,
    slug: row.slug,
    title: row.title,
    excerpt: row.excerpt,
    category: row.category,
    categoryLabel: isSupabase ? row.category_label : row.categoryLabel,
    image: isSupabase ? row.image_url : row.image,
    date: row.date,
    time: formatTime(isSupabase ? row.time : row.time),
    endTime: formatTime(isSupabase ? row.end_time : row.endTime),
    location: row.location,
    type: row.type,
    capacity: row.capacity,
    hosts: row.hosts,
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
      titulo: row.title,
      resumo: row.excerpt,
      categoria: row.category,
      categoriaLabel: row.category_label,
      imagem: row.image_url,
      data: row.date,
      hora: formatTime(row.time),
      hora_termino: formatTime(row.end_time),
      plataforma: row.platform,
      link_acesso: row.access_link,
      id_reuniao: row.meeting_id,
      senha: row.password,
      materiais_apoio: row.materials,
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
      .select('*')
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
      .select('*')
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
