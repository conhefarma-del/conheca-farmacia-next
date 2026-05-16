# Artigos Científicos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar uma sub-página "Artigos Científicos" dentro da secção de Artigos, com layout académico próprio, citações exportáveis (ABNT/APA/Vancouver), e suporte bilingue (PT/EN).

**Architecture:** Sub-página acessível via banner na página `artigos.html` existente. Nova página `cientificos.html` para listagem (cards académicos) e `artigo-cientifico.html` para detalhe (layout académico com sidebar própria). Dados em JSON (`scientific-articles-catalog.json`) seguindo o padrão existente, com migração futura para Supabase. Campo `lang` nos dados suporta artigos PT e EN. Sistema de citações gera formatos ABNT, APA e Vancouver via JavaScript. **SEO académico:** Highwire Press meta tags injetadas no `<head>` via JS para indexação pelo Google Scholar. **Afiliações estruturadas:** campo `institution` com ID normalizado + campo `department` para permitir filtros futuros por instituição.

**Tech Stack:** HTML5, Tailwind CSS v4, Vanilla JS (ES6+), Vite, marked.js, DOMPurify, JSON data source (mesmo padrão do projeto)

---

## Requisitos (Resumo das Decisões)

| Decisão           | Escolha                                                                                                          |
| ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| Conteúdo          | Artigos da equipa + de terceiros                                                                                 |
| Estrutura visual  | Muito diferente dos artigos atuais (abstract, palavras-chave, referências, múltiplos autores, secções numeradas) |
| Navegação         | Sub-página via banner em `artigos.html`                                                                          |
| Página de detalhe | Nova página dedicada (`artigo-cientifico.html`)                                                                  |
| Sidebar           | Própria (citação copiável, palavras-chave, autores)                                                              |
| Listagem          | Cards académicos (sem imagem hero, com autores, palavras-chave, DOI)                                             |
| Intercatividade   | Leitura + citações exportáveis (ABNT/APA/Vancouver)                                                              |
| DOI               | Fase posterior (campo opcional no JSON; citações adaptam-se quando vazio)                                        |
| SEO Académico     | Highwire Press meta tags para Google Scholar                                                                     |
| Afiliações        | Estruturadas: `institution` (normalizado) + `department` (texto livre)                                           |
| PDF download      | Fase posterior                                                                                                   |
| Review por pares  | Não visível por agora                                                                                            |
| Idioma            | Bilingue (PT + EN) — cada artigo tem `lang`                                                                      |
| Armazenamento     | JSON agora → Supabase depois                                                                                     |
| Volume esperado   | 10-30 artigos no primeiro ano                                                                                    |
| Autores           | Variável (1-N com afiliações)                                                                                    |

---

## File Structure

### Ficheiros Novos

| Ficheiro                                       | Responsabilidade                                                             |
| ---------------------------------------------- | ---------------------------------------------------------------------------- |
| `cientificos.html`                             | Página de listagem de artigos científicos (cards académicos, filtros, busca) |
| `artigo-cientifico.html`                       | Página de detalhe de artigo científico (layout académico, sidebar própria)   |
| `src/scientific-articles-logic.js`             | Lógica de listagem/filtros/busca para `cientificos.html`                     |
| `src/scientific-article-detail.js`             | Lógica de carregamento/renderização para `artigo-cientifico.html`            |
| `src/lib/citation-formatter.js`                | Geração de citações nos formatos ABNT, APA, Vancouver                        |
| `src/content/scientific-articles-catalog.json` | Catálogo de dados dos artigos científicos                                    |
| `src/content/scientific-articles/`             | Directório para ficheiros Markdown de conteúdo                               |

### Ficheiros Modificados

| Ficheiro        | Alteração                                                                  |
| --------------- | -------------------------------------------------------------------------- |
| `artigos.html`  | Adicionar banner "Artigos Científicos" antes do grid                       |
| `src/input.css` | Estilos para cards académicos, layout artigo científico, sidebar, citações |

---

## Data Schema

### `scientific-articles-catalog.json`

```json
{
  "scientificArticles": [
    {
      "id": "sc001-farmacovigilancia-angola",
      "slug": "sc001-farmacovigilancia-angola",
      "title": "Farmacovigilância em Angola: Panorama Atual e Perspectivas Futuras",
      "abstract": "Resumo executivo do artigo científico com 150-300 palavras descrevendo objectivos, metodologia, resultados e conclusões.",
      "keywords": [
        "farmacovigilância",
        "Angola",
        "segurança de medicamentos",
        "regulação"
      ],
      "category": "farmacologia-clinica",
      "categoryLabel": "Farmacologia Clínica",
      "lang": "pt",
      "authors": [
        {
          "name": "Dr. João Pedro",
          "institution": "universidade-de-luanda",
          "institutionLabel": "Universidade de Luanda",
          "department": "Faculdade de Farmácia",
          "affiliation": "Universidade de Luanda, Faculdade de Farmácia",
          "role": "Farmacêutico · Investigador Principal",
          "avatar": "JP",
          "avatarBg": "#006171",
          "corresponding": true
        },
        {
          "name": "Dra. Maria Lima",
          "institution": "hospital-provincial-de-luanda",
          "institutionLabel": "Hospital Provincial de Luanda",
          "department": "Serviço de Farmácia",
          "affiliation": "Hospital Provincial de Luanda, Serviço de Farmácia",
          "role": "Farmacêutica · Co-investigadora",
          "avatar": "ML",
          "avatarBg": "#00493a",
          "corresponding": false
        }
      ],
      "date": "2026-05-01",
      "readTime": 25,
      "image": "/content/scientific-articles/farmacovigilancia-angola.png",
      "content": "## Introdução\n\nConteúdo completo em Markdown...\n\n## Metodologia\n\n...\n\n## Resultados\n\n...\n\n## Discussão\n\n...\n\n## Conclusão\n\n...",
      "references": [
        "World Health Organization. Pharmacovigilance: ensuring the safe use of medicines. WHO, 2024.",
        "ANVISA. Guia de Farmacovigilância. Brasília: ANVISA, 2023.",
        "Silva A, Costa B. A prática farmacêutica em países lusófonos. Rev Saúde Pública. 2025;59(2):45-52."
      ],
      "doi": ""
    }
  ]
}
```

**Notas sobre o schema:**

- `doi`: campo vazio por agora, preenchido quando houver registo oficial. As citações adaptam-se: se `doi` estiver vazio, omitem a referência ao DOI sem gerar texto incompleto.
- `lang`: `"pt"` ou `"en"` — controla etiqueta visual e formatação de citação
- `authors`: array com `institution` (ID slug normalizado para filtragem futura), `institutionLabel` (nome legível), `department` (texto livre), `affiliation` (texto completo para exibição = `institutionLabel, department`), e `corresponding` (autor correspondente)
- `institution` + `institutionLabel`: permitem futuramente "Ver todos os artigos de investigadores da Universidade de Luanda" — o `institution` é o ID normalizado (slug), `institutionLabel` é o nome de exibição
- `abstract`: resumo académico (não confundir com `excerpt` dos artigos normais)
- `keywords`: array de palavras-chave para filtros e sidebar
- `content`: Markdown com secções académicas (Introdução, Metodologia, Resultados, Discussão, Conclusão)
- `references`: array de strings formatadas (mesmo padrão dos artigos atuais, mas mais rigoroso)

---

## Task 1: Criar catálogo JSON com dados de exemplo

**Files:**

- Create: `src/content/scientific-articles-catalog.json`
- Create: `src/content/scientific-articles/sc001-farmacovigilancia-angola.md`
- Create: `src/content/scientific-articles/SC002-antibiotic-resistance-angola.md`

- [ ] **Step 1: Criar directório para conteúdo Markdown**
      Run: `mkdir -p src/content/scientific-articles`

- [ ] **Step 2: Criar o catálogo JSON com 2 artigos de exemplo**
      Criar `src/content/scientific-articles-catalog.json` com o schema acima, contendo:
  - Artigo 1 (PT): "Farmacovigilância em Angola" — categoria `farmacologia-clinica`, 2 autores com afiliações estruturadas (`institution` + `institutionLabel` + `department` + `affiliation`), 3 referências, 5 keywords, abstract completo, lang `"pt"`
  - Artigo 2 (EN): "Antibiotic Resistance in Angola" — categoria `saude-publica`, 3 autores com afiliações estruturadas, 4 referências, 4 keywords, abstract completo, lang `"en"`

