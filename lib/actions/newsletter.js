'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

/**
 * SEC-ATH-02: Helper — verifica sessão + admin_users.
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
 * Buscar todos os subscritores (admin).
 * SEC-API-03: colunas explícitas.
 */
export async function getSubscribers() {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    const { data, error } = await supabase
      .from('newsletter')
      .select('id, email, status, created_at, updated_at')
      .order('created_at', { ascending: false })

    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Estatísticas de newsletter.
 */
export async function getNewsletterStats() {
  const ctx = await requireAdmin()
  if (!ctx) return { total: 0, active: 0, unsubscribed: 0 }

  const { supabase } = ctx

  try {
    const now = new Date()
    const firstOfMonth = new Date(now.getFullYear(), now.getMonth(), 1).toISOString()

    const [totalResult, activeResult, unsubResult, sentResult] = await Promise.all([
      supabase.from('newsletter').select('*', { count: 'exact', head: true }),
      supabase.from('newsletter').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabase.from('newsletter').select('*', { count: 'exact', head: true }).eq('status', 'unsubscribed'),
      supabase.from('email_logs').select('*', { count: 'exact', head: true }).gte('sent_at', firstOfMonth),
    ])

    return {
      total: totalResult.count || 0,
      active: activeResult.count || 0,
      unsubscribed: unsubResult.count || 0,
      sentThisMonth: sentResult.count || 0,
    }
  } catch {
    return { total: 0, active: 0, unsubscribed: 0 }
  }
}

/**
 * Buscar conteúdo publicado (para o dropdown de envio de alertas).
 * SEC-API-03: colunas explícitas por tabela.
 */
export async function getPublishedContent(type = 'article') {
  const ctx = await requireAdmin()
  if (!ctx) return []

  const { supabase } = ctx

  try {
    let query

    if (type === 'article') {
      query = supabase
        .from('articles')
        .select('id, slug, title, excerpt, published_date')
        .eq('status', 'published')
        .order('published_date', { ascending: false })
    } else if (type === 'event') {
      query = supabase
        .from('events')
        .select('id, slug, title, excerpt, date, location')
        .eq('status', 'published')
        .order('date', { ascending: false })
    } else {
      query = supabase
        .from('lives')
        .select('id, slug, title, excerpt, date, platform')
        .eq('status', 'published')
        .order('date', { ascending: false })
    }

    const { data, error } = await query
    if (error) return []
    return data || []
  } catch {
    return []
  }
}

/**
 * Enviar alerta de conteúdo para subscritores.
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function sendContentAlert(type, content, targetEmails, sendMode = 'all') {
  const ctx = await requireAdmin()
  if (!ctx) {
    return { success: false, error: 'Sessão expirada. Faça login novamente.' }
  }

  const { supabase } = ctx

  try {
    if (!content?.title || !content?.url) {
      return { success: false, error: 'Título e URL do conteúdo são obrigatórios.' }
    }

    // Buscar subscritores ativos
    let query = supabase
      .from('newsletter')
      .select('email, unsubscribe_token')
      .eq('status', 'active')

    if (sendMode === 'manual' && targetEmails?.length > 0) {
      query = query.in('email', targetEmails)
    }

    const { data: subscribers, error: fetchError } = await query

    if (fetchError) return { success: false, error: 'Erro ao buscar subscritores.' }

    let targetSubs = subscribers || []

    // Modo aleatório: selecionar N aleatórios
    if (sendMode === 'random' && targetEmails?.length === 1) {
      const count = Math.min(parseInt(targetEmails[0]) || 10, targetSubs.length)
      const shuffled = [...targetSubs].sort(() => Math.random() - 0.5)
      targetSubs = shuffled.slice(0, count)
    }

    if (targetSubs.length === 0) {
      return { success: false, error: 'Nenhum subscritor ativo selecionado.' }
    }

    // Enviar emails via Edge Function
    const results = []
    for (const subscriber of targetSubs) {
      try {
        const response = await fetch(`${SUPABASE_URL}/functions/v1/send-newsletter-email`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          },
          body: JSON.stringify({
            type,
            email: subscriber.email,
            contentTitle: content.title,
            contentUrl: content.url,
            contentDescription: content.description || '',
            contentDate: content.date || '',
            contentPlatform: content.platform || '',
            contentLocation: content.location || '',
            unsubscribeToken: subscriber.unsubscribe_token,
          }),
        })
        results.push({ email: subscriber.email, success: response.ok })
      } catch {
        results.push({ email: subscriber.email, success: false })
      }
    }

    const sent = results.filter(r => r.success).length

    // Log successful sends to email_logs
    const logsToInsert = results
      .filter(r => r.success)
      .map(r => ({
        email_type: type,
        recipient_email: r.email,
        content_slug: content?.slug || null,
      }))

    if (logsToInsert.length > 0) {
      await supabase.from('email_logs').insert(logsToInsert)
    }

    return { success: true, sent, total: targetSubs.length }
  } catch {
    return { success: false, error: 'Erro interno. Tente novamente.' }
  }
}

/**
 * Enviar email de boas-vindas após subscrição pública.
 * Não requer auth — chamado pelo NewsletterSection.
 */
export async function sendWelcomeEmail(email) {
  const supabase = await createClient()

  try {
    // Buscar o token de unsubscribe do subscritor
    const { data: subscriber, error } = await supabase
      .from('newsletter')
      .select('unsubscribe_token')
      .eq('email', email.toLowerCase().trim())
      .eq('status', 'active')
      .single()

    if (error || !subscriber) {
      return { success: false, error: 'Subscritor não encontrado.' }
    }

    // Chamar Edge Function
    const response = await fetch(`${SUPABASE_URL}/functions/v1/send-newsletter-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        type: 'welcome',
        email,
        nome: email.split('@')[0],
        unsubscribeToken: subscriber.unsubscribe_token,
      }),
    })

    if (!response.ok) {
      return { success: false, error: 'Erro ao enviar email.' }
    }

    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno.' }
  }
}

/**
 * Cancelar inscrição (soft delete).
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function unsubscribeSubscriber(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Sessão expirada.' }

  const { supabase } = ctx

  try {
    const { error } = await supabase
      .from('newsletter')
      .update({ status: 'unsubscribed', updated_at: new Date().toISOString() })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao cancelar inscrição.' }

    revalidatePath(`/[lang]/admin/newsletter`, 'page')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno.' }
  }
}

/**
 * Reativar subscritor.
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function reactivateSubscriber(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Sessão expirada.' }

  const { supabase } = ctx

  try {
    const { error } = await supabase
      .from('newsletter')
      .update({ status: 'active', updated_at: new Date().toISOString() })
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao reativar subscritor.' }

    revalidatePath(`/[lang]/admin/newsletter`, 'page')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno.' }
  }
}

/**
 * Apagar subscritor permanentemente (hard delete).
 * SEC-ATH-02: Verifica sessão + admin_users.
 */
export async function deleteSubscriber(id) {
  const ctx = await requireAdmin()
  if (!ctx) return { success: false, error: 'Sessão expirada.' }

  const { supabase } = ctx

  try {
    const { error } = await supabase
      .from('newsletter')
      .delete()
      .eq('id', id)

    if (error) return { success: false, error: 'Erro ao apagar subscritor.' }

    revalidatePath(`/[lang]/admin/newsletter`, 'page')
    return { success: true }
  } catch {
    return { success: false, error: 'Erro interno.' }
  }
}
