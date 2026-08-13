import { createClient } from '@/lib/supabase/server'
import InterviewCategoriesAdminPage from '@/components/admin/InterviewCategoriesAdminPage'
import { getCurrentRole } from '@/lib/actions/content'

export const dynamic = 'force-dynamic'

export default async function CategoriasEntrevistasPage() {
  const supabase = await createClient()

  const { data: categories } = await supabase
    .from('interview_categories')
    .select('id, slug, name, color, sort_order')
    .order('sort_order', { ascending: true })

  const currentUserRole = await getCurrentRole()

  return (
    <InterviewCategoriesAdminPage
      categories={categories || []}
      currentUserRole={currentUserRole}
    />
  )
}
