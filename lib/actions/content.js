'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath, revalidateTag } from 'next/cache'
import { isValidHexColor, validateUrl } from '@/lib/security'
import { sanitizeHtml } from '@/lib/sanitize'

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
