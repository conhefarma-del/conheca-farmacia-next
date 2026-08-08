# Páginas de Medicamentos (Lista + Detalhe) e Conteúdo Alargado das Interações — Implementation Plan

> **For agentic workers:** implementar por tarefas com checkboxes. Migrações SQL são
> aplicadas manualmente pelo utilizador no Supabase (o agente nunca executa migrações).

**Goal:** (1) Criar uma página de **listagem de fármacos** com pesquisa e 3 modos de
organização; (2) criar a **página dedicada por fármaco** com perfil (duas audiências) e
secção de interações; (3) alargar o conteúdo de cada interação fármaco-fármaco com um
**resumo profissional** e uma **explicação mais longa**, mantendo o resumo atual como
resumo do público.

**Contexto:** dados já existem em `public.drugs`, `public.drug_interactions`,
`public.drug_food_interactions`, `public.drug_disease_interactions`,
`public.drug_pregnancy_info`. Nota: o slug real da varfarina na BD é **`warfarina`**
(corrigido na migração 070 — o documento `INTERACOES_FLUXO_PESQUISA.md` usa `varfarina`,
que está desatualizado). O par warfarina×ibuprofeno **não existe** no seed — é criado
nesta migração (é o par-modelo do documento, com setIDs já validados).

---

## Nota sobre os resumos profissionais e leigos

| Campo | Público-alvo | Tom | Comprimento | Onde aparece |
|---|---|---|---|---|
| `summary_pt/en` (existente) | Público leigo | Sem jargão, sem siglas, linguagem do dia-a-dia | 1–2 frases | Cartão da interação (checker e página do fármaco) |
| `summary_pro_pt/en` (novo) | Profissionais de saúde | Terminologia técnica, classes, mecanismos | 1–2 frases | Expansor "Ver detalhes" e toggle "Profissionais" |
| `explanation_pt/en` (novo) | Ambos (leitura longa) | Autoral, ancorado nas fontes citadas | 2–4 frases (mecanismo + contexto clínico + orientação) | Primeiro bloco do expansor "Ver detalhes" |
| `drug_profiles.overview_public_*` (novo) | Público leigo | O que é, para que serve, como funciona | 2–3 frases | Página do fármaco, aba "Público" |
| `drug_profiles.overview_pro_*` (novo) | Profissionais | Indicações, classe, pontos de segurança | 2–3 frases | Página do fármaco, aba "Profissionais" |

Regra de ouro do fluxo existente (`INTERACOES_FLUXO_PESQUISA.md`): conteúdo **autoral**,
nunca copiado das fontes; citação real e clicável (setIDs validados na API DailyMed);
omissões honestas. A migração é **idempotente** (`ON CONFLICT DO NOTHING` nos INSERTs,
`WHERE LEAST/GREATEST` independente da ordem nos UPDATEs).

---

## Arquitetura

Rotas (padrão do projeto: `interacoes`/`interactions`, `protocolos`/`protocols`):

| Rota PT | Rota EN | Ficheiros |
|---|---|---|
| `/medicamentos` | `/medicines` | `app/[lang]/(public)/medicamentos/page.js` + `medicamentosPageClient.jsx`; `app/[lang]/(public)/medicines/page.js` reutiliza o client |
| `/medicamento/[slug]` | `/medicine/[slug]` | `app/[lang]/(public)/medicamento/[slug]/page.js` + `medicamentoDetailClient.jsx`; `app/[lang]/(public)/medicine/[slug]/page.js` reutiliza o client |

Padrões usados (iguais às rotas existentes): `export const dynamic = 'force-dynamic'`,
`generateMetadata` com `alternates`, `notFound()` quando o slug não existe, `LangContext`
para `t()` no client, `loading.jsx` em cada pasta de rota.

### Migração 079

1. **DDL em `public.drug_interactions`**: `ADD COLUMN summary_pro_pt, summary_pro_en,
   explanation_pt, explanation_en TEXT NOT NULL DEFAULT ''`.
2. **Nova tabela `public.drug_profiles`** (1:1 com `public.drugs`): `overview_public_pt/en`,
   `overview_pro_pt/en`, `source_pt/en`, `status`, `is_archived`, timestamps;
   `UNIQUE (drug_id)`, RLS `admin_all`/`anon_read`, trigger `updated_at`.
3. **Seed piloto**:
   - 6 perfis: warfarina, ibuprofeno, ramipril, espironolactona, sotalol, furosemida
     (setIDs dos rótulos já validados nas migrações 057/063/070).
   - **INSERT** do par novo warfarina×ibuprofeno (`moderate`, padrão 7.4 do documento,
     com os campos novos preenchidos).
   - **UPDATE** (padrão 7.1, `WHERE LEAST/GREATEST`) dos campos novos em 2 pares
     existentes: ramipril×espironolactona (`moderate`, hipercaliemia) e
     sotalol×furosemida (`critical`, torsades de pointes).

