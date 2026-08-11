'use server'

import { createClient } from '@/lib/supabase/server'
import { headers } from 'next/headers'

// SEC (vistoria o-sentinela 2026-08-11): os endpoints de analytics são
// públicos (anon) e sem limite um atacante podia encher page_views com
// linhas lixo e inflar contadores (métricas falsas + custo DB). O rate
// limit é DB-backed (check_rate_limit/log_auth_attempt, attempt='analytics')
// — o mesmo padrão de login/inscrição, partilhado entre instâncias.
const ANALYTICS_MAX = 120
const ANALYTICS_WINDOW_SECONDS = 300

// path: 1–500 chars, sem caracteres de controlo nem HTML (evita XSS/injecção
// de conteúdo na tabela page_views, lida pelo admin).
const PATH_RE = /^[^\x00-\x1f\x7f<>"']{1,500}$/
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const SLUG_RE = /^[a-zA-Z0-9_-]{1,200}$/

/**
 * Check + regista em auth_attempts. Retorna true se rate limited.
 * Falha aberta por erro de RPC (padrão auth.js/inscription.js).
 */
async function rateLimitAnalytics() {
  try {
    const supabase = await createClient()
    const headersList = await headers()
    const ip = headersList.get('x-forwarded-for')?.split(',')[0]?.trim() || null

    const { data, error } = await supabase.rpc('check_rate_limit', {
      p_ip: ip,
      p_email_hash: null,
      p_attempt_type: 'analytics',
      p_max_attempts: ANALYTICS_MAX,
      p_window_seconds: ANALYTICS_WINDOW_SECONDS,
    })
    if (error) throw error

    // O check conta linhas — sem este log o contador nunca sobe.
    await supabase.rpc('log_auth_attempt', {
      p_ip: ip,
      p_email_hash: null,
      p_attempt_type: 'analytics',
      p_success: true,
      p_user_id: null,
    })

    return data === true
  } catch {
    return false // falha aberta — não bloquear analytics por erro de RPC
  }
}

export async function incrementViewCount(articleSlug) {
  if (typeof articleSlug !== 'string' || !SLUG_RE.test(articleSlug)) return
  if (await rateLimitAnalytics()) return
  const supabase = await createClient()
  await supabase.rpc('increment_view_count', { article_slug: articleSlug })
}

export async function incrementShareCount(articleId) {
  if (typeof articleId !== 'string' || !UUID_RE.test(articleId)) return
  if (await rateLimitAnalytics()) return
  const supabase = await createClient()
  await supabase.rpc('increment_share_count', { row_id: articleId })
}

export async function addReadingTime(articleId, seconds) {
  if (typeof articleId !== 'string' || !UUID_RE.test(articleId)) return
  if (!Number.isInteger(seconds) || seconds < 1 || seconds > 3600) return
  if (await rateLimitAnalytics()) return
  const supabase = await createClient()
  await supabase.rpc('add_reading_time', { row_id: articleId, seconds })
}

export async function incrementEventViewCount(eventSlug) {
  if (typeof eventSlug !== 'string' || !SLUG_RE.test(eventSlug)) return
  if (await rateLimitAnalytics()) return
  const supabase = await createClient()
  await supabase.rpc('increment_event_view_count', { event_slug: eventSlug })
}

export async function incrementLiveViewCount(liveSlug) {
  if (typeof liveSlug !== 'string' || !SLUG_RE.test(liveSlug)) return
  if (await rateLimitAnalytics()) return
  const supabase = await createClient()
  await supabase.rpc('increment_live_view_count', { live_slug: liveSlug })
}

export async function incrementLiveAccessCount(liveSlug) {
  if (typeof liveSlug !== 'string' || !SLUG_RE.test(liveSlug)) return
  if (await rateLimitAnalytics()) return
  const supabase = await createClient()
  await supabase.rpc('increment_live_access_count', { live_slug: liveSlug })
}

export async function incrementLiveDownloadCount(liveSlug) {
  if (typeof liveSlug !== 'string' || !SLUG_RE.test(liveSlug)) return
  if (await rateLimitAnalytics()) return
  const supabase = await createClient()
  await supabase.rpc('increment_live_download_count', { live_slug: liveSlug })
}

export async function trackPageView(path, referrer, sessionId) {
  // Validação server-side (o client é contornável): path é a única entrada
  // que fica gravada em page_views com visibilidade admin.
  if (typeof path !== 'string' || !PATH_RE.test(path)) return

  let cleanReferrer = null
  if (referrer) {
    if (typeof referrer === 'string' && referrer.length <= 500 && !/[\x00-\x1f\x7f]/.test(referrer)) {
      cleanReferrer = referrer
    }
  }

  if (typeof sessionId !== 'string' || !UUID_RE.test(sessionId)) return
  if (await rateLimitAnalytics()) return

  const supabase = await createClient()
  await supabase.from('page_views').insert({
    page_path: path,
    referrer: cleanReferrer,
    session_id: sessionId,
  })
}
