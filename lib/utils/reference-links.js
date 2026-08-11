/**
 * Referências vivas — converte o texto de uma referência bibliográfica
 * (já sanitizado na gravação) em HTML com links para DOI / PMID / PMCID.
 * O texto é escapado primeiro (prevenção de XSS — as referências vêm da BD).
 */

const PMID_RE = /\bPMID[:\s]*(\d{6,9})\b/gi
const PMCID_RE = /\bPMC(?:ID)?\s*(\d{5,8})\b/gi
const DOI_RE = /\b(10\.\d{4,9}\/[-._;()\/:A-Z0-9]+)\b/gi

function escapeHtml(text) {
  return String(text)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

function refLink(href, label) {
  return `<a class="sci-ref-link" href="${href}" target="_blank" rel="noopener noreferrer">${label}</a>`
}

/**
 * @param {string} text - texto de uma referência (ex.: "…Antibiotics (Basel). 2022;11(10):1410. doi:10.3390/…")
 * @returns {string} HTML seguro com os identificadores ligados
 */
export function linkReferenceText(text) {
  let html = escapeHtml(text)

  // PMID → PubMed
  html = html.replace(PMID_RE, (_m, id) => refLink(`https://pubmed.ncbi.nlm.nih.gov/${id}/`, `PMID: ${id}`))

  // PMCID → PMC
  html = html.replace(PMCID_RE, (_m, id) => refLink(`https://pmc.ncbi.nlm.nih.gov/articles/PMC${id}/`, `PMC${id}`))

  // DOI → doi.org (o greedy pode apanhar pontuação final — limpa-se)
  html = html.replace(DOI_RE, (_m, doi) => {
    const clean = doi.replace(/[.,;:]+$/, '')
    return refLink(`https://doi.org/${clean}`, clean)
  })

  return html
}
