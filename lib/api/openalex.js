/**
 * OpenAlex — contagem de citações por DOI.
 *
 * API pública gratuita (sem chave): GET /works/doi:{doi} → cited_by_count.
 * Camadas de cache:
 *   1. Mapa em memória com TTL (evita repetir chamadas na mesma instância);
 *   2. `next: { revalidate }` do Next.js (data cache partilhada entre
 *      requisições, recalculada uma vez por dia).
 * Em falha/rate-limit devolve null — a UI degrada graciosamente (sem chip).
 */

const CACHE = new Map()
const TTL = 12 * 60 * 60 * 1000 // 12h em memória
const REVALIDATE = 60 * 60 * 24 // 24h na data cache do Next

const DOI_RE = /^10\.\d{4,9}\/[-._;()/:A-Z0-9]+$/i

/**
 * @param {string} doi
 * @returns {Promise<{count: number, workId: string|null}|null>}
 */
export async function getOpenAlexCitedBy(doi) {
  if (typeof doi !== 'string' || !DOI_RE.test(doi.trim())) return null
  const key = doi.trim()

  const cached = CACHE.get(key)
  if (cached && Date.now() - cached.at < TTL) return cached.data

  try {
    const res = await fetch(
      `https://api.openalex.org/works/doi:${encodeURIComponent(key)}`,
      {
        headers: { 'User-Agent': 'mailto:dev@conhecafarmacia.pt' },
        next: { revalidate: REVALIDATE },
      }
    )
    if (!res.ok) return null
    const json = await res.json()
    const workId = String(json.id || '')
      .replace('https://openalex.org/', '')
      .replace(/^W(\d+)$/, 'W$1')
    const data = {
      count: Number.isFinite(json.cited_by_count) ? json.cited_by_count : 0,
      workId: workId.startsWith('W') ? workId : null,
    }
    CACHE.set(key, { at: Date.now(), data })
    return data
  } catch {
    return null
  }
}
