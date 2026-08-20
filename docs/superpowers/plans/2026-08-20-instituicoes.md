# Sistema de Instituições — Plano de Implementação (2026-08-20, v1)

> Extensão do sistema de competições inter-escolas. Permite que instituições
> (escolas, faculdades, cursos) criem perfis verificados, gerem turmas e
> alunos, e criem competições para os seus alunos. Alunos podem procurar e
> selecionar a sua instituição no perfil, ou adicioná-la se não existir.

## Decisões do utilizador (2026-08-20)

| # | Pergunta | Opção escolhida |
|---|----------|-----------------|
| 1 | Search de escolas | **Lista + pesquisa** — lista paginada com barra de busca |
| 2 | Adicionar escola (aluno) | **Nome + localização** — formulário mínimo para reduzir fricção |
| 3 | Dados obrigatórios da instituição | **Nome, Tipo, Localização, Telefone, Email** — sem logo nem descrição no MVP |
| 4 | Merge de escolas duplicadas | **Aluno escolhe** — quando admin aprova instituição, alunos com escola homónima são notificados e migram manualmente |
| 5 | Criar competições | **Limite de 30/mês** — sem aprovação do admin, mas com quota |
| 6 | Dashboard de alunos | **Completo** — lista + email + turma + histórico competições + progresso flashcards + ranking interno |
| 7 | Multi-instituição | **Uma por tipo** — aluno pode estar numa escola + num instituto superior (2 instituições máxima) |

## Arquitetura atual vs. pretendida

```
┌─────────────────────────────────────────────────────────────────┐
│  ESTADO ATUAL                                                   │
│  • schools: admin-only (CRUD em /admin/competicoes/escolas)     │
│  • classes: admin-only (CRUD em /admin/competicoes/turmas)      │
│  • Aluno: seleciona escola + turma ao entrar na competição      │
│  • Competições: criadas pelo admin com school_ids[]              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  ESTADO PRETENDIDO                                              │
│  • schools: admin + instituições (com verificação)              │
│  • classes: admin + instituições (donos gerem as suas turmas)   │
│  • Aluno: edita escola/turma no perfil (search + add)           │
│  • Instituição: dashboard completo (turmas + alunos + competições)│
│  • Admin: painel de aprovação de instituições                    │
│  • Competições: admin + instituições (com limite mensal)         │
└─────────────────────────────────────────────────────────────────┘
```

## Decisões de schema

### Tabela `schools` — campos novos

| Campo | Tipo | Default | Descrição |
|---|---|---|---|
| `owner_user_id` | UUID FK → auth.users | NULL | Quem criou o perfil (instituição) |
| `institution_type` | TEXT | `'school'` | `school` / `university` / `course` / `association` |
| `contact_email` | TEXT | `''` | Email de contacto |
| `contact_phone` | TEXT | `''` | Telefone |
| `is_verified` | BOOLEAN | `false` | Selo de verificação (admin aprova) |
| `verified_at` | TIMESTAMPTZ | NULL | Data da aprovação |
| `verified_by` | UUID FK → auth.users | NULL | Admin que aprovou |
| `verification_status` | TEXT | `'none'` | `none` / `pending` / `approved` / `rejected` |
| `rejection_reason` | TEXT | `''` | Motivo da rejeição |
| `monthly_competition_limit` | INTEGER | `30` | Limite mensal de competições |
| `competitions_used_this_month` | INTEGER | `0` | Competições usadas no mês atual |

### Nova tabela `institution_members`

```sql
CREATE TABLE public.institution_members (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  institution_id  UUID NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role            TEXT NOT NULL DEFAULT 'student'
                  CHECK (role IN ('owner', 'admin', 'teacher', 'student')),
  class_id        UUID REFERENCES public.classes(id) ON DELETE SET NULL,
  joined_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (institution_id, user_id)
);
```

### Nova tabela `institution_requests`

