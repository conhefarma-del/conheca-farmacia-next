import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import EventForm from '@/components/admin/EventForm'
import BilingualTabs from '@/components/admin/BilingualTabs'
import { getTranslationByEntityId } from '@/lib/api/translations'

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

  // Carrega tradução EN (pode ser null) para o BilingualTabs
  const translation = await getTranslationByEntityId('event', id, 'en')

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Evento</h1>
        <p className="admin-page-subtitle">{event.title}</p>
      </div>
      <EventForm mode="edit" initialData={event} lang={lang} />

      <section
        className="admin-section"
        style={{
          marginTop: '48px',
          padding: '24px',
          background: '#f9fafb',
          borderRadius: '8px',
          border: '1px solid #e5e7eb',
        }}
      >
        <h2 style={{ marginTop: 0 }}>Tradução EN</h2>
        <BilingualTabs
          entityType="event"
          entityId={id}
          translation={translation}
          fields={[
            { key: 'title', label: 'Title' },
            { key: 'slug', label: 'Slug' },
            { key: 'description', label: 'Description', type: 'textarea', rows: 6 },
            { key: 'location', label: 'Location' },
            { key: 'host_role', label: 'Host role' },
            { key: 'host_bio', label: 'Host bio', type: 'textarea', rows: 3 },
            { key: 'meta_description', label: 'Meta description', type: 'textarea', rows: 2 },
          ]}
          lang={lang}
        />
      </section>
    </>
  )
}
