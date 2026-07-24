'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

// ============================================================
//  Helper: requireAdmin (reuse pattern from content.js)
// ============================================================
async function requireAdmin() {
  const supabase = await createClient()

  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) return null

    const { data: adminUser, error: adminError } = await supabase
      .from('admin_users')
      .select('user_id, role')
      .eq('user_id', user.id)
      .maybeSingle()

    if (adminError || !adminUser) return null

    return { supabase, user, role: adminUser.role }
  } catch {
    return null
  }
}

// ============================================================
//  PUBLIC DATA — FAQ
// ============================================================

/**
 * Retorna dados públicos da FAQ: tabs com questions não-pending e não-archived.
 * Usado na página pública /[lang]/faq.
 */
export async function getPublicFAQData() {
  const supabase = await createClient()

  try {
    // Buscar tabs não-archived, ordenadas
    const { data: tabs, error: tabsError } = await supabase
      .from('faq_tabs')
      .select('id, slug, label_pt, label_en, sort_order')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })

    if (tabsError || !tabs) return []

    // Buscar questions não-archived, ordenadas
    const { data: allQuestions, error: qError } = await supabase
      .from('faq_questions')
      .select('id, tab_id, question_pt, question_en, answer_pt, answer_en, pending, sort_order')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })

    if (qError || !allQuestions) return []

    // Estruturar: tabs → questions, filtrar tab se 0 visible questions
    const result = tabs.map((tab) => {
      const questions = allQuestions
        .filter((q) => q.tab_id === tab.id)
        .map((q) => ({
          id: q.id,
          question_pt: q.question_pt,
          question_en: q.question_en,
          answer_pt: q.answer_pt,
          answer_en: q.answer_en,
          pending: q.pending,
        }))

      // Filtrar: tab só aparece se tiver pelo menos 1 question visible (non-pending)
      const visibleCount = questions.filter((q) => !q.pending).length
      if (visibleCount === 0) return null

      return {
        id: tab.id,
        slug: tab.slug,
        label_pt: tab.label_pt,
        label_en: tab.label_en,
        questions,
      }
    }).filter(Boolean) // Remove tabs nulas (0 visible questions)

    return result
  } catch {
    return []
  }
}

// ============================================================
//  PUBLIC DATA — Privacy Policy
// ============================================================

/**
 * Retorna dados públicos da política de privacidade: secções hierárquicas.
 * Secções pending são incluídas com flag pending=true (mostrar badge).
 */
export async function getPublicPrivacyData() {
  const supabase = await createClient()

  try {
    const { data: sections, error } = await supabase
      .from('privacy_sections')
      .select('id, parent_id, anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order')
      .eq('is_archived', false)
      .order('sort_order', { ascending: true })

    if (error || !sections) return []

    // Estruturar hierarquia: level 1 com children level 2
    const level1 = sections.filter((s) => s.level === 1)
    const level2 = sections.filter((s) => s.level === 2)

    return level1.map((section) => ({
      id: section.id,
      anchor_slug: section.anchor_slug,
      title_pt: section.title_pt,
      title_en: section.title_en,
      content_pt: section.content_pt,
      content_en: section.content_en,
      pending: section.pending,
      children: level2
        .filter((child) => child.parent_id === section.id)
        .map((child) => ({
          id: child.id,
          anchor_slug: child.anchor_slug,
          title_pt: child.title_pt,
          title_en: child.title_en,
          content_pt: child.content_pt,
          content_en: child.content_en,
          pending: child.pending,
        })),
    }))
  } catch {
    return []
  }
}

// ============================================================
//  ADMIN — FAQ Tabs CRUD
// ============================================================

export async function getFAQTabs() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_tabs')
      .select('*')
      .order('sort_order', { ascending: true })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

export async function createFAQTab({ slug, label_pt, label_en, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_tabs')
      .insert({ slug, label_pt, label_en, sort_order: sort_order || 0 })
      .select()
      .single()

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true, data }
  } catch {
    return { success: false, error: 'Erro ao criar separador' }
  }
}

export async function updateFAQTab(id, { slug, label_pt, label_en, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_tabs')
      .update({ slug, label_pt, label_en, sort_order })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar separador' }
  }
}

export async function archiveFAQTab(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase, user } = ctx
  try {
    const { error } = await supabase
      .from('faq_tabs')
      .update({
        is_archived: true,
        archived_at: new Date().toISOString(),
        archived_by: user.id,
      })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao arquivar separador' }
  }
}

export async function restoreFAQTab(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_tabs')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao restaurar separador' }
  }
}

// ============================================================
//  ADMIN — FAQ Questions CRUD
// ============================================================

export async function getFAQQuestions(tabId) {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_questions')
      .select('*')
      .eq('tab_id', tabId)
      .order('sort_order', { ascending: true })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

export async function createFAQQuestion({ tab_id, question_pt, question_en, answer_pt, answer_en, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('faq_questions')
      .insert({
        tab_id,
        question_pt,
        question_en,
        answer_pt: answer_pt || '',
        answer_en: answer_en || '',
        pending: pending !== false,
        sort_order: sort_order || 0,
      })
      .select()
      .single()

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true, data }
  } catch {
    return { success: false, error: 'Erro ao criar pergunta' }
  }
}

export async function updateFAQQuestion(id, { question_pt, question_en, answer_pt, answer_en, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_questions')
      .update({ question_pt, question_en, answer_pt, answer_en, pending, sort_order })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar pergunta' }
  }
}

export async function archiveFAQQuestion(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase, user } = ctx
  try {
    const { error } = await supabase
      .from('faq_questions')
      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao arquivar pergunta' }
  }
}

export async function restoreFAQQuestion(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('faq_questions')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/faq')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao restaurar pergunta' }
  }
}

// ============================================================
//  ADMIN — Privacy Sections CRUD
// ============================================================

export async function getPrivacySections() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('privacy_sections')
      .select('*')
      .order('sort_order', { ascending: true })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

export async function createPrivacySection({ parent_id, anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { data, error } = await supabase
      .from('privacy_sections')
      .insert({
        parent_id: parent_id || null,
        anchor_slug,
        title_pt,
        title_en,
        content_pt: content_pt || '',
        content_en: content_en || '',
        level: level || 1,
        pending: pending || false,
        sort_order: sort_order || 0,
      })
      .select()
      .single()

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true, data }
  } catch {
    return { success: false, error: 'Erro ao criar secção' }
  }
}

export async function updatePrivacySection(id, { anchor_slug, title_pt, title_en, content_pt, content_en, pending, sort_order }) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('privacy_sections')
      .update({ anchor_slug, title_pt, title_en, content_pt, content_en, pending, sort_order })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao atualizar secção' }
  }
}

export async function archivePrivacySection(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Não autorizado' }

  const { supabase, user } = ctx
  try {
    const { error } = await supabase
      .from('privacy_sections')
      .update({ is_archived: true, archived_at: new Date().toISOString(), archived_by: user.id })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao arquivar secção' }
  }
}

export async function restorePrivacySection(id) {
  const ctx = await requireAdmin()
  if (!ctx || ctx.role !== 'superadmin') return { success: false, error: 'Não autorizado' }

  const { supabase } = ctx
  try {
    const { error } = await supabase
      .from('privacy_sections')
      .update({ is_archived: false, archived_at: null, archived_by: null })
      .eq('id', id)

    if (error) return { success: false, error: error.message }
    revalidatePath('/[lang]/admin/conteudo-legal/politica-privacidade')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro ao restaurar secção' }
  }
}