```sql
CREATE TABLE public.institution_requests (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  institution_name TEXT NOT NULL,
  institution_type TEXT NOT NULL DEFAULT 'school',
  location        TEXT NOT NULL DEFAULT '',
  contact_email   TEXT NOT NULL DEFAULT '',
  contact_phone   TEXT NOT NULL DEFAULT '',
  status          TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by     UUID REFERENCES auth.users(id),
  reviewed_at     TIMESTAMPTZ,
  rejection_reason TEXT NOT NULL DEFAULT '',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Alterações na tabela `competitions`

| Campo | Tipo | Descrição |
|---|---|---|
| `created_by_institution` | BOOLEAN | `true` se criado por instituição (senão `false` = admin) |
| `institution_id` | UUID FK → schools | ID da instituição criadora (se aplicável) |

### Reset mensal de competições

Cron job (ou lazy reset) que faz `competitions_used_this_month = 0` no primeiro dia de cada mês. Implementação lazy: ao criar competição, verificar se `updated_at` é do mês anterior → reset antes de incrementar.

## Fluxos de utilizador

### 1. Aluno — Editar escola no perfil

```
/ perfil → "Editar Escola" → Lista de escolas com pesquisa
  ├── Encontra → Seleciona → Confirma → Atualiza user_metadata + institution_members
  └── Não encontra → "Adicionar Escola" → Nome + Localização → Submete →
      institution_requests (status: pending) → Escola aparece como "Pendente"
```

**UI**: Combobox com pesquisa (debounce 300ms) + scroll de resultados + botão "Não encontrei? Adicionar".

### 2. Instituição — Criar perfil

```
/ instituicao/criar → Formulário:
  Nome + Tipo (dropdown) + Localização + Telefone + Email
  → Submete → institution_requests (status: pending) →
  → Email ao admin: "Novo pedido de verificação" →
  → Admin aprova → schools.is_verified = true →
  → Email ao owner: "Instituição aprovada! Selo de verificação ativado"
```

### 3. Admin — Aprovar instituição

```
/admin/instituicoes → Lista de pedidos pendentes
  ├── Ver dados (nome, tipo, local, email, telefone)
  ├── Aprovar → schools.is_verified = true + institutions.request.status = 'approved'
  └── Rejeitar → institutions.request.status = 'rejected' + rejection_reason →
      Email ao owner: "Instituição rejeitada: {motivo}"
```

### 4. Instituição — Dashboard completo

```
/instituicao/dashboard → 3 tabs:
  ├── Turmas → CRUD classes + assignment de alunos
  ├── Alunos → Lista completa com:
  │   ├── Nome + Email + Turma
  │   ├── Últimas pontuações (quiz + competições)
  │   ├── Precisão média
  │   ├── Histórico de competições
  │   ├── Progresso flashcards (cartões estudados, revisões, mastery)
  │   └── Ranking interno (posição na instituição)
  └── Competições → Criar competição (máx 30/mês) + histórico
```

### 5. Instituição — Criar competição

```
/instituicao/competicoes/criar → Formulário:
  Nome + Configuração (perguntas, tempo, streak) + Selecionar turmas
  → Verifica quota (30/mês) → Cria competição →
  → Alunos das turmas selecionadas são notificados
