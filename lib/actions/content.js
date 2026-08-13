'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath, revalidateTag } from 'next/cache'
import { isValidHexColor, validateUrl } from '@/lib/security'
import { sanitizeHtml } from '@/lib/sanitize'
import { slugify } from '@/lib/utils/slugify'

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

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
    .select('user_id, role')
    .eq('user_id', user.id)
    .single()

  if (adminError || !adminUser) return null

  return { supabase, user, role: adminUser.role || 'admin' }
}

/**
 * SEC-ATH-02 (extensão): verifica role = superadmin.
 * Definido em migration 020 (2026-06-15).
 */
async function requireSuperAdmin() {
  const ctx = await requireAdmin()
  if (!ctx) return null
  if (ctx.role !== 'superadmin') return null
  return ctx
}

/**
 * Retorna a role do user autenticado. Para uso em Server Components (parents das ListPages).
 * Devolve 'superadmin' | 'admin' | null.
 * Definido em Phase 2.1 do plano 2026-06-15-admin-role-ui.
 */
export async function getCurrentRole() {
  const ctx = await requireAdmin()
  if (!ctx) return null
  return ctx.role
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
 * Arquivar artigo (soft delete).
 * SEC-API-02: admin + superadmin. Migration 020.
 */
export async function archiveArticle(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID do artigo é obrigatório.' }
    }

    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    const { data: article } = await supabase
      .from('articles')
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!article) {
      return { success: false, error: 'Artigo não encontrado.' }
    }

    if (article.is_archived) {
      return { success: true } // já arquivado, idempotente
    }

    const { error } = await supabase
      .from('articles')
      .update({
        is_archived: true,
        archived_at: new Date().toISOString(),
        archived_by: user.id,
      })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao arquivar artigo.' }
    }

    await logAudit(supabase, user, 'ARCHIVE', 'articles', id, { title: article.title })
    revalidatePath(`/[lang]/admin/artigos`, 'page')
    revalidateTag('articles')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Eliminar artigo definitivamente (hard delete).
 * SEC-API-02 + migration 020: só superadmin.
 */
export async function deleteArticle(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID do artigo é obrigatório.' }
    }

    const ctx = await requireSuperAdmin()
    if (!ctx) {
      return { success: false, error: 'Operação restrita a superadmin.' }
    }

    const { supabase, user } = ctx

    const { data: article } = await supabase
      .from('articles')
      .select('title')
      .eq('id', id)
      .single()

    const { error } = await supabase
      .from('articles')
      .delete()
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao eliminar artigo.' }
    }

    await logAudit(supabase, user, 'DELETE', 'articles', id, { title: article?.title })
    revalidatePath(`/[lang]/admin/artigos`, 'page')
    revalidateTag('articles')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Restaurar artigo arquivado.
 * SEC-API-02 + migration 020: só superadmin.
 */
export async function restoreArticle(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID do artigo é obrigatório.' }
    }

    const ctx = await requireSuperAdmin()
    if (!ctx) {
      return { success: false, error: 'Operação restrita a superadmin.' }
    }

    const { supabase, user } = ctx

    const { data: article } = await supabase
      .from('articles')
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!article) {
      return { success: false, error: 'Artigo não encontrado.' }
    }

    if (!article.is_archived) {
      return { success: true } // já restaurado
    }

    const { error } = await supabase
      .from('articles')
      .update({
        is_archived: false,
        archived_at: null,
        archived_by: null,
      })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao restaurar artigo.' }
    }

    await logAudit(supabase, user, 'RESTORE', 'articles', id, { title: article.title })
    revalidatePath(`/[lang]/admin/artigos`, 'page')
    revalidateTag('articles')

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
    revalidateTag('articles')

    return { success: true, newStatus }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  EVENTOS
// ============================================================

/**
 * Arquivar evento (soft delete).
 * SEC-API-02: admin + superadmin. Migration 020.
 */
export async function archiveEvent(id) {
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
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!event) {
      return { success: false, error: 'Evento não encontrado.' }
    }

    if (event.is_archived) {
      return { success: true } // já arquivado, idempotente
    }

    const { error } = await supabase
      .from('events')
      .update({
        is_archived: true,
        archived_at: new Date().toISOString(),
        archived_by: user.id,
      })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao arquivar evento.' }
    }

    await logAudit(supabase, user, 'ARCHIVE', 'events', id, { title: event.title })
    revalidatePath(`/[lang]/admin/eventos`, 'page')
    revalidateTag('events')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Eliminar evento definitivamente (hard delete).
 * SEC-API-02 + migration 020: só superadmin.
 */
