"use client";

import { useContext, useMemo, useState } from "react";
import Link from "next/link";
import { ArrowRight, Search, Pill, X } from "lucide-react";
import { LangContext } from "@/lib/contexts";

export default function ClassesPageClient({ lang, classes }) {
  const { t } = useContext(LangContext);
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return classes;
    return classes.filter(
      (c) =>
        c.name.toLowerCase().includes(q) ||
        (c.description || "").toLowerCase().includes(q)
    );
  }, [query, classes]);

  const detailPath = (slug) => `/${lang}/classes/${slug}`;

  return (
    <div className="medicamentos-page">
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6 break-words">
              {t("classes_page.hero_title")}
            </h1>
            <p className="hero-subtitle text-center">
              {t("classes_page.hero_subtitle")}
            </p>
          </div>
        </div>
      </section>

      <div className="container-center">
        {/* Pesquisa */}
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
        </div>

        <div className="medicamentos-count">
          {t("classes_page.resultados", { count: filtered.length })}
        </div>

        {filtered.length === 0 ? (
          <div className="results-empty">
            <div className="search-empty-icon">
              <Search size={28} aria-hidden="true" />
            </div>
            <p>{t("classes_page.sem_resultados")}</p>
            {query.trim() && (
              <button
                type="button"
                className="medicamentos-clear-search"
                onClick={() => setQuery("")}
              >
                <X size={14} aria-hidden="true" />
                {t("medicamentos_page.limpar_pesquisa")}
              </button>
            )}
          </div>
        ) : (
          <div className="drug-list-groups">
            <section className="drug-list-group">
              <div id="grupo-classes" className="drug-list-group-body">
                <div className="drug-list-grid">
                  {filtered.map((c) => (
                    <Link
                      key={c.slug}
                      href={detailPath(c.slug)}
                      className="drug-list-card"
                    >
                      <div className="drug-list-card-main">
                        <span className="drug-list-card-name">{c.name}</span>
                        {c.atcPrefix && (
                          <span className="drug-list-card-atc">{c.atcPrefix}</span>
                        )}
                        {c.description && (
                          <span className="drug-list-card-class">
                            {c.description.length > 100
                              ? c.description.slice(0, 100) + "..."
                              : c.description}
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
                  ))}
                </div>
              </div>
            </section>
          </div>
        )}
      </div>
    </div>
  );
}
