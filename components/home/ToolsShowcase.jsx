import Link from 'next/link'
import { getSectionHref } from '@/lib/i18n-routes'
import { BookOpen, ClipboardList, Pill, Tablets, FlaskConical, ArrowRight } from 'lucide-react'

/**
 * ToolsShowcase — homepage, entre o hero e os Artigos em Destaque.
 * Cards pequenos das 4 ferramentas (Guias, Protocolos, Interações,
 * Medicamentos — mesmas do menu "Ferramentas") + card em destaque dos
 * Artigos Científicos, incentivando a exploração.
 * Server component: recebe `tFn` (a página já tem traduções carregadas).
 */
export default function ToolsShowcase({ lang = 'pt', tFn }) {
  const tools = [
    {
      href: getSectionHref(lang, 'guias'),
      icon: BookOpen,
      label: tFn('nav.guias'),
      desc: tFn('nav.guias_desc'),
    },
    {
      href: getSectionHref(lang, 'protocolos'),
      icon: ClipboardList,
      label: tFn('nav.protocolos'),
      desc: tFn('nav.protocolos_desc'),
    },
    {
      href: getSectionHref(lang, 'interacoes'),
      icon: Pill,
      label: tFn('nav.interacoes'),
      desc: tFn('nav.interacoes_desc'),
    },
    {
      href: getSectionHref(lang, 'medicamentos'),
      icon: Tablets,
      label: tFn('nav.medicamentos'),
      desc: tFn('nav.medicamentos_desc'),
    },
  ]

  return (
    <section className="section-padding bg-brand-bg">
      <div className="container-center">
        <h2 className="section-title text-3xl font-bold text-center mb-4">
          {tFn('home.tools_title')}
        </h2>
        <p className="text-center text-brand-deep/60 max-w-2xl mx-auto mb-10">
          {tFn('home.tools_subtitle')}
        </p>

        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
          {tools.map((tool) => (
            <Link key={tool.href} href={tool.href} className="tools-card">
              <span className="tools-card-icon">
                <tool.icon aria-hidden="true" />
              </span>
              <span className="tools-card-title">{tool.label}</span>
              <span className="tools-card-desc">{tool.desc}</span>
              <span className="tools-card-arrow">
                <ArrowRight size={14} aria-hidden="true" />
              </span>
            </Link>
          ))}

          {/* Artigos Científicos — destaque (novo conteúdo académico) */}
          <Link
            href={getSectionHref(lang, 'cientificos')}
            className="tools-card tools-card-featured col-span-2 md:col-span-1"
          >
            <span className="tools-card-icon">
              <FlaskConical aria-hidden="true" />
            </span>
            <span className="tools-card-title">{tFn('nav.cientificos')}</span>
            <span className="tools-card-desc">{tFn('cientificos_page.banner_desc')}</span>
            <span className="tools-card-arrow">
              <ArrowRight size={14} aria-hidden="true" />
            </span>
          </Link>
        </div>
      </div>
    </section>
  )
}
