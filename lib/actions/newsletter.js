'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { headers } from 'next/headers'

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

// SEC (vistoria o-sentinela 2026-08-11, #6): rate limit DB-backed para
// sendWelcomeEmail (check_rate_limit/log_auth_attempt, attempt='welcome_email')
// — partilhado entre instâncias, ao contrário do Map in-memory anterior. Este
// Server Action envia emails de verdade; sem limite era um vetor de spam de
// email (auditoria #9/#10). 10 pedidos/5min por IP/email, fail-open.
const WELCOME_MAX = 10
const WELCOME_WINDOW_SECONDS = 300

async function isWelcomeEmailRateLimited(supabase, ip, emailHash) {
  try {
    const { data, error } = await supabase.rpc('check_rate_limit', {
      p_ip: ip,
      p_email_hash: emailHash,
      p_attempt_type: 'welcome_email',
      p_max_attempts: WELCOME_MAX,
      p_window_seconds: WELCOME_WINDOW_SECONDS,
    })
    if (error) throw error
    // Regista a tentativa para o contador funcionar (o check conta linhas).
    await supabase.rpc('log_auth_attempt', {
      p_ip: ip,
      p_email_hash: emailHash,
      p_attempt_type: 'welcome_email',
      p_success: true,
      p_user_id: null,
    })
    return data === true
  } catch {
    return false // falha aberta — não bloquear por erro de RPC
  }
}

