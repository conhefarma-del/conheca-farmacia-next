import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import ScientificArticleForm from '@/components/admin/ScientificArticleForm'
import { normalizeScientificArticle, getScientificCategories } from '@/lib/api/scientific-articles'

export const dynamic = 'force-dynamic'

const FULL_COLUMNS =
  'id, slug, title, abstract, keywords, category_id, doi, authors, content, references_arr, read_time, status, featured, published_at, is_archived, journal, volume, issue, pages, license, license_url, scientific_categories(slug, name_pt, name_en, color)'

export default async function EditCientificoPage({ params }) {
  const { lang, id } = await params

  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const { data: article } = await supabase
    .from('scientific_articles')
    .select(FULL_COLUMNS)
    .eq('id', id)
    .single()

  if (!article) redirect(`/${lang}/admin/cientificos`)

  const categories = await getScientificCategories('pt')

  // Tradução EN (pode ser null)
  const { data: translation } = await supabase
    .from('scientific_article_translations')
    .select('id, article_id, lang, slug, title, abstract, keywords, content, references_arr')
    .eq('article_id', id)
    .eq('lang', 'en')
    .maybeSingle()

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Editar Artigo Científico</h1>
        <p className="admin-page-subtitle">{article.title}</p>
      </div>
      <ScientificArticleForm
        mode="edit"
        initialData={normalizeScientificArticle(article, 'pt')}
        categories={categories}
        translation={translation}
        lang={lang}
      />
    </>
  )
}
