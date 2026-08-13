import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getInterviews, getInterviewCategories } from '@/lib/api/interviews'
import EntrevistasPageClient from '@/components/pages/EntrevistasPageClient'

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
    ? `${tFn('entrevistas_page.hero_title')} — ${tFn('entrevistas_page.page_number', { n: page })} | Conheça Farmácia`
    : `${tFn('entrevistas_page.hero_title')} | Conheça Farmácia`

  // Entrevistas são apenas PT por agora — o EN partilha a mesma rota /entrevistas
  const ptPath = buildCanonicalPath('/pt/entrevistas', categoria, isSearch ? 1 : page)
  const enPath = buildCanonicalPath('/en/entrevistas', categoria, isSearch ? 1 : page)

  return {
    title,
    description: tFn('entrevistas_page.hero_subtitle'),
    alternates: {
      canonical: safeLang === 'pt' ? ptPath : enPath,
      languages: {
        pt: ptPath,
        en: enPath,
        'x-default': '/pt/entrevistas',
      },
    },
    // Resultados de pesquisa não são indexáveis (duplicados/parâmetros)
    robots: isSearch ? { index: false, follow: true } : undefined,
  }
}

export default async function EntrevistasPage({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  const categoria = typeof sp?.categoria === 'string' ? sp.categoria : ''
  const q = typeof sp?.q === 'string' ? sp.q.trim() : ''
  const ordenar = sp?.ordenar === 'views' ? 'views' : 'recent'
  const page = Math.max(1, parseInt(sp?.page, 10) || 1)

  let interviews = []
  try {
    interviews = await getInterviews()
  } catch (err) {
    console.error('Error fetching interviews:', err)
  }

  let categories = []
  try {
    categories = await getInterviewCategories()
  } catch (err) {
    console.error('Error fetching interview categories:', err)
  }

  // Filtro por categoria
  let filtered = categoria ? interviews.filter((i) => i.category === categoria) : interviews

  // Pesquisa (mesma lógica que o client usava: título/excerto/entrevistado)
  if (q) {
    const term = q.toLowerCase()
    filtered = filtered.filter(
      (i) =>
        i.title?.toLowerCase().includes(term) ||
        i.excerpt?.toLowerCase().includes(term) ||
        (i.interviewee?.name || '').toLowerCase().includes(term)
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
  const pageInterviews = filtered.slice((safePage - 1) * PER_PAGE, safePage * PER_PAGE)

  return (
    <EntrevistasPageClient
      interviews={pageInterviews}
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