O campo `content` deve conter Markdown inline (mesmo padrão dos artigos atuais no `articles-catalog.json`), com secções académicas completas: Introdução, Metodologia, Resultados, Discussão, Conclusão.

- [ ] **Step 3: Verificar que o JSON é válido**
      Run: `node -e "const d = require('./src/content/scientific-articles-catalog.json'); console.log('Artigos carregados:', d.scientificArticles.length)"`

- [ ] **Step 4: Commit**

```bash
git add src/content/scientific-articles-catalog.json src/content/scientific-articles/
git commit -m "feat: add scientific articles catalog with sample data (PT + EN)"
```

---

## Task 2: Criar utilitário de formatação de citações

**Files:**

- Create: `src/lib/citation-formatter.js`

- [ ] **Step 1: Implementar o módulo de citações**
      Criar `src/lib/citation-formatter.js` com a função `formatCitation(article, style)` que recebe um artigo científico (do catálogo) e um estilo (`"abnt"`, `"apa"`, `"vancouver"`) e retorna uma string de citação formatada. **Quando DOI está vazio**, as citações incluem a URL do artigo como fallback (ABNT: "Disponível em: <URL>", APA: URL directa, Vancouver: "Available from: URL"). Quando DOI existe, usa-o como referência permanente. Inclui também nome do publicador ("Conheça Farmácia") nas citações.

````javascript
// src/lib/citation-formatter.js
// src/lib/citation-formatter.js

/**
 * Formata citação bibliográfica de artigo científico
 * @param {Object} article - Objecto artigo do scientific-articles-catalog.json
 * @param {string} style - Estilo de citação: "abnt", "apa", "vancouver"
 * @returns {string} Citação formatada
 */
export function formatCitation(article, style) {
 const authors = article.authors || [];
 const year = article.date ? new Date(article.date).getFullYear() : "s.d.";
 const title = article.title;
 const doi = article.doi || "";
 const publisher = "Conheça Farmácia";
 const url = window.location.href;

 switch (style) {
 case "abnt":
 return formatABNT(authors, year, title, doi, url);
 case "apa":
 return formatAPA(authors, year, title, doi, url);
 case "vancouver":
 return formatVancouver(authors, year, title, doi, publisher, url);
 default:
 return formatABNT(authors, year, title, doi, url);
 }
}

function formatABNT(authors, year, title, doi, url) {
 // ABNT: SOBRENOME, Nome. Título. Conheça Farmácia, Ano. DOI ou Disponível em: URL
 const authorStr = authors
 .map((a) => {
 const parts = a.name.split(" ");
 const lastName = parts[parts.length - 1].toUpperCase();
 const firstNames = parts.slice(0, -1).map((n) => n.charAt(0).toUpperCase() + ".").join(" ");
 return `${lastName}, ${firstNames}`;
 })
 .join("; ");

 let citation = `${authorStr}. ${title}. Conheça Farmácia, ${year}.`;
 if (doi) {
 citation += ` DOI: ${doi}`;
 } else {
 citation += ` Disponível em: <${url}>.`;
 }
 return citation;
}

function formatAPA(authors, year, title, doi, url) {
 // APA: Last, F. M., & Last, F. M. (Year). Title. Conheça Farmácia. DOI ou URL
 const authorStr = authors
 .map((a, i) => {
 const parts = a.name.split(" ");
 const lastName = parts[parts.length - 1];
 const initials = parts.slice(0, -1).map((n) => n.charAt(0).toUpperCase() + ".").join(" ");
 return `${lastName}, ${initials}`;
 })
 .join(", & ");

 let citation = `${authorStr} (${year}). ${title}. Conheça Farmácia.`;
 if (doi) {
 citation += ` https://doi.org/${doi}`;
 } else {
 citation += ` ${url}`;
 }
 return citation;
}

function formatVancouver(authors, year, title, doi, publisher, url) {
 // Vancouver: Last1 FM, Last2 FM. Title. Publisher. Year. DOI ou URL
 const authorStr = authors
 .map((a) => {
 const parts = a.name.split(" ");
 const lastName = parts[parts.length - 1];
 const initials = parts.slice(0, -1).map((n) => n.charAt(0).toUpperCase()).join("");
 return `${lastName} ${initials}`;
 })
 .join(", ");

 let citation = `${authorStr}. ${title}. ${publisher}. ${year}.`;
 if (doi) {
 citation += ` doi:${doi}`;
 } else {
 citation += ` Available from: ${url}`;
 }
 return citation;
}

/**
 * Copia texto para clipboard
 * @param {string} text - Texto a copiar
 * @returns {Promise<boolean>} true se copiou com sucesso
 */
export async function copyToClipboard(text) {
 try {
 await navigator.clipboard.writeText(text);
 return true;
 } catch {
 // Fallback para browsers sem clipboard API
 const textarea = document.createElement("textarea");
 textarea.value = text;
 textarea.style.position = "fixed";
 textarea.style.opacity = "0";
 document.body.appendChild(textarea);
 textarea.select();
 const success = document.execCommand("copy");
 document.body.removeChild(textarea);
 return success;
 }
}

- [ ] **Step 2: Testar manualmente o módulo no browser**
Run: `npm run dev`
No console do browser em `localhost:5173`, verificar que import funciona:
```javascript
import { formatCitation } from "/src/lib/citation-formatter.js";
````

- [ ] **Step 3: Commit**

```bash
git add src/lib/citation-formatter.js
git commit -m "feat: add citation formatter (ABNT, APA, Vancouver)"
```

---

## Task 3: Adicionar banner "Artigos Científicos" em artigos.html

**Files:**

- Modify: `artigos.html` (inserir banner antes da secção do grid)

- [ ] **Step 1: Adicionar o banner entre a secção de filtros e o grid**
      Em `artigos.html`, inserir após o fecho da secção `articles-filter-section` (linha ~205) e antes da secção `section-padding bg-brand-bg-alt` (linha ~208):

```html
<!-- Scientific Articles Banner -->
<section class="scientific-articles-banner">
  <div class="container-center">
    <a href="cientificos.html" class="sci-banner-link">
      <div class="sci-banner-content">
        <div class="sci-banner-icon">
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
          >
            <path
              d="M12 6.042A8.967 8.967 0 006 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 016 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 016-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0018 18a8.967 8.967 0 00-6 2.292m0-14.25v14.25"
            />
          </svg>
        </div>
        <div class="sci-banner-text">
          <h2 class="sci-banner-title">Artigos Científicos</h2>
          <p class="sci-banner-desc">
            Publicações académicas com revisão, referências e citações
            exportáveis
          </p>
        </div>
        <div class="sci-banner-arrow">
          <svg
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
          >
            <path d="M9 18l6-6-6-6" />
          </svg>
        </div>
      </div>
    </a>
  </div>
</section>
```

- [ ] **Step 2: Verificar visualmente no browser**
      Run: `npm run dev`
      Navegar para `http://localhost:5173/artigos.html` e confirmar que o banner aparece entre os filtros e o grid de artigos.

- [ ] **Step 3: Commit**

```bash
git add artigos.html
git commit -m "feat: add scientific articles banner on artigos.html"
```

---

## Task 4: Adicionar estilos CSS para o banner e componentes científicos

**Files:**

- Modify: `src/input.css` (adicionar estilos no final)

- [ ] **Step 1: Adicionar estilos do banner em artigos.html**
      No final de `src/input.css`, adicionar:

```css
/* ============================================
   Scientific Articles Banner (artigos.html)
   ============================================ */
.scientific-articles-banner {
  @apply py-8 bg-brand-bg-alt;
}

.sci-banner-link {
  @apply block rounded-2xl border-2 border-dashed border-brand-accent/30
    hover:border-brand-accent/60 hover:shadow-soft
    transition-all duration-300 overflow-hidden;
}

.sci-banner-content {
  @apply flex items-center gap-6 p-6 md:p-8;
}

.sci-banner-icon {
  @apply flex-shrink-0 w-12 h-12 rounded-xl bg-brand-accent/10
    flex items-center justify-center text-brand-accent;
}

.sci-banner-icon svg {
  @apply w-6 h-6;
}

.sci-banner-text {
  @apply flex-1;
}

.sci-banner-title {
  @apply text-xl md:text-2xl font-bold text-brand-deep mb-1;
}

.sci-banner-desc {
  @apply text-sm md:text-base text-brand-deep/60;
}

.sci-banner-arrow {
  @apply flex-shrink-0 text-brand-accent/50;
}

.sci-banner-arrow svg {
  @apply w-6 h-6;
}
```

