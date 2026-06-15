# SEO Backlog — Remaining Gaps (deferred from 2026-06-15 audit)

> **Data:** 2026-06-15
> **Origem:** [`2026-06-15-seo-audit.md`](./2026-06-15-seo-audit.md)
> **Porquê:** Sprint 1 (Gaps 1, 5, 6, 7) foi commitada e pushed. Restam 5 itens — alguns de refactor amplo, outros de schema desconhecido. Documentados aqui para próximas sessões.

---

## ✅ Já entregues (Sprint 1 — 2026-06-15)

| Gap | Descrição | Commit |
|---|---|---|
| **Gap 1** | next/font/google (Inter + Fraunces) com `adjustFontFallback` | commitado |
| **Gap 5** | `sobre/page.js` typo hreflang (`/en/sobre` → `/en/about`) | commitado |
| **Gap 6** | Logos Header/MobileDrawer/Footer com `next/image` + `priority` | commitado |
| **Gap 7** | Description root copy única 120-160 chars PT com keywords | commitado |

## ❌ Skipped (decisão produto)

| Gap | Razão |
|---|---|
| **Gap 2** | Admin autenticado, RLS isola dados. User 2026-06-15: "admin não é público, não precisa de SEO". Hygiene defensiva nice-to-have, não crítico. |

---

## 📋 Backlog (5 itens)

### Gap 4 — Title `template` em root layout

**File:** `app/layout.js:24-31` (metadata export)

**Estado actual:** `title: { default: '...', template: '%s | Conheça Farmácia' }` foi adicionado no Sprint 1 (commit Gap 7), mas **detail pages ainda não foram refactoradas** para tirar proveito do template.

**Trabalho pendente:**
- Refactor em ~16 detail/list pages que fazem `${title} — Conheça Farmácia` manual.
- Trocar para devolver só o título base (e.g. `title: article.title` em vez de `title: \`${article.title} — Conheça Farmácia\``).
- Afecta: `app/[lang]/(public)/{artigos/[slug],articles/[slug],eventos/[slug],events/[slug],lives/[slug]}/page.js` (5 detail) + restantes pages com `title` explícito.

**Esforço:** 1h (refactor mecânico, mas em ~16 ficheiros — risco de inconsistência se não for exaustivo).

**Impacto:** SERP consistency — todos os títulos passam a ter o mesmo sufixo de marca.

**Como retomar:**
```bash
# Listar todos os ficheiros com title explícito
grep -rln "title:" app/\[lang\]/\(public\)/
# Para cada um, remover o "— Conheça Farmácia" / "| Conheça Farmácia" manual
```

---

### Gap 8 — Anti-FOUC inline script vs CSP

**File:** `app/layout.js:54-60` (após refactor Gap 7, linhas podem ter shifted)

```jsx
<script
  dangerouslySetInnerHTML={{
    __html: `(function(){try{var t=localStorage.getItem('theme');var d=t==='dark'||(!t&&matchMedia('(prefers-color-scheme:dark)').matches);if(d)document.documentElement.classList.add('dark')}catch(e){}})()`,
  }}
/>
```

**Problema:** CSP em `vercel.json` (e `next.config.mjs`) precisa permitir inline scripts OU ser refactorado para usar nonce/hash. Sem audit, não sei se CSP está `unsafe-inline` (vulnerável) ou strict (e este script é excluído, partindo o dark mode).

**Trabalho pendente:**
1. Auditar `vercel.json` e `next.config.mjs` para ver o `Content-Security-Policy` actual.
2. Se for `unsafe-inline` → migrar para nonce-based CSP (Next.js suporta via `headers().get('x-nonce')`).
3. Se for strict → confirmar que há exceção para este script específico (improvável, senão dark mode parte).

**Esforço:** 30min audit + 1-2h fix (se migrar para nonce).

**Impacto:** XSS surface reduction. Não é SEO — é security hygiene.

**Como retomar:**
```bash
# Ver CSP actual
cat vercel.json | grep -A 20 "Content-Security-Policy"
grep -A 5 "script-src" next.config.mjs
```

---

### Gap 9 — Metadata per-locale em `app/[lang]/layout.js`

**File:** `app/[lang]/layout.js:23-30`

**Estado actual:** Root layout define `openGraph.locale: 'pt_PT'` fixo. Detail pages em `/en/articles/[slug]` vão ter `locale: 'pt_PT'` (incorrecto para partilha em redes sociais EN).

