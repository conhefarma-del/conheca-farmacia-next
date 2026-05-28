'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

/**
 * SEC-ATH-02: Helper — verifica sessão + admin_users.
 * Retorna o supabase client + user se autenticado e admin.
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
 * Log de auditoria para operações CRUD.
 */
async function logAudit(supabase, user, action, tableName, recordId, newValues = null) {
  try {
    await supabase.from('audit_logs').insert({
      action,
      table_name: tableName,
      record_id: String(recordId),
      user_email: user.email,
      new_values: newValues ? JSON.stringify(newValues) : null,
      created_at: new Date().toISOString(),
    })
  } catch {
    // SEC-AUD-02: Não bloquear operação por falha de log
  }
}

// ============================================================
//  ARTIGOS
// ============================================================

/**
 * Eliminar artigo.
 * SEC-API-02: Verifica sessão + admin_users antes de DELETE.
 */
export async function deleteArticle(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID do artigo é obrigatório.' }
    }

    // SEC-API-02: Verificar sessão + admin_users
    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    // Buscar dados antes de eliminar (para audit)
    const { data: article } = await supabase
      .from('articles')
      .select('title')
      .eq('id', id)
      .single()

    // DELETE
    const { error } = await supabase
      .from('articles')
      .delete()
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao eliminar artigo.' }
    }

    // Audit log
    await logAudit(supabase, user, 'DELETE', 'articles', id, { title: article?.title })

    // Revalidate
    revalidatePath(`/[lang]/admin/artigos`, 'page')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Toggle status do artigo (published ↔ draft).
 * SEC-API-02: Verifica sessão + admin_users antes de UPDATE.
 */
export async function toggleArticleStatus(id, currentStatus) {
  try {
    if (!id || !currentStatus) {
      return { success: false, error: 'ID e status são obrigatórios.' }
    }

    const newStatus = currentStatus === 'published' ? 'draft' : 'published'

    // SEC-API-02: Verificar sessão + admin_users
    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    const { error } = await supabase
      .from('articles')
      .update({ status: newStatus })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao alterar status.' }
    }

    // Audit log
    await logAudit(
      supabase,
      user,
      newStatus === 'published' ? 'PUBLISH' : 'UNPUBLISH',
      'articles',
      id,
      { status: newStatus }
    )

    revalidatePath(`/[lang]/admin/artigos`, 'page')

    return { success: true, newStatus }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  EVENTOS
// ============================================================

/**
 * Eliminar evento.
 * SEC-API-02: Verifica sessão + admin_users antes de DELETE.
 */
export async function deleteEvent(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID do evento é obrigatório.' }
    }

    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    const { data: event } = await supabase
      .from('events')
      .select('title')
      .eq('id', id)
      .single()

    const { error } = await supabase
      .from('events')
      .delete()
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao eliminar evento.' }
    }

    await logAudit(supabase, user, 'DELETE', 'events', id, { title: event?.title })

    revalidatePath(`/[lang]/admin/eventos`, 'page')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Toggle status do evento (published ↔ draft).
 * SEC-API-02: Verifica sessão + admin_users antes de UPDATE.
 */
export async function toggleEventStatus(id, currentStatus) {
  try {
    if (!id || !currentStatus) {
      return { success: false, error: 'ID e status são obrigatórios.' }
    }

    const newStatus = currentStatus === 'published' ? 'draft' : 'published'

    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    const { error } = await supabase
      .from('events')
      .update({ status: newStatus })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao alterar status.' }
    }

    await logAudit(
      supabase,
      user,
      newStatus === 'published' ? 'PUBLISH' : 'UNPUBLISH',
      'events',
      id,
      { status: newStatus }
    )

    revalidatePath(`/[lang]/admin/eventos`, 'page')

    return { success: true, newStatus }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  LIVES
// ============================================================

/**
 * Eliminar live.
 * SEC-API-02: Verifica sessão + admin_users antes de DELETE.
 */
export async function deleteLive(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID da live é obrigatório.' }
    }

    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    const { data: live } = await supabase
      .from('lives')
      .select('title')
      .eq('id', id)
      .single()

    const { error } = await supabase
      .from('lives')
      .delete()
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao eliminar live.' }
    }

    await logAudit(supabase, user, 'DELETE', 'lives', id, { title: live?.title })

    revalidatePath(`/[lang]/admin/lives`, 'page')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Toggle status da live (published ↔ draft).
 * SEC-API-02: Verifica sessão + admin_users antes de UPDATE.
 */
