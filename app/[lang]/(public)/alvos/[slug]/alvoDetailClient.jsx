"use client";

import { useContext, useMemo } from "react";
import Link from "next/link";
import SaveButton from "@/components/ui/SaveButton";
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

/**
 * DrugLinks — liga os nomes de fármacos mencionados nos textos de
 * substratos/inibidores/indutores ao perfil do medicamento, mas APENAS para
 * fármacos que existem na base do Conheça Farmácia (match por nome + aliases,
 * case-insensitive, fronteiras de palavra). O resto do texto fica intacto.
 */
function DrugLinks({ text, drugs = [], lang }) {
  const pattern = useMemo(() => {
    const names = (drugs || []).flatMap((d) => [
      d.name,
      ...(d.aliases || []),
    ]);
    if (names.length === 0) return null;
    const escaped = [...new Set(names)]
      .filter(Boolean)
      .map((n) => n.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
      // ordena do mais longo para o mais curto
      .sort((a, b) => b.length - a.length);
    return new RegExp(`\\b(${escaped.join("|")})\\b`, "gi");
  }, [drugs]);

  const segments = useMemo(() => {
    if (!text) return [{ text: "", drug: null }];
    if (!pattern) return [{ text, drug: null }];
    const parts = [];
    let lastIndex = 0;
    let match;
    pattern.lastIndex = 0;
    while ((match = pattern.exec(text)) !== null) {
      if (match.index > lastIndex) {
        parts.push({ text: text.slice(lastIndex, match.index), drug: null });
      }
      const mention = match[0];
      const drug = (drugs || []).find((d) =>
        [d.name, ...(d.aliases || [])].some(
          (n) => n && n.toLowerCase() === mention.toLowerCase()
        )
      );
      parts.push({ text: mention, drug: drug || null });
      lastIndex = match.index + mention.length;
    }
    if (lastIndex < text.length) {
      parts.push({ text: text.slice(lastIndex), drug: null });
    }
    return parts;
  }, [text, pattern, drugs]);

  return (
    <>
      {segments.map((seg, i) =>
        seg.drug ? (
          <Link
            key={i}
            href={`/${lang}/${lang === "pt" ? "medicamento" : "medicine"}/${seg.drug.slug}`}
            className="alvo-drug-link"
          >
            {seg.text}
          </Link>
        ) : (
          <span key={i}>{seg.text}</span>
        )
      )}
    </>
  );
}

export default function AlvoDetailClient({ lang, target, drugs = [] }) {
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
          <div className="flex items-center gap-3">
            <h1 className="alvo-detail-title">{target.name}</h1>
            <SaveButton
              itemType="molecular_target"
              itemId={target.id}
              itemSlug={target.slug}
              itemName={target.name}
              itemSubtitle={target.fullName || target.targetType || null}
              lang={lang}
              size="lg"
              className="save-button-hero"
            />
          </div>
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
              <p>
                <DrugLinks text={target.substrates} drugs={drugs} lang={lang} />
              </p>
            </Section>
          )}
          {target.inhibitors && (
            <Section icon={<Lightbulb size={17} aria-hidden="true" />} title={t("alvos_page.inibidores")}>
              <p>
                <DrugLinks text={target.inhibitors} drugs={drugs} lang={lang} />
              </p>
            </Section>
          )}
        </div>

        {target.inducers && (
          <Section icon={<Lightbulb size={17} aria-hidden="true" />} title={t("alvos_page.indutores")}>
            <p>
              <DrugLinks text={target.inducers} drugs={drugs} lang={lang} />
            </p>
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