**Trabalho pendente:**
1. Em `app/[lang]/layout.js`, exportar `generateMetadata` (em vez de `metadata` estático) que recebe `params.lang` e devolve:
   - `openGraph.locale: lang === 'pt' ? 'pt_PT' : 'en_US'`
   - `openGraph.alternateLocale: [lang === 'pt' ? 'en_US' : 'pt_PT']`
   - `description` PT vs EN (carregado de `lib/i18n.js` ou inline)
   - `title` localizado (e.g. "Conheça Farmácia — Articles, events and live sessions" para EN)
2. Confirmar que `title.template` em root layout é compatível com `generateMetadata` do lang layout (Next.js merge order: root → lang → page).

**Esforço:** 1-2h.

**Impacto:** i18n polish — FB/Twitter/LinkedIn cards em EN vão mostrar a descrição certa para o público EN.

**Como retomar:**
```bash
# Ver lang layout actual
cat app/\[lang\]/layout.js
# Ver dicionários PT/EN disponíveis
ls public/i18n/
```

---

### M2 — `live.data` typo em `app/sitemap.js:136`

**File:** `app/sitemap.js:136` (linha exacta a confirmar — pode ter shifted)

```js
const lastmod = t?.updated_at || live.updated_at || live.data || live.date
```

**Suspeita:** `live.data` é typo — provavelmente devia ser `live.start_date` ou `live.event_date`.

**Trabalho pendente:**
1. Confirmar schema da tabela `lives` no remote:
   ```sql
   SELECT column_name FROM information_schema.columns
   WHERE table_name = 'lives' AND column_name IN ('data', 'date', 'start_date', 'event_date');
   ```
2. Se coluna `data` existir → sem fix, fallback é legítimo.
3. Se não existir → sitemap está a dar `undefined` em `lastModified` para todas as lives (silenciosamente, Next.js omite a chave).

**Esforço:** 5min (1 query + 1 linha).

**Impacto:** Sitemap `lastmod` EN VEZ para lives — Google re-crawl menos frequente após updates.

**Como retomar:**
- User aplica a query no Supabase Dashboard SQL Editor (padrão established em 2026-06-15 — ver memory `user-splits-migration-and-push-parallel`).
- Coordinator recebe output → decide se `live.data` é typo ou legítimo.

---

### M3 — `t?.updated_at` fallback chain frágil

**File:** `app/sitemap.js` (mesma área do M2)

```js
const lastmod = t?.updated_at || live.updated_at || live.data || live.date
```

**Problema:** Cadeia de 4 fallbacks sugere desconhecimento do schema. M2 pode resolver a maioria. Mas o padrão repete-se provavelmente para `articles` e `events`.

**Trabalho pendente:**
1. Auditar `app/sitemap.js` inteiro para os fallbacks em cada secção (articles/events/lives).
2. Para cada um, confirmar no remote qual coluna é a fonte de verdade.
3. Refactor para single source of truth (e.g. helper `getLastModified(row, type)`).

**Esforço:** 30min.

**Impacto:** Sitemap correctness + manutenibilidade.

**Como retomar:** aplicar após M2 (M2 pode indicar a direcção).

---

## 🎯 Quick wins remanescentes

Se for preciso retomar em <= 30min:
- **M2** (5min, depende de user correr query SQL)
- **Gap 8 audit** (30min, sem fix — só levantar o que CSP actual permite)

## 🏗️ Refactors (>1h, agendar)

- **Gap 4** (1h, 16 ficheiros)
- **Gap 9** (1-2h, i18n polish)
- **M3** (30min, depende M2)

---

## 📊 Scorecard final (após Sprint 1 + backlog)

| Categoria | Antes | Depois Sprint 1 | Após backlog completo |
|---|---|---|---|
| 🔴 Críticos | 1 | 0 | 0 |
| 🟡 Médios | 5 | 3 (4, 5, 6 → 4) | 0 |
| 🟢 Menores | 3 | 2 (8, 9 → 2) | 0 |
| ❓ A confirmar | 2 (M2, M3) | 2 | 0 |

Sprint 1 cobriu 1 crítico (Gap 1) + 1 typo (Gap 5) + 1 polish (Gap 6) + 1 copy (Gap 7). Backlog claro para próximas sessões.