export async function toggleLiveStatus(id, currentStatus) {
  try {
    if (!id || !currentStatus) {
      return { success: false, error: 'ID e status são obrigatórios.' }
    }

    const newStatus = currentStatus === 'published' ? 'draft' : 'published'

    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    const { error } = await supabase
      .from('lives')
      .update({ status: newStatus })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao alterar status.' }
    }

    await logAudit(
      supabase,
      user,
      newStatus === 'published' ? 'PUBLISH' : 'UNPUBLISH',
      'lives',
      id,
      { status: newStatus }
    )

    revalidatePath(`/[lang]/admin/lives`, 'page')

    return { success: true, newStatus }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  ARTIGOS — Create / Update
// ============================================================

export async function createArticle(formData) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    if (!formData.title || !formData.slug) {
      return { success: false, error: 'Título e slug são obrigatórios.' }
    }

    const articleData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      meta_description: formData.meta_description || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      content: formData.content || '',
      author_name: formData.author_name || null,
      author_role: formData.author_role || null,
      author_bio: formData.author_bio || null,
      author_avatar: formData.author_avatar || null,
      author_avatar_bg: formData.author_avatar_bg || null,
      image_url: formData.image_url || null,
      published_date: formData.published_date || null,
      read_time: formData.read_time ? parseInt(formData.read_time) : null,
      references_arr: formData.references || [],
      status: formData.status || 'draft',
      featured: formData.featured || false,
    }

    const { data, error } = await supabase
      .from('articles')
      .insert(articleData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar artigo: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'articles', data.id, { title: articleData.title })
    revalidatePath(`/[lang]/admin/artigos`, 'page')

    return { success: true, id: data.id }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function updateArticle(id, formData) {
  try {
    if (!id) return { success: false, error: 'ID do artigo é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const articleData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      meta_description: formData.meta_description || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      content: formData.content || '',
      author_name: formData.author_name || null,
      author_role: formData.author_role || null,
      author_bio: formData.author_bio || null,
      author_avatar: formData.author_avatar || null,
      author_avatar_bg: formData.author_avatar_bg || null,
      image_url: formData.image_url || null,
      published_date: formData.published_date || null,
      read_time: formData.read_time ? parseInt(formData.read_time) : null,
      references_arr: formData.references || [],
      status: formData.status || 'draft',
      featured: formData.featured || false,
    }

    const { error } = await supabase.from('articles').update(articleData).eq('id', id)
    if (error) return { success: false, error: `Erro ao atualizar artigo: ${error.message}` }

    await logAudit(supabase, user, 'UPDATE', 'articles', id, { title: articleData.title })
    revalidatePath(`/[lang]/admin/artigos`, 'page')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  EVENTOS — Create / Update
// ============================================================

export async function createEvent(formData) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    if (!formData.title || !formData.slug) {
      return { success: false, error: 'Título e slug são obrigatórios.' }
    }

    const eventData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      date: formData.date || null,
      time: formData.time || null,
      end_time: formData.end_time || null,
      location: formData.location || null,
      type: formData.type || null,
      capacity: formData.capacity ? parseInt(formData.capacity) : null,
      registration_link: formData.registration_link || null,
      image_url: formData.image_url || null,
      hosts: formData.hosts || [],
      status: formData.status || 'draft',
      featured: formData.featured || false,
    }

    const { data, error } = await supabase
      .from('events')
      .insert(eventData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar evento: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'events', data.id, { title: eventData.title })
    revalidatePath(`/[lang]/admin/eventos`, 'page')

    return { success: true, id: data.id }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function updateEvent(id, formData) {
  try {
    if (!id) return { success: false, error: 'ID do evento é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    // Buscar slug atual antes de atualizar
    const { data: existingEvent } = await supabase
      .from('events')
      .select('slug')
      .eq('id', id)
      .single()
    const oldSlug = existingEvent?.slug

    const eventData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      date: formData.date || null,
      time: formData.time || null,
      end_time: formData.end_time || null,
      location: formData.location || null,
      type: formData.type || null,
      capacity: formData.capacity ? parseInt(formData.capacity) : null,
      registration_link: formData.registration_link || null,
      image_url: formData.image_url || null,
      hosts: formData.hosts || [],
      status: formData.status || 'draft',
      featured: formData.featured || false,
    }

    const { error } = await supabase.from('events').update(eventData).eq('id', id)
    if (error) return { success: false, error: `Erro ao atualizar evento: ${error.message}` }

    // Propagar alteração de slug às inscrições existentes
    if (oldSlug && oldSlug !== eventData.slug) {
      await supabase
        .from('inscricoes')
        .update({ evento_slug: eventData.slug })
        .eq('evento_slug', oldSlug)
    }

    await logAudit(supabase, user, 'UPDATE', 'events', id, { title: eventData.title })
    revalidatePath(`/[lang]/admin/eventos`, 'page')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  LIVES — Create / Update
// ============================================================

export async function createLive(formData) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    if (!formData.title || !formData.slug) {
      return { success: false, error: 'Título e slug são obrigatórios.' }
    }

    let materials = formData.materials || []
    if (typeof materials === 'string') {
      try { materials = JSON.parse(materials) } catch { materials = [] }
    }

    const liveData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      date: formData.date || null,
      time: formData.time || null,
      end_time: formData.end_time || null,
      platform: formData.platform || null,
      access_link: formData.access_link || null,
      meeting_id: formData.meeting_id || null,
      password: formData.password || null,
      materials,
      host_name: formData.host_name || null,
      host_role: formData.host_role || null,
      host_organization: formData.host_organization || null,
      image_url: formData.image_url || null,
      status: formData.status || 'draft',
      featured: formData.featured || false,
    }

    const { data, error } = await supabase
      .from('lives')
      .insert(liveData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar live: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'lives', data.id, { title: liveData.title })
    revalidatePath(`/[lang]/admin/lives`, 'page')

    return { success: true, id: data.id }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function updateLive(id, formData) {
  try {
    if (!id) return { success: false, error: 'ID da live é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    let materials = formData.materials || []
    if (typeof materials === 'string') {
      try { materials = JSON.parse(materials) } catch { materials = [] }
    }

    const liveData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      date: formData.date || null,
      time: formData.time || null,
      end_time: formData.end_time || null,
      platform: formData.platform || null,
      access_link: formData.access_link || null,
      meeting_id: formData.meeting_id || null,
      password: formData.password || null,
      materials,
      host_name: formData.host_name || null,
      host_role: formData.host_role || null,
      host_organization: formData.host_organization || null,
      image_url: formData.image_url || null,
      status: formData.status || 'draft',
      featured: formData.featured || false,
    }

    const { error } = await supabase.from('lives').update(liveData).eq('id', id)
    if (error) return { success: false, error: `Erro ao atualizar live: ${error.message}` }

    await logAudit(supabase, user, 'UPDATE', 'lives', id, { title: liveData.title })
    revalidatePath(`/[lang]/admin/lives`, 'page')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}
