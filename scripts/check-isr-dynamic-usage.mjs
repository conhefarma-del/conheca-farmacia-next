#!/usr/bin/env node
/**
 * ISR Guard — bloqueia o padrão que causou 500 DYNAMIC_SERVER_USAGE em produção
 * (Lição 45 do CLAUDE-Next.md, rev. 2026-09-18).
 *
 * Mecanismo do bug:
 *   Página com `export const revalidate > 0` (ISR) cujo `generateMetadata`
 *   acede a APIs dinâmicas (`cookies()`/`headers()` de `next/headers`, ou
 *   `createClient()` do Supabase que as usa) — directa ou via função
 *   importada/local que as usa. Na regeneração ISR em background o
 *   DynamicServerError é RELANÇADO no boundary de generateMetadata → 500
 *   intermitente só em produção. try/catch NÃO protege.
 *
 * Política (dois níveis):
 *   ✗ BLOQUEIA: uso dinâmico dentro de `generateMetadata` de página ISR.
 *   ⚠ AVISA: uso dinâmico no corpo do page component. O Next captura o erro
 *     aí e serve a rota dinamicamente — sem 500, mas a página perde ISR
 *     silenciosamente (as ~3 páginas legais estão neste estado). Corrigir
 *     oportunisticamente (createAnonClient).
 *
 * Análise: estática, função-a-função. Para cada página ISR:
 *   1. Extrai declarações de função do próprio ficheiro (brace matching).
 *   2. Mapeia imports para módulos do projecto e extrai as declarações
 *      exportadas deles (inclui `export const X = unstable_cache(...)`).
 *   3. Uma função é "dinâmica" se o corpo usa cookies()/headers()/
 *      createClient(), ou chama (local ou importada) outra função dinâmica.
 *   4. Classifica as chamadas em generateMetadata vs. resto do ficheiro.
 *
 * Não seguidos: módulos 'use client' (o que importam só corre via RPC após
 * hidratação) e bare imports (react, next/*). Layouts não são verificados.
 *
 * Escape hatch por página: comentário `isr-guard: allow <motivo>` nas
 * primeiras 10 linhas. Usar com parcimónia e motivo explícito.
 *
 * Corre no `build` (ver package.json) → a Vercel falha o deploy se houver
 * regressão.
 */

import fs from 'node:fs'
import path from 'node:path'
import process from 'node:process'

const ROOT = process.cwd()
const APP_DIR = path.join(ROOT, 'app')
const PAGE_NAMES = new Set(['page.js', 'page.jsx'])
const SRC_EXT = new Set(['.js', '.jsx', '.mjs'])
const ALLOW_MARKER = 'isr-guard: allow'
const MAX_CALL_DEPTH = 6

const RESERVED = new Set([
  'if', 'for', 'while', 'switch', 'catch', 'function', 'return', 'new',
  'typeof', 'await', 'async', 'else', 'do', 'try', 'delete', 'void', 'in',
  'of', 'instanceof', 'super', 'this', 'class', 'let', 'var', 'const',
])

function walk(dir, out = []) {
  let entries
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true })
  } catch {
    return out
  }
  for (const entry of entries) {
    if (entry.name === 'node_modules' || entry.name === '.next') continue
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) walk(full, out)
    else if (PAGE_NAMES.has(entry.name)) out.push(full)
  }
  return out
}

function readText(file) {
  try {
    return fs.readFileSync(file, 'utf8')
  } catch {
    return null
  }
}

/**
 * Remove comentários // e /* *\//* de um texto, respeitando strings
 * (URLs tipo https:// não são tocadas). Sem isto, um comentário que mencione
 * cookies() ou createClient() no corpo de uma função é um falso positivo.
 */
function stripComments(text) {
  let out = ''
  let i = 0
  let inStr = null
  let esc = false
  while (i < text.length) {
    const ch = text[i]
    const next = text[i + 1]
    if (inStr) {
      out += ch
      if (esc) esc = false
      else if (ch === '\\') esc = true
      else if (ch === inStr) inStr = null
      i++
      continue
    }
    if (ch === '"' || ch === "'" || ch === '`') {
      inStr = ch
      out += ch
      i++
      continue
    }
    if (ch === '/' && next === '/') {
      while (i < text.length && text[i] !== '\n') i++
      continue
    }
    if (ch === '/' && next === '*') {
      i += 2
      while (i < text.length && !(text[i] === '*' && text[i + 1] === '/')) i++
      i += 2
      out += ' '
      continue
    }
    out += ch
    i++
  }
  return out
}

/** Corpo de bloco { ... } começando em braceIdx (ignora strings/template). */
function extractBlock(text, braceIdx) {
  let depth = 0
  let inStr = null
  let esc = false
  for (let i = braceIdx; i < text.length; i++) {
    const ch = text[i]
    if (esc) {
      esc = false
      continue
    }
    if (inStr) {
      if (ch === '\\') esc = true
      else if (ch === inStr) inStr = null
      continue
    }
    if (ch === '"' || ch === "'" || ch === '`') inStr = ch
    else if (ch === '{') depth++
    else if (ch === '}') {
      depth--
      if (depth === 0) return { body: text.slice(braceIdx, i + 1), end: i + 1 }
    }
  }
  return { body: text.slice(braceIdx), end: text.length }
}

