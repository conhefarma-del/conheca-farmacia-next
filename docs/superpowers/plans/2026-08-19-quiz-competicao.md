# Quiz Competição Inter-Escolas — Plano de Implementação (2026-08-19, v1)

> Plano baseado na análise de viabilidade de 2026-08-19 e nas decisões do
> utilizador. O motor de quiz já existe (`lib/quiz/engine.js`,
> `lib/actions/quiz.js`); este plano adiciona o modo **competição** com
> leaderboard por escola/turma, identidade híbrida (código de acesso +
> opção de conta), real-time via polling, streak com bónus de pontos e
> perguntas sobre classes terapêuticas.

## Decisões a confirmar (respondidas em 2026-08-19)

| # | Pergunta | Opção escolhida |
|---|----------|-----------------|
| 1 | Identidade dos alunos | **Híbrido** — entrada com código de acesso (nome + código turma) sem fricção + opção opcional "Guardar na minha conta" ( Supabase Auth). Session_id no browser para sessão anónima. |
| 2 | Leaderboard | **Ambos** — sessão temporal (competição com início/fim) + ranking histórico agregado por escola/turma ao longo do tempo. |
| 3 | Real-time | **Polling a cada 5s** — request ao servidor que devolve as posições atuais. Simples, funciona sempre, sem configuração Realtime. |
| 4 | Escolas/Turmas | **Tabelas no admin** — `schools` e `classes` com CRUD em `/admin/competicoes/escolas` e `/admin/competicoes/turmas`. |
| 5 | Tipos de pergunta | **5 tipos** — farmacologia, interações, flashcards, protocolos + **classes terapêuticas** (novo: "A que classe pertence X?"). |
| 6 | Gamificação | **Streak + bónus** — 3+ respostas corretas seguidas = bónus de pontos crescente. Counter visível no ecrã. |

## Arquitetura

### Fluxo do aluno

```
1. Entrar → /competicao → código da competição + nome + escola + turma
2. Lobby  → Sala de espera (mostra participantes, countdown)
3. Quiz   → Perguntas com timer, streak, pontuação ao vivo
4. Result → Pódio + ranking + opção "Guardar na minha conta"
```

### Fluxo do admin

```
1. Criar escolas e turmas → /admin/competicoes/escolas
2. Criar competição → /admin/competicoes/new (nome, duração, tipos de pergunta, escolas convidadas)
3. Iniciar competição → botão "Iniciar" (gera código de acesso, abre lobby)
4. Monitorizar → leaderboard ao vivo, estatísticas por escola/turma
5. Terminar → botão "Terminar" (fecha lobby, mostra pódio final)
```

### Identidade híbrida (decisão 1)

- **Sem conta (padrão):** aluno entra com nome + código de turma. Session ID gerado pelo servidor e guardado em `localStorage`. Progresso guardado em `competition_sessions` com `session_id` (não `user_id`).
- **Com conta (opcional):** toggle "Guardar na minha conta" → Supabase anonymous sign-in → `user_id` preenchido em `competition_sessions`. Se o aluno já tiver conta, liga diretamente.
- **Migração futura:** sessões anónimas podem ser "reivindicadas" por uma conta posteriormente (campos `session_id` + `user_id` na mesma tabela).

### Leaderboard duplo (decisão 2)

- **Sessão temporal:** cada competição tem `started_at` e `ended_at`. O leaderboard da sessão filtra por `competition_id` + `started_at >= competição.started_at`.
- **Histórico:**视图 `competition_leaderboard_historical` agrega resultados por (school_id, class_id) ao longo de todas as competições. Ranking permanente que sobrevive a sessões individuais.

### Perguntas de classes (decisão 5)

Novo tipo no pool do quiz, reutilizando a tabela `drug_classes` (migração 227):
- "A que classe terapêutica pertence o fármaco X?" → resposta = `drug_classes.name_pt` do fármaco
- Distratores = nomes de outras classes reais (mesmo dataset)
- Fonte: `drugs.class_id` → `drug_classes.name_pt`

---

## Migração 233 — Schools + Classes

**Ficheiro:** `supabase/migrations/233_quiz_competicao_schools.sql`

