/**
 * renderBreadcrumb — renderiza navegação breadcrumb semântica.
 * @param {Array<{label: string, href?: string}>} levels
 *   - levels com `href` → link clicável
 *   - último nível sem `href` → página atual (não clicável)
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

    if (isLast) {
      // Página atual — não clicável
      const span = document.createElement("span");
      span.className = "breadcrumb-current";
      span.setAttribute("aria-current", "page");
      span.textContent = level.label;
      li.appendChild(span);
    } else {
      const a = document.createElement("a");
      a.className = "breadcrumb-link";
      a.href = level.href;
      a.textContent = level.label;
      li.appendChild(a);

      // Separador ">"
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
