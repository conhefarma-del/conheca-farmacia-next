# Casos Clínicos Simulados — Plano de Implementação (2026-08-13, v1)

> Plano baseado nos modelos de design em `_temp/design-demos/` (`casos-clinicos.html`,
> `caso-clinico.html`) e na análise de viabilidade feita em 2026-08-13.
> Os casos ligam-se aos **Protocolos Clínicos** já existentes (`clinical_protocols`
> + `clinical_protocol_steps`) e aos fármacos/interações do banco de Medicamentos
> — cada pergunta termina com fundamentação e referências reais.

## Decisões a confirmar (antes da implementação)

| # | Pergunta | Opção recomendada | Alternativa |
|---|----------|-------------------|-------------|
| 1 | Progresso por utilizador | **Sem progresso individual na v1** — apenas contador agregado de tentativas (`attempt_count`) no caso | localStorage por dispositivo (histórico de tentativas/respostas, como os flashcards) |
| 2 | Conteúdo inicial | **Seed com 2–4 casos reais** ligados a protocolos publicados existentes (verificar slugs reais no seed: malária, diarreia, TB, hipertensão...) | Sem seed (só admin) |
| 3 | Formato das perguntas | **MCQ de escolha única** com feedback imediato (correto/incorreto + fundamentação) — como no demo | Perguntas abertas com resposta modelo (sem correção automática) |
| 4 | Tabela de ligação a fármacos | Steps referenciam **diretamente slugs** (protocolo/fármaco/interação) num JSONB de referências — simples e à prova de FK frágil | FK rígidas por tipo de referência (3 tabelas junction) |

## Arquitetura

- **Público:** `/casos-clinicos` (listagem com filtros por sistema/dificuldade e pesquisa) e `/casos-clinicos/[slug]` (stepper de perguntas). Rotas top-level, irmãs de `/protocolos`.
- **Admin:** `/admin/casos-clinicos` (lista), `/admin/casos-clinicos/new`, `/admin/casos-clinicos/[id]` (editar) — form com **editor de steps dinâmico** (pergunta, contexto, opções com correta, explicação, referências) e **picker de protocolo**.
- **Dados:** 2 tabelas novas — `clinical_cases`, `clinical_case_steps` — padrão RLS do projeto. `clinical_cases.protocol_id` (FK, `ON DELETE SET NULL`) liga o caso ao protocolo; o badge "Protocolo: X" abre a página do protocolo.
- **Conteúdo:** o caso **reutiliza** o material editorial dos protocolos (red_flags, safety_notes, steps com `drugs [{label, dose}]`) — o autor do caso referencia-os em vez de duplicar.

---

## Migração 158 — Schema

**Ficheiro:** `supabase/migrations/158_casos_clinicos.sql`

```sql
-- Casos clínicos simulados
CREATE TABLE IF NOT EXISTS public.clinical_cases (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug          TEXT NOT NULL UNIQUE,
  protocol_id   UUID REFERENCES public.clinical_protocols(id) ON DELETE SET NULL,
  title_pt      TEXT NOT NULL,
  title_en      TEXT,
  description_pt TEXT NOT NULL DEFAULT '',
  description_en TEXT,
  system        TEXT NOT NULL DEFAULT 'geral',  -- infeção, cardiovascular, pediatria...
  difficulty    TEXT NOT NULL DEFAULT 'intermedio'
                CHECK (difficulty IN ('iniciante','intermedio','avancado')),
  read_time     INTEGER,
  attempt_count INTEGER NOT NULL DEFAULT 0,     -- contador agregado (decisão 1)
  status        TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  sort_order    INTEGER NOT NULL DEFAULT 0,
  is_archived   BOOLEAN NOT NULL DEFAULT false,
  archived_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- Steps: pergunta + contexto + opções + correção + fundamentação
CREATE TABLE IF NOT EXISTS public.clinical_case_steps (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  case_id         UUID NOT NULL REFERENCES public.clinical_cases(id) ON DELETE CASCADE,
  position        INTEGER NOT NULL DEFAULT 0,
  question_pt     TEXT NOT NULL,
  question_en     TEXT,
  context_pt      TEXT,                          -- contexto clínico da pergunta
  context_en      TEXT,
  options         JSONB NOT NULL DEFAULT '[]',   -- [{pt, en}]
  correct_index   INTEGER NOT NULL DEFAULT 0,
  explanation_pt  TEXT NOT NULL DEFAULT '',
  explanation_en  TEXT,
  -- [{type: 'protocol'|'drug'|'interaction', slug, label}] — referências para links
  references      JSONB NOT NULL DEFAULT '[]',
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- RLS (padrão do projeto)
ALTER TABLE public.clinical_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clinical_case_steps ENABLE ROW LEVEL SECURITY;

-- Público: casos publicados e não arquivados + steps dos casos publicados
CREATE POLICY "anon_read_clinical_cases" ON public.clinical_cases
  FOR SELECT TO anon, authenticated USING (status = 'published' AND is_archived = false);
CREATE POLICY "anon_read_clinical_case_steps" ON public.clinical_case_steps
  FOR SELECT TO anon, authenticated USING (EXISTS (
    SELECT 1 FROM public.clinical_cases c
    WHERE c.id = case_id AND c.status = 'published' AND c.is_archived = false));

-- Admin: tudo (padrão admin_users)
CREATE POLICY "admin_all_clinical_cases" ON public.clinical_cases
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));
CREATE POLICY "admin_all_clinical_case_steps" ON public.clinical_case_steps
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- Indexes
CREATE INDEX idx_clinical_cases_status ON public.clinical_cases(status, is_archived);
CREATE INDEX idx_clinical_cases_protocol ON public.clinical_cases(protocol_id);
CREATE INDEX idx_clinical_cases_system ON public.clinical_cases(system, difficulty);
CREATE INDEX idx_case_steps_case ON public.clinical_case_steps(case_id, position);
```

