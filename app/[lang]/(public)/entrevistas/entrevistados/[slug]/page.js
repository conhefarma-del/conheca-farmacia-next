import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getInterviewPerson } from '@/lib/api/interviews'
import EntrevistadoProfilePage from '@/components/pages/EntrevistadoProfilePage'
import { notFound } from 'next/navigation'

export const dynamic = 'force-dynamic'

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG

  let profile
  try {
    profile = await getInterviewPerson(slug)
  } catch {
    return { title: 'Entrevistado — Conheça Farmácia' }
  }
  if (!profile) return { title: 'Entrevistado não encontrado — Conheça Farmácia' }

  const translations = loadTranslations(safeLang)
  const title = t(translations, 'entrevistado_profile.interviews_of', { name: profile.person.name })

  return {
    title: `${title} | Conheça Farmácia`,
    description: profile.person.role
      ? `${profile.person.name} — ${profile.person.role}`
      : `${profile.person.name} — Entrevistas`,
  }
}

export default async function InterviewPersonPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (keyPath, params) => t(translations, keyPath, params)

  let profile
  try {
    profile = await getInterviewPerson(slug)
  } catch (err) {
    console.error('Error fetching interview person:', err)
    notFound()
  }
  if (!profile) notFound()

  return (
    <EntrevistadoProfilePage
      person={profile.person}
      interviews={profile.interviews}
      lang={safeLang}
      tFn={tFn}
    />
  )
}
