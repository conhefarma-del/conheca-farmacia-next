import InterviewForm from '@/components/admin/InterviewForm'
import { getInterviewCategories } from '@/lib/api/interviews'

export default async function NewInterviewPage({ params }) {
  const { lang } = await params
  const categories = await getInterviewCategories()

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Nova Entrevista</h1>
        <p className="admin-page-subtitle">Criar uma nova entrevista</p>
      </div>
      <InterviewForm mode="create" categories={categories} lang={lang} />
    </>
  )
}