```sql
-- =====================================================================
-- 233 — Quiz Competição: escolas e turmas
-- =====================================================================

-- Escolas
CREATE TABLE IF NOT EXISTS public.schools (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  name         TEXT NOT NULL,
  location     TEXT NOT NULL DEFAULT '',
  status       TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published')),
  is_archived  BOOLEAN NOT NULL DEFAULT false,
  archived_at  TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Turmas
CREATE TABLE IF NOT EXISTS public.classes (
  id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug         TEXT NOT NULL UNIQUE,
  school_id    UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,            -- ex: '10.ª A'
  grade        TEXT NOT NULL DEFAULT '', -- ex: '10'
  status       TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('draft','published')),
  is_archived  BOOLEAN NOT NULL DEFAULT false,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (school_id, name)
);

-- RLS
ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;

-- Admin: tudo
CREATE POLICY admin_all_schools ON public.schools
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY admin_all_classes ON public.classes
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND NOT is_archived);

CREATE POLICY admin_manage_classes ON public.classes
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: escolas publicadas (para o formulário de entrada)
CREATE POLICY anon_read_schools ON public.schools
  FOR SELECT TO anon, authenticated
  USING (status = 'published' AND NOT is_archived);

-- Índices
CREATE INDEX idx_classes_school ON public.classes(school_id);
```

---

## Migração 234 — Competitions + Sessions + Leaderboard

**Ficheiro:** `supabase/migrations/234_quiz_competicao_schema.sql`

```sql
-- =====================================================================
-- 234 — Quiz Competição: sessões, competições e leaderboard
-- =====================================================================

-- Competições (criadas pelo admin)
CREATE TABLE IF NOT EXISTS public.competitions (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug            TEXT NOT NULL UNIQUE,
  name            TEXT NOT NULL,
  access_code     TEXT NOT NULL UNIQUE,     -- ex: 'CF-2026'
  description     TEXT NOT NULL DEFAULT '',
  -- Configuração
  question_types  TEXT[] NOT NULL DEFAULT '{pharmacology,interaction,flashcard,protocol,drug_class}',
  questions_count INTEGER NOT NULL DEFAULT 10,
  time_per_question INTEGER NOT NULL DEFAULT 30,  -- segundos
  streak_bonus    BOOLEAN NOT NULL DEFAULT true,
  -- Escolas convidadas
  school_ids      UUID[] NOT NULL DEFAULT '{}',
  -- Estado
  status          TEXT NOT NULL DEFAULT 'draft'
                  CHECK (status IN ('draft','lobby','active','ended','cancelled')),
  started_at      TIMESTAMPTZ,
  ended_at        TIMESTAMPTZ,
  -- Timestamps
  created_by      UUID REFERENCES auth.users(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Sessões de competição (um registo por aluno numa competição)
CREATE TABLE IF NOT EXISTS public.competition_sessions (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  competition_id  UUID NOT NULL REFERENCES public.competitions(id) ON DELETE CASCADE,
  -- Identidade
  session_id      TEXT NOT NULL,            -- ID anónimo (gerado pelo servidor)
  user_id         UUID REFERENCES auth.users(id),  -- NULL = sem conta
  student_name    TEXT NOT NULL,
  -- Escola / turma
  school_id       UUID REFERENCES public.schools(id),
  class_id        UUID REFERENCES public.classes(id),
  -- Pontuação
  total_score     INTEGER NOT NULL DEFAULT 0,
  correct_count   INTEGER NOT NULL DEFAULT 0,
  total_answered  INTEGER NOT NULL DEFAULT 0,
  max_streak      INTEGER NOT NULL DEFAULT 0,
  current_streak  INTEGER NOT NULL DEFAULT 0,
  -- Detalhes
  answers         JSONB NOT NULL DEFAULT '[]',  -- [{qIdx, correct, points, streak_at}]
  finished_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Um aluno só participa uma vez por competição
  UNIQUE (competition_id, session_id)
);

-- RLS
ALTER TABLE public.competitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competition_sessions ENABLE ROW LEVEL SECURITY;

-- Admin: competições
CREATE POLICY admin_all_competitions ON public.competitions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: ler competições ativas/lobby (para o formulário de entrada)
CREATE POLICY anon_read_competitions ON public.competitions
  FOR SELECT TO anon, authenticated
  USING (status IN ('lobby','active'));

-- Admin: sessões
CREATE POLICY admin_all_sessions ON public.competition_sessions
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

-- Anon: ler sessões (para leaderboard público)
CREATE POLICY anon_read_sessions ON public.competition_sessions
  FOR SELECT TO anon, authenticated
  USING (true);

-- Anon: inserir sessão (para entrada sem conta)
CREATE POLICY anon_insert_session ON public.competition_sessions
  FOR INSERT TO anon, authenticated
  WITH CHECK (true);

-- Auth: atualizar a sua própria sessão
CREATE POLICY own_session_update ON public.competition_sessions
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR session_id = current_setting('request.headers')::json->>'x-session-id')
  WITH CHECK (user_id = auth.uid() OR session_id = current_setting('request.headers')::json->>'x-session-id');

-- Índices
CREATE INDEX idx_comp_sessions_comp ON public.competition_sessions(competition_id, total_score DESC);
CREATE INDEX idx_comp_sessions_school ON public.competition_sessions(school_id, total_score DESC);
CREATE INDEX idx_comp_sessions_class ON public.competition_sessions(class_id, total_score DESC);
CREATE INDEX idx_comp_sessions_user ON public.competition_sessions(user_id);
CREATE INDEX idx_competitions_status ON public.competitions(status);
CREATE INDEX idx_competitions_code ON public.competitions(access_code);

-- =====================================================================
-- View: leaderboard por competição (top N)
-- =====================================================================
CREATE OR REPLACE VIEW public.competition_leaderboard AS
SELECT
  cs.id,
  cs.competition_id,
  cs.student_name,
  cs.total_score,
  cs.correct_count,
  cs.total_answered,
  cs.max_streak,
  cs.school_id,
  s.name AS school_name,
  cs.class_id,
  c.name AS class_name,
  cs.finished_at,
  cs.created_at,
  RANK() OVER (
    PARTITION BY cs.competition_id
    ORDER BY cs.total_score DESC, cs.correct_count DESC, cs.created_at ASC
  ) AS position
FROM public.competition_sessions cs
LEFT JOIN public.schools s ON s.id = cs.school_id
LEFT JOIN public.classes c ON c.id = cs.class_id
WHERE cs.total_answered > 0;
```