### Camada de dados

- `lib/actions/interacoes.js`: adicionar os 4 campos ao zod `drugInteractionSchema` e ao
  `select`/mapping de `getPublishedInteractions` (`summaryPro`, `explanation`).
- `lib/actions/medicamentos.js` (novo):
  - `getPublicDrugsWithInfo(lang)` — lista publicada: id, slug, name, className, aliases,
    `maxSeverity` (severidade máxima dos pares publicados, para o modo "risco").
  - `getPublicDrugBySlug(slug, lang)` — fármaco + perfil (ou `null`).
  - `getPublicDrugInteractionsForDrug(drugId, lang)` — pares fármaco-fármaco +
    alimento + doença + gestação desse fármaco (mesmas shapes do checker).

### UI

- **Lista** (`medicamentosPageClient`): pesquisa por nome/alias/classe (autocomplete);
  3 modos de organização: **alfabética** (A–Z), **grupo farmacológico** (cabeçalhos por
  `class`), **risco** (critical → moderate → minor → none → sem registo). Cards ligam a
  `/medicamento/[slug]`.
- **Detalhe** (`medicamentoDetailClient`): header (nome, classe, aliases) + **toggle
  "Público | Profissionais"** que alterna o `overview` do perfil; secção de interações
  fármaco-fármaco (cartões com resumo público + expansor com explicação e resumo
  profissional) e as 3 dimensões (alimento, doença, gestação).
- **Checker** (`interacoesPageClient.jsx`): no expansor do cartão fármaco-fármaco,
  adicionar blocos "Explicação" (primeiro) e "Resumo para profissionais"; `hasDetails`
  passa a incluir os campos novos.
- **Admin** (`DrugInteractionForm.jsx`): textareas novos
  (summary_pro PT/EN, explanation PT/EN) + payload.

### i18n (public/i18n/pt.json e en.json)

- `interacoes_page.explicacao`, `interacoes_page.resumo_profissionais`.
- Nova secção `medicamentos_page.*` e `medicamento_detalhe.*` (herói, pesquisa,
  organizar, modos, sem_resultados, toggle audiências, secções, voltar).

### Estilos (styles/globals.css)

- `.detail-explanation` (+ variante dark) para a explicação longa.
- Classes da lista (grelha de cards, cabeçalhos de grupo, chips de severidade) e do
  detalhe (toggle de audiência, secções), alinhadas com o design tokens existentes.

---

## Tarefas

- [ ] **T1 — Plano** (este documento).
- [ ] **T2 — Migração 079** `supabase/migrations/079_medicamentos_perfil_explicacao.sql`
  (DDL + RLS + trigger + seed piloto). Validação estrutural antes de entregar:
  `grep -c '^UPDATE public.drug_interactions'` = 2 e `grep -c '= LEAST((SELECT id'` = 4
  (2 UPDATEs × 2 linhas), zero ocorrências da forma antiga.
- [ ] **T3 — `lib/actions/interacoes.js`**: zod + `getPublishedInteractions`.
- [ ] **T4 — `lib/actions/medicamentos.js`** (novo): as 3 funções públicas.
- [ ] **T5 — i18n** pt/en (3 grupos de chaves).
- [ ] **T6 — Admin** `DrugInteractionForm.jsx`.
- [ ] **T7 — Checker** `interacoesPageClient.jsx` (blocos novos).
- [ ] **T8 — Rotas** lista e detalhe (PT + EN), clients e loading.
- [ ] **T9 — Estilos** `styles/globals.css`.
- [ ] **T10 — Validação**: `npx eslint` nas pastas alteradas e `npm run build`
  (ou o comando de verificação do projeto).
- [ ] **T11 — Entrega**: resumo das alterações + instruções para aplicar a migração 079
  manualmente no Supabase (o agente não executa migrações).

## Notas finais

- A reescrita em massa dos `summary_*` existentes para tom leigo fica **fora de escopo**
  (fluxo dedicado futuro); nesta fase mantêm-se e só os pares piloto ganham os campos novos.
- As 3 dimensões (alimento/doença/gestação) **não** ganham `summary_pro`/`explanation`
  nesta fase (fica para um fluxo posterior, seguindo a secção 12 do documento).
- Organização por **código ATC** fica como evolução futura (exige coluna nova + dados OMS);
  o modo "risco" é a 3.ª organização desta fase, derivada da severidade já existente.