> **Nota (decisão 1 = localStorage):** o `attempt_count` mantém-se (contador
> agregado, incrementado na conclusão — útil para mostrar "X concluíram" nos
> cards, como no demo). O histórico individual (opcional) fica em localStorage
> `cf-casos:{slug}` com o melhor resultado por caso.

## Migração 159 — Seed de casos reais

- **Casos:** 2–4 casos de exemplo ligados a **protocolos existentes e publicados**
  (validar os slugs reais antes de escrever o seed — ex.: malária, diarreia
  aguda, tuberculose, hipertensão). Título PT, descrição, sistema, dificuldade,
  read_time, `status='published'`.
- **Steps por caso:** 4–6 perguntas MCQ com contexto clínico (idade/peso/queixas),
  opções PT, `correct_index`, explicação com fundamentação e `references`
  (protocolo + fármacos do banco + interações reais quando fizer sentido).
- **Ligação ao material editorial:** a explicação referencia `red_flags`/
  `safety_notes` do protocolo e os `drugs [{label, dose}]` dos steps do protocolo
  — sem duplicar conteúdo.

---

## Tarefas

### T1 — Migração 158 (schema) + 159 (seed)
SQL acima. Aplicar no Supabase. Validar slugs dos protocolos reais para o seed.

### T2 — Camada de dados: `lib/api/clinical-cases.js` (novo)
- `CASE_COLUMNS` (SELECT explícito) + `normalizeClinicalCase(row)` → `{ id, slug, title, description, system, difficulty, readTime, protocol: {slug, title}, attemptCount, steps: [...] }` (protocolo resolvido por join)
- `getClinicalCases()` — publicados + não arquivados, com join a `clinical_protocols` (slug, título) e contagem de steps
- `getClinicalCaseBySlug(slug)` — caso + steps ordenados por `position`
- `getClinicalCaseSystems()` — lista de sistemas distintos (para os filtros)
- Padrão `unstable_cache` + tags `clinical-cases`.

### T3 — Ações server: `lib/actions/clinicalCases.js` (novo)
- Admin: `createClinicalCase` / `updateClinicalCase` / `deleteClinicalCase` (hard delete, só superadmin) / `archiveClinicalCase` — padrão `requireAdmin`, slugs únicos, sanitização (`sanitizeHtml` em perguntas/explicações), validação (opções 2–6, `correct_index` no range, `references` array ≤10)
- Steps em bulk: `saveCaseSteps(caseId, steps)` — delete + insert idempotente (padrão do sync de autores)
- Público: `incrementCaseAttempt(caseId)` — action rate-limited (RPC `check_rate_limit` DB-backed, padrão do feedback) + `UPDATE attempt_count = attempt_count + 1`

### T4 — Admin: `app/[lang]/admin/(protected)/casos-clinicos/`
- `page.js` — lista com sistema, dificuldade, protocolo, nº de steps, contagem de tentativas, status; ações editar/arquivar/eliminar
- `new/page.js` + `[id]/page.js` — `components/admin/ClinicalCaseForm.jsx` (novo):
  - Campos base: título, slug, descrição, sistema (livre com sugestões), dificuldade, tempo de leitura, **protocolo (dropdown da BD)**, status, ordem
  - **Editor de steps dinâmico**: pergunta, contexto, lista de opções (adicionar/remover, marcar a correta), explicação, referências (tipo + slug + label — com autocomplete de fármacos/protocolos existentes)
  - Preview dos steps na ordem final
- Sidebar: item "Casos Clínicos" (ícone `Stethoscope`)

