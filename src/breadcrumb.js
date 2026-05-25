import { t, applyTranslations } from "./i18n.js";

/**
 * renderBreadcrumb — renderiza navegação breadcrumb semântica.
 * @param {Array<{label: string, href?: string, i18nKey?: string}>} levels
 *   - levels com `href` → link clicável
 *   - último nível sem `href` → página atual (não clicável)
 *   - `i18nKey` (opcional) → chave de tradução para o label
 */
export function renderBreadcrumb(levels) {
  const nav = document.getElementById("breadcrumb");
  if (!nav || !levels || levels.length === 0) return;

  const ol = document.createElement("ol");
  ol.className = "breadcrumb-list";

  levels.forEach((level, i) => {
    const li = document.createElement("li");
    li.className = "breadcrumb-item";

    const isLast = i === levels.length - 1;
    const displayLabel = level.i18nKey ? t(level.i18nKey) : level.label;

    if (isLast) {
      const span = document.createElement("span");
      span.className = "breadcrumb-current";
      span.setAttribute("aria-current", "page");
      span.textContent = displayLabel;
      if (level.i18nKey) {
        span.setAttribute("data-i18n", level.i18nKey);
      }
      li.appendChild(span);
    } else {
      const a = document.createElement("a");
      a.className = "breadcrumb-link";
      a.href = level.href;
      a.textContent = displayLabel;
      if (level.i18nKey) {
        a.setAttribute("data-i18n", level.i18nKey);
      }
      li.appendChild(a);

      const sep = document.createElement("span");
      sep.className = "breadcrumb-separator";
      sep.setAttribute("aria-hidden", "true");
      sep.textContent = ">";
      li.appendChild(sep);
    }

    ol.appendChild(li);
  });

  nav.appendChild(ol);
}
