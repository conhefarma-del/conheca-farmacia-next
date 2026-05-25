# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

```bash
# Dev server (hot-reload, http://localhost:5173)
npm run dev

# Production build + post-build admin relocate
npm run build
npm run preview

# Format code
npm run format
```

## Project Architecture

### Core Technologies

- **Framework**: Vite (ES modules, HMR)
- **Styling**: Tailwind CSS v4 (`@tailwindcss/vite` plugin)
- **Backend**: Supabase (PostgreSQL, Auth, RLS, Edge Functions)
- **CMS**: Admin panel (`src/admin/`) for articles, events, lives management
- **i18n**: PT/EN support via `src/i18n.js` + `public/i18n/*.json`
- **State**: Vanilla JavaScript (no framework)

### Directory Structure

```
├── index.html                  # Homepage
├── pesquisa.html               # Global search page
├── artigos.html / artigo.html  # Article list + detail
├── eventos.html / evento.html  # Event list + detail
├── lives-list.html / lives.html# Lives list + detail
├── inscricao.html              # Registration form
├── sobre.html                  # About page
├── unsubscribe.html            # Newsletter unsubscribe
├── 404.html                    # Error page
├── main.js                     # Vite entry: CSS, script, dark-mode, analytics, i18n
├── vite.config.js              # Vite config with rollupOptions.input
├── netlify.toml                # Deploy config, redirects, CSP headers
│
├── src/
│   ├── input.css               # Tailwind directives + all custom CSS (@layer)
│   ├── config.js               # Supabase client (persistSession: true for admin)
│   ├── script.js               # Global nav, hamburger, search redirect, lang dropdown
│   ├── dark-mode.js            # Theme toggle (sun-icon/moon-icon)
│   ├── i18n.js                 # i18n system (fetches /i18n/{lang}.json)
│   ├── hero-animated.js        # Hero ticker animation (homepage)
│   ├── breadcrumb.js           # Breadcrumb navigation
│   ├── pesquisa-logic.js       # Search page logic (client-side pagination)
│   ├── articles-logic.js       # Articles listing
│   ├── article-detail.js       # Article detail rendering
│   ├── events-logic.js         # Events listing
│   ├── event-detail.js         # Event detail rendering
│   ├── lives-logic.js          # Lives listing
│   ├── live-detail.js          # Live detail rendering
│   ├── inscription-logic.js    # Registration form logic
│   ├── inscription-handler.js  # Registration button handlers
│   ├── inscription-validation.js# Form validation
│   ├── unsubscribe.js          # Unsubscribe logic
│   ├── home-articles-logic.js  # Homepage featured articles
│   ├── home-events-logic.js    # Homepage featured events
│   │
│   ├── lib/
│   │   ├── api.js              # API layer: getArticles(), getEvents(), getLives()
│   │   ├── search.js           # searchAllContent() — Supabase ilike, no server pagination
│   │   ├── security.js         # escapeHtml(), escapeAttr(), validateUrl()
│   │   ├── seo.js              # SEO helpers (meta, OG, JSON-LD)
│   │   ├── supabaseClient.js   # Shared Supabase client
│   │   ├── fallback-data.js    # Local JSON fallback
│   │   ├── analytics.js        # Page view tracking
│   │   ├── capacity-cache.js   # Capacity cache (15s TTL)
│   │   ├── polling.js          # Polling with cleanup + visibility detection
│   │   ├── newsletter.js       # Newsletter subscription
│   │   ├── sitemap.js          # Sitemap generator (build-time)
│   │   ├── admin-gate.js       # Secret questions gate for admin access
│   │   ├── error-handler.js    # Centralized error handling
│   │   └── logger.js           # Logging utility
│   │
│   └── admin/                  # CMS Admin (sidebar layout)
│       ├── index.html          # Login (split-screen redesign)
│       ├── dashboard.html      # Stats + activity feed
│       ├── artigos/            # CRUD articles
│       ├── eventos/            # CRUD events
│       ├── lives/              # CRUD lives
│       ├── definicoes.html     # Settings (2FA, profile, password)
│       ├── newsletter.html     # Newsletter subscriber management
│       └── styles/admin.css    # Admin-only CSS
│
├── public/
│   ├── i18n/                   # Translation files (pt.json, en.json)
│   └── logo/                   # Logo variants
│
└── supabase/
    ├── migrations/             # Database migrations (001-013+)
    └── functions/              # Edge Functions (validate-inscription, newsletter, etc.)
```

### Data Flow

1. **Content Sources**: Supabase (primary) + JSON fallback (`src/content/`)
2. **API Layer**: `src/lib/api.js` normalizes data (snake_case → camelCase)
3. **Rendering**: Detail pages use `getEventBySlug()`, `getArticleBySlug()`, etc.
4. **Admin CMS**: Creates/edits content → Supabase → Public site (read)
5. **Fallback**: If Supabase fails, uses local JSON

