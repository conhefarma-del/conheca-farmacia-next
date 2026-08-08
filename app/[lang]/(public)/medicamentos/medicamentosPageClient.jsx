"use client";

import { useContext, useMemo, useState } from "react";
import Link from "next/link";
import {
  ArrowRight,
  ListOrdered,
  Search,
  ShieldAlert,
  Tag,
  TriangleAlert,
} from "lucide-react";
import { LangContext } from "@/lib/contexts";

// Mesma ordem do checker: documentadas primeiro, depois sem registo.
const SEVERITY_ORDER = {
  critical: 0,
  moderate: 1,
  minor: 2,
  none: 3,
  unknown: 4,
};

const RISK_ICONS = {
  critical: ShieldAlert,
  moderate: TriangleAlert,
  minor: null,
  none: null,
  unknown: null,
};

const MODES = [
  { value: "alpha", icon: ListOrdered },
  { value: "group", icon: Tag },
  { value: "risk", icon: ShieldAlert },
];

export default function MedicamentosPageClient({ lang, drugs }) {
  const { t } = useContext(LangContext);
  const [query, setQuery] = useState("");
  const [mode, setMode] = useState("alpha");

  const detailPath = (slug) =>
    `/${lang}/${lang === "pt" ? "medicamento" : "medicine"}/${slug}`;

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return drugs;
    return drugs.filter(
      (d) =>
        d.name.toLowerCase().includes(q) ||
        d.className.toLowerCase().includes(q) ||
        (d.aliases || []).some((a) => a.toLowerCase().includes(q))
    );
  }, [query, drugs]);

  const sorted = useMemo(() => {
    return [...filtered].sort((a, b) => a.name.localeCompare(b.name));
  }, [filtered]);

  // Modo "grupo": cabeçalhos por classe farmacológica; dentro, alfabético.
  const groupedByClass = useMemo(() => {
    const map = {};
    sorted.forEach((d) => {
      const key = d.className || "—";
      if (!map[key]) map[key] = [];
      map[key].push(d);
    });
    return Object.entries(map).sort(([a], [b]) => a.localeCompare(b));
  }, [sorted]);

  // Modo "risco": baldes por severidade máxima; dentro, alfabético.
  const groupedByRisk = useMemo(() => {
    const buckets = {
      critical: [],
      moderate: [],
      minor: [],
      none: [],
      unknown: [],
    };
    sorted.forEach((d) => {
      const key = d.maxSeverity || "unknown";
      buckets[key].push(d);
    });
    return Object.entries(buckets)
      .sort(([a], [b]) => SEVERITY_ORDER[a] - SEVERITY_ORDER[b])
      .filter(([, list]) => list.length > 0);
  }, [sorted]);

  const riskLabelKey = (sev) =>
    sev === "unknown"
      ? "medicamentos_page.risco_unknown"
      : `medicamentos_page.risco_${sev}`;

  const severityLabelKey = (sev) => `interacoes_page.severidade_${sev}`;

  const renderCard = (d) => {
    const RiskIcon = RISK_ICONS[d.maxSeverity];
    return (
      <Link key={d.id} href={detailPath(d.slug)} className="drug-list-card">
        <div className="drug-list-card-main">
          <span className="drug-list-card-name">{d.name}</span>
          {d.className && (
            <span className="drug-list-card-class">{d.className}</span>
          )}
        </div>
        <div className="drug-list-card-meta">
          {d.maxSeverity && (
            <span className={`severity-badge is-${d.maxSeverity}`}>
              {RiskIcon && <RiskIcon size={12} aria-hidden="true" />}
              {t(severityLabelKey(d.maxSeverity))}
            </span>
          )}
          <span className="drug-list-card-cta">
            {t("medicamentos_page.ver_ficha")}
            <ArrowRight size={13} aria-hidden="true" />
          </span>
        </div>
      </Link>
    );
  };

  return (
    <div className="medicamentos-page">
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6 break-words">
              {t("medicamentos_page.hero_title")}
            </h1>
            <p className="hero-subtitle text-center">
              {t("medicamentos_page.hero_subtitle")}
            </p>
          </div>
        </div>
      </section>

      <div className="container-center">
        <div className="medicamentos-toolbar">
          {/* Pesquisa */}
          <div className="drug-input-group medicamentos-search">
            <div className="drug-input-wrap">
              <Search
                size={16}
                className="drug-input-icon"
                aria-hidden="true"
              />
              <input
                type="text"
                className="drug-input"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder={t("medicamentos_page.search_placeholder")}
              />
            </div>
          </div>

          {/* Modos de organização */}
          <div
            className="medicamentos-modes"
            role="group"
            aria-label={t("medicamentos_page.organizar")}
          >
            <span className="medicamentos-modes-label">
              {t("medicamentos_page.organizar")}
            </span>
            {MODES.map((m) => (
              <button
                key={m.value}
                className={`severity-filter-chip${mode === m.value ? " is-active" : ""}`}
                aria-pressed={mode === m.value}
                onClick={() => setMode(m.value)}
              >
                <m.icon size={13} aria-hidden="true" />
                {t(`medicamentos_page.modo_${m.value}`)}
              </button>
            ))}
          </div>
        </div>

        <div className="medicamentos-count">
          {t("medicamentos_page.resultados", { count: filtered.length })}
        </div>

        {filtered.length === 0 ? (
          <div className="results-empty">
            <div className="search-empty-icon">
              <Search size={28} aria-hidden="true" />
            </div>
            <p>{t("medicamentos_page.sem_resultados")}</p>
          </div>
        ) : mode === "alpha" ? (
          <div className="drug-list-grid">{sorted.map(renderCard)}</div>
        ) : mode === "group" ? (
          <div className="drug-list-groups">
            {groupedByClass.map(([className, list]) => (
              <section key={className} className="drug-list-group">
                <h2 className="drug-list-group-title">{className}</h2>
                <div className="drug-list-grid">{list.map(renderCard)}</div>
              </section>
            ))}
          </div>
        ) : (
          <div className="drug-list-groups">
            {groupedByRisk.map(([sev, list]) => (
              <section key={sev} className={`drug-list-group is-${sev}`}>
                <h2 className="drug-list-group-title">
                  {t(riskLabelKey(sev))}
                </h2>
                <div className="drug-list-grid">{list.map(renderCard)}</div>
              </section>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