export async function deleteEvent(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID do evento é obrigatório.' }
    }

    const ctx = await requireSuperAdmin()
    if (!ctx) {
      return { success: false, error: 'Operação restrita a superadmin.' }
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
    revalidateTag('events')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Restaurar evento arquivado.
 * SEC-API-02 + migration 020: só superadmin.
 */
export async function restoreEvent(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID do evento é obrigatório.' }
    }

    const ctx = await requireSuperAdmin()
    if (!ctx) {
      return { success: false, error: 'Operação restrita a superadmin.' }
    }

    const { supabase, user } = ctx

    const { data: event } = await supabase
      .from('events')
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!event) {
      return { success: false, error: 'Evento não encontrado.' }
    }

    if (!event.is_archived) {
      return { success: true } // já restaurado
    }

    const { error } = await supabase
      .from('events')
      .update({
        is_archived: false,
        archived_at: null,
        archived_by: null,
      })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao restaurar evento.' }
    }

    await logAudit(supabase, user, 'RESTORE', 'events', id, { title: event.title })
    revalidatePath(`/[lang]/admin/eventos`, 'page')
    revalidateTag('events')

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
    revalidateTag('events')

    return { success: true, newStatus }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  LIVES
// ============================================================

/**
 * Arquivar live (soft delete).
 * SEC-API-02: admin + superadmin. Migration 020.
 */
export async function archiveLive(id) {
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
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!live) {
      return { success: false, error: 'Live não encontrada.' }
    }

    if (live.is_archived) {
      return { success: true } // já arquivada, idempotente
    }

    const { error } = await supabase
      .from('lives')
      .update({
        is_archived: true,
        archived_at: new Date().toISOString(),
        archived_by: user.id,
      })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao arquivar live.' }
    }

    await logAudit(supabase, user, 'ARCHIVE', 'lives', id, { title: live.title })
    revalidatePath(`/[lang]/admin/lives`, 'page')
    revalidateTag('lives')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Eliminar live definitivamente (hard delete).
 * SEC-API-02 + migration 020: só superadmin.
 */
