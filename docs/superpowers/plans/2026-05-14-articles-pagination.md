# Paginação de Artigos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar paginação client-side na página artigos.html com 30 artigos por página, navegação numérica + Anterior/Próximo, hash na URL e scroll suave.

**Architecture:** Paginação client-side via fatiamento do array filtrado com `Array.slice()`. O JSON inteiro é importado via Vite (como já funciona). A função `renderArticles()` fatia os resultados filtrados para exibir apenas 30 cards por vez. Uma nova função `renderPagination()` gera os botões de navegação. Hash `#page=N` na URL permite share/bookmark e sincronização com botões voltar/avançar do browser.

**Tech Stack:** Vanilla JavaScript, Tailwind CSS v4 (via `@tailwindcss/vite`), Vite ES modules, JSON import

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `src/articles-logic.js` | Modify | Adicionar estado de paginação, fatiar array, renderPagination(), hash sync, scroll |
| `artigos.html` | Modify | Adicionar `<div id="pagination">` abaixo do grid |
| `src/input.css` | Modify | Adicionar estilos do componente de paginação na camada `@layer components` |

---

### Task 1: Adicionar container de paginação no HTML

**Files:**
- Modify: `artigos.html:282` (após o `#no-results` div, antes do fechamento do `container-center`)

- [ ] **Step 1: Adicionar div #pagination abaixo do grid e no-results**

No arquivo `artigos.html`, após a linha `</div>` que fecha o `#no-results` (linha 282) e antes do `</div>` que fecha o `container-center` (linha 283), adicionar:

```html
<!-- Pagination -->
<div id="pagination" class="mt-8"></div>
```

O bloco final da seção do grid fica assim:

```html
<div id="articles-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
  <!-- Articles will be rendered here by JS -->
</div>

<!-- No Results State -->
<div id="no-results" class="hidden text-center py-20">
  <div class="text-6xl mb-4">🔍</div>
  <h3 class="text-xl font-bold text-brand-deep">
    Nenhum artigo encontrado
  </h3>
  <p class="text-brand-deep/60">
    Tente termos diferentes ou remova os filtros.
  </p>
</div>

<!-- Pagination -->
<div id="pagination" class="mt-8"></div>
```

- [ ] **Step 2: Verificar no browser que a div vazia aparece no DOM**

Run: `npm run dev`

Abrir http://localhost:5173/artigos.html, inspecionar o DOM e confirmar que `#pagination` existe abaixo de `#no-results`. Deve estar vazio (sem conteúdo visual).

- [ ] **Step 3: Commit**

```bash
git add artigos.html
git commit -m "feat: add pagination container div to artigos.html"
```

---

### Task 2: Adicionar estilos CSS do componente de paginação

**Files:**
- Modify: `src/input.css:1586` (dentro do `@layer components { ... }`, antes da chave de fechamento final)

- [ ] **Step 1: Adicionar estilos da paginação no input.css**

Dentro de `@layer components { ... }`, após os estilos de breadcrumb (após a linha ~1498, antes do `.capacity-status`), adicionar:

```css
/* ============================================
PAGINATION (artigos.html)
============================================ */
.pagination {
  @apply flex items-center justify-center gap-2 flex-wrap;
}

.pagination-btn {
  @apply inline-flex items-center gap-1.5 px-4 py-2 rounded-lg text-sm font-medium border-2 border-brand-divider text-brand-deep transition-all duration-200 hover:bg-brand-primary hover:text-white hover:border-brand-primary;
}

.pagination-btn:disabled {
  @apply opacity-40 cursor-not-allowed hover:bg-transparent hover:text-brand-deep hover:border-brand-divider;
}

.pagination-numbers {
  @apply flex items-center gap-1;
}

.pagination-num {
  @apply w-10 h-10 rounded-lg text-sm font-medium flex items-center justify-center transition-all duration-200 border-2 border-transparent text-brand-deep hover:bg-brand-primary/10 hover:border-brand-primary/20;
}

.pagination-num.active {
  @apply bg-brand-primary text-white font-semibold border-brand-primary;
}

.pagination-ellipsis {
  @apply w-10 h-10 flex items-center justify-center text-brand-deep/40 select-none;
}

/* Mobile: botões menores, texto vira só ícone */
@media (max-width: 640px) {
  .pagination {
    @apply gap-1.5;
  }

  .pagination-btn {
    @apply px-2 py-1.5 text-xs;
  }

  .pagination-btn .btn-label {
    @apply hidden;
  }

  .pagination-num {
    @apply w-9 h-9 text-xs;
  }

  .pagination-ellipsis {
    @apply w-9 h-9 text-xs;
  }
}

/* Dark mode pagination */
html.dark .pagination-btn {
  border-color: var(--color-brand-divider);
  color: var(--color-brand-deep);
}

html.dark .pagination-btn:hover:not(:disabled) {
  background-color: var(--color-brand-primary);
  color: white;
  border-color: var(--color-brand-primary);
}

html.dark .pagination-num {
  color: var(--color-brand-deep);
}

html.dark .pagination-num:hover {
  background-color: rgba(0, 73, 58, 0.08);
}

html.dark .pagination-num.active {
  background-color: var(--color-brand-primary);
  color: white;
  border-color: var(--color-brand-primary);
}

html.dark .pagination-ellipsis {
  color: var(--color-brand-deep);
  opacity: 0.4;
}
```

- [ ] **Step 2: Verificar que os estilos compilam sem erros**

Run: `npm run dev`

Abrir http://localhost:5173/artigos.html — não deve haver erros no console do Vite. Os estilos estão definidos mas não visíveis ainda (paginação ainda não é renderizada).

- [ ] **Step 3: Commit**

```bash
git add src/input.css
git commit -m "feat: add pagination component styles with dark mode and mobile responsive"
```

---

### Task 3: Implementar lógica de paginação no articles-logic.js

**Files:**
- Modify: `src/articles-logic.js`

- [ ] **Step 1: Adicionar constantes e estado de paginação**

No topo do arquivo `src/articles-logic.js`, após as variáveis existentes (linha 5), adicionar:

```javascript
let currentPage = 1;
const ARTICLES_PER_PAGE = 30;
```

O bloco de estado fica:

```javascript
let articles = [];
let currentFilter = "all";
let searchTerm = "";
let currentPage = 1;
const ARTICLES_PER_PAGE = 30;
```

- [ ] **Step 2: Adicionar referência ao container de paginação**

Na função `DOMContentLoaded` (linha 18), após as referências existentes (linha 22), adicionar:

```javascript
const paginationContainer = document.getElementById("pagination");
```

O bloco de referências fica:

```javascript
const grid = document.getElementById("articles-grid");
const noResults = document.getElementById("no-results");
const searchInput = document.getElementById("search-input");
const filterButtons = document.querySelectorAll(".filter-btn");
const paginationContainer = document.getElementById("pagination");
```

- [ ] **Step 3: Modificar renderArticles() para fatiar o array filtrado**

Substituir o corpo da função `renderArticles()` (linhas 24-59) por:

```javascript
function renderArticles() {
  console.log("Renderizando artigos. Total:", articles.length);

  const filtered = articles.filter((article) => {
    const matchesFilter =
      currentFilter === "all" || article.category === currentFilter;
    const matchesSearch =
      article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      article.excerpt.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesFilter && matchesSearch;
  });

  console.log("Artigos filtrados:", filtered.length);

  // Pagination slice
  const totalPages = Math.ceil(filtered.length / ARTICLES_PER_PAGE);
  if (currentPage > totalPages && totalPages > 0) currentPage = 1;
  if (currentPage < 1) currentPage = 1;

  const start = (currentPage - 1) * ARTICLES_PER_PAGE;
  const end = start + ARTICLES_PER_PAGE;
  const pageArticles = filtered.slice(start, end);

  grid.innerHTML = "";

  if (filtered.length === 0) {
    noResults.classList.remove("hidden");
    paginationContainer.innerHTML = "";
  } else {
    noResults.classList.add("hidden");
    pageArticles.forEach((article) => {
      const card = document.createElement("article");
      card.className =
        "article-card article-card-anim border border-brand-divider/10";
      card.innerHTML = `
        <img src="${article.image}" alt="${article.title}" class="article-card-img" loading="lazy" decoding="async">
        <div class="article-card-content">
          <span class="article-tag" style="background-color: ${categoryColors[article.category]}20; color: ${categoryColors[article.category]}; border: 1px solid ${categoryColors[article.category]}40">${article.categoryLabel}</span>
          <h3 class="article-card-title">${article.title}</h3>
          <p class="article-card-excerpt">${article.excerpt}</p>
          <a href="artigo.html?id=${article.id}" class="article-card-link">Ler mais <span>→</span></a>
        </div>
      `;
      grid.appendChild(card);
    });
    renderPagination(filtered.length);
  }
}
```

