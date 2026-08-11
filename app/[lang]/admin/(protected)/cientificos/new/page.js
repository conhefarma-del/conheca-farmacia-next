import ScientificArticleForm from '@/components/admin/ScientificArticleForm'
import { getScientificCategories } from '@/lib/api/scientific-articles'

export const dynamic = 'force-dynamic'

export default async function NewCientificoPage({ params }) {
  const { lang } = await params
  const categories = await getScientificCategories('pt')

  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Novo Artigo Científico</h1>
        <p className="admin-page-subtitle">Criar uma publicação académica com autores, DOI e citações</p>
      </div>
      <ScientificArticleForm mode="create" categories={categories} lang={lang} />
    </>
  )
}
