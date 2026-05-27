import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import LiveForm from '@/components/admin/LiveForm'

export default async function EditLivePage({ params }) {
  const { lang, id } = await params

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const { data: live } = await supabase
    .from('lives')
    .select('id, slug, title, excerpt, category, category_label, date, time, end_time, platform, access_link, meeting_id, password, materials, host_name, host_role, host_organization, image_url, status, featured')
    .eq('id', id)
    .single()

  if (!live) redirect(`/${lang}/admin/lives`)

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Live</h1>
        <p className="admin-page-subtitle">{live.title}</p>
      </div>
      <LiveForm mode="edit" initialData={live} lang={lang} />
    </>
  )
}
