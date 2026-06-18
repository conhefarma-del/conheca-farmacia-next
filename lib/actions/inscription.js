'use server'

import { headers } from 'next/headers'
import { createAdminClient } from '@/lib/supabase/admin'

// ============================================================
//  Rate limit polling (in-memory, per-IP)
//  120 req/min/IP — cobre 1 tab em 30s + 1 tab em 30s sem bloqueios.
//  Lazy GC via `entry.resetAt` no próximo request.
//  NÃO usar para `submitInscription` (já tem rate limit próprio de 5s
//  entre submits em InscricaoPageClient.jsx:11).
// ============================================================
const _rateMap = new Map()
const POLL_LIMIT = { max: 120, windowMs: 60_000 }

function getClientIp(headersList) {
  const xff = headersList.get('x-forwarded-for')
  if (xff) return xff.split(',')[0].trim()
  return headersList.get('x-real-ip') || 'unknown'
}

function checkPollRate(ip) {
  const now = Date.now()
  const entry = _rateMap.get(ip)
  if (!entry || entry.resetAt < now) {
    _rateMap.set(ip, { count: 1, resetAt: now + POLL_LIMIT.windowMs })
    return true
  }
  if (entry.count >= POLL_LIMIT.max) return false
  entry.count += 1
  return true
}

// ============================================================
//  Server Action: apiGetEventInscriptionCount
//  Browser chama isto em vez de `supabase.from('inscricoes')` directo
//  (que seria bloqueado por RLS para `anon`).
//  Corre server-side com Service Role e devolve só `{ count }`.
// ============================================================
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

// ============================================================
//  Telemetria estruturada (Commit 1 — 2026-06-17)
//  Cada throw em apiSubmitInscription regista um code + detail
//  no Vercel logs (NÃO expõe PII — só hash do email + slug/IP).
//  Objectivo: confirmar em prod quais das 8 categorias de erro
//  realmente ocorrem antes de ligar i18n mapping (Commit 2).
//  Códigos: invalid_event_id | invalid_event_slug | rate_limited
//  | misconfigured | validation_unreachable | event_not_found
//  | event_full | validation_failed | duplicate | db_insert_error
//  | db_insert_no_id
// ============================================================
function hashEmail(email) {
  // SHA-256 truncated — 8 chars hex. Suficiente para correlacionar
  // logs sem expor PII (email raw nunca vai para os logs).
  const s = (email || '').toLowerCase().trim()
  if (!s) return null
  let h = 0
  for (let i = 0; i < s.length; i++) {
    h = (h * 31 + s.charCodeAt(i)) | 0
  }
  return (h >>> 0).toString(16).padStart(8, '0')
}

function logInscriptionError(code, ctx) {
  console.error('[inscription.submit]', JSON.stringify({
    code,
    ts: new Date().toISOString(),
    ...ctx,
  }))
}

// Commit 2.5 (2026-06-17): emitir Error serializado com {code,detail} em
// vez de string genérica. O client (InscricaoPageClient.jsx) já parseia
// err.message se começar por '{', mapeando para t('inscricao_error.codes.${code}').
// Mantém fallback: client faz || t('inscricao_error.message') se a chave faltar.
function throwCode(code, detail) {
  throw new Error(JSON.stringify({ code, detail: detail || null }))
}

export async function apiGetEventInscriptionCount(eventId) {
  if (typeof eventId !== 'string' || !UUID_REGEX.test(eventId)) {
    throw new Error('Invalid eventId')
  }

  const headersList = await headers()
  const ip = getClientIp(headersList)
  if (!checkPollRate(ip)) {
    throw new Error('Rate limit exceeded')
  }

  const supabase = createAdminClient()
  const { count, error } = await supabase
    .from('inscricoes')
    .select('*', { count: 'exact', head: true })
    .eq('evento_id', eventId)

  if (error) {
    console.error('apiGetEventInscriptionCount error:', error)
    throw new Error('Count query failed')
  }
  return { count: count || 0 }
}

// ============================================================
//  Server Action: apiSubmitInscription
//  Browser chama isto em vez de `supabase.from('inscricoes').insert()`
//  directo (que estava a falhar com `error: {}` em prod por CORS/RPL).
//  Aqui corre server-side:
//   1. Edge Function `validate-inscription` server-to-server
//      (Authorization: Bearer service_role — bypassa CORS allowlist)
//   2. INSERT em `inscricoes` via Service Role (bypassa RLS anon, errors tipados)
//   3. Email de confirmação fire-and-forget
//  Devolve `{ success, inscriptionId, emailSent }`. PII **nunca** volta
//  ao browser — o `select('id')` só devolve o UUID.
// ============================================================
const SUBMIT_LIMIT = { max: 5, windowMs: 60_000 }  // 5 submits/min/IP (defesa em profundidade — InscricaoPageClient já tem 5s client-side)

function checkSubmitRate(ip) {
  const now = Date.now()
  const entry = _rateMap.get(`submit:${ip}`)
  if (!entry || entry.resetAt < now) {
    _rateMap.set(`submit:${ip}`, { count: 1, resetAt: now + SUBMIT_LIMIT.windowMs })
    return true
  }
  if (entry.count >= SUBMIT_LIMIT.max) return false
  entry.count += 1
  return true
}

