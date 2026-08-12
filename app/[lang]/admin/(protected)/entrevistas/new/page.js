import InterviewForm from '@/components/admin/InterviewForm'

export default async function NewInterviewPage({ params }) {
  const { lang } = await params
  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Nova Entrevista</h1>
        <p className="admin-page-subtitle">Criar uma nova entrevista</p>
      </div>
      <InterviewForm mode="create" lang={lang} />
    </>
  )
}
