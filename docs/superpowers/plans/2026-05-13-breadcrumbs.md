# Breadcrumbs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar navegação contextual (breadcrumbs) nas 4 páginas de detalhe do site, mostrando o caminho hierárquico e permitindo voltar a qualquer nível anterior com um clique.

**Architecture:** Módulo JS reutilizável `src/breadcrumb.js` exporta `renderBreadcrumb(levels)` que injeta HTML semântico (`<nav><ol><li>`) num container `<nav id="breadcrumb">` colocado entre `</header>` e `<main>` em cada HTML. Cada página de detalhe importa e chama a função após carregar os dados. Inscrição importa `events-catalog.json` para obter o título do evento (única página que não tinha o título disponível).

**Tech Stack:** Vanilla JS (ES modules), Tailwind CSS v4 (`@layer components`), Vite (import estático de JSON), variáveis CSS existentes (`--brand-accent`, `--brand-deep`).

---

## File Structure

| Arquivo                          | Responsabilidade                                                                   | Ação      |
| -------------------------------- | ---------------------------------------------------------------------------------- | --------- |
| `src/breadcrumb.js`              | Módulo reutilizável — `renderBreadcrumb(levels)` gera HTML semântico do breadcrumb | Criar     |
| `src/input.css:185-191`          | Estilos `.breadcrumb-*` dentro de `@layer components` (linha 191, antes do `}`)    | Modificar |
| `artigo.html:145`                | Container `<nav id="breadcrumb">` entre `</aside>` (l.144) e `<main>` (l.146)      | Modificar |
| `evento.html:141`                | Container `<nav id="breadcrumb">` entre `</aside>` (l.140) e `<main>` (l.142)      | Modificar |
| `lives.html:141`                 | Container `<nav id="breadcrumb">` entre `</aside>` (l.140) e `<main>` (l.142)      | Modificar |
| `inscricao.html:160`             | Container `<nav id="breadcrumb">` entre `</aside>` (l.159) e `<main>` (l.161)      | Modificar |
| `src/article-detail.js:1,~130`   | Importar e chamar `renderBreadcrumb()` após carregar artigo                        | Modificar |
| `src/event-detail.js:3,~90`      | Importar e chamar `renderBreadcrumb()` após carregar evento                        | Modificar |
| `src/live-detail.js:1,~40`       | Importar e chamar `renderBreadcrumb()` após carregar live                          | Modificar |
| `src/inscription-logic.js:1,~70` | Importar `events-catalog.json` + `renderBreadcrumb()`, buscar título do evento     | Modificar |

---

### Task 1: Criar módulo `src/breadcrumb.js`

**Files:**

- Create: `src/breadcrumb.js`

- [ ] **Step 1: Criar o ficheiro `src/breadcrumb.js`**

```javascript
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
```

- [ ] **Step 2: Verificar que o ficheiro não tem erros de sintaxe**

Run: `node -c "C:/Users/bapti/Documents/Criação de WebSites/Conheça Farmácia/src/breadcrumb.js"`

Expected: `Syntax OK` ou sem output de erro.

- [ ] **Step 3: Commit**

```bash
git add src/breadcrumb.js
git commit -m "feat: add reusable renderBreadcrumb() module"
```

---

### Task 2: Adicionar estilos CSS do breadcrumb

**Files:**

- Modify: `src/input.css:191` (inserir antes do `}` que fecha `@layer components`)

- [ ] **Step 1: Adicionar estilos do breadcrumb dentro de `@layer components`**

Inserir antes da linha 191 (o `}` que fecha `@layer components`), logo após o bloco `.nav-links a:hover`:

```css
/* ============================================
   BREADCRUMB
   ============================================ */
.breadcrumb-list {
  @apply container-center flex items-center flex-wrap gap-0 py-3 text-sm font-medium list-none m-0 p-0;
}

.breadcrumb-item {
  @apply flex items-center;
}

.breadcrumb-link {
  color: var(--brand-accent);
  @apply hover:underline transition-colors duration-200;
}

html.dark .breadcrumb-link {
  color: var(--brand-accent);
}

.breadcrumb-separator {
  color: var(--brand-deep);
  opacity: 0.4;
  @apply mx-2 select-none;
}

.breadcrumb-current {
  color: var(--brand-deep);
  opacity: 0.7;
}

/* Mobile: truncar "Início" com "..." */
@media (max-width: 767px) {
  .breadcrumb-item:first-child .breadcrumb-link {
    font-size: 0;
    overflow: hidden;
    width: 1.2em;
    display: inline-block;
    text-indent: 0;
    text-align: center;
  }

  .breadcrumb-item:first-child .breadcrumb-link::before {
    content: "…";
    font-size: 14px;
    display: inline;
  }
}
```

**Notas sobre dark mode:** O projeto usa variáveis CSS (`--brand-accent`, `--brand-deep`) que flipam automaticamente com `html.dark` — já definidas no `:root` e `html.dark`. Por isso NÃO usamos prefixo `dark:` do Tailwind, seguindo o padrão do projeto.

