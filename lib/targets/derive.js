// ============================================================
//  lib/targets/derive.js — Motor de derivação fármaco ↔ alvo
//
//  Deriva os papéis (substrato/inibidor/indutor) de cada fármaco
//  em cada alvo molecular a partir dos TEXOS dos alvos
//  (molecular_targets.substrates_pt / inhibitors_pt / inducers_pt),
//  casando com os nomes reais dos fármacos da BD (drugs.name_pt +
//  aliases). Puro e testável — usado pelo seed (migração 189) e pelo
//  admin (modo "re-derivar"). Não inventa conteúdo: só gera linhas
//  quando o nome normalizado do fármaco aparece num texto do alvo.
// ============================================================

/**
 * Normaliza um nome para comparação: NFD (remove acentos), minúsculas,
 * remove pontuação não-alfanumérica e colapsa espaços.
 * Ex.: "Ácido acetilsalicílico" → "acido acetilsalicilico"
 */
export function normalizeName(s) {
  if (!s) return ''
  return String(s)
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
}

/**
 * Devolve todos os "nomes de pesquisa" de um fármaco (nome principal +
 * aliases), normalizados. Ordenados do mais longo para o mais curto para
 * que o match prefira o nome completo (ex.: "amoxicilina + ácido
 * clavulânico" antes de "amoxicilina").
 */
export function drugSearchNames(drug) {
  const names = [drug.name_pt, ...(drug.aliases || [])]
  return names
    .map(normalizeName)
    .filter(Boolean)
    .filter((n, i, arr) => arr.indexOf(n) === i)
    .sort((a, b) => b.length - a.length)
}

/**
 * Divide o texto de uma lista de alvos em itens (separados por vírgula ou
 * ponto e vírgula), limpando notas entre parênteses e o prefixo da lista
 * ("Substratos:", "Inibidores:", "Indutores:").
 */
export function splitList(text) {
  if (!text) return []
  return String(text)
    .replace(/^[^:]*:/, '')
    .split(/[,;]/)
    .map((item) =>
      item
        .replace(/\([^)]*\)/g, ' ')
        .replace(/[^a-z0-9\s]/gi, ' ')
        .replace(/\s+/g, ' ')
        .trim()
    )
    .filter(Boolean)
}

/**
 * Para um item da lista, encontra o fármaco (por nome ou alias) que casa.
 * Devolve o slug do fármaco ou null. O match é por token normalizado:
 * o item "fluconazol" casa com o fármaco "Fluconazol"; o item "aspirina"
 * casa com "Ácido acetilsalicílico" através do alias.
 */
export function matchItem(item, searchNamesByDrug) {
  const ni = normalizeName(item)
  if (!ni) return null
  // itens com 2+ palavras podem ser nomes compostos; procura o match mais longo
  for (const { names, slug } of searchNamesByDrug) {
    for (const name of names) {
      if (ni === name) return slug
    }
  }
  // fallback: o item contém exatamente o nome como palavra inteira
  for (const { names, slug } of searchNamesByDrug) {
    for (const name of names) {
      if (name.length >= 4 && ni.indexOf(name) !== -1) {
        const before = ni.slice(0, ni.indexOf(name))
        const after = ni.slice(ni.indexOf(name) + name.length)
        if ((!before || /\s/.test(before.slice(-1))) && (!after || /\s/.test(after[0]))) {
          return slug
        }
      }
    }
  }
  return null
}

/**
 * Deriva as linhas candidatas para um alvo a partir dos seus textos.
 *
 * @param {object} target — molecular_targets row {id, slug, substrates_pt, inhibitors_pt, inducers_pt, source_pt}
 * @param {Array<{slug, name_pt, aliases}>} drugs — fármacos publicados
 * @returns {Array<{drugId, drugSlug, targetId, targetSlug, role, source}>}
 */
export function deriveRolesForTarget(target, drugs, roleFieldMap) {
  const byRole = roleFieldMap || {
    substrate: 'substrates_pt',
    inhibitor: 'inhibitors_pt',
    inducer: 'inducers_pt',
  }
  const searchNames = drugs.map((d) => ({ slug: d.slug, names: drugSearchNames(d) }))
  const out = []
  for (const [role, field] of Object.entries(byRole)) {
    const items = splitList(target[field])
    for (const item of items) {
      const slug = matchItem(item, searchNames)
      if (slug) {
        const drug = drugs.find((d) => d.slug === slug)
        out.push({
          drugId: drug.id,
          drugSlug: drug.slug,
          targetId: target.id,
          targetSlug: target.slug,
          role,
          source: target.source_pt || target.source_en || '',
        })
      }
    }
  }
  return out
}

/**
 * Deriva todas as linhas candidatas para vários alvos.
 */
export function deriveAllRoles(targets, drugs) {
  const out = []
  for (const target of targets) {
    out.push(...deriveRolesForTarget(target, drugs))
  }
  return out
}

/**
 * True se o fármaco é simultaneamente substrato e inibidor/indutor do mesmo
 * alvo — a "auto-interação" clínica (ex.: substrato e inibidor de CYP3A4).
 * Recebe as linhas do fármaco: [{targetId, role}].
 */
export function findAutoInteraction(drugRoles) {
  if (!drugRoles || drugRoles.length < 2) return null
  const byTarget = {}
  for (const r of drugRoles) {
    if (!byTarget[r.targetId]) byTarget[r.targetId] = new Set()
    byTarget[r.targetId].add(r.role)
  }
  for (const targetId of Object.keys(byTarget)) {
    const roles = byTarget[targetId]
    if (roles.has('substrate') && (roles.has('inhibitor') || roles.has('inducer'))) {
      return { targetId, roles: Array.from(roles) }
    }
  }
  return null
}
