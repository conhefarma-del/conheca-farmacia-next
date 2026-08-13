# Flashcards com Repetição Espaçada — Plano de Implementação (2026-08-13, v1)

> Plano baseado nos modelos de design em `_temp/design-demos/` (`flashcards.html`,
> `flashcards-deck.html`) e na análise de viabilidade feita em 2026-08-13.
> Os cartões ligam-se ao banco de dados de **Medicamentos** já existente
> (`drugs` + `drug_profiles` + `drug_pharmacology` + `atc_code`) — o conteúdo
> é gerado a partir dos dados reais, não escrito à mão do zero.

## Decisões a confirmar (antes da implementação)

| # | Pergunta | Opção recomendada | Alternativa |
|---|----------|-------------------|-------------|
| 1 | Onde vive o progresso de revisão? | **B — Supabase anonymous sign-in** (contas anónimas: progresso na cloud, pronto para contas reais; RLS por `auth.uid()`) | A — localStorage por dispositivo (mais simples, mas o progresso não acompanha entre aparelhos) |
| 2 | Decks: gerados automaticamente do ATC ou curados? | **Híbrido** — seed automático por prefixo ATC (`J01` → "Antibióticos", `C` → "Cardiovascular"...), com edição/adição manual no admin | Só manual no admin |
| 3 | Geração dos cartões | **Automática a partir dos dados** dos fármacos com perfil/farmacologia completos (tipos: mecanismo, classe, perfil, interação) + cartões manuais no admin | Só manuais (mais trabalho editorial) |
| 4 | Algoritmo | **SM-2** (ease, intervalos 1/6/15 dias + repetições, lapses) — simples, testado, sem dependências | FSRS (mais moderno, mas mais complexo) |

## Arquitetura

- **Público:** `/flashcards` (página principal: painel "para revisar hoje", decks, filtros e pesquisa) e `/flashcards/[slug]` (sessão de revisão com flip card). Rotas top-level, irmãs de `/interacoes`.
- **Admin:** `/admin/flashcards` (decks + cartões), `/admin/flashcards/decks/[id]`, `/admin/flashcards/cards/new` e `/admin/flashcards/cards/[id]` — com **geração assistida** (picker de fármaco → cartão pré-preenchido dos dados do perfil/farmacologia).
- **Dados:** 3 tabelas novas — `flashcard_decks`, `flashcards`, `flashcard_reviews` — padrão RLS do projeto.
- **Conteúdo:** os cartões **não duplicam** o conteúdo: guardam as perguntas/respostas geradas, mas ligam `drug_id` → página do Medicamento ("Ver perfil") e a interação → página da interação. Se o perfil do fármaco mudar, o cartão é regenerável.
- **Progresso:** decisão 1 (recomendado anonymous sign-in). Sem contas públicas hoje → alternativa localStorage mantém o plano 100% viável sem migração de auth.

---

## Migração 156 — Schema

**Ficheiro:** `supabase/migrations/156_flashcards.sql`

