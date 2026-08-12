import { notFound } from 'next/navigation'
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from '@/lib/i18n'
import { getPublicProtocolBySlug, getRelatedProtocols } from '@/lib/actions/protocolos'
import ProtocoloDetailClient from '../../protocolos/[slug]/protocoloDetailClient'

export const revalidate = 3600

export async function generateMetadata({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const translations = loadTranslations(safeLang)
  const tFn = (key) => t(translations, key)
  const protocol = await getPublicProtocolBySlug(slug, safeLang)
  if (!protocol) return { title: `${tFn('protocolos_detalhe.erro_carregar')} | Conheça Farmácia` }
  return {
    title: `${protocol.title} — ${tFn('protocolos_page.hero_title')} | Conheça Farmácia`,
    description: protocol.description,
    alternates: { languages: { pt: `/pt/protocolos/${slug}`, en: `/en/protocols/${slug}` } },
  }
}

export default async function ProtocolDetailPage({ params }) {
  const { lang, slug } = await params
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG
  const protocol = await getPublicProtocolBySlug(slug, safeLang)
  if (!protocol) notFound()
  const related = await getRelatedProtocols(protocol.category.slug, protocol.slug, safeLang, 3)
  return <ProtocoloDetailClient lang={safeLang} protocol={protocol} related={related} />
}