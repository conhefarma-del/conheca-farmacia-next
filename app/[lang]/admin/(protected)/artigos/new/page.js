import ArticleForm from '@/components/admin/ArticleForm'

export default async function NewArticlePage({ params }) {
  const { lang } = await params
  return (
    <>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Novo Artigo</h1>
        <p className="admin-page-subtitle">Criar um novo artigo para o blog</p>
      </div>
      <ArticleForm mode="create" lang={lang} />
    </>
  )
}