- [ ] **Step 4: Implementar renderPagination(totalFiltered)**

Adicionar a função `renderPagination()` dentro do escopo do `DOMContentLoaded`, após `renderArticles()`:

```javascript
function renderPagination(totalFiltered) {
  const totalPages = Math.ceil(totalFiltered / ARTICLES_PER_PAGE);

  // Hide pagination if only 1 page
  if (totalPages <= 1) {
    paginationContainer.innerHTML = "";
    return;
  }

  // Build page number list with ellipsis truncation
  const pageNumbers = buildPageNumbers(currentPage, totalPages);

  let html = `<nav class="pagination" aria-label="Navegação de páginas">`;

  // Previous button
  html += `<button class="pagination-btn" data-page="prev" ${currentPage === 1 ? "disabled" : ""}>
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
    <span class="btn-label">Anterior</span>
  </button>`;

  // Page numbers
  html += `<div class="pagination-numbers">`;
  pageNumbers.forEach((item) => {
    if (item === "...") {
      html += `<span class="pagination-ellipsis">...</span>`;
    } else {
      html += `<button class="pagination-num ${item === currentPage ? "active" : ""}" data-page="${item}">${item}</button>`;
    }
  });
  html += `</div>`;

  // Next button
  html += `<button class="pagination-btn" data-page="next" ${currentPage === totalPages ? "disabled" : ""}>
    <span class="btn-label">Próximo</span>
    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
  </button>`;

  html += `</nav>`;
  paginationContainer.innerHTML = html;
}
```

- [ ] **Step 5: Implementar buildPageNumbers() para truncamento com elipses**

Adicionar a função `buildPageNumbers()` dentro do escopo do `DOMContentLoaded`, antes de `renderPagination()`:

```javascript
function buildPageNumbers(current, total) {
  // Always show first and last.
  // Show 2 pages around current.
  // Use ellipsis for gaps.
  if (total <= 7) {
    return Array.from({ length: total }, (_, i) => i + 1);
  }

  const pages = [];
  const showAroundCurrent = 2;

  // Always include page 1
  pages.push(1);

  // Calculate range around current
  const rangeStart = Math.max(2, current - showAroundCurrent);
  const rangeEnd = Math.min(total - 1, current + showAroundCurrent);

  // Add ellipsis after page 1 if needed
  if (rangeStart > 2) {
    pages.push("...");
  }

  // Add range around current
  for (let i = rangeStart; i <= rangeEnd; i++) {
    pages.push(i);
  }

  // Add ellipsis before last page if needed
  if (rangeEnd < total - 1) {
    pages.push("...");
  }

  // Always include last page
  pages.push(total);

  return pages;
}
```

- [ ] **Step 6: Adicionar event delegation para cliques na paginação**

Após `renderPagination()`, adicionar o listener de clique:

```javascript
paginationContainer.addEventListener("click", (e) => {
  const btn = e.target.closest("[data-page]");
  if (!btn || btn.disabled) return;

  const page = btn.dataset.page;
  const totalPages = Math.ceil(
    articles.filter((article) => {
      const matchesFilter =
        currentFilter === "all" || article.category === currentFilter;
      const matchesSearch =
        article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        article.excerpt.toLowerCase().includes(searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    }).length / ARTICLES_PER_PAGE
  );

  if (page === "prev") {
    currentPage = Math.max(1, currentPage - 1);
  } else if (page === "next") {
    currentPage = Math.min(totalPages, currentPage + 1);
  } else {
    currentPage = parseInt(page, 10);
  }

  // Update hash (triggers hashchange → syncPageFromHash)
  window.location.hash = "page=" + currentPage;
  renderArticles();

  // Scroll to top of grid
  grid.scrollIntoView({ behavior: "smooth", block: "start" });
});
```

