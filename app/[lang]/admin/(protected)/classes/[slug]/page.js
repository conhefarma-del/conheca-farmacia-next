import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import ClassForm from '@/components/admin/ClassForm'

export const dynamic = 'force-dynamic'

export default async function EditClassPage({ params }) {
  const { lang, slug } = await params

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const { data: cls } = await supabase
    .from('drug_classes')
    .select('id, slug, name_pt, name_en, description_pt, description_en, atc_prefix, sort_order, status')
    .eq('slug', slug)
    .maybeSingle()

  if (!cls) redirect(`/${lang}/admin/classes`)

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Classe</h1>
        <p className="admin-page-subtitle">{cls.name_pt}</p>
      </div>
      <ClassForm mode="edit" initialData={cls} lang={lang} />
    </>
  )
}
