# Nav Links Active State — Bug no Netlify

## Problema Original

No `localhost:5173`, os nav links do header e do drawer mobile mostravam correctamente o estado **active** (classe `nav-link-active` / `drawer-link-active`) ao navegar entre páginas. No entanto, após deploy no Netlify, **nenhum nav link ficava active em nenhuma página** — tanto no desktop como no drawer mobile.

### Sintomas observados

- **Desktop**: hover funciona normalmente (feedback visual ao passar o rato), mas após clicar e navegar para a página, o link não fica marcado como active.
- **Drawer mobile**: o active não funciona de forma alguma no Netlify.
- **Localhost**: tudo funciona perfeitamente.

---

## Investigação

### 1. Verificação da lógica no código-fonte

A função `setActiveNavLink()` em `src/script.js` usava um `PAGE_SECTION_MAP` para mapear o `window.location.pathname` ao href do link que devia ficar active:

```js
// Lógica original (simplificada)
const normalizedPath = currentPath.replace(/^\//, "").replace(/#.*$/, "");
const activeHref = PAGE_SECTION_MAP[normalizedPath] || null;

// Comparação directa
if (activeHref && linkHref === activeHref) {
  link.classList.add("nav-link-active");
}
```

- `currentPath = "/artigos.html"` → `normalizedPath = "artigos.html"`
- `PAGE_SECTION_MAP["artigos.html"]` = `"artigos.html"`
- `linkHref = getAttribute("href")` → depende do que está no HTML

### 2. Simulação da lógica — tudo correto em teoria

Corremos simulações em Node.js com todos os cenários de pathname (`/artigos`, `/artigos.html`, `/`, `/index.html`, etc.) e **todos produziam o resultado esperado**. A lógica parecia correcta.

### 3. Verificação do build do Vite

Confirmámos que:

- O bundle `main-*.js` contém a função `setActiveNavLink()` completa
- O `PAGE_SECTION_MAP` está incluído no bundle com todas as chaves
- Todas as páginas importam o `main.js` (via `main-*.js` chunk partilhado)
- A chamada à função executa no top-level do módulo (depois do DOM estar pronto, pois é `type="module"`)

### 4. Comparação entre deploy que funcionava e o que quebrou

O deploy `2a3e776` (floating drawer) **funcionava** — usava `endsWith()` para matching:

```js
// Versão antiga que funcionava
if (href.endsWith(link.getAttribute("href"))) { ... }
```

O deploy `c60b166` (PAGE_SECTION_MAP) **quebrou** — usava comparação exacta:

```js
// Versão nova que quebrou
if (activeHref && linkHref === activeHref) { ... }
```

### 5. Descoberta da causa raiz — Netlify Post Processing

Ao comparar os hrefs no HTML **no dist local** vs **no site live do Netlify**, encontrámos a diferença:

| O que        | HTML no dist/              | HTML servido pelo Netlify |
| ------------ | -------------------------- | ------------------------- |
| Link Artigos | `href="artigos.html"`      | `href='/artigos'`         |
| Link Eventos | `href="eventos.html"`      | `href='/eventos'`         |
| Link Início  | `href="index.html#inicio"` | `href='/#inicio'`         |
| Link Sobre   | `href="sobre.html"`        | `href='/sobre'`           |

O **Netlify Post Processing** (Asset Optimization) reescreve automaticamente os hrefs no HTML deployado:

- Remove a extensão `.html`
- Adiciona `/` inicial (caminho absoluto)
- Altera aspas duplas para plicas

Isto causava a falha na comparação:

```
linkHref (depois da reescrita) = "artigos"     (sem .html, sem /)
activeHref (do PAGE_SECTION_MAP) = "artigos.html"  (com .html)
"artigos" !== "artigos.html" → NO MATCH!
```

### 6. Problema adicional — query strings não tratadas

As páginas de detalhe (`artigo.html?id=slug`, `evento.html?id=slug`) também falhavam porque o `normalizeToSection` original não removia `?query=strings`, resultando em `"artigo.html?id=slug"` — que não existia no MAP.

---

## Resolução

### Mudança principal — função `normalizeToSection()`

Criámos uma função de normalização que **ambos os lados** (pathname e linkHref) atravessam antes da comparação:

```js
// Normalize hrefs/paths to section keys — handles Netlify Post Processing which
// rewrites href="artigos.html" → href='/artigos' at deploy time
function normalizeToSection(href) {
  return href
    .replace(/^\//, "") // Remove / inicial
    .replace(/[?#].*$/, "") // Remove query strings e hashes
    .replace(/\.html$/, ""); // Remove extensão .html
}
```

### Comparação via MAP em ambos os lados

Em vez de comparar `linkHref === activeHref` directamente, **ambos são normalizados e depois mapeados pelo PAGE_SECTION_MAP**:

```js
function setActiveNavLink() {
  const normalizedPath = normalizeToSection(window.location.pathname);
  const activeHref = PAGE_SECTION_MAP[normalizedPath] || null;

  // Para cada link:
  const linkHref = normalizeToSection(link.getAttribute("href"));
  const linkSection = PAGE_SECTION_MAP[linkHref] || linkHref;
  if (activeHref && linkSection === activeHref) {
    link.classList.add("nav-link-active");
  }
}
```

Isto garante que, independentemente de o href ser `"artigos.html"` (localhost) ou `"/artigos"` (Netlify), ambos normalizam para `"artigos"` e mapeiam para `"artigos.html"` via MAP.

### Adição da chave `"index"` ao MAP

O href `index.html` normaliza para `"index"` (removida a extensão). Sem a chave `"index"` no MAP, o link "Início" nunca ficaria active:

```js
const PAGE_SECTION_MAP = {
  // Homepage
  "index.html": "index.html",
  index: "index.html", // ← Adicionado
  "": "index.html",
  // ... resto do MAP
};
```

---

## Cenários testados

| Cenário               | Pathname               | Link href           | normalizedPath | linkSection    | activeHref     | Match |
| --------------------- | ---------------------- | ------------------- | -------------- | -------------- | -------------- | ----- |
| Netlify artigos       | `/artigos`             | `/artigos`          | `artigos`      | `artigos.html` | `artigos.html` | ✓     |
| Netlify homepage      | `/`                    | `/#inicio`          | `""`           | `index.html`   | `index.html`   | ✓     |
| Localhost artigos     | `/artigos.html`        | `artigos.html`      | `artigos`      | `artigos.html` | `artigos.html` | ✓     |
| Localhost homepage    | `/index.html`          | `index.html#inicio` | `index`        | `index.html`   | `index.html`   | ✓     |
| Netlify artigo detail | `/artigo.html?id=slug` | `/artigos`          | `artigo`       | `artigos.html` | `artigos.html` | ✓     |
| Netlify evento detail | `/evento?id=slug`      | `/eventos`          | `evento`       | `eventos.html` | `eventos.html` | ✓     |

---

## Ficheiro alterado

- `src/script.js` — função `normalizeToSection()`, MAP actualizado com `"index"`, e `setActiveNavLink()` refactored

## Lição aprendida

O Netlify aplica **Post Processing** no HTML deployado que pode reescrever atributos como `href`, `src`, etc. — mesmo quando não configuramos explicitamente redirects. Qualquer lógica JS que dependa de comparar `getAttribute("href")` com valores esperados deve normalizar ambos os lados da comparação, assumindo que o HTML servido pode diferir do HTML no build.
