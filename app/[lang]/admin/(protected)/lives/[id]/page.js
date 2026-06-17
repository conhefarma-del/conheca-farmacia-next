import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import LiveForm from '@/components/admin/LiveForm'
import BilingualTabs from '@/components/admin/BilingualTabs'
import { getTranslationByEntityId } from '@/lib/api/translations'

export default async function EditLivePage({ params }) {
  const { lang, id } = await params

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const { data: live } = await supabase
    .from('lives')
    .select('id, slug, title, excerpt, category, category_label, date, time, end_time, platform, access_link, meeting_id, password, materials, hosts, topic, image_url, status, featured_langs')
    .eq('id', id)
    .single()

  if (!live) redirect(`/${lang}/admin/lives`)

  // Carrega tradução EN (pode ser null) para o BilingualTabs
  const translation = await getTranslationByEntityId('live', id, 'en')

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Live</h1>
        <p className="admin-page-subtitle">{live.title}</p>
      </div>
      <LiveForm mode="edit" initialData={live} lang={lang} />

      <section
        className="admin-section"
        style={{
          marginTop: '48px',
          padding: '24px',
          background: 'var(--admin-card-bg, #f9fafb)',
          borderRadius: '8px',
          border: '1px solid var(--admin-border, #e5e7eb)',
        }}
      >
        <h2 style={{ marginTop: 0 }}>Tradução EN</h2>
        <BilingualTabs
          entityType="live"
          entityId={id}
          translation={translation}
          ptHosts={live.hosts ?? []}
          fields={[
            { key: 'title', label: 'Title' },
            { key: 'slug', label: 'Slug' },
            { key: 'excerpt', label: 'Excerpt', type: 'textarea', rows: 6 },
            { key: 'topic', label: 'Topic' },
            { key: 'hosts', label: 'Hosts' },
          ]}
          lang={lang}
        />
      </section>
    </>
  )
}