- [ ] **Step 2: Verificar build sem erros**

Run: `cd "C:/Users/bapti/Documents/Criação de WebSites/Conheça Farmácia" && npm run build 2>&1 | tail -5`

Expected: Build completo sem erros de CSS.

- [ ] **Step 3: Commit**

```bash
git add src/input.css
git commit -m "feat: add breadcrumb CSS styles in @layer components"
```

---

### Task 3: Adicionar container `#breadcrumb` nos 4 HTMLs

**Files:**

- Modify: `artigo.html:145`
- Modify: `evento.html:141`
- Modify: `lives.html:141`
- Modify: `inscricao.html:160`

- [ ] **Step 1: Adicionar container em `artigo.html`**

Na linha 145 (linha vazia entre `</aside>` l.144 e `<main>` l.146), inserir:

```html
<nav id="breadcrumb" aria-label="Breadcrumb"></nav>
```

- [ ] **Step 2: Adicionar container em `evento.html`**

Na linha 141 (linha vazia entre `</aside>` l.140 e `<main>` l.142), inserir:

```html
<nav id="breadcrumb" aria-label="Breadcrumb"></nav>
```

- [ ] **Step 3: Adicionar container em `lives.html`**

Na linha 141 (linha vazia entre `</aside>` l.140 e `<main>` l.142), inserir:

```html
<nav id="breadcrumb" aria-label="Breadcrumb"></nav>
```

- [ ] **Step 4: Adicionar container em `inscricao.html`**

Na linha 160 (linha vazia entre `</aside>` l.159 e `<main>` l.161), inserir:

```html
<nav id="breadcrumb" aria-label="Breadcrumb"></nav>
```

- [ ] **Step 5: Verificar build sem erros**

Run: `cd "C:/Users/bapti/Documents/Criação de WebSites/Conheça Farmácia" && npm run build 2>&1 | tail -5`

Expected: Build completo sem erros.

- [ ] **Step 6: Commit**

```bash
git add artigo.html evento.html lives.html inscricao.html
git commit -m "feat: add breadcrumb nav containers to detail pages"
```

---

### Task 4: Integrar breadcrumb em `article-detail.js`

**Files:**

- Modify: `src/article-detail.js`

O ficheiro já importa `articlesData from "./content/articles-catalog.json"` na linha 1. O artigo carregado fica na variável `article` com propriedade `.title`.

- [ ] **Step 1: Adicionar import do breadcrumb**

Na linha 1, adicionar import:

```javascript
import { renderBreadcrumb } from "./breadcrumb.js";
```

- [ ] **Step 2: Chamar `renderBreadcrumb()` após carregar o artigo**

Após a linha onde o artigo é renderizado com sucesso (a função `renderArticle(article)` dentro do `DOMContentLoaded`), adicionar:

```javascript
renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Artigos", href: "/artigos.html" },
  { label: article.title },
]);
```

- [ ] **Step 3: Verificar no browser**

Run: `cd "C:/Users/bapti/Documents/Criação de WebSites/Conheça Farmácia" && npm run dev`

Abrir `http://localhost:5173/artigo.html?slug=<algum-slug>`. Verificar que o breadcrumb aparece entre o header e o main: "Início > Artigos > [Título do Artigo]". Confirmar que "Início" e "Artigos" são clicáveis e que o título do artigo não é link.

- [ ] **Step 4: Commit**

```bash
git add src/article-detail.js
git commit -m "feat: add breadcrumb to article detail page"
```

---

### Task 5: Integrar breadcrumb em `event-detail.js`

**Files:**

- Modify: `src/event-detail.js`

O ficheiro já importa `eventsData from './content/events-catalog.json'` na linha 3. O evento carregado fica na variável `event` com propriedade `.title`.

- [ ] **Step 1: Adicionar import do breadcrumb**

Após os imports existentes, adicionar:

```javascript
import { renderBreadcrumb } from "./breadcrumb.js";
```

- [ ] **Step 2: Chamar `renderBreadcrumb()` após carregar o evento**

Após o evento ser carregado e renderizado com sucesso (dentro do `DOMContentLoaded`), adicionar:

```javascript
renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Eventos", href: "/eventos.html" },
  { label: event.title },
]);
```

- [ ] **Step 3: Verificar no browser**

Abrir `http://localhost:5173/evento.html?slug=<algum-slug>`. Verificar breadcrumb: "Início > Eventos > [Título do Evento]". Confirmar que "Eventos" navega para `eventos.html`.

- [ ] **Step 4: Commit**

```bash
git add src/event-detail.js
git commit -m "feat: add breadcrumb to event detail page"
```

---

### Task 6: Integrar breadcrumb em `live-detail.js`

**Files:**

- Modify: `src/live-detail.js`

