"use client";

import { useContext, useMemo } from "react";
import Link from "next/link";
import { ArrowLeft, BookOpen, Info, Lightbulb } from "lucide-react";
import { LangContext } from "@/lib/contexts";
import { getFlockhartEvidence } from "@/lib/targets/flockhart-evidence";

function Section({ icon, title, count, children }) {
  return (
    <section className="alvo-detail-section">
      <h2 className="alvo-detail-section-title">
        {icon}
        {title}
        {typeof count === "number" && count > 0 && (
          <span className="alvo-list-count">{count}</span>
        )}
      </h2>
      <div className="alvo-detail-section-body">{children}</div>
    </section>
  );
}

/**
 * splitListCount — conta os itens de uma lista editorial do alvo
 * (substrates_pt/inhibitors_pt/inducers_pt) com a mesma normalização de
 * lib/targets/derive.js, para o contador do título da secção bater certo
 * com os cards da listagem /alvos (getTargetDrugCounts).
 */
const COUNT_RESERVED = new Set([
  "substratos", "substrates", "inibidores", "inhibitors", "indutores", "inducers",
  "lista", "em", "revisão", "revisao", "não", "nao", "aplicável", "aplicavel",
  "aplicável", "nenhum", "nenhuma", "não aplicável", "nao aplicavel",
]);

function splitListCount(text) {
  if (!text) return 0;
  return String(text)
    .replace(/^[^:]*:/, "")
    .split(/[,;]/)
    .map((item) =>
      item
        .replace(/\([^)]*\)/g, " ")
        .replace(/[^a-z0-9\s]/gi, " ")
        .replace(/\s+/g, " ")
        .trim()
    )
    .filter((item) => item && !COUNT_RESERVED.has(item.toLowerCase())).length;
}

/**
 * PillList — lista editorial do alvo como "pill cloud": um chip por fármaco.
 *  - Fármaco existente na BD (match por nome/alias) → chip clicável que
 *    navega para /medicamento/[slug] (match por nome + aliases)
 *  - Restantes nomes → chip não-clicável
 *  - Evidência Flockhart: pontinho colorido por chip — forte (#ff6c23) e
 *    moderada (#006171) — com legenda por secção.
 */
function PillList({ text, drugs = [], lang, targetSlug, role }) {
  const { t } = useContext(LangContext);

  // 1. Dividir a lista em itens (mesma normalização de derive.splitList)
  const items = useMemo(() => {
    if (!text) return [];
    return String(text)
      .replace(/^[^:]*:/, "")
      .split(/[,;]/)
      .map((item) => item.replace(/\s+/g, " ").trim().replace(/\.$/, ""))
      .filter(Boolean);
  }, [text]);

  // 2. Classificar cada item: é fármaco da BD? Tem nota de evidência?
  const classified = useMemo(() => {
    const byLower = new Map();
    (drugs || []).forEach((d) => {
      [d.name, ...(d.aliases || [])].forEach((n) => {
        if (n && !byLower.has(n.toLowerCase())) byLower.set(n.toLowerCase(), d);
      });
    });
    return items.map((raw) => {
      // Notas entre parênteses não impedem o match ("amlodipina (3A5)")
      const core = raw.replace(/\([^)]*\)/g, " ").replace(/\s+/g, " ").trim();
      const drug =
        byLower.get(core.toLowerCase()) ||
        byLower.get(raw.toLowerCase()) ||
        null;
      // Evidência Flockhart (só alvos CYP, papéis substrate/inhibitor):
      // 'strong' | 'moderate' | null — colore o pontinho do chip
      const evidence = getFlockhartEvidence(targetSlug, role, core);
      return { raw, core, drug, evidence };
    });
  }, [items, drugs]);

  if (classified.length === 0) return null;

  const hasEvidence = classified.some((it) => it.evidence);

  return (
    <div>
      <div className="alvo-pill-cloud">
        {classified.map((it, i) => {
          const evClass =
            it.evidence === "strong"
              ? " ev-strong"
              : it.evidence === "moderate"
                ? " ev-moderate"
                : "";
          const dot =
            it.evidence ? (
              <span className={`alvo-ev-dot${evClass}`} aria-hidden="true" />
            ) : null;
          return it.drug ? (
            <Link
              key={i}
              href={`/${lang}/${lang === "pt" ? "medicamento" : "medicine"}/${it.drug.slug}`}
              className={`alvo-pill alvo-pill-link${evClass}`}
              title={
                it.evidence
                  ? t(`alvos_page.evidencia_${it.evidence === "strong" ? "forte" : "moderada"}`)
                  : undefined
              }
            >
              {dot}
              {it.raw}
            </Link>
          ) : (
            <span key={i} className={`alvo-pill${evClass}`} title={
              it.evidence
                ? t(`alvos_page.evidencia_${it.evidence === "strong" ? "forte" : "moderada"}`)
                : undefined
            }>
              {dot}
              {it.raw}
            </span>
          );
        })}
      </div>
      {hasEvidence && (
        <div className="alvo-pill-legend">
          <span>
            <span className="alvo-ev-dot ev-strong" aria-hidden="true" />
            {t("alvos_page.evidencia_forte")}
          </span>
          <span>
            <span className="alvo-ev-dot ev-moderate" aria-hidden="true" />
            {t("alvos_page.evidencia_moderada")}
          </span>
        </div>
      )}
    </div>
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
            <Section
              icon={<Lightbulb size={17} aria-hidden="true" />}
              title={t("alvos_page.substratos")}
              count={splitListCount(target.substrates)}
            >
              <PillList text={target.substrates} drugs={drugs} lang={lang} targetSlug={target.slug} role="substrate" />
            </Section>
          )}
          {target.inhibitors && (
            <Section
              icon={<Lightbulb size={17} aria-hidden="true" />}
              title={t("alvos_page.inibidores")}
              count={splitListCount(target.inhibitors)}
            >
              <PillList text={target.inhibitors} drugs={drugs} lang={lang} targetSlug={target.slug} role="inhibitor" />
            </Section>
          )}
        </div>

        {target.inducers && (
          <Section
            icon={<Lightbulb size={17} aria-hidden="true" />}
            title={t("alvos_page.indutores")}
            count={splitListCount(target.inducers)}
          >
            <PillList text={target.inducers} drugs={drugs} lang={lang} targetSlug={target.slug} role="inducer" />
          </Section>
        )}

        {target.clinicalNotes && (
          <Section icon={<Lightbulb size={17} aria-hidden="true" />} title={t("alvos_page.notas_clinicas")}>
            <p>{target.clinicalNotes}</p>
          </Section>
        )}

        {target.source && (
          <aside className="alvo-source-card">
            <h3>
              <BookOpen size={14} aria-hidden="true" />
              {t("alvos_page.fonte")}
            </h3>
            <p className="alvo-detail-source">{target.source}</p>
          </aside>
        )}
      </div>
    </div>
  );
}
