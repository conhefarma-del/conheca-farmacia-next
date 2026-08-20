"use client";

import { useContext } from "react";
import Link from "next/link";
import SaveButton from "@/components/ui/SaveButton";
import { ArrowLeft, ArrowRight, ExternalLink, Pill } from "lucide-react";
import { LangContext } from "@/lib/contexts";

export default function ClassDetailClient({ lang, cls }) {
  const { t } = useContext(LangContext);
  const basePath = `/${lang}/classes`;
  const medsBase = `/${lang}/${lang === "pt" ? "medicamento" : "medicine"}`;

  return (
    <div className="medicamentos-page">
      {/* Hero */}
      <section className="events-hero">
        <div className="container-center">
          <div className="text-center py-12 md:py-16">
            <p className="text-center mb-4">
              <Link href={basePath} className="medicamento-back-link">
                <ArrowLeft size={14} aria-hidden="true" />
                {t("classes_page.voltar")}
              </Link>
            </p>
            <div className="flex items-center justify-center gap-3 mb-4">
              <h1 className="text-5xl md:text-7xl font-bold text-brand-deep break-words">
                {cls.name}
              </h1>
              <SaveButton
                itemType="drug_class"
                itemId={cls.id}
                itemSlug={cls.slug}
                itemName={cls.name}
                itemSubtitle={cls.atcPrefix ? `ATC: ${cls.atcPrefix}` : null}
                lang={lang}
                size="lg"
                className="save-button-hero"
              />
            </div>
            {cls.atcPrefix && (
              <p className="text-center text-sm text-gray-500 dark:text-gray-400 mb-2 font-mono">
                ATC: {cls.atcPrefix}
              </p>
            )}
            <p className="hero-subtitle text-center">
              {t("classes_page.drug_count", { count: cls.drugs.length })}
            </p>
          </div>
        </div>
      </section>

      <div className="container-center">
        {/* Descrição: O que são */}
        {cls.description && (
          <section className="medicamento-section">
            <h2 className="medicamento-section-title">
              <Pill size={18} aria-hidden="true" />
              {t("classes_page.o_que_sao")}
            </h2>
            <p className="medicamento-text">{cls.description}</p>
          </section>
        )}

        {/* Lista de fármacos */}
        {cls.drugs.length > 0 && (
          <section className="medicamento-section">
            <h2 className="medicamento-section-title">
              {t("classes_page.farmacos_da_classe")}
            </h2>
            <div className="drug-list-groups">
              <section className="drug-list-group">
                <div className="drug-list-group-body">
                  <div className="drug-list-grid">
                    {cls.drugs.map((drug) => (
                      <Link
                        key={drug.slug}
                        href={`${medsBase}/${drug.slug}`}
                        className="drug-list-card"
                      >
                        <div className="drug-list-card-main">
                          <span className="drug-list-card-name">{drug.name}</span>
                          {drug.atcCode && (
                            <span className="drug-list-card-atc">{drug.atcCode}</span>
                          )}
                        </div>
                        <div className="drug-list-card-meta">
                          <span className="drug-list-card-cta">
                            {t("medicamentos_page.ver_ficha")}
                            <ArrowRight size={13} aria-hidden="true" />
                          </span>
                        </div>
                      </Link>
                    ))}
                  </div>
                </div>
              </section>
            </div>
          </section>
        )}

        {cls.drugs.length === 0 && (
          <div className="results-empty">
            <p>{t("classes_page.sem_farmacos")}</p>
          </div>
        )}
      </div>
    </div>
  );
}
