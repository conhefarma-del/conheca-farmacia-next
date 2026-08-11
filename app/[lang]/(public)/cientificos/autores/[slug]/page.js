import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getScientificAuthor } from '@/lib/api/scientific-articles'
import CientificosAuthorPage from '@/components/pages/CientificosAuthorPage'
import { notFound } from 'next/navigation'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let author
  try {
    author = await getScientificAuthor(slug, safeLang)
  } catch {
    return { title: 'Autor — Conheça Farmácia' }
  }
  if (!author) return { title: 'Autor não encontrado — Conheça Farmácia' }

  const translations = loadTranslations(safeLang)
  const title = t(translations, 'cientifico_author.articles_of', { name: author.author.name })

  return {
    title: `${title} | Conheça Farmácia`,
    description: author.author.institution
      ? `${author.author.name} — ${author.author.institution}`
      : undefined,
  }
}

export default async function AuthorArticlesPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath, params) => t(translations, keyPath, params)

  let author
  try {
    author = await getScientificAuthor(slug, safeLang)
  } catch (err) {
    console.error('Error fetching scientific author:', err)
    notFound()
  }
  if (!author) notFound()

  return (
    <CientificosAuthorPage
      author={author.author}
      articles={author.articles}
      lang={safeLang}
      variant="articles"
      tFn={tFn}
    />
  )
}
