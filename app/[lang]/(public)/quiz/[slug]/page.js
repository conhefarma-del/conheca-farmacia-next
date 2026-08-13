import { notFound } from 'next/navigation'
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getQuizPools } from '@/lib/api/quiz'
import QuizSessionClient from '@/components/pages/QuizSessionClient'

export const revalidate = 0

const VALID_SOURCES = ['flashcard', 'pharmacology', 'interaction', 'protocol']

/**
 * Interpreta o slug da sessão:
 *  - `rapido`                    → modo rápido (mistura)
 *  - `tipo-<source>`             → modo por tipo
 *  - `deck-<deckSlug>`           → modo por deck
 */
function parseSlug(slug) {
  if (slug === 'rapido') return { mode: 'rapido', source: 'mixed', deckSlug: '' }
  if (slug.startsWith('tipo-')) {
    const source = slug.slice(5)
    if (!VALID_SOURCES.includes(source)) return null
    return { mode: 'tipo', source, deckSlug: '' }
  }
  if (slug.startsWith('deck-')) {
    const deckSlug = slug.slice(5)
    if (!deckSlug) return null
    return { mode: 'deck', source: 'flashcard', deckSlug }
  }
  return null
}

export async function generateMetadata({ params }) {
  const { lang } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)

  return {
    title: `${tFn('quiz_session.page_title')} | Conheça Farmácia`,
    description: tFn('quiz_page.hero_subtitle'),
    // Sessão interativa — não indexável
    robots: { index: false, follow: true },
  }
}

export default async function QuizSessionPage({ params, searchParams }) {
  const { lang } = await params
  const sp = await searchParams
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  const config = parseSlug(String(params.slug || ''))
  if (!config) notFound()

  // Nome do deck (só para o cabeçalho da sessão)
  let deckName = ''
  if (config.mode === 'deck') {
    try {
      const pools = await getQuizPools()
      deckName = pools.decks.find((d) => d.slug === config.deckSlug)?.name || ''
    } catch {
      // silencioso
    }
  }

  const save = sp?.save !== '0'

  return (
    <QuizSessionClient
      lang={safeLang}
      mode={config.mode}
      source={config.source}
      deckSlug={config.deckSlug}
      deckName={deckName}
      save={save}
    />
  )
}