- [ ] **Step 2: Adicionar estilos para cards académicos (cientificos.html)**
      Ainda em `src/input.css`, adicionar:

```css
/* ============================================
   Scientific Article Cards (cientificos.html)
   ============================================ */
.sci-card {
  @apply rounded-2xl border border-brand-divider/10 bg-white
    p-6 md:p-8 hover:shadow-soft transition-all duration-300;
}

.sci-card-category {
  @apply inline-block text-xs font-semibold uppercase tracking-wider
    px-3 py-1 rounded-full mb-4;
}

.sci-card-title {
  @apply text-lg md:text-xl font-bold text-brand-deep mb-3 leading-tight;
}

.sci-card-abstract {
  @apply text-sm text-brand-deep/70 mb-4 line-clamp-3;
}

.sci-card-authors {
  @apply flex flex-wrap gap-1 mb-3;
}

.sci-card-author {
  @apply text-xs text-brand-deep/50;
}

.sci-card-author-separator {
  @apply text-xs text-brand-deep/30;
}

.sci-card-keywords {
  @apply flex flex-wrap gap-2 mb-4;
}

.sci-card-keyword {
  @apply text-xs px-2 py-0.5 rounded bg-brand-accent/10 text-brand-accent
    font-medium;
}

.sci-card-meta {
  @apply flex items-center gap-4 text-xs text-brand-deep/50 pt-4
    border-t border-brand-divider/10;
}

.sci-card-lang {
  @apply inline-flex items-center gap-1 text-xs font-semibold uppercase
    px-2 py-0.5 rounded bg-brand-deep/5 text-brand-deep/60;
}

/* ============================================
   Scientific Article Detail (artigo-cientifico.html)
   ============================================ */

/* Abstract Box */
.sci-abstract-box {
  @apply bg-brand-accent/5 border-l-4 border-brand-accent rounded-r-xl
    p-6 md:p-8 mb-8;
}

.sci-abstract-title {
  @apply text-sm font-bold uppercase tracking-wider text-brand-accent mb-3;
}

.sci-abstract-text {
  @apply text-brand-deep/80 leading-relaxed italic;
}

/* Keywords */
.sci-keywords-section {
  @apply mb-8;
}

.sci-keywords-label {
  @apply text-xs font-bold uppercase tracking-wider text-brand-deep/40 mb-2;
}

.sci-keywords-list {
  @apply flex flex-wrap gap-2;
}

.sci-keyword-tag {
  @apply text-sm px-3 py-1 rounded-full bg-brand-accent/10 text-brand-accent
    font-medium cursor-pointer hover:bg-brand-accent/20 transition-colors;
}

/* Authors Grid */
.sci-authors-grid {
  @apply grid grid-cols-1 md:grid-cols-2 gap-4 mb-8;
}

.sci-author-card {
  @apply flex items-start gap-3 p-4 rounded-xl bg-brand-bg-alt;
}

.sci-author-avatar {
  @apply flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center
    text-sm font-bold text-white;
}

.sci-author-info {
  @apply flex-1;
}

.sci-author-name {
  @apply text-sm font-bold text-brand-deep;
}

.sci-author-affiliation {
  @apply text-xs text-brand-deep/50 mt-0.5;
}

.sci-author-corresponding {
  @apply text-xs text-brand-accent font-medium mt-1;
}

/* Citation Widget (sidebar) */
.sci-citation-widget {
  @apply rounded-2xl border border-brand-divider/10 bg-white p-6;
}

.sci-citation-title {
  @apply text-sm font-bold uppercase tracking-wider text-brand-deep/40 mb-4;
}

.sci-citation-tabs {
  @apply flex gap-2 mb-4;
}

.sci-citation-tab {
  @apply text-xs px-3 py-1.5 rounded-lg font-semibold uppercase
    bg-brand-deep/5 text-brand-deep/50 cursor-pointer
    hover:bg-brand-accent/10 hover:text-brand-accent transition-colors;
}

.sci-citation-tab.active {
  @apply bg-brand-accent text-white;
}

.sci-citation-text {
  @apply text-sm text-brand-deep/70 bg-brand-bg-alt rounded-lg p-4
    font-mono leading-relaxed break-words;
}

.sci-citation-copy-btn {
  @apply mt-3 w-full flex items-center justify-center gap-2
    px-4 py-2 rounded-lg border border-brand-divider/20
    text-sm font-medium text-brand-deep/60
    hover:bg-brand-accent hover:text-white hover:border-brand-accent
    transition-all;
}

.sci-citation-copy-btn.copied {
  @apply bg-green-500 border-green-500 text-white;
}

/* Scientific article body styles */
.sci-article-body {
  @apply text-brand-deep leading-relaxed;
}

.sci-article-body h2 {
  @apply text-2xl font-bold text-brand-deep mt-10 mb-4 pb-2
    border-b border-brand-divider/10;
}

.sci-article-body h3 {
  @apply text-xl font-bold text-brand-deep mt-8 mb-3;
}

.sci-article-body p {
  @apply mb-4;
}

.sci-article-body ul,
.sci-article-body ol {
  @apply mb-4 pl-6;
}

.sci-article-body li {
  @apply mb-1;
}

.sci-article-body blockquote {
  @apply pl-4 border-l-4 border-brand-accent/30 italic
    text-brand-deep/70 my-6;
}

.sci-article-body table {
  @apply w-full border-collapse mb-6;
}

.sci-article-body th,
.sci-article-body td {
  @apply border border-brand-divider/20 px-4 py-2 text-sm;
}

.sci-article-body th {
  @apply bg-brand-deep/5 font-bold;
}

/* References list */
.sci-references-list {
  @apply space-y-3;
}

.sci-reference-item {
  @apply flex gap-3 text-sm text-brand-deep/70;
}

.sci-reference-number {
  @apply flex-shrink-0 font-bold text-brand-accent;
}

.sci-reference-text {
  @apply flex-1;
}
```

- [ ] **Step 3: Adicionar estilos dark mode para componentes científicos**
      Ainda em `src/input.css`, dentro da secção dark mode (após o bloco `@variant dark`):

```css
/* Dark mode — Scientific Articles */
@variant dark {
  .sci-card {
    @apply bg-brand-deep border-brand-divider/20;
  }

  .sci-banner-link {
    @apply border-brand-accent/20;
  }

  .sci-banner-title {
    @apply text-white;
  }

  .sci-banner-desc {
    @apply text-white/60;
  }

  .sci-banner-icon {
    @apply bg-brand-accent/20;
  }

  .sci-abstract-box {
    @apply bg-brand-accent/10 border-brand-accent;
  }

  .sci-author-card {
    @apply bg-brand-deep;
  }

  .sci-author-name {
    @apply text-white;
  }

  .sci-author-affiliation {
    @apply text-white/50;
  }

  .sci-citation-widget {
    @apply bg-brand-deep border-brand-divider/20;
  }

  .sci-citation-text {
    @apply bg-brand-deep text-white/70;
  }

  .sci-citation-copy-btn {
    @apply text-white/60 border-white/10;
  }

  .sci-article-body {
    @apply text-white/90;
  }

  .sci-article-body h2 {
    @apply text-white border-white/10;
  }

  .sci-article-body h3 {
    @apply text-white;
  }

  .sci-article-body th {
    @apply bg-white/5 text-white;
  }

  .sci-article-body td {
    @apply border-white/10 text-white/70;
  }

  .sci-card-title {
    @apply text-white;
  }

  .sci-card-abstract {
    @apply text-white/60;
  }
}
```

- [ ] **Step 4: Verificar que o build compila sem erros**
      Run: `npm run build`
      Expected: Build conclui sem erros CSS.

- [ ] **Step 5: Commit**

```bash
git add src/input.css
git commit -m "feat: add CSS styles for scientific articles (banner, cards, detail, citations)"
```

---

## Task 5: Criar página de listagem cientificos.html

**Files:**

- Create: `cientificos.html`

