import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getScientificArticles, getScientificCategories } from '@/lib/api/scientific-articles'
import CientificosPageClient from '@/components/pages/CientificosPageClient'

export const dynamic = 'force-dynamic'

const PER_PAGE = 15

/**
 * Constrói o caminho canónico (base PT/EN + categoria/página) para uma
 * língua — exclui `q` (pesquisa → noindex) e `ordenar` (evita duplicados).
 */
function buildCanonicalPath(base, categoria, page) {
  const params = new URLSearchParams()
  if (categoria) params.set('categoria', categoria)
  if (page && page > 1) params.set('page', String(page))
  const qs = params.toString()
  return qs ? `${base}?${qs}` : base
}

export async function generateMetadata({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  const categoria = typeof sp?.categoria === 'string' ? sp.categoria : ''
  const q = typeof sp?.q === 'string' ? sp.q.trim() : ''
  const page = Math.max(1, parseInt(sp?.page, 10) || 1)
  const isSearch = Boolean(q)

  const title = page > 1
    ? `${tFn('cientificos_page.hero_title')} — ${tFn('cientificos_page.page_number', { n: page })} | Conheça Farmácia`
    : `${tFn('cientificos_page.hero_title')} | Conheça Farmácia`

  const ptPath = buildCanonicalPath('/pt/cientificos', categoria, isSearch ? 1 : page)
  const enPath = buildCanonicalPath('/en/cientificos', categoria, isSearch ? 1 : page)

  return {
    title,
    description: tFn('cientificos_page.hero_subtitle'),
    alternates: {
      canonical: safeLang === 'pt' ? ptPath : enPath,
      languages: {
        pt: ptPath,
        en: enPath,
        'x-default': '/pt/cientificos',
      },
    },
    // Secção oculta (lib/features.js) — não indexar
    robots: { index: false, follow: false },
  }
}

export default async function CientificosPage({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  const categoria = typeof sp?.categoria === 'string' ? sp.categoria : ''
  const q = typeof sp?.q === 'string' ? sp.q.trim() : ''
  const ordenar = sp?.ordenar === 'views' ? 'views' : 'recent'
  const page = Math.max(1, parseInt(sp?.page, 10) || 1)

  let articles = []
  let categories = []
  try {
    ;[articles, categories] = await Promise.all([
      getScientificArticles(safeLang),
      getScientificCategories(safeLang),
    ])
  } catch (err) {
    console.error('Error fetching scientific articles:', err)
  }

  // Filtro por categoria (da BD)
  let filtered = categoria
    ? articles.filter((a) => a.category?.slug === categoria)
    : articles

  // Pesquisa (mesma lógica que o client usava: título/abstract/keywords)
  if (q) {
    const term = q.toLowerCase()
    filtered = filtered.filter(
      (a) =>
        a.title?.toLowerCase().includes(term) ||
        a.abstract?.toLowerCase().includes(term) ||
        (a.keywords || []).some((k) => k.toLowerCase().includes(term))
    )
  }

  // Ordenação
  filtered = filtered.sort((a, b) => {
    if (ordenar === 'views') return (b.viewCount || 0) - (a.viewCount || 0)
    return new Date(b.date || 0) - new Date(a.date || 0)
  })

  // Paginação
  const total = filtered.length
  const totalPages = Math.max(1, Math.ceil(total / PER_PAGE))
  const safePage = Math.min(page, totalPages)
  const pageArticles = filtered.slice((safePage - 1) * PER_PAGE, safePage * PER_PAGE)

  return (
    <CientificosPageClient
      articles={pageArticles}
      categories={categories}
      lang={safeLang}
      total={total}
      page={safePage}
      totalPages={totalPages}
      categoria={categoria}
      q={q}
      ordenar={ordenar}
    />
  )
}
