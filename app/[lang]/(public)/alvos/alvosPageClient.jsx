"use client";

import { useContext, useMemo, useState } from "react";
import Link from "next/link";
import { Search } from "lucide-react";
import { LangContext } from "@/lib/contexts";

// Tipos de alvo com rótulo i18n (chave base: alvos_page.tipo_*)
const TYPE_KEYS = ["cyp450", "cox", "transporter", "mao", "enzyme"];

// Badge de contagem com tooltip, padrão TargetLinks:
//  - desktop: hover abre o tooltip
//  - mobile: o 1.º toque abre o tooltip (preventDefault bloqueia a
//    navegação do card); o 2.º toque deixa o link do card navegar
function RoleTip({ label, tip, open, onOpen, onClose }) {
  return (
    <span
      className="alvo-role-wrap"
      onMouseEnter={onOpen}
      onMouseLeave={onClose}
      onClick={(e) => {
        if (open) return; // 2.º toque → deixa o card navegar
        e.preventDefault(); // 1.º toque → abre o tooltip, não navega
        onOpen();
      }}
    >
      {label}
      <span
        className={`alvo-role-tip${open ? " is-open" : ""}`}
        role="tooltip"
      >
        {tip}
      </span>
    </span>
  );
}

export default function AlvosPageClient({ lang, targets, drugCounts = {} }) {
  const { t } = useContext(LangContext);
  const [query, setQuery] = useState("");
  const [type, setType] = useState("todos");
  const [sort, setSort] = useState("nome");
  // Tooltip aberto por badge (chave `${slug}:${role}`) — um de cada vez.
  const [openTip, setOpenTip] = useState(null);

  const typeLabel = (key) => t(`alvos_page.tipo_${key}`);

  // Total de fármacos por alvo (soma dos três papéis) para a ordenação.
  const totalByTarget = useMemo(() => {
    const totals = {};
    for (const [targetId, c] of Object.entries(drugCounts || {})) {
      totals[targetId] =
        (c.substrate || 0) + (c.inhibitor || 0) + (c.inducer || 0);
    }
    return totals;
  }, [drugCounts]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    const TYPE_ORDER = [
      "cyp450",
      "cox",
      "transporter",
      "mao",
      "enzyme",
      "receptor",
      "other",
    ];
    const list = (targets || []).filter((target) => {
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
    const sorted = [...list];
    if (sort === "mais_ligados") {
      sorted.sort(
        (a, b) =>
          (totalByTarget[b.id] || 0) - (totalByTarget[a.id] || 0) ||
          a.name.localeCompare(b.name)
      );
    } else if (sort === "tipo") {
      sorted.sort(
        (a, b) =>
          TYPE_ORDER.indexOf(a.targetType) - TYPE_ORDER.indexOf(b.targetType) ||
          a.name.localeCompare(b.name)
      );
    } else {
      sorted.sort((a, b) => a.name.localeCompare(b.name));
    }
    return sorted;
  }, [targets, query, type, sort, totalByTarget]);

  const countByType = useMemo(() => {
    const counts = {};
    for (const target of targets || []) {
      counts[target.targetType] = (counts[target.targetType] || 0) + 1;
    }
    return counts;
  }, [targets]);

  return (
    <div className="alvos-page">
      {/* Hero — mesmo modelo de /cientificos: título + subtítulo + pesquisa e
          filtros dentro do mesmo hero (dimensão igual a /eventos) */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <h1 className="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              {t("alvos_page.hero_title")}
            </h1>
            <p className="hero-subtitle text-center">
              {t("alvos_page.hero_subtitle")}
            </p>

            {/* Pesquisa — centrada, como /cientificos */}
            <div className="max-w-3xl mx-auto mt-10 relative">
              <Search
                size={18}
                className="absolute left-4 top-1/2 -translate-y-1/2 text-brand-deep/40"
                aria-hidden="true"
              />
              <input
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder={t("alvos_page.search_placeholder")}
                aria-label={t("alvos_page.search_placeholder")}
                className="w-full pl-11 pr-4 py-3.5 rounded-2xl border border-brand-divider bg-brand-bg text-brand-deep shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all placeholder:text-brand-deep/40"
              />
            </div>

            {/* Filtros por tipo — centrados, como /cientificos */}
            <div className="alvos-filters flex flex-wrap items-center justify-center gap-3 mt-6">
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
          {/* Barra acima dos cards: ordenação (fora do hero, como /cientificos) */}
          <div className="flex flex-wrap items-center justify-between gap-3 mb-8">
            <span className="alvos-total">
              {filtered.length} {t("alvos_page.de_contagem")}
            </span>
            <div className="alvos-sort">
              <label htmlFor="alvos-sort" className="alvos-sort-label">
                {t("alvos_page.ordenar")}
              </label>
              <select
                id="alvos-sort"
                className="alvos-sort-select"
                value={sort}
                onChange={(e) => setSort(e.target.value)}
                aria-label={t("alvos_page.ordenar")}
              >
                <option value="nome">{t("alvos_page.ordenar_nome")}</option>
                <option value="mais_ligados">
                  {t("alvos_page.ordenar_mais_ligados")}
                </option>
                <option value="tipo">{t("alvos_page.ordenar_tipo")}</option>
              </select>
            </div>
          </div>

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
                const roleKey = (role) => `${target.slug}:${role}`;
                const roleProps = (role) => ({
                  open: openTip === roleKey(role),
                  onOpen: () => setOpenTip(roleKey(role)),
                  onClose: () =>
                    setOpenTip((cur) => (cur === roleKey(role) ? null : cur)),
                });
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
                                {...roleProps("substrate")}
                              />
                            </span>
                          )}
                          {counts.inhibitor > 0 && (
                            <span className="alvo-role-count alvo-role-inhibitor">
                              <RoleTip
                                label={`${counts.inhibitor} ${t("alvos_page.papel_plural_inhibitor")}`}
                                tip={t("alvos_page.papel_tip_inhibitor")}
                                {...roleProps("inhibitor")}
                              />
                            </span>
                          )}
                          {counts.inducer > 0 && (
                            <span className="alvo-role-count alvo-role-inducer">
                              <RoleTip
                                label={`${counts.inducer} ${t("alvos_page.papel_plural_inducer")}`}
                                tip={t("alvos_page.papel_tip_inducer")}
                                {...roleProps("inducer")}
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