- [ ] **Step 1: Criar a página HTML completa**
      Criar `cientificos.html` seguindo o mesmo padrão de `artigos.html` (header, drawer, footer) mas com conteúdo próprio:

```html
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Artigos Científicos - Conheça Farmácia</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap"
      rel="stylesheet"
    />
  </head>
  <body class="antialiased text-brand-deep bg-brand-bg">
    <!-- Header (mesmo padrão de artigos.html) -->
    <header class="header">
      <nav class="nav-container">
        <div class="logo">
          <a href="index.html">
            <img
              src="assets/logo/logo-principal-verde.svg"
              alt="Conheça Farmácia Logo"
            />
          </a>
        </div>
        <div class="header-right">
          <button
            class="theme-toggle"
            aria-label="Alternar modo escuro"
            onclick="toggleTheme()"
          >
            <svg class="sun-icon" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="5"></circle>
              <line x1="12" y1="1" x2="12" y2="3"></line>
              <line x1="12" y1="21" x2="12" y2="23"></line>
              <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
              <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
              <line x1="1" y1="12" x2="3" y2="12"></line>
              <line x1="21" y1="12" x2="23" y2="12"></line>
              <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
              <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
            </svg>
            <svg class="moon-icon" viewBox="0 0 24 24">
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
            </svg>
          </button>
          <button class="hamburger" aria-label="Menu">
            <span></span><span></span><span></span>
          </button>
        </div>
      </nav>
    </header>

    <!-- Drawer Overlay + Mobile Drawer (mesmo padrão) -->
    <div class="drawer-overlay" id="drawer-overlay"></div>
    <aside
      class="mobile-drawer"
      id="mobile-drawer"
      aria-label="Menu de navegação"
    >
      <button class="drawer-close" id="drawer-close" aria-label="Fechar menu">
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>
      <div class="drawer-logo">
        <a href="index.html"
          ><img
            src="assets/logo/logo-principal-verde.svg"
            alt="Conheça Farmácia Logo"
        /></a>
      </div>
      <ul class="drawer-links" id="drawer-links">
        <li><a href="index.html#inicio">Início</a></li>
        <li><a href="artigos.html">Artigos</a></li>
        <li><a href="eventos.html">Eventos</a></li>
        <li><a href="lives-list.html">Lives</a></li>
        <li><a href="sobre.html">Sobre Nós</a></li>
      </ul>
      <div class="drawer-footer">
        <button
          class="drawer-theme-toggle"
          aria-label="Alternar modo escuro"
          onclick="toggleTheme()"
        >
          <svg class="sun-icon" viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="5"></circle>
            <line x1="12" y1="1" x2="12" y2="3"></line>
            <line x1="12" y1="21" x2="12" y2="23"></line>
            <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
            <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
            <line x1="1" y1="12" x2="3" y2="12"></line>
            <line x1="21" y1="12" x2="23" y2="12"></line>
            <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
            <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
          </svg>
          <svg class="moon-icon" viewBox="0 0 24 24">
            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
          </svg>
        </button>
        <div class="drawer-social">
          <a
            href="https://facebook.com/conhecafarmacia"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Facebook"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"
              /></svg
          ></a>
          <a
            href="https://instagram.com/conhecafarmacia"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Instagram"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"
              /></svg
          ></a>
          <a
            href="https://linkedin.com/company/conhecafarmacia"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="LinkedIn"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 01-2.063-2.065 2.064 2.064 0 112.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"
              /></svg
          ></a>
          <a
            href="https://tiktok.com/conhecafarmaciaofficial"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="TikTok"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 2.91 1.75 3.93 1.12 1.04 2.57 1.56 4.07 1.6v3.88c-1.37-.04-2.69-.39-3.86-1.03-.61-.34-1.17-.77-1.69-1.24v8.48c.02 2.01-.48 3.99-1.52 5.72-1.54 2.56-4.17 4.35-7.08 4.75-2.36.34-4.86-.14-6.91-1.42-2.5-1.55-4.21-4.24-4.49-7.18-.04-.36-.06-.72-.07-1.08.01-2.3.83-4.59 2.37-6.3 1.72-1.93 4.25-3.09 6.85-3.15v3.89c-1.71.18-3.29 1.14-4.26 2.52-.84 1.18-1.22 2.67-1.04 4.11.22 1.8 1.28 3.46 2.85 4.42 1.43.88 3.24 1.09 4.84.56 1.31-.43 2.43-1.34 3.14-2.52.54-.88.82-1.91.84-2.95V.03h-1.63z"
              /></svg
          ></a>
        </div>
      </div>
    </aside>

    <main>
      <!-- Page Hero -->
      <section class="articles-hero">
        <div class="container-center">
          <div class="text-center py-20 md:py-32">
            <div class="flex items-center justify-center gap-3 mb-6">
              <a
                href="artigos.html"
                class="text-sm text-brand-accent hover:underline"
                >← Artigos</a
              >
              <span class="text-brand-deep/30">|</span>
              <span class="text-sm text-brand-deep/50"
                >Publicações Académicas</span
              >
            </div>
            <h1 class="text-5xl md:text-7xl font-bold text-brand-deep mb-6">
              Artigos Científicos
            </h1>
            <p class="hero-subtitle">
              Publicações académicas com revisão, referências bibliográficas e
              citações exportáveis.
            </p>
          </div>
        </div>
      </section>

      <!-- Search & Filters -->
      <section class="articles-filter-section">
        <div class="container-center">
          <div class="max-w-4xl mx-auto">
            <!-- Search -->
            <div class="relative mb-8">
              <span
                class="absolute inset-y-0 left-0 flex items-center pl-4 text-brand-deep/40"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                  />
                </svg>
              </span>
              <input
                type="text"
                id="sci-search-input"
                placeholder="Pesquise por título, autor, palavras-chave..."
                class="w-full pl-12 pr-4 py-4 rounded-2xl border border-brand-divider shadow-soft focus:ring-2 focus:ring-brand-accent focus:outline-none transition-all text-brand-deep"
              />
            </div>

            <!-- Category Filters -->
            <div
              id="sci-filter-container"
              class="flex flex-wrap justify-center gap-3 pb-8"
            >
              <button class="filter-btn active" data-sci-filter="all">
                Todos
              </button>
              <!-- Dynamic category buttons rendered by JS -->
            </div>

            <!-- Language Filter -->
            <div class="flex justify-center gap-2 pb-4">
              <button class="sci-lang-btn active" data-lang="all">Todos</button>
              <button class="sci-lang-btn" data-lang="pt">PT</button>
              <button class="sci-lang-btn" data-lang="en">EN</button>
            </div>
          </div>
        </div>
      </section>

      <!-- Scientific Articles Grid -->
      <section class="section-padding bg-brand-bg-alt">
        <div class="container-center">
          <div
            id="sci-articles-grid"
            class="grid grid-cols-1 md:grid-cols-2 gap-8 max-w-4xl mx-auto"
          >
            <!-- Cards rendered by JS -->
          </div>

          <!-- No Results -->
          <div id="sci-no-results" class="hidden text-center py-20">
            <div class="text-6xl mb-4">📚</div>
            <h3 class="text-xl font-bold text-brand-deep">
              Nenhum artigo encontrado
            </h3>
            <p class="text-brand-deep/60">
              Tente termos diferentes ou remova os filtros.
            </p>
          </div>
        </div>
      </section>

      <!-- Back to Articles CTA -->
      <section class="py-16 bg-brand-bg-alt">
        <div class="container-center text-center">
          <a href="artigos.html" class="btn btn-primary"
            >← Voltar para Artigos</a
          >
        </div>
      </section>
    </main>

    <!-- Footer (mesmo padrão de artigos.html) -->
    <footer class="footer">
      <div class="container-center">
        <div class="footer-grid">
          <div class="footer-logo">
            <img
              src="assets/logo/logo-principal-branco.svg"
              alt="Conheça Farmácia Logo"
            />
            <p class="text-white/70 text-sm mt-4">
              Conhecimento que conecta. Formação que transforma. Saúde que
              evolui.
            </p>
          </div>
          <div class="footer-links">
            <h4>Navegação</h4>
            <ul>
              <li><a href="index.html#inicio">Início</a></li>
              <li><a href="artigos.html">Artigos</a></li>
              <li><a href="eventos.html">Eventos</a></li>
              <li><a href="lives-list.html">Lives</a></li>
              <li><a href="sobre.html">Sobre Nós</a></li>
            </ul>
          </div>
          <div class="footer-links">
            <h4>Contato</h4>
            <ul class="text-sm text-white/70">
              <li>Luanda, Angola</li>
              <li>
                <a
                  href="mailto:conhecerfarmacia@gmail.com"
                  class="text-white/70 hover:text-brand-accent"
                  >conhecerfarmacia@gmail.com</a
                >
              </li>
              <li>
                <a
                  href="https://wa.me/244925696002"
                  class="text-white/70 hover:text-brand-accent"
                  >+244 925 696 002</a
                >
              </li>
            </ul>
          </div>
          <div class="footer-links">
            <h4>Redes Sociais</h4>
            <ul class="text-sm">
              <li>
                <a
                  href="https://www.facebook.com/conhecafarmacia"
                  target="_blank"
                  >Facebook</a
                >
              </li>
              <li>
                <a
                  href="https://www.instagram.com/conhecafarmacia"
                  target="_blank"
                  >Instagram</a
                >
              </li>
              <li>
                <a
                  href="https://www.tiktok.com/conhecafarmaciaofficial"
                  target="_blank"
                  >TikTok</a
                >
              </li>
              <li>
                <a
                  href="https://www.linkedin.com/company/conhecafarmacia"
                  target="_blank"
                  >LinkedIn</a
                >
              </li>
            </ul>
          </div>
        </div>
        <div class="footer-divider"></div>
        <div class="footer-bottom">
          <p>&copy; 2026 Conheça Farmácia. Todos os direitos reservados.</p>
        </div>
      </div>
    </footer>

    <script type="module" src="/main.js"></script>
    <script type="module" src="/src/scientific-articles-logic.js"></script>
  </body>
</html>
```

