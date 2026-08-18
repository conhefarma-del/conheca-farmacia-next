"use client";

import { useContext, useState } from "react";
import Link from "next/link";
import { ArrowUpRight, Atom, ShieldAlert } from "lucide-react";
import { LangContext } from "@/lib/contexts";

// Rótulos, cores e tooltips dos papéis (substrato/inibidor/indutor) — padrão
// do módulo de alvos moleculares. As chaves de tooltip reutilizam as mesmas
// dos cards de /alvos (alvos_page.papel_tip_*). Cada badge liga ao perfil do
// alvo em /alvos/[slug].
const ROLE_META = {
  substrate: {
    labelKey: "medicamento_detalhe.papel_substrato",
    tipKey: "alvos_page.papel_tip_substrate",
    className: "target-role target-role-substrate",
  },
  inhibitor: {
    labelKey: "medicamento_detalhe.papel_inibidor",
    tipKey: "alvos_page.papel_tip_inhibitor",
    className: "target-role target-role-inhibitor",
  },
  inducer: {
    labelKey: "medicamento_detalhe.papel_indutor",
    tipKey: "alvos_page.papel_tip_inducer",
    className: "target-role target-role-inducer",
  },
};

// Deteta auto-interação: o fármaco é substrato E inibidor/indutor do mesmo alvo.
function findAutoInteraction(roles) {
  const byTarget = {};
  roles.forEach((r) => {
    if (!byTarget[r.target?.id]) byTarget[r.target.id] = new Set();
    byTarget[r.target.id].add(r.role);
  });
  for (const [targetId, rolesSet] of Object.entries(byTarget)) {
    if (rolesSet.has("substrate") && (rolesSet.has("inhibitor") || rolesSet.has("inducer"))) {
      const row = roles.find((r) => r.target?.id === targetId);
      return {
        targetId,
        targetName: row?.target?.name || "",
        targetSlug: row?.target?.slug || "",
        acao: rolesSet.has("inhibitor") ? "inibidor" : "indutor",
      };
    }
  }
  return null;
}

// Secção "Metabolismo — alvos moleculares" da ficha do fármaco
// (/medicamento/[slug]) — lazy-loaded via next/dynamic (como a Farmacologia).
// Mostra o mapa estruturado fármaco ↔ alvo derivado dos textos dos alvos
// (drug_target_roles) com badge colorida por papel, link para /alvos/[slug]
// e aviso clínico quando há auto-interação no mesmo alvo.
export default function MetabolismSection({ roles = [], lang = "pt" }) {
  const { t } = useContext(LangContext);
  // Tooltip aberto por badge (chave = id da linha) — um de cada vez, padrão
  // dos TargetLinks: desktop hover abre; mobile 1.º toque abre, 2.º navega.
  const [openTip, setOpenTip] = useState(null);
  if (!roles || roles.length === 0) return null;

  const auto = findAutoInteraction(roles);
  const sorted = [...roles].sort((a, b) => {
    const order = { substrate: 0, inhibitor: 1, inducer: 2 };
    return (order[a.role] ?? 9) - (order[b.role] ?? 9);
  });

  return (
    <section className="medicamento-section">
      <h2 className="medicamento-section-title">
        <Atom size={18} aria-hidden="true" />
        {t("medicamento_detalhe.secao_metabolismo_alvos")}
      </h2>
      <p className="medicamento-section-subtitle">
        {t("medicamento_detalhe.metabolismo_alvos_subtitle")}
      </p>

      {auto && (
        <div className="target-auto-warning">
          <ShieldAlert size={16} aria-hidden="true" />
          <div>
            <strong>{t("medicamento_detalhe.aviso_auto_interacao")}:</strong>{" "}
            {t("medicamento_detalhe.aviso_auto_interacao_texto")
              .replace("{acao}", auto.acao)
              .replace("{alvo}", auto.targetName)}{" "}
            <Link href={`/${lang}/alvos/${auto.targetSlug}`} className="target-auto-link">
              {t("medicamento_detalhe.ver_alvo")}
              <ArrowUpRight size={13} aria-hidden="true" />
            </Link>
          </div>
        </div>
      )}

      <div className="target-roles-list">
        {sorted.map((r) => {
          const meta = ROLE_META[r.role] || ROLE_META.substrate;
          const href = `/${lang}/alvos/${r.target?.slug || "#"}`;
          const tipOpen = openTip === r.id;
          return (
            <Link key={r.id} href={href} className="target-role-row" title={r.target?.whatIs || r.target?.name}>
              <span
                className="target-role-wrap"
                onMouseEnter={() => setOpenTip(r.id)}
                onMouseLeave={() => setOpenTip((cur) => (cur === r.id ? null : cur))}
                onClick={(e) => {
                  if (tipOpen) return; // 2.º toque → deixa a linha navegar
                  e.preventDefault(); // 1.º toque → abre o tooltip
                  setOpenTip(r.id);
                }}
              >
                <span className={`${meta.className}`}>{t(meta.labelKey)}</span>
                <span
                  className={`target-role-tip${tipOpen ? " is-open" : ""}`}
                  role="tooltip"
                >
                  {t(meta.tipKey)}
                </span>
              </span>
              <span className="target-role-name">{r.target?.name || "—"}</span>
              <span className="target-role-type">{r.target?.targetType || ""}</span>
              <ArrowUpRight size={14} className="target-role-arrow" aria-hidden="true" />
            </Link>
          );
        })}
      </div>
    </section>
  );
}
