// src/lib/seo.js
// Módulo centralizado de SEO para páginas de conteúdo.
// Todas as funções manipulam <head> via DOM.

const SITE_NAME = 'Conheça Farmácia';
const SITE_LOGO = 'https://conhecafarmacia.netlify.app/logo/3.png';

/**
 * Atualiza document.title
 * @param {string} title
 */
export function setDocumentTitle(title) {
  if (title) document.title = title;
}

/**
 * Cria ou atualiza <meta name="description">
 * @param {string} description
 */
export function setMetaDescription(description) {
  if (!description) return;
  let tag = document.querySelector('meta[name="description"]');
  if (!tag) {
    tag = document.createElement('meta');
    tag.setAttribute('name', 'description');
    document.head.appendChild(tag);
  }
  tag.setAttribute('content', description);
}

/**
 * Cria ou atualiza <link rel="canonical">
 * @param {string} url
 */
export function setCanonicalUrl(url) {
  if (!url) return;
  let tag = document.querySelector('link[rel="canonical"]');
  if (!tag) {
    tag = document.createElement('link');
    tag.setAttribute('rel', 'canonical');
    document.head.appendChild(tag);
  }
  tag.setAttribute('href', url);
}

/**
 * Cria ou atualiza Open Graph meta tags
 * @param {{title?: string, description?: string, image?: string, url?: string, type?: string}} opts
 */
export function setOpenGraphTags({ title, description, image, url, type } = {}) {
  const setMeta = (property, content) => {
    if (!content) return;
    let tag = document.querySelector(`meta[property="${property}"]`);
    if (!tag) {
      tag = document.createElement('meta');
      tag.setAttribute('property', property);
      document.head.appendChild(tag);
    }
    tag.setAttribute('content', content);
  };

  setMeta('og:title', title);
  setMeta('og:description', description);
  setMeta('og:image', image);
  setMeta('og:url', url);
  setMeta('og:type', type || 'website');
  setMeta('og:site_name', SITE_NAME);
}

/**
 * Cria ou atualiza Twitter Card meta tags
 * @param {{title?: string, description?: string, image?: string}} opts
 */
export function setTwitterCardTags({ title, description, image } = {}) {
  const setMeta = (name, content) => {
    if (!content) return;
    let tag = document.querySelector(`meta[name="${name}"]`);
    if (!tag) {
      tag = document.createElement('meta');
      tag.setAttribute('name', name);
      document.head.appendChild(tag);
    }
    tag.setAttribute('content', content);
  };

  setMeta('twitter:card', 'summary_large_image');
  setMeta('twitter:title', title);
  setMeta('twitter:description', description);
  setMeta('twitter:image', image);
}

/**
 * Injeta um bloco <script type="application/ld+json"> no <head>
 * @param {object} schema — objeto JSON-LD
 * @param {string} [id] — id opcional para evitar duplicados
 */
export function injectJsonLd(schema, id) {
  if (!schema) return;

  // Remover script anterior com o mesmo id (evita duplicados em SPAs)
  if (id) {
    const existing = document.getElementById(id);
    if (existing) existing.remove();
  }

  const script = document.createElement('script');
  script.type = 'application/ld+json';
  if (id) script.id = id;
  script.textContent = JSON.stringify(schema);
  document.head.appendChild(script);
}

/**
 * Gera schema.org/Article a partir de um objeto artigo normalizado
 * @param {object} article
 * @returns {object}
 */
export function buildArticleSchema(article) {
  if (!article) return null;

  const baseUrl = window.location.origin;
  const articleUrl = window.location.href;
  const image = article.image
    ? (article.image.startsWith('http') ? article.image : `${baseUrl}${article.image}`)
    : null;

  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    'headline': article.title,
    'description': article.metaDescription || article.excerpt || article.title,
    'image': image,
    'datePublished': article.published_date || article.date || null,
    'dateModified': article.published_date || article.date || null,
    'author': {
      '@type': 'Person',
      'name': article.author?.name || article.author_name || 'Conheça Farmácia',
    },
    'publisher': {
      '@type': 'Organization',
      'name': SITE_NAME,
      'logo': {
        '@type': 'ImageObject',
        'url': SITE_LOGO,
      },
    },
    'mainEntityOfPage': {
      '@type': 'WebPage',
      '@id': articleUrl,
    },
  };
}

/**
 * Gera schema.org/BreadcrumbList a partir dos níveis do breadcrumb
 * @param {Array<{label: string, href?: string}>} levels
 * @returns {object}
 */
export function buildBreadcrumbSchema(levels) {
  if (!levels || levels.length === 0) return null;

  const baseUrl = window.location.origin;

  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    'itemListElement': levels.map((level, i) => {
      const item = {
        '@type': 'ListItem',
        'position': i + 1,
        'name': level.label,
      };
      if (level.href) {
        item.item = level.href.startsWith('http')
          ? level.href
          : `${baseUrl}${level.href.startsWith('/') ? '' : '/'}${level.href}`;
      }
      return item;
    }),
  };
}