- [ ] **Step 2: Adicionar estilo para botões de idioma**
      Em `src/input.css`, adicionar:

```css
/* Language filter buttons */
.sci-lang-btn {
  @apply text-xs px-3 py-1.5 rounded-lg font-semibold uppercase
    bg-brand-deep/5 text-brand-deep/50 cursor-pointer
    hover:bg-brand-accent/10 hover:text-brand-accent transition-colors;
}

.sci-lang-btn.active {
  @apply bg-brand-accent text-white;
}
```

E no bloco `@variant dark`:

```css
.sci-lang-btn {
  @apply bg-white/5 text-white/50;
}
```

- [ ] **Step 3: Commit**

```bash
git add cientificos.html src/input.css
git commit -m "feat: add scientific articles listing page (cientificos.html)"
```

---

## Task 6: Criar lógica de listagem scientific-articles-logic.js

**Files:**

- Create: `src/scientific-articles-logic.js`

- [ ] **Step 1: Implementar a lógica completa**
      Criar `src/scientific-articles-logic.js`:

```javascript
import sciData from "./content/scientific-articles-catalog.json";

let articles = [];
let currentFilter = "all";
let currentLang = "all";
let searchTerm = "";

const categoryColors = {
  "farmacologia-clinica": "#0a844f",
  "saude-publica": "#006171",
  farmacovigilancia: "#ff6c23",
  "educacao-farmaceutica": "#002a32",
  fitoterapia: "#6b7280",
};

function formatDate(dateStr) {
  const date = new Date(dateStr);
  return date.toLocaleDateString("pt-PT", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

function renderCategoryButtons(categories) {
  const container = document.getElementById("sci-filter-container");
  if (!container) return;

  // Keep "Todos" button, remove rest
  const allBtn = container.querySelector('[data-sci-filter="all"]');
  container.innerHTML = "";
  if (allBtn) container.appendChild(allBtn);

  categories.forEach((cat) => {
    const btn = document.createElement("button");
    btn.className = "filter-btn";
    btn.dataset.sciFilter = cat.key;
    btn.textContent = cat.label;
    container.appendChild(btn);
  });

  // Re-attach click events
  container.querySelectorAll("button").forEach((btn) => {
    btn.addEventListener("click", () => {
      container
        .querySelectorAll("button")
        .forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      currentFilter = btn.dataset.sciFilter;
      renderArticles();
    });
  });
}

function renderArticles() {
  const grid = document.getElementById("sci-articles-grid");
  const noResults = document.getElementById("sci-no-results");
  if (!grid || !noResults) return;

  const filtered = articles.filter((article) => {
    const matchesFilter =
      currentFilter === "all" || article.category === currentFilter;
    const matchesLang = currentLang === "all" || article.lang === currentLang;
    const matchesSearch =
      article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      article.abstract.toLowerCase().includes(searchTerm.toLowerCase()) ||
      article.authors.some((a) =>
        a.name.toLowerCase().includes(searchTerm.toLowerCase())
      ) ||
      article.keywords.some((k) =>
        k.toLowerCase().includes(searchTerm.toLowerCase())
      );
    return matchesFilter && matchesLang && matchesSearch;
  });

  grid.innerHTML = "";

  if (filtered.length === 0) {
    noResults.classList.remove("hidden");
  } else {
    noResults.classList.add("hidden");
    filtered.forEach((article) => {
      const card = document.createElement("article");
      card.className = "sci-card article-card-anim";

      const color = categoryColors[article.category] || "#666";
      const langLabel = article.lang === "pt" ? "PT" : "EN";
      const authorNames = article.authors.map((a) => a.name).join(", ");

      card.innerHTML = `
        <span class="sci-card-category" style="background-color: ${color}20; color: ${color}; border: 1px solid ${color}40">${article.categoryLabel}</span>
        <span class="sci-card-lang">${langLabel}</span>
        <h2 class="sci-card-title">${article.title}</h2>
        <p class="sci-card-abstract">${article.abstract}</p>
        <div class="sci-card-authors">
          <span class="sci-card-author">${authorNames}</span>
        </div>
        <div class="sci-card-keywords">
          ${article.keywords
            .slice(0, 4)
            .map((kw) => `<span class="sci-card-keyword">${kw}</span>`)
            .join("")}
        </div>
        <div class="sci-card-meta">
          <span>${formatDate(article.date)}</span>
          <span>·</span>
          <span>${article.readTime} min leitura</span>
          <span>·</span>
          <span>${article.references.length} ref.</span>
        </div>
        <a href="artigo-cientifico.html?id=${article.id}" class="sci-card-link mt-4 inline-flex items-center gap-1 text-brand-accent font-semibold text-sm hover:underline">
          Ler artigo <span>→</span>
        </a>
      `;
      grid.appendChild(card);
    });
  }
}

document.addEventListener("DOMContentLoaded", () => {
  articles = sciData.scientificArticles;

  // Extract unique categories
  const catMap = new Map();
  articles.forEach((a) => {
    if (!catMap.has(a.category)) {
      catMap.set(a.category, a.categoryLabel);
    }
  });
  const categories = Array.from(catMap.entries()).map(([key, label]) => ({
    key,
    label,
  }));
  renderCategoryButtons(categories);

  // Language filter
  const langButtons = document.querySelectorAll(".sci-lang-btn");
  langButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      langButtons.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      currentLang = btn.dataset.lang;
      renderArticles();
    });
  });

  // Search
  const searchInput = document.getElementById("sci-search-input");
  if (searchInput) {
    searchInput.addEventListener("input", (e) => {
      searchTerm = e.target.value;
      renderArticles();
    });
  }

  renderArticles();
});
```

- [ ] **Step 2: Verificar que a página carrega**
      Run: `npm run dev`
      Navegar para `http://localhost:5173/cientificos.html` e confirmar que os 2 artigos de exemplo aparecem com filtros, busca e cards académicos.

- [ ] **Step 3: Commit**

```bash
git add src/scientific-articles-logic.js
git commit -m "feat: add scientific articles listing logic with filters and search"
```

---

## Task 7: Criar página de detalhe artigo-cientifico.html

**Files:**

- Create: `artigo-cientifico.html`

- [ ] **Step 1: Criar a página HTML completa**
      Criar `artigo-cientifico.html` com layout académico próprio — hero compacto, abstract box, conteúdo 2/3 + sidebar 1/3 com widget de citação e palavras-chave:

