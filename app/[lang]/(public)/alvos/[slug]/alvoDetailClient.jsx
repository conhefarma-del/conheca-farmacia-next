"use client";

import { useContext } from "react";
import Link from "next/link";
import { ArrowLeft, BookOpen, Info, Lightbulb } from "lucide-react";
import { LangContext } from "@/lib/contexts";

function Section({ icon, title, children }) {
  return (
    <section className="alvo-detail-section">
      <h2 className="alvo-detail-section-title">
        {icon}
        {title}
      </h2>
      <div className="alvo-detail-section-body">{children}</div>
    </section>
  );
}

export default function AlvoDetailClient({ lang, target }) {
  const { t } = useContext(LangContext);

  const typeLabel = t(`alvos_page.tipo_${target.targetType}`);

  return (
    <div className="alvo-detail-page">
      <div className="container-center">
        <Link href={`/${lang}/alvos`} className="alvo-detail-back">
          <ArrowLeft size={16} aria-hidden="true" />
          {t("alvos_page.voltar")}
        </Link>

        <header className="alvo-detail-hero">
          <span className={`alvo-badge alvo-badge-${target.targetType}`}>
            {typeLabel}
          </span>
          <h1 className="alvo-detail-title">{target.name}</h1>
          {target.fullName && (
            <p className="alvo-detail-fullname">{target.fullName}</p>
          )}
          {target.aliases && target.aliases.length > 0 && (
            <p className="alvo-detail-aliases">
              {t("alvos_page.tambem_conhecido")}: {target.aliases.join(", ")}
            </p>
          )}
        </header>

        {target.whatIs && (
          <Section icon={<Info size={17} aria-hidden="true" />} title={t("alvos_page.o_que_e")}>
            <p>{target.whatIs}</p>
          </Section>
        )}

        {target.role && (
          <Section icon={<BookOpen size={17} aria-hidden="true" />} title={t("alvos_page.papel_interacoes")}>
            <p>{target.role}</p>
          </Section>
        )}

        <div className="alvo-detail-cols">
          {target.substrates && (
            <Section icon={<Lightbulb size={17} aria-hidden="true" />} title={t("alvos_page.substratos")}>
              <p>{target.substrates}</p>
            </Section>
          )}
          {target.inhibitors && (
            <Section icon={<Lightbulb size={17} aria-hidden="true" />} title={t("alvos_page.inibidores")}>
              <p>{target.inhibitors}</p>
            </Section>
          )}
        </div>

        {target.inducers && (
          <Section icon={<Lightbulb size={17} aria-hidden="true" />} title={t("alvos_page.indutores")}>
            <p>{target.inducers}</p>
          </Section>
        )}

        {target.clinicalNotes && (
          <Section icon={<Lightbulb size={17} aria-hidden="true" />} title={t("alvos_page.notas_clinicas")}>
            <p>{target.clinicalNotes}</p>
          </Section>
        )}

        {target.source && (
          <Section icon={<BookOpen size={17} aria-hidden="true" />} title={t("alvos_page.fonte")}>
            <p className="alvo-detail-source">{target.source}</p>
          </Section>
        )}
      </div>
    </div>
  );
}
