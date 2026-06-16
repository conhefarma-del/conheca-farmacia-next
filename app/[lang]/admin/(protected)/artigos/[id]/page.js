import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import ArticleForm from '@/components/admin/ArticleForm'
import BilingualTabs from '@/components/admin/BilingualTabs'
import { getTranslationByEntityId } from '@/lib/api/translations'

export default async function EditArticlePage({ params }) {
  const { lang, id } = await params

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const { data: article } = await supabase
    .from('articles')
    .select('id, slug, title, excerpt, meta_description, category, category_label, content, author_name, author_role, author_bio, author_avatar, author_avatar_bg, image_url, published_date, read_time, references_arr, status, featured')
    .eq('id', id)
    .single()

  if (!article) redirect(`/${lang}/admin/artigos`)

  // Carrega tradução EN (pode ser null) para o BilingualTabs
  const translation = await getTranslationByEntityId('article', id, 'en')

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Artigo</h1>
        <p className="admin-page-subtitle">{article.title}</p>
      </div>
      <ArticleForm mode="edit" initialData={article} lang={lang} />

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
          entityType="article"
          entityId={id}
          translation={translation}
          fields={[
            { key: 'title', label: 'Title' },
            { key: 'slug', label: 'Slug' },
            { key: 'excerpt', label: 'Excerpt', type: 'textarea', rows: 3 },
            { key: 'content', label: 'Content (markdown)', type: 'textarea', rows: 12 },
            { key: 'category_label', label: 'Category label' },
            { key: 'author_role', label: 'Author role' },
            { key: 'author_bio', label: 'Author bio', type: 'textarea', rows: 3 },
            { key: 'meta_description', label: 'Meta description', type: 'textarea', rows: 2 },
          ]}
          lang={lang}
        />
      </section>
    </>
  )
}
