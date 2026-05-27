import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import ArticleForm from '@/components/admin/ArticleForm'

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

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Artigo</h1>
        <p className="admin-page-subtitle">{article.title}</p>
      </div>
      <ArticleForm mode="edit" initialData={article} lang={lang} />
    </>
  )
}
