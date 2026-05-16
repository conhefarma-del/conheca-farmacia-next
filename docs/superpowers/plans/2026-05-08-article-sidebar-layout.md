# Article Sidebar Layout Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ajustar o layout desktop da página artigo.html para que o conteúdo do artigo ocupe 2/3 da largura e o sidebar do autor ocupe 1/3, removendo o comportamento sticky do card do autor.

**Architecture:** Alterar a classe CSS `article-grid` de um grid 3-colunas iguais para que o `article-body-wrapper` ocupe `col-span-2` e o `article-sidebar` mantenha `col-span-1`. Remover `sticky top-8` do `author-card-detailed`.

**Tech Stack:** Tailwind CSS v4, vanilla HTML/CSS

---

### Task 1: Atualizar article-body-wrapper para col-span-2

**Files:**

- Modify: `src/input.css:378-380` (`.article-body-wrapper`)

- [ ] **Step 1: Modificar a classe `.article-body-wrapper` no CSS**

  Atual:

  ```css
  .article-body-wrapper {
    @apply w-full;
  }
  ```

  Novo:

  ```css
  .article-body-wrapper {
    @apply lg:col-span-2;
  }
  ```

- [ ] **Step 2: Verificar que o build compila sem erros**
      Run: `npm run build`
      Expected: BUILD SUCCESS, sem warnings de CSS

- [ ] **Step 3: Commit**
  ```bash
  git add src/input.css
  git commit -m "feat: article body ocupa 2/3 do grid desktop (lg:col-span-2)"
  ```

---

### Task 2: Remover sticky do author-card-detailed

**Files:**

- Modify: `src/input.css:432-434` (`.author-card-detailed`)

- [ ] **Step 1: Modificar a classe `.author-card-detailed` no CSS**

  Atual:

  ```css
  .author-card-detailed {
    @apply bg-brand-bg-alt rounded-2xl p-8 text-center sticky top-8;
  }
  ```

  Novo:

  ```css
  .author-card-detailed {
    @apply bg-brand-bg-alt rounded-2xl p-8 text-center;
  }
  ```

- [ ] **Step 2: Verificar que o build compila sem erros**
      Run: `npm run build`
      Expected: BUILD SUCCESS

- [ ] **Step 3: Commit**
  ```bash
  git add src/input.css
  git commit -m "feat: remover sticky do card do autor no sidebar"
  ```

---

### Task 3: Confirmar visualmente no browser

**Files:** Nenhum — teste manual

- [ ] **Step 1: Iniciar o dev server e abrir artigo.html**
      Run: `npm run dev`
      Abrir: `http://localhost:5173/artigo.html?id=001`

- [ ] **Step 2: Verificar desktop (≥1024px)**
  - Conteúdo do artigo ocupa ~2/3 da largura
  - Sidebar do autor ocupa ~1/3 à direita
  - Card do autor NÃO acompanha o scroll (não sticky)

- [ ] **Step 3: Verificar mobile (<1024px)**
  - Layout mantém stack vertical (artigo acima, sidebar abaixo)
  - Sem regressões visuais

- [ ] **Step 4: Commit final se tudo OK (nenhuma alteração extra necessária)**
      Se forem necessários ajustes, corrigir e commitar.
