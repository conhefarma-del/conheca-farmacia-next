import ArtigosListPage from '@/components/admin/ArtigosListPage'
import { getAllArticlesAdmin, getArticleStats, getTopArticles } from '@/lib/actions/lists'
import { getCurrentRole } from '@/lib/actions/content'

/**
 * Artigos List Page — Server Component (puro)
 *
 * Busca dados no servidor e passa como props para ArtigosListPage (Client Component).
 * SEC-API-03: colunas explícitas nas queries.
 * Phase 4 (2026-06-15): passa currentUserRole para condicionar visibilidade de botões.
 */

export default async function ArtigosPage() {
  const [articles, stats, topArticles, currentUserRole] = await Promise.all([
    getAllArticlesAdmin(),
    getArticleStats(),
    getTopArticles('views', 3),
    getCurrentRole(),
  ])

  return (
    <ArtigosListPage
      articles={articles}
      stats={stats}
      topArticles={topArticles}
      currentUserRole={currentUserRole}
    />
  )
}