/** Import statements → lista de { spec, stmt }. */
const IMPORT_RE = /import\s+(?:[\w*{}\s,]+\s+from\s+)?['"]([^'"]+)['"]/g
function extractImportStatements(content) {
  const out = []
  let m
  IMPORT_RE.lastIndex = 0
  while ((m = IMPORT_RE.exec(content)) !== null) out.push({ spec: m[1], stmt: m[0] })
  return out
}

/** Resolve specifier de projecto (alias @/ ou relativo) → ficheiro ou null. */
function resolveSpecifier(spec, fromFile) {
  let base = null
  if (spec.startsWith('@/')) base = path.join(ROOT, spec.slice(2))
  else if (spec.startsWith('./') || spec.startsWith('../')) {
    base = path.resolve(path.dirname(fromFile), spec)
  } else return null
  const candidates = [
    base,
    `${base}.js`,
    `${base}.jsx`,
    `${base}.mjs`,
    path.join(base, 'index.js'),
    path.join(base, 'index.jsx'),
  ]
  for (const c of candidates) {
    try {
      if (fs.statSync(c).isFile() && SRC_EXT.has(path.extname(c))) return c
    } catch {
      /* próximo candidato */
    }
  }
  return null
}

/** Nomes de chamadas `ident(` num texto, menos reservadas. */
function callsIn(text) {
  const names = new Set()
  const re = /\b([A-Za-z_$][\w$]*)\s*\(/g
  let m
  while ((m = re.exec(text)) !== null) {
    if (!RESERVED.has(m[1])) names.add(m[1])
  }
  return names
}

// --- registo de módulos -----------------------------------------------------
const FN_DECL_RE = /(?:^|\n)(export\s+)?(?:default\s+)?(async\s+)?function\s+([\w$]+)/g
const CONST_DECL_RE = /(?:^|\n)(export\s+)?const\s+([\w$]+)\s*=/g
const EXPORT_LIST_RE = /^export\s*\{([^}]+)\}/gm

const moduleCache = new Map()

function getModule(file) {
  const cached = moduleCache.get(file)
  if (cached) return cached
  const mod = { decls: new Map(), imports: new Map(), content: '' }
  moduleCache.set(file, mod)
  const raw = readText(file)
  if (raw === null) return mod
  // Texto sem comentários: offsets consistentes para decls, imports e slicing
  // em analyzePage (comentários não podem gerar falsos positivos de chamada).
  const content = stripComments(raw)
  mod.content = content

  // Declarações top-level: funções (corpo exacto) + consts (slice até à
  // próxima declaração top-level — cobre `export const X = unstable_cache(...)`)
  const bounds = []
  let m
  FN_DECL_RE.lastIndex = 0
  while ((m = FN_DECL_RE.exec(content)) !== null) {
    bounds.push({
      start: m.index + (m[0].startsWith('\n') ? 1 : 0),
      name: m[3],
      exported: Boolean(m[1] || m[0].includes('default')),
      kind: 'fn',
    })
  }
  CONST_DECL_RE.lastIndex = 0
  while ((m = CONST_DECL_RE.exec(content)) !== null) {
    bounds.push({
      start: m.index + (m[0].startsWith('\n') ? 1 : 0),
      name: m[2],
      exported: Boolean(m[1]),
      kind: 'const',
    })
  }
  bounds.sort((a, b) => a.start - b.start)
  for (let i = 0; i < bounds.length; i++) {
    const b = bounds[i]
    const end = i + 1 < bounds.length ? bounds[i + 1].start : content.length
    if (b.kind === 'fn') {
      const braceIdx = content.indexOf('{', b.start)
      if (braceIdx === -1 || braceIdx >= end) continue
      const { body, end: blockEnd } = extractBlock(content, braceIdx)
      mod.decls.set(b.name, { body, start: b.start, end: blockEnd })
    } else {
      mod.decls.set(b.name, { body: content.slice(b.start, end), start: b.start, end })
    }
  }
  // `export { a, b }` marca os nomes como exportados
  let em
  EXPORT_LIST_RE.lastIndex = 0
  while ((em = EXPORT_LIST_RE.exec(content)) !== null) {
    for (const part of em[1].split(',')) {
      const name = part.trim().split(/\s+as\s+/)[0]
      if (mod.decls.has(name)) mod.decls.get(name).exported = true
    }
  }
  // Imports → ficheiro resolvido
  for (const { spec, stmt } of extractImportStatements(content)) {
    const resolved = resolveSpecifier(spec, file)
    if (!resolved) continue
    const named = stmt.match(/\{([^}]*)\}/)
    if (named) {
      for (const part of named[1].split(',')) {
        const binding = part.split(/\s+as\s+/)[0].trim()
        if (binding) mod.imports.set(binding, resolved)
      }
    }
    const def = stmt.match(/import\s+([\w$]+)/)
    if (def) mod.imports.set(def[1], resolved)
  }
  return mod
}