```html
<!doctype html>
<html lang="pt-BR">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Artigo Científico - Conheça Farmácia</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap"
      rel="stylesheet"
    />
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js"></script>
  </head>
  <body class="antialiased text-brand-deep bg-brand-bg">
    <!-- Header (mesmo padrão) -->
    <header class="header">
      <nav class="nav-container">
        <div class="logo">
          <a href="index.html"
            ><img
              src="assets/logo/logo-principal-verde.svg"
              alt="Conheça Farmácia Logo"
          /></a>
        </div>
        <div class="header-right">
          <button
            class="theme-toggle"
            aria-label="Alternar modo escuro"
            onclick="toggleTheme()"
          >
            <svg class="sun-icon" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="5"></circle>
              <line x1="12" y1="1" x2="12" y2="3"></line>
              <line x1="12" y1="21" x2="12" y2="23"></line>
              <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
              <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
              <line x1="1" y1="12" x2="3" y2="12"></line>
              <line x1="21" y1="12" x2="23" y2="12"></line>
              <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
              <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
            </svg>
            <svg class="moon-icon" viewBox="0 0 24 24">
              <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
            </svg>
          </button>
          <button class="hamburger" aria-label="Menu">
            <span></span><span></span><span></span>
          </button>
        </div>
      </nav>
    </header>

    <!-- Drawer (mesmo padrão) -->
    <div class="drawer-overlay" id="drawer-overlay"></div>
    <aside
      class="mobile-drawer"
      id="mobile-drawer"
      aria-label="Menu de navegação"
    >
      <button class="drawer-close" id="drawer-close" aria-label="Fechar menu">
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>
      <div class="drawer-logo">
        <a href="index.html"
          ><img
            src="assets/logo/logo-principal-verde.svg"
            alt="Conheça Farmácia Logo"
        /></a>
      </div>
      <ul class="drawer-links" id="drawer-links">
        <li><a href="index.html#inicio">Início</a></li>
        <li><a href="artigos.html">Artigos</a></li>
        <li><a href="eventos.html">Eventos</a></li>
        <li><a href="lives-list.html">Lives</a></li>
        <li><a href="sobre.html">Sobre Nós</a></li>
      </ul>
      <div class="drawer-footer">
        <button
          class="drawer-theme-toggle"
          aria-label="Alternar modo escuro"
          onclick="toggleTheme()"
        >
          <svg class="sun-icon" viewBox="0 0 24 24">
            <circle cx="12" cy="12" r="5"></circle>
            <line x1="12" y1="1" x2="12" y2="3"></line>
            <line x1="12" y1="21" x2="12" y2="23"></line>
            <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
            <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
            <line x1="1" y1="12" x2="3" y2="12"></line>
            <line x1="21" y1="12" x2="23" y2="12"></line>
            <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
            <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
          </svg>
          <svg class="moon-icon" viewBox="0 0 24 24">
            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
          </svg>
        </button>
        <div class="drawer-social">
          <a
            href="https://facebook.com/conhecafarmacia"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Facebook"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"
              /></svg
          ></a>
          <a
            href="https://instagram.com/conhecafarmacia"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Instagram"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z"
              /></svg
          ></a>
          <a
            href="https://linkedin.com/company/conhecafarmacia"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="LinkedIn"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 01-2.063-2.065 2.064 2.064 0 112.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"
              /></svg
          ></a>
          <a
            href="https://tiktok.com/conhecafarmaciaofficial"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="TikTok"
            ><svg viewBox="0 0 24 24" fill="currentColor">
              <path
                d="M12.525.02c1.31-.02 2.61-.01 3.91-.02.08 1.53.63 2.91 1.75 3.93 1.12 1.04 2.57 1.56 4.07 1.6v3.88c-1.37-.04-2.69-.39-3.86-1.03-.61-.34-1.17-.77-1.69-1.24v8.48c.02 2.01-.48 3.99-1.52 5.72-1.54 2.56-4.17 4.35-7.08 4.75-2.36.34-4.86-.14-6.91-1.42-2.5-1.55-4.21-4.24-4.49-7.18-.04-.36-.06-.72-.07-1.08.01-2.3.83-4.59 2.37-6.3 1.72-1.93 4.25-3.09 6.85-3.15v3.89c-1.71.18-3.29 1.14-4.26 2.52-.84 1.18-1.22 2.67-1.04 4.11.22 1.8 1.28 3.46 2.85 4.42 1.43.88 3.24 1.09 4.84.56 1.31-.43 2.43-1.34 3.14-2.52.54-.88.82-1.91.84-2.95V.03h-1.63z"
              /></svg
          ></a>
        </div>
      </div>
    </aside>

    <main>
      <!-- Article Header -->
      <section class="article-hero">
        <div class="container-center">
          <div class="flex items-center gap-3 mb-6">
            <a
              href="cientificos.html"
              class="text-sm text-brand-accent hover:underline"
              >← Artigos Científicos</a
            >
          </div>
          <div class="mb-4 flex items-center gap-3">
            <span id="sci-category" class="article-tag"></span>
            <span id="sci-lang-badge" class="sci-card-lang"></span>
          </div>
          <h1 id="sci-title" class="article-hero-title mb-6"></h1>
          <div
            id="sci-authors-meta"
            class="flex flex-wrap items-center gap-4 text-sm text-brand-deep/60 mb-4"
          >
            <!-- Authors rendered by JS -->
          </div>
          <div class="flex items-center gap-4 text-sm text-brand-deep/60">
            <span id="sci-date"></span>
            <span>·</span>
            <span id="sci-readtime"></span>
          </div>
        </div>
      </section>

      <!-- Abstract -->
      <section class="article-content-section">
        <div class="container-center">
          <div class="sci-abstract-box">
            <div class="sci-abstract-title">Abstract</div>
            <p id="sci-abstract" class="sci-abstract-text"></p>
          </div>

          <!-- Keywords -->
          <div class="sci-keywords-section">
            <div class="sci-keywords-label">Palavras-chave</div>
            <div id="sci-keywords" class="sci-keywords-list">
              <!-- Keywords rendered by JS -->
            </div>
          </div>

          <!-- Authors Grid -->
          <h2 class="section-title mb-6">Autores</h2>
          <div id="sci-authors-grid" class="sci-authors-grid mb-12">
            <!-- Author cards rendered by JS -->
          </div>
        </div>
      </section>

      <!-- Article Body + Sidebar -->
      <section class="article-content-section">
        <div class="container-center">
          <div class="article-grid">
            <!-- Main Content -->
            <div class="article-body-wrapper">
              <div id="sci-body" class="sci-article-body"></div>
            </div>

            <!-- Sidebar: Citation Widget -->
            <aside class="article-sidebar">
              <div class="sci-citation-widget">
                <div class="sci-citation-title">Citar este artigo</div>
                <div class="sci-citation-tabs" id="citation-tabs">
                  <button
                    class="sci-citation-tab active"
                    data-citation-style="abnt"
                  >
                    ABNT
                  </button>
                  <button class="sci-citation-tab" data-citation-style="apa">
                    APA
                  </button>
                  <button
                    class="sci-citation-tab"
                    data-citation-style="vancouver"
                  >
                    Vancouver
                  </button>
                </div>
                <div id="sci-citation-text" class="sci-citation-text"></div>
                <button id="sci-citation-copy" class="sci-citation-copy-btn">
                  <svg
                    class="w-4 h-4"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2"
                  >
                    <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
                    <path
                      d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"
                    />
                  </svg>
                  Copiar citação
                </button>
              </div>

              <!-- Sidebar: Quick Links -->
              <div class="sci-citation-widget mt-6">
                <div class="sci-citation-title">Neste artigo</div>
                <div id="sci-toc" class="space-y-2">
                  <!-- Table of contents rendered by JS -->
                </div>
              </div>
            </aside>
          </div>
        </div>
      </section>

      <!-- References -->
      <section
        id="sci-references-section"
        class="article-references-section"
        style="display: none"
      >
        <div class="container-center">
          <h2 class="section-title mb-12">Referências</h2>
          <div id="sci-references" class="sci-references-list"></div>
        </div>
      </section>

      <!-- Back CTA -->
      <section class="py-16 bg-brand-bg-alt">
        <div class="container-center text-center">
          <a href="cientificos.html" class="btn btn-primary"
            >← Voltar para Artigos Científicos</a
          >
        </div>
      </section>
    </main>

    <!-- Footer (mesmo padrão) -->
    <footer class="footer">
      <div class="container-center">
        <div class="footer-grid">
          <div class="footer-logo">
            <img
              src="assets/logo/logo-principal-branco.svg"
              alt="Conheça Farmácia Logo"
            />
            <p class="text-white/70 text-sm mt-4">
              Conhecimento que conecta. Formação que transforma. Saúde que
              evolui.
            </p>
          </div>
          <div class="footer-links">
            <h4>Navegação</h4>
            <ul>
              <li><a href="index.html#inicio">Início</a></li>
              <li><a href="artigos.html">Artigos</a></li>
              <li><a href="eventos.html">Eventos</a></li>
              <li><a href="lives-list.html">Lives</a></li>
              <li><a href="sobre.html">Sobre Nós</a></li>
            </ul>
          </div>
          <div class="footer-links">
            <h4>Contato</h4>
            <ul class="text-sm text-white/70">
              <li>Luanda, Angola</li>
              <li>
                <a
                  href="mailto:conhecerfarmacia@gmail.com"
                  class="text-white/70 hover:text-brand-accent"
                  >conhecerfarmacia@gmail.com</a
                >
              </li>
              <li>
                <a
                  href="https://wa.me/244925696002"
                  class="text-white/70 hover:text-brand-accent"
                  >+244 925 696 002</a
                >
              </li>
            </ul>
          </div>
          <div class="footer-links">
            <h4>Redes Sociais</h4>
            <ul class="text-sm">
              <li>
                <a
                  href="https://www.facebook.com/conhecafarmacia"
                  target="_blank"
                  >Facebook</a
                >
              </li>
              <li>
                <a
                  href="https://www.instagram.com/conhecafarmacia"
                  target="_blank"
                  >Instagram</a
                >
              </li>
              <li>
                <a
                  href="https://www.tiktok.com/conhecafarmaciaofficial"
                  target="_blank"
                  >TikTok</a
                >
              </li>
              <li>
                <a
                  href="https://www.linkedin.com/company/conhecafarmacia"
                  target="_blank"
                  >LinkedIn</a
                >
              </li>
            </ul>
          </div>
        </div>
        <div class="footer-divider"></div>
        <div class="footer-bottom">
          <p>&copy; 2026 Conheça Farmácia. Todos os direitos reservados.</p>
        </div>
      </div>
    </footer>

    <script type="module" src="/main.js"></script>
    <script type="module" src="/src/scientific-article-detail.js"></script>
  </body>
</html>
```