```sql
-- Decks (curadoria + seed automático por prefixo ATC)
CREATE TABLE IF NOT EXISTS public.flashcard_decks (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  name_pt      TEXT NOT NULL,
  name_en      TEXT,
  description_pt TEXT,
  description_en TEXT,
  atc_prefix   TEXT,                    -- ex.: 'J01' | 'C' | NULL (deck manual)
  color        TEXT NOT NULL DEFAULT '#0a844f',
  sort_order   INTEGER NOT NULL DEFAULT 0,
  status       TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived  BOOLEAN NOT NULL DEFAULT false,
  archived_at  TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- Cartões (conteúdo gerado ou manual)
CREATE TABLE IF NOT EXISTS public.flashcards (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  deck_id     UUID NOT NULL REFERENCES public.flashcard_decks(id) ON DELETE CASCADE,
  drug_id     UUID REFERENCES public.drugs(id) ON DELETE SET NULL,   -- origem opcional
  card_type   TEXT NOT NULL DEFAULT 'manual'
              CHECK (card_type IN ('mecanismo','classe','perfil','interacao','manual')),
  front_pt    TEXT NOT NULL,
  front_en    TEXT,
  back_pt     TEXT NOT NULL,
  back_en     TEXT,
  source_note TEXT,                     -- fonte da resposta (DailyMed/EMC)
  status      TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Progresso de revisão (SM-2) — uma linha por (user, card)
CREATE TABLE IF NOT EXISTS public.flashcard_reviews (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  card_id          UUID NOT NULL REFERENCES public.flashcards(id) ON DELETE CASCADE,
  ease             REAL NOT NULL DEFAULT 2.5,
  interval_days    INTEGER NOT NULL DEFAULT 0,
  repetitions      INTEGER NOT NULL DEFAULT 0,
  lapses           INTEGER NOT NULL DEFAULT 0,
  due_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_reviewed_at TIMESTAMPTZ,
  created_at       TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, card_id)
);

-- RLS (padrão do projeto)
ALTER TABLE public.flashcard_decks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flashcard_reviews ENABLE ROW LEVEL SECURITY;

-- Público: decks e cartões publicados
CREATE POLICY "anon_read_flashcard_decks" ON public.flashcard_decks
  FOR SELECT TO anon, authenticated USING (status = 'published' AND is_archived = false);
CREATE POLICY "anon_read_flashcards" ON public.flashcards
  FOR SELECT TO anon, authenticated USING (status = 'published' AND is_archived = false);

-- Reviews: cada utilizador só vê/altera os seus (anon tem auth.uid() próprio)
CREATE POLICY "own_reviews_select" ON public.flashcard_reviews
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "own_reviews_insert" ON public.flashcard_reviews
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY "own_reviews_update" ON public.flashcard_reviews
  FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY "own_reviews_delete" ON public.flashcard_reviews
  FOR DELETE TO authenticated USING (user_id = auth.uid());

-- Admin: decks e cartões (padrão admin_users)
CREATE POLICY "admin_all_flashcard_decks" ON public.flashcard_decks
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));
CREATE POLICY "admin_all_flashcards" ON public.flashcards
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- Indexes
CREATE INDEX idx_flashcards_deck ON public.flashcards(deck_id, status);
CREATE INDEX idx_flashcards_drug ON public.flashcards(drug_id);
CREATE INDEX idx_reviews_user_due ON public.flashcard_reviews(user_id, due_at) WHERE due_at <= now();
```

> **Nota (decisão 1 = localStorage):** se se optar pela opção A, a tabela
> `flashcard_reviews` não é criada — o estado vive em localStorage
> (`cf-flashcards:{deckSlug}`) e o algoritmo corre no cliente. A migração 156
> fica sem reviews; os decks/cartões mantêm-se na BD (partilhados por todos).

## Migração 157 — Seed de decks + cartões gerados

- **Decks:** um por grupo ATC com fármacos publicados (ex.: `J01` Antibióticos, `J` Anti-infeciosos, `C` Cardiovascular, `N` SNC, `A` Alimentar/Metabolismo) + deck "Interações frequentes" (manual). Slug, nome PT/EN, cor, ordem.
- **Cartões:** script SQL (ou Node, padrão do gerador do pack Airtable) que gera, para cada fármaco publicado **com `drug_pharmacology` completo**:
  - `mecanismo`: front "Qual é o mecanismo de ação de {fármaco}?" → back `drug_pharmacology.mechanism_pt` (fonte)
  - `classe`: front "{fármaco} — a que classe pertence?" → back `drugs.class_pt`
  - `perfil`: front "Indicação/visão geral de {fármaco}" → back `drug_profiles.overview_public_pt`
  - `interacao`: para os pares críticos/moderados com summary → front "Interação: {A} + {B}?" → back `summary + severity`
  - `status='published'`, `source_note` preenchido; `drug_id` ligado.