- [ ] **Step 7: Resetar currentPage ao trocar filtro ou buscar**

Modificar o handler de clique nos filtros (linhas 63-69) para resetar página:

```javascript
filterButtons.forEach((btn) => {
  btn.addEventListener("click", () => {
    filterButtons.forEach((b) => b.classList.remove("active"));
    btn.classList.add("active");
    currentFilter = btn.dataset.filter;
    currentPage = 1;
    window.location.hash = "page=1";
    renderArticles();
  });
});
```

Modificar o handler de busca (linhas 73-76) para resetar página:

```javascript
searchInput.addEventListener("input", (e) => {
  searchTerm = e.target.value;
  currentPage = 1;
  window.location.hash = "page=1";
  renderArticles();
});
```

- [ ] **Step 8: Implementar sincronização com hash da URL**

Antes da chamada inicial `renderArticles()` (linha 81), adicionar:

```javascript
// Sync page from URL hash
function syncPageFromHash() {
  const hash = window.location.hash;
  const match = hash.match(/^#page=(\d+)$/);
  if (match) {
    const page = parseInt(match[1], 10);
    if (page > 0) {
      currentPage = page;
    } else {
      currentPage = 1;
    }
  }
}

syncPageFromHash();

// Listen for hash changes (browser back/forward)
window.addEventListener("hashchange", () => {
  syncPageFromHash();
  renderArticles();
});
```

A chamada final fica:

```javascript
articles = articlesData.articles;
console.log("Catálogo carregado:", articlesData);
syncPageFromHash();
renderArticles();
```

- [ ] **Step 9: Verificar que tudo funciona no browser**

Run: `npm run dev`

Abrir http://localhost:5173/artigos.html — com 14 artigos a paginação NÃO deve aparecer (≤1 página). Verificar que:
- Todos os 14 cards aparecem normalmente
- Filtros continuam funcionando
- Busca continua funcionando
- Nenhum erro no console
- Hash `#page=1` funciona sem erros (mesmo que paginação não apareça)

- [ ] **Step 10: Commit**

```bash
git add src/articles-logic.js
git commit -m "feat: add client-side pagination to articles page with hash sync and scroll"
```

---

### Task 4: Verificação final e teste com dados simulados

**Files:**
- Modify: `src/articles-logic.js` (temporariamente, apenas para teste visual)

- [ ] **Step 1: Testar paginação visualmente reduzindo ARTICLES_PER_PAGE**

Temporariamente alterar `ARTICLES_PER_PAGE` para `3` (em vez de 30) para forçar paginação com 14 artigos:

```javascript
const ARTICLES_PER_PAGE = 3; // TEMP: test pagination visibility
```

- [ ] **Step 2: Verificar no browser**

Abrir http://localhost:5173/artigos.html e confirmar:

1. Paginação aparece abaixo do grid com números 1, 2, 3, 4, 5
2. Botão "Anterior" está desabilitado na página 1
3. Clicar em "2" → mostra artigos 4-6, URL muda para `#page=2`
4. Clicar em "Próximo" → vai para página 3, URL `#page=3`
5. Na última página, "Próximo" está desabilitado
6. Recarregar com `#page=2` na URL → abre na página 2
7. Botão voltar do browser → volta para página anterior
8. Trocar filtro → volta para página 1
9. Digitar na busca → volta para página 1
10. Scroll suave para o topo do grid ao trocar página
11. Dark mode: paginação com cores corretas
12. Mobile: botões Anterior/Próximo mostram só ícone (sem texto)
13. Se filtro resulta em ≤3 artigos → paginação some
14. Se filtro resulta em 0 artigos → paginação some, "sem resultados" aparece

- [ ] **Step 3: Restaurar ARTICLES_PER_PAGE para 30**

```javascript
const ARTICLES_PER_PAGE = 30;
```

- [ ] **Step 4: Build de produção sem erros**

Run: `npm run build`

Confirmar que o build completa sem erros.

- [ ] **Step 5: Commit final**

```bash
git add src/articles-logic.js
git commit -m "feat: complete articles pagination — verified and production-ready"
```