// djb2 8-char hex (espelha lib/actions/inscription.js hashEmail e
// supabase/functions/_shared/hash.ts para correlação de logs).
function hashEmail(email) {
  const s = (email || '').toLowerCase().trim()
  if (!s) return null
  let h = 0
  for (let i = 0; i < s.length; i++) {
    h = (h * 31 + s.charCodeAt(i)) | 0
  }
  return (h >>> 0).toString(16).padStart(8, '0')
}

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
  try {
    const ctx = await requireAdmin()
    if (!ctx) {
      console.error('[newsletter] getSubscribers: requireAdmin returned null — user not authenticated or not admin')
      return []
    }

    const { supabase } = ctx

    const { data, error } = await supabase
      .from('newsletter')
      .select('id, email, status, created_at, updated_at')
      .order('created_at', { ascending: false })

    if (error) {
      console.error('[newsletter] getSubscribers: query error:', error.message)
      return []
    }
    return data || []
  } catch (err) {
    console.error('[newsletter] getSubscribers: exception:', err?.message)
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

    // Enviar emails via Edge Function (paralelizado em batches para não
    // ultrapassar o wall-time de ~150s das Edge Functions Supabase com
    // envios em série). 10 concorrentes cobre o limite prático.
    const BATCH_SIZE = 10
    const results = []
    for (let i = 0; i < targetSubs.length; i += BATCH_SIZE) {
      const batch = targetSubs.slice(i, i + BATCH_SIZE)
      const batchResults = await Promise.allSettled(
        batch.map((subscriber) =>
          fetch(`${SUPABASE_URL}/functions/v1/send-newsletter-email`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
              // SEC (vistoria 2026-08-11): a Edge exige o segredo partilhado.
              'x-internal-key': process.env.EDGE_INTERNAL_KEY,
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
        )
      )
      batchResults.forEach((r, idx) => {
        const email = batch[idx].email
        const success = r.status === 'fulfilled' && r.value.ok
        results.push({ email, success })
        if (!success) {
          console.error('[newsletter.broadcast] code=brevo_send_failed emailHash=', hashEmail(email))
        }
      })
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
 * Subscrição pública à newsletter (SEC vistoria 2026-08-11).
 * Substitui a chamada direta do cliente à RPC subscribe_newsletter: a RPC
 * era invocável com a anon key (pública) sem qualquer limite — um atacante
 * podia encher a tabela newsletter com inserts ilimitados e envenenar a
 * lista. Agora passa por esta Server Action com rate limit DB-backed
 * (check_rate_limit, o mesmo padrão de login/inscrição).
 */
export async function subscribeNewsletterAction(email) {
  try {
    if (!email || typeof email !== 'string') {
      return { success: false, error: 'Email inválido.' }
    }

    const supabase = await createClient()
    let ip = null
    try {
      const headersList = await headers()
      ip = headersList.get('x-forwarded-for')?.split(',')[0]?.trim() || null
    } catch {}
    const emailHash = hashEmail(email)

    // SEC-ATH-05: rate limit DB-backed — 5 por 5 minutos por IP/email.
    // Falha aberta por erro de RPC (padrão auth.js/inscription.js).
    let limited = false
    try {
      const { data, error } = await supabase.rpc('check_rate_limit', {
        p_ip: ip,
        p_email_hash: emailHash,
        p_attempt_type: 'newsletter',
        p_max_attempts: 5,
        p_window_seconds: 300,
      })
      if (error) throw error
      limited = data === true
    } catch {
      limited = false
    }

    // Regista a tentativa para o contador do check_rate_limit funcionar
    // (o check conta linhas em auth_attempts — sem log, o limite nunca
    // dispara). Registado antes de devolver, limitado ou não.
    try {
      await supabase.rpc('log_auth_attempt', {
        p_ip: ip,
        p_email_hash: emailHash,
        p_attempt_type: 'newsletter',
        p_success: !limited,
        p_user_id: null,
      })
    } catch {
      // falha silenciosa — não quebrar o fluxo principal
    }

    if (limited) {
      return {
        success: false,
        rateLimited: true,
        error: 'Demasiados pedidos. Tenta novamente em 5 minutos.',
      }
    }

    // A RPC valida formato, gere reativação de unsubscribed/bounced e
    // devolve o unsubscribe_token (contrato da migration 050).
    const { data, error } = await supabase.rpc('subscribe_newsletter', {
      p_email: email.toLowerCase().trim(),
    })

    if (error) {
      console.error('[newsletter] subscribeNewsletterAction: RPC error:', error.message, error.code)
      if (error.message?.includes('already')) {
        return { success: false, exists: true }
      }
      return { success: false, error: error.message || 'Erro ao subscrever.' }
    }

    console.log('[newsletter] subscribeNewsletterAction: success emailHash=', emailHash)
    return { success: true, unsubscribeToken: data?.unsubscribe_token || null }
  } catch (err) {
    console.error('[newsletter] subscribeNewsletterAction: exception:', err?.message, err?.stack)
    return { success: false, error: 'Erro interno. Tenta novamente.' }
  }
}

/**
 * Enviar email de boas-vindas após subscrição pública.
 * Não requer auth — chamado pelo NewsletterSection.
 *
 * Correção auditoria #9: o token vem do parâmetro (devolvido pela RPC
 * subscribe_newsletter, migration 050) em vez de um SELECT anon a newsletter —
 * o RLS bloqueava essa leitura e o email nunca era enviado ("Subscritor não
 * encontrado"). O token é o do próprio subscritor que acabou de subscrever.
 * SEC-#10: rate limit por IP para evitar spam via este endpoint.
 */
export async function sendWelcomeEmail(email, unsubscribeToken = null) {
  const headersList = await headers()
  const ip = headersList.get('x-forwarded-for')?.split(',')[0]?.trim() || null
  const emailHash = hashEmail(email)

  // SEC (#6): rate limit DB-backed antes de enviar email.
  const supabase = await createClient()
  if (await isWelcomeEmailRateLimited(supabase, ip, emailHash)) {
    return { success: false, error: 'Demasiados pedidos. Tenta novamente em 5 minutos.' }
  }

  try {
    if (!unsubscribeToken) {
      return { success: false, error: 'Subscritor não encontrado.' }
    }

    // Chamar Edge Function
    const response = await fetch(`${SUPABASE_URL}/functions/v1/send-newsletter-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        // SEC (vistoria 2026-08-11): a Edge exige o segredo partilhado.
        'x-internal-key': process.env.EDGE_INTERNAL_KEY,
      },
      body: JSON.stringify({
        type: 'welcome',
        email,
        nome: email.split('@')[0],
        unsubscribeToken,
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