- Regenerável: `ON CONFLICT` por chave natural (`deck_id + drug_id + card_type`) para reaplicar sem duplicar.

---

## Tarefas

### T1 — Migração 156 (schema) + 157 (seed)
SQL acima. Aplicar no Supabase. Se decisão 1 = localStorage, 156 sem `flashcard_reviews`.

### T2 — Algoritmo SM-2: `lib/flashcards/sm2.js` (novo)
Função pura:
```js
export function sm2Next(grade, state /* {ease, interval, repetitions, lapses} */)
// grade: 0=again, 1=hard, 2=good, 3=easy  (dos 4 botões do demo)
// devolve { ease, interval, repetitions, lapses, dueAt }
```
- `again` → repetições 0, intervalo <1 min, lapse+1, ease −0.20
- `hard` → intervalo ×1.2, ease −0.15 · `good` → ×ease, ease estável · `easy` → ×ease×1.3, ease +0.15
- `ease` mínimo 1.3; intervalo máximo configurável (ex.: 365 dias)
- Testes unitários (node) com sequências típicas.

### T3 — Camada de dados: `lib/api/flashcards.js` (novo)
- `getFlashcardDecks()` — decks publicados + contagem por deck (total, dominados, para revisar hoje) + contagem global "para revisar hoje"
- `getFlashcardDeckBySlug(slug)` — deck + cartões publicados
- `getDueCards(deckId)` — cartões com `due_at <= now()` (decisão 1) ou todos novos+devidos (localStorage)
- `getReviewState(userId)` — estado de revisão do utilizador
- Padrão `unstable_cache` + tags `flashcards`; queries com colunas explícitas.

### T4 — Ações server: `lib/actions/flashcards.js` (novo)
- `answerCard(cardId, grade)` — `requireAuth` (ou sem auth se localStorage) + `sm2Next` + upsert `flashcard_reviews`
- `resetDeckProgress(deckId)` / `resetCard(cardId)` — para recomeçar
- Admin: `createFlashcardDeck` / `updateFlashcardDeck` / `deleteFlashcardDeck` (delete bloqueado com cartões), `createFlashcard` / `updateFlashcard` / `deleteFlashcard` / `archiveFlashcard` — padrão `requireAdmin` + sanitização + slugs únicos
- `generateCardFromDrug(drugId, cardType)` — action de **geração assistida** (preenche o form a partir de `drug_profiles`/`drug_pharmacology`)

### T5 — Admin: `app/[lang]/admin/(protected)/flashcards/`
- `page.js` — abas "Decks" e "Cartões": tabelas com status, contagens, ações editar/arquivar/eliminar
- `decks/[id]/page.js` + `cards/new/page.js` + `cards/[id]/page.js` — `components/admin/FlashcardForm.jsx` (novo): picker de fármaco (search por nome) + **botão "Gerar a partir do fármaco"** que pré-preenche front/back do tipo escolhido; campos front/back PT/EN, fonte, deck, tipo, status
- Sidebar: item "Flashcards" (ícone `Layers`/`Sparkles`)

### T6 — Página principal `/flashcards`
`app/[lang]/(public)/flashcards/page.js` + `components/pages/FlashcardsPageClient.jsx`:
- Hero (eyebrow "Repetição espaçada" + título + subtítulo) — do demo
- **Painel "Para revisar hoje"** (cartão verde com contagem + CTA "Começar revisão") + estatísticas (dominados, total, taxa de acerto 7 dias)
- Filtros por tipo/grupo + pesquisa
- Grid `.deck-card`: badge do grupo, nº de cartões, **barra de progresso "Dominado"**, "N para revisar" e botão "Revisar"
- Estado vazio + skeletons (`loading.jsx`) no padrão do projeto