```

## RLS — Matriz de permissões

| Tabela | Admin | Institution Owner | Institution Admin | Teacher | Student | Anon |
|---|---|---|---|---|---|---|
| `schools` | Tudo | Ler + Atualizar (só os seus) | Ler | Ler | Ler (publicadas) | Ler (publicadas) |
| `classes` | Tudo | Tudo (só os seus) | Ler + Criar | Ler + Atualizar (só as suas) | Ler (só a sua) | — |
| `institution_members` | Tudo | Tudo (só os seus) | Ler | Ler (só os seus alunos) | — | — |
| `institution_requests` | Tudo | Ler (só as suas) | — | — | — | — |
| `competitions` | Tudo | Criar (com quota) + Ler (só as suas) | Ler | Ler (só as suas) | Ler (só as que tem acesso) | — |

## Componentes frontend novos

| Componente | Localização | Descrição |
|---|---|---|
| `SchoolSearch` | `components/ui/SchoolSearch.jsx` | Combobox de pesquisa de escolas com debounce + botão "Adicionar" |
| `SchoolAddForm` | `components/ui/SchoolAddForm.jsx` | Formulário de submissão de nova escola (nome + localização) |
| `InstitutionDashboard` | `components/pages/InstitutionDashboard.jsx` | Dashboard completo (turmas, alunos, competições) |
| `InstitutionStudentsList` | `components/admin/InstitutionStudentsList.jsx` | Lista de alunos com stats detalhados |
| `InstitutionCompetitionsList` | `components/admin/InstitutionCompetitionsList.jsx` | Lista de competições da instituição |
| `AdminInstitutionRequests` | `components/admin/AdminInstitutionRequests.jsx` | Painel de aprovação de pedidos |
| `ProfileSchoolEditor` | `components/ui/ProfileSchoolEditor.jsx` | Editor de escola no perfil do aluno |

## Rotas novas

| Rota | Tipo | Descrição |
|---|---|---|
| `/[lang]/instituicao/criar` | Public | Formulário de criação de perfil |
| `/[lang]/instituicao/dashboard` | Protected (owner) | Dashboard da instituição |
| `/[lang]/instituicao/dashboard/turmas` | Protected (owner) | Gestão de turmas |
| `/[lang]/instituicao/dashboard/alunos` | Protected (owner) | Lista de alunos |
| `/[lang]/instituicao/dashboard/competicoes` | Protected (owner) | Gestão de competições |
| `/[lang]/instituicao/dashboard/competicoes/criar` | Protected (owner) | Criar competição |
| `/[lang]/admin/instituicoes` | Admin | Painel de aprovação |

## Server actions novas

| Action | Ficheiro | Descrição |
|---|---|---|
| `searchSchools(query)` | `lib/actions/schools.js` | Pesquisa de escolas por nome |
| `requestInstitution(data)` | `lib/actions/institutions.js` | Submeter pedido de verificação |
| `getUserInstitutionRequests()` | `lib/actions/institutions.js` | Ver pedidos do utilizador |
| `approveInstitution(requestId)` | `lib/actions/institutions.js` | Admin aprova (cria school + liga owner) |
| `rejectInstitution(requestId, reason)` | `lib/actions/institutions.js` | Admin rejeita |
| `getInstitutionDashboard(schoolId)` | `lib/actions/institutions.js` | Dashboard completo |
| `getInstitutionStudents(schoolId)` | `lib/actions/institutions.js` | Lista de alunos com stats |
| `getInstitutionStats(schoolId)` | `lib/actions/institutions.js` | Stats agregados |
| `createInstitutionCompetition(schoolId, data)` | `lib/actions/institutions.js` | Criar competição (com verificação de quota) |
| `claimSchoolToUser(schoolId)` | `lib/actions/schools.js` | Aluno liga escola existente ao seu perfil |
| `joinInstitution(schoolId, classId)` | `lib/actions/institutions.js` | Aluno entra na instituição |

## Roadmap de implementação

| Fase | O que | Tempo est. | Dependências |
|---|---|---|---|
| **1** | Migração: novos campos `schools` + `institution_members` + `institution_requests` | 1h | — |
| **2** | Aluno: `SchoolSearch` + `SchoolAddForm` no perfil (combobox + submissão) | 2h | Fase 1 |
| **3** | Instituição: formulário de criação + `requestInstitution` action | 2h | Fase 1 |
| **4** | Admin: `AdminInstitutionRequests` + approve/reject + email Brevo | 2h | Fase 3 |
| **5** | Instituição: dashboard (turmas + alunos + competições) | 4h | Fase 4 |
| **6** | Instituição: criar competições (com quota mensal) | 2h | Fase 5 |
| **7** | Badge verificado + filtros de busca + merge de escolas | 2h | Fase 4 |
| **8** | i18n + loading skeletons + polish | 1h | Todas |
| **Total** | | **~16h** | |

## i18n keys necessárias

### PT
```json
{
  "institution": {
    "create_title": "Registar Instituição",
    "create_description": "Cria um perfil para a tua instituição e gaining access to competition tools",
    "type_school": "Escola",
    "type_university": "Universidade",
    "type_course": "Curso",
    "type_association": "Associação",
    "dashboard_title": "Painel da Instituição",
    "students_title": "Alunos",
    "classes_title": "Turmas",
    "competitions_title": "Competições",
    "verified_badge": "Verificada",
    "pending_badge": "Pendente",
    "monthly_limit": "Limite mensal: {used}/{limit} competições",
    "request_submitted": "Pedido submetido! Será analisado pelo admin em breve.",
    "request_approved": "Instituição aprovada! Selo de verificação ativado.",
    "request_rejected": "Instituição rejeitada: {reason}",
    "search_placeholder": "Procura a tua escola...",
    "not_found": "Não encontraste a tua escola?",
    "add_new": "Adicionar Escola",
    "add_name": "Nome da escola",
    "add_location": "Localização (cidade/bairro)",
    "add_submitted": "Escola submetida! Aparecerá após aprovação.",
    "merge_prompt": "A instituição \"{name}\" foi verificada. Queres migrar para ela?",
    "merge_accept": "Sim, migrar",
    "merge_decline": "Não, manter",
    "stats_total_students": "Total de alunos",
    "stats_avg_accuracy": "Precisão média",
    "stats_competitions": "Competições realizadas"
  }
}
```

### EN
```json
{
  "institution": {
    "create_title": "Register Institution",
    "create_description": "Create a profile for your institution and gain access to competition tools",
    "type_school": "School",
    "type_university": "University",
    "type_course": "Course",
    "type_association": "Association",
    "dashboard_title": "Institution Dashboard",
    "students_title": "Students",
    "classes_title": "Classes",
    "competitions_title": "Competitions",
    "verified_badge": "Verified",
    "pending_badge": "Pending",
    "monthly_limit": "Monthly limit: {used}/{limit} competitions",
    "request_submitted": "Request submitted! It will be reviewed by an admin soon.",
    "request_approved": "Institution approved! Verification badge activated.",
    "request_rejected": "Institution rejected: {reason}",
    "search_placeholder": "Search for your school...",
    "not_found": "Can't find your school?",
    "add_new": "Add School",
    "add_name": "School name",
    "add_location": "Location (city/district)",
    "add_submitted": "School submitted! It will appear after approval.",
    "merge_prompt": "The institution \"{name}\" was verified. Do you want to migrate to it?",
    "merge_accept": "Yes, migrate",
    "merge_decline": "No, keep current",
    "stats_total_students": "Total students",
    "stats_avg_accuracy": "Average accuracy",
    "stats_competitions": "Competitions held"
  }
}
```

## Notas de implementação

### Reset mensal de competições (lazy)

```js
// Em createInstitutionCompetition:
const now = new Date();
const lastUpdate = new Date(school.updated_at);
if (lastUpdate.getMonth() !== now.getMonth() || lastUpdate.getFullYear() !== now.getFullYear()) {
  // Reset: mês anterior
  await supabase.from('schools')
    .update({ competitions_used_this_month: 0, updated_at: now.toISOString() })
    .eq('id', schoolId);
}
```

### Search de escolas (debounce + Índice)

```sql
-- Índice para LIKE '%query%' (usar pg_trgm se necessário)
CREATE INDEX idx_schools_name_trgm ON public.schools
  USING gin(name gin_trgm_ops);
