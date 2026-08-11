import ScientificAdminListPage from '@/components/admin/ScientificAdminListPage'
import { getAllScientificArticlesAdmin, getScientificCategories } from '@/lib/api/scientific-articles'
import { getCurrentRole } from '@/lib/actions/content'

export const dynamic = 'force-dynamic'

export default async function CientificosAdminPage({ params }) {
  const { lang } = await params

  const [articles, categories, currentUserRole] = await Promise.all([
    getAllScientificArticlesAdmin(),
    getScientificCategories('pt'),
    getCurrentRole(),
  ])

  return (
    <ScientificAdminListPage
      articles={articles}
      categories={categories}
      currentUserRole={currentUserRole}
      lang={lang}
    />
  )
}
