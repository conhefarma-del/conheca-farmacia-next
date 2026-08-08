"use client";

import { useContext, useMemo, useState } from "react";
import Link from "next/link";
import {
  AlertTriangle,
  Apple,
  ArrowLeft,
  ArrowUpRight,
  Baby,
  BookOpen,
  CheckCircle2,
  ChevronDown,
  HeartPulse,
  Info,
  Pill,
  ShieldAlert,
  Users,
  Stethoscope,
} from "lucide-react";
import { LangContext } from "@/lib/contexts";

const SEVERITY_META = {
  critical: { icon: ShieldAlert },
  moderate: { icon: AlertTriangle },
  minor: { icon: Info },
  none: { icon: CheckCircle2 },
  unknown: { icon: BookOpen },
};

// Chips de filtro por severidade (mesmo padrão do checker).
const SEVERITY_FILTERS = [
  { value: "all", labelKey: "interacoes_page.filter_todas" },
  { value: "critical", labelKey: "interacoes_page.severidade_critical" },
  { value: "moderate", labelKey: "interacoes_page.severidade_moderate" },
  { value: "minor", labelKey: "interacoes_page.severidade_minor" },
  { value: "none", labelKey: "interacoes_page.severidade_none" },
];

function severityLabelKey(severity) {
  return `interacoes_page.severidade_${severity}`;
}

function pregnancySeverity(category) {
  if (category === "contraindicated") return "critical";
  if (category === "caution") return "moderate";
  if (category === "compatible") return "none";
  return "unknown";
}

function InteractionCard({ titleA, titleB, severity, description, children }) {
  const { t } = useContext(LangContext);
  const Icon = SEVERITY_META[severity]?.icon || Info;
  const hasContent = Array.isArray(children)
    ? children.some(Boolean)
    : Boolean(children);
  return (
    <div className={`interaction-card is-${severity}`}>
      <div className="card-header">
        <div className="card-drugs">
          <span className="card-drug">{titleA}</span>
          <span className="card-vs">+</span>
          <span className="card-drug">{titleB}</span>
        </div>
        <span className={`severity-badge is-${severity}`}>
          <Icon size={12} aria-hidden="true" />
          {t(severityLabelKey(severity))}
        </span>
      </div>
      {description && <p className="card-description">{description}</p>}
      {hasContent && (
        <details className="card-details">
          <summary className="card-toggle">
            {t("interacoes_page.expandir")}
            <ChevronDown size={14} aria-hidden="true" />
          </summary>
          <div className="interaction-detail">{children}</div>
        </details>
      )}
    </div>
  );
}

function InfoList({ titleKey, text }) {
  const { t } = useContext(LangContext);
  if (!text) return null;
  const items = text
    .split("\n")
    .map((s) => s.trim())
    .filter(Boolean);
  return (
    <div className="medicamento-info-block">
      <h3 className="medicamento-info-title">{t(titleKey)}</h3>
      <ul className="medicamento-info-list">
        {items.map((item, i) => (
          <li key={i}>{item}</li>
        ))}
      </ul>
    </div>
  );
}

function DetailBlock({ titleKey, children, className }) {
  const { t } = useContext(LangContext);
  if (!children) return null;
  return (
    <div className={`detail-block ${className || ""}`}>
      <h4 className="detail-title">{t(titleKey)}</h4>
      <p>{children}</p>
    </div>
  );
}

