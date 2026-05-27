import { SITE_NAME, SITE_URL, SITE_LOGO } from '@/lib/constants'

export function buildArticleSchema(article, lang = 'pt') {
  if (!article) return null

  const articleUrl = `${SITE_URL}/${lang}/artigos/${article.slug}`
  const image = article.image
    ? (article.image.startsWith('http') ? article.image : `${SITE_URL}${article.image}`)
    : null

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
      'name': article.author?.name || article.author_name || SITE_NAME,
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
  }
}

export function buildEventSchema(event, lang = 'pt') {
  if (!event) return null

  const eventUrl = `${SITE_URL}/${lang}/eventos/${event.slug}`
  const image = event.image
    ? (event.image.startsWith('http') ? event.image : `${SITE_URL}${event.image}`)
    : null

  return {
    '@context': 'https://schema.org',
    '@type': 'Event',
    'name': event.title,
    'description': event.excerpt || event.title,
    'image': image,
    'startDate': event.date ? `${event.date}T${event.time || '00:00'}` : null,
    'endDate': event.date && event.endTime ? `${event.date}T${event.endTime}` : null,
    'eventStatus': 'https://schema.org/EventScheduled',
    'eventAttendanceMode': event.type === 'online'
      ? 'https://schema.org/OnlineEventAttendanceMode'
      : 'https://schema.org/OfflineEventAttendanceMode',
    'location': event.type === 'online'
      ? { '@type': 'VirtualLocation', 'url': eventUrl }
      : { '@type': 'Place', 'name': event.location || 'A definir' },
    'organizer': {
      '@type': 'Organization',
      'name': SITE_NAME,
    },
  }
}

export function buildLiveSchema(live, lang = 'pt') {
  if (!live) return null

  const liveUrl = `${SITE_URL}/${lang}/lives/${live.slug}`
  const image = live.imagem || live.image
  const safeImage = image
    ? (image.startsWith('http') ? image : `${SITE_URL}${image}`)
    : null

  return {
    '@context': 'https://schema.org',
    '@type': 'Event',
    'name': live.titulo || live.title,
    'description': live.resumo || live.excerpt || live.titulo || live.title,
    'image': safeImage,
    'startDate': live.data || live.date ? `${live.data || live.date}T${live.hora || '00:00'}` : null,
    'endDate': live.data || live.date && live.hora_termino ? `${live.data || live.date}T${live.hora_termino}` : null,
    'eventStatus': 'https://schema.org/EventScheduled',
    'eventAttendanceMode': 'https://schema.org/OnlineEventAttendanceMode',
    'location': {
      '@type': 'VirtualLocation',
      'url': live.link_acesso || liveUrl,
    },
    'organizer': {
      '@type': 'Organization',
      'name': SITE_NAME,
    },
    'offers': {
      '@type': 'Offer',
      'price': '0',
      'priceCurrency': 'EUR',
      'availability': 'https://schema.org/InStock',
    },
  }
}

export function buildBreadcrumbSchema(levels) {
  if (!levels || levels.length === 0) return null

  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    'itemListElement': levels.map((level, i) => {
      const item = {
        '@type': 'ListItem',
        'position': i + 1,
        'name': level.label,
      }
      if (level.href) {
        item.item = level.href.startsWith('http')
          ? level.href
          : `${SITE_URL}${level.href.startsWith('/') ? '' : '/'}${level.href}`
      }
      return item
    }),
  }
}

export function buildOrganizationSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    'name': SITE_NAME,
    'url': SITE_URL,
    'logo': `${SITE_URL}/logo/3.png`,
  }
}

export function buildWebSiteSchema() {
  return {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    'name': SITE_NAME,
    'url': SITE_URL,
    'potentialAction': {
      '@type': 'SearchAction',
      'target': `${SITE_URL}/pt/pesquisa?q={search_term_string}`,
      'query-input': 'required name=search_term_string',
    },
  }
}
