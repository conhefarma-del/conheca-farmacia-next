import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getScientificAuthors } from '@/lib/api/scientific-articles'
import CientificosAutoresPageClient from '@/components/pages/CientificosAutoresPageClient'

export const dynamic = 'force-dynamic'

const PER_PAGE = 30

/**
 * Caminho canónico da listagem de autores (exclui `q` → noindex e
 * `ordenar` → evita duplicados); inclui `correspondente` e `page`.
 */
function buildCanonicalPath(base, corresponding, page) {
  const params = new URLSearchParams()
  if (corresponding) params.set('correspondente', '1')
  if (page && page > 1) params.set('page', String(page))
  const qs = params.toString()
  return qs ? `${base}?${qs}` : base
}

export async function generateMetadata({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath) => t(translations, keyPath)

  const q = typeof sp?.q === 'string' ? sp.q.trim() : ''
  const corresponding = sp?.correspondente === '1'
  const page = Math.max(1, parseInt(sp?.page, 10) || 1)
  const isSearch = Boolean(q)

  const title = page > 1
    ? `${tFn('cientifico_autores.title')} — ${tFn('cientificos_page.page_number', { n: page })} | Conheça Farmácia`
    : `${tFn('cientifico_autores.title')} | Conheça Farmácia`

  const ptPath = buildCanonicalPath('/pt/cientificos/autores', corresponding, isSearch ? 1 : page)
  const enPath = buildCanonicalPath('/en/cientificos/autores', corresponding, isSearch ? 1 : page)

  return {
    title,
    description: tFn('cientifico_autores.subtitle'),
    alternates: {
      canonical: safeLang === 'pt' ? ptPath : enPath,
      languages: {
        pt: ptPath,
        en: enPath,
        'x-default': '/pt/cientificos/autores',
      },
    },
    robots: isSearch ? { index: false, follow: true } : undefined,
  }
}

export default async function CientificosAutoresPage({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  const q = typeof sp?.q === 'string' ? sp.q.trim() : ''
  const corresponding = sp?.correspondente === '1'
  const ordenar = sp?.ordenar === 'articles' ? 'articles' : 'az'
  const page = Math.max(1, parseInt(sp?.page, 10) || 1)

  let authors = []
  try {
    authors = await getScientificAuthors(safeLang)
  } catch (err) {
    console.error('Error fetching scientific authors:', err)
  }

  // Filtro por autor correspondente + pesquisa (nome/instituição/departamento/cargo)
  let filtered = authors.filter((a) => {
    if (corresponding && !a.isCorresponding) return false
    if (!q) return true
    const term = q.toLowerCase()
    return (
      a.name?.toLowerCase().includes(term) ||
      a.institution?.toLowerCase().includes(term) ||
      a.department?.toLowerCase().includes(term) ||
      a.role?.toLowerCase().includes(term)
    )
  })

  // Ordenação: A–Z (padrão) ou por nº de artigos publicados
  filtered = filtered.sort((a, b) => {
    if (ordenar === 'articles') return (b.articleCount || 0) - (a.articleCount || 0)
    return a.name?.localeCompare(b.name, 'pt')
  })

  // Paginação (30 por página)
  const total = filtered.length
  const totalPages = Math.max(1, Math.ceil(total / PER_PAGE))
  const safePage = Math.min(page, totalPages)
  const pageAuthors = filtered.slice((safePage - 1) * PER_PAGE, safePage * PER_PAGE)

  return (
    <CientificosAutoresPageClient
      authors={pageAuthors}
      lang={safeLang}
      total={total}
      page={safePage}
      totalPages={totalPages}
      q={q}
      correspondente={corresponding}
      ordenar={ordenar}
    />
  )
}