- [ ] **Step 2: Commit**

```bash
git add artigo-cientifico.html
git commit -m "feat: add scientific article detail page (artigo-cientifico.html)"
```

---

## Task 8: Criar lógica de detalhe scientific-article-detail.js

**Files:**

- Create: `src/scientific-article-detail.js`

- [ ] **Step 1: Implementar a lógica completa**
      Criar `src/scientific-article-detail.js`:

```javascript
import sciData from "./content/scientific-articles-catalog.json";
import { formatCitation, copyToClipboard } from "./lib/citation-formatter.js";

const categoryColors = {
  "farmacologia-clinica": "#0a844f",
  "saude-publica": "#006171",
  farmacovigilancia: "#ff6c23",
  "educacao-farmaceutica": "#002a32",
  fitoterapia: "#6b7280",
};

let currentCitationStyle = "abnt";
let currentArticle = null;

function formatDate(dateStr) {
  const date = new Date(dateStr);
  return date.toLocaleDateString("pt-PT", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
}

function renderArticle(article) {
  // Category badge
  const color = categoryColors[article.category] || "#666";
  const categoryEl = document.getElementById("sci-category");
  categoryEl.className = "article-tag";
  categoryEl.style.cssText = `background-color: ${color}20; color: ${color}; border: 1px solid ${color}40`;
  categoryEl.textContent = article.categoryLabel;

  // Language badge
  const langBadge = document.getElementById("sci-lang-badge");
  langBadge.textContent = article.lang === "pt" ? "PT" : "EN";

  // Title
  document.getElementById("sci-title").textContent = article.title;

  // Authors meta (inline)
  const authorsMeta = document.getElementById("sci-authors-meta");
  authorsMeta.innerHTML = article.authors
    .map(
      (a) =>
        `<span class="font-medium">${a.name}</span><span class="text-brand-deep/40">${a.institutionLabel}</span>`
    )
    .join('<span class="text-brand-deep/30 mx-1">·</span>');

  // Date + readtime
  document.getElementById("sci-date").textContent = formatDate(article.date);
  document.getElementById("sci-readtime").textContent =
    `${article.readTime} min leitura`;

  // Abstract
  document.getElementById("sci-abstract").textContent = article.abstract;

  // Keywords
  const keywordsContainer = document.getElementById("sci-keywords");
  keywordsContainer.innerHTML = article.keywords
    .map((kw) => `<span class="sci-keyword-tag">${kw}</span>`)
    .join("");

  // Authors grid
  const authorsGrid = document.getElementById("sci-authors-grid");
  authorsGrid.innerHTML = article.authors
    .map(
      (a) => `
    <div class="sci-author-card">
      <div class="sci-author-avatar" style="background-color: ${a.avatarBg}">${a.avatar}</div>
      <div class="sci-author-info">
        <div class="sci-author-name">${a.name}</div>
        <div class="sci-author-affiliation">${a.institutionLabel}${a.department ? ", " + a.department : ""}</div>
        <div class="text-xs text-brand-deep/40 mt-0.5">${a.role}</div>
        ${a.corresponding ? '<div class="sci-author-corresponding">✉ Autor correspondente</div>' : ""}
      </div>
    </div>
  `
    )
    .join("");

  // Article body (Markdown → sanitized HTML)
  const rawHtml = marked.parse(article.content);
  const safeHtml = DOMPurify.sanitize(rawHtml, {
    ALLOWED_TAGS: [
      "b",
      "i",
      "em",
      "strong",
      "p",
      "br",
      "h1",
      "h2",
      "h3",
      "h4",
      "h5",
      "h6",
      "ul",
      "ol",
      "li",
      "blockquote",
      "code",
      "pre",
      "a",
      "img",
      "table",
      "thead",
      "tbody",
      "tr",
      "th",
      "td",
    ],
    ALLOWED_ATTR: ["href", "src", "alt", "title", "target"],
  });
  document.getElementById("sci-body").innerHTML = safeHtml;

  // Table of contents (from h2 headings)
  const bodyEl = document.getElementById("sci-body");
  const headings = bodyEl.querySelectorAll("h2");
  const tocEl = document.getElementById("sci-toc");
  tocEl.innerHTML = "";
  headings.forEach((h, i) => {
    const id = `sci-section-${i}`;
    h.id = id;
    const link = document.createElement("a");
    link.href = `#${id}`;
    link.className =
      "block text-sm text-brand-deep/60 hover:text-brand-accent transition-colors py-1";
    link.textContent = h.textContent;
    tocEl.appendChild(link);
  });

  // References
  const refSection = document.getElementById("sci-references-section");
  const refList = document.getElementById("sci-references");
  if (article.references && article.references.length > 0) {
    refSection.style.display = "block";
    refList.innerHTML = article.references
      .map(
        (ref, i) => `
      <div class="sci-reference-item">
        <span class="sci-reference-number">${i + 1}.</span>
        <span class="sci-reference-text">${ref}</span>
      </div>
    `
      )
      .join("");
  } else {
    refSection.style.display = "none";
  }

  // Citation widget
  updateCitation(article);

  // Page title
  document.title = `${article.title} - Conheça Farmácia`;

  // SEO Acadêmico: Highwire Press meta tags (para Google Scholar)
  injectScholarMetaTags(article);
}

/**
 * Injeta Highwire Press meta tags no <head> para indexacao
 * pelo Google Scholar e outros motores de busca academicos.
 * Estas tags sao o padrao de facto que o Google Scholar usa
 * para identificar e indexar artigos cientificos.
 */
