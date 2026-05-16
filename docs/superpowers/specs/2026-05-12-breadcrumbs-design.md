# Breadcrumbs — Design Spec

**Data:** 2026-05-12
**Status:** Aprovado pelo usuário

## Contexto

O site "Conheça Farmácia" tem páginas de detalhe (artigo, evento, live, inscrição) que o usuário acessa a partir de páginas de listagem. Atualmente não existe nenhuma forma de navegação contextual — o usuário não sabe onde está na hierarquia do site e precisa usar o botão "Voltar" do browser ou os links do rodapé. Breadcrumbs resolvem isso mostrando o caminho de navegação e permitindo voltar a qualquer nível anterior com um clique.

## Páginas Afetadas

Breadcrumbs aparecem APENAS nas páginas de detail/inscrição:

| Página         | Breadcrumb                                      | Níveis |
| -------------- | ----------------------------------------------- | ------ |
| artigo.html    | Início > Artigos > [Título do Artigo]           | 3      |
| evento.html    | Início > Eventos > [Título do Evento]           | 3      |
| lives.html     | Início > Lives > [Título da Live]               | 3      |
| inscricao.html | Início > Eventos > [Nome do Evento] > Inscrição | 4      |

**Páginas SEM breadcrumbs:** index.html, artigos.html, eventos.html, lives-list.html, sobre.html — páginas principais e de listagem.

## Hierarquia de Navegação

```
index.html (Início)
├── artigos.html (Artigos)
│   └── artigo.html?slug=... (Título do Artigo)
├── eventos.html (Eventos)
│   ├── evento.html?slug=... (Título do Evento)
│   └── inscricao.html?evento=... (Inscrição)
└── lives-list.html (Lives)
    └── lives.html?slug=... (Título da Live)
```

Nota: `inscricao.html` tem 4 níveis porque o usuário chega a partir de um evento específico. O 3º nível (nome do evento) é clicável e volta para `evento.html?slug=...`.

## Estilo Visual — Minimalista

- **Fonte:** `text-sm` (14px), `font-medium` (500) — mesmo padrão dos nav-links
- **Links:** `text-brand-accent` (verde `#0a844f` light / `#0d995f` dark), `hover:text-brand-primary`
- **Página atual (último nível):** `text-brand-deep/70` (cinza, não clicável)
- **Separador:** `>` em `text-brand-deep/40` (cinza claro)
- **Container:** `container-center`, `py-3`, sem fundo especial
- **Dark mode:** Automático via variáveis CSS existentes (`text-brand-accent`, `text-brand-deep/70` já flipam com `html.dark`). Não usa prefixo `dark:` do Tailwind — segue o padrão do projeto com `html.dark` + variáveis CSS.

## Comportamento Mobile

Em telas <768px (abaixo do breakpoint `md`):

- **Desktop (md+):** Mostra todos os níveis: `Início > Artigos > Título do Artigo`
- **Mobile (<md):** Trunca o primeiro nível com `...`: `... > Artigos > Título do Artigo`
- **Inscrição mobile:** `... > [Nome Evento] > Inscrição`

O "..." continua clicável e navega para Início (index.html).

## Links Clicáveis

Todos os níveis anteriores ao atual são clicáveis e navegam para a página correspondente:

- "Início" → index.html
- "Artigos" → artigos.html
- "Eventos" → eventos.html
- "Lives" → lives-list.html
- "Nome do Evento" (inscrição) → evento.html?slug=...
- O último nível (página atual) NÃO é link — apenas texto em cinza

## Arquitetura — Módulo JS Reutilizável

### Novo Arquivo

**`src/breadcrumb.js`** — Módulo reutilizável com função `renderBreadcrumb(levels)`

```javascript
export function renderBreadcrumb(levels) {
  // levels = [
  //   { label: "Início", href: "/index.html" },     // clicável
  //   { label: "Artigos", href: "/artigos.html" },  // clicável
  //   { label: "Título do Artigo" }                  // sem href = página atual
  // ]
  // Monta o HTML do breadcrumb e injeta no container #breadcrumb
}
```

