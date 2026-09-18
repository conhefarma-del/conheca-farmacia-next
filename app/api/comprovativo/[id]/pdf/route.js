// GET /api/comprovativo/[id]/pdf?code=<share_code>&lang=pt|en
//
// Gera o PDF do comprovativo de inscrição (A4 landscape, design
// boarding-pass igual ao do ecrã) via satori → resvg-js → pdf-lib.
//
// Acesso: o PDF contém PII (nome, email). O id é sequencial/previsível,
// pelo que o endpoint exige `code` = share_code (secreto, aleatório,
// migração 253). Sem código, código inválido ou id inexistente → 404
// idêntico (sem enumeração). O link completo vive na página de sucesso
// e no modal admin (Inscritos).
//
// História: um pipeline anterior foi desactivado porque produzia PDF
// vazio/mal formatado — causa raiz: satori.loadFont() deixou de existir
// no satori 0.26 (fonts passam agora na opção `fonts`) e os pacotes
// @fontsource/noto-* nunca estavam instalados. O pipeline reanimado usa
// Inter/Fraunces (já no projecto) e está corrigido em lib/pdf/buildPdf.js.

import React from 'react'
import { createAdminClient } from '@/lib/supabase/admin'
import { loadTranslations, t } from '@/lib/i18n'
import { buildComprovativoPdf } from '@/lib/pdf/buildPdf'
import ComprovativoSatori from '@/lib/pdf/ComprovativoSatori'
import { readFile } from 'fs/promises'
import path from 'path'
import qrcode from 'qrcode'
import { timingSafeEqual } from 'crypto'
import { getTranslationByEntityId } from '@/lib/api/translations'

// inscricoes.id é int8 (ex.: 97) — confirmado na BD (alguma migração
// posterior converteu o UUID do RPC 029 em bigint). Aceito também UUID
// por robustez futura.
const INT_RE = /^\d{1,18}$/
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
const CODE_RE = /^[0-9a-f]{32}$/i // share_code = hex de 16 bytes (migração 253)

const COMP_LIMIT = { max: 10, windowMs: 60_000 }
const _rateMap = new Map()

function getClientIp(headersList) {
  const xff = headersList.get('x-forwarded-for')
  if (xff) return xff.split(',')[0].trim()
  return headersList.get('x-real-ip') || 'unknown'
}

function checkRate(ip) {
  const now = Date.now()
  const entry = _rateMap.get(ip)
  if (!entry || entry.resetAt < now) {
    _rateMap.set(ip, { count: 1, resetAt: now + COMP_LIMIT.windowMs })
    return true
  }
  if (entry.count >= COMP_LIMIT.max) return false
  entry.count += 1
  return true
}

// Constant-time comparison (ambos hex de 32 chars validados antes)
function codeMatches(a, b) {
  try {
    return timingSafeEqual(Buffer.from(a, 'hex'), Buffer.from(b, 'hex'))
  } catch {
    return false
  }
}

const notFound = () =>
  new Response('Not found', {
    status: 404,
    headers: { 'cache-control': 'no-store' },
  })

function fmtDate(value, locale) {
  if (!value) return null
  const d = new Date(value)
  if (isNaN(d.getTime())) return null
  try {
    return new Intl.DateTimeFormat(locale, {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    }).format(d)
  } catch {
    return d.toISOString().slice(0, 10)
  }
}

function fmtDateTime(value, locale, hour12) {
  if (!value) return null
  const d = new Date(value)
  if (isNaN(d.getTime())) return null
  try {
    const dateStr = new Intl.DateTimeFormat(locale, {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    }).format(d)
    const timeStr = new Intl.DateTimeFormat(locale, {
      hour: '2-digit',
      minute: '2-digit',
      hour12,
    }).format(d)
    return `${dateStr} · ${timeStr}`
  } catch {
    return d.toISOString().slice(0, 16).replace('T', ' ')
  }
}

// Mesma normalização de profissão que InscricaoPageClient (profKey)
function profKey(profissao) {
  switch (profissao) {
    case 'estudante-saude': return 'estudante'
    case 'tecnico-medio-saude': return 'tecnico_medio'
    case 'tecnico-radiologia': return 'tecnico_radio'
    case 'tecnico-analises-clinicas': return 'tecnico_analises'
    case 'medico-dentista': return 'dentista'
    case 'biologo-analista': return 'biologo'
    default: return profissao
  }
}

async function logoDataUrl() {
  const buf = await readFile(
    path.join(process.cwd(), 'public', 'logo', 'logo-principal-branco.png')
  )
  return `data:image/png;base64,${buf.toString('base64')}`
}