---

## Migração 235 — Seed: tipos de pergunta de classes

**Ficheiro:** `supabase/migrations/235_quiz_competicao_drug_class_questions.sql`

```sql
-- =====================================================================
-- 235 — Quiz Competição: função para gerar perguntas de classes
-- =====================================================================

-- Não há tabela de perguntas — as sessões são montadas em tempo real
-- pelo engine (lib/quiz/engine.js) a partir dos dados existentes.
-- A migração 233/234 é suficiente; o engine existente é estendido
-- com um novo builder para 'drug_class'.
```

> Nota: o tipo `drug_class` é adicionado ao engine existente em
> `lib/quiz/engine.js` (T2), não requer tabela nova.

---

## Tarefas

### T1 — Migrações 233 + 234 (schema)
SQL acima. Aplicar no Supabase. Cria tabelas `schools`, `classes`,
`competitions`, `competition_sessions` + view `competition_leaderboard`.

### T2 — Extensão do engine: `lib/quiz/engine.js` (modificar)
Adicionar novo builder ao engine existente:

```js
// Novo tipo: drug_class
export function buildDrugClassQuestion(drug, classesPool) {
  // Pergunta: "A que classe terapêutica pertence o fármaco {name}?"
  // Resposta: drug_classes.name_pt do fármaco (via drugs.class_id)
  // Distratores: nomes de 3 outras classes reais (mesmo dataset)
}

// Estender buildSession para aceitar source='drug_class'
// Estender getQuizPools para incluir classes no pool
```

- Garantir que os distratores são únicos e do mesmo dataset
- Resposta correta sempre presente
- Opções embaralhadas
- Testes unitários: distratores únicos, correctIndex bate com a resposta

### T3 — Server actions de competição: `lib/actions/competition.js` (novo)

**Admin:**
- `createCompetition(data)` — criar competição com código de acesso único
- `updateCompetition(id, data)` — editar configurações
- `startCompetition(id)` — muda status para 'lobby', gera código
- `endCompetition(id)` — muda status para 'ended', regata `ended_at`
- `getAllCompetitionsAdmin()` — listar competições com estatísticas
- `getCompetitionLeaderboardAdmin(competitionId)` — leaderboard completo

