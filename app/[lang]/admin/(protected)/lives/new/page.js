import LiveForm from '@/components/admin/LiveForm'

export default async function NewLivePage({ params }) {
  const { lang } = await params
  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Nova Live</h1>
        <p className="admin-page-subtitle">Criar uma nova live ou webinar</p>
      </div>
      <LiveForm mode="create" lang={lang} />
    </>
  )
}