### T5 — Listagem pública `/casos-clinicos`
`app/[lang]/(public)/casos-clinicos/page.js` + `components/pages/CasosClinicosPageClient.jsx`:
- Hero (eyebrow "Aprender a decidir" + título + subtítulo) — do demo
- Filtros por sistema + dificuldade + pesquisa
- Grid `.case-card`: badge de sistema, dificuldade, título, descrição, meta (tempo · nº de perguntas · "X concluíram"), **badge do protocolo ligado** no rodapé e CTA "Resolver caso →"
- Estado vazio + skeletons (`loading.jsx`) no padrão do projeto

### T6 — Detalhe `/casos-clinicos/[slug]`
`app/[lang]/(public)/casos-clinicos/[slug]/page.js` + `components/pages/CasoClinicoClient.jsx`:
- Header: badge sistema, título, meta (perguntas, dificuldade, tempo)
- **Stepper** (dots de progresso) + cartão de pergunta: contexto clínico, opções clicáveis, **feedback imediato** (correto/incorreto + fundamentação + referências com links)
- Navegação Anterior/Próxima; resultado final com pontuação ("4/5") e botões "Refazer caso" / "Mais casos"
- Sidebar: cartão **Doente** (idade, peso, queixas — do contexto), cartão **Protocolo ligado** (link direto), **Fármacos do caso** (chips para os perfis) — como no demo
- `incrementCaseAttempt` na conclusão (uma vez por sessão, dedupe por estado do client)

### T7 — i18n, CSS, SEO e navegação
- Chaves `casos_clinicos_page.*` e `caso_clinico.*` em pt/en
- Classes `.case-*`/`.q-*` do demo adaptadas + dark mode
- `loading.jsx` para `/casos-clinicos` e `/casos-clinicos/[slug]`
- Sitemap: `/casos-clinicos` estático + slugs dinâmicos
- Menu principal: item "Casos Clínicos" (junto de Protocolos/Ferramentas)

---

## Ficheiros

| Ficheiro | Ação |
|---|---|
| `supabase/migrations/158_casos_clinicos.sql` | Novo (schema) |
| `supabase/migrations/159_seed_casos_clinicos.sql` | Novo (seed com protocolos reais) |
| `lib/api/clinical-cases.js` | Novo |
| `lib/actions/clinicalCases.js` | Novo |
| `components/admin/ClinicalCaseForm.jsx` | Novo |
| `components/pages/CasosClinicosPageClient.jsx` | Novo |
| `components/pages/CasoClinicoClient.jsx` | Novo |
| `app/[lang]/(public)/casos-clinicos/{page,[slug]}` | Novos (+ `loading.jsx`) |
| `app/[lang]/admin/(protected)/casos-clinicos/` | Novos (listagem + forms) |
| `components/layout/AdminSidebar.jsx` | Modificar (item Casos Clínicos) |
| Menu principal público | Modificar (item Casos Clínicos) |
| `app/sitemap.js` | Modificar |
| `lib/i18n.js` + `public/i18n/*.json` | Modificar |
| CSS do projeto | Modificar (classes do demo) |

## Fora de âmbito (consciente)

- **Progresso individual** (histórico, melhor resultado, badges) — v1 só contador agregado; localStorage é o follow-up natural
- **Casos adaptativos** (perguntas que mudam com as respostas) — v1 linear
- **Perguntas abertas** (sem correção automática) — v1 só MCQ
- **Timers/ranking/leaderboard** — sem gamificação na v1
- **PDF/impressão** do caso — pode ser follow-up (como nos guias/protocolos)
- **Vídeo/áudio** nos casos — v1 só texto

---

## Ordem de Execução

1. **Confirmar decisões** (1–4) com o utilizador
2. **T1** — Migrações 158 + 159 (aplicar; validar slugs dos protocolos reais)
3. **T2 + T3** — Camada de dados + ações (admin + increment de tentativas rate-limited)
4. **T4** — Admin (listagem + form com editor de steps)
5. **T7 parcial** — i18n + CSS base + skeletons
6. **T5 + T6** — Páginas públicas (listagem + stepper)
7. **T7 restante** — sitemap + menu + SEO

## Verificação

- `npm run build` sem erros
- Seed: cada caso publicado tem protocolo ligado (badge abre a página do protocolo), 4–6 steps com opções e correta válida
- Resolver um caso: feedback correto/incorreto imediato, navegação funcional, pontuação final; "X concluíram" incrementa (uma vez por sessão)
- Links da fundamentação abrem protocolo/fármaco/interação corretos
- Admin: criar/editar caso com steps dinâmicos; arquivar/eliminar reflete no público
- Filtros por sistema/dificuldade + pesquisa funcionam; estado vazio e skeletons corretos
- Dark mode correto nas classes novas; sitemap com `/casos-clinicos` e slugs