**Admin — Escolas/Turmas:**
- `createSchool(data)` / `updateSchool(id, data)` / `archiveSchool(id)`
- `createClass(data)` / `updateClass(id, data)` / `archiveClass(id)`
- `getAllSchoolsAdmin()` / `getAllClassesAdmin(schoolId?)`

**Aluno:**
- `joinCompetition(accessCode, { studentName, schoolId, classId })` — valida código, cria sessão, devolve `sessionId`
- `submitAnswer(sessionId, { questionIndex, selected, timeMs })` — valida resposta no servidor, calcula pontos + streak, atualiza sessão
- `finishCompetition(sessionId)` — marca `finished_at`, devolve resultado final
- `getCompetitionLeaderboard(competitionId)` — leaderboard público (top 50)
- `claimSessionToAccount(sessionId)` — liga sessão anónima a conta Supabase (toggle "Guardar na minha conta")

**Gamificação (streak + bónus):**
- Lógica de streak: `current_streak` incrementa se correto, reseta se errado
- Bónus: 3+ streak = +50pts, 5+ = +100pts, 8+ = +200pts, 12+ = +500pts
- `max_streak` guardado para estatísticas
- Pontuação base: 100pts por resposta correta + bónus de tempo (timer restante × 3)

### T4 — Polling do leaderboard: `lib/actions/competition.js` (extensão)

```js
// Endpoint de polling (server action chamada a cada 5s pelo cliente)
export async function pollLeaderboard(competitionId, lastUpdate) {
  // Devolve apenas posições alteradas desde lastUpdate
  // Para otimizar: compara updated_at > lastUpdate
  // Se nada mudou → { unchanged: true } (cliente não re-renderiza)
}
```

- Polling a cada 5s no cliente (interval no componente)
- Resposta otimizada: só envia dados se houve alterações
- Cache de 5s no servidor para reduzir load

### T5 — Admin: páginas de gestão

**Escolas e turmas:**
- `app/[lang]/admin/(protected)/competicoes/escolas/page.js` — listagem de escolas com CRUD
- `app/[lang]/admin/(protected)/competicoes/turmas/page.js` — listagem de turmas por escola
- Componentes: `SchoolsAdminPage.jsx`, `ClassesAdminPage.jsx`, `SchoolForm.jsx`, `ClassForm.jsx`

**Competições:**
- `app/[lang]/admin/(protected)/competicoes/page.js` — listagem de competições
- `app/[lang]/admin/(protected)/competicoes/new/page.js` — criar competição
- `app/[lang]/admin/(protected)/competicoes/[id]/page.js` — detalhe + leaderboard ao vivo
- Componentes: `CompetitionsAdminPage.jsx`, `CompetitionForm.jsx`, `CompetitionDetailPage.jsx`

**Sidebar:** item "Competições" (ícone `Trophy`) com submenu "Escolas" e "Turmas"

### T6 — Páginas públicas

**`/competicao`** (entrada):
- `app/[lang]/(public)/competicao/page.js` + `components/pages/CompetitionJoinClient.jsx`
- Hero: "Quiz Competição — Representa a tua escola!"
- Formulário: código de competição + nome + escola + turma
- Botão "Entrar" → redireciona para lobby

**`/competicao/[code]`** (lobby + quiz + resultado):
- `app/[lang]/(public)/competicao/[code]/page.js` + `components/pages/CompetitionSessionClient.jsx`
- **Fase Lobby:** sala de espera, participantes, countdown, leaderboard preview
- **Fase Quiz:** perguntas com timer, streak counter, pontuação ao vivo, mini-leaderboard
- **Fase Result:** pódio (top 3), ranking completo, estatísticas, botão "Guardar na minha conta"

**Componentes novos:**
- `CompetitionJoinClient.jsx` — formulário de entrada
- `CompetitionLobbyClient.jsx` — sala de espera
- `CompetitionQuizClient.jsx` — sessão ativa
- `CompetitionResultClient.jsx` — resultado final com pódio
- `CompetitionLeaderboard.jsx` — leaderboard reutilizável (usado em lobby, quiz e resultado)

### T7 — i18n, CSS, SEO e navegação

