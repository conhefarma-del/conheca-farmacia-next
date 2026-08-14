# Ocultação de secções (Artigos Científicos e Protocolos Clínicos)

> Estado: **ocultas** (decisão com os parceiros, agosto 2026). Dados e rotas intactos — apenas os pontos de entrada foram removidos. Este documento explica o que foi ocultado, como funciona e **como voltar a ativar** quando a decisão mudar.

---

## 1. O que está oculto

| Secção | Rotas afetadas | Natureza |
|---|---|---|
| **Artigos Científicos** | `/cientificos`, `/cientificos/[slug]`, `/cientificos/autores`, `/cientificos/autores/[slug]`, `/autores/[slug]/perfil` | Ocultação temporária (volta) |
| **Protocolos Clínicos** | `/protocolos`, `/protocolos/[slug]` | Ocultação temporária (volta) |

**Regra transversal:** as rotas continuam a funcionar por URL direta (links antigos não quebram), os dados na BD mantêm-se intactos e não há migrações destrutivas. O conteúdo de protocolos continua a alimentar os quizzes de `/praticar` (é uso interno, não é ponto de entrada).

---

## 2. Pontos de entrada removidos

| Ponto de entrada | Científicos | Protocolos |
|---|---|---|
| Menu do header | ❌ removido | ❌ removido (submenu Ferramentas) |
| Drawer mobile | ❌ removido | ❌ removido |
| Footer (Ferramentas) | ❌ removido | ❌ removido |
| Homepage (ToolsShowcase) | ❌ card grande removido | ❌ card pequeno removido |
| Sitemap | ❌ listagem + autores + slugs | ❌ listagem + slugs |
| Pesquisa global (`/pesquisa`) | ❌ índice + filtro + destinos | ❌ índice + filtro |
| SEO | ❌ `robots: noindex` nas 4 rotas | ❌ `robots: noindex` nas 2 rotas |

**Layout da homepage sem as secções:** a Calculadora de Interações passa a ocupar a largura total (em vez de 2/3) e os cards pequenos ficam em 3 colunas (Praticar, Guias, Medicamentos).

---

## 3. Como funciona — `lib/features.js`

A fonte de verdade é **`lib/features.js`** (um ficheiro, sem dependências):

```js
export const FEATURES = {
  cientificos: false,   // Artigos Científicos (inclui /autores)
  protocolos: false,    // Protocolos Clínicos
}
export const featureEnabled = (key) => FEATURES[key] === true
```

Tudo o que foi ocultado **lê esta flag** em tempo de execução:

| Componente | Como lê |
|---|---|
| `Header.jsx`, `MobileDrawer.jsx`, `Footer.jsx` | entrada no array só se `featureEnabled(...)` |
| `ToolsShowcase.jsx` | cards + colunas da grelha calculados com a flag |
| `app/sitemap.js` | blocos de entries e paths removidos só se desligado |
| `lib/api/search.js` | queries de protocolos/científicos/autores não correm |
| `PesquisaPageClient.jsx` | tipos ocultos saem do índice, filtros e destinos |

---

## 4. Como voltar a ativar (2 minutos)

1. **`lib/features.js`** — mudar para `true`:

   ```js
   export const FEATURES = {
     cientificos: true,
     protocolos: true,
   }
   ```

   Com isto voltam automaticamente: menus (header, drawer, footer), cards da homepage (com o layout de 2/3 + 4 colunas), sitemap (entries estáticas + slugs dinâmicos + autores) e pesquisa (índice + filtros).

2. **Remover o `noindex`** das 6 rotas (ficou hardcoded no `generateMetadata`, não lê a flag):
   - `app/[lang]/(public)/cientificos/page.js`
   - `app/[lang]/(public)/cientificos/[slug]/page.js`
   - `app/[lang]/(public)/cientificos/autores/page.js`
   - `app/[lang]/(public)/cientificos/autores/[slug]/page.js`
   - `app/[lang]/(public)/protocolos/page.js`
   - `app/[lang]/(public)/protocolos/[slug]/page.js`

   Procurar a linha `robots: { index: false, follow: false },` e apagá-la (nas páginas de listagem, há também o comentário `// Secção oculta (lib/features.js) — não indexar`).

3. **Deploy** — depois do push, o Vercel regenera o sitemap e as páginas voltam a ser indexáveis.

> Nada mais é preciso: não há migrações, não há dados a repor, não há links a reescrever.

---

## 5. Relacionado — Lives fundidas em Eventos (eliminação, não ocultação)

Em paralelo, a página **`/lives` foi eliminada** (não é ocultação temporária — é uma fusão permanente): as lives/webinares passaram a ser **eventos** (categoria `live`/`webinar`, tipo `online`, com os campos de acesso e o toggle de inscrições). Ver `supabase/migrations/159_lives_merge_eventos.sql`. Links antigos `/lives` e `/lives/{slug}` fazem **redirect 301** para `/eventos` e `/eventos/{slug}`.

Por isso:
- `/lives` não aparece em lado nenhum (menus, sitemap, pesquisa) — **não se reativa via `lib/features.js`**;
- se algum dia quiserem um separador "Lives" de novo, será como um **filtro de categoria** dentro de `/eventos`, não como página própria.

---

## 6. Resumo rápido

| Pergunta | Resposta |
|---|---|
| As rotas dão 404? | Não — continuam acessíveis por URL direta |
| Os dados foram apagados? | Não — tudo intacto na BD |
| Como reativar? | `lib/features.js` → `true` + apagar o `noindex` das 6 rotas |
| As lives voltam? | Não — foram fundidas em eventos (permanente) |
| O quiz continua a usar protocolos? | Sim — é conteúdo interno, não afetado |
