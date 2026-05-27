import EventForm from '@/components/admin/EventForm'

export default async function NewEventPage({ params }) {
  const { lang } = await params
  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Novo Evento</h1>
        <p className="admin-page-subtitle">Criar um novo evento</p>
      </div>
      <EventForm mode="create" lang={lang} />
    </>
  )
}