O ficheiro carrega lives do catálogo. A live carregada fica na variável `live` com propriedade `.titulo` (NÃO `.title` — lives-catalog.json usa `titulo`).

- [ ] **Step 1: Adicionar import do breadcrumb**

Após os imports existentes, adicionar:

```javascript
import { renderBreadcrumb } from "./breadcrumb.js";
```

- [ ] **Step 2: Chamar `renderBreadcrumb()` após carregar a live**

Após a live ser carregada e renderizada com sucesso (dentro do `DOMContentLoaded`), adicionar:

```javascript
renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Lives", href: "/lives-list.html" },
  { label: live.titulo },
]);
```

- [ ] **Step 3: Verificar no browser**

Abrir `http://localhost:5173/lives.html?slug=<algum-slug>`. Verificar breadcrumb: "Início > Lives > [Título da Live]". Confirmar que "Lives" navega para `lives-list.html`.

- [ ] **Step 4: Commit**

```bash
git add src/live-detail.js
git commit -m "feat: add breadcrumb to live detail page"
```

---

### Task 7: Integrar breadcrumb em `inscription-logic.js` (com import do events-catalog)

**Files:**

- Modify: `src/inscription-logic.js`

Este é o caso especial. O `inscription-logic.js` NÃO importa o catálogo de eventos e NÃO tem o título do evento — só tem o slug via `params.get("evento")`. Precisamos importar `events-catalog.json` para buscar o título e montar o breadcrumb de 4 níveis.

O slug é obtido na linha ~70: `const eventoSlug = params.get("evento");`

- [ ] **Step 1: Adicionar imports**

No topo do ficheiro (após os imports existentes nas linhas 1-2), adicionar:

```javascript
import eventsData from "./content/events-catalog.json";
import { renderBreadcrumb } from "./breadcrumb.js";
```

- [ ] **Step 2: Buscar título do evento e chamar `renderBreadcrumb()`**

Após a linha onde `eventoSlug` é obtido (dentro do `DOMContentLoaded`), adicionar:

```javascript
// Buscar título do evento para o breadcrumb
const eventoForBreadcrumb = eventsData.events.find(
  (e) => e.slug === eventoSlug
);
const eventoTitle = eventoForBreadcrumb ? eventoForBreadcrumb.title : "Evento";

renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Eventos", href: "/eventos.html" },
  { label: eventoTitle, href: `/evento.html?slug=${eventoSlug}` },
  { label: "Inscrição" },
]);
```

**Nota:** `eventsData.events` — verificar o nome da propriedade raiz do JSON. Se o catálogo for um array direto, usar `eventsData.find(...)`. Se for objeto com propriedade `events`, usar `eventsData.events.find(...)`. O `event-detail.js` importa como `eventsData from './content/events-catalog.json'` e acessa os dados — confirmar a estrutura ao implementar.

- [ ] **Step 3: Verificar no browser**

Abrir `http://localhost:5173/inscricao.html?evento=<algum-slug>`. Verificar breadcrumb de 4 níveis: "Início > Eventos > [Nome do Evento] > Inscrição". Confirmar que clicar no nome do evento navega para `evento.html?slug=<slug>`. Confirmar que "Inscrição" não é link.

- [ ] **Step 4: Commit**

```bash
git add src/inscription-logic.js
git commit -m "feat: add breadcrumb with event title to inscription page"
```

---

### Task 8: Verificação final e build

- [ ] **Step 1: Verificar build de produção**

Run: `cd "C:/Users/bapti/Documents/Criação de WebSites/Conheça Farmácia" && npm run build`

Expected: Build completo sem erros.

- [ ] **Step 2: Verificar checklist de aceitação do spec**

1. [ ] `artigo.html?slug=...` → breadcrumb "Início > Artigos > Título"
2. [ ] Clicar em "Início" → navega para `index.html`
3. [ ] Clicar em "Artigos" → navega para `artigos.html`
4. [ ] Página atual (último nível) não é clicável
5. [ ] Em mobile (<768px), "Início" é substituído por "…"
6. [ ] Ativar dark mode → breadcrumb adapta cores automaticamente
7. [ ] `evento.html?slug=...` → breadcrumb "Início > Eventos > Título"
8. [ ] `lives.html?slug=...` → breadcrumb "Início > Lives > Título"
9. [ ] `inscricao.html?evento=...` → breadcrumb "Início > Eventos > [Nome Evento] > Inscrição"
10. [ ] Na inscrição, clicar no nome do evento → volta para `evento.html?slug=...`
11. [ ] Páginas de listagem (`artigos.html`, `eventos.html`, `lives-list.html`) NÃO mostram breadcrumb
12. [ ] `npm run build` → sem erros

- [ ] **Step 3: Commit final se houver correções**

```bash
git add -A
git commit -m "fix: breadcrumb final adjustments after QA"
```

(Apenas se necessário — não commitar se não houver mudanças.)
