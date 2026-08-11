import Link from "next/link";
import { getSectionHref } from "@/lib/i18n-routes";
import {
  BookOpen,
  ClipboardList,
  Pill,
  Plus,
  Tablets,
  FlaskConical,
  ArrowRight,
} from "lucide-react";

/**
 * ToolsShowcase — homepage, entre o hero e os Artigos em Destaque.
 * Bento: a Calculadora de Interações (a ferramenta mais forte) tem destaque
 * próprio (2/3 da largura, badge + CTA), os Artigos Científicos ocupam 1/3,
 * e as restantes ferramentas (Guias, Protocolos, Medicamentos) ficam em
 * cards pequenos por baixo.
 * Server component: recebe `tFn` (a página já tem traduções carregadas).
 */
export default function ToolsShowcase({ lang = "pt", tFn }) {
  const tools = [
    {
      href: getSectionHref(lang, "guias"),
      icon: BookOpen,
      label: tFn("nav.guias"),
      desc: tFn("nav.guias_desc"),
    },
    {
      href: getSectionHref(lang, "protocolos"),
      icon: ClipboardList,
      label: tFn("nav.protocolos"),
      desc: tFn("nav.protocolos_desc"),
    },
    {
      href: getSectionHref(lang, "medicamentos"),
      icon: Tablets,
      label: tFn("nav.medicamentos"),
      desc: tFn("nav.medicamentos_desc"),
    },
  ];

  return (
    <section className="section-padding tools-showcase">
      <div className="container-center">
        <h2 className="section-title text-3xl font-bold text-center mb-4">
          {tFn("home.tools_title")}
        </h2>
        <p className="text-center text-brand-deep/60 max-w-2xl mx-auto mb-10">
          {tFn("home.tools_subtitle")}
        </p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Calculadora de Interações — destaque próprio (2/3) */}
          <Link
            href={getSectionHref(lang, "interacoes")}
            className="tools-card tools-card-featured tools-card-calculator md:col-span-2"
          >
            <span className="tools-calc-badge">
              {tFn("home.calculator_badge")}
            </span>
            <span className="tools-calc-main">
              <span className="tools-card-icon tools-calc-icon">
                <Pill size={22} aria-hidden="true" />
                <Plus size={14} aria-hidden="true" />
                <Pill size={22} aria-hidden="true" />
              </span>
              <span className="tools-calc-text">
                <span className="tools-card-title">
                  {tFn("nav.interacoes")}
                </span>
                <span className="tools-card-desc">
                  {tFn("nav.interacoes_desc")}
                </span>
              </span>
            </span>
            <span className="tools-calc-cta">
              {tFn("home.calculator_cta")}{" "}
              <ArrowRight size={16} aria-hidden="true" />
            </span>
          </Link>

          {/* Artigos Científicos — destaque (novo conteúdo académico) */}
          <Link
            href={getSectionHref(lang, "cientificos")}
            className="tools-card tools-card-featured md:col-span-1"
          >
            <span className="tools-card-icon">
              <FlaskConical aria-hidden="true" />
            </span>
            <span className="tools-card-title">{tFn("nav.cientificos")}</span>
            <span className="tools-card-desc">
              {tFn("cientificos_page.banner_desc")}
            </span>
            <span className="tools-card-arrow">
              <ArrowRight size={14} aria-hidden="true" />
            </span>
          </Link>

          {/* Restantes ferramentas — cards pequenos */}
          <div className="md:col-span-3 grid grid-cols-2 md:grid-cols-3 gap-4">
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
          </div>
        </div>
      </div>
    </section>
  );
}
