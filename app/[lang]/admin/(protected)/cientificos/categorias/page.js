import { createClient } from '@/lib/supabase/server'
import ScientificCategoriesAdminPage from '@/components/admin/ScientificCategoriesAdminPage'
import { getCurrentRole } from '@/lib/actions/content'

export const dynamic = 'force-dynamic'

export default async function CategoriasCientificasPage() {
  const supabase = await createClient()

  const { data: categories } = await supabase
    .from('scientific_categories')
    .select('id, slug, name_pt, name_en, color, sort_order')
    .order('sort_order', { ascending: true })

  const currentUserRole = await getCurrentRole()

  return (
    <ScientificCategoriesAdminPage
      categories={categories || []}
      currentUserRole={currentUserRole}
    />
  )
}
