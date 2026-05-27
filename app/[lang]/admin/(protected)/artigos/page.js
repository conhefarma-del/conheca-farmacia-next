import ArtigosListPage from '@/components/admin/ArtigosListPage'
import { getAllArticlesAdmin, getArticleStats, getTopArticles } from '@/lib/actions/lists'

/**
 * Artigos List Page — Server Component (puro)
 *
 * Busca dados no servidor e passa como props para ArtigosListPage (Client Component).
 * SEC-API-03: colunas explícitas nas queries.
 */

export default async function ArtigosPage() {
  const [articles, stats, topArticles] = await Promise.all([
    getAllArticlesAdmin(),
    getArticleStats(),
    getTopArticles('views', 3),
  ])

  return (
    <ArtigosListPage
      articles={articles}
      stats={stats}
      topArticles={topArticles}
    />
  )
}