export async function deleteLive(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID da live é obrigatório.' }
    }

    const ctx = await requireSuperAdmin()
    if (!ctx) {
      return { success: false, error: 'Operação restrita a superadmin.' }
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
    revalidateTag('lives')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Restaurar live arquivada.
 * SEC-API-02 + migration 020: só superadmin.
 */
export async function restoreLive(id) {
  try {
    if (!id) {
      return { success: false, error: 'ID da live é obrigatório.' }
    }

    const ctx = await requireSuperAdmin()
    if (!ctx) {
      return { success: false, error: 'Operação restrita a superadmin.' }
    }

    const { supabase, user } = ctx

    const { data: live } = await supabase
      .from('lives')
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!live) {
      return { success: false, error: 'Live não encontrada.' }
    }

    if (!live.is_archived) {
      return { success: true } // já restaurada
    }

    const { error } = await supabase
      .from('lives')
      .update({
        is_archived: false,
        archived_at: null,
        archived_by: null,
      })
      .eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao restaurar live.' }
    }

    await logAudit(supabase, user, 'RESTORE', 'lives', id, { title: live.title })
    revalidatePath(`/[lang]/admin/lives`, 'page')
    revalidateTag('lives')

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
    revalidateTag('lives')

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
      // SEC-UMN-06 (vistoria o-sentinela 2026-08-11, #8): sanitização
      // server-side do conteúdo HTML (defesa em profundidade — o render-time
      // DOMPurify protege os leitores, mas um admin comprometido ou um futuro
      // consumidor de API podia gravar HTML que outros admins veem no preview).
      // Espelha o padrão de translation.js/legalContent.js.
      content: sanitizeHtml(formData.content || ''),
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
      featured_langs: Array.isArray(formData.featured_langs) ? formData.featured_langs : [],
    }

    const { data, error } = await supabase
      .from('articles')
      .insert(articleData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar artigo: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'articles', data.id, { title: articleData.title })
    revalidatePath(`/[lang]/admin/artigos`, 'page')
    revalidateTag('articles')

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
      // SEC-UMN-06 (#8): sanitização server-side do conteúdo HTML.
      content: sanitizeHtml(formData.content || ''),
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
      featured_langs: Array.isArray(formData.featured_langs) ? formData.featured_langs : [],
    }

    const { error } = await supabase.from('articles').update(articleData).eq('id', id)
    if (error) return { success: false, error: `Erro ao atualizar artigo: ${error.message}` }

    await logAudit(supabase, user, 'UPDATE', 'articles', id, { title: articleData.title })
    revalidatePath(`/[lang]/admin/artigos`, 'page')
    revalidateTag('articles')

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
      location_maps_url: formData.location_maps_url || null,
      location_maps_embed_url: formData.location_maps_embed_url || null,
      type: formData.type || null,
      capacity: formData.capacity ? parseInt(formData.capacity) : null,
      registration_link: formData.registration_link || null,
      image_url: formData.image_url || null,
      hosts: formData.hosts || [],
      status: formData.status || 'draft',
      featured_langs: Array.isArray(formData.featured_langs) ? formData.featured_langs : [],
    }

    const { data, error } = await supabase
      .from('events')
      .insert(eventData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar evento: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'events', data.id, { title: eventData.title })
    revalidatePath(`/[lang]/admin/eventos`, 'page')
    revalidateTag('events')

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

    // Validar campos de certificado
    const cor = formData.certificado_cor
    if (cor && !isValidHexColor(cor)) {
      return { success: false, error: 'Cor do certificado inválida. Use formato hex (#RRGGBB).' }
    }
    const logo = formData.certificado_logo_url
    if (logo && validateUrl(logo) === '#') {
      return { success: false, error: 'URL do logótipo do certificado inválida.' }
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
      location_maps_url: formData.location_maps_url || null,
      location_maps_embed_url: formData.location_maps_embed_url || null,
      type: formData.type || null,
      capacity: formData.capacity ? parseInt(formData.capacity) : null,
      registration_link: formData.registration_link || null,
      image_url: formData.image_url || null,
      hosts: formData.hosts || [],
      status: formData.status || 'draft',
      featured_langs: Array.isArray(formData.featured_langs) ? formData.featured_langs : [],
      // Campos de certificado
      certificado_cor: formData.certificado_cor || '#00493A',
      certificado_texto: formData.certificado_texto || 'Certificamos que o participante concluiu com aproveitamento.',
      certificado_logo_url: formData.certificado_logo_url || null,
      certificado_carga_horaria: formData.certificado_carga_horaria || null,
      certificado_assinante_1_nome: formData.certificado_assinante_1_nome || 'Conheça Farmácia',
      certificado_assinante_1_cargo: formData.certificado_assinante_1_cargo || 'Conheça Farmácia',
      certificado_assinante_2_nome: formData.certificado_assinante_2_nome || null,
      certificado_assinante_2_cargo: formData.certificado_assinante_2_cargo || null,
    }

    const { error } = await supabase.from('events').update(eventData).eq('id', id)
    if (error) return { success: false, error: `Erro ao atualizar evento: ${error.message}` }

    // (evento_slug propagation removed — evento_id (UUID) is the source-of-truth FK
    //  and is stable across slug renames. See migration 024.)

    await logAudit(supabase, user, 'UPDATE', 'events', id, { title: eventData.title })
    revalidatePath(`/[lang]/admin/eventos`, 'page')
    revalidateTag('events')

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
      hosts: Array.isArray(formData.hosts)
        ? formData.hosts.filter((h) => h && (h.name || h.role || h.organization))
        : [],
      topic: formData.topic || null,
      image_url: formData.image_url || null,
      status: formData.status || 'draft',
      featured_langs: Array.isArray(formData.featured_langs) ? formData.featured_langs : [],
    }

    const { data, error } = await supabase
      .from('lives')
      .insert(liveData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar live: ${error.message}` }

    await logAudit(supabase, user, 'CREATE', 'lives', data.id, { title: liveData.title })
    revalidatePath(`/[lang]/admin/lives`, 'page')
    revalidateTag('lives')

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
      hosts: Array.isArray(formData.hosts)
        ? formData.hosts.filter((h) => h && (h.name || h.role || h.organization))
        : [],
      topic: formData.topic || null,
      image_url: formData.image_url || null,
      status: formData.status || 'draft',
      featured_langs: Array.isArray(formData.featured_langs) ? formData.featured_langs : [],
    }

    const { error } = await supabase.from('lives').update(liveData).eq('id', id)
    if (error) return { success: false, error: `Erro ao atualizar live: ${error.message}` }

    await logAudit(supabase, user, 'UPDATE', 'lives', id, { title: liveData.title })
    revalidatePath(`/[lang]/admin/lives`, 'page')
    revalidateTag('lives')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  INSCRIÇÕES — Marcar compareceu / Certificado
// ============================================================

/**
 * Marca (ou desmarca) participação de um inscrito.
 * Apenas admin+. Ao marcar compareceu=true, preenche certificado_emitido_at/por.
 * Retorna { ok: true } ou throw via o padrão do ficheiro.
 */
export async function marcarCompareceu(inscricaoId, compareceu) {
  try {
    if (!inscricaoId) {
      return { success: false, error: 'ID da inscrição é obrigatório.' }
    }

    const ctx = await requireAdmin()
    if (!ctx) {
      return { success: false, error: 'Sessão expirada. Faça login novamente.' }
    }

    const { supabase, user } = ctx

    const now = compareceu ? new Date().toISOString() : null

    const { error } = await supabase
      .from('inscricoes')
      .update({
        compareceu: Boolean(compareceu),
        certificado_emitido_at: now,
        certificado_emitido_por: compareceu ? user.id : null,
      })
      .eq('id', inscricaoId)

    if (error) {
      return { success: false, error: `Erro ao atualizar participação: ${error.message}` }
    }

    await logAudit(
      supabase,
      user,
      'UPDATE',
      'inscricoes',
      inscricaoId,
      { compareceu: Boolean(compareceu), action: 'marcar_compareceu' }
    )

    revalidatePath(`/[lang]/admin/inscritos`, 'page')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

// ============================================================
//  ENTREVISTAS — Create / Update / Archive / Delete
//  Módulo de Entrevistas (migration 152)
// ============================================================

function normalizeInterviewee(obj, fallbackName) {
  if (!obj || typeof obj !== 'object') return { name: fallbackName || '' }
  return {
    name: obj.name || '',
    role: obj.role || '',
    bio: obj.bio || '',
    avatar: obj.avatar || (obj.name || '').split(' ').map((w) => w[0]).join('').slice(0, 2).toUpperCase(),
    avatarBg: obj.avatarBg || '#00493a',
  }
}

/**
 * Normaliza a lista de entrevistados (até 5). Aceita o formato antigo
 * (objeto único) ou o novo (array). Filtra entradas vazias e guarda sempre
 * como array JSONB.
 */
function normalizeInterviewees(list, fallbackName) {
  const raw = Array.isArray(list) ? list : list ? [list] : []
  return raw
    .filter((p) => p && typeof p === 'object')
    .map((p) => normalizeInterviewee(p, fallbackName))
    .filter((p) => p.name || p.role || p.bio)
    .slice(0, 5)
}

/**
 * Upsert de um entrevistado no registo (interview_people) — devolve o id
 * (novo ou existente). Mesmas regras da migração 154 (role como campo
 * distintivo, no lugar da institution dos autores científicos):
 *   1. nome + role iguais (ambas conhecidas) → mesma pessoa
 *   2. nome igual e um dos lados sem role → funde (só se único)
 *   3. roles conhecidos e diferentes → pessoa nova (slug único)
 */
async function upsertPerson(supabase, p) {
  const name = String(p.name || '').trim()
  const role = String(p.role || '').trim() || null
  const fields = {
    name,
    role: role || null,
    bio: p.bio || null,
    avatar: p.avatar || null,
    avatar_bg: p.avatarBg || '#00493a',
  }

  // Regra 1: nome + role iguais
  if (role) {
    const { data: exact } = await supabase
      .from('interview_people')
      .select('id')
      .eq('name', name)
      .eq('role', role)
      .maybeSingle()
    if (exact) {
      await supabase
        .from('interview_people')
        .update({ ...fields, updated_at: new Date().toISOString() })
        .eq('id', exact.id)
      return exact.id
    }
  }

  // Regra 2: nome igual e um dos lados sem role → funde (só se único)
  const { data: sameName } = await supabase
    .from('interview_people')
    .select('id, role')
    .eq('name', name)
    .limit(2)
  if (sameName && sameName.length === 1 && (!sameName[0].role || !role)) {
    await supabase
      .from('interview_people')
      .update({ ...fields, updated_at: new Date().toISOString() })
      .eq('id', sameName[0].id)
    return sameName[0].id
  }

  // Regra 3: cria novo com slug único (desambiguado)
  const baseSlug = slugify(name) || 'entrevistado'
  let slug = baseSlug
  let n = 2
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const { data: clash } = await supabase
      .from('interview_people')
      .select('id')
      .eq('slug', slug)
      .maybeSingle()
    if (!clash) break
    slug = `${baseSlug}-${n}`
    n += 1
  }

  const { data: created, error } = await supabase
    .from('interview_people')
    .insert({ ...fields, slug })
    .select('id')
    .single()
  if (error) throw error
  return created.id
}

/**
 * Sincroniza o registo interview_people + junction interview_person_links
 * a partir do JSONB canónico `interviewee` da entrevista (154). Mesmas
 * regras da migração 154. A junction é reconstruída (delete + insert) —
 * idempotente, pode correr em cada save.
 */
async function syncInterviewPeople(supabase, interviewId, interviewees) {
  if (!Array.isArray(interviewees)) interviewees = []

  await supabase.from('interview_person_links').delete().eq('interview_id', interviewId)
  if (interviewees.length === 0) return

  const links = []
  for (let i = 0; i < interviewees.length; i++) {
    const personId = await upsertPerson(supabase, interviewees[i])
    links.push({ interview_id: interviewId, person_id: personId, position: i + 1 })
  }

  const { error } = await supabase.from('interview_person_links').insert(links)
  if (error) throw error
}

export async function createInterview(formData) {
  try {
    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    if (!formData.title || !formData.slug) {
      return { success: false, error: 'Título e slug são obrigatórios.' }
    }

    const interviewData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      interviewee: normalizeInterviewees(formData.interviewees || formData.interviewee, ''),
      interviewer: normalizeInterviewee(formData.interviewer, ''),
      date: formData.date || null,
      read_time: formData.read_time ? parseInt(formData.read_time) : null,
      video_duration: formData.video_duration || null,
      thumbnail_url: formData.thumbnail_url || null,
      video_id: formData.video_id || null,
      audio_url: formData.audio_url || null,
      executive_summary: formData.executive_summary || null,
      pull_quotes: Array.isArray(formData.pull_quotes) ? formData.pull_quotes.filter(Boolean) : [],
      qa: Array.isArray(formData.qa) ? formData.qa : [],
      content: formData.content || null,
      references_arr: Array.isArray(formData.references_arr) ? formData.references_arr.filter(Boolean) : [],
      related: Array.isArray(formData.related) ? formData.related.filter(Boolean) : [],
      status: formData.status || 'draft',
      featured: Boolean(formData.featured),
      meta_description: formData.meta_description || null,
    }

    const { data, error } = await supabase
      .from('interviews')
      .insert(interviewData)
      .select('id')
      .single()

    if (error) return { success: false, error: `Erro ao criar entrevista: ${error.message}` }

    // Registo de identidade dos entrevistados (interview_people, migração 154)
    await syncInterviewPeople(supabase, data.id, interviewData.interviewee)

    await logAudit(supabase, user, 'CREATE', 'interviews', data.id, { title: interviewData.title })
    revalidatePath(`/[lang]/admin/entrevistas`, 'page')
    revalidateTag('interviews')

    return { success: true, id: data.id }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function updateInterview(id, formData) {
  try {
    if (!id) return { success: false, error: 'ID da entrevista é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const interviewData = {
      slug: formData.slug,
      title: formData.title,
      excerpt: formData.excerpt || null,
      category: formData.category || null,
      category_label: formData.category_label || null,
      interviewee: normalizeInterviewees(formData.interviewees || formData.interviewee, ''),
      interviewer: normalizeInterviewee(formData.interviewer, ''),
      date: formData.date || null,
      read_time: formData.read_time ? parseInt(formData.read_time) : null,
      video_duration: formData.video_duration || null,
      thumbnail_url: formData.thumbnail_url || null,
      video_id: formData.video_id || null,
      audio_url: formData.audio_url || null,
      executive_summary: formData.executive_summary || null,
      pull_quotes: Array.isArray(formData.pull_quotes) ? formData.pull_quotes.filter(Boolean) : [],
      qa: Array.isArray(formData.qa) ? formData.qa : [],
      content: formData.content || null,
      references_arr: Array.isArray(formData.references_arr) ? formData.references_arr.filter(Boolean) : [],
      related: Array.isArray(formData.related) ? formData.related.filter(Boolean) : [],
      status: formData.status || 'draft',
      featured: Boolean(formData.featured),
      meta_description: formData.meta_description || null,
    }

    const { error } = await supabase.from('interviews').update(interviewData).eq('id', id)
    if (error) return { success: false, error: `Erro ao atualizar entrevista: ${error.message}` }

    // Registo de identidade dos entrevistados (interview_people, migração 154)
    await syncInterviewPeople(supabase, id, interviewData.interviewee)

    await logAudit(supabase, user, 'UPDATE', 'interviews', id, { title: interviewData.title })
    revalidatePath(`/[lang]/admin/entrevistas`, 'page')
    revalidateTag('interviews')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Contador de visualizações — action pública (sem requireAdmin de propósito):
 * qualquer visitante pode incrementar a view de uma entrevista publicada via
 * o RPC `increment_interview_view` (SECURITY DEFINER, só incrementa um
 * contador de entrevistas publicadas — não expõe nem altera mais nada).
 * Best-effort: nunca lança erro (o contador não deve partir a página).
 */
export async function incrementInterviewView(interviewId) {
  try {
    if (!interviewId || typeof interviewId !== 'string' || !UUID_REGEX.test(interviewId)) return
    const supabase = await createClient()
    await supabase.rpc('increment_interview_view', { p_interview_id: interviewId })
  } catch (err) {
    console.error('incrementInterviewView error:', err)
  }
}

export async function toggleInterviewStatus(id, currentStatus) {
  try {
    if (!id) return { success: false, error: 'ID da entrevista é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx
    const next = currentStatus === 'published' ? 'draft' : 'published'

    const { error } = await supabase
      .from('interviews')
      .update({ status: next })
      .eq('id', id)

    if (error) return { success: false, error: `Erro ao alterar status: ${error.message}` }

    await logAudit(supabase, user, 'UPDATE', 'interviews', id, { status: next })
    revalidateTag('interviews')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function archiveInterview(id) {
  try {
    if (!id) return { success: false, error: 'ID da entrevista é obrigatório.' }

    const ctx = await requireAdmin()
    if (!ctx) return { success: false, error: 'Sessão expirada. Faça login novamente.' }

    const { supabase, user } = ctx

    const { data: interview } = await supabase
      .from('interviews')
      .select('title, is_archived')
      .eq('id', id)
      .single()

    if (!interview) return { success: false, error: 'Entrevista não encontrada.' }
    if (interview.is_archived) return { success: true }

    const { error } = await supabase
      .from('interviews')
      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao arquivar entrevista.' }

    await logAudit(supabase, user, 'ARCHIVE', 'interviews', id, { title: interview.title })
    revalidatePath(`/[lang]/admin/entrevistas`, 'page')
    revalidateTag('interviews')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function restoreInterview(id) {
  try {
    if (!id) return { success: false, error: 'ID da entrevista é obrigatório.' }

    const ctx = await requireSuperAdmin()
    if (!ctx) return { success: false, error: 'Operação restrita a superadmin.' }

    const { supabase, user } = ctx

    const { error } = await supabase
      .from('interviews')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao restaurar entrevista.' }

    await logAudit(supabase, user, 'UPDATE', 'interviews', id, { action: 'restore' })
    revalidatePath(`/[lang]/admin/entrevistas`, 'page')
    revalidateTag('interviews')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

export async function deleteInterview(id) {
  try {
    if (!id) return { success: false, error: 'ID da entrevista é obrigatório.' }

    const ctx = await requireSuperAdmin()
    if (!ctx) return { success: false, error: 'Operação restrita a superadmin.' }

    const { supabase, user } = ctx

    const { data: interview } = await supabase
      .from('interviews')
      .select('title')
      .eq('id', id)
      .single()

    const { error } = await supabase.from('interviews').delete().eq('id', id)

    if (error) {
      return { success: false, error: 'Erro ao eliminar entrevista.' }
    }

    await logAudit(supabase, user, 'DELETE', 'interviews', id, { title: interview?.title })
    revalidatePath(`/[lang]/admin/entrevistas`, 'page')
    revalidateTag('interviews')

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}
