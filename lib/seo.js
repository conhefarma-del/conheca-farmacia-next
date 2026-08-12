import { SITE_NAME, SITE_URL, SITE_LOGO } from '@/lib/constants'
import { INTERACOES_FAQ_ITEMS } from '@/lib/interacoes-faq'

// Schema da Calculadora de Interações: uma WebApplication (HealthApplication)
// e um FAQPage construído a partir das perguntas partilhadas (client+server).
export function buildInteractionCheckerSchema(tFn, lang = 'pt') {
  const path = lang === 'en' ? 'en/interactions' : 'pt/interacoes'
  const url = `${SITE_URL}/${path}`
  return [
    {
      '@context': 'https://schema.org',
      '@type': 'WebApplication',
      name: tFn('interacoes_page.hero_title'),
      description: tFn('interacoes_page.hero_subtitle'),
      url,
      applicationCategory: 'HealthApplication',
      operatingSystem: 'Web',
      inLanguage: lang === 'en' ? 'en' : 'pt',
    },
    {
      '@context': 'https://schema.org',
      '@type': 'FAQPage',
      inLanguage: lang === 'en' ? 'en' : 'pt',
      mainEntity: INTERACOES_FAQ_ITEMS.map(({ q, a }) => ({
        '@type': 'Question',
        name: tFn(q),
        acceptedAnswer: {
          '@type': 'Answer',
          text: tFn(a),
        },
      })),
    },
  ]
}

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

// Schema de página médica (MedicalWebPage) para as fichas de fármaco.
// Declara o público (leigo vs profissional), a data da última revisão e a
// entidade Drug sobre a qual a página é — sinais de confiança E-E-A-T para
// conteúdo YMYL. `lastReviewed` usa o updated_at do perfil quando disponível.
export function buildMedicalWebPageSchema(drug, lang = 'pt') {
  if (!drug) return null

  const url =
    lang === 'en'
      ? `${SITE_URL}/en/medicine/${drug.slug}`
      : `${SITE_URL}/pt/medicamento/${drug.slug}`

  const schema = {
    '@context': 'https://schema.org',
    '@type': 'MedicalWebPage',
    'name': drug.name,
    'url': url,
    'description': drug.profile?.overviewPublic || drug.className || drug.name,
    'inLanguage': lang === 'en' ? 'en' : 'pt',
    'medicalAudience': [
      { '@type': 'MedicalAudience', 'audienceType': 'patient' },
      { '@type': 'MedicalAudience', 'audienceType': 'clinician' },
    ],
    'about': {
      '@type': 'Drug',
      'name': drug.name,
      'url': url,
      'identifier': drug.atcCode
        ? {
            '@type': 'PropertyValue',
            'propertyID': 'ATC',
            'value': drug.atcCode,
          }
        : undefined,
    },
    'mainEntity': {
      '@type': 'Drug',
      'name': drug.name,
      'url': url,
    },
    'reviewedBy': {
      '@type': 'Organization',
      'name': SITE_NAME,
      'url': SITE_URL,
    },
    'isPartOf': {
      '@type': 'WebSite',
      'name': SITE_NAME,
      'url': SITE_URL,
    },
  }

  // JSON.stringify omite propriedades `undefined`, por isso só adicionamos
  // lastReviewed quando existe data real (updated_at do perfil).
  if (drug.profile?.updatedAt) {
    schema.lastReviewed = String(drug.profile.updatedAt).slice(0, 10)
  }
  return schema
}

// Schema académico (ScholarlyArticle) para os Artigos Científicos.
// Autores reais como array de Person, DOI via sameAs e acesso livre.
// Sinais E-E-A-T para conteúdo YMYL de saúde: autor afiliado + DOI + data.
export function buildScholarlyArticleSchema(article, lang = 'pt') {
  if (!article) return null

  const articleUrl = `${SITE_URL}/${lang}/cientificos/${article.slug}`
  const authors = Array.isArray(article.authors) ? article.authors : []
  const doi = (article.doi || '').trim()

  const schema = {
    '@context': 'https://schema.org',
    '@type': 'ScholarlyArticle',
    'headline': article.title,
    'description': article.abstract || article.title,
    'datePublished': article.publishedAt || article.date || null,
    'dateModified': article.publishedAt || article.date || null,
    'inLanguage': lang === 'en' ? 'en' : 'pt',
    'isAccessibleForFree': true,
    'author': authors.length
      ? authors.map((a) => ({
          '@type': 'Person',
          'name': a.name || SITE_NAME,
          'affiliation': a.institution
            ? { '@type': 'Organization', 'name': a.institution }
            : undefined,
        }))
      : { '@type': 'Person', 'name': SITE_NAME },
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

  // JSON.stringify omite `undefined` — só adicionamos sameAs com DOI real.
  if (doi) {
    schema.sameAs = `https://doi.org/${doi}`
  }
  return schema
}

export function buildInterviewSchema(interview, lang = 'pt') {
  if (!interview) return null

  const url = `${SITE_URL}/${lang}/entrevistas/${interview.slug}`
  const interviewees =
    Array.isArray(interview.interviewees) && interview.interviewees.length > 0
      ? interview.interviewees
      : interview.interviewee?.name
        ? [interview.interviewee]
        : []
  const people = interviewees.map((p) => ({
    '@type': 'Person',
    'name': p.name || SITE_NAME,
    ...(p.role ? { 'jobTitle': p.role } : {}),
  }))

  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    'headline': interview.title,
    'description': interview.metaDescription || interview.excerpt || interview.title,
    'datePublished': interview.date || null,
    'dateModified': interview.date || null,
    'author': people.length > 1 ? people : (people[0] || { '@type': 'Person', 'name': SITE_NAME }),
    'publisher': {
      '@type': 'Organization',
      'name': SITE_NAME,
      'logo': { '@type': 'ImageObject', 'url': SITE_LOGO },
    },
    'mainEntityOfPage': { '@type': 'WebPage', '@id': url },
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