```

### Email de notificação (Brevo Edge Function)

| Evento | Template | Destinatário |
|---|---|---|
| Pedido de verificação | `institution_request_pending` | Admin |
| Instituição aprovada | `institution_approved` | Owner |
| Instituição rejeitada | `institution_rejected` | Owner |
| Escola verificada (merge) | `school_verified_merge` | Alunos com escola homónima |

### Segurança

- **RLS**: `institution_members` com `institution_id` — cada utilizador só vê membros da sua instituição
- **Quota**: `competitions_used_this_month` verificada antes de criar competição
- **Aprovação**: `verification_status = 'pending'` impede que a instituição seja visível nos resultados de busca até admin aprovar
- **Owner check**: só o `owner_user_id` pode gerir a instituição (não membros com role `admin`)

---

## Checklist de implementação

- [ ] **Fase 1**: Migração SQL (schools novos campos + institution_members + institution_requests)
- [ ] **Fase 2**: SchoolSearch + SchoolAddForm no perfil do aluno
- [ ] **Fase 3**: Formulário de criação de instituição + server action
- [ ] **Fase 4**: Admin painel de aprovação + emails Brevo
- [ ] **Fase 5**: Dashboard completo (turmas, alunos, competições)
- [ ] **Fase 6**: Criar competições com quota mensal
- [ ] **Fase 7**: Badge verificado + filtros + merge de escolas
- [ ] **Fase 8**: i18n + loading skeletons + polish