### Key Patterns

- **Header**: Utility bar (search icon → pesquisa.html, lang dropdown) + nav + theme toggle (sun-icon/moon-icon)
- **Mobile**: Hamburger → floating drawer with `id="drawer-links"`, push animation
- **Dark Mode**: `html.dark` class, CSS variables in `:root` and `html.dark`, toggle buttons use `.theme-toggle` (header) and `.drawer-theme-toggle` (drawer)
- **Search**: Button/Enter triggers search, 15 results per page, client-side pagination from cache, highlight matches with `<mark>`
- **Language**: Dropdown toggle with globe icon, localStorage persistence, `data-i18n` attributes on elements
- **CSS Layers**: `@layer base`, `@layer components` for main styles; search page styles outside layers (scoped to `.search-*` classes)
- **Admin**: All paths use relative (`./` or `../`), works in dev + production

## Lições Aprendidas (Erros a Evitar)

### 1. Edição de Ficheiros JavaScript

**Problema**: Quando editar funções em ficheiros JS, garantir que todas as chaves de abertura têm correspondente de fecho e não deixar código incompleto.

**Solução**: Validar sintaxe com `node --check` após cada edição:
```bash
node --check src/filename.js  # Deve retornar vazio (sem erros)
```

### 2. Substituição de Funções em Ficheiros Existentes

**Problema**: Ao substituir funções inteiras, o padrão de busca pode não ser exato devido a diferenças de whitespace, linhas em branco, ou comentários adjacentes.

**Solução**: Ler o ficheiro completo primeiro, identificar marcadores únicos, usar Python para substituições complexas, validar com `node --check` após edição.

### 3. Gerir Estado em Funções de Renderização

**Problema**: Adicionar botões "Show More/Show Less" requer referências a variáveis de estado e event listeners que persistem após re-renderização.

**Solução**: Evitar resize handlers que re-renderizam; se necessário usar debounce e limpar estado antes de re-renderizar.

### 4. Validação de Sintaxe Após Edição de Ficheiros JavaScript

**Problema**: Ficheiros JS com erro de sintaxe causam `Expected '}' but found 'EOF'` no Vite.

**Solução**: Após qualquer edição, validar e contar chaves:
```bash
node --check src/filename.js
python3 -c "content=open('src/filename.js').read(); print(f'Abertas: {content.count(\"{\")}, Fechadas: {content.count(\"}\")}')"
```

### 5. Configuração de Auth para Admin

**Problema**: Ciclo infinito de login no admin se `persistSession: false`.

**Solução**: `config.js` deve ter `persistSession: true` para admin CMS.

### 6. Edição de Ficheiros JavaScript - Adicionar Múltiplas Funções

**Problema**: Ao adicionar múltiplas funções, Edit tool com strings longas pode falhar devido a diferenças de whitespace.

**Solução**: Adicionar funções individualmente, validar com `node --check` após cada adição; se Edit tool falhar, usar Python.

### 7. Edição de Ficheiros CSS - Especificidade e Variáveis

**Problema**: Novos componentes CSS devem usar variáveis consistentes com o tema (`var(--admin-text)`, etc.) e considerar dark mode.

**Solução**: Ler CSS existente para identificar variáveis disponíveis, adicionar novos estilos no final com comentário de secção, testar em ambos os modos.

### 8. Import de Módulos em Ficheiros JavaScript

**Problema**: Módulos novos esquecem exports ou imports de dependências.

**Solução**: Criar módulo com exportação nomeada, importar dependências no topo, atualizar ficheiros que usam o módulo, validar sintaxe em todos os ficheiros modificados.

### 9. Validação de Sintaxe em Cadeia

**Problema**: Múltiplos ficheiros JS modificados podem ter erros que só aparecem no runtime.

**Solução**: Após editar múltiplos ficheiros, validar todos em sequência:
```bash
node --check src/lib/api.js && node --check src/lib/search.js && node --check src/script.js
```

### 10. Edição de Ficheiros HTML - Estrutura e IDs

**Problema**: IDs de elementos devem ser consistentes entre HTML, JavaScript e CSS.

**Solução**: Usar grep para verificar consistência de IDs, manter convenção `bloco-elemento-modificador`.

### 11. Criação de Ficheiros Novos

**Problema**: Ficheiros novos devem ter estrutura correta de módulo ES6 com exports nomeados.

**Solução**: Usar Write tool com conteúdo completo, validar com `node --check`, testar import noutro ficheiro.

### 12. Git - Lidar com Line Endings (CRLF vs LF)

No Windows, Git converte LF para CRLF automaticamente. Warnings são normais — não alterar manualmente.

### 13. Debounce em Event Listeners

**Problema**: Event listeners como `input` disparam a cada caractere, causando múltiplas chamadas de API.

