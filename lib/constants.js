// Constantes partilhadas para categorias e cores

export const SITE_NAME = 'Conheça Farmácia'
export const SITE_URL = 'https://conhecafarmacia.netlify.app'
export const SITE_LOGO = 'https://conhecafarmacia.netlify.app/logo/3.png'

// Cores por categoria de artigos
export const ARTICLE_CATEGORY_COLORS = {
  profissionais: '#ff6c23',
  'voce-sabia': '#0a844f',
  'conheca-medicamento': '#7c3aed',
  curiosidades: '#002a32',
  saude: '#006171',
  legislacao: '#ff4d4d',
}

// Cores por categoria de eventos
export const EVENT_CATEGORY_COLORS = {
  workshop: '#ff6c23',
  palestra: '#0a844f',
  congresso: '#002a32',
  seminario: '#7c3aed',
  outro: '#6b7280',
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
