/**
 * Id determinístico para itens que não têm linha própria na base.
 *
 * Um par de interação (fármaco A + fármaco B, fármaco × alimento, fármaco ×
 * doença) não é um registo com UUID: é um cartão calculado. Para o guardado e
 * a nota continuarem ligados ao mesmo cartão entre visitas, o `saved_items`
 * precisa de um id estável. Deriva-se do texto que identifica o cartão
 * («interacao:drug:… ») com FNV-1a em quatro sementes, formatado como UUID
 * (versão 5, variante RFC 4122) — a coluna `item_id` é do tipo `uuid`.
 *
 * Sem dependências e síncrono: corre igual no servidor e no cliente, e o mesmo
 * par dá sempre o mesmo id (a ordem dos lados é normalizada por quem chama).
 */

const SEMENTES = [0x811c9dc5, 0x1b873593, 0x85ebca6b, 0xc2b2ae35]

function fnv1a(texto, semente) {
  let hash = semente >>> 0
  for (let i = 0; i < texto.length; i += 1) {
    hash ^= texto.charCodeAt(i)
    hash = Math.imul(hash, 0x01000193) >>> 0
  }
  return hash >>> 0
}

export function idDeterministico(chave) {
  const texto = String(chave || '')
  const hex = SEMENTES.map((s) => fnv1a(texto, s).toString(16).padStart(8, '0')).join('')
  // 8-4-4-4-12 com os bits de versão (5) e variante (RFC 4122) marcados.
  return [
    hex.slice(0, 8),
    hex.slice(8, 12),
    `5${hex.slice(13, 16)}`,
    `8${hex.slice(17, 20)}`,
    hex.slice(20, 32),
  ].join('-')
}

/** Chave de um par fármaco–fármaco, independente da ordem em que aparecem. */
export function chaveDoPar(idA, idB) {
  return `par:${[String(idA), String(idB)].sort().join(':')}`
}
