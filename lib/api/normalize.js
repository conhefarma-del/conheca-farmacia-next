/**
 * Format time string from Supabase (HH:MM:SS) to frontend format (HH:MM)
 */
export function formatTime(time) {
  if (!time) return null
  return time.split(':').slice(0, 2).join(':')
}

/**
 * Normalize article from Supabase (snake_case, flat) to frontend format (camelCase, nested author)
 * Also handles JSON fallback data (already in camelCase) for consistency
 */
export function normalizeArticle(row) {
  const isSupabase = 'category_label' in row || 'author_name' in row

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
    author: isSupabase
      ? {
          name: row.author_name,
          role: row.author_role,
          bio: row.author_bio,
          avatar: row.author_avatar,
          avatarBg: row.author_avatar_bg,
        }
      : row.author,
    author_name: isSupabase ? row.author_name : row.author?.name,
    date: isSupabase ? row.published_date : row.date,
    published_date: isSupabase ? row.published_date : row.date,
    readTime: isSupabase ? row.read_time : row.readTime,
    references: isSupabase ? row.references_arr : row.references,
    metaDescription: isSupabase ? row.meta_description : row.metaDescription,
  }
}

/**
 * Normalize event from Supabase to frontend format
 */
export function normalizeEvent(row) {
  const isSupabase = 'category_label' in row || 'end_time' in row

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
    locationMapsUrl: isSupabase ? row.location_maps_url : row.locationMapsUrl,
    locationMapsEmbedUrl: isSupabase ? row.location_maps_embed_url : row.locationMapsEmbedUrl,
    type: row.type,
    capacity: row.capacity,
    hosts: row.hosts || [],
    status: row.status,
    registrationLink: isSupabase ? row.registration_link : row.registrationLink,
  }
}

/**
 * Normalize live from Supabase (English snake_case) to frontend format (Portuguese names)
 * The live-detail.js uses Portuguese property names (titulo, hora, etc.)
 */
export function normalizeLive(row) {
  const isSupabase = 'category_label' in row || 'hosts' in row

  if (isSupabase) {
    const hosts = Array.isArray(row.hosts) ? row.hosts : []
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
      hosts: hosts,
      hosts_pt: hosts,
      topic: row.topic,
      topico: row.topic,
    }
  }

  // JSON fallback — already in Portuguese format, just format times
  return {
    ...row,
    hora: formatTime(row.hora),
    hora_termino: row.hora_termino ? formatTime(row.hora_termino) : null,
  }
}