export const runtime = 'nodejs'
export const dynamic = 'force-dynamic' // never cache

export async function GET(request, { params }) {
  const { id } = await params

  // Validação de formato ANTES de qualquer I/O (rejeição barata)
  if (!id || (!INT_RE.test(id) && !UUID_RE.test(id))) return notFound()
  if (!checkRate(getClientIp(request.headers))) {
    return new Response('Too many requests', { status: 429 })
  }

  const url = new URL(request.url)
  const lang = url.searchParams.get('lang') === 'en' ? 'en' : 'pt'
  const code = String(url.searchParams.get('code') || '')
  if (!CODE_RE.test(code)) return notFound()

  try {
    const supabase = createAdminClient()

    // 1. Inscrição por id (Service Role — RLS não filtra; o gate é o code)
    const { data: ins, error: insErr } = await supabase
      .from('inscricoes')
      .select('id, nome, email, telefone, profissao, created_at, share_code, evento_id')
      .eq('id', id)
      .maybeSingle()

    if (insErr || !ins || !ins.share_code || !codeMatches(ins.share_code, code)) {
      return notFound()
    }

    // 2. Evento (título/data/local/modalidade)
    let event = null
    if (ins.evento_id) {
      const { data } = await supabase
        .from('events')
        .select('title, date, time, location, type')
        .eq('id', ins.evento_id)
        .maybeSingle()
      event = data
    }

    // 3. Título traduzido para EN (mesma estratégia da página de inscrição)
    let eventTitle = event?.title || null
    if (event && lang === 'en') {
      try {
        const tr = await getTranslationByEntityId('event', ins.evento_id, 'en')
        eventTitle = tr?.title || eventTitle
      } catch {}
    }

    // 4. Strings i18n
    const translations = loadTranslations(lang)
    const tFn = (key) => t(translations, key)
    const locale = lang === 'en' ? 'en-US' : 'pt-PT'
    const hour12 = lang === 'en'

    // Referência curta: mesma derivação do InscricaoBilhete/ComprovativoModal
    // (int8 zero-padded a 6 dígitos, ex.: 97 → "000097") — consistente entre
    // ecrã, admin e PDF.
    const ref6 = String(ins.id).padStart(6, '0')

    // 5. QR (mesmo formato de URL de validação do bilhete do ecrã)
    const validationUrl = `https://conhecafarmacia.com/validar?ref=${ref6}`
    const qrDataUrl = await qrcode.toDataURL(validationUrl, {
      errorCorrectionLevel: 'M',
      margin: 1,
      width: 400,
    })

    // 6. Logo (PNG → data URL)
    const logo = await logoDataUrl()

    // 7. Campos formatados
    const eventDate = event?.date
      ? event.time
        ? `${fmtDate(event.date, locale)} · ${String(event.time).slice(0, 5)}`
        : fmtDate(event.date, locale)
      : null

    const modalityLabel = event?.type
      ? (() => {
          const key = `inscricao_success.comprovativo_modalidade_${event.type}`
          const val = tFn(key)
          return val && val !== key ? val : event.type
        })()
      : null

    const profLabel = ins.profissao
      ? (() => {
          const key = `inscricao.prof_${profKey(ins.profissao)}`
          const val = tFn(key)
          return val && val !== key ? val : ins.profissao
        })()
      : null

    // 8. JSX → SVG → PNG → PDF
    const element = React.createElement(ComprovativoSatori, {
      logoDataUrl: logo,
      qrDataUrl,
      shortRef: ref6,
      eventTitle,
      eventDate,
      eventLocation: event?.location || null,
      modality: event?.type || null,
      modalityLabel,
      attendeeName: ins.nome,
      attendeeEmail: ins.email,
      attestationCode: tFn('inscricao_success.referencia') + ' ' + ref6,
      inscriptionDate: fmtDateTime(ins.created_at, locale, hour12),
      eventBadge: tFn('inscricao_success.comprovativo_badge'),
      docSubtitle: tFn('inscricao_success.comprovativo_doc_sub'),
      stubTagline: tFn('inscricao_success.comprovativo_stub_tagline'),
      lang,
    })

    const pdfBytes = await buildComprovativoPdf(element)

    return new Response(Buffer.from(pdfBytes), {
      status: 200,
      headers: {
        'content-type': 'application/pdf',
        'content-disposition': `attachment; filename="comprovativo-${ref6}.pdf"`,
        'cache-control': 'no-store',
      },
    })
  } catch (err) {
    // Log sem PII; resposta idêntica a "não encontrado" para não vazar estado
    console.error('[comprovativo-pdf] generation failed:', err?.message)
    return notFound()
  }
}
