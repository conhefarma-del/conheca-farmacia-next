"use client";

import { useContext, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { LangContext } from "@/lib/contexts";

/**
 * TargetLinks — liga automaticamente as menções a alvos moleculares
 * (CYP3A4, CYP2D6, P-gp, COX-1, ...) dentro de um texto de explicação.
 *
 * - Desktop: hover abre um tooltip com "o que é" + link para /alvos/[slug]
 * - Mobile: o 1.º toque abre o tooltip; o 2.º toque navega para a página
 * - O matching usa o slug, o nome e os aliases de cada alvo (regex
 *   case-insensitive, fronteiras de palavra)
 */
export default function TargetLinks({ text, targets = [], lang }) {
  const { t } = useContext(LangContext);
  const [openTooltip, setOpenTooltip] = useState(null); // slug ativo
  const openTimer = useRef(null);

  const pattern = useMemo(() => {
    const names = (targets || []).flatMap((target) => [
      target.slug,
      target.name,
      target.fullName,
      ...(target.aliases || []),
    ]);
    if (names.length === 0) return null;
    const escaped = [...new Set(names)]
      .filter(Boolean)
      .map((n) => n.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
      // ordena do mais longo para o mais curto (P-gp antes de P)
      .sort((a, b) => b.length - a.length);
    return new RegExp(`(${escaped.join("|")})`, "gi");
  }, [targets]);

  const segments = useMemo(() => {
    if (!text) return [{ text: "", target: null }];
    if (!pattern) return [{ text, target: null }];
    const parts = [];
    let lastIndex = 0;
    let match;
    pattern.lastIndex = 0;
    while ((match = pattern.exec(text)) !== null) {
      if (match.index > lastIndex) {
        parts.push({ text: text.slice(lastIndex, match.index), target: null });
      }
      const mention = match[0];
      // encontra o alvo correspondente (pelo nome/alias, case-insensitive)
      const target = (targets || []).find((tgt) =>
        [tgt.slug, tgt.name, tgt.fullName, ...(tgt.aliases || [])].some(
          (n) => n && n.toLowerCase() === mention.toLowerCase()
        )
      );
      parts.push({ text: mention, target: target || null });
      lastIndex = match.index + mention.length;
    }
    if (lastIndex < text.length) {
      parts.push({ text: text.slice(lastIndex), target: null });
    }
    return parts;
  }, [text, pattern, targets]);

  const handleOpen = (slug, e) => {
    if (openTooltip === slug) {
      // 2.º toque no mobile → deixa o link nativo navegar
      return;
    }
    // 1.º toque (mobile) → abre o tooltip e impede a navegação
    e.preventDefault();
    clearTimeout(openTimer.current);
    setOpenTooltip(slug);
  };

  const handleClose = () => {
    clearTimeout(openTimer.current);
    openTimer.current = setTimeout(() => setOpenTooltip(null), 120);
  };

  return (
    <>
      {segments.map((seg, i) =>
        seg.target ? (
          <span
            key={i}
            className="target-link-wrap"
            onMouseEnter={() => setOpenTooltip(seg.target.slug)}
            onMouseLeave={handleClose}
          >
            <Link
              href={`/${lang || "pt"}/alvos/${seg.target.slug}`}
              className="target-link"
              onClick={(e) => handleOpen(seg.target.slug, e)}
            >
              {seg.text}
            </Link>
            {openTooltip === seg.target.slug && (
              <span className="target-tooltip" onMouseEnter={() => clearTimeout(openTimer.current)}>
                <strong>{seg.target.name}</strong>
                {seg.target.whatIs && <span className="target-tooltip-text">{seg.target.whatIs}</span>}
                <Link
                  href={`/${lang || "pt"}/alvos/${seg.target.slug}`}
                  className="target-tooltip-cta"
                  onClick={(e) => e.stopPropagation()}
                >
                  {t("alvos_page.ver_detalhe")} →
                </Link>
              </span>
            )}
          </span>
        ) : (
          <span key={i}>{seg.text}</span>
        )
      )}
    </>
  );
}
