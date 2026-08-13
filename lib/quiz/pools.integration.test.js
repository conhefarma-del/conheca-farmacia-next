/**
 * Teste de integração dos pools reais do Quiz (sem cache).
 *
 * Importa `getQuizPoolCounts` diretamente de lib/api/quiz.js (a função NÃO
 * usa unstable_cache) e falha se algum pool essencial do nível DIFÍCIL
 * estiver vazio — sem dados de interações/protocolos/cartões, o nível
 * difícil perde as categorias que o definem.
 *
 * Como correr (na raiz do projeto):
 *   node lib/quiz/pools.integration.test.js
 *
 * Usa NEXT_PUBLIC_SUPABASE_URL + NEXT_PUBLIC_SUPABASE_ANON_KEY (lidas de
 * .env.local automaticamente; podem também ser injetadas no ambiente).
 */
import { register } from 'node:module'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

// ---- Loader inline: resolve o alias '@/' e faz stub de 'next/cache' ----
// Necessário porque lib/api/quiz.js importa unstable_cache (Next runtime),
// que não existe fora da app; o stub devolve a função tal qual, e o
// getQuizPoolCounts (sem cache) executa normalmente contra a BD real.
const loader = `
import { pathToFileURL } from 'node:url'
export async function resolve(specifier, context, nextResolve) {
  if (specifier.startsWith('@/')) {
    let p = specifier.slice(2)
    if (!/\\.[a-z]+$/i.test(p)) p += '.js'
    return { url: new URL(p, pathToFileURL(process.cwd() + '/')).href, shortCircuit: true }
  }
  if (specifier === 'next/cache') {
    const stub = 'export function unstable_cache(fn) { return fn }'
    return { url: 'data:text/javascript,' + encodeURIComponent(stub), shortCircuit: true }
  }
  return nextResolve(specifier, context)
}
`
register('data:text/javascript,' + encodeURIComponent(loader), import.meta.url)

// ---- Carrega .env.local se as vars ainda não estiverem no ambiente ----
const envPath = fileURLToPath(new URL('../../.env.local', import.meta.url))
try {
  for (const line of readFileSync(envPath, 'utf8').split(/\r?\n/)) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue
    const eq = trimmed.indexOf('=')
    if (eq === -1) continue
    const key = trimmed.slice(0, eq).trim()
    let value = trimmed.slice(eq + 1).trim()
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1)
    }
    if (process.env[key] === undefined) process.env[key] = value
  }
} catch {
  // sem .env.local — assume vars já injetadas
}

if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) {
  console.error('FALHA: faltam NEXT_PUBLIC_SUPABASE_URL / NEXT_PUBLIC_SUPABASE_ANON_KEY (.env.local ou ambiente)')
  process.exit(1)
}

// ---- Importa a função real (sem cache) ----
const { getQuizPoolCounts } = await import('../api/quiz.js')

const counts = await getQuizPoolCounts()
if (!counts) {
  console.error('FALHA: getQuizPoolCounts devolveu null (erro de query?)')
  process.exit(1)
}

console.log('Contagens reais dos pools (publicados, não arquivados):')
for (const [key, val] of Object.entries(counts)) {
  console.log(`  ${key.padEnd(14)} ${val ?? 'ERRO'}`)
}

// Pools usados pelo nível DIFÍCIL (quotas de LEVELS.dificil):
//   flashcard (cards), classe/mecanismo/meia_vida (drugs+pharm),
//   interaction, food, protocol — todos têm de ter dados.
const ESSENTIAL = {
  decks: 'decks de flashcards',
  cards: 'cartões de flashcards',
  drugs: 'fármacos com farmacologia',
  interactions: 'interações fármaco-fármaco (assinatura do difícil)',
  food: 'interações alimento/bebida',
  protocols: 'quizzes de protocolo (assinatura do difícil)',
}

const empty = []
for (const [key, label] of Object.entries(ESSENTIAL)) {
  const val = counts[key]
  if (typeof val !== 'number' || val <= 0) empty.push(`${key} (${label})`)
}

if (empty.length > 0) {
  console.error(`\nFALHA: pools essenciais do nível difícil vazios ou em erro → ${empty.join('; ')}`)
  console.error('Sem estes dados, o nível difícil fica sem as categorias que o definem.')
  process.exit(1)
}

console.log(`\nOK — todos os pools essenciais do nível difícil têm dados (${Object.keys(ESSENTIAL).length}/${Object.keys(ESSENTIAL).length}).`)