**Solução**:
```javascript
let debounceTimer;
searchInput.addEventListener('input', (e) => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(async () => { /* ... */ }, 300);
});
```

### 14. XSS Protection em User Input

**Problema**: Mostrar conteúdo de pesquisa (títulos, nomes) pode injetar HTML malicioso.

**Solução**: Usar `escapeHtml()` de `security.js` antes de inserir no DOM:
```javascript
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
```

### 15. Estrutura de Planos e Tasks

**Problema**: Planos de implementação podem ter tasks desatualizadas.

**Solução**: Ler ficheiro do plano, verificar estado atual do código antes de implementar, usar TaskCreate/TaskUpdate para tracking.

### 16. Edição de Ficheiros JSON

**Problema**: Ficheiros JSON são sensíveis a aspas duplas, trailing commas, e não suportam comentários.

**Solução**: Validar com `JSON.parse()`:
```bash
node -e "JSON.parse(require('fs').readFileSync('package.json'))"
```

### 17. Edição de Ficheiros Markdown (.md)

**Problema**: Ficheiros Markdown podem ter links quebrados, formatação inconsistente.

**Solução**: Manter consistência com estilo existente, especificar linguagem em code blocks, validar links.

### 18. Edição de Ficheiros CSS - Estrutura e Especificidade

**Problema**: CSS duplicado no mesmo stylesheet causa conflitos imprevisíveis.

**Solução**: Consolidar seletores duplicados, usar variáveis CSS, adicionar comentários de secção, testar em ambos os modos (claro/escuro).

### 19. Vite Rollup Input - Estrutura de Diretórios no Build

**Problema**: Ficheiros em subdiretórios (ex: `src/admin/`) geram `dist/src/admin/` em vez de `dist/admin/`.

**Solução**: Usar passo pós-build no `package.json`:
```json
"build": "vite build && cp -r dist/src/admin dist/admin && rm -rf dist/src"
```

### 20. Vite 8 Plugin Hooks - closeBundle/writeBundle Podem Não Executar

Em Vite 8 (Rolldown), hooks `closeBundle()`/`writeBundle()` de plugins podem não executar. Usar scripts shell no `package.json` em vez de plugins para operações pós-build.

### 21. node -e com Strings Complexas Falha no Windows Bash

No Windows (Git Bash), `node -e` com scripts inline longos falha com exit code 127. Usar comandos shell nativos (`cp`, `rm`, `mv`) ou criar ficheiro `.js` separado.

### 22. Edição de Ficheiros CSS - CSS `@layer` Specificity

Selectors fora de `@layer` sobrescrevem regras dentro de `@layer`. Ao adicionar estilos page-specific (ex: filtros de pesquisa), scoping com classe pai (`.search-filters .filter-btn`) evita sobrescrever cores de categorias noutras páginas.

### 23. CSP — No Inline Scripts

Nunca usar `onclick=`, `onsubmit=`, inline `<script>` sem `type="module"`, ou `style=""`. Sempre usar `.addEventListener()` em ficheiros `.js` externos. CSP no Netlify bloqueia handlers inline.

### 24. Dark Mode Toggle Classes

SVG icons devem usar `class="sun-icon"` e `class="moon-icon"` (nunca `theme-icon-light`/`theme-icon-dark`). O drawer toggle é `<button class="drawer-theme-toggle">` diretamente, não envolvido em div.

### 25. Header/Footer Consistency

Todas as páginas públicas devem ter a mesma estrutura de header (utility bar, nav, theme toggle) e footer (`footer-grid`, `footer-logo`, logo branco, `footer-divider`, `footer-bottom`, `footer-admin-access`).

### 26. Hero Text Centering

`.hero-subtitle` tem `lg:text-left` no seu @apply. Páginas que precisam de texto centrado devem adicionar `text-center` diretamente no elemento `<p>`.

### 27. i18n Files

Traduções ficam apenas em `public/i18n/`. `src/i18n.js` faz fetch via `/i18n/{lang}.json`. Nunca criar cópias duplicadas em `src/i18n/`.

### 28. Language Dropdown

A utility bar usa um único botão com globo (`.lang-toggle`) com dropdown (`.lang-dropdown`). JavaScript no `script.js` faz toggle, click-outside-close, e troca de idioma com sync do localStorage. Todas as 12 páginas HTML devem ter a mesma estrutura de dropdown.

### 29. Search Page Architecture

- `src/lib/search.js`: Busca TODOS os resultados do Supabase (sem `range()`)
- `src/pesquisa-logic.js`: Paginação client-side (15/página) a partir de cache
- Pesquisa dispara apenas com Enter ou clique no botão (sem pesquisa em tempo real)
- Destaque de termos: `escapeHtml()` primeiro, depois `highlightTerms()` envolve em `<mark>`
- Busca por Enter/botão em todas as páginas: redirect da utility bar para `pesquisa.html`
