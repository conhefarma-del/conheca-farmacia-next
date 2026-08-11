/**
 * Formatação de citações bibliográficas — ABNT / APA / Vancouver.
 * Funções puras (sem DOM); o botão copiar vive no CitationWidget.
 *
 * Regras (formato do design demo 2026-08-11):
 *   ABNT:     SOBRENOME, N.; N. SOBRENOME. Título. Conheça Farmácia, Ano.
 *             DOI: 10.xxxx/xxx. Disponível em: URL
 *   APA:      Sobrenome, N., & Sobrenome, N. (Ano). Título. Conheça Farmácia.
 *             https://doi.org/10.xxxx/xxx
 *   Vancouver: Sobrenome NI, Sobrenome NI. Título. Conheça Farmácia. Ano.
 *             doi:10.xxxx/xxx (ou Available from: URL)
 *
 * DOI vazio → URL como fallback.
 */

const JOURNAL = 'Conheça Farmácia'

function parseName(name) {
  const cleaned = String(name || '')
    .replace(/^(Dr\.?|Dra\.?|Prof\.?|PhD|MD|MSc)\s+/i, '')
    .trim()
  const parts = cleaned.split(/\s+/).filter(Boolean)
  if (!parts.length) return { first: [], last: '' }
  if (parts.length === 1) return { first: [], last: parts[0] }
  const last = parts.pop()
  return { first: parts, last }
}

function initials(firstParts) {
  return firstParts.map((w) => `${w[0] || ''}.`).join(' ')
}

function initialLetters(firstParts) {
  return firstParts.map((w) => w[0] || '').join('')
}

function yearOf(article) {
  const y = (article.date || '').slice(0, 4)
  return y || 's.d.'
}

function abntAuthors(authors) {
  // Primeiro autor: SOBRENOME, Iniciais; seguintes: Iniciais SOBRENOME
  return (authors || [])
    .map((a, i) => {
      const { first, last } = parseName(a.name)
      if (i === 0) {
        const ini = first.length ? initials(first) : ''
        return `${last.toUpperCase()}, ${ini}`
      }
      const ini = first.length ? initialLetters(first) : ''
      return `${ini} ${last}`
    })
    .join('; ')
}

function apaAuthors(authors) {
  const list = (authors || [])
    .map((a) => {
      const { first, last } = parseName(a.name)
      const ini = first.map((w) => `${w[0] || ''}.`).join(' ')
      return `${last}, ${ini}`
    })
  if (list.length <= 1) return list.join('')
  if (list.length === 2) return `${list[0]} & ${list[1]}`
  return `${list.slice(0, -1).join(', ')}, & ${list[list.length - 1]}`
}

function vancouverAuthors(authors) {
  return (authors || [])
    .map((a) => {
      const { first, last } = parseName(a.name)
      return `${last} ${initialLetters(first)}`
    })
    .join(', ')
}

/**
 * @param {object} article — artigo normalizado (title, authors, date, doi)
 * @param {'abnt'|'apa'|'vancouver'} style
 * @param {string} url — URL pública do artigo (fallback sem DOI)
 * @returns {string}
 */
/** RIS (Reference Manager/Zotero) — um registo JOUR por artigo. */
export function formatRis(article, url = '') {
  const lines = ['TY  - JOUR']
  for (const a of article.authors || []) {
    const { first, last } = parseName(a.name)
    lines.push(`AU  - ${last}, ${first.join(' ')}`)
  }
  lines.push(`TI  - ${(article.title || '').trim()}`)
  lines.push(`JO  - ${JOURNAL}`)
  lines.push(`PY  - ${yearOf(article)}`)
  if (article.doi) lines.push(`DO  - ${article.doi}`)
  lines.push(`UR  - ${url}`)
  lines.push('ER  - ')
  return lines.join('\n')
}

/** Escapar caracteres especiais do LaTeX/BibTeX. */
function escapeBibtex(text) {
  return String(text || '')
    .replace(/\\/g, '\\textbackslash{}')
    .replace(/([&%#$_{}~^])/g, (m) => {
      switch (m) {
        case '&': return '\\&'
        case '%': return '\\%'
        case '#': return '\\#'
        case '$': return '\\$'
        case '_': return '\\_'
        case '{': return '\\{'
        case '}': return '\\}'
        case '~': return '\\textasciitilde{}'
        case '^': return '\\textasciicircum{}'
        default: return m
      }
    })
}

/** BibTeX — entrada @article com chave = slug. */
export function formatBibtex(article, url = '') {
  const key = (article.slug || 'artigo').replace(/[^a-zA-Z0-9:_-]/g, '')
  const authors = (article.authors || [])
    .map((a) => {
      const { first, last } = parseName(a.name)
      const ini = first.length ? initials(first) : ''
      return `${last}, ${ini}`
    })
    .join(' and ')
  const lines = [
    `@article{${key},`,
    `  author = {${authors}},`,
    `  title = {${escapeBibtex(article.title)}},`,
    `  journal = {${JOURNAL}},`,
    `  year = {${yearOf(article)}},`,
  ]
  if (article.doi) lines.push(`  doi = {${article.doi}},`)
  if (url) lines.push(`  url = {${url}},`)
  lines.push('}')
  return lines.join('\n')
}

/**
 * COinS (ContextObjects in Spans) — o Zotero captura a citação automaticamente
 * a partir do atributo title de <span class="Z3988">. Formato kev:mtx:journal.
 */
export function buildCoins(article, url = '') {
  const sp = new URLSearchParams()
  sp.set('ctx_ver', 'Z39.88-2004')
  sp.set('rft_val_fmt', 'info:ofi/fmt:kev:mtx:journal')
  sp.set('rft.genre', 'article')
  sp.set('rft.jtitle', JOURNAL)
  sp.set('rft.atitle', (article.title || '').trim())
  sp.set('rft.date', yearOf(article))
  if (article.doi) sp.set('rft_id', `info:doi/${article.doi}`)
  for (const a of article.authors || []) {
    const { first, last } = parseName(a.name)
    sp.append('rft.au', `${last}, ${first.join(' ')}`)
  }
  sp.set('rft.url', url)
  return sp.toString()
}

/**
 * @param {object} article — artigo normalizado (title, authors, date, doi)
 * @param {'abnt'|'apa'|'vancouver'|'ris'|'bibtex'} style
 * @param {string} url — URL pública do artigo (fallback sem DOI)
 * @returns {string}
 */
export function formatCitation(article, style = 'abnt', url = '') {
  const title = (article.title || '').trim()
  const year = yearOf(article)
  const doi = (article.doi || '').trim()
  const doiUrl = doi ? `https://doi.org/${doi}` : url

  switch (style) {
    case 'ris': return formatRis(article, url)
    case 'bibtex': return formatBibtex(article, url)
    case 'apa': {
      const authors = apaAuthors(article.authors)
      return `${authors} (${year}). ${title}. ${JOURNAL}. ${doiUrl}`
    }
    case 'vancouver': {
      const authors = vancouverAuthors(article.authors)
      const tail = doi ? `doi:${doi}` : `Available from: ${url}`
      return `${authors}. ${title}. ${JOURNAL}. ${year}. ${tail}`
    }
    case 'abnt':
    default: {
      const authors = abntAuthors(article.authors)
      const tail = doi
        ? `DOI: ${doi}. Disponível em: ${url}`
        : `Disponível em: ${url}`
      return `${authors} ${title}. ${JOURNAL}, ${year}. ${tail}`
    }
  }
}
