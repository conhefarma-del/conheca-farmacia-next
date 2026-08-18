"use client";

import { useContext, useMemo, useState } from "react";
import Link from "next/link";
import { Search } from "lucide-react";
import { LangContext } from "@/lib/contexts";

// Tipos de alvo com rótulo i18n (chave base: alvos_page.tipo_*)
const TYPE_KEYS = ["cyp450", "cox", "transporter", "mao", "enzyme"];

// Tooltip simples (CSS puro, hover) para explicar o papel da contagem.
function RoleTip({ label, tip }) {
  return (
    <span className="alvo-role-wrap">
      {label}
      <span className="alvo-role-tip" role="tooltip">
        {tip}
      </span>
    </span>
  );
}

export default function AlvosPageClient({ lang, targets, drugCounts = {} }) {
  const { t } = useContext(LangContext);
  const [query, setQuery] = useState("");
  const [type, setType] = useState("todos");

  const typeLabel = (key) => t(`alvos_page.tipo_${key}`);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return (targets || []).filter((target) => {
      if (type !== "todos" && target.targetType !== type) return false;
      if (!q) return true;
      const haystack = [
        target.name,
        target.fullName,
        target.whatIs,
        target.role,
        ...(target.aliases || []),
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase();
      return haystack.includes(q);
    });
  }, [targets, query, type]);

  const countByType = useMemo(() => {
    const counts = {};
    for (const target of targets || []) {
      counts[target.targetType] = (counts[target.targetType] || 0) + 1;
    }
    return counts;
  }, [targets]);

  return (
    <div className="alvos-page">
      {/* Hero — padrão events-hero (mesma dimensão das restantes páginas) */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6 break-words">
              {t("alvos_page.hero_title")}
            </h1>
            <p className="hero-subtitle text-center">
              {t("alvos_page.hero_subtitle")}
            </p>
          </div>
        </div>
      </section>

      {/* Pesquisa + filtros por tipo — dentro do hero, como /artigos */}
      <section className="events-hero">
        <div className="container-center pb-10">
          <div className="alvos-toolbar">
            <div className="alvos-search">
              <Search size={16} aria-hidden="true" />
              <input
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder={t("alvos_page.search_placeholder")}
                aria-label={t("alvos_page.search_placeholder")}
              />
            </div>
            <div className="alvos-filters">
              <button
                type="button"
                className={`alvos-filter ${type === "todos" ? "active" : ""}`}
                onClick={() => setType("todos")}
              >
                {t("alvos_page.filter_todos")}
                <span className="alvos-filter-count">
                  {targets ? targets.length : 0}
                </span>
              </button>
              {TYPE_KEYS.map((key) => (
                <button
                  key={key}
                  type="button"
                  className={`alvos-filter ${type === key ? "active" : ""}`}
                  onClick={() => setType(key)}
                >
                  {typeLabel(key)}
                  <span className="alvos-filter-count">
                    {countByType[key] || 0}
                  </span>
                </button>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Lista de alvos */}
      <section className="alvos-section section-padding">
        <div className="container-center">
          {filtered.length === 0 ? (
            <p className="alvos-empty">
              {t("alvos_page.sem_resultados")}
            </p>
          ) : (
            <div className="alvos-grid">
              {filtered.map((target) => {
                const counts = drugCounts[target.id] || {
                  substrate: 0,
                  inhibitor: 0,
                  inducer: 0,
                };
                const hasRoles = counts.substrate + counts.inhibitor + counts.inducer > 0;
                return (
                  <Link
                    key={target.slug}
                    href={`/${lang}/alvos/${target.slug}`}
                    className="alvo-card"
                  >
                    <div className="alvo-card-head">
                      <span className={`alvo-badge alvo-badge-${target.targetType}`}>
                        {typeLabel(target.targetType)}
                      </span>
                      {target.fullName && (
                        <span className="alvo-card-fullname">{target.fullName}</span>
                      )}
                    </div>
                    <h2 className="alvo-card-name">{target.name}</h2>
                    <p className="alvo-card-role">{target.role}</p>
                    <div className="alvo-card-roles">
                      {hasRoles ? (
                        <>
                          {counts.substrate > 0 && (
                            <span className="alvo-role-count alvo-role-substrate">
                              <RoleTip
                                label={`${counts.substrate} ${t("alvos_page.papel_plural_substrate")}`}
                                tip={t("alvos_page.papel_tip_substrate")}
                              />
                            </span>
                          )}
                          {counts.inhibitor > 0 && (
                            <span className="alvo-role-count alvo-role-inhibitor">
                              <RoleTip
                                label={`${counts.inhibitor} ${t("alvos_page.papel_plural_inhibitor")}`}
                                tip={t("alvos_page.papel_tip_inhibitor")}
                              />
                            </span>
                          )}
                          {counts.inducer > 0 && (
                            <span className="alvo-role-count alvo-role-inducer">
                              <RoleTip
                                label={`${counts.inducer} ${t("alvos_page.papel_plural_inducer")}`}
                                tip={t("alvos_page.papel_tip_inducer")}
                              />
                            </span>
                          )}
                        </>
                      ) : (
                        <span className="alvo-role-count alvo-role-empty">
                          {t("alvos_page.sem_papeis")}
                        </span>
                      )}
                    </div>
                    <span className="alvo-card-cta">
                      {t("alvos_page.ver_detalhe")} →
                    </span>
                  </Link>
                );
              })}
            </div>
          )}
        </div>
      </section>
    </div>
  );
}
