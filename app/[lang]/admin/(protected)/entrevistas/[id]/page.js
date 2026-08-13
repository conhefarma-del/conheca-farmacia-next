import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import InterviewForm from '@/components/admin/InterviewForm'
import { getInterviewCategories } from '@/lib/api/interviews'

export default async function EditInterviewPage({ params }) {
  const { lang, id } = await params

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const { data: interview } = await supabase
    .from('interviews')
    .select('*')
    .eq('id', id)
    .single()

  if (!interview) redirect(`/${lang}/admin/entrevistas`)

  const categories = await getInterviewCategories()

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Entrevista</h1>
        <p className="admin-page-subtitle">{interview.title}</p>
      </div>
      <InterviewForm mode="edit" initialData={interview} categories={categories} lang={lang} />
    </>
  )
}
