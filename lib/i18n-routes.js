// Mapeamento de slugs estruturais entre PT e EN.
// Usado pelo LanguageSwitcher para que trocar de idioma navegue para a
// secção equivalente (ex: /pt/artigos → /en/articles, não /en/artigos).

const PT_TO_EN = {
  artigos: 'articles',
  eventos: 'events',
  sobre: 'about',
  pesquisa: 'search',
  inscricao: 'register',
  faq: 'faq',
  'politica-privacidade': 'privacy-policy',
  guias: 'guides',
  protocolos: 'protocols',
  interacoes: 'interactions',
  medicamentos: 'medicines',
}

const EN_TO_PT = Object.fromEntries(
  Object.entries(PT_TO_EN).map(([pt, en]) => [en, pt])
)

/**
 * Devolve o pathname traduzido para o novo idioma.
 * - Substitui o segmento de lang no índice 1.
 * - Se o segmento estrutural (índice 2) tem equivalente no novo idioma,
 *   usa-o. Caso contrário, mantém o slug actual (útil para secções
 *   partilhadas como `lives` ou `unsubscribe`, e para slugs dinâmicos
 *   que dependem de tradução de conteúdo).
 */
export function getLocalizedPath(pathname, newLang) {
  const segments = (pathname || '/').split('/')
  // segments[0] = '' (porque o path começa com /)
  // segments[1] = lang actual
  // segments[2] = secção (artigos/articles/etc.) ou undefined (home)
  if (segments.length < 2) return `/${newLang}`

  segments[1] = newLang

  if (segments.length >= 3 && segments[2]) {
    const currentSection = segments[2]
    const isPt = newLang === 'pt'
    const map = isPt ? EN_TO_PT : PT_TO_EN
    if (map[currentSection]) {
      segments[2] = map[currentSection]
    }
  }

  return segments.join('/') || `/${newLang}`
}

/**
 * Devolve o href de uma secção estrutural num dado idioma.
 * `sectionPt` é o slug canónico em PT (ex: 'artigos', 'pesquisa').
 * Devolve `/{lang}/{slug}`, onde `slug` é a tradução se existir, ou
 * `sectionPt` se a secção for partilhada (ex: 'lives').
 *
 * Uso: `getSectionHref('en', 'artigos')` → '/en/articles'
 *      `getSectionHref('pt', 'lives')`   → '/pt/lives'
 */
export function getSectionHref(lang, sectionPt) {
  const translated = lang === 'en' ? PT_TO_EN[sectionPt] : undefined
  return `/${lang}/${translated || sectionPt}`
}