function injectScholarMetaTags(article) {
  // Remove tags anteriores (caso navegue entre artigos sem reload)
  document
    .querySelectorAll('meta[name^="citation_"]')
    .forEach((m) => m.remove());

  const tags = [
    { name: "citation_title", content: article.title },
    {
      name: "citation_publication_date",
      content: article.date.replace(/-/g, "/"),
    },
    { name: "citation_journal_title", content: "Conheça Farmácia" },
    { name: "citation_language", content: article.lang === "pt" ? "pt" : "en" },
    { name: "citation_publisher", content: "Conheça Farmácia" },
  ];

  // Um meta tag por autor (Google Scholar requer um tag por autor)
  article.authors.forEach((author) => {
    tags.push({ name: "citation_author", content: author.name });
  });

  // DOI (se existir)
  if (article.doi) {
    tags.push({ name: "citation_doi", content: article.doi });
  }

  // Keywords
  article.keywords.forEach((kw) => {
    tags.push({ name: "citation_keywords", content: kw });
  });

  // Inserir no <head>
  tags.forEach(({ name, content }) => {
    const meta = document.createElement("meta");
    meta.name = name;
    meta.content = content;
    document.head.appendChild(meta);
  });
}

function updateCitation(article) {
  const citationText = document.getElementById("sci-citation-text");
  citationText.textContent = formatCitation(article, currentCitationStyle);
}

function initCitationTabs(article) {
  const tabs = document.querySelectorAll(".sci-citation-tab");
  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      tabs.forEach((t) => t.classList.remove("active"));
      tab.classList.add("active");
      currentCitationStyle = tab.dataset.citationStyle;
      updateCitation(article);
    });
  });

  // Copy button
  const copyBtn = document.getElementById("sci-citation-copy");
  copyBtn.addEventListener("click", async () => {
    const citationText =
      document.getElementById("sci-citation-text").textContent;
    const success = await copyToClipboard(citationText);
    if (success) {
      copyBtn.classList.add("copied");
      const originalHTML = copyBtn.innerHTML;
      copyBtn.innerHTML = `<svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg> Copiado!`;
      setTimeout(() => {
        copyBtn.classList.remove("copied");
        copyBtn.innerHTML = originalHTML;
      }, 2000);
    }
  });
}

async function loadArticle() {
  const params = new URLSearchParams(window.location.search);
  const articleId = params.get("id");

  if (!articleId) {
    ErrorHandler.handle(
      new Error("ID do artigo não fornecido"),
      "PAGE",
      "Artigo não encontrado"
    );
    return;
  }

  try {
    const article = sciData.scientificArticles.find((a) => a.id == articleId);

    if (!article) {
      ErrorHandler.handle(
        new Error(`Artigo com ID ${articleId} não encontrado`),
        "PAGE",
        "Artigo não encontrado"
      );
      return;
    }

    currentArticle = article;
    renderArticle(article);
    initCitationTabs(article);
  } catch (error) {
    ErrorHandler.handle(error, "PAGE", "Desculpe, artigo não disponível");
  }
}

document.addEventListener("DOMContentLoaded", loadArticle);
```

- [ ] **Step 2: Verificar que a página de detalhe funciona**
      Run: `npm run dev`
      Navegar para `http://localhost:5173/artigo-cientifico.html?id=sc001-farmacovigilancia-angola` e confirmar:
  - Título, abstract, autores com afiliações
  - Keywords como tags clicáveis
  - Conteúdo Markdown renderizado
  - Widget de citação com tabs ABNT/APA/Vancouver
  - **Citações sem DOI** mostram URL como fallback (ABNT: "Disponível em: <URL>", APA: URL, Vancouver: "Available from: URL")
  - Botão copiar funciona
  - Tabela de conteúdo (TOC) no sidebar
  - Referências no final
  - **SEO Acadêmico:** Inspecionar o `<head>` no DevTools e confirmar que existem meta tags `citation_title`, `citation_author`, `citation_publication_date`, `citation_journal_title`, `citation_language`, `citation_keywords`

- [ ] **Step 3: Testar o artigo em inglês**
      Navegar para `http://localhost:5173/artigo-cientifico.html?id=SC002-antibiotic-resistance-angola` e confirmar que o badge "EN" aparece.

- [ ] **Step 4: Commit**

```bash
git add src/scientific-article-detail.js
git commit -m "feat: add scientific article detail logic with citations and TOC"
```

---

## Task 9: Verificar build de produção e responsividade

**Files:**

- Nenhum ficheiro novo (validação)

- [ ] **Step 1: Build de produção**
      Run: `npm run build`
      Expected: Build conclui sem erros.

- [ ] **Step 2: Preview de produção**
      Run: `npm run preview`
      Verificar as 4 páginas no preview:
  - `artigos.html` — banner aparece correctamente
  - `cientificos.html` — cards académicos, filtros, busca
  - `artigo-cientifico.html?id=sc001-farmacovigilancia-angola` — layout académico completo
  - `artigo-cientifico.html?id=SC002-antibiotic-resistance-angola` — artigo EN

- [ ] **Step 3: Verificar responsividade**
      Em cada página, testar viewports:
  - Mobile (320px-480px): sidebar empilha abaixo do conteúdo
  - Tablet (768px): layout 2 colunas
  - Desktop (1024px+): layout completo com sidebar

- [ ] **Step 4: Verificar dark mode**
      Alternar dark mode em cada página e confirmar que os estilos `.sci-*` aplicam correctamente.

- [ ] **Step 5: Commit final (se houver correcções)**

```bash
git add -A
git commit -m "fix: responsive and dark mode adjustments for scientific articles"
```

---

## Tarefas Futuras (fora do escopo deste plano)

Estes itens foram identificados como desejáveis mas **não implementados nesta fase**:

1. **DOI** — campo `doi` já existe no schema JSON, fica vazio. As citações já usam URL como fallback quando DOI não existe. Adicionar validação e link quando houver registo DOI. A meta tag `citation_doi` só é injetada quando o DOI existe.
2. **PDF Download** — futuro: upload manual de PDFs para Supabase Storage + botão de download.
3. **Migração para Supabase** — quando o volume justificar, migrar `scientific-articles-catalog.json` para tabela Supabase com RLS.
4. **Peer Review visível** — adicionar campo `reviewers` no schema e secção visual quando necessário.
5. **Submissão por autores externos** — formulário de submissão com Edge Function de validação.
6. **Busca textual avançada** — implementar quando migrar para Supabase (Full Text Search).
7. **Filtro por instituição** — o campo `institution` (ID normalizado) e `institutionLabel` já existem no schema. Futuramente, permitir filtrar artigos por instituição dos autores (ex: "Ver todos os artigos de investigadores da Universidade de Luanda").

---

## Self-Review Checklist

**1. Spec coverage:**

- [x] Sub-página dentro de Artigos (banner em artigos.html) → Task 3
- [x] Listagem com cards académicos → Tasks 5-6
- [x] Página de detalhe dedicada → Tasks 7-8
- [x] Sidebar própria (citações, keywords, TOC) → Task 7-8
- [x] Citações ABNT/APA/Vancouver com fallback URL quando DOI vazio → Task 2 + 8
- [x] Suporte bilingue PT/EN → Task 6 (filtro) + Task 8 (badge)
- [x] Múltiplos autores com afiliações estruturadas (institution + department) → Task 1 (schema) + Task 8 (authors grid)
- [x] JSON agora, Supabase depois → Task 1 (schema preparado)
- [x] Abstract, keywords, referências → Tasks 7-8
- [x] SEO Académico: Highwire Press meta tags para Google Scholar → Task 8
- [x] Afiliações estruturadas: institution (slug) + institutionLabel + department → Task 1 (schema)
- [x] Citações com DOI fallback para URL → Task 2
- [x] Dark mode → Task 4
- [x] Responsividade → Task 9

**2. Placeholder scan:** Nenhum TBD/TODO encontrado. Todos os passos têm código completo.

**3. Type consistency:**

- `article.id` usado consistentemente em `scientific-articles-catalog.json`, `scientific-articles-logic.js`, e `scientific-article-detail.js`
- `article.authors` é sempre um array com `{name, institution, institutionLabel, department, affiliation, role, avatar, avatarBg, corresponding}`
- `formatCitation(article, style)` — `article` segue o mesmo schema em todo o plano; `doi` vazio → URL como fallback
- `categoryColors` — mesmas chaves em ambos os ficheiros JS
- `injectScholarMetaTags(article)` — usa `article.title`, `article.date`, `article.lang`, `article.doi`, `article.authors[].name`, `article.keywords[]` — todos definidos no schema da Task 1
