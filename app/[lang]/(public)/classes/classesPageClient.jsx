"use client";

import { useContext, useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { ArrowRight, ChevronDown, ChevronUp, ListOrdered, Search, Pill, Tag, X } from "lucide-react";
import { LangContext } from "@/lib/contexts";

// Filter modes: flat (no grouping) is default — only groups when user selects
const MODES = [
  { value: "flat", icon: ListOrdered },
  { value: "atc", icon: Tag },
  { value: "size", icon: Pill },
];

export default function ClassesPageClient({ lang, classes }) {
  const { t } = useContext(LangContext);
  const [query, setQuery] = useState("");
  const [mode, setMode] = useState("flat");
  const [openGroups, setOpenGroups] = useState(() => new Set());

  const toggleGroup = (key) => {
    setOpenGroups((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  };

  // Restore from URL
  useEffect(() => {
    const applyFromUrl = () => {
      const params = new URLSearchParams(window.location.search);
      const q = params.get("q") || "";
      const modo = params.get("modo");
      const raw = params.get("abertos") || "";
      const open = new Set(
        raw.split(",").map((k) => k.trim()).filter((k) => /^(flat|atc|size):.+$/.test(k))
      );
      setQuery(q);
      if (MODES.some((m) => m.value === modo)) setMode(modo);
      setOpenGroups(open);
    };
    applyFromUrl();
    window.addEventListener("popstate", applyFromUrl);
    return () => window.removeEventListener("popstate", applyFromUrl);
  }, []);

  // Persist to URL
  const firstWrite = useRef(true);
  useEffect(() => {
    if (firstWrite.current) { firstWrite.current = false; return; }
    const params = new URLSearchParams();
    if (query) params.set("q", query);
    if (mode !== "flat") params.set("modo", mode);
    const open = [...openGroups].filter((k) => /^(flat|atc|size):.+$/.test(k));
    if (open.length) params.set("abertos", open.join(","));
    const qs = params.toString();
    const url = qs ? `${window.location.pathname}?${qs}` : window.location.pathname;
    history.replaceState(history.state, "", url);
  }, [query, mode, openGroups]);

  const detailPath = (slug) => `/${lang}/classes/${slug}`;

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return classes;
    return classes.filter(
      (c) =>
        c.name.toLowerCase().includes(q) ||
        (c.description || "").toLowerCase().includes(q)
    );
  }, [query, classes]);

  const sorted = useMemo(() => [...filtered].sort((a, b) => a.name.localeCompare(b.name)), [filtered]);

  // Mode "flat": no grouping — plain list
  // Mode "atc": group by ATC prefix letter (A, B, C, etc.)
  const groupedByAtc = useMemo(() => {
    const map = {};
    sorted.forEach((c) => {
      const letter = (c.atcPrefix || "").slice(0, 1) || "—";
      if (!map[letter]) map[letter] = [];
      map[letter].push(c);
    });
    return Object.entries(map)
      .filter(([, list]) => list.length > 0)
      .sort(([a], [b]) => a.localeCompare(b));
  }, [sorted]);

  // Mode "size": group by drug count (Muitos ≥10, Médios 4-9, Poucos 1-3)
  const groupedBySize = useMemo(() => {
    const buckets = { many: [], medium: [], few: [] };
    sorted.forEach((c) => {
      if (c.drugCount >= 10) buckets.many.push(c);
      else if (c.drugCount >= 4) buckets.medium.push(c);
      else buckets.few.push(c);
    });
    return [
      ["many", buckets.many],
      ["medium", buckets.medium],
      ["few", buckets.few],
    ].filter(([, list]) => list.length > 0);
  }, [sorted]);

  const sizeLabelKey = (key) => `classes_page.size_${key}`;

  const atcLabel = (letter) =>
    letter === "—" ? t("classes_page.atc_sem_grupo") : `ATC ${letter}`;

  const renderGroup = ({ key, label, list, className }) => {
    const searching = query.trim().length > 0;
    const isOpen = searching || openGroups.has(key);
    return (
      <section key={key} className={`drug-list-group${className ? ` ${className}` : ""}`}>
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
          {!searching && (isOpen ? <ChevronUp size={18} /> : <ChevronDown size={18} />)}
        </button>
        {isOpen && (
          <div id={`grupo-${key}`} className="drug-list-group-body">
            <div className="drug-list-grid">{list.map(renderCard)}</div>
          </div>
        )}
      </section>
    );
  };

  const renderCard = (c) => (
    <Link key={c.slug} href={detailPath(c.slug)} className="drug-list-card">
      <div className="drug-list-card-main">
        <span className="drug-list-card-name">{c.name}</span>
        {c.atcPrefix && <span className="drug-list-card-atc">{c.atcPrefix}</span>}
        {c.description && (
          <span className="drug-list-card-class">
            {c.description.length > 100 ? c.description.slice(0, 100) + "..." : c.description}
          </span>
        )}
      </div>
      <div className="drug-list-card-meta">
        <span className="drug-list-card-class">
          <Pill size={13} aria-hidden="true" />
          {t("classes_page.drug_count", { count: c.drugCount })}
        </span>
        <span className="drug-list-card-cta">
          {t("classes_page.ver_detalhes")}
          <ArrowRight size={13} aria-hidden="true" />
        </span>
      </div>
    </Link>
  );

  return (
    <div className="medicamentos-page">
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6 break-words">
              {t("classes_page.hero_title")}
            </h1>
            <p className="hero-subtitle text-center">{t("classes_page.hero_subtitle")}</p>
          </div>
        </div>
      </section>

      <div className="container-center">
        {/* Toolbar: search + filter modes */}
        <div className="medicamentos-toolbar">
          <div className="drug-input-group medicamentos-search">
            <div className="drug-input-wrap">
              <Search size={16} className="drug-input-icon" aria-hidden="true" />
              <input
                type="text"
                className="drug-input"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder={t("classes_page.search_placeholder")}
              />
            </div>
          </div>

          <div className="medicamentos-modes" role="group" aria-label={t("classes_page.organizar")}>
            <span className="medicamentos-modes-label">{t("classes_page.organizar")}</span>
            {MODES.map((m) => (
              <button
                key={m.value}
                className={`severity-filter-chip${mode === m.value ? " is-active" : ""}`}
                aria-pressed={mode === m.value}
                onClick={() => setMode(m.value)}
              >
                <m.icon size={13} aria-hidden="true" />
                {t(`classes_page.modo_${m.value}`)}
              </button>
            ))}
          </div>
        </div>

        <div className="medicamentos-count">
          {t("classes_page.resultados", { count: filtered.length })}
        </div>

        {filtered.length === 0 ? (
          <div className="results-empty">
            <div className="search-empty-icon"><Search size={28} aria-hidden="true" /></div>
            <p>{t("classes_page.sem_resultados")}</p>
            {query.trim() && (
              <button type="button" className="medicamentos-clear-search" onClick={() => setQuery("")}>
                <X size={14} aria-hidden="true" />
                {t("medicamentos_page.limpar_pesquisa")}
              </button>
            )}
          </div>
        ) : (
          <div className="drug-list-groups">
            {mode === "flat" && (
              <section className="drug-list-group">
                <div className="drug-list-group-body">
                  <div className="drug-list-grid">{sorted.map(renderCard)}</div>
                </div>
              </section>
            )}
            {mode === "atc" &&
              groupedByAtc.map(([letter, list]) =>
                renderGroup({ key: `atc:${letter}`, label: atcLabel(letter), list })
              )}
            {mode === "size" &&
              groupedBySize.map(([key, list]) =>
                renderGroup({ key: `size:${key}`, label: t(sizeLabelKey(key)), list })
              )}
          </div>
        )}
      </div>
    </div>
  );
}