export default function MedicamentoDetailClient({
  lang,
  drug,
  drugs,
  interactions,
}) {
  const { t } = useContext(LangContext);
  const [audience, setAudience] = useState("public");
  const [severityFilter, setSeverityFilter] = useState("all");

  const listPath = `/${lang}/${lang === "pt" ? "medicamentos" : "medicines"}`;
  const checkerPath = `/${lang}/${lang === "pt" ? "interacoes" : "interactions"}?farmaco=${drug.slug}`;
  const detailPath = (slug) =>
    `/${lang}/${lang === "pt" ? "medicamento" : "medicine"}/${slug}`;
  const drugsById = useMemo(() => {
    const map = {};
    drugs.forEach((d) => {
      map[d.id] = d;
    });
    return map;
  }, [drugs]);

  // Fármacos relacionados/similares: mesmo subgrupo químico ATC (prefixo 4),
  // depois subgrupo farmacológico (prefixo 3), por fim a mesma classe.
  const relatedDrugs = useMemo(() => {
    const atc = drug.atcCode || "";
    const pool = [];
    const pushUnique = (list) => {
      list.forEach((d) => {
        if (d.id !== drug.id && !pool.some((x) => x.id === d.id)) pool.push(d);
      });
    };
    if (atc.length >= 4)
      pushUnique(
        drugs.filter((d) => d.atcCode?.slice(0, 4) === atc.slice(0, 4))
      );
    if (atc.length >= 3)
      pushUnique(
        drugs.filter((d) => d.atcCode?.slice(0, 3) === atc.slice(0, 3))
      );
    pushUnique(
      drugs.filter((d) => d.className && d.className === drug.className)
    );
    return pool.sort((a, b) => a.name.localeCompare(b.name)).slice(0, 10);
  }, [drug, drugs]);

  // Filtro de severidade aplicado às 4 secções de interações.
  const hasInteractions =
    interactions.drugDrug.length > 0 ||
    interactions.food.length > 0 ||
    interactions.disease.length > 0 ||
    interactions.pregnancy.length > 0;
  const sevMatches = (s) => severityFilter === "all" || severityFilter === s;
  const filteredDrugDrug = interactions.drugDrug.filter((p) =>
    sevMatches(p.severity)
  );
  const filteredFood = interactions.food.filter((x) => sevMatches(x.severity));
  const filteredDisease = interactions.disease.filter((x) =>
    sevMatches(x.severity)
  );
  const filteredPregnancy = interactions.pregnancy.filter((x) =>
    sevMatches(pregnancySeverity(x.pregnancyCategory))
  );

  const partnerName = (pair) => {
    const partnerId = pair.drugAId === drug.id ? pair.drugBId : pair.drugAId;
    return drugsById[partnerId]?.name || "—";
  };

  const overview =
    audience === "public"
      ? drug.profile?.overviewPublic
      : drug.profile?.overviewPro;
  const profileSourceUrl =
    drug.profile?.source?.match(/https:\/\/[^\s]+/)?.[0] || "";

  return (
    <div className="medicamento-page">
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <p className="hero-subtitle text-center mb-3">
              <Link href={listPath} className="medicamento-back-link">
                <ArrowLeft size={14} aria-hidden="true" />
                {t("medicamento_detalhe.voltar")}
              </Link>
            </p>
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-4 break-words">
              {drug.name}
            </h1>
            {drug.className && (
              <p className="hero-subtitle text-center">{drug.className}</p>
            )}
            <p className="text-center mt-4">
              <Link href={checkerPath} className="medicamento-checker-btn">
                <ShieldAlert size={14} aria-hidden="true" />
                {t("medicamento_detalhe.verificar_interacoes", {
                  name: drug.name,
                })}
              </Link>
            </p>
          </div>
        </div>
      </section>

      <div className="container-center">
        {/* Toggle de audiência + perfil */}
        {drug.profile && (
          <section className="medicamento-profile">
            <div
              className="audience-toggle"
              role="group"
              aria-label={t("medicamento_detalhe.audiencia_publico")}
            >
              <button
                className={`audience-toggle-btn${audience === "public" ? " is-active" : ""}`}
                aria-pressed={audience === "public"}
                onClick={() => setAudience("public")}
              >
                <Users size={14} aria-hidden="true" />
                {t("medicamento_detalhe.audiencia_publico")}
              </button>
              <button
                className={`audience-toggle-btn${audience === "pro" ? " is-active" : ""}`}
                aria-pressed={audience === "pro"}
                onClick={() => setAudience("pro")}
              >
                <Stethoscope size={14} aria-hidden="true" />
                {t("medicamento_detalhe.audiencia_profissionais")}
              </button>
            </div>
            <p className="medicamento-overview">{overview}</p>
            {drug.profile.source && (
              <p className="medicamento-source">
                <span className="detail-title">
                  {t("interacoes_page.fonte")}
                </span>
                <span>
                  {drug.profile.source}
                  {profileSourceUrl && (
                    <a
                      href={profileSourceUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <ArrowUpRight size={13} aria-hidden="true" />
                    </a>
                  )}
                </span>
              </p>
            )}
            {drug.aliases?.length > 0 && (
              <p className="medicamento-aliases">
                <strong>{t("medicamento_detalhe.aliases")}:</strong>{" "}
                {drug.aliases.join(", ")}
              </p>
            )}
          </section>
        )}

        {/* ---- Informação do fármaco (indicações, efeitos, precauções) ---- */}
        {(drug.profile?.indications ||
          drug.profile?.sideEffects ||
          drug.profile?.precautions) && (
          <section className="medicamento-profile">
            <InfoList
              titleKey="medicamento_detalhe.indications"
              text={drug.profile.indications}
            />
            <InfoList
              titleKey="medicamento_detalhe.side_effects"
              text={drug.profile.sideEffects}
            />
            <InfoList
              titleKey="medicamento_detalhe.precautions"
              text={drug.profile.precautions}
            />
          </section>
        )}

        {/* ---- Fármacos relacionados/similares ---- */}
        {relatedDrugs.length > 0 && (
          <section className="medicamento-section">
            <h2 className="medicamento-section-title">
              <BookOpen size={18} aria-hidden="true" />
              {t("medicamento_detalhe.secao_relacionados")}
            </h2>
            <p className="medicamento-section-subtitle">
              {t("medicamento_detalhe.relacionados_subtitle")}
            </p>
            <div className="related-drugs">
              {relatedDrugs.map((d) => (
                <Link
                  key={d.id}
                  href={detailPath(d.slug)}
                  className="related-drug-chip"
                >
                  <span className="related-drug-name">{d.name}</span>
                  {d.className && (
                    <span className="related-drug-class">{d.className}</span>
                  )}
                </Link>
              ))}
            </div>
          </section>
        )}

        {/* ---- Filtro de severidade das interações ---- */}
        {hasInteractions && (
          <div className="medicamento-filter-bar">
            <span className="medicamento-filter-label">
              {t("interacoes_page.filter_aria_label")}
            </span>
            <div
              className="severity-filters"
              role="group"
              aria-label={t("interacoes_page.filter_aria_label")}
            >
              {SEVERITY_FILTERS.map((f) => (
                <button
                  key={f.value}
                  className={`severity-filter-chip${severityFilter === f.value ? " is-active" : ""}`}
                  aria-pressed={severityFilter === f.value}
                  onClick={() => setSeverityFilter(f.value)}
                >
                  {t(f.labelKey)}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* ---- Interações fármaco-fármaco ---- */}
        <section className="medicamento-section">
          <h2 className="medicamento-section-title">
            <Pill size={18} aria-hidden="true" />
            {t("medicamento_detalhe.secao_interacoes")}
          </h2>
          {interactions.drugDrug.length === 0 ? (
            <p className="medicamento-empty">
              {t("medicamento_detalhe.sem_interacoes")}
            </p>
          ) : filteredDrugDrug.length === 0 ? (
            <p className="medicamento-empty">
              {t("interacoes_page.filter_sem_resultados")}
            </p>
          ) : (
            <div className="medicamento-cards">
              {filteredDrugDrug.map((pair) => (
                <InteractionCard
                  key={pair.id}
                  titleA={drug.name}
                  titleB={partnerName(pair)}
                  severity={pair.severity}
                  description={
                    audience === "public"
                      ? pair.summary
                      : pair.summaryPro || pair.summary
                  }
                >
                  <DetailBlock
                    titleKey="interacoes_page.explicacao"
                    className="detail-explanation"
                  >
                    {pair.explanation}
                  </DetailBlock>
                  {audience === "public" && (
                    <DetailBlock titleKey="interacoes_page.resumo_profissionais">
                      {pair.summaryPro}
                    </DetailBlock>
                  )}
                  <DetailBlock titleKey="interacoes_page.mecanismo">
                    {pair.mechanism}
                  </DetailBlock>
                  <DetailBlock titleKey="interacoes_page.monitorizacao">
                    {pair.monitoring}
                  </DetailBlock>
                  <DetailBlock
                    titleKey="interacoes_page.sinais_alerta"
                    className="detail-red-flags"
                  >
                    {pair.redFlags}
                  </DetailBlock>
                  <DetailBlock
                    titleKey="interacoes_page.recomendacao"
                    className="detail-recommendation"
                  >
                    {pair.management}
                  </DetailBlock>
                  <DetailBlock
                    titleKey="interacoes_page.fonte"
                    className="detail-source"
                  >
                    {pair.source}
                  </DetailBlock>
                </InteractionCard>
              ))}
            </div>
          )}
        </section>

        {/* ---- Alimentos & bebidas ---- */}
        <section className="medicamento-section">
          <h2 className="medicamento-section-title">
            <Apple size={18} aria-hidden="true" />
            {t("medicamento_detalhe.secao_alimentos")}
          </h2>
          {interactions.food.length === 0 ? (
            <p className="medicamento-empty">
              {t("medicamento_detalhe.sem_alimentos")}
            </p>
          ) : filteredFood.length === 0 ? (
            <p className="medicamento-empty">
              {t("interacoes_page.filter_sem_resultados")}
            </p>
          ) : (
            <div className="medicamento-cards">
              {filteredFood.map((item) => (
                <InteractionCard
                  key={item.id}
                  titleA={drug.name}
                  titleB={item.entity}
                  severity={item.severity}
                  description={item.mechanism}
                >
                  <DetailBlock
                    titleKey="interacoes_page.recomendacao"
                    className="detail-recommendation"
                  >
                    {item.advice}
                  </DetailBlock>
                  <DetailBlock
                    titleKey="interacoes_page.fonte"
                    className="detail-source"
                  >
                    {item.source}
                  </DetailBlock>
                </InteractionCard>
              ))}
            </div>
          )}
        </section>

        {/* ---- Doenças ---- */}
        <section className="medicamento-section">
          <h2 className="medicamento-section-title">
            <HeartPulse size={18} aria-hidden="true" />
            {t("medicamento_detalhe.secao_doencas")}
          </h2>
          {interactions.disease.length === 0 ? (
            <p className="medicamento-empty">
              {t("medicamento_detalhe.sem_doencas")}
            </p>
          ) : filteredDisease.length === 0 ? (
            <p className="medicamento-empty">
              {t("interacoes_page.filter_sem_resultados")}
            </p>
          ) : (
            <div className="medicamento-cards">
              {filteredDisease.map((item) => {
                const isCI = item.interactionType === "contraindication";
                return (
                  <InteractionCard
                    key={item.id}
                    titleA={drug.name}
                    titleB={item.condition}
                    severity={item.severity}
                    description={item.reason}
                  >
                    <DetailBlock
                      titleKey="interacoes_page.recomendacao"
                      className="detail-recommendation"
                    >
                      {item.advice}
                    </DetailBlock>
                    <DetailBlock
                      titleKey="interacoes_page.fonte"
                      className="detail-source"
                    >
                      {item.source}
                    </DetailBlock>
                  </InteractionCard>
                );
              })}
            </div>
          )}
        </section>

        {/* ---- Gestação ---- */}
        <section className="medicamento-section">
          <h2 className="medicamento-section-title">
            <Baby size={18} aria-hidden="true" />
            {t("medicamento_detalhe.secao_gravidez")}
          </h2>
          {interactions.pregnancy.length === 0 ? (
            <p className="medicamento-empty">
              {t("medicamento_detalhe.sem_gravidez")}
            </p>
          ) : filteredPregnancy.length === 0 ? (
            <p className="medicamento-empty">
              {t("interacoes_page.filter_sem_resultados")}
            </p>
          ) : (
            <div className="medicamento-cards">
              {filteredPregnancy.map((item) => {
                const sev = pregnancySeverity(item.pregnancyCategory);
                const isCI = item.pregnancyCategory === "contraindicated";
                return (
                  <InteractionCard
                    key={item.id}
                    titleA={drug.name}
                    titleB={
                      isCI
                        ? t("interacoes_page.tipo_contraindicacao")
                        : t("interacoes_page.categoria_gravidez")
                    }
                    severity={sev}
                    description={item.risk}
                  >
                    <DetailBlock titleKey="interacoes_page.trimestre">
                      {item.trimester}
                    </DetailBlock>
                    <DetailBlock titleKey="interacoes_page.lactacao">
                      {item.lactation}
                    </DetailBlock>
                    <DetailBlock
                      titleKey="interacoes_page.contracepcao"
                      className="detail-recommendation"
                    >
                      {item.contraception}
                    </DetailBlock>
                    <DetailBlock
                      titleKey="interacoes_page.fonte"
                      className="detail-source"
                    >
                      {item.source}
                    </DetailBlock>
                  </InteractionCard>
                );
              })}
            </div>
          )}
        </section>

        <p className="medicamento-disclaimer">
          {t("medicamento_detalhe.disclaimer")}
        </p>
      </div>
    </div>
  );
}
