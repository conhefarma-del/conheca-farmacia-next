/**
 * Funcionalidades ocultas temporariamente (decisão com os parceiros, 2026-08).
 *
 * Os dados e as rotas mantêm-se intactos — apenas os pontos de entrada
 * (menus, footer, homepage, sitemap, pesquisa) deixam de apresentar as
 * secções. Reativar = mudar o valor para true; os componentes leem isto.
 *
 * Onde é lido:
 *  - components/layout/Header.jsx, MobileDrawer.jsx, Footer.jsx
 *  - components/home/ToolsShowcase.jsx
 *  - app/sitemap.js
 *  - lib/api/search.js (queries) e components/pages/PesquisaPageClient.jsx
 */
export const FEATURES = {
  // Artigos Científicos (inclui /cientificos/autores e perfis)
  cientificos: false,
  // Protocolos Clínicos
  protocolos: false,
}

export const featureEnabled = (key) => FEATURES[key] === true
