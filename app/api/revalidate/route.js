// POST/GET /api/revalidate?secret=...&tag=interacoes[&path=/pt/interacoes]
//
// Revalidação on-demand da cache ISR (Next.js). Serve para invalidar a cache
// depois de alterações feitas DIRETAMENTE na base de dados (ex.: migrações
// aplicadas no SQL editor do Supabase), que não passam pelas actions do admin
// e portanto não disparam revalidateTag/revalidatePath automaticamente.
//
// Exemplos:
//   curl "https://<site>/api/revalidate?secret=$REVALIDATE_SECRET&tag=interacoes"
//   curl "https://<site>/api/revalidate?secret=$REVALIDATE_SECRET&path=/pt/interacoes"
//
// Segurança:
//   - Requer REVALIDATE_SECRET (variável de ambiente) na query — 401 sem ele.
//   - Rate-limit 20 req/min/IP por instância (in-memory; mesmo trade-off do
//     comprovativo — suficiente para uso manual, não substitui WAF).
//   - Whitelist de tags/paths: só revalida o que está declarado abaixo, para
//     não permitir revalidar rotas arbitrárias a quem tenha o secret.
//   - GET é aceite por conveniência (curl/browser); o impacto é só invalidar
//     cache, e o secret nunca aparece no código nem em logs.

import { revalidatePath, revalidateTag } from 'next/cache'
import { NextResponse } from 'next/server'

const LIMIT = { max: 20, windowMs: 60_000 }
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
    _rateMap.set(ip, { count: 1, resetAt: now + LIMIT.windowMs })
    return true
  }
  if (entry.count >= LIMIT.max) return false
  entry.count += 1
  return true
}

// Whitelist — tags e paths que este endpoint pode invalidar.
const ALLOWED_TAGS = new Set([
  'articles',
  'events',
  'flashcards',
  'guides',
  'interacoes',
  'interviews',
  'protocolos',
  'quiz',
  'scientific',
])

const ALLOWED_PATHS = new Set([
  '/pt/interacoes',
  '/en/interactions',
  '/pt/medicamentos',
  '/en/medications',
  '/pt/guias',
  '/en/guides',
  '/pt/eventos',
  '/en/events',
  '/pt/artigos',
  '/en/articles',
  '/pt/pesquisa',
  '/en/search',
  '/',
])

export const runtime = 'nodejs'
export const dynamic = 'force-dynamic' // never cache

async function handle(request) {
  const ip = getClientIp(request.headers)
  if (!checkRate(ip)) {
    return NextResponse.json(
      { error: 'Demasiados pedidos — tenta novamente dentro de 1 minuto.' },
      { status: 429 }
    )
  }

  const { searchParams } = new URL(request.url)
  const secret = searchParams.get('secret')
  const tag = searchParams.get('tag')
  const path = searchParams.get('path')

  // Secret ausente ou errado → 401 (compara com timing-safe para evitar
  // timing attacks).
  const expected = process.env.REVALIDATE_SECRET || ''
  if (!expected) {
    return NextResponse.json(
      { error: 'REVALIDATE_SECRET não configurado no servidor.' },
      { status: 500 }
    )
  }
  const a = Buffer.from(String(secret || ''))
  const b = Buffer.from(expected)
  if (a.length !== b.length || !a.equals(b)) {
    return NextResponse.json({ error: 'Secret inválido.' }, { status: 401 })
  }

  if (!tag && !path) {
    return NextResponse.json(
      { error: 'Indica ?tag=<tag> ou ?path=<path>.' },
      { status: 400 }
    )
  }

  let revalidated = { tags: [], paths: [] }

  if (tag) {
    if (!ALLOWED_TAGS.has(tag)) {
      return NextResponse.json(
        { error: `Tag "${tag}" não está na whitelist.` },
        { status: 400 }
      )
    }
    revalidateTag(tag)
    revalidated.tags.push(tag)
  }

  if (path) {
    if (!ALLOWED_PATHS.has(path)) {
      return NextResponse.json(
        { error: `Path "${path}" não está na whitelist.` },
        { status: 400 }
      )
    }
    revalidatePath(path, 'page')
    revalidated.paths.push(path)
  }

  return NextResponse.json({ revalidated, now: Date.now() })
}

export async function GET(request) {
  return handle(request)
}

export async function POST(request) {
  return handle(request)
}