### Arquivos Modificados

| Arquivo                  | Mudança                                                                                   |
| ------------------------ | ----------------------------------------------------------------------------------------- |
| artigo.html              | Adicionar `<nav id="breadcrumb" aria-label="Breadcrumb"></nav>` como 1º filho de `<main>` |
| evento.html              | Adicionar `<nav id="breadcrumb" aria-label="Breadcrumb"></nav>` como 1º filho de `<main>` |
| lives.html               | Adicionar `<nav id="breadcrumb" aria-label="Breadcrumb"></nav>` como 1º filho de `<main>` |
| inscricao.html           | Adicionar `<nav id="breadcrumb" aria-label="Breadcrumb"></nav>` como 1º filho de `<main>` |
| src/article-detail.js    | Importar e chamar `renderBreadcrumb()` após carregar artigo                               |
| src/event-detail.js      | Importar e chamar `renderBreadcrumb()` após carregar evento                               |
| src/live-detail.js       | Importar e chamar `renderBreadcrumb()` após carregar live                                 |
| src/inscription-logic.js | Importar e chamar `renderBreadcrumb()` após carregar dados do evento                      |
| src/input.css            | Adicionar estilos `.breadcrumb` em `@layer components`                                    |

### Padrões Existentes Reutilizados

- **`PAGE_SECTION_MAP`** em `src/script.js` — já define a hierarquia pai-filho das páginas
- **`normalizeToSection()`** em `src/script.js` — já trata das rewrites do Netlify
- **`container-center`** — classe existente para largura máxima e padding horizontal
- **Variáveis CSS** — `text-brand-accent`, `text-brand-deep`, etc. — já flipam em dark mode
- **JSON catalogs** — `articles-catalog.json`, `events-catalog.json`, `lives-catalog.json` — fornecem títulos e categorias

### Chamadas por Página

**article-detail.js:**

```javascript
import { renderBreadcrumb } from "./breadcrumb.js";
// Após carregar article:
renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Artigos", href: "/artigos.html" },
  { label: article.title },
]);
```

**event-detail.js:**

```javascript
import { renderBreadcrumb } from "./breadcrumb.js";
// Após carregar event:
renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Eventos", href: "/eventos.html" },
  { label: event.title },
]);
```

**live-detail.js:**

```javascript
import { renderBreadcrumb } from "./breadcrumb.js";
// Após carregar live:
renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Lives", href: "/lives-list.html" },
  { label: live.titulo },
]);
```

**inscription-logic.js:**

```javascript
import { renderBreadcrumb } from "./breadcrumb.js";
// Após carregar event:
renderBreadcrumb([
  { label: "Início", href: "/index.html" },
  { label: "Eventos", href: "/eventos.html" },
  { label: event.title, href: `/evento.html?slug=${event.slug}` },
  { label: "Inscrição" },
]);
```

## Acessibilidade

- Container: `<nav aria-label="Breadcrumb">` — identifica a navegação para screen readers
- Separadores: `<span aria-hidden="true">></span>` — decorativos, não lidos por screen readers
- Links: marcados com `<a>` com `href` válido
- Página atual: `<span aria-current="page">` — indica a página atual para screen readers
- Estrutura: lista ordenada `<ol>` com `<li>` para cada nível — semântica de sequência

## Verificação

1. Abrir artigo.html?slug=... → breadcrumb mostra "Início > Artigos > Título"
2. Clicar em "Início" → navega para index.html
3. Clicar em "Artigos" → navega para artigos.html
4. Página atual (último nível) não é clicável
5. Em mobile (<768px), "Início" é substituído por "..."
6. Ativar dark mode → breadcrumb adapta cores automaticamente
7. Repetir para evento.html, lives.html, inscricao.html
8. Na inscrição, clicar no nome do evento → volta para evento.html?slug=...
9. Páginas de listagem (artigos.html, eventos.html, lives-list.html) NÃO mostram breadcrumb
10. `npm run build` → sem erros
