import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import EventForm from '@/components/admin/EventForm'

export default async function EditEventPage({ params }) {
  const { lang, id } = await params

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const { data: event } = await supabase
    .from('events')
    .select('id, slug, title, excerpt, category, category_label, date, time, end_time, location, type, capacity, registration_link, image_url, hosts, status, featured')
    .eq('id', id)
    .single()

  if (!event) redirect(`/${lang}/admin/eventos`)

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Evento</h1>
        <p className="admin-page-subtitle">{event.title}</p>
      </div>
      <EventForm mode="edit" initialData={event} lang={lang} />
    </>
  )
}