### T7 — Sessão de revisão `/flashcards/[slug]`
`app/[lang]/(public)/flashcards/[slug]/page.js` + `components/pages/FlashcardReviewClient.jsx`:
- Barra de progresso da sessão ("Cartão 4 de 18")
- **Flip card** (CSS `perspective`/`rotateY`, como no demo): front pergunta → back resposta (mecanismo, espetro, interações, monitorização) + **links** "Ver perfil: {fármaco}" / "Ver interação"
- Botões SM-2 **Outra vez / Difícil / Boa / Fácil** (com intervalos mostrados), só após virar
- Fim da sessão: resumo (acertos, próximas revisões, botões "Refazer" / "Mais decks")
- Apenas cartões devidos; se não houver → estado "Nada para revisar hoje" com sugestão de novo deck

### T8 — i18n, CSS, SEO e navegação
- Chaves `flashcards_page.*` e `flashcard_review.*` em pt/en
- Classes `.flash-*`/`.flip-*` do demo adaptadas + dark mode
- `loading.jsx` para `/flashcards` e `/flashcards/[slug]`
- Sitemap: `/flashcards` estático + slugs dinâmicos dos decks
- Menu principal: item "Flashcards" (ao lado de Interações/Ferramentas)

---

## Ficheiros

| Ficheiro | Ação |
|---|---|
| `supabase/migrations/156_flashcards.sql` | Novo (schema) |
| `supabase/migrations/157_flashcards_seed.sql` | Novo (decks + cartões gerados) |
| `lib/flashcards/sm2.js` | Novo (algoritmo puro + testes) |
| `lib/api/flashcards.js` | Novo |
| `lib/actions/flashcards.js` | Novo |
| `components/admin/FlashcardForm.jsx` | Novo |
| `components/pages/FlashcardsPageClient.jsx` | Novo |
| `components/pages/FlashcardReviewClient.jsx` | Novo |
| `app/[lang]/(public)/flashcards/{page,[slug]}` | Novos (+ `loading.jsx`) |
| `app/[lang]/admin/(protected)/flashcards/` | Novos (listagem + forms) |
| `components/layout/AdminSidebar.jsx` | Modificar (item Flashcards) |
| Menu principal público | Modificar (item Flashcards) |
| `app/sitemap.js` | Modificar |
| `lib/i18n.js` + `public/i18n/*.json` | Modificar |
| CSS do projeto | Modificar (classes do demo) |

## Fora de âmbito (consciente)

- **FSRS** (fica SM-2 na v1; migrar mais tarde sem tocar no schema)
- **Estatísticas avançadas** (gráficos de retenção, streak heatmap — pode ser follow-up)
- **Cartões com áudio/imagens** (v1 só texto, ligação ao perfil)
- **Deck builder visual** no público (só admin na v1)
- **Multi-dispositivo real** sem contas — depende da decisão 1
- **Notificações/push** de revisão

---

## Ordem de Execução

1. **Confirmar decisões** (1–4) com o utilizador
2. **T1** — Migrações 156 + 157 (aplicar) + **T2** — algoritmo SM-2 com testes
3. **T3 + T4** — Camada de dados + ações (review + admin)
4. **T5** — Admin (listagem + form + geração assistida)
5. **T8 parcial** — i18n + CSS base + skeletons
6. **T6 + T7** — Páginas públicas (principal + revisão)
7. **T8 restante** — sitemap + menu + SEO

## Verificação

- `npm run build` sem erros + testes do `sm2.js` passam
- Seed: cada deck tem cartões publicados com `drug_id` ligado e fonte preenchida
- Revisão: responder Outra vez/Difícil/Boa/Fácil atualiza `due_at` corretamente (ou localStorage); cartão "again" volta à sessão
- Painel "Para revisar hoje" reflete os devidos; ao terminar, 0 devidos
- Links dos cartões abrem o perfil do medicamento e a interação
- Admin: gerar cartão a partir de um fármaco pré-preenche front/back; editar/arquivar/eliminar reflete no público
- Dark mode correto nas classes novas
- Skeletons visíveis durante o carregamento; sitemap com `/flashcards` e slugs