- Chaves `competition_page.*`, `competition_session.*`, `competition_leaderboard.*` em pt/en
- Classes `.comp-*` no padrão do projeto + dark mode
- `loading.jsx` para `/competicao` e `/competicao/[code]`
- Sitemap: `/competicao` estático; `/competicao/[code]` com `noindex` (interativo)
- Menu principal: item "Competição" (ao lado de "Praticar" no menu Ferramentas)
- Admin sidebar: item "Competições" com submenu

---

## Ficheiros

| Ficheiro | Ação |
|----------|------|
| `supabase/migrations/233_quiz_competicao_schools.sql` | Novo (schools + classes) |
| `supabase/migrations/234_quiz_competicao_schema.sql` | Novo (competitions + sessions + leaderboard view) |
| `lib/quiz/engine.js` | Modificar (adicionar `buildDrugClassQuestion`) |
| `lib/actions/competition.js` | Novo (CRUD competições + join + submit + leaderboard) |
| `components/admin/CompetitionsAdminPage.jsx` | Novo |
| `components/admin/CompetitionForm.jsx` | Novo |
| `components/admin/CompetitionDetailPage.jsx` | Novo |
| `components/admin/SchoolsAdminPage.jsx` | Novo |
| `components/admin/ClassesAdminPage.jsx` | Novo |
| `components/admin/SchoolForm.jsx` | Novo |
| `components/admin/ClassForm.jsx` | Novo |
| `components/pages/CompetitionJoinClient.jsx` | Novo |
| `components/pages/CompetitionLobbyClient.jsx` | Novo |
| `components/pages/CompetitionQuizClient.jsx` | Novo |
| `components/pages/CompetitionResultClient.jsx` | Novo |
| `components/ui/CompetitionLeaderboard.jsx` | Novo (reutilizável) |
| `app/[lang]/(public)/competicao/` | Novos (page + [code] + loading) |
| `app/[lang]/admin/(protected)/competicoes/` | Novos (page + new + [id] + escolas + turmas) |
| `components/layout/AdminSidebar.jsx` | Modificar (item Competições) |
| Menu principal público + Footer | Modificar (item Competição) |
| `app/sitemap.js` | Modificar |
| `app/api/revalidate/route.js` | Modificar (tag 'competitions') |
| `lib/i18n.js` + `public/i18n/*.json` | Modificar |
| CSS do projeto | Modificar (classes `.comp-*`) |

## Fora de âmbito (consciente)

- **Supabase Realtime** (v1 usa polling; Realtime é follow-up)
- **Anti-cheating avançado** (detetar tab switching, tempo suspeito — v1 valida só no servidor)
- **Perguntas com imagem/áudio**
- **Export de resultados** (PDF/CSV do leaderboard — follow-up)
- **Notificações push** para leaderboard
- **Desafio 1v1** (modo head-to-head entre dois alunos)
- **Temporadas** (ranking semanal/mensal com reset automático)

---

## Ordem de Execução

1. **T1** — Migrações 233 + 234 (aplicar no Supabase)
2. **T2** — Extensão do engine (`buildDrugClassQuestion` + testes)
3. **T3** — Server actions de competição (join, submit, leaderboard, admin CRUD)
4. **T5 parcial** — Admin: escolas e turmas (CRUD básico)
5. **T5 restante** — Admin: competições (criar, iniciar, monitorizar)
6. **T7 parcial** — i18n + CSS base + skeletons
7. **T6** — Páginas públicas (entrada, lobby, quiz, resultado)
8. **T4** — Polling do leaderboard
9. **T7 restante** — sitemap + menu + revalidation + SEO

## Verificação

- `npm run build` sem erros
- Migrações aplicadas: `schools`, `classes`, `competitions`, `competition_sessions` existem
- Admin: criar escola → criar turma → criar competição → iniciar → código aparece
- Aluno: entrar com código → lobby → quiz → resultado → leaderboard
- Streak: 3+ respostas corretas seguidas = bónus visível no ecrã
- Polling: leaderboard atualiza a cada 5s sem refresh manual
- Perguntas de classes: "A que classe pertence X?" com distratores reais
- Sessão anónima: progresso guardado sem conta
- Opção "Guardar na minha conta": liga sessão a Supabase Auth
- Leaderboard histórico: agrega resultados de múltiplas competições
- Dark mode correto nas classes novas
- Skeletons visíveis durante carregamento
- i18n PT/EN em todas as chaves novas