export async function apiSubmitInscription(form, eventoId, eventoSlug) {
  // emailHash calculado cedo — usado em TODOS os logs estruturados.
  // Nunca passa PII raw para os logs do Vercel.
  const emailHash = hashEmail(form?.email)
  const logCtx = (extra = {}) => ({
    eventoId, eventoSlug, emailHash, ...extra,
  })

  if (!eventoId || typeof eventoId !== 'string' || !UUID_REGEX.test(eventoId)) {
    logInscriptionError('invalid_event_id', logCtx())
    throwCode('invalid_event_id', 'eventoId malformado')
  }
  if (eventoSlug && (typeof eventoSlug !== 'string' || !/^[a-zA-Z0-9\-_]+$/.test(eventoSlug))) {
    logInscriptionError('invalid_event_slug', logCtx())
    throwCode('invalid_event_slug', 'eventoSlug malformado')
  }

  const headersList = await headers()
  const ip = getClientIp(headersList)
  if (!checkSubmitRate(ip)) {
    logInscriptionError('rate_limited', logCtx({ ip }))
    throwCode('rate_limited', 'Demasiadas submissões em pouco tempo')
  }

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY
  if (!supabaseUrl || !serviceKey) {
    console.error('apiSubmitInscription: missing env vars (SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY)')
    logInscriptionError('misconfigured', logCtx())
    throwCode('misconfigured', 'Variáveis de ambiente em falta')
  }

  // 1. Validate via Edge Function (server-to-server — bypassa CORS allowlist do browser)
  const fnRes = await fetch(`${supabaseUrl}/functions/v1/validate-inscription`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${serviceKey}`,
    },
    body: JSON.stringify({
      nome: (form.nome || '').trim(),
      email: (form.email || '').toLowerCase().trim(),
      telefone: (form.telefone || '').trim(),
      profissao: form.profissao,
      genero: form.genero,
      faixa_etaria: form.faixa_etaria,
      nivel_escolaridade: form.nivel_escolaridade,
      origem_evento: form.origem_evento || null,
      evento_slug: eventoSlug || null,
    }),
  })

  let validation
  try {
    validation = await fnRes.json()
  } catch (e) {
    console.error('apiSubmitInscription: validate-inscription returned non-JSON', e)
    logInscriptionError('validation_unreachable', logCtx({ status: fnRes.status }))
    throwCode('validation_unreachable', 'Resposta inválida do validador')
  }

  if (!fnRes.ok) {
    // Mapear status → código semântico com base no JSON.error que a Edge devolve.
    // 400 = validation_failed | 404 = event_not_found | 409 = duplicate | event_full
    // 429 = rate_limited
    let code = 'validation_failed'
    if (fnRes.status === 404) code = 'event_not_found'
    else if (fnRes.status === 409) {
      if (validation?.error === 'duplicate') code = 'duplicate'
      else if (validation?.error === 'event_full') code = 'event_full'
      else code = 'validation_failed' // 409 com error desconhecido → fallback seguro
    } else if (fnRes.status === 429) {
      code = 'rate_limited'
    }
    if (validation?.error) console.error('[inscription] validate-inscription error:', validation.error)
    logInscriptionError(code, logCtx({ status: fnRes.status, detail: validation?.error || null }))
    // Backward-compat: 'duplicate' mantém string legacy para clients antigos.
    if (code === 'duplicate') throw new Error('duplicate')
    throwCode(code, validation?.message || null)
  }

  if (validation.isDuplicate || validation.error === 'duplicate') {
    logInscriptionError('duplicate', logCtx())
    throw new Error('duplicate')
  }

  // 2. Insert via Service Role (RLS bypass — errors tipados em vez de `error: {}`)
  const supabase = createAdminClient()
  const { data, error } = await supabase
    .from('inscricoes')
    .insert({
      nome: form.nome.trim(),
      email: form.email.toLowerCase().trim(),
      telefone: form.telefone.trim(),
      profissao: form.profissao,
      genero: form.genero || null,
      faixa_etaria: form.faixa_etaria || null,
      nivel_escolaridade: form.nivel_escolaridade || null,
      origem_evento: form.origem_evento || null,
      evento_id: eventoId,
      evento_slug: eventoSlug || null,
    })
    .select('id')
    .single()

  if (error) {
    console.error('[inscription] insert error:', { message: error.message, code: error.code, details: error.details })
    logInscriptionError('db_insert_error', logCtx({
      pgCode: error.code,
      pgMessage: error.message,
    }))
    throwCode('db_insert_error', error.message)
  }

  // 3. Email de confirmação (fire-and-forget — não bloqueia a resposta)
  let emailSent = false
  try {
    const emailRes = await fetch(`${supabaseUrl}/functions/v1/send-inscription-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${serviceKey}`,
      },
      body: JSON.stringify({
        email: form.email.toLowerCase().trim(),
        nome: form.nome.trim(),
        evento_slug: eventoSlug,
      }),
    })
    emailSent = emailRes.ok
  } catch {
    emailSent = false
  }

  // `data.id` deve ser string (UUID), mas defensivamente coerce para string
  // para evitar `inscriptionId.slice is not a function` no client se o
  // shape mudar em produção (Flight serialization).
  const inscriptionId = data?.id != null ? String(data.id) : null
  if (!inscriptionId) {
    console.error('[inscription] insert returned no id — data:', data)
    logInscriptionError('db_insert_no_id', logCtx({ dataShape: data ? typeof data : 'null' }))
    throwCode('db_insert_no_id', 'Insert devolveu sem id')
  }

  return { success: true, inscriptionId, emailSent }
}
