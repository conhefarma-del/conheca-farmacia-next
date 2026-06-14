import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { listEntitiesMissingTranslation } from '@/lib/api/translations'
import BulkTranslateClient from './BulkTranslateClient'

export const dynamic = 'force-dynamic'

export default async function TraducoesPage({ params }) {
  const { lang } = await params

  // Auth check (a rota está dentro de (protected), mas reforçamos)
  const supabase = await createClient()
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect(`/${lang}/admin`)

  const [missingArticles, missingEvents, missingLives] = await Promise.all([
    listEntitiesMissingTranslation('article'),
    listEntitiesMissingTranslation('event'),
    listEntitiesMissingTranslation('live'),
  ])

  return (
    <div style={{ padding: '24px' }}>
      <div className="admin-page-header">
        <h1 className="admin-page-title">Gestão de Traduções EN</h1>
        <p className="admin-page-subtitle">
          Artigos, eventos e lives que ainda não têm tradução para inglês. Use o
          botão abaixo para gerar traduções automáticas via IA (OpenRouter).
        </p>
      </div>

      <BulkTranslateClient
        groups={{
          article: missingArticles.map((a) => ({
            id: a.id,
            title: a.title,
            slug: a.slug,
          })),
          event: missingEvents.map((e) => ({
            id: e.id,
            title: e.title,
            slug: e.slug,
          })),
          live: missingLives.map((l) => ({
            id: l.id,
            title: l.title,
            slug: l.slug,
          })),
        }}
        lang={lang}
      />
    </div>
  )
}
