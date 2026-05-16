# Active Nav Links Design

**Data:** 2026-05-11

## Contexto

O mobile drawer tem active state (border-radius + fundo) nos links, mas apresenta um bug no Netlify: o link "Início" fica ativo em todas as páginas. No localhost:5173 funciona correctamente. A causa é que o `netlify.toml` define redirects clean URL (ex: `/artigos` → `/artigos.html`, status 200), o que faz com que `window.location.pathname` seja `/artigos` em vez de `/artigos.html`. A função actual `setActiveDrawerLink()` compara `normalizedPath` com os hrefs dos links (que têm `.html`), falhando o matching no Netlify. Além disso, os nav-links desktop não têm active state nem hover visual. O utilizador quer:

1. Corrigir o bug do "Início" sempre ativo
2. Active state em **ambos** (drawer + desktop nav-links)
3. Sub-páginas devem herdar o active state da página pai (evento.html → "Eventos", lives.html → "Lives")
4. Estilo pill/fundo arredondado nos nav-links desktop (igual ao drawer)
5. Hover visual nos nav-links desktop

## Abordagem

**Corrigir JS + adicionar CSS** — reutilizar a função existente `setActiveDrawerLink()`, corrigir a lógica de matching e expandir para também marcar os nav-links desktop.

## Ficheiros a Modificar

| Ficheiro        | Mudança                                                                                                                                                    |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/script.js` | Corrigir `setActiveDrawerLink()`: usar mapa de páginas → secção pai; renomear para `setActiveNavLink()`; aplicar classe ativa nos nav-links desktop também |
| `src/input.css` | Adicionar `.nav-links a.nav-link-active` (pill/fundo), `.nav-links a:hover`, dark mode                                                                     |

Não se mexe nos HTMLs — tudo é dinâmico via JS.

## Detalhes de Implementação

### 1. JS: Corrigir e expandir active state (`src/script.js`)

Substituir a função `setActiveDrawerLink()` (linhas 9-30) por `setActiveNavLink()`:

```js
// Map page paths (both with and without .html) to their parent section link href
// Netlify serves clean URLs (e.g. /artigos instead of /artigos.html)
const PAGE_SECTION_MAP = {
  "index.html": "index.html",
  "": "index.html",
  "artigos.html": "artigos.html",
  artigos: "artigos.html",
  "artigo.html": "artigos.html",
  artigo: "artigos.html",
  "eventos.html": "eventos.html",
  eventos: "eventos.html",
  "evento.html": "eventos.html",
  evento: "eventos.html",
  "inscricao.html": "eventos.html",
  inscricao: "eventos.html",
  "lives-list.html": "lives-list.html",
  "lives-list": "lives-list.html",
  "lives.html": "lives-list.html",
  lives: "lives-list.html",
  "sobre.html": "sobre.html",
  sobre: "sobre.html",
};

function setActiveNavLink() {
  const currentPath = window.location.pathname;
  const normalizedPath = currentPath.replace(/^\//, "").replace(/#.*$/, "");
  const activeHref = PAGE_SECTION_MAP[normalizedPath] || null;

  // Drawer links
  const drawerLinksEl = document.getElementById("drawer-links");
  if (drawerLinksEl) {
    drawerLinksEl.querySelectorAll("a").forEach((link) => {
      const linkHref = link
        .getAttribute("href")
        .replace(/^\//, "")
        .replace(/#.*$/, "");
      if (activeHref && linkHref === activeHref) {
        link.classList.add("drawer-link-active");
      } else {
        link.classList.remove("drawer-link-active");
      }
    });
  }

  // Desktop nav links
  const navLinksEl = document.querySelector(".nav-links");
  if (navLinksEl) {
    navLinksEl.querySelectorAll("a").forEach((link) => {
      const linkHref = link
        .getAttribute("href")
        .replace(/^\//, "")
        .replace(/#.*$/, "");
      if (activeHref && linkHref === activeHref) {
        link.classList.add("nav-link-active");
      } else {
        link.classList.remove("nav-link-active");
      }
    });
  }
}
```

Atualizar a chamada no final do ficheiro (linha ~97): `setActiveDrawerLink()` → `setActiveNavLink()`.

### 2. CSS: Nav-links active + hover (`src/input.css`)

Adicionar após o bloco `html.dark .nav-links a` (linha 182):

```css
/* Desktop nav-links hover */
.nav-links a:hover {
  background: rgba(0, 73, 58, 0.06);
  border-radius: 10px;
}

/* Desktop nav-links active state (pill style) */
.nav-links a.nav-link-active {
  background: rgba(0, 73, 58, 0.12);
  color: var(--color-brand-primary);
  font-weight: 600;
  border-radius: 10px;
}

/* Dark mode nav-links active/hover */
html.dark .nav-links a:hover {
  background: rgba(255, 255, 255, 0.08);
}

html.dark .nav-links a.nav-link-active {
  background: rgba(255, 255, 255, 0.12);
  color: var(--color-brand-deep);
}

/* Drawer link active dark mode (missing) */
html.dark .drawer-links li a.drawer-link-active {
  background: rgba(255, 255, 255, 0.12);
  color: var(--color-brand-deep);
}
```

### 3. Regras de matching

| Página atual               | Link ativo |
| -------------------------- | ---------- |
| `index.html` ou path vazio | Início     |
| `artigos.html`             | Artigos    |
| `artigo.html`              | Artigos    |
| `eventos.html`             | Eventos    |
| `evento.html`              | Eventos    |
| `inscricao.html`           | Eventos    |
| `lives-list.html`          | Lives      |
| `lives.html`               | Lives      |
| `sobre.html`               | Sobre Nós  |

## Verificação

1. `npm run build` — sem erros
2. Abrir cada página no desktop e verificar que o nav-link correto tem fundo pill
3. Reduzir para mobile e verificar que o drawer link correto tem fundo + border-radius
4. Testar hover nos nav-links desktop
5. Testar dark mode em ambos
6. Confirmar que "Início" **não** fica ativo em artigos.html
