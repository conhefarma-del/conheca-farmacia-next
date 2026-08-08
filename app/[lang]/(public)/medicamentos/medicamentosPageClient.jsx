"use client";

import { useContext, useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import {
  ArrowRight,
  ChevronDown,
  ChevronUp,
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

// Chaves de grupo válidas para persistir no URL (formato "modo:grupo").
const GROUP_KEY_RE = /^(alpha|group|risk):.+$/;

export default function MedicamentosPageClient({ lang, drugs }) {
  const { t } = useContext(LangContext);
  const [query, setQuery] = useState("");
  const [mode, setMode] = useState("alpha");
  // Grupos colapsáveis por modo: chave "modo:grupo" -> aberto.
  // Por predefinição começam todos fechados (contagem visível no cabeçalho).
  const [openGroups, setOpenGroups] = useState(() => new Set());

  const toggleGroup = (key) => {
    setOpenGroups((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  };

  // Restaura o estado a partir do URL após a hidratação e em back/forward.
  useEffect(() => {
    const applyFromUrl = () => {
      const params = new URLSearchParams(window.location.search);
      const q = params.get("q") || "";
      const modo = params.get("modo");
      const raw = params.get("abertos") || "";
      const open = new Set(
        raw
          .split(",")
          .map((k) => k.trim())
          .filter((k) => GROUP_KEY_RE.test(k))
      );
      setQuery(q);
      if (MODES.some((m) => m.value === modo)) setMode(modo);
      setOpenGroups(open);
    };
    applyFromUrl();
    window.addEventListener("popstate", applyFromUrl);
    return () => window.removeEventListener("popstate", applyFromUrl);
  }, []);

  // Persiste o estado no URL (partilhável e recuperável entre navegações).
  // A primeira execução é ignorada: no mount quem aplica o URL é o restore.
  const firstWrite = useRef(true);
  useEffect(() => {
    if (firstWrite.current) {
      firstWrite.current = false;
      return;
    }
    const params = new URLSearchParams();
    if (query) params.set("q", query);
    if (mode !== "alpha") params.set("modo", mode);
    const open = [...openGroups].filter((k) => GROUP_KEY_RE.test(k));
    if (open.length) params.set("abertos", open.join(","));
    const qs = params.toString();
    const url = qs
      ? `${window.location.pathname}?${qs}`
      : window.location.pathname;
    history.replaceState(history.state, "", url);
  }, [query, mode, openGroups]);

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

  // Modo "alfabético": grupos pela letra inicial do nome (sem acentos).
  const groupedByAlpha = useMemo(() => {
    const map = {};
    sorted.forEach((d) => {
      const letter =
        (d.name || "")
          .normalize("NFD")
          .replace(/[\u0300-\u036f]/g, "")
          .charAt(0)
          .toUpperCase() || "—";
      if (!map[letter]) map[letter] = [];
      map[letter].push(d);
    });
    return Object.entries(map).sort(([a], [b]) => a.localeCompare(b));
  }, [sorted]);

  // Modo "grupo": classificação ATC nível 1 (letra A–V); dentro, alfabético.
  const groupedByAtc = useMemo(() => {
    const map = {};
    sorted.forEach((d) => {
      const letter = (d.atcCode || "").slice(0, 1);
      const key = letter || "—";
      if (!map[key]) map[key] = [];
      map[key].push(d);
    });
    return Object.entries(map).sort(([a], [b]) => a.localeCompare(b));
  }, [sorted]);

  const atcLabelKey = (letter) =>
    letter === "—"
      ? "medicamentos_page.atc_sem_grupo"
      : `medicamentos_page.atc_${letter}`;

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

  // Secção de grupo colapsável: cabeçalho clicável com seta e contagem.
  // Durante a pesquisa o fluxo de colapsar não se aplica — os grupos ficam
  // sempre abertos e o cabeçalho deixa de ser interativo (sem seta).
  const renderGroup = ({ key, label, list, className }) => {
    const searching = query.trim().length > 0;
    const isOpen = searching || openGroups.has(key);
    return (
      <section
        key={key}
        className={`drug-list-group${className ? ` ${className}` : ""}`}
      >
        <button
          type="button"
          className="drug-list-group-toggle"
          aria-expanded={isOpen}
          aria-controls={`grupo-${key}`}
          disabled={searching}
          onClick={() => toggleGroup(key)}
        >
          <span className="drug-list-group-label">{label}</span>
          <span className="drug-list-group-count">{list.length}</span>
          {!searching &&
            (isOpen ? (
              <ChevronUp size={18} aria-hidden="true" />
            ) : (
              <ChevronDown size={18} aria-hidden="true" />
            ))}
        </button>
        {isOpen && (
          <div id={`grupo-${key}`} className="drug-list-group-body">
            <div className="drug-list-grid">{list.map(renderCard)}</div>
          </div>
        )}
      </section>
    );
  };

  const renderCard = (d) => {
    const RiskIcon = RISK_ICONS[d.maxSeverity];
    return (
      <Link key={d.id} href={detailPath(d.slug)} className="drug-list-card">
        <div className="drug-list-card-main">
          <span className="drug-list-card-name">{d.name}</span>
          {d.className && (
            <span className="drug-list-card-class">{d.className}</span>
          )}
          {d.atcCode && <span className="drug-list-card-atc">{d.atcCode}</span>}
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
        ) : (
          <div className="drug-list-groups">
            {mode === "alpha"
              ? groupedByAlpha.map(([letter, list]) =>
                  renderGroup({ key: `alpha:${letter}`, label: letter, list })
                )
              : mode === "group"
                ? groupedByAtc.map(([letter, list]) =>
                    renderGroup({
                      key: `group:${letter}`,
                      label: t(atcLabelKey(letter)),
                      list,
                    })
                  )
                : groupedByRisk.map(([sev, list]) =>
                    renderGroup({
                      key: `risk:${sev}`,
                      label: t(riskLabelKey(sev)),
                      list,
                      className: `is-${sev}`,
                    })
                  )}
          </div>
        )}
      </div>
    </div>
  );
}
