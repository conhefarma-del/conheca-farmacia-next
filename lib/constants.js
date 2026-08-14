// Constantes partilhadas para categorias e cores

export const SITE_NAME = 'Conheça Farmácia'
export const SITE_URL = 'https://conhecafarmacia.com'
export const SITE_LOGO = 'https://conhecafarmacia.com/logo/3.png'

// Cores por categoria de artigos
export const ARTICLE_CATEGORY_COLORS = {
  profissionais: '#ff6c23',
  // 'conheca-medicamento' herdou a cor da descontinuada 'voce-sabia' (#0a844f)
  'conheca-medicamento': '#0a844f',
  curiosidades: '#002a32',
  saude: '#006171',
  legislacao: '#ff4d4d',
}

// Cores por categoria de eventos (lives/webinars fundidas em eventos — 159)
export const EVENT_CATEGORY_COLORS = {
  workshop: '#ff6c23',
  palestra: '#0a844f',
  congresso: '#002a32',
  seminario: '#7c3aed',
  outro: '#6b7280',
  live: '#0e7490',
  webinar: '#b45309',
}

// Cores por categoria de lives
export const LIVE_CATEGORY_COLORS = {
  live: '#006171',
  webinar: '#7c3aed',
  entrevista: '#ff6c23',
}

// Categorias válidas
export const ARTICLE_CATEGORIES = Object.keys(ARTICLE_CATEGORY_COLORS)
export const EVENT_CATEGORIES = Object.keys(EVENT_CATEGORY_COLORS)
export const LIVE_CATEGORIES = Object.keys(LIVE_CATEGORY_COLORS)
