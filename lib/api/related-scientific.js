/**
 * Relacionados por similaridade de keywords (recomendação 7) — módulo puro,
 * sem imports externos, para poder ser testado isoladamente.
 *
 * Score = nº de keywords normalizadas em comum; desempate por mesma
 * categoria e depois por data mais recente. Fallbacks documentados em
 * `findRelatedScientificArticles`.
 */

/**
 * Normaliza uma keyword para comparação (minúsculas + sem diacríticos).
 */
export function normalizeKeyword(kw) {
  return String(kw || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .trim()
}

/**
 * findRelatedScientificArticles — artigos relacionados por similaridade de
 * keywords: score = nº de keywords em comum, com desempate por mesma
 * categoria e depois por data mais recente.
 *
 * Fallback: sem keywords no artigo atual, mantém o comportamento anterior
 * (mesma categoria). Se as keywords não encherem o limite, preenche com
 * artigos da mesma categoria — a secção nunca fica vazia.
 *
 * @param {object} current - artigo normalizado (com .keywords e .category)
 * @param {Array<object>} candidates - todos os artigos publicados
 * @param {{limit?: number}} opts
 * @returns {Array<object>}
 */
export function findRelatedScientificArticles(current, candidates, { limit = 4 } = {}) {
  const all = candidates || []
  const others = all.filter((a) => a.slug !== current.slug)
  const target = new Set((current.keywords || []).map(normalizeKeyword).filter(Boolean))

  if (target.size === 0) {
    return others
      .filter((a) => a.category?.slug === current.category?.slug)
      .slice(0, limit)
  }

  const scored = others
    .map((a) => {
      const own = new Set((a.keywords || []).map(normalizeKeyword).filter(Boolean))
      let overlap = 0
      for (const k of own) if (target.has(k)) overlap += 1
      return { a, overlap, sameCat: a.category?.slug === current.category?.slug ? 1 : 0 }
    })
    .filter((s) => s.overlap > 0)
    .sort(
      (x, y) =>
        y.overlap - x.overlap ||
        y.sameCat - x.sameCat ||
        String(y.a.date || '').localeCompare(String(x.a.date || ''))
    )
    .map((s) => s.a)

  if (scored.length >= limit) return scored.slice(0, limit)

  // Preenche com mesma categoria (comportamento anterior) até ao limite
  const have = new Set(scored.map((a) => a.slug))
  const fill = others
    .filter((a) => !have.has(a.slug) && a.category?.slug === current.category?.slug)
    .slice(0, limit - scored.length)
  return [...scored, ...fill].slice(0, limit)
}
