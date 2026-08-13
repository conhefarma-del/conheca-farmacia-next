import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getInterviewPeople } from '@/lib/api/interviews'
import EntrevistadosPageClient from '@/components/pages/EntrevistadosPageClient'

export const dynamic = 'force-dynamic'

const PER_PAGE = 30

/**
 * Caminho canónico da listagem de entrevistados (exclui `q` → noindex e
 * `ordenar` → evita duplicados); inclui `page`.
 */
function buildCanonicalPath(base, page) {
  const qs = page && page > 1 ? `?page=${page}` : ''
  return `${base}${qs}`
}

export async function generateMetadata({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath) => t(translations, keyPath)

  const q = typeof sp?.q === 'string' ? sp.q.trim() : ''
  const page = Math.max(1, parseInt(sp?.page, 10) || 1)
  const isSearch = Boolean(q)

  const title = page > 1
    ? `${tFn('entrevistados_page.title')} — ${tFn('entrevistas_page.page_number', { n: page })} | Conheça Farmácia`
    : `${tFn('entrevistados_page.title')} | Conheça Farmácia`

  const ptPath = buildCanonicalPath('/pt/entrevistas/entrevistados', isSearch ? 1 : page)
  const enPath = buildCanonicalPath('/en/entrevistas/entrevistados', isSearch ? 1 : page)

  return {
    title,
    description: tFn('entrevistados_page.subtitle'),
    alternates: {
      canonical: safeLang === 'pt' ? ptPath : enPath,
      languages: {
        pt: ptPath,
        en: enPath,
        'x-default': '/pt/entrevistas/entrevistados',
      },
    },
    robots: isSearch ? { index: false, follow: true } : undefined,
  }
}

export default async function EntrevistadosPage({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  const q = typeof sp?.q === 'string' ? sp.q.trim() : ''
  const ordenar = sp?.ordenar === 'interviews' ? 'interviews' : 'az'
  const page = Math.max(1, parseInt(sp?.page, 10) || 1)

  let people = []
  try {
    people = await getInterviewPeople()
  } catch (err) {
    console.error('Error fetching interview people:', err)
  }

  // Pesquisa (nome/cargo/bio)
  let filtered = people.filter((p) => {
    if (!q) return true
    const term = q.toLowerCase()
    return (
      p.name?.toLowerCase().includes(term) ||
      p.role?.toLowerCase().includes(term) ||
      p.bio?.toLowerCase().includes(term)
    )
  })

  // Ordenação: A–Z (padrão) ou por nº de entrevistas
  filtered = filtered.sort((a, b) => {
    if (ordenar === 'interviews') return (b.interviewCount || 0) - (a.interviewCount || 0)
    return a.name?.localeCompare(b.name, 'pt')
  })

  // Paginação (30 por página)
  const total = filtered.length
  const totalPages = Math.max(1, Math.ceil(total / PER_PAGE))
  const safePage = Math.min(page, totalPages)
  const pagePeople = filtered.slice((safePage - 1) * PER_PAGE, safePage * PER_PAGE)

  return (
    <EntrevistadosPageClient
      people={pagePeople}
      lang={safeLang}
      total={total}
      page={safePage}
      totalPages={totalPages}
      q={q}
      ordenar={ordenar}
    />
  )
}