/** A função `name` declarada em `file` usa APIs dinâmicas (transitivamente)? */
const dynamicMemo = new Map() // `${file}::${name}` → bool
function isDynamicFn(name, file, depth = 0) {
  if (depth > MAX_CALL_DEPTH) return false
  const key = `${file}::${name}`
  const memo = dynamicMemo.get(key)
  if (memo !== undefined) return memo
  dynamicMemo.set(key, false) // anti-ciclo
  const mod = getModule(file)
  const decl = mod.decls.get(name)
  if (!decl) return false
  let result =
    /\bcookies\s*\(/.test(decl.body) ||
    /\bheaders\s*\(/.test(decl.body) ||
    /\bcreateClient\s*\(/.test(decl.body)
  if (!result) {
    for (const callName of callsIn(decl.body)) {
      if (mod.decls.has(callName)) {
        if (isDynamicFn(callName, file, depth + 1)) {
          result = true
          break
        }
      } else if (mod.imports.has(callName)) {
        const other = mod.imports.get(callName)
        if (getModule(other).decls.has(callName)) {
          if (isDynamicFn(callName, other, depth + 1)) {
            result = true
            break
          }
        }
      }
    }
  }
  dynamicMemo.set(key, result)
  return result
}

/** Num texto, chamadas que resolvem para funções dinâmicas. */
function dynamicCallsIn(text, file, mod) {
  const found = []
  for (const name of callsIn(text)) {
    if (name === 'cookies' || name === 'headers') {
      found.push(`${name}() (next/headers)`)
      continue
    }
    if (mod.decls.has(name)) {
      if (isDynamicFn(name, file)) found.push(`${name}() (local)`)
    } else if (mod.imports.has(name)) {
      const other = mod.imports.get(name)
      if (getModule(other).decls.has(name) && isDynamicFn(name, other)) {
        found.push(`${name}() de '${path.relative(ROOT, other)}'`)
      }
    }
  }
  return [...new Set(found)]
}

// --- classificação de páginas ------------------------------------------------
function classifyPage(content) {
  const isDynamic =
    /export\s+const\s+dynamic\s*=\s*['"]force-dynamic['"]/.test(content)
  const revalidateMatch = content.match(/export\s+const\s+revalidate\s*=\s*(\d+)/)
  const revalidate = revalidateMatch ? parseInt(revalidateMatch[1], 10) : 0
  return { isDynamic, revalidate }
}

function hasAllowMarker(content) {
  return content
    .split('\n')
    .slice(0, 10)
    .some((line) => line.includes(ALLOW_MARKER))
}

function analyzePage(file) {
  const mod = getModule(file)
  const content = mod.content
  if (!content) return null
  const gmDecl = mod.decls.get('generateMetadata')
  const gmText = gmDecl ? content.slice(gmDecl.start, gmDecl.end) : ''
  const restText = gmDecl
    ? content.slice(0, gmDecl.start) + content.slice(gmDecl.end)
    : content
  return {
    gm: dynamicCallsIn(gmText, file, mod),
    rest: dynamicCallsIn(restText, file, mod),
  }
}

// --- execução -----------------------------------------------------------------
const pages = walk(APP_DIR)
const violations = []
const warnings = []
let isrCount = 0
let allowedCount = 0

for (const page of pages) {
  const rel = path.relative(ROOT, page)
  const content = readText(page)
  if (content === null) continue
  const { isDynamic, revalidate } = classifyPage(content)
  if (isDynamic) continue
  if (revalidate <= 0) continue
  if (hasAllowMarker(content)) {
    allowedCount++
    console.log(`  [allow] ${rel} (isr-guard: allow)`)
    continue
  }
  isrCount++
  const result = analyzePage(page)
  if (!result) continue
  if (result.gm.length > 0) violations.push({ rel, calls: result.gm })
  else if (result.rest.length > 0) warnings.push({ rel, calls: result.rest })
}

console.log(
  `\nISR guard: ${pages.length} páginas, ${isrCount} em ISR` +
    (allowedCount > 0 ? `, ${allowedCount} com allow` : '') +
    '.'
)

for (const { rel, calls } of warnings) {
  console.warn(`⚠ ${rel} (corpo da página — a rota perde ISR silenciosamente)`)
  for (const c of calls) console.warn(`    └─ ${c}`)
}

if (violations.length > 0) {
  console.error('')
  for (const { rel, calls } of violations) {
    console.error(`✗ ${rel} (generateMetadata)`)
    for (const c of calls) console.error(`    └─ ${c}`)
  }
  console.error(
    `\n${violations.length} violação(ões): generateMetadata de página ISR acede a` +
      ` cookies()/headers()/createClient().\nCompila, mas dá 500` +
      ` DYNAMIC_SERVER_USAGE na regeneração ISR em produção.\nCorrecção:` +
      ` createAnonClient() para leituras públicas, ou force-dynamic.\nVer` +
      ` Lição 45 do CLAUDE-Next.md (rev. 2026-09-18).`
  )
  process.exit(1)
}

console.log(
  warnings.length > 0
    ? `ISR guard: OK (${warnings.length} aviso(s) no corpo de páginas — não bloqueiam).`
    : 'ISR guard: OK.'
)
